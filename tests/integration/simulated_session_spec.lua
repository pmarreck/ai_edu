local cqueues = require("cqueues")
local web_server = require("ai_edu.web_server")
local http_app = require("ai_edu.http_app")
local course = require("ai_edu.course")
local event_log = require("ai_edu.event_log")
local projection = require("ai_edu.learner_projection")
local sim_learner = require("ai_edu.sim_learner")
local sim_client = require("ai_edu.sim_client")

local function items()
	local out = {}
	for i = 1, 6 do
		out[#out + 1] = { schema = "item/1", id = "letter" .. i, skill_ids = { "letters" }, prompt = { text = "?" },
			response = { kind = "choice", choices = { { id = "a", label = "a" }, { id = "b", label = "b" } } },
			key = { choice = "a" }, provenance = { policy_version = "p" } }
		out[#out + 1] = { schema = "item/1", id = "count" .. i, skill_ids = { "counting" }, prompt = { text = "?" },
			response = { kind = "typed" }, key = { accepted = { tostring(i) } }, provenance = { policy_version = "p" } }
	end
	return out
end

describe("simulated learner over the real HTTP API", function()
	it("drives a full session through the socket and the server's log replays to what it did", function()
		local log, t = event_log.new(), 0
		local app = http_app.new({ log = log, static = {}, clock = function() t = t + 250; return t end,
			course = course.define({ learner_id = "sim", policy_version = "p", day_index = function() return 0 end,
				lessons = { { id = "L", title = "L", day = 0, items = items() } } }) })
		assert.equal(200, app:handle({ method = "POST", path = "/api/start", body = '{"lesson_id":"L"}' }).status)
		local server = assert(web_server.listen({ host = "127.0.0.1", port = 0, handler = function(req) return app:handle(req) end }))
		local _, host, port = server:localname()
		local learner = sim_learner.new({ items = items(), seed = 11, p_know = { letters = 1, counting = 0 } })
		local transcript
		local cq = cqueues.new()
		cq:wrap(function() assert(server:loop()) end)
		cq:wrap(function()
			transcript = assert(sim_client.run(string.format("http://%s:%d", host, port), learner))
			server:close()
		end)
		assert(cq:loop(10))

		assert.equal(12, #transcript)
		for _, turn in ipairs(transcript) do
			assert.equal(turn.item_id:match("^letter") ~= nil, turn.correct, turn.item_id)
		end
		local skills = projection.replay(log:events()).learners.sim.skills
		assert.same({ attempts = 6, correct = 6 }, skills.letters.independent)
		assert.same({ attempts = 6, correct = 0 }, skills.counting.independent)
	end)
end)
