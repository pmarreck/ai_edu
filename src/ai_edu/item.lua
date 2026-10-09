-- item/1 contract: one assessment or practice question, its answer key, and scoring.
-- The input modality (tap, type, speak) is recorded on events; scoring depends only on answer shape.
local item = {}

item.SCHEMA = "item/1"

local function nonempty_string(s) return type(s) == "string" and s ~= "" end

-- Normalize typed text for exact matching: trim and case-fold only, so punctuation still counts.
local function normalize(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""):lower())
end

local kinds = {}

kinds.choice = {
	validate = function(it)
		local choices = it.response.choices
		if type(choices) ~= "table" or #choices < 2 then return "choice items need at least 2 choices" end
		local seen = {}
		for _, c in ipairs(choices) do
			if not nonempty_string(c.id) or seen[c.id] then return "choice ids must be unique non-empty strings" end
			seen[c.id] = true
		end
		if not seen[it.key.choice] then return "key.choice must name a choice" end
	end,
	score = function(it, answer)
		if type(answer.choice) ~= "string" then return nil, "choice answer required" end
		for _, c in ipairs(it.response.choices) do
			if c.id == answer.choice then return { correct = answer.choice == it.key.choice } end
		end
		return nil, "unknown choice " .. answer.choice
	end,
}

kinds.typed = {
	validate = function(it)
		local accepted = it.key.accepted
		if type(accepted) ~= "table" or #accepted == 0 then return "typed items need key.accepted" end
	end,
	score = function(it, answer)
		if type(answer.text) ~= "string" then return nil, "text answer required" end
		local given = normalize(answer.text)
		for _, a in ipairs(it.key.accepted) do
			if given == normalize(a) then return { correct = true } end
		end
		return { correct = false }
	end,
}

-- Explanation or worked-example card: acknowledged, never scored.
kinds.info = {
	validate = function() end,
	score = function(_, answer)
		if answer.ack ~= true then return nil, "ack required" end
		return { ack = true }
	end,
}

kinds.move = {
	validate = function(it)
		local legal = it.response.legal_moves
		if type(it.prompt.board) ~= "table" then return "move items need prompt.board" end
		if type(legal) ~= "table" or #legal == 0 then return "move items need response.legal_moves" end
		local is_legal = {}
		for _, m in ipairs(legal) do is_legal[m] = true end
		local accepted = it.key.accepted
		if type(accepted) ~= "table" or #accepted == 0 then return "move items need key.accepted" end
		for _, m in ipairs(accepted) do
			if not is_legal[m] then return "accepted move " .. tostring(m) .. " is not legal" end
		end
	end,
	score = function(it, answer)
		if type(answer.move) ~= "string" then return nil, "move answer required" end
		local legal = false
		for _, m in ipairs(it.response.legal_moves) do legal = legal or m == answer.move end
		if not legal then return nil, "illegal move " .. answer.move end
		for _, m in ipairs(it.key.accepted) do
			if m == answer.move then return { correct = true } end
		end
		return { correct = false }
	end,
}

-- Returns true, or nil plus a reason.
function item.validate(it)
	if type(it) ~= "table" or it.schema ~= item.SCHEMA then return nil, "schema must be " .. item.SCHEMA end
	if not nonempty_string(it.id) then return nil, "id required" end
	if type(it.skill_ids) ~= "table" or #it.skill_ids == 0 then return nil, "skill_ids required" end
	if type(it.prompt) ~= "table" or not (nonempty_string(it.prompt.text) or nonempty_string(it.prompt.audio)) then
		return nil, "prompt needs text or audio"
	end
	if type(it.response) ~= "table" or not kinds[it.response.kind] then return nil, "unknown response kind" end
	if type(it.key) ~= "table" then return nil, "key required" end
	if type(it.provenance) ~= "table" or not nonempty_string(it.provenance.policy_version) then
		return nil, "provenance.policy_version required"
	end
	local err = kinds[it.response.kind].validate(it)
	if err then return nil, err end
	return true
end

local function copy(v)
	if type(v) ~= "table" then return v end
	local c = {}
	for k, x in pairs(v) do c[k] = copy(x) end
	return c
end

-- What the client may see: an allowlist of fields, so a new secret field cannot leak by default.
function item.public_view(it)
	return { schema = it.schema, id = it.id, prompt = copy(it.prompt), response = copy(it.response) }
end

-- Deterministic scoring; returns { correct = bool }, or nil plus a reason for a malformed answer.
function item.score(it, answer)
	return kinds[it.response.kind].score(it, answer)
end


-- The correct answer plus any explanation, shown only after the learner has answered.
-- Refutations are keyed by wrong answer; only the one for the answer given is revealed.
function item.reveal(it, answer)
	local out = {}
	for k, v in pairs(copy(it.key)) do
		if k ~= "refutations" then out[k] = v end
	end
	out.feedback = it.feedback
	local r = answer and answer.move and it.key.refutations and it.key.refutations[answer.move]
	if r then out.refutation = r.text end
	return out
end

return item
