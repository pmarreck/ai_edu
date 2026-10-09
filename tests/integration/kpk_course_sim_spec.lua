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
