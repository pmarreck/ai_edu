local http_app = require("ai_edu.http_app")
local course = require("ai_edu.course")
local event_log = require("ai_edu.event_log")
local cjson = require("cjson")

local CHOICE = {
	schema = "item/1", id = "b-sound", skill_ids = { "letters.b" },
	prompt = { text = "Which letter says /b/?" },
	response = { kind = "choice", choices = { { id = "d", label = "d" }, { id = "b", label = "b" } } },
	key = { choice = "b" }, provenance = { policy_version = "pedagogy-priors/2" },
}
local function card(id) return { schema = "item/1", id = id, skill_ids = { "s" }, prompt = { text = id },
	response = { kind = "info" }, key = {}, provenance = { policy_version = "p" } } end

local STATIC = { ["/"] = { type = "text/html; charset=utf-8", body = "<!doctype html>" },
	["/app.js"] = { type = "text/javascript", body = "// app" } }

local function make(log, lessons)
	local t = 0
	return http_app.new({ log = log, static = STATIC, clock = function() t = t + 1000; return t end,
		course = course.define({ learner_id = "learner", policy_version = "p", day_index = function() return 0 end,
			lessons = lessons or { { id = "L1", title = "One", day = 0, items = { CHOICE } },
				{ id = "L2", title = "Two", day = 1, items = { card("c") } } } }) })
end

local function post(a, path, value) return a:handle({ method = "POST", path = path, body = cjson.encode(value or {}) }) end
local function json(res) return cjson.decode(res.body) end

describe("http_app (imperative shell)", function()
	it("serves allowlisted static files with a strict content security policy", function()
		local res = make(event_log.new()):handle({ method = "GET", path = "/" })
		assert.equal(200, res.status)
		assert.equal("text/html; charset=utf-8", res.headers["content-type"])
		assert.matches("default%-src 'self'", res.headers["content-security-policy"])
		assert.equal("nosniff", res.headers["x-content-type-options"])
	end)

	it("classifies request paths: only allowlisted statics and API routes resolve", function()
		local a = make(event_log.new())
		post(a, "/api/start", { lesson_id = "L1" })
		local expected = {
			["GET /"] = 200, ["GET /app.js"] = 200, ["POST /api/next"] = 200,
			["GET /api/next"] = 405, ["POST /"] = 405, ["GET /../flake.nix"] = 404, ["GET /app.js/"] = 404,
			["GET /src/ai_edu/item.lua"] = 404, ["GET /%2e%2e/flake.nix"] = 404, ["GET /nope"] = 404,
		}
		local got = {}
		for req in pairs(expected) do
			local method, path = req:match("^(%S+) (.+)$")
			got[req] = a:handle({ method = method, path = path, body = "{}" }).status
		end
		assert.same(expected, got)
	end)

	it("serves the next key-free item with progress, scores a submission, then reports done", function()
		local log = event_log.new()
		local a = make(log)
		assert.equal(200, post(a, "/api/start", { lesson_id = "L1" }).status)
		local nxt = json(post(a, "/api/next"))
		assert.equal("b-sound", nxt.item.id)
		assert.is_nil(nxt.item.key)
		assert.same({ position = 1, total = 1 }, nxt.progress)
		local res = post(a, "/api/submit", { item_id = "b-sound", answer = { choice = "b" }, modality = "tap", hint_level = 0 })
		assert.equal(200, res.status)
		assert.same({ correct = true, reveal = { choice = "b" } }, json(res))
		assert.same({ done = true }, json(post(a, "/api/next")))
		local types = {}
		for _, e in ipairs(log:events()) do types[#types + 1] = e.type end
		assert.same({ "session.started", "activity.presented", "answer.submitted", "answer.scored", "lesson.completed" }, types)
	end)

	it("answers 400 with a reason for malformed JSON or rejected submissions, logging nothing", function()
		local log = event_log.new()
		local a = make(log)
		post(a, "/api/start", { lesson_id = "L1" })
		local before = log:count()
		for _, body in ipairs({ "not json", "[]", cjson.encode({ item_id = "b-sound", answer = { choice = "b" },
			modality = "tap", hint_level = 0 }) }) do
			local res = a:handle({ method = "POST", path = "/api/submit", body = body })
			assert.equal(400, res.status, body)
			assert.is_string(json(res).error)
		end
		assert.equal(before, log:count())
	end)

	it("lists lessons with lock state", function()
		local body = json(post(make(event_log.new()), "/api/lessons"))
		assert.same({ "L1", true, "L2", false },
			{ body.lessons[1].id, body.lessons[1].unlocked, body.lessons[2].id, body.lessons[2].unlocked })
	end)

	it("requires a started lesson before next, and refuses locked lessons", function()
		local a = make(event_log.new())
		assert.equal(409, post(a, "/api/next").status)
		assert.equal(400, post(a, "/api/start", { lesson_id = "L2" }).status)
		assert.equal(200, post(a, "/api/start", { lesson_id = "L1" }).status)
		assert.equal("b-sound", json(post(a, "/api/next")).item.id)
	end)

	it("accepts reports for the current lesson", function()
		local a = make(event_log.new())
		post(a, "/api/start", { lesson_id = "L1" })
		assert.equal(200, post(a, "/api/report", { kind = "wrong", item_id = "b-sound", note = "hmm" }).status)
		assert.equal(400, post(a, "/api/report", { kind = "nope", item_id = "b-sound" }).status)
	end)

	it("resumes the open lesson after a restart and reports it as in progress", function()
		local log = event_log.new()
		local lessons = { { id = "L1", title = "One", day = 0, items = { card("a"), card("b") } } }
		local first = make(log, lessons)
		post(first, "/api/start", { lesson_id = "L1" })
		post(first, "/api/next")
		post(first, "/api/submit", { item_id = "a", answer = { ack = true }, modality = "tap", hint_level = 0 })
		local rebooted = make(log, lessons)
		assert.equal("L1", json(post(rebooted, "/api/lessons")).in_progress)
		local res = post(rebooted, "/api/next")
		assert.equal(200, res.status)
		assert.equal("b", json(res).item.id)
	end)
end)
