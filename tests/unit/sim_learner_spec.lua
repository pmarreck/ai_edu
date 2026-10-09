local sim_learner = require("ai_edu.sim_learner")
local item = require("ai_edu.item")

local ITEMS = {
	{ schema = "item/1", id = "c", skill_ids = { "known" }, prompt = { text = "?" },
		response = { kind = "choice", choices = { { id = "x", label = "x" }, { id = "y", label = "y" }, { id = "z", label = "z" } } },
		key = { choice = "y" }, provenance = { policy_version = "p" } },
	{ schema = "item/1", id = "t", skill_ids = { "unknown" }, prompt = { text = "?" },
		response = { kind = "typed" }, key = { accepted = { "8", "eight" } }, provenance = { policy_version = "p" } },
}

local function by_id(id) for _, it in ipairs(ITEMS) do if it.id == id then return it end end end

describe("sim_learner", function()
	it("answers correctly for mastered skills and incorrectly for unknown ones, as scored by item.score", function()
		local learner = sim_learner.new({ items = ITEMS, seed = 1, p_know = { known = 1, unknown = 0 } })
		for _ = 1, 50 do
			for _, it in ipairs(ITEMS) do
				local reply = learner:answer(item.public_view(it))
				local scored = assert(item.score(by_id(it.id), reply.answer))
				assert.equal(it.id == "c", scored.correct)
			end
		end
	end)

	it("is deterministic for a seed and varies across seeds", function()
		local function run(seed)
			local learner = sim_learner.new({ items = ITEMS, seed = seed, p_know = { known = 0.5, unknown = 0.5 } })
			local out = {}
			for i = 1, 40 do out[i] = item.score(ITEMS[1], learner:answer(item.public_view(ITEMS[1])).answer).correct end
			return table.concat((function() local s = {} for i, v in ipairs(out) do s[i] = v and "1" or "0" end return s end)())
		end
		assert.equal(run(7), run(7))
		assert.are_not.equal(run(7), run(8))
	end)

	it("hits roughly the configured success rate", function()
		local learner = sim_learner.new({ items = ITEMS, seed = 3, p_know = { known = 0.7 } })
		local correct = 0
		for _ = 1, 2000 do
			if item.score(ITEMS[1], learner:answer(item.public_view(ITEMS[1])).answer).correct then correct = correct + 1 end
		end
		assert.is_true(correct > 1300 and correct < 1500, "got " .. correct)
	end)

	it("reports a modality matching the answer shape", function()
		local learner = sim_learner.new({ items = ITEMS, seed = 1, p_know = {} })
		assert.equal("tap", learner:answer(item.public_view(ITEMS[1])).modality)
		assert.equal("type", learner:answer(item.public_view(ITEMS[2])).modality)
	end)
end)
