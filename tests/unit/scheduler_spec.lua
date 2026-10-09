local scheduler = require("ai_edu.scheduler")

local DAY = 86400000
local T0 = 1790000000000
local function day_index(ms) return math.floor(ms / DAY) end

-- Build a log: sessions = { {day, session_id, { {skill, correct}, ... }} }
local function log_of(sessions)
	local events, seq = {}, 0
	local function add(e) seq = seq + 1; e.seq = seq; events[seq] = e end
	for _, s in ipairs(sessions) do
		local t = T0 + s[1] * DAY
		for i, a in ipairs(s[3]) do
			add({ type = "answer.submitted", learner_id = "L", occurred_at = t + i, payload = { item_id = "i" .. i, session_id = s[2] } })
			add({ type = "answer.scored", learner_id = "L", occurred_at = t + i,
				payload = { item_id = "i" .. i, skill_id = a[1], correct = a[2], hint_level = a[3] or 0 } })
		end
	end
	return events
end

local function due_days(state, skill)
	return day_index(state.learners.L.skills[skill].due_at) - day_index(T0)
end

describe("scheduler (ladder model)", function()
	it("schedules the first review one day after a session that met the first-session criterion", function()
		local st = scheduler.replay(log_of({ { 0, "S1", { { "sq", true }, { "sq", true } } } }))
		assert.equal(1, due_days(st, "sq"))
		assert.equal(1, st.learners.L.skills.sq.rung)
	end)

	it("requires 2 correct in the first session; 1 correct is relearned next day without climbing", function()
		local st = scheduler.replay(log_of({ { 0, "S1", { { "sq", true }, { "sq", false } } } }))
		assert.equal(0, st.learners.L.skills.sq.rung)
		assert.equal(1, due_days(st, "sq"))
	end)

	it("climbs the 1, 3, 7, 16, 35 day ladder on successive successful reviews", function()
		local sessions = { { 0, "S1", { { "sq", true }, { "sq", true } } } }
		local day, expected = 0, {}
		for rung, gap in ipairs({ 1, 3, 7, 16 }) do
			day = day + gap
			sessions[#sessions + 1] = { day, "R" .. rung, { { "sq", true } } }
			expected[#expected + 1] = ({ 3, 7, 16, 35 })[rung]
		end
		local st = scheduler.replay(log_of(sessions))
		assert.equal(day + 35, due_days(st, "sq"))
		assert.equal(5, st.learners.L.skills.sq.rung)
	end)

	it("drops a failed review back to relearning the next day and counts the lapse", function()
		local st = scheduler.replay(log_of({
			{ 0, "S1", { { "sq", true }, { "sq", true } } },
			{ 1, "R1", { { "sq", true } } },
			{ 4, "R2", { { "sq", false } } },
		}))
		local s = st.learners.L.skills.sq
		assert.same({ 0, 1 }, { s.rung, s.lapses })
		assert.equal(5, due_days(st, "sq"))
	end)

	it("ignores assisted attempts for scheduling, since they are not independent retrieval", function()
		local st = scheduler.replay(log_of({ { 0, "S1", { { "sq", true, 2 }, { "sq", true, 1 } } } }))
		assert.is_nil(st.learners.L)
	end)

	it("lists due skills for a day, most overdue first", function()
		local st = scheduler.replay(log_of({
			{ 0, "S1", { { "a", true }, { "a", true }, { "b", true }, { "b", false } } },
			{ 1, "S2", { { "c", true }, { "c", true } } },
		}))
		assert.same({}, scheduler.due(st, "L", T0, day_index))
		assert.same({ "a", "b" }, scheduler.due(st, "L", T0 + DAY, day_index))
		assert.same({ "a", "b", "c" }, scheduler.due(st, "L", T0 + 2 * DAY, day_index))
	end)

	it("is a pure fold: replaying a prefix then the rest equals replaying everything", function()
		local events = log_of({ { 0, "S1", { { "a", true }, { "a", true } } }, { 1, "S2", { { "a", false } } } })
		local canonical = require("ai_edu.canonical")
		assert.equal(canonical.encode(scheduler.replay(events)), canonical.encode(scheduler.replay(events)))
	end)
end)
