-- learner-projection/1: canonical learner state derived only by folding the event log.
-- Only engine-scored answers change state; LLM proposals are never read, so a model
-- cannot move mastery evidence and swapping vendors cannot change the result.
local projection = {}

projection.SCHEMA = "learner-projection/1"

function projection.empty()
	return { schema = projection.SCHEMA, last_seq = 0, learners = {} }
end

local function scored_payload_error(p)
	if type(p.skill_id) ~= "string" or p.skill_id == "" then return "skill_id must be a non-empty string" end
	if type(p.correct) ~= "boolean" then return "correct must be a boolean" end
	local h = p.hint_level
	if type(h) ~= "number" or h < 0 or h ~= math.floor(h) then return "hint_level must be a non-negative integer" end
	return nil
end

local function shallow(t)
	local c = {}
	for k, v in pairs(t or {}) do c[k] = v end
	return c
end

-- The skill record after one scored attempt, as a new table (the old one is untouched).
local function scored_skill(old, payload, occurred_at)
	old = old or { independent = { attempts = 0, correct = 0 }, assisted = { attempts = 0, correct = 0 } }
	local skill = shallow(old)
	-- Checkpoint attempts measure delayed retention; they get their own bucket, never practice's.
	local which = payload.checkpoint and "checkpoint" or payload.hint_level == 0 and "independent" or "assisted"
	local bucket = shallow(old[which] or { attempts = 0, correct = 0 })
	bucket.attempts = bucket.attempts + 1
	if payload.correct then
		bucket.correct = bucket.correct + 1
		if which == "independent" then skill.last_independent_success_at = occurred_at end
	end
	skill[which] = bucket
	return skill
end

-- The skill record after an upheld challenge reverses one earlier score: one correct count moves
-- in that attempt's bucket. Attempts are unchanged, and so is last_independent_success_at,
-- which reflects scored events only.
local function corrected_skill(old, payload)
	if not old then return nil, "no scored attempt to correct" end
	local skill = shallow(old)
	local which = payload.hint_level == 0 and "independent" or "assisted"
	local bucket = shallow(old[which])
	bucket.correct = bucket.correct + (payload.correct and 1 or -1)
	if bucket.correct < 0 or bucket.correct > bucket.attempts then return nil, "correction out of range" end
	skill[which] = bucket
	return skill
end

-- Fold one logged event into a NEW projection (structural sharing: only the changed learner
-- and skill path is copied), or return nil plus a reason. Any hint (hint_level > 0) makes the
-- attempt assisted: assisted success is not independent mastery.
-- complexity: O(learners + skills of that learner) per scored event.
function projection.step(proj, e)
	local out = { schema = proj.schema, last_seq = e.seq, learners = proj.learners }
	if e.type == "answer.scored" or e.type == "answer.corrected" then
		local err = scored_payload_error(e.payload)
		if err then return nil, string.format("seq %d: %s", e.seq, err) end
		local learners = shallow(proj.learners)
		local learner = shallow(learners[e.learner_id])
		learner.skills = shallow(learner.skills)
		local old, skill = learner.skills[e.payload.skill_id]
		if e.type == "answer.scored" then
			skill = scored_skill(old, e.payload, e.occurred_at)
		else
			skill, err = corrected_skill(old, e.payload)
			if not skill then return nil, string.format("seq %d: %s", e.seq, err) end
		end
		learner.skills[e.payload.skill_id] = skill
		learners[e.learner_id] = learner
		out.learners = learners
	end
	return out
end

-- Rebuild the projection from scratch; the event log, not this state, is the source of truth.
function projection.replay(events)
	local proj = projection.empty()
	for _, e in ipairs(events) do
		local err
		proj, err = projection.step(proj, e)
		if not proj then return nil, err end
	end
	return proj
end

return projection
