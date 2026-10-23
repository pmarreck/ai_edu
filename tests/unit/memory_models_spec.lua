local mm = require("ai_edu.memory_models")
local rng = require("ai_edu.rng")

local DAY = 86400000
local T0 = 1790000000000

describe("fsrs6 model", function()
	local m = mm.fsrs6()
	local W = mm.FSRS6_DEFAULT_PARAMETERS

	it("carries FSRS-6's published default parameters", function()
		assert.equal(21, #W)
		assert.same({ 0.212, 1.2931, 2.3065, 8.2956 }, { W[1], W[2], W[3], W[4] })
		assert.equal(0.1542, W[21])
	end)

	it("starts from the published initial stability and difficulty for Good and Again", function()
		local good = m.update(nil, 0, true)
		assert.equal(W[3], good.stability)
		assert.near(W[5] - math.exp(W[6] * 2) + 1, good.difficulty, 1e-12)
		local again = m.update(nil, 0, false)
		assert.equal(W[1], again.stability)
		assert.near(math.min(10, W[5] - math.exp(0) + 1), again.difficulty, 1e-12)
	end)

	it("predicts 90% recall exactly when elapsed days equal stability, decaying with time", function()
		for _, s in ipairs({ 0.5, 2.3065, 10, 100 }) do
			assert.near(0.9, m.predict({ stability = s, difficulty = 5 }, s), 1e-12)
		end
		local st, prev = { stability = 3, difficulty = 5 }, 1
		for d = 0, 60 do
			local p = m.predict(st, d)
			assert.is_true(p <= prev and p > 0)
			prev = p
		end
		assert.equal(1, m.predict(st, 0))
	end)

	it("raises stability after a recall and lowers it after a lapse, keeping difficulty in [1, 10]", function()
		for seed = 1, 50 do
			local rand = rng.new(seed)
			local st = m.update(nil, 0, rand() < 0.5)
			for _ = 1, 30 do
				local days = math.floor(rand() * 20)
				local correct = rand() < 0.7
				local nxt = m.update(st, days, correct)
				if days >= 1 then
					if correct then assert.is_true(nxt.stability > st.stability) else assert.is_true(nxt.stability < st.stability) end
				end
				assert.is_true(nxt.difficulty >= 1 and nxt.difficulty <= 10)
				assert.is_true(nxt.stability >= 0.001)
				st = nxt
			end
		end
	end)
end)

describe("moving-average baseline", function()
	it("ignores time and tracks recent correctness", function()
		local m = mm.moving_average()
		assert.equal(0.5, m.predict(nil, 3))
		local st = m.update(nil, 0, true)
		assert.near(0.5 + mm.MOVING_AVERAGE_ALPHA * 0.5, m.predict(st, 0), 1e-12)
		assert.equal(m.predict(st, 0), m.predict(st, 400))
	end)
end)

describe("memory_models.evaluate", function()
	local seq = 0
	local function scored(day, skill, correct, extra)
		seq = seq + 1
		local p = { item_id = "i" .. seq, skill_id = skill, correct = correct, hint_level = 0 }
		for k, v in pairs(extra or {}) do p[k] = v end
		return { seq = seq, id = "e" .. seq, type = "answer.scored", learner_id = "L", occurred_at = T0 + day * DAY, payload = p }
	end

	it("scores each prediction made before an attempt by log loss, skipping each skill's first attempt", function()
		local events = { scored(0, "a", true), scored(1, "a", false), scored(1, "b", true), scored(3, "a", true) }
		local const = { name = "half@1", predict = function() return 0.5 end, update = function(st) return st or {} end }
		local r = mm.evaluate(const, events, "L")
		assert.equal(2, r.predictions)
		assert.near(math.log(2), r.log_loss, 1e-12)
	end)

	it("predicts only attempts at least a day after the skill's previous one; same-day ones only update", function()
		local events = { scored(0, "a", true), scored(0, "a", false), scored(0, "a", true), scored(2, "a", true) }
		local updates = 0
		local const = { name = "half@1", predict = function() return 0.5 end, update = function(st) updates = updates + 1; return st or {} end }
		local r = mm.evaluate(const, events, "L")
		assert.equal(1, r.predictions)
		assert.equal(4, updates)
	end)

	it("ignores assisted, checkpoint and other learners' attempts and applies corrections", function()
		local events = { scored(0, "a", true), scored(1, "a", false, { hint_level = 1 }), scored(2, "a", false, { checkpoint = 1 }),
			scored(2, "a", false), { seq = 99, type = "answer.corrected", learner_id = "L", occurred_at = T0 + 3 * DAY,
				payload = { item_id = "x", skill_id = "a", correct = true, was_correct = false, hint_level = 0, corrects = "e" .. seq } } }
		local seen = {}
		local spy = { name = "spy@1", predict = function() return 0.5 end, update = function(st, _, c) seen[#seen + 1] = c; return st or {} end }
		local r = mm.evaluate(spy, events, "L")
		assert.equal(1, r.predictions)
		assert.same({ true, true }, seen)
	end)

	it("withholds a verdict until both models have enough predictions", function()
		local events = { scored(0, "a", true), scored(1, "a", true) }
		local report = mm.compare(events, "L")
		assert.is_false(report.enough_data)
		assert.equal(mm.MIN_PREDICTIONS, report.min_predictions)
		assert.is_nil(report.better)
		local long = {}
		for d = 0, mm.MIN_PREDICTIONS + 1 do long[#long + 1] = scored(d * 2, "a", d % 3 ~= 0) end
		local r2 = mm.compare(long, "L")
		assert.is_true(r2.enough_data)
		assert.truthy(r2.better == "fsrs6@1" or r2.better == "moving_average@1")
	end)
end)

describe("fsrs6 against ts-fsrs", function()
	it("matches the reference implementation's stability and difficulty on 40 seeded sequences", function()
		local m = mm.fsrs6()
		local worst = 0
		for _, seq in ipairs(dofile("tests/fixtures/fsrs6_ts_fsrs.lua")) do
			local st
			for _, step in ipairs(seq) do
				st = m.update(st, step[1], step[2])
				worst = math.max(worst, math.abs(st.stability - step[3]) / step[3], math.abs(st.difficulty - step[4]) / step[4])
			end
		end
		assert.is_true(worst < 1e-6, "worst relative error " .. worst)
	end)
end)
