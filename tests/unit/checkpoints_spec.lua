local checkpoints = require("ai_edu.checkpoints")

local DAY = 86400000
local T0 = 1790000000000
local function day_index(ms) return math.floor(ms / DAY) end

local seq = 0
local function scored(day, skill, opts)
	seq = seq + 1
	opts = opts or {}
	return { seq = seq, id = "e" .. seq, type = "answer.scored", learner_id = opts.learner or "L", occurred_at = T0 + day * DAY,
		payload = { item_id = (opts.item or "i") .. seq, skill_id = skill, correct = true, hint_level = opts.hint or 0,
			checkpoint = opts.checkpoint } }
end

local function due(events, day) return checkpoints.due(events, "L", T0 + day * DAY, day_index) end

describe("checkpoints.due", function()
	it("offers nothing before a skill has an unaided lesson attempt", function()
		assert.same({}, due({}, 5))
		assert.same({}, due({ scored(0, "sq", { hint = 1 }) }, 5))
		assert.same({}, due({ scored(0, "sq", { learner = "M" }) }, 5))
	end)

	it("classifies days 0..40 for one skill with no checkpoints taken", function()
		local events = { scored(0, "sq") }
		local got = {}
		for d = 0, 40 do
			local list = due(events, d)
			got[d] = list[1] and list[1].offset or 0
		end
		for d = 0, 40 do
			local want = d >= 30 and 30 or d >= 7 and 7 or d >= 1 and 1 or 0
			assert.equal(want, got[d], "day " .. d)
		end
	end)

	it("moves past taken checkpoints and skips missed smaller ones", function()
		local events = { scored(0, "sq"), scored(1, "sq", { checkpoint = 1 }) }
		assert.same({}, due(events, 3))
		assert.same({ { skill = "sq", offset = 7 } }, due(events, 7))
		events[#events + 1] = scored(9, "sq", { checkpoint = 7 })
		assert.same({}, due(events, 29))
		assert.same({ { skill = "sq", offset = 30 } }, due(events, 31))
		events[#events + 1] = scored(31, "sq", { checkpoint = 30 })
		assert.same({}, due(events, 400))
		-- a learner first back on day 8 takes the 7-day check; the 1-day one is never offered
		local late = { scored(0, "ko") }
		assert.same({ { skill = "ko", offset = 7 } }, due(late, 8))
		late[2] = scored(8, "ko", { checkpoint = 7 })
		assert.same({}, due(late, 20))
	end)

	it("anchors each skill on its own first attempt and ignores checkpoint attempts as anchors", function()
		local events = { scored(0, "sq"), scored(3, "ko"), scored(2, "zz", { checkpoint = 1 }) }
		assert.same({ { skill = "ko", offset = 1 }, { skill = "sq", offset = 1 } }, due(events, 4))
	end)
end)
