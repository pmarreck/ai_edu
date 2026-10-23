-- event/1 contract: validates an educational event before it may enter the log.
-- Enforces the canonical-state rule by actor: LLM roles may only emit proposals.
local event = {}

event.SCHEMA = "event/1"

local function set(list)
	local s = {}
	for _, v in ipairs(list) do s[v] = true end
	return s
end

local TYPES_BY_ACTOR_KIND = {
	learner = set({
		"student.response", "student.prediction", "student.self_explanation", "hint.requested",
		"answer.submitted", "activity.failure_reported", "challenge.raised", "break.requested",
	}),
	engine = set({
		"session.started", "activity.presented", "hint.given", "answer.scored",
		"observation.accepted", "observation.rejected", "misconception.confirmed",
		"break.offered", "break.started", "break.ended", "artifact.fallback_used",
		"lesson.completed", "retrieval.scheduled", "challenge.settled", "answer.corrected",
	}),
	parent = set({ "annotation.added" }),
	llm = set({ "lesson.planned", "tutor.response", "misconception.proposed", "observation.proposed" }),
}

local LLM_ROLES = set({ "planner", "tutor", "evaluator", "verifier", "research" })

local REQUIRED = {
	{ "schema", "string" }, { "id", "string" }, { "type", "string" }, { "actor", "string" },
	{ "learner_id", "string" }, { "occurred_at", "number" }, { "payload", "table" },
	{ "provenance", "table" },
}

-- Map an actor string to its permission kind; nil for unknown actors.
local function actor_kind(actor)
	if TYPES_BY_ACTOR_KIND[actor] and actor ~= "llm" then return actor end
	local role = actor:match("^llm:(.+)$")
	if role and LLM_ROLES[role] then return "llm" end
	return nil
end

local function nonempty_string(s) return type(s) == "string" and s ~= "" end

-- Payload contracts for event types that change canonical learner state.
local function score_error(p)
	if not nonempty_string(p.item_id) then return "payload.item_id must be a non-empty string" end
	if not nonempty_string(p.skill_id) then return "payload.skill_id must be a non-empty string" end
	if type(p.correct) ~= "boolean" then return "payload.correct must be a boolean" end
	local h = p.hint_level
	if type(h) ~= "number" or h < 0 or h ~= math.floor(h) then return "payload.hint_level must be a non-negative integer" end
end

local PAYLOAD_CHECKS = {
	["answer.scored"] = function(p)
		local err = score_error(p)
		if err then return err end
		local c = p.checkpoint
		if c ~= nil and (type(c) ~= "number" or c < 1 or c ~= math.floor(c)) then
			return "payload.checkpoint must be a positive whole number of days"
		end
	end,
	-- An upheld challenge reverses one earlier answer.scored event, named by its id.
	["answer.corrected"] = function(p)
		local err = score_error(p)
		if err then return err end
		if not nonempty_string(p.corrects) then return "payload.corrects must name the corrected answer.scored event" end
		if type(p.was_correct) ~= "boolean" or p.was_correct == p.correct then
			return "payload.was_correct must be the opposite boolean of payload.correct"
		end
	end,
	["challenge.settled"] = function(p)
		if not nonempty_string(p.item_id) then return "payload.item_id must be a non-empty string" end
		if type(p.upheld) ~= "boolean" then return "payload.upheld must be a boolean" end
		if not nonempty_string(p.oracle) then return "payload.oracle must be a non-empty string" end
		if type(p.proof) ~= "string" then return "payload.proof must be a string" end
	end,
}

-- Returns true, or nil plus a reason naming the offending field or rule.
function event.validate(e)
	if type(e) ~= "table" then return nil, "event must be a table" end
	for _, spec in ipairs(REQUIRED) do
		local field, ty = spec[1], spec[2]
		if type(e[field]) ~= ty then return nil, field .. " must be a " .. ty end
	end
	if e.schema ~= event.SCHEMA then return nil, "schema must be " .. event.SCHEMA end
	if e.id == "" then return nil, "id must be non-empty" end
	if e.occurred_at ~= math.floor(e.occurred_at) then return nil, "occurred_at must be integer ms" end
	if e.seq ~= nil then return nil, "seq is assigned by the log" end
	if type(e.provenance.policy_version) ~= "string" then
		return nil, "provenance.policy_version must be a string"
	end
	local kind = actor_kind(e.actor)
	if not kind then return nil, "unknown actor " .. e.actor end
	if not TYPES_BY_ACTOR_KIND[kind][e.type] then
		return nil, e.actor .. " may not emit " .. e.type
	end
	local check = PAYLOAD_CHECKS[e.type]
	local payload_err = check and check(e.payload)
	if payload_err then return nil, payload_err end
	return true
end

return event
