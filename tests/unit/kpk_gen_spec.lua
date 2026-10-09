local kpk = require("ai_edu.kpk")
local kpk_gen = require("ai_edu.kpk_gen")
local kpk_content = require("ai_edu.kpk_content")

local solved = kpk.shared()

local function coords(sq) return sq:byte(1) - 96, tonumber(sq:sub(2)) end
local function dist(a, b)
	local af, ar = coords(a); local bf, br = coords(b)
	return math.max(math.abs(af - bf), math.abs(ar - br))
end
local function winning(board)
	local out = {}
	for _, m in ipairs(solved:moves(board)) do if m.value == "win" then out[#out + 1] = m.from .. m.to end end
	return out
end

-- Independent statement of the square rule, for checking generated race positions.
-- The pawn needs m moves (double step counted); Black's king, k moves from the queening square,
-- is in time if k - 1 <= m with Black to move (it can take a new queen from beside it), else k <= m.
local function square_rule(board)
	local pf, pr = coords(board.p)
	local m = 8 - math.max(pr, 3)
	local k = dist(board.bk, string.char(96 + pf) .. "8")
	local head_start = board.stm == "black" and 1 or 0
	return k - head_start <= m and "draw" or "win"
end

describe("kpk_gen", function()
	it("generates square-rule races the solver agrees with, with White's king out of play", function()
		local cards = kpk_gen.generate(solved, "square", { seed = 1, count = 12 })
		assert.equal(12, #cards)
		for _, c in ipairs(cards) do
			assert.equal("stop", c.ask)
			assert.equal(solved:value(c.board), c.claim)
			assert.equal(square_rule(c.board), c.claim, c.id)
			assert.is_true(dist(c.board.wk, c.board.p) >= 4 and dist(c.board.wk, c.board.bk) >= 4, c.id)
			-- Close races only: the king's effective count is within one move of the pawn's.
			local pf, pr = coords(c.board.p)
			local m = 8 - math.max(pr, 3)
			local k = dist(c.board.bk, string.char(96 + pf) .. "8") - (c.board.stm == "black" and 1 or 0)
			assert.is_true(math.abs(k - m) <= 1, c.id)
		end
	end)

	it("generates opposition positions: one winning move, a king move that leaves the kings facing", function()
		for _, c in ipairs(kpk_gen.generate(solved, "opposition", { seed = 2, count = 10 })) do
			local w = winning(c.board)
			assert.same(w, c.claim_moves)
			assert.equal(1, #w, c.id)
			assert.equal(c.board.wk, w[1]:sub(1, 2))
			local to = w[1]:sub(3, 4)
			local tf, tr = coords(to); local bf, br = coords(c.board.bk)
			assert.is_true(tf == bf and math.abs(tr - br) == 2, c.id .. " " .. w[1])
			assert.is_false(kpk_content.is_key_square(solved, c.board.p, to), c.id .. " should be pure opposition")
		end
	end)

	it("generates key-square positions: the one winning move steps onto a key square", function()
		for _, c in ipairs(kpk_gen.generate(solved, "key_squares", { seed = 3, count = 10 })) do
			local w = winning(c.board)
			assert.equal(1, #w, c.id)
			assert.equal(c.board.wk, w[1]:sub(1, 2))
			assert.is_true(kpk_content.is_key_square(solved, c.board.p, w[1]:sub(3, 4)), c.id)
			local tf, tr = coords(w[1]:sub(3, 4)); local bf, br = coords(c.board.bk)
			assert.is_false(tf == bf and math.abs(tr - br) == 2, c.id .. " should not be plain opposition")
		end
	end)

	it("generates tempting pawn pushes: the push is legal but throws the win away", function()
		for _, c in ipairs(kpk_gen.generate(solved, "pawn_push", { seed = 4, count = 10 })) do
			local pushes = 0
			for _, m in ipairs(solved:moves(c.board)) do
				if m.from == c.board.p then
					pushes = pushes + 1
					assert.equal("draw", m.value, c.id)
				end
			end
			assert.is_true(pushes > 0, c.id)
			assert.equal(1, #winning(c.board), c.id)
		end
	end)

	it("is reproducible from a seed, avoids excluded positions and builds as verified content", function()
		local a = kpk_gen.generate(solved, "opposition", { seed = 9, count = 6 })
		local b = kpk_gen.generate(solved, "opposition", { seed = 9, count = 6 })
		assert.same(a, b)
		local exclude = { [kpk_gen.position_key(a[1].board)] = true }
		local c = kpk_gen.generate(solved, "opposition", { seed = 9, count = 6, exclude = exclude })
		local seen = {}
		for _, card in ipairs(c) do
			local k = kpk_gen.position_key(card.board)
			assert.is_nil(exclude[k])
			assert.is_nil(seen[k])
			seen[k] = true
		end
		assert.truthy(kpk_content.build(solved, { { id = "gen", title = "g", day = 0, cards = c } }))
	end)
end)
