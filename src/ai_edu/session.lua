-- Session engine as pure transitions: each function takes a session state and `now`, and
-- returns a NEW state plus the events to append (event/1 records without seq). It never reads
-- a clock, touches a log or mutates its inputs; the imperative shell (http_app) does that.
local item = require("ai_edu.item")

local session = {}

local MODALITIES = { tap = true, type = true, speak = true, draw = true }

-- "I think you're wrong" and "This isn't working right": logged for review, never scored.
local REPORT_TYPES = {
	wrong = "challenge.raised", broken = "activity.failure_reported", confusing = "activity.failure_reported",
	too_easy = "activity.failure_reported", too_hard = "activity.failure_reported", other = "activity.failure_reported",
}

local function copy(t)
	local c = {}
	for k, v in pairs(t) do c[k] = v end
	return c
end

-- A shallow successor state; `answered` and `open` are copied only when a transition changes them.
local function successor(st, changes)
	local s = copy(st)
	for k, v in pairs(changes) do s[k] = v end
	return s
end

-- Build sequential events for this session, returning them and the advanced id counter.
local function make_events(st, now, specs)
	local events, counter = {}, st.counter
	for _, spec in ipairs(specs) do
		counter = counter + 1
		events[#events + 1] = {
			schema = "event/1", id = st.session_id .. ":" .. counter, type = spec[2], actor = spec[1],
			learner_id = st.learner_id, occurred_at = now, payload = spec[3],
			provenance = { policy_version = st.policy_version },
		}
	end
	return events, counter
end

