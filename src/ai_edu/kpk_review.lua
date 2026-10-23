-- Review provider for the king-and-pawn course: turns scheduler-due skills into a review
-- lesson of fresh, never-seen, solver-verified positions, interleaved across skills.
-- Plans are small serializable tables (concept + board) logged at session start.
local scheduler = require("ai_edu.scheduler")
local kpk_gen = require("ai_edu.kpk_gen")
local kpk_content = require("ai_edu.kpk_content")
local checkpoints = require("ai_edu.checkpoints")

local kpk_review = {}

local CONCEPT_FOR_SKILL = {
	["kpk.square"] = "square",
	["kpk.opposition"] = "opposition",
	["kpk.key_squares"] = "key_squares",
	["kpk.pawn_push"] = "pawn_push",
}
local PER_SKILL = 2

local Provider = {}
Provider.__index = Provider

-- opts: solved, lessons (built course, to exclude its positions), learner_id, day_index.
function kpk_review.new(opts)
	local authored = {}
	for _, l in ipairs(opts.lessons) do
		for _, it in ipairs(l.items) do
			local b = it.prompt.board
			if b and b.wk and b.bk and b.p and b.stm then authored[kpk_gen.position_key(b)] = true end
		end
	end
	return setmetatable({ solved = opts.solved, authored = authored, learner_id = opts.learner_id,
		day_index = opts.day_index }, Provider)
end

function Provider:due(events, now)
	local out = {}
	for _, skill in ipairs(scheduler.due(scheduler.replay(events), self.learner_id, now, self.day_index)) do
		if CONCEPT_FOR_SKILL[skill] then out[#out + 1] = skill end
	end
	table.sort(out)
	return out
end

-- Positions to avoid: every authored lesson position plus every generated one already shown.
function Provider:_seen(events)
	local seen = {}
	for k in pairs(self.authored) do seen[k] = true end
	for _, e in ipairs(events) do
		if e.type == "activity.presented" and e.learner_id == self.learner_id then
			local key = tostring(e.payload.item_id):match("^gen%-[%w_]+%-(.+)$")
			if key then seen[key] = true end
		end
	end
	return seen
end

-- PER_SKILL fresh positions per skill, interleaved round-robin; extra[i] is merged into skill i's cards.
local function plan_cards(self, events, now, skills, extra)
	local seen = self:_seen(events)
	local per_skill = {}
	for i, skill in ipairs(skills) do
		local concept = CONCEPT_FOR_SKILL[skill]
		local cards = kpk_gen.generate(self.solved, concept, { seed = now + i, count = PER_SKILL, exclude = seen })
		per_skill[i] = {}
		for _, c in ipairs(cards) do
			seen[kpk_gen.position_key(c.board)] = true
			local card = { concept = concept, board = c.board }
			for k, v in pairs(extra and extra[i] or {}) do card[k] = v end
			per_skill[i][#per_skill[i] + 1] = card
		end
	end
	local cards = {}
	for round = 1, PER_SKILL do
		for i = 1, #skills do cards[#cards + 1] = per_skill[i][round] end
	end
	return { cards = cards }
end

-- A plan of PER_SKILL fresh positions per due skill, interleaved round-robin across skills.
function Provider:plan(events, now, due)
	return plan_cards(self, events, now, due)
end

function Provider:lesson(plan)
	local cards = { { id = "review-intro", ask = "info",
		text = "Review: fresh positions you have not seen, mixing the ideas that are due today. No explanations until you answer." } }
	for _, p in ipairs(plan.cards) do cards[#cards + 1] = assert(kpk_gen.card(self.solved, p.concept, p.board)) end
	local built = assert(kpk_content.build(self.solved, { { id = "review", title = "Review", day = 0, skill = "kpk.review", cards = cards } }))
	return built[1]
end


local Checkpoints = setmetatable({}, { __index = Provider })
Checkpoints.__index = Checkpoints

-- Delayed no-feedback checks (docs/plan_context/checkpoints.md) built from the same fresh,
-- never-seen positions as reviews. opts as for kpk_review.new.
function kpk_review.checkpoints(opts)
	return setmetatable(kpk_review.new(opts), Checkpoints)
end

-- Due checkpoints as { {skill, offset} } for skills that have a generator.
function Checkpoints:due(events, now)
	local out = {}
	for _, d in ipairs(checkpoints.due(events, self.learner_id, now, self.day_index)) do
		if CONCEPT_FOR_SKILL[d.skill] then out[#out + 1] = d end
	end
	return out
end

function Checkpoints:plan(events, now, due)
	local skills, extra = {}, {}
	for i, d in ipairs(due) do skills[i], extra[i] = d.skill, { offset = d.offset } end
	return plan_cards(self, events, now, skills, extra)
end

function Checkpoints:lesson(plan)
	local cards = { { id = "checkpoint-intro", ask = "info",
		text = "Checkpoint: fresh positions, no hints and no feedback. It measures what you remember; answers are recorded, not marked, here." } }
	local offsets = {}
	for _, p in ipairs(plan.cards) do
		local card = assert(kpk_gen.card(self.solved, p.concept, p.board))
		offsets[card.id] = p.offset
		cards[#cards + 1] = card
	end
	local built = assert(kpk_content.build(self.solved, { { id = "checkpoint", title = "Checkpoint", day = 0, skill = "kpk.review", cards = cards } }))[1]
	for _, it in ipairs(built.items) do it.checkpoint = offsets[it.id] end
	built.feedback = false
	return built
end

return kpk_review
