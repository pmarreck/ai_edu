-- Spaced-review scheduler: a pure fold over the event log giving, per learner and skill, a
-- memory state and the next due time. Successive relearning: a session succeeds for a skill
-- when its independent correct answers meet the criterion (2 in the first session, 1 later)
-- and the last attempt was correct. The interval model is swappable; the default is the
-- approved starting ladder (1, 3, 7, 16, 35 days), used until a model is fitted per learner.
local scheduler = {}

local DAY_MS = 86400000

scheduler.ladder = {
	name = "ladder@1",
	gaps_days = { 1, 3, 7, 16, 35 },
	-- Days until the next review after reaching `rung` (0 = relearning).
	interval_days = function(self, rung)
		if rung == 0 then return self.gaps_days[1] end
		return self.gaps_days[math.min(rung, #self.gaps_days)]
	end,
}

local DEFAULTS = { model = scheduler.ladder, first_criterion = 2, later_criterion = 1 }

local function copy(t)
	local c = {}
	for k, v in pairs(t or {}) do c[k] = v end
	return c
end

-- A new skill state after one completed session, from the session's attempts for that skill.
local function after_session(old, attempts, ended_at, opts)
	local correct, last_correct = 0, false
	for _, a in ipairs(attempts) do
		if a then correct = correct + 1 end
		last_correct = a
	end
	local first = old == nil
	local s = copy(old or { rung = 0, lapses = 0, sessions = 0 })
	local criterion = first and opts.first_criterion or opts.later_criterion
	if correct >= criterion and last_correct then
		s.rung = s.rung + 1
	else
		if not first and s.rung > 0 then s.lapses = s.lapses + 1 end
		s.rung = 0
	end
	s.sessions = s.sessions + 1
	s.last_session_at = ended_at
	s.due_at = ended_at + opts.model:interval_days(s.rung) * DAY_MS
	return s
end

-- Fold the log into { model, learners = { [id] = { skills = { [skill] = state } } } }.
-- Attempts are grouped by the session named on the preceding answer.submitted event.
-- complexity: O(events).
function scheduler.replay(events, opts)
	opts = setmetatable(copy(opts), { __index = DEFAULTS })
	local learners = {}
	local current = {}   -- learner -> session id of the latest submission
	local pending = {}   -- learner -> { session, ended_at, skills = { [skill] = { attempts } } }

	local function close(learner_id)
		local p = pending[learner_id]
		if not p then return end
		local learner = copy(learners[learner_id] or { skills = {} })
		learner.skills = copy(learner.skills)
		for skill, attempts in pairs(p.skills) do
			learner.skills[skill] = after_session(learner.skills[skill], attempts, p.ended_at, opts)
		end
		learners[learner_id] = learner
		pending[learner_id] = nil
	end

	-- Upheld challenges reverse earlier scores by event id, wherever they fall in the log.
	local corrected = {}
	for _, e in ipairs(events) do
		if e.type == "answer.corrected" then corrected[e.payload.corrects] = e.payload.correct end
	end

	for _, e in ipairs(events) do
		local id = e.learner_id
		if e.type == "answer.submitted" then
			if pending[id] and pending[id].session ~= e.payload.session_id then close(id) end
			current[id] = e.payload.session_id
		elseif e.type == "answer.scored" and e.payload.hint_level == 0 then
			local p = pending[id] or { session = current[id], skills = {} }
			local attempts = p.skills[e.payload.skill_id] or {}
			local c = corrected[e.id]
			if c == nil then c = e.payload.correct end
			attempts[#attempts + 1] = c == true
			p.skills[e.payload.skill_id] = attempts
			p.ended_at = e.occurred_at
			pending[id] = p
		end
	end
	for id in pairs(pending) do close(id) end
	return { model = opts.model.name, learners = learners }
end

-- Skills due for review on the calendar day of `now`, most overdue first (ties by name).
function scheduler.due(state, learner_id, now, day_index)
	local learner = state.learners[learner_id]
	if not learner then return {} end
	local today, due = day_index(now), {}
	for skill, s in pairs(learner.skills) do
		if day_index(s.due_at) <= today then due[#due + 1] = { skill = skill, at = s.due_at } end
	end
	table.sort(due, function(a, b)
		if a.at ~= b.at then return a.at < b.at end
		return a.skill < b.skill
	end)
	local out = {}
	for i, d in ipairs(due) do out[i] = d.skill end
	return out
end

return scheduler
