local cqueues = require("cqueues")
local http_request = require("http.request")
local cjson = require("cjson")
local web_server = require("ai_edu.web_server")
local http_app = require("ai_edu.http_app")
local course = require("ai_edu.course")
local event_log = require("ai_edu.event_log")
local projection = require("ai_edu.learner_projection")
local sim_learner = require("ai_edu.sim_learner")
local sim_client = require("ai_edu.sim_client")
local kpk = require("ai_edu.kpk")
local kpk_content = require("ai_edu.kpk_content")

-- Browser-free run of the real king-and-pawn lessons through the real HTTP stack.
local function run_lesson(lesson_id, p_know, seed)
	local lessons = assert(kpk_content.build(kpk.shared(), dofile("content/kpk_week.lua")))
	local items = {}
	for _, l in ipairs(lessons) do for _, it in ipairs(l.items) do items[#items + 1] = it end end
	local log, t = event_log.new(), 0
	local app = http_app.new({ log = log, static = {}, clock = function() t = t + 1000; return t end,
		course = course.define({ lessons = lessons, learner_id = "sim", policy_version = "p", day_index = function() return 0 end }) })
	local server = assert(web_server.listen({ host = "127.0.0.1", port = 0, handler = function(req) return app:handle(req) end }))
	local _, host, port = server:localname()
	local base = string.format("http://%s:%d", host, port)
	local transcript, start_status
	local cq = cqueues.new()
	cq:wrap(function() assert(server:loop()) end)
	cq:wrap(function()
		local req = http_request.new_from_uri(base .. "/api/start")
		req.headers:upsert(":method", "POST")
		req:set_body(cjson.encode({ lesson_id = lesson_id }))
		local headers, stream = assert(req:go(5))
		stream:get_body_as_string()
		start_status = headers:get(":status")
		transcript = assert(sim_client.run(base, sim_learner.new({ items = items, seed = seed, p_know = p_know })))
		server:close()
	end)
	assert(cq:loop(20))
	return start_status, transcript, log
end

describe("king-and-pawn lesson, simulated over HTTP", function()
	it("a learner who knows the skill gets every scored item right and completes the lesson", function()
		local status, transcript, log = run_lesson("square", { ["kpk.square"] = 1 }, 5)
		assert.equal("200", status)
		local scored = 0
		for _, turn in ipairs(transcript) do
			if turn.correct ~= nil then scored = scored + 1; assert.is_true(turn.correct, turn.item_id) end
		end
		assert.equal(5, scored)
		local completed = false
		for _, e in ipairs(log:events()) do completed = completed or e.type == "lesson.completed" end
		assert.is_true(completed)
		assert.same({ attempts = 5, correct = 5 }, projection.replay(log:events()).learners.sim.skills["kpk.square"].independent)
	end)

	it("a learner who does not know it gets every scored item wrong", function()
		local _, transcript = run_lesson("square", {}, 5)
		for _, turn in ipairs(transcript) do
			if turn.correct ~= nil then assert.is_false(turn.correct, turn.item_id) end
		end
	end)
end)

describe("king-and-pawn challenges settled by the solver", function()
	local ORACLE = { name = "kpk-solver", judge = function(it, a) return kpk_content.judge(kpk.shared(), it, a) end }

	-- Run a lesson in-process, answering the first move item with a losing move, then challenge it.
	-- tamper(lessons) may corrupt a stored key first, standing in for a grading error.
	local function challenge_first_move(tamper)
		local lessons = assert(kpk_content.build(kpk.shared(), dofile("content/kpk_week.lua")))
		if tamper then tamper(lessons) end
		for _, l in ipairs(lessons) do l.day = 0 end -- unlock every lesson; calendar gating is tested elsewhere
		local log, t = event_log.new(), 0
		local app = http_app.new({ log = log, static = {}, oracle = ORACLE, clock = function() t = t + 1000; return t end,
			course = course.define({ lessons = lessons, learner_id = "sim", policy_version = "p", day_index = function() return 0 end }) })
		local function post(path, v) return cjson.decode(app:handle({ method = "POST", path = path, body = cjson.encode(v or {}) }).body) end
		assert(post("/api/start", { lesson_id = "opposition" }).lesson_id)
		while true do
			local it = assert(post("/api/next").item, "lesson has no move item")
			if it.response.kind == "move" then
				local move = it.response.legal_moves[1]
				for _, m in ipairs(it.response.legal_moves) do
					if not kpk_content.judge(kpk.shared(), { oracle = { name = "kpk-solver", ask = "best_move" }, prompt = it.prompt }, { move = m }).correct then move = m end
				end
				local scored = post("/api/submit", { item_id = it.id, answer = { move = move }, modality = "tap", hint_level = 0 })
				return scored, post("/api/report", { kind = "wrong", item_id = it.id, note = "" }), log
			end
			local answer = it.response.kind == "info" and { ack = true } or { choice = it.response.choices[1].id }
			post("/api/submit", { item_id = it.id, answer = answer, modality = "tap", hint_level = 0 })
		end
	end

	it("rejects a challenge to a correctly graded losing move, with Black's saving reply as proof", function()
		local scored, res = challenge_first_move()
		assert.is_false(scored.correct)
		assert.is_false(res.settled.upheld)
		assert.matches("Black holds the draw", res.settled.proof)
	end)

	it("upholds a challenge when the stored key is corrupted, and the projection follows the oracle", function()
		local function tamper(lessons)
			for _, l in ipairs(lessons) do
				if l.id == "opposition" then
					for _, it in ipairs(l.items) do
						if it.response.kind == "move" then it.key = { accepted = it.response.legal_moves, refutations = {} }; return end
					end
				end
			end
		end
		local scored, res, log = challenge_first_move(tamper)
		assert.is_true(scored.correct)
		assert.is_true(res.settled.upheld)
		assert.is_false(res.settled.correct)
		local p = assert(projection.replay(log:events()))
		for _, s in pairs(p.learners.sim.skills) do
			assert.is_true(s.independent.correct <= s.independent.attempts)
		end
		local corrected = 0
		for _, e in ipairs(log:events()) do if e.type == "answer.corrected" then corrected = corrected + 1 end end
		assert.equal(1, corrected)
	end)
end)

describe("king-and-pawn checkpoints over the HTTP app", function()
	it("offers an unmarked checkpoint the day after first practice and keeps it out of practice counts", function()
		local DAY = 86400000
		local lessons = assert(kpk_content.build(kpk.shared(), dofile("content/kpk_week.lua")))
		local cps = require("ai_edu.kpk_review").checkpoints({ solved = kpk.shared(), lessons = lessons, learner_id = "sim",
			day_index = function(ms) return math.floor(ms / DAY) end })
		local log, t = event_log.new(), 1790000000000
		local app = http_app.new({ log = log, static = {}, clock = function() t = t + 1000; return t end,
			course = course.define({ lessons = lessons, learner_id = "sim", policy_version = "p", checkpoints = cps,
				day_index = function(ms) return math.floor(ms / DAY) end }) })
		local function post(path, v) return cjson.decode(app:handle({ method = "POST", path = path, body = cjson.encode(v or {}) }).body) end
		local function run_to_end()
			local results = {}
			while true do
				local nx = post("/api/next")
				if nx.done then return results end
				local it = nx.item
				local answer = it.response.kind == "info" and { ack = true }
					or it.response.kind == "move" and { move = it.response.legal_moves[1] }
					or { choice = it.response.choices[1].id }
				results[#results + 1] = post("/api/submit", { item_id = it.id, answer = answer, modality = "tap", hint_level = 0 })
			end
		end
		local function row()
			for _, l in ipairs(post("/api/lessons").lessons) do if l.id == "checkpoint" then return l end end
		end
		post("/api/start", { lesson_id = "square" })
		run_to_end()
		assert.is_false(row().unlocked)
		t = t + DAY
		assert.is_true(row().unlocked)
		post("/api/start", { lesson_id = "checkpoint" })
		local recorded = 0
		for _, r in ipairs(run_to_end()) do
			if not r.ack then
				assert.same({ recorded = true }, r)
				recorded = recorded + 1
			end
		end
		assert.equal(2, recorded)
		assert.is_false(row().unlocked)
		local p = assert(projection.replay(log:events()))
		local sq = p.learners.sim.skills["kpk.square"]
		assert.equal(2, sq.checkpoint.attempts)
		assert.equal(5, sq.independent.attempts)
	end)
end)
