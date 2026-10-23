-- Builds item/1 lessons from authored king-and-pawn cards. Authors supply positions, text and
-- their predicted answers ("claims"); every answer key comes from the KPK solver, and any claim
-- the solver contradicts fails the build. This is the verify step of author-ahead content.
local kpk_content = {}

local POLICY_VERSION = "pedagogy-priors/2"
local AUTHOR = "claude-opus-5-5, 2026-09-28"

local RESULT_CHOICES = { { id = "win", label = "White wins" }, { id = "draw", label = "Draw" } }
local STOP_CHOICES = { { id = "yes", label = "Yes, Black catches it" }, { id = "no", label = "No, it promotes" } }

local function set_equal(a, b)
	if #a ~= #b then return false end
	local seen = {}
	for _, x in ipairs(a) do seen[x] = true end
	for _, x in ipairs(b) do if not seen[x] then return false end end
	return true
end

local function square_name(f, r) return string.char(96 + f) .. r end

local function coords(name) return name:byte(1) - 96, tonumber(name:sub(2)) end

-- A key square for a pawn: with White's king there, White wins with either side to move
-- against every Black king placement that cannot simply capture the pawn.
local function is_key_square(solved, pawn, sq)
	if sq == pawn then return false end
	local pf, pr = coords(pawn)
	for f = 1, 8 do for r = 1, 8 do
		local bk = square_name(f, r)
		if math.max(math.abs(f - pf), math.abs(r - pr)) > 1 then
			for _, stm in ipairs({ "white", "black" }) do
				local v = solved:value({ wk = sq, bk = bk, p = pawn, stm = stm })
				if v and v ~= "win" then return false end
			end
		end
	end end
	return true
end

local builders = {}

builders.info = function(_, card)
	return { response = { kind = "info" }, key = {} }
end

local function result_value(solved, card)
	local v = solved:value(card.board)
	if not v then return nil, "illegal board" end
	if card.claim and card.claim ~= v then return nil, "claim " .. card.claim .. " but solver says " .. v end
	return v
end

builders.result = function(solved, card)
	local v, err = result_value(solved, card)
	if not v then return nil, err end
	return { response = { kind = "choice", choices = RESULT_CHOICES }, key = { choice = v } }
end

builders.stop = function(solved, card)
	local v, err = result_value(solved, card)
	if not v then return nil, err end
	return { response = { kind = "choice", choices = STOP_CHOICES }, key = { choice = v == "draw" and "yes" or "no" } }
end

-- Short algebraic for a move in a KPK position: king moves as "Ke7", pawn moves as "d5".
local function san(move, king_square)
	return (move:sub(1, 2) == king_square and "K" or "") .. move:sub(3, 4)
end

