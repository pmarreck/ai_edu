-- Generates fresh king-and-pawn practice positions for a named concept by seeded rejection
-- sampling: a candidate is kept only if the solver's facts satisfy the concept's definition.
-- Output is authored-card form, so kpk_content.build verifies it again like hand-written cards.
local rng = require("ai_edu.rng")
local kpk_content = require("ai_edu.kpk_content")

local kpk_gen = {}

local MAX_ATTEMPTS = 400000

local function name(f, r) return string.char(96 + f) .. r end
local function coords(sq) return sq:byte(1) - 96, tonumber(sq:sub(2)) end
local function dist(a, b)
	local af, ar = coords(a); local bf, br = coords(b)
	return math.max(math.abs(af - bf), math.abs(ar - br))
end

function kpk_gen.position_key(board)
	return board.wk .. board.bk .. board.p .. board.stm
end

local function winning_moves(solved, board)
	local out = {}
	for _, m in ipairs(solved:moves(board)) do if m.value == "win" then out[#out + 1] = m.from .. m.to end end
	return out
end

-- Square rule by counting: pawn moves to promote (double step counted) against king moves
-- to the queening square, with one move of grace when Black is to move.
local function square_rule(board)
	local pf, pr = coords(board.p)
	local m = 8 - math.max(pr, 3)
	local k = dist(board.bk, name(pf, 8))
	return k - (board.stm == "black" and 1 or 0) <= m and "draw" or "win", m, k
end

-- A White king in front of its pawn, a Black king further up, White to move.
local function escort_candidate(pick)
	local pf, pr = pick(6) + 1, pick(4) + 1
	local wf, wr = pf + pick(3) - 2, pr + pick(2)
	local bf, br = pf + pick(3) - 2, wr + pick(3) + 1
	if wf < 1 or wf > 8 or bf < 1 or bf > 8 or br > 8 then return nil end
	return { wk = name(wf, wr), bk = name(bf, br), p = name(pf, pr), stm = "white" }
end

local concepts = {}

concepts.square = {
	candidate = function(pick)
		local board = { p = name(pick(8), pick(5) + 1), bk = name(pick(8), pick(8)), wk = name(pick(8), pick(8)),
			stm = pick(2) == 1 and "white" or "black" }
		if dist(board.wk, board.p) < 4 or dist(board.wk, board.bk) < 4 then return nil end
		return board
	end,
	card = function(solved, board)
		local value = solved:value(board)
		local rule, m, k = square_rule(board)
		if value ~= rule then return nil end
		local effective = k - (board.stm == "black" and 1 or 0)
		if math.abs(effective - m) > 1 then return nil end  -- close races only; lopsided ones teach nothing
		local promo = name(coords(board.p), 8)
		local who = board.stm == "black" and "Black" or "White"
		local verdict = value == "draw" and ("within " .. m .. ", so the king is in time.")
			or ("more than " .. m .. ", so the pawn wins the race.")
		local count = board.stm == "black"
			and string.format("Black moves first, so the king effectively needs %d: %s", effective, verdict)
			or string.format("White moves first, so the king needs all %d: %s", k, verdict)
		return { ask = "stop", claim = value, skill = "kpk.square",
			text = who .. " to move. Can Black's king catch the pawn?",
			feedback = string.format("The pawn needs %d moves to promote; Black's king is %d moves from %s. %s", m, k, promo, count) }
	end,
}

concepts.opposition = {
	candidate = escort_candidate,
	card = function(solved, board)
		if solved:value(board) ~= "win" then return nil end
		local w = winning_moves(solved, board)
		if #w ~= 1 or w[1]:sub(1, 2) ~= board.wk then return nil end
		local to = w[1]:sub(3, 4)
		local tf, tr = coords(to); local bf, br = coords(board.bk)
		if tf ~= bf or math.abs(tr - br) ~= 2 then return nil end
		if kpk_content.is_key_square(solved, board.p, to) then return nil end  -- keep opposition distinct from key squares
		return { ask = "best_move", claim = "win", claim_moves = w, skill = "kpk.opposition",
			text = "White to move. Find the only winning move.",
			feedback = "K" .. to .. " takes the opposition: the kings face each other with Black to move, so Black must give way." }
	end,
}

concepts.key_squares = {
	candidate = escort_candidate,
	card = function(solved, board)
		if solved:value(board) ~= "win" then return nil end
		local w = winning_moves(solved, board)
		if #w ~= 1 or w[1]:sub(1, 2) ~= board.wk then return nil end
		local to = w[1]:sub(3, 4)
		if not kpk_content.is_key_square(solved, board.p, to) then return nil end
		local tf, tr = coords(to); local bf, br = coords(board.bk)
		if tf == bf and math.abs(tr - br) == 2 then return nil end  -- not plain opposition
		return { ask = "best_move", claim = "win", claim_moves = w, skill = "kpk.key_squares",
			text = "White to move. Find the only winning move.",
			feedback = "K" .. to .. " reaches a key square of the " .. board.p .. " pawn; from there White wins whoever is to move." }
	end,
}

concepts.pawn_push = {
	candidate = escort_candidate,
	card = function(solved, board)
		if solved:value(board) ~= "win" then return nil end
		local w = winning_moves(solved, board)
		if #w ~= 1 or w[1]:sub(1, 2) ~= board.wk then return nil end
		local pushes = 0
		for _, m in ipairs(solved:moves(board)) do if m.from == board.p then pushes = pushes + 1 end end
		if pushes == 0 then return nil end
		return { ask = "best_move", claim = "win", claim_moves = w, skill = "kpk.pawn_push",
			text = "White to move. Find the only winning move.",
			feedback = "The king leads: K" .. w[1]:sub(3, 4) .. " wins. Pushing the pawn now would let Black's king block it and draw." }
	end,
}

-- The card for one known position under a concept, or nil if the position does not fit it.
-- Deterministic, so a logged review plan (concept + board) rebuilds identical items.
function kpk_gen.card(solved, concept, board)
	local spec = assert(concepts[concept], "unknown concept " .. tostring(concept))
	if not solved:value(board) then return nil end
	local card = spec.card(solved, board)
	if not card then return nil end
	card.id = "gen-" .. concept .. "-" .. kpk_gen.position_key(board)
	card.board = board
	return card
end

-- opts: seed, count, exclude = { [position_key] = true }. Returns cards, or errors if the
-- concept cannot supply enough distinct positions.
function kpk_gen.generate(solved, concept, opts)
	local spec = assert(concepts[concept], "unknown concept " .. tostring(concept))
	local random = rng.new(opts.seed)
	local function pick(n) return math.floor(random() * n) + 1 end
	local exclude, cards = {}, {}
	for k in pairs(opts.exclude or {}) do exclude[k] = true end  -- never mutate the caller's set
	for _ = 1, MAX_ATTEMPTS do
		if #cards == opts.count then return cards end
		local board = spec.candidate(pick)
		if board and solved:value(board) then
			local key = kpk_gen.position_key(board)
			if not exclude[key] then
				local card = spec.card(solved, board)
				if card then
					exclude[key] = true
					card.id = "gen-" .. concept .. "-" .. key
					card.board = board
					cards[#cards + 1] = card
				end
			end
		end
	end
	error(string.format("kpk_gen: only %d of %d %s positions found", #cards, opts.count, concept))
end

return kpk_gen
