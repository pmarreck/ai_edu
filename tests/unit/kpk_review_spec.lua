local kpk = require("ai_edu.kpk")
local kpk_review = require("ai_edu.kpk_review")
local kpk_content = require("ai_edu.kpk_content")
local kpk_gen = require("ai_edu.kpk_gen")
local item = require("ai_edu.item")

local solved = kpk.shared()
local DAY = 86400000
local T0 = 1790000000000
local function day_index(ms) return math.floor(ms / DAY) end
local lessons = assert(kpk_content.build(solved, dofile("content/kpk_week.lua")))

-- A first lesson session that met the criterion for two skills on day 0.
local function log_day0()
	local events, seq = {}, 0
	local function add(e) seq = seq + 1; e.seq = seq; e.learner_id = "learner"; events[seq] = e end
	for i, skill in ipairs({ "kpk.square", "kpk.square", "kpk.opposition", "kpk.opposition" }) do
		add({ type = "answer.submitted", occurred_at = T0 + i, payload = { item_id = "x" .. i, session_id = "S1" } })
		add({ type = "answer.scored", occurred_at = T0 + i, payload = { item_id = "x" .. i, skill_id = skill, correct = true, hint_level = 0 } })
	end
	return events
end

local function provider() return kpk_review.new({ solved = solved, lessons = lessons, learner_id = "learner", day_index = day_index }) end

describe("kpk_review provider", function()
	it("reports scheduler-due skills that have a generator", function()
		local p = provider()
		assert.same({}, p:due(log_day0(), T0))
		assert.same({ "kpk.opposition", "kpk.square" }, p:due(log_day0(), T0 + DAY))
	end)

	it("plans fresh, never-seen positions, interleaved across due skills", function()
		local p = provider()
		local plan = p:plan(log_day0(), T0 + DAY, p:due(log_day0(), T0 + DAY))
		local authored = {}
		for _, l in ipairs(lessons) do
			for _, it in ipairs(l.items) do
				if it.prompt.board and it.prompt.board.wk then authored[kpk_gen.position_key(it.prompt.board)] = true end
			end
		end
		local concepts, seen = {}, {}
		for i, c in ipairs(plan.cards) do
			local key = kpk_gen.position_key(c.board)
			assert.is_nil(authored[key], "reused a lesson position")
			assert.is_nil(seen[key], "duplicate position")
			seen[key] = true
			concepts[i] = c.concept
		end
		assert.same({ "opposition", "square", "opposition", "square" }, concepts)
	end)

	it("excludes generated positions the learner was already shown", function()
		local p = provider()
		local events = log_day0()
		local first = p:plan(events, T0 + DAY, { "kpk.square" })
		local shown = "gen-square-" .. kpk_gen.position_key(first.cards[1].board)
		events[#events + 1] = { seq = #events + 1, learner_id = "learner", type = "activity.presented", occurred_at = T0 + DAY,
			payload = { item_id = shown, session_id = "R1" } }
		for _, c in ipairs(p:plan(events, T0 + DAY, { "kpk.square" }).cards) do
			assert.are_not.equal(shown, "gen-square-" .. kpk_gen.position_key(c.board))
		end
	end)

	it("rebuilds the same verified lesson from a logged plan", function()
		local p = provider()
		local plan = p:plan(log_day0(), T0 + DAY, { "kpk.opposition", "kpk.square" })
		local a, b = p:lesson(plan), p:lesson(plan)
		assert.equal("review", a.id)
		assert.same(a, b)
		assert.equal("info", a.items[1].response.kind)
		assert.equal(#plan.cards + 1, #a.items)
		for _, it in ipairs(a.items) do assert.is_true(item.validate(it), it.id) end
	end)
end)

describe("kpk checkpoint provider", function()
	local function cp() return kpk_review.checkpoints({ solved = solved, lessons = lessons, learner_id = "learner", day_index = day_index }) end

	it("is due a day after first practice, with the offset", function()
		assert.same({}, cp():due(log_day0(), T0))
		assert.same({ { skill = "kpk.opposition", offset = 1 }, { skill = "kpk.square", offset = 1 } }, cp():due(log_day0(), T0 + DAY))
	end)

	it("builds a no-feedback lesson of fresh verified positions tagged with their checkpoint", function()
		local p = cp()
		local now = T0 + 7 * DAY
		local due = p:due(log_day0(), now)
		assert.equal(7, due[1].offset)
		local plan = p:plan(log_day0(), now, due)
		local lesson = p:lesson(plan)
		assert.equal("checkpoint", lesson.id)
		assert.is_false(lesson.feedback)
		local scored, keys = 0, {}
		for _, it in ipairs(lesson.items) do
			assert.is_true(item.validate(it), it.id)
			if it.response.kind ~= "info" then
				scored = scored + 1
				assert.equal(7, it.checkpoint)
				local key = kpk_gen.position_key(it.prompt.board)
				assert.is_nil(keys[key])
				keys[key] = true
			end
		end
		assert.equal(4, scored)
		assert.same(lesson, p:lesson(plan))
	end)
end)
