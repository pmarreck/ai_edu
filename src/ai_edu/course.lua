-- Course as pure functions of (definition, events, now): lessons unlocked by calendar day,
-- session numbering, completion and resumption are all derived from the event log. Starting a
-- lesson returns a session state plus the session.started event for the shell to append.
local session = require("ai_edu.session")

local course = {}

-- opts: lessons = { {id, title, day, items} }, learner_id, policy_version,
-- day_index(ms) -> calendar day (injected so the core never reads a time zone),
-- reviews (optional provider): due(events, now) -> skills; plan(events, now, due) -> a
-- serializable plan; lesson(plan) -> { id = "review", title, items }.
function course.define(opts)
	local by_id = {}
	for _, l in ipairs(opts.lessons) do by_id[l.id] = l end
	return { lessons = opts.lessons, by_id = by_id, learner_id = opts.learner_id,
		policy_version = opts.policy_version, day_index = opts.day_index, reviews = opts.reviews }
end

-- This learner's course start, per-lesson session counts, completions and latest session.
local function history(def, events)
	local h = { started = {}, completed = {}, finished_sessions = {} }
	for _, e in ipairs(events) do
		if e.learner_id == def.learner_id then
			if e.type == "session.started" and e.payload.lesson_id then
				h.start_ms = h.start_ms or e.occurred_at
				h.started[e.payload.lesson_id] = (h.started[e.payload.lesson_id] or 0) + 1
				h.last = e.payload
			elseif e.type == "lesson.completed" then
				h.completed[e.payload.lesson_id] = true
				h.finished_sessions[e.payload.session_id] = true
			end
		end
	end
	return h
end

local function unlocked(def, lesson, start_ms, now)
	if lesson.day == 0 then return true end
	if not start_ms then return false end
	return def.day_index(now) - def.day_index(start_ms) >= lesson.day
end

function course.status(def, events, now)
	local h = history(def, events)
	local out = {}
	for _, l in ipairs(def.lessons) do
		out[#out + 1] = { id = l.id, title = l.title, day = l.day,
			unlocked = unlocked(def, l, h.start_ms, now), completed = h.completed[l.id] == true }
	end
	if def.reviews then
		local due = def.reviews:due(events, now)
		out[#out + 1] = { id = "review", title = "Review", day = 0, unlocked = #due > 0, completed = false, due = #due }
	end
	return out
end

local function new_session(def, lesson, session_id)
	return session.init({ items = lesson.items, learner_id = def.learner_id, session_id = session_id,
		policy_version = def.policy_version, lesson_id = lesson.id })
end

-- Returns a fresh session state and { session.started }, or nil plus a reason.
function course.start(def, events, now, lesson_id)
	local lesson, plan = def.by_id[lesson_id], nil
	local h = history(def, events)
	if lesson_id == "review" and def.reviews then
		local due = def.reviews:due(events, now)
		if #due == 0 then return nil, "nothing due for review" end
		plan = def.reviews:plan(events, now, due)
		lesson = def.reviews:lesson(plan)
	end
	if not lesson then return nil, "unknown lesson " .. tostring(lesson_id) end
	if not plan and not unlocked(def, lesson, h.start_ms, now) then return nil, "lesson " .. lesson_id .. " is locked" end
	local session_id = lesson_id .. "#" .. ((h.started[lesson_id] or 0) + 1)
	local st, err = new_session(def, lesson, session_id)
	if not st then return nil, err end
	return st, { {
		schema = "event/1", id = session_id .. ":start", type = "session.started", actor = "engine",
		learner_id = def.learner_id, occurred_at = now,
		payload = { lesson_id = lesson_id, session_id = session_id, plan = plan },
		provenance = { policy_version = def.policy_version },
	} }
end

-- The most recent unfinished session, rebuilt from the log; nil if there is none.
function course.resume(def, events)
	local h = history(def, events)
	local last = h.last
	if not last or h.finished_sessions[last.session_id] then return nil end
	local lesson = def.by_id[last.lesson_id]
	if last.lesson_id == "review" and def.reviews and last.plan then lesson = def.reviews:lesson(last.plan) end
	if not lesson then return nil end
	local st = new_session(def, lesson, last.session_id)
	return st and session.restore(st, events)
end

return course
