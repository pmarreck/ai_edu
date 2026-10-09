local kpk = require("ai_edu.kpk")
local ORACLE = dofile("tests/fixtures/kpk_lichess.lua")

describe("kpk solver", function()
	local solved = kpk.shared()

	it("agrees with the lichess tablebase on every oracle position", function()
		local mismatches = {}
		for _, o in ipairs(ORACLE) do
			local got = solved:value({ wk = o.wk, bk = o.bk, p = o.p, stm = o.stm })
			if got ~= o.value then
				mismatches[#mismatches + 1] = string.format("K%s P%s vs k%s %s: want %s got %s", o.wk, o.p, o.bk, o.stm, o.value, tostring(got))
			end
		end
		assert.equal(300, #ORACLE)
		assert.same({}, mismatches)
	end)

	it("is invariant under mirroring files a<->h, over every legal position", function()
		local checked, broken = solved:check_mirror_symmetry()
		assert.is_true(checked > 100000, "checked " .. checked)
		assert.equal(0, broken)
	end)

	it("rejects illegal positions", function()
		for _, pos in ipairs({
			{ wk = "e1", bk = "e2", p = "a2", stm = "white" },  -- kings adjacent
			{ wk = "e1", bk = "e1", p = "a2", stm = "white" },  -- same square
			{ wk = "e1", bk = "e8", p = "e1", stm = "white" },  -- pawn on king
			{ wk = "e1", bk = "e8", p = "e8", stm = "white" },
			{ wk = "a1", bk = "d5", p = "e4", stm = "white" },  -- black in check, white to move
			{ wk = "a1", bk = "h8", p = "a1", stm = "black" },
			{ wk = "a1", bk = "h8", p = "c1", stm = "black" },  -- pawn on first rank
			{ wk = "a1", bk = "h8", p = "c8", stm = "black" },  -- pawn on last rank
			{ wk = "z9", bk = "h8", p = "c4", stm = "black" },
		}) do
			assert.is_nil(solved:value(pos))
		end
	end)

	it("classifies every legal move exactly as the lichess tablebase does", function()
		-- Fetched 2026-09-28 from tablebase.lichess.ovh; values converted to White's perspective.
		local cases = {
			{ pos = { wk = "d6", bk = "d8", p = "d5", stm = "white" }, value = "win",
				moves = { d6e6 = "win", d6c6 = "win", d6c5 = "draw", d6e5 = "draw" } },
			{ pos = { wk = "d6", bk = "d8", p = "d5", stm = "black" }, value = "win",
				moves = { d8e8 = "win", d8c8 = "win" } },
			{ pos = { wk = "d4", bk = "d6", p = "d3", stm = "white" }, value = "draw",
				moves = { d4c3 = "draw", d4e3 = "draw", d4c4 = "draw", d4e4 = "draw" } },
		}
		for _, c in ipairs(cases) do
			assert.equal(c.value, solved:value(c.pos))
			local got = {}
			for _, m in ipairs(solved:moves(c.pos)) do got[m.from .. m.to] = m.value end
			assert.same(c.moves, got)
		end
	end)
end)
