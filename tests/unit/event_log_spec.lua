package.path = "tests/support/?.lua;" .. package.path
local event_log = require("ai_edu.event_log")
local fx = require("fixtures")

describe("event_log", function()
	it("assigns dense, monotonic seq numbers starting at 1", function()
		local log = event_log.new()
		assert.equal(1, log:append(fx.event({ id = "a" })))
		assert.equal(2, log:append(fx.event({ id = "b" })))
		assert.equal(2, log:count())
		local seqs = {}
		for i, e in ipairs(log:events()) do seqs[i] = e.seq end
		assert.same({ 1, 2 }, seqs)
	end)

	it("rejects invalid events without consuming a seq", function()
		local log = event_log.new()
		local seq, err = log:append(fx.event({ actor = "llm:tutor", type = "answer.scored" }))
		assert.is_nil(seq)
		assert.matches("may not emit", err)
		assert.equal(0, log:count())
		assert.equal(1, log:append(fx.event()))
	end)

	it("rejects a duplicate event id", function()
		local log = event_log.new()
		log:append(fx.event({ id = "dup" }))
		local seq, err = log:append(fx.event({ id = "dup", type = "hint.requested" }))
		assert.is_nil(seq)
		assert.matches("duplicate", err)
		assert.equal(1, log:count())
	end)

	it("is unaffected by mutating the appended input or the returned events", function()
		local log = event_log.new()
		local input = fx.event({ payload = { answer = "4" } })
		log:append(input)
		input.payload.answer = "5"
		local out = log:events()
		out[1].payload.answer = "6"
		out[1].type = "answer.scored"
		out[2] = fx.event({ id = "smuggled" })
		local again = log:events()
		assert.equal(1, #again)
		assert.equal("4", again[1].payload.answer)
		assert.equal("answer.submitted", again[1].type)
	end)

	it("round-trips through canonical NDJSON, byte for byte", function()
		local log = event_log.new()
		log:append(fx.event({ id = "a", payload = { answer = "x\ny", skills = { "s1" } } }))
		log:append(fx.event({ id = "b", actor = "engine", type = "answer.scored", payload = { correct = true } }))
		local text = log:encode()
		local decoded = assert(event_log.decode(text))
		assert.equal(text, decoded:encode())
		assert.same(log:events(), decoded:events())
	end)

	it("refuses to decode a log with gaps, reordering or invalid events", function()
		local log = event_log.new()
		log:append(fx.event({ id = "a" }))
		log:append(fx.event({ id = "b" }))
		log:append(fx.event({ id = "c" }))
		local lines = {}
		for line in log:encode():gmatch("[^\n]+") do lines[#lines + 1] = line end
		local gap = lines[1] .. "\n" .. lines[3] .. "\n"
		local swapped = lines[2] .. "\n" .. lines[1] .. "\n"
		local forged = lines[1]:gsub('"actor":"learner"', '"actor":"llm:tutor"'):gsub('"answer.submitted"', '"answer.scored"') .. "\n"
		for name, text in pairs({ gap = gap, swapped = swapped, forged = forged }) do
			local decoded, err = event_log.decode(text)
			assert.is_nil(decoded, name)
			assert.is_string(err, name)
		end
	end)
end)

describe("event_log encapsulation", function()
	it("exposes only append, count, encode and events: no update, delete or stored event is reachable", function()
		local log = event_log.new()
		assert(log:append({ schema = "event/1", id = "x", type = "answer.submitted", actor = "learner",
			learner_id = "L", occurred_at = 1, payload = {}, provenance = { policy_version = "p" } }))
		local fields = {}
		for k in pairs(log) do fields[#fields + 1] = k end
		table.sort(fields)
		assert.same({ "append", "count", "encode", "events" }, fields)
		assert.is_nil(getmetatable(log))
	end)
end)
