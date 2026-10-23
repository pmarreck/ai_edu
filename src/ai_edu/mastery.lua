-- mastery-estimate/1: per-skill mastery recomputed from the event log, never stored as truth.
-- Estimator bkt@1 is Bayesian Knowledge Tracing (Corbett and Anderson 1995): a hidden
-- learned/unlearned state with initial, transit, slip and guess probabilities, updated by
-- Bayes' rule after each attempt. Evidence tier C until validated against delayed unaided
-- outcomes (docs/policy/PEDAGOGY_PRIORS.md, prior 8).
local mastery = {}

mastery.SCHEMA = "mastery-estimate/1"
mastery.ESTIMATOR = "bkt@1"

-- Unfitted starting values; per-learner fitting replaces them once data allow.
mastery.DEFAULT_PARAMS = { p_init = 0.2, p_transit = 0.1, p_slip = 0.1, p_guess = 0.2 }

-- The interval is a sensitivity band, not a posterior credible interval: the estimate
-- recomputed with slip and guess each moved by this much in both directions.
local SENSITIVITY = 0.05

local function params_error(prm)
	for _, k in ipairs({ "p_init", "p_transit", "p_slip", "p_guess" }) do
		local v = prm[k]
		if type(v) ~= "number" or v < 0 or v > 1 then return k .. " must be a probability" end
	end
	-- slip or guess at or above one half makes a wrong answer evidence of mastery
	if prm.p_slip >= 0.5 or prm.p_guess >= 0.5 then return "p_slip and p_guess must be below 0.5" end
end

local function bkt(outcomes, prm)
	local L = prm.p_init
	for _, correct in ipairs(outcomes) do
		local post
		if correct then
			post = L * (1 - prm.p_slip) / (L * (1 - prm.p_slip) + (1 - L) * prm.p_guess)
		else
			post = L * prm.p_slip / (L * prm.p_slip + (1 - L) * (1 - prm.p_guess))
		end
		L = post + (1 - post) * prm.p_transit
	end
	return L
end

local function clamp(x, lo, hi) return math.max(lo, math.min(hi, x)) end

-- The learner's attempts at one skill in log order, with upheld challenges applied by event id.
local function outcomes(events, learner_id, skill_id, independent_only)
	local corrected = {}
	for _, e in ipairs(events) do
		if e.type == "answer.corrected" then corrected[e.payload.corrects] = e.payload.correct end
	end
	local out = {}
	for _, e in ipairs(events) do
		local pl = e.payload
		if e.type == "answer.scored" and e.learner_id == learner_id and pl.skill_id == skill_id
			and not pl.checkpoint and (pl.hint_level == 0 or not independent_only) then
			local c = corrected[e.id]
			if c == nil then c = pl.correct end
			out[#out + 1] = c == true
		end
	end
	return out
end

-- opts: params (default DEFAULT_PARAMS), independent_only (default true). Returns a
-- mastery-estimate/1 record, or nil plus a reason for invalid parameters.
function mastery.estimate(events, learner_id, skill_id, opts)
	opts = opts or {}
	local prm = opts.params or mastery.DEFAULT_PARAMS
	local err = params_error(prm)
	if err then return nil, err end
	local independent_only = opts.independent_only ~= false
	local obs = outcomes(events, learner_id, skill_id, independent_only)
	local p = bkt(obs, prm)
	local lo, hi = p, p
	for _, ds in ipairs({ -SENSITIVITY, SENSITIVITY }) do
		for _, dg in ipairs({ -SENSITIVITY, SENSITIVITY }) do
			local v = bkt(obs, { p_init = prm.p_init, p_transit = prm.p_transit,
				p_slip = clamp(prm.p_slip + ds, 0.001, 0.499), p_guess = clamp(prm.p_guess + dg, 0.001, 0.499) })
			lo, hi = math.min(lo, v), math.max(hi, v)
		end
	end
	local params = {}
	for k, v in pairs(prm) do params[k] = v end
	return {
		schema = mastery.SCHEMA, skill_id = skill_id, p_mastery = p, interval = { lo, hi },
		estimator = { name = mastery.ESTIMATOR, params = params },
		evidence_count = #obs, independent_only = independent_only,
	}
end

return mastery
