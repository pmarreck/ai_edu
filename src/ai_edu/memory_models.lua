-- Candidate memory models for the review scheduler, scored by log loss on the learner's own
-- unaided practice before any is allowed to drive scheduling (PLAN.md). A model is
-- { name, predict(state, elapsed_days) -> p_recall, update(state, elapsed_days, correct) -> state },
-- pure and never mutating its state argument.
local memory_models = {}

-- FSRS-6 (Free Spaced Repetition Scheduler) default parameters w0..w20, from py-fsrs
-- fsrs/scheduler.py at commit 9446cb06605c597a063aeee49f7d188d42e34dc2. Lua index i holds w(i-1).
memory_models.FSRS6_DEFAULT_PARAMETERS = {
	0.212, 1.2931, 2.3065, 8.2956, 6.4133, 0.8334, 3.0194, 0.001, 1.8722, 0.1666, 0.796,
	1.4835, 0.0614, 0.2629, 1.6483, 0.6014, 1.8729, 0.5425, 0.0912, 0.0658, 0.1542,
}

local STABILITY_MIN, MIN_DIFFICULTY, MAX_DIFFICULTY = 0.001, 1.0, 10.0
-- Binary outcomes map to FSRS ratings: wrong = Again (1), right = Good (3).
local AGAIN, GOOD, EASY = 1, 3, 4

-- FSRS-6 memory model: stability S (days until recall falls to 90%) and difficulty D in [1, 10].
-- Same-day repeats use the short-term stability update, as py-fsrs does.
function memory_models.fsrs6(params)
	local w = params or memory_models.FSRS6_DEFAULT_PARAMETERS
	local function W(i) return w[i + 1] end
	local decay = -W(20)
	local factor = 0.9 ^ (1 / decay) - 1

	local function clamp_s(s) return math.max(s, STABILITY_MIN) end
	local function clamp_d(d) return math.min(math.max(d, MIN_DIFFICULTY), MAX_DIFFICULTY) end
	local function init_d(g) return W(4) - math.exp(W(5) * (g - 1)) + 1 end
	local function retrievability(s, days) return (1 + factor * days / s) ^ decay end

	local function next_d(d, g)
		local delta = -(W(6) * (g - 3))
		local damped = d + (10.0 - d) * delta / 9.0
		return clamp_d(W(7) * init_d(EASY) + (1 - W(7)) * damped)
	end

	local function short_term_s(s, g)
		local inc = math.exp(W(17) * (g - 3 + W(18))) * s ^ -W(19)
		if g >= 2 then inc = math.max(inc, 1.0) end
		return clamp_s(s * inc)
	end

	local function next_s(d, s, r, g)
		if g == AGAIN then
			local long = W(11) * d ^ -W(12) * ((s + 1) ^ W(13) - 1) * math.exp((1 - r) * W(14))
			local short = s / math.exp(W(17) * W(18))
			return clamp_s(math.min(long, short))
		end
		return clamp_s(s * (1 + math.exp(W(8)) * (11 - d) * s ^ -W(9) * (math.exp((1 - r) * W(10)) - 1)))
	end

	return {
		name = "fsrs6@1",
		predict = function(st, days)
			if not st then return 0.5 end
			return retrievability(st.stability, days)
		end,
		update = function(st, days, correct)
			local g = correct and GOOD or AGAIN
			if not st then return { stability = clamp_s(W(g - 1)), difficulty = clamp_d(init_d(g)) } end
			local s
			if days < 1 then s = short_term_s(st.stability, g)
			else s = next_s(st.difficulty, st.stability, retrievability(st.stability, days), g) end
			return { stability = s, difficulty = next_d(st.difficulty, g) }
		end,
	}
end

memory_models.MOVING_AVERAGE_ALPHA = 0.3
local MOVING_AVERAGE_PRIOR = 0.5

-- Baseline that ignores time: an exponentially weighted average of recent correctness.
function memory_models.moving_average()
	local a = memory_models.MOVING_AVERAGE_ALPHA
	return {
		name = "moving_average@1",
		predict = function(st) return st and st.p or MOVING_AVERAGE_PRIOR end,
		update = function(st, _, correct)
			local p = st and st.p or MOVING_AVERAGE_PRIOR
			return { p = p + a * ((correct and 1 or 0) - p) }
		end,
	}
end

local DAY_MS = 86400000
local P_FLOOR = 1e-6

-- Unaided practice attempts per skill in log order, with upheld challenges applied; checkpoint
-- scores are excluded, since they are the held-out measurement.
local function attempts(events, learner_id)
	local corrected = {}
	for _, e in ipairs(events) do
		if e.type == "answer.corrected" then corrected[e.payload.corrects] = e.payload.correct end
	end
	local out = {}
	for _, e in ipairs(events) do
		local p = e.payload
		if e.type == "answer.scored" and e.learner_id == learner_id and p.hint_level == 0 and not p.checkpoint then
			local c = corrected[e.id]
			if c == nil then c = p.correct end
			out[#out + 1] = { skill = p.skill_id, at = e.occurred_at, correct = c == true }
		end
	end
	return out
end

-- Replay a model over the learner's attempts, predicting each attempt made a day or more after the
-- skill's previous one (what a scheduler must predict) from the state before it; same-day
-- attempts only update the state. Returns { model, predictions, log_loss } (log_loss nil with none).
function memory_models.evaluate(model, events, learner_id)
	local states, last, n, loss = {}, {}, 0, 0
	for _, a in ipairs(attempts(events, learner_id)) do
		local days = last[a.skill] and math.floor((a.at - last[a.skill]) / DAY_MS) or 0
		if last[a.skill] and days >= 1 then
			local p = math.min(math.max(model.predict(states[a.skill], days), P_FLOOR), 1 - P_FLOOR)
			loss = loss - math.log(a.correct and p or 1 - p)
			n = n + 1
		end
		states[a.skill] = model.update(states[a.skill], days, a.correct)
		last[a.skill] = a.at
	end
	return { model = model.name, predictions = n, log_loss = n > 0 and loss / n or nil }
end

memory_models.MIN_PREDICTIONS = 30

-- Both candidates' scores, and which is better only once each has MIN_PREDICTIONS predictions.
function memory_models.compare(events, learner_id)
	local f = memory_models.evaluate(memory_models.fsrs6(), events, learner_id)
	local b = memory_models.evaluate(memory_models.moving_average(), events, learner_id)
	local enough = f.predictions >= memory_models.MIN_PREDICTIONS and b.predictions >= memory_models.MIN_PREDICTIONS
	return {
		results = { f, b }, min_predictions = memory_models.MIN_PREDICTIONS, enough_data = enough,
		better = enough and (f.log_loss <= b.log_loss and f.model or b.model) or nil,
	}
end

return memory_models
