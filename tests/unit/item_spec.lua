local item = require("ai_edu.item")

local function choice_item()
	return {
		schema = "item/1", id = "i1", skill_ids = { "letters.b" },
		prompt = { text = "Which letter says /b/?", audio = "sha256:abc" },
		response = { kind = "choice", choices = {
			{ id = "a", label = "d" }, { id = "b", label = "b" }, { id = "c", label = "p" },
		} },
		key = { choice = "b" },
		provenance = { policy_version = "pedagogy-priors/2", author = "llm:planner", verified_by = "learner" },
	}
end

local function typed_item()
	return {
		schema = "item/1", id = "i2", skill_ids = { "counting" },
		prompt = { text = "How many legs does a spider have?" },
		response = { kind = "typed" },
		key = { accepted = { "8", "eight" } },
		provenance = { policy_version = "pedagogy-priors/2" },
	}
end

describe("item.validate", function()
	it("accepts well-formed choice and typed items", function()
		assert.is_true(item.validate(choice_item()))
		assert.is_true(item.validate(typed_item()))
	end)

	it("rejects a choice key that names no choice, duplicate choice ids, and unknown kinds", function()
		local bad_key = choice_item(); bad_key.key.choice = "z"
		local dup = choice_item(); dup.response.choices[2].id = "a"
		local kind = typed_item(); kind.response.kind = "telepathy"
		local no_accepted = typed_item(); no_accepted.key = { accepted = {} }
		local no_prompt = typed_item(); no_prompt.prompt = {}
		for name, it_ in pairs({ bad_key = bad_key, dup = dup, kind = kind, no_accepted = no_accepted, no_prompt = no_prompt }) do
			assert.is_nil(item.validate(it_), name)
		end
	end)
end)

describe("item.public_view", function()
	it("never contains the answer key or provenance, at any depth", function()
		for _, it_ in ipairs({ choice_item(), typed_item() }) do
			local view = item.public_view(it_)
			assert.is_nil(view.key)
			assert.is_nil(view.provenance)
			local encoded = require("ai_edu.canonical").encode(view)
			assert.falsy(encoded:find('"key"', 1, true))
			assert.falsy(encoded:find('eight', 1, true))
		end
	end)

	it("keeps what the learner needs to answer", function()
		local view = item.public_view(choice_item())
		assert.equal("i1", view.id)
		assert.equal("sha256:abc", view.prompt.audio)
		assert.equal(3, #view.response.choices)
	end)
end)

describe("item.score", function()
	it("classifies every choice exactly once as correct or incorrect", function()
		local verdicts = {}
		for _, c in ipairs(choice_item().response.choices) do
			verdicts[c.id] = item.score(choice_item(), { choice = c.id }).correct
		end
		assert.same({ a = false, b = true, c = false }, verdicts)
	end)

	it("normalizes typed answers over a set of variants", function()
		local cases = {
			["8"] = true, [" 8 "] = true, ["EIGHT"] = true, ["Eight\n"] = true, ["eight."] = false,
			["88"] = false, ["6"] = false, [""] = false, ["e i g h t"] = false,
		}
		local got = {}
		for input, _ in pairs(cases) do got[input] = item.score(typed_item(), { text = input }).correct end
		assert.same(cases, got)
	end)

	it("rejects an answer of the wrong shape instead of scoring it", function()
		local r, err = item.score(choice_item(), { text = "b" })
		assert.is_nil(r)
		assert.matches("choice", err)
		assert.is_nil(item.score(choice_item(), { choice = "zzz" }))
	end)
end)

local function move_item()
	return {
		schema = "item/1", id = "m1", skill_ids = { "kpk.opposition" },
		prompt = { text = "White to move. Win it.", board = { wk = "d6", bk = "d8", p = "d5", stm = "white" } },
		response = { kind = "move", legal_moves = { "d6e6", "d6c6", "d6c5", "d6e5" } },
		key = { accepted = { "d6e6", "d6c6" } },
		feedback = "Stepping sideways keeps the opposition.",
		provenance = { policy_version = "pedagogy-priors/2" },
	}
end

describe("move items", function()
	it("validate only when accepted moves are a non-empty subset of legal moves", function()
		assert.is_true(item.validate(move_item()))
		local stray = move_item(); stray.key.accepted = { "d6d7" }
		local empty = move_item(); empty.key.accepted = {}
		local no_legal = move_item(); no_legal.response.legal_moves = {}
		for name, it_ in pairs({ stray = stray, empty = empty, no_legal = no_legal }) do
			assert.is_nil(item.validate(it_), name)
		end
	end)

	it("score every legal move as a classifier and refuse illegal ones", function()
		local got = {}
		for _, m in ipairs(move_item().response.legal_moves) do got[m] = item.score(move_item(), { move = m }).correct end
		assert.same({ d6e6 = true, d6c6 = true, d6c5 = false, d6e5 = false }, got)
		assert.is_nil(item.score(move_item(), { move = "d6d7" }))
		assert.is_nil(item.score(move_item(), { choice = "d6e6" }))
	end)

	it("show the board and legal moves but not the key or feedback", function()
		local view = item.public_view(move_item())
		assert.equal("d6", view.prompt.board.wk)
		assert.equal(4, #view.response.legal_moves)
		assert.is_nil(view.key)
		assert.is_nil(view.feedback)
	end)
end)

describe("item.reveal", function()
	it("gives the correct answer and feedback for display after an answer", function()
		assert.same({ accepted = { "d6e6", "d6c6" }, feedback = "Stepping sideways keeps the opposition." },
			item.reveal(move_item()))
		assert.same({ choice = "b" }, item.reveal(choice_item()))
		assert.same({ accepted = { "8", "eight" } }, item.reveal(typed_item()))
	end)
end)
