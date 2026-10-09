-- King+pawn vs king (KPK) endgame solver: exhaustive retrograde analysis over all
-- 2*64*64*64 positions (White pawn only), giving the game-theoretic win/draw value.
-- Used as the independent oracle that verifies every chess lesson item's answer key.
local ffi = require("ffi")

local kpk = {}

local UNKNOWN, WIN, DRAW, ILLEGAL = 0, 1, 2, 3
local WHITE, BLACK = 0, 1
local SIZE = 2 * 64 * 64 * 64
local NAMES = { [WIN] = "win", [DRAW] = "draw" }

local function file(sq) return sq % 8 end
local function rank(sq) return math.floor(sq / 8) end
local function index(stm, wk, bk, p) return ((stm * 64 + wk) * 64 + bk) * 64 + p end

local neighbors, adjacent = {}, {}
for a = 0, 63 do
	neighbors[a] = {}
	for b = 0, 63 do
		local near = a ~= b and math.abs(file(a) - file(b)) <= 1 and math.abs(rank(a) - rank(b)) <= 1
		adjacent[a * 64 + b] = near
		if near then neighbors[a][#neighbors[a] + 1] = b end
	end
end

local function pawn_attacks(p, sq)
	return rank(sq) == rank(p) + 1 and math.abs(file(sq) - file(p)) == 1
end

local function legal(stm, wk, bk, p)
	if p < 8 or p > 55 or wk == bk or wk == p or bk == p or adjacent[wk * 64 + bk] then return false end
	return not (stm == WHITE and pawn_attacks(p, bk))
end

-- Does a queen (or rook) on q attack sq, with the White king as the only blocker?
local function slider_attacks(q, sq, wk, diagonal_ok)
	if q == sq then return false end
	local df, dr = file(sq) - file(q), rank(sq) - rank(q)
	local straight = df == 0 or dr == 0
	if not (straight or (diagonal_ok and math.abs(df) == math.abs(dr))) then return false end
	local sf, sr = (df > 0 and 1) or (df < 0 and -1) or 0, (dr > 0 and 1) or (dr < 0 and -1) or 0
	local f, r = file(q) + sf, rank(q) + sr
	while f >= 0 and f <= 7 and r >= 0 and r <= 7 do
		local cur = r * 8 + f
		if cur == sq then return true end
		if cur == wk then return false end
		f, r = f + sf, r + sr
	end
	return false
end

-- Value for White right after promoting on q, Black to move: a win unless Black can take
-- the new piece or is stalemated. Tries a queen, then a rook (avoids queen stalemates).
local function promotion_value(wk, bk, q)
	for _, diagonal_ok in ipairs({ true, false }) do
		local escapes, captures = 0, false
		for _, t in ipairs(neighbors[bk]) do
			if not adjacent[t * 64 + wk] then
				if t == q then captures = true
				elseif not slider_attacks(q, t, wk, diagonal_ok) then escapes = escapes + 1 end
			end
		end
		if not captures then
			local in_check = slider_attacks(q, bk, wk, diagonal_ok)
			if escapes > 0 or in_check then return WIN end
		end
	end
	return DRAW
end

-- Successors of a White-to-move position: calls visit(from, to, kind, a, b, c) where kind is
-- "pos" (Black-to-move wk, bk, p) or "value" (a final value after promotion).
local function white_moves(wk, bk, p, visit)
	for _, t in ipairs(neighbors[wk]) do
		if t ~= p and not adjacent[t * 64 + bk] then visit(wk, t, "pos", t, bk, p) end
	end
	local push = p + 8
	if push ~= wk and push ~= bk then
		if rank(push) == 7 then visit(p, push, "value", promotion_value(wk, bk, push))
		else
			visit(p, push, "pos", wk, bk, push)
			local double = p + 16
			if rank(p) == 1 and double ~= wk and double ~= bk then visit(p, double, "pos", wk, bk, double) end
		end
	end
end

-- Successors of a Black-to-move position; capturing an unprotected pawn is a final draw.
local function black_moves(wk, bk, p, visit)
	for _, t in ipairs(neighbors[bk]) do
		if not adjacent[t * 64 + wk] then
			if t == p then visit(bk, t, "value", DRAW)
			elseif not pawn_attacks(p, t) then visit(bk, t, "pos", wk, t, p) end
		end
	end
end

local Solved = {}
Solved.__index = Solved

-- complexity: O(positions x passes); passes are bounded by the longest forced win.
function kpk.solve()
	local v = ffi.new("uint8_t[?]", SIZE)
	for stm = WHITE, BLACK do
		for wk = 0, 63 do for bk = 0, 63 do for p = 0, 63 do
			if not legal(stm, wk, bk, p) then v[index(stm, wk, bk, p)] = ILLEGAL end
		end end end
	end
	-- Black to move with no legal moves: mate by the pawn is a win, otherwise stalemate.
	for wk = 0, 63 do for bk = 0, 63 do for p = 8, 55 do
		local i = index(BLACK, wk, bk, p)
		if v[i] == UNKNOWN then
			local count = 0
			black_moves(wk, bk, p, function() count = count + 1 end)
			if count == 0 then v[i] = pawn_attacks(p, bk) and WIN or DRAW end
		end
	end end end

	local changed = true
	while changed do
		changed = false
		for wk = 0, 63 do for bk = 0, 63 do for p = 8, 55 do
			local wi = index(WHITE, wk, bk, p)
			if v[wi] == UNKNOWN then
				local wins = false
				white_moves(wk, bk, p, function(_, _, kind, a, b, c)
					if kind == "value" then wins = wins or a == WIN
					else wins = wins or v[index(BLACK, a, b, c)] == WIN end
				end)
				if wins then v[wi] = WIN; changed = true end
			end
			local bi = index(BLACK, wk, bk, p)
			if v[bi] == UNKNOWN then
				local all_lose = true
				black_moves(wk, bk, p, function(_, _, kind, a, b, c)
					if kind == "value" then all_lose = false
					elseif v[index(WHITE, a, b, c)] ~= WIN then all_lose = false end
				end)
				if all_lose then v[bi] = WIN; changed = true end
			end
		end end end
	end
	for i = 0, SIZE - 1 do if v[i] == UNKNOWN then v[i] = DRAW end end
	return setmetatable({ v = v }, Solved)
end

local function square(name)
	if type(name) ~= "string" then return nil end
	local f, r = name:match("^([a-h])([1-8])$")
	if not f then return nil end
	return (tonumber(r) - 1) * 8 + (f:byte() - 97)
end

local function square_name(sq) return string.char(97 + file(sq)) .. (rank(sq) + 1) end

-- pos = { wk = "e1", bk = "e8", p = "e2", stm = "white"|"black" }; nil if illegal.
local function decode(pos)
	local wk, bk, p = square(pos.wk), square(pos.bk), square(pos.p)
	local stm = (pos.stm == "white" and WHITE) or (pos.stm == "black" and BLACK) or nil
	if not (wk and bk and p and stm) or not legal(stm, wk, bk, p) then return nil end
	return stm, wk, bk, p
end

function Solved:value(pos)
	local stm, wk, bk, p = decode(pos)
	if not stm then return nil end
	return NAMES[self.v[index(stm, wk, bk, p)]]
end

-- Every legal move with the White-perspective value of the position it leads to.
function Solved:moves(pos)
	local stm, wk, bk, p = decode(pos)
	if not stm then return nil end
	local out = {}
	local function visit(from, to, kind, a, b, c)
		local value = kind == "value" and a or self.v[index(1 - stm, a, b, c)]
		out[#out + 1] = { from = square_name(from), to = square_name(to), value = NAMES[value] }
	end
	if stm == WHITE then white_moves(wk, bk, p, visit) else black_moves(wk, bk, p, visit) end
	return out
end

-- Exhaustive metamorphic check: mirroring files a<->h must never change a value.
function Solved:check_mirror_symmetry()
	local function mirror(sq) return rank(sq) * 8 + (7 - file(sq)) end
	local checked, broken = 0, 0
	for stm = WHITE, BLACK do for wk = 0, 63 do for bk = 0, 63 do for p = 8, 55 do
		local a = self.v[index(stm, wk, bk, p)]
		if a ~= ILLEGAL then
			checked = checked + 1
			if a ~= self.v[index(stm, mirror(wk), mirror(bk), mirror(p))] then broken = broken + 1 end
		end
	end end end end
	return checked, broken
end


local shared_solution
-- The solved table is immutable, so one solve per process serves every caller.
function kpk.shared()
	shared_solution = shared_solution or kpk.solve()
	return shared_solution
end

return kpk