-- For a White move that throws away the win: Black's saving replies and a one-line explanation.
local function refutation(solved, board, move)
	local after = { wk = board.wk, bk = board.bk, p = board.p, stm = "black" }
	if move:sub(1, 2) == board.wk then after.wk = move:sub(3, 4) else after.p = move:sub(3, 4) end
	if after.p:sub(2, 2) == "8" then
		return { replies = {}, text = "After " .. san(move, board.wk) .. ", Black captures the new piece or is stalemated: draw." }
	end
	local replies, names = {}, {}
	for _, m in ipairs(solved:moves(after) or {}) do
		if m.value == "draw" then
			replies[#replies + 1] = m.from .. m.to
			names[#names + 1] = "K" .. m.to
		end
	end
	local how = #names == 1 and (names[1] .. ", the only saving move")
		or (table.concat(names, ", ", 1, #names - 1) .. " or " .. names[#names])
	return { replies = replies, text = "After " .. san(move, board.wk) .. ", Black holds the draw with " .. how .. "." }
end

builders.best_move = function(solved, card)
	if card.board.stm ~= "white" then return nil, "best_move needs White to move" end
	local v, err = result_value(solved, card)
	if not v then return nil, err end
	if v ~= "win" then return nil, "best_move needs a winning position" end
	local legal, winning = {}, {}
	for _, m in ipairs(solved:moves(card.board)) do
		legal[#legal + 1] = m.from .. m.to
		if m.value == "win" then winning[#winning + 1] = m.from .. m.to end
	end
	if card.claim_moves and not set_equal(card.claim_moves, winning) then
		return nil, "claimed " .. table.concat(card.claim_moves, ",") .. " but winning moves are " .. table.concat(winning, ",")
	end
	local is_winning, refutations = {}, {}
	for _, m in ipairs(winning) do is_winning[m] = true end
	for _, m in ipairs(legal) do
		if not is_winning[m] then refutations[m] = refutation(solved, card.board, m) end
	end
	return { response = { kind = "move", legal_moves = legal }, key = { accepted = winning, refutations = refutations } }
end

builders.key_square = function(solved, card)
	if not is_key_square(solved, card.pawn, card.key) then return nil, card.key .. " is not a key square" end
	local choices = { { id = card.key, label = card.key } }
	for _, d in ipairs(card.distractors) do
		if is_key_square(solved, card.pawn, d) then return nil, "distractor " .. d .. " is a key square" end
		choices[#choices + 1] = { id = d, label = d }
	end
	table.sort(choices, function(a, b) return a.id < b.id end)
	return { response = { kind = "choice", choices = choices }, key = { choice = card.key },
		board = { p = card.pawn } }
end

local VALUE_TEXT = { win = "a win for White", draw = "a draw" }

-- Independent verdicts per ask, computed from the position alone; never reads item.key.
local judges = {}

judges.result = function(solved, it, answer)
	local v = solved:value(it.prompt.board)
	if not v or type(answer.choice) ~= "string" then return nil, "choice answer required" end
	return { correct = answer.choice == v, proof = "With best play this position is " .. VALUE_TEXT[v] .. "." }
end

judges.stop = function(solved, it, answer)
	local v = solved:value(it.prompt.board)
	if not v or (answer.choice ~= "yes" and answer.choice ~= "no") then return nil, "yes or no answer required" end
	return { correct = (answer.choice == "yes") == (v == "draw"), proof = "With best play this position is " .. VALUE_TEXT[v] .. "." }
end

judges.best_move = function(solved, it, answer)
	local board = it.prompt.board
	for _, m in ipairs(type(answer.move) == "string" and solved:moves(board) or {}) do
		if m.from .. m.to == answer.move then
			if m.value == "win" then
				return { correct = true, proof = "After " .. san(answer.move, board.wk) .. ", White keeps the win." }
			end
			return { correct = false, proof = refutation(solved, board, answer.move).text }
		end
	end
	return nil, "legal move answer required"
end

judges.key_square = function(solved, it, answer)
	local pawn = it.prompt.board.p
	if type(answer.choice) ~= "string" or not answer.choice:match("^[a-h][1-8]$") then return nil, "square answer required" end
	local yes = is_key_square(solved, pawn, answer.choice)
	return { correct = yes, proof = answer.choice .. (yes and " is" or " is not") .. " a key square for the pawn on " .. pawn .. "." }
end

-- Settle a challenge: the solver's verdict on a learner's answer, as { correct, proof }, or nil
-- plus a reason. Reads only the position and the ask recorded in item.oracle, so a wrong stored
-- key is exposed instead of defended (docs/policy/ORACLES.md).
function kpk_content.judge(solved, it, answer)
	local judge = it.oracle and it.oracle.name == "kpk-solver" and judges[it.oracle.ask]
	if not judge then return nil, "no kpk-solver oracle for item " .. tostring(it.id) end
	return judge(solved, it, answer)
end

kpk_content.is_key_square = is_key_square

-- authored: { {id, title, day, skill, cards = {...}} }. Returns lessons with items, or nil, reason.
function kpk_content.build(solved, authored)
	local lessons = {}
	for _, l in ipairs(authored) do
		local items = {}
		for _, card in ipairs(l.cards) do
			local builder = builders[card.ask]
			if not builder then return nil, card.id .. ": unknown ask " .. tostring(card.ask) end
			local built, err = builder(solved, card)
			if not built then return nil, card.id .. ": " .. err end
			items[#items + 1] = {
				schema = "item/1", id = card.id, skill_ids = { card.skill or l.skill or "kpk" },
				prompt = { text = card.text, board = built.board or card.board },
				response = built.response, key = built.key, feedback = card.feedback, phase = card.phase,
				provenance = { policy_version = POLICY_VERSION, author = AUTHOR, key_source = "kpk-solver", oracle_tier = 2 },
				oracle = { name = "kpk-solver", ask = card.ask },
			}
		end
		lessons[#lessons + 1] = { id = l.id, title = l.title, day = l.day, items = items }
	end
	return lessons
end

return kpk_content
