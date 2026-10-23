local kpk = require("ai_edu.kpk")
local kpk_content = require("ai_edu.kpk_content")
local item = require("ai_edu.item")

local solved = kpk.shared()

local function build(cards)
	return kpk_content.build(solved, { { id = "T", title = "t", day = 0, cards = cards } })
end

describe("kpk_content.build", function()
	it("derives the answer key from the solver, not from the author", function()
		local lessons = assert(build({
			{ id = "q", ask = "result", board = { wk = "e5", p = "e4", bk = "e7", stm = "white" }, claim = "draw", text = "?" },
			{ id = "m", ask = "best_move", board = { wk = "e5", p = "d4", bk = "d7", stm = "white" }, claim_moves = { "e5d5" }, text = "?" },
		}))
		local q, m = lessons[1].items[1], lessons[1].items[2]
		assert.equal("draw", q.key.choice)
		assert.same({ "e5d5" }, m.key.accepted)
		assert.equal(6, #m.response.legal_moves)
		assert.is_true(item.validate(q))
		assert.is_true(item.validate(m))
	end)

	it("fails the build when the author's claim disagrees with the solver", function()
		local lessons, err = build({ { id = "bad", ask = "result", board = { wk = "e5", p = "e4", bk = "e7", stm = "white" }, claim = "win", text = "?" } })
		assert.is_nil(lessons)
		assert.matches("bad", err)
		assert.is_nil(build({ { id = "bad2", ask = "best_move", board = { wk = "e5", p = "d4", bk = "d7", stm = "white" }, claim_moves = { "e5e6" }, text = "?" } }))
	end)

	it("checks key-square answers and distractors against the solver's definition", function()
		assert.truthy(build({ { id = "k", ask = "key_square", pawn = "d4", key = "e6", distractors = { "d5", "c5", "e7" }, text = "?" } }))
		assert.is_nil(build({ { id = "k2", ask = "key_square", pawn = "d4", key = "d5", distractors = { "e6" }, text = "?" } }))
	end)

	it("builds the real week of lessons: every item valid, every move item has a wrong option", function()
		local lessons = assert(kpk_content.build(solved, dofile("content/kpk_week.lua")))
		local days = {}
		for _, l in ipairs(lessons) do
			days[#days + 1] = l.day
			assert.is_true(#l.items >= 4, l.id)
			for _, it in ipairs(l.items) do
				assert.is_true(item.validate(it), it.id)
				if it.response.kind == "move" then
					assert.is_true(#it.key.accepted < #it.response.legal_moves, it.id)
				end
			end
		end
		assert.same({ 0, 1, 2, 7 }, days)
	end)
end)

describe("kpk_content refutations", function()
	local function move_item()
		return assert(kpk_content.build(solved, { { id = "T", title = "t", day = 0, cards = {
			{ id = "m", ask = "best_move", board = { wk = "e5", p = "d4", bk = "d7", stm = "white" }, claim_moves = { "e5d5" }, text = "?" },
		} } }))[1].items[1]
	end

	it("stores, for every losing legal move, Black's saving replies taken from the solver", function()
		local it = move_item()
		local wrong = {}
		for _, m in ipairs(it.response.legal_moves) do if m ~= "e5d5" then wrong[#wrong + 1] = m end end
		for _, m in ipairs(wrong) do
			local r = it.key.refutations[m]
			assert.is_table(r, m)
			assert.is_true(#r.replies > 0, m)
			for _, reply in ipairs(r.replies) do
				local after = { wk = it.prompt.board.wk, bk = it.prompt.board.bk, p = it.prompt.board.p, stm = "black" }
				if m:sub(1, 2) == after.wk then after.wk = m:sub(3, 4) else after.p = m:sub(3, 4) end
				after.bk = reply:sub(3, 4); after.stm = "white"
				assert.equal("draw", solved:value(after), m .. " " .. reply)
			end
		end
		assert.is_nil(it.key.refutations["e5d5"])
	end)

	it("explains a premature d5 in plain chess notation", function()
		assert.same({ replies = { "d7e7" }, text = "After d5, Black holds the draw with Ke7, the only saving move." },
			move_item().key.refutations["d4d5"])
	end)

	it("reveals only the refutation of the move actually played", function()
		local it = move_item()
		local r = item.reveal(it, { move = "d4d5" })
		assert.equal("After d5, Black holds the draw with Ke7, the only saving move.", r.refutation)
		assert.is_nil(r.refutations)
		assert.is_nil(item.reveal(it, { move = "e5d5" }).refutation)
	end)
end)

describe("kpk_content.judge", function()
	local lessons = assert(kpk_content.build(solved, dofile("content/kpk_week.lua")))

	-- Every answer a learner could give: each choice, or each legal move.
	local function answers(it)
		local out = {}
		if it.response.kind == "choice" then
			for _, c in ipairs(it.response.choices) do out[#out + 1] = { choice = c.id } end
		elseif it.response.kind == "move" then
			for _, m in ipairs(it.response.legal_moves) do out[#out + 1] = { move = m } end
		end
		return out
	end

	it("agrees with the stored key on every possible answer to every item in the week", function()
		local judged = 0
		for _, l in ipairs(lessons) do
			for _, it in ipairs(l.items) do
				for _, a in ipairs(answers(it)) do
					local verdict = assert(kpk_content.judge(solved, it, a))
					assert.equal(item.score(it, a).correct, verdict.correct, it.id)
					assert.is_string(verdict.proof)
					judged = judged + 1
				end
			end
		end
		assert.is_true(judged > 60)
	end)

	it("ignores the stored key, so a corrupted key is exposed", function()
		local it
		for _, l in ipairs(lessons) do
			for _, x in ipairs(l.items) do
				if not it and x.response.kind == "move" then it = x end
			end
		end
		local wrong
		for _, m in ipairs(it.response.legal_moves) do
			if it.key.accepted[1] ~= m and not wrong then wrong = m end
		end
		local tampered = {}
		for k, v in pairs(it) do tampered[k] = v end
		tampered.key = { accepted = { wrong }, refutations = {} }
		assert.is_true(item.score(tampered, { move = wrong }).correct)
		assert.is_false(assert(kpk_content.judge(solved, tampered, { move = wrong })).correct)
	end)

	it("explains a losing move with Black's saving reply", function()
		local m = assert(build({ { id = "m", ask = "best_move", board = { wk = "e5", p = "d4", bk = "d7", stm = "white" }, text = "?" } }))[1].items[1]
		local v = assert(kpk_content.judge(solved, m, { move = "d4d5" }))
		assert.is_false(v.correct)
		assert.matches("Black holds the draw", v.proof)
		assert.matches("keeps the win", assert(kpk_content.judge(solved, m, { move = "e5d5" })).proof)
	end)

	it("refuses items it has no oracle for and malformed answers", function()
		local info = { schema = "item/1", id = "i", response = { kind = "info" } }
		assert.is_nil(kpk_content.judge(solved, info, { ack = true }))
		local m = assert(build({ { id = "m", ask = "best_move", board = { wk = "e5", p = "d4", bk = "d7", stm = "white" }, text = "?" } }))[1].items[1]
		assert.is_nil(kpk_content.judge(solved, m, { move = "a1a2" }))
		assert.is_nil(kpk_content.judge(solved, m, { choice = "win" }))
	end)
end)

describe("kpk_content provenance", function()
	it("records the solver as a tier-2 oracle, so no item waits for human approval", function()
		local approvals = require("ai_edu.approvals")
		for _, l in ipairs(assert(kpk_content.build(solved, dofile("content/kpk_week.lua")))) do
			for _, it in ipairs(l.items) do
				assert.equal(2, it.provenance.oracle_tier)
				assert.is_false(approvals.required(it))
			end
		end
	end)
end)
