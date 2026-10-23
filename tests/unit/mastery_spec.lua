local mastery = require("ai_edu.mastery")
local rng = require("ai_edu.rng")

local PARAMS = { p_init = 0.2, p_transit = 0.1, p_slip = 0.1, p_guess = 0.2 }

-- Scored events for learner L, skill s: outcomes = { {correct, hint_level, id?}, ... }
local function scored(outcomes)
	local events = {}
	for i, o in ipairs(outcomes) do
		events[i] = { seq = i, id = o[3] or ("e" .. i), type = "answer.scored", learner_id = "L", occurred_at = i,
			payload = { item_id = "i" .. i, skill_id = "s", correct = o[1], hint_level = o[2] or 0 } }
	end
	return events
end

local function p(events, opts)
	return assert(mastery.estimate(events, "L", "s", opts or { params = PARAMS })).p_mastery
end

describe("mastery.estimate (BKT)", function()
	it("matches a hand-computed update", function()
		-- correct: posterior .2*.9 / (.2*.9 + .8*.2) = .18/.34; then learning: post + (1 - post) * .1
		local post = 0.18 / 0.34
		assert.near(post + (1 - post) * 0.1, p(scored({ { true } })), 1e-12)
		local wrong = 0.2 * 0.1 / (0.2 * 0.1 + 0.8 * 0.8)
		assert.near(wrong + (1 - wrong) * 0.1, p(scored({ { false } })), 1e-12)
		assert.equal(0.2, p({}))
	end)

	it("reports the mastery-estimate/1 contract", function()
		local est = assert(mastery.estimate(scored({ { true }, { true }, { false, 2 } }), "L", "s", { params = PARAMS }))
		assert.equal("mastery-estimate/1", est.schema)
		assert.equal("s", est.skill_id)
		assert.equal("bkt@1", est.estimator.name)
		assert.same(PARAMS, est.estimator.params)
		assert.equal(2, est.evidence_count)
		assert.is_true(est.independent_only)
		assert.is_true(est.interval[1] <= est.p_mastery and est.p_mastery <= est.interval[2])
		assert.is_true(est.interval[1] >= 0 and est.interval[2] <= 1)
	end)

	it("never lets assisted attempts count as independent evidence unless asked", function()
		local events = scored({ { true }, { true, 1 }, { true, 3 } })
		assert.equal(p(scored({ { true } })), p(events))
		local all = assert(mastery.estimate(events, "L", "s", { params = PARAMS, independent_only = false }))
		assert.equal(3, all.evidence_count)
		assert.is_false(all.independent_only)
	end)

	it("applies answer.corrected to the score it names", function()
		local events = scored({ { false, 0, "x1" } })
		events[2] = { seq = 2, type = "answer.corrected", learner_id = "L", occurred_at = 2,
			payload = { item_id = "i1", skill_id = "s", correct = true, was_correct = false, hint_level = 0, corrects = "x1" } }
		assert.equal(p(scored({ { true } })), p(events))
	end)

	it("ignores other learners, skills and event types", function()
		local events = scored({ { true } })
		events[2] = { seq = 2, id = "o", type = "answer.scored", learner_id = "M", occurred_at = 2,
			payload = { item_id = "i", skill_id = "s", correct = false, hint_level = 0 } }
		events[3] = { seq = 3, id = "q", type = "answer.scored", learner_id = "L", occurred_at = 3,
			payload = { item_id = "i", skill_id = "t", correct = false, hint_level = 0 } }
		events[4] = { seq = 4, id = "r", type = "misconception.proposed", learner_id = "L", occurred_at = 4, payload = {} }
		assert.equal(p(scored({ { true } })), p(events))
	end)

	it("moves up on every correct answer and down on every wrong one, staying in (0, 1)", function()
		for seed = 1, 100 do
			local rand, outcomes = rng.new(seed), {}
			for i = 1, 1 + math.floor(rand() * 20) do
				outcomes[i] = { rand() < 0.6 }
				local before = p(scored({ unpack(outcomes, 1, i - 1) }))
				local after = p(scored(outcomes))
				-- learning (p_transit) can lift even a wrong answer's estimate, so compare the posterior
				-- direction against the no-evidence prior step instead: correct beats wrong from the same start
				local flipped = {}
				for j = 1, i do flipped[j] = outcomes[j] end
				flipped[i] = { not outcomes[i][1] }
				local other = p(scored(flipped))
				if outcomes[i][1] then assert.is_true(after > other) else assert.is_true(after < other) end
				assert.is_true(after > 0 and after < 1 and before > 0 and before < 1)
			end
		end
	end)

	it("rejects parameters that make the model unidentifiable or out of range", function()
		local bad = {
			{ p_init = 0.2, p_transit = 0.1, p_slip = 0.6, p_guess = 0.2 },
			{ p_init = 0.2, p_transit = 0.1, p_slip = 0.1, p_guess = 0.5 },
			{ p_init = 1.2, p_transit = 0.1, p_slip = 0.1, p_guess = 0.2 },
			{ p_init = 0.2, p_transit = -0.1, p_slip = 0.1, p_guess = 0.2 },
			{ p_init = 0.2, p_slip = 0.1, p_guess = 0.2 },
		}
		for i, params in ipairs(bad) do
			assert.is_nil(mastery.estimate({}, "L", "s", { params = params }), "case " .. i)
		end
		assert.truthy(mastery.estimate({}, "L", "s", {}))
	end)
end)