-- opts: items, learner_id, session_id, policy_version, lesson_id (optional; finishing a lesson
-- session emits lesson.completed once), feedback (default true; false records answers without
-- revealing anything, for checkpoints). Returns a state, or nil plus the first invalid item.
function session.init(opts)
	local items, order = {}, {}
	for _, it in ipairs(opts.items) do
		local ok, err = item.validate(it)
		if not ok then return nil, "item " .. tostring(it.id) .. ": " .. err end
		items[it.id] = it
		order[#order + 1] = it.id
	end
	return {
		items = items, order = order, learner_id = opts.learner_id, session_id = opts.session_id,
		policy_version = opts.policy_version, lesson_id = opts.lesson_id, feedback = opts.feedback ~= false,
		answered = {}, open = {}, completed = false, counter = 0,
	}
end

-- Present an item: returns state, events, key-free view (or nil plus a reason).
function session.present(st, item_id, now)
	local it = st.items[item_id]
	if not it then return nil, "unknown item " .. tostring(item_id) end
	local events, counter = make_events(st, now, {
		{ "engine", "activity.presented", { item_id = item_id, session_id = st.session_id } },
	})
	local open = copy(st.open)
	open[item_id] = now
	return successor(st, { open = open, counter = counter }), events, item.public_view(it)
end

-- Present the first unanswered item in bank order. When all are answered returns
-- state, events, nil, true (events hold lesson.completed the first time for a lesson session).
function session.next(st, now)
	for _, id in ipairs(st.order) do
		if not st.answered[id] then return session.present(st, id, now) end
	end
	if st.lesson_id and not st.completed then
		local events, counter = make_events(st, now, {
			{ "engine", "lesson.completed", { lesson_id = st.lesson_id, session_id = st.session_id } },
		})
		return successor(st, { completed = true, counter = counter }), events, nil, true
	end
	return st, {}, nil, true
end

-- Score one answer to an open presentation: returns state, events, result (or nil plus a
-- reason, emitting nothing and leaving the presentation open). Info cards are acknowledged.
function session.submit(st, item_id, answer, meta, now)
	local presented_at = st.open[item_id]
	if not presented_at then return nil, "item " .. tostring(item_id) .. " not presented" end
	if not MODALITIES[meta.modality] then return nil, "unknown modality " .. tostring(meta.modality) end
	local h = meta.hint_level
	if type(h) ~= "number" or h < 0 or h ~= math.floor(h) then return nil, "hint_level must be a non-negative integer" end
	local it = st.items[item_id]
	local result, err = item.score(it, answer)
	if not result then return nil, err end
	local open, answered = copy(st.open), copy(st.answered)
	open[item_id], answered[item_id] = nil, true
	local specs, out
	if result.ack then
		specs = { { "learner", "student.response", { item_id = item_id, session_id = st.session_id, ack = true } } }
		out = { ack = true }
	else
		specs = { { "learner", "answer.submitted", { item_id = item_id, session_id = st.session_id, answer = answer,
			modality = meta.modality, latency_ms = now - presented_at } } }
		-- practice-only items (awaiting approval) give feedback but write no score
		for _, skill_id in ipairs(it.graded == false and {} or it.skill_ids) do
			specs[#specs + 1] = { "engine", "answer.scored",
				{ item_id = item_id, skill_id = skill_id, correct = result.correct, hint_level = h,
					checkpoint = it.checkpoint } }
		end
		out = st.feedback and { correct = result.correct, reveal = item.reveal(it, answer), practice = it.graded == false or nil }
			or { recorded = true }
	end
	local events, counter = make_events(st, now, specs)
	local record = { ack = result.ack, answer = answer, correct = result.correct, hint_level = h, scored = {} }
	for _, e in ipairs(events) do
		if e.type == "answer.scored" then record.scored[#record.scored + 1] = { id = e.id, skill_id = e.payload.skill_id } end
	end
	answered[item_id] = record
	return successor(st, { open = open, answered = answered, counter = counter }), events, out
end

-- "I think you're wrong", settled by an oracle instead of the stored key: judge(item, answer)
-- returns { correct, proof } or nil plus a reason. When the oracle disagrees with the logged score
-- the challenge is upheld and each score event is reversed by an answer.corrected naming it.
-- Works in both directions (wrong marked right too). Returns state, events, { upheld, correct,
-- proof }, or nil plus a reason with no events, so the shell can fall back to a plain report.
function session.challenge(st, item_id, note, judge, oracle, now)
	if not st.feedback then return nil, "checkpoint answers are not revealed, so they cannot be challenged" end
	local rec = st.answered[item_id]
	if not rec or rec.ack or rec.correct == nil then return nil, "item " .. tostring(item_id) .. " has no scored answer" end
	local verdict, err = judge(st.items[item_id], rec.answer)
	if not verdict then return nil, err end
	local upheld = verdict.correct ~= rec.correct
	local specs = {
		{ "learner", "challenge.raised", { kind = "wrong", item_id = item_id, session_id = st.session_id,
			note = type(note) == "string" and note or "" } },
		{ "engine", "challenge.settled", { item_id = item_id, session_id = st.session_id, upheld = upheld,
			oracle = oracle.name, proof = verdict.proof } },
	}
	local answered = st.answered
	if upheld then
		for _, sc in ipairs(rec.scored) do
			specs[#specs + 1] = { "engine", "answer.corrected", { item_id = item_id, skill_id = sc.skill_id,
				correct = verdict.correct, was_correct = rec.correct, hint_level = rec.hint_level, corrects = sc.id } }
		end
		local fixed = copy(rec)
		fixed.correct = verdict.correct
		answered = copy(st.answered)
		answered[item_id] = fixed
	end
	local events, counter = make_events(st, now, specs)
	return successor(st, { answered = answered, counter = counter }), events,
		{ upheld = upheld, correct = verdict.correct, proof = verdict.proof }
end

function session.report(st, kind, item_id, note, now)
	local type_ = REPORT_TYPES[kind]
	if not type_ then return nil, "unknown report kind " .. tostring(kind) end
	local events, counter = make_events(st, now, { { "learner", type_, { kind = kind, item_id = tostring(item_id),
		session_id = st.session_id, note = type(note) == "string" and note or "" } } })
	return successor(st, { counter = counter }), events
end

-- Rebuild answered/open/completed state and the event-id counter from this session's logged
-- events, so a lesson survives a server restart.
function session.restore(st, events)
	local open, answered, counter, completed = copy(st.open), copy(st.answered), st.counter, st.completed
	local prefix = st.session_id .. ":"
	for _, e in ipairs(events) do
		local n = e.id:sub(1, #prefix) == prefix and tonumber(e.id:sub(#prefix + 1))
		if n and n > counter then counter = n end
		if n then
			local id = e.payload.item_id
			if e.type == "activity.presented" then open[id] = e.occurred_at
			elseif e.type == "student.response" then
				open[id], answered[id] = nil, { ack = true }
			elseif e.type == "answer.submitted" then
				open[id], answered[id] = nil, { answer = e.payload.answer, scored = {} }
			elseif e.type == "answer.scored" and answered[id] then
				local rec = copy(answered[id])
				rec.scored = copy(rec.scored)
				rec.scored[#rec.scored + 1] = { id = e.id, skill_id = e.payload.skill_id }
				rec.correct, rec.hint_level = e.payload.correct, e.payload.hint_level
				answered[id] = rec
			elseif e.type == "answer.corrected" and answered[id] then
				local rec = copy(answered[id])
				rec.correct = e.payload.correct
				answered[id] = rec
			elseif e.type == "lesson.completed" then completed = true end
		end
	end
	return successor(st, { open = open, answered = answered, counter = counter, completed = completed })
end

-- Position (1-based) of the next unanswered item and the lesson length, for the progress display.
function session.progress(st)
	local answered = 0
	for _, id in ipairs(st.order) do if st.answered[id] then answered = answered + 1 end end
	return { position = math.min(answered + 1, #st.order), total = #st.order }
end

return session
