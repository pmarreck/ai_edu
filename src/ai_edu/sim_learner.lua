-- Simulated learner for exercising the real web API without a browser. It sees only the
-- public item view; its "knowledge" is the item bank plus a per-skill probability of knowing.
local sim_learner = {}

local rng = require("ai_edu.rng").new

local WRONG_TEXT = "not sure"

local Learner = {}
Learner.__index = Learner

-- opts: items (with keys), seed, p_know = { [skill_id] = probability } (missing skills = 0).
function sim_learner.new(opts)
	local by_id = {}
	for _, it in ipairs(opts.items) do by_id[it.id] = it end
	return setmetatable({ by_id = by_id, random = rng(opts.seed), p_know = opts.p_know }, Learner)
end

-- A learner knows an item only if a draw succeeds against its least-known skill.
function Learner:_knows(it)
	local p = 1
	for _, skill in ipairs(it.skill_ids) do p = math.min(p, self.p_know[skill] or 0) end
	return self.random() < p
end

-- Returns { answer = ..., modality = ..., hint_level = 0 } for a public item view.
function Learner:answer(view)
	local it = assert(self.by_id[view.id], "simulated learner has no knowledge of item " .. tostring(view.id))
	if view.response.kind == "info" then return { answer = { ack = true }, modality = "tap", hint_level = 0 } end
	local knows = self:_knows(it)
	if view.response.kind == "move" then
		local accepted = {}
		for _, m in ipairs(it.key.accepted) do accepted[m] = true end
		local pool = {}
		for _, m in ipairs(view.response.legal_moves) do
			if (accepted[m] == true) == knows then pool[#pool + 1] = m end
		end
		return { answer = { move = pool[math.floor(self.random() * #pool) + 1] }, modality = "tap", hint_level = 0 }
	end
	if view.response.kind == "choice" then
		local choice = it.key.choice
		if not knows then
			local wrong = {}
			for _, c in ipairs(view.response.choices) do if c.id ~= it.key.choice then wrong[#wrong + 1] = c.id end end
			choice = wrong[math.floor(self.random() * #wrong) + 1]
		end
		return { answer = { choice = choice }, modality = "tap", hint_level = 0 }
	end
	return { answer = { text = knows and it.key.accepted[1] or WRONG_TEXT }, modality = "type", hint_level = 0 }
end

return sim_learner
