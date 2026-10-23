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
	it("exposes only append, count, encode, events and head: no update, delete or stored event is reachable", function()
		local log = event_log.new()
		assert(log:append({ schema = "event/1", id = "x", type = "answer.submitted", actor = "learner",
			learner_id = "L", occurred_at = 1, payload = {}, provenance = { policy_version = "p" } }))
		local fields = {}
		for k in pairs(log) do fields[#fields + 1] = k end
		table.sort(fields)
		assert.same({ "append", "count", "encode", "events", "head" }, fields)
		assert.is_nil(getmetatable(log))
	end)
end)

describe("event_log hash chain", function()
	local blake3 = require("blake3").blake3
	local canonical = require("ai_edu.canonical")

	local function sample(n)
		local log = event_log.new()
		for i = 1, n do assert(log:append(fx.event({ id = "e" .. i, payload = { answer = tostring(i) } }))) end
		return log
	end

	it("chains each line to the one before it: chain_i = BLAKE3(chain_{i-1} .. newline .. entry)", function()
		local log = sample(4)
		local prev = ""
		for line in log:encode():gmatch("[^\n]+") do
			local entry = canonical.decode(line)
			local chain = entry.chain
			entry.chain = nil
			assert.equal(blake3(prev .. "\n" .. canonical.encode(entry)), chain)
			prev = chain
		end
		assert.equal(prev, log:head())
		assert.equal("", event_log.new():head())
	end)

	it("keeps the chain out of the events it returns", function()
		for _, e in ipairs(sample(2):events()) do assert.is_nil(e.chain) end
	end)

	it("rejects every single-byte change anywhere in the saved text", function()
		local text = sample(3):encode()
		local accepted = {}
		for i = 1, #text do
			if text:sub(i, i) ~= "\n" then
				local b = text:byte(i)
				local mutated = text:sub(1, i - 1) .. string.char(b == 48 and 49 or 48) .. text:sub(i + 1)
				if event_log.decode(mutated) then accepted[#accepted + 1] = i end
			end
		end
		assert.same({}, accepted)
	end)

	it("rejects a deleted, swapped or rewritten line even when seq numbers are fixed up", function()
		local log = sample(3)
		local lines = {}
		for line in log:encode():gmatch("[^\n]+") do lines[#lines + 1] = canonical.decode(line) end
		local function text_of(entries)
			local out = {}
			for i, e in ipairs(entries) do out[i] = canonical.encode(e) .. "\n" end
			return table.concat(out)
		end
		local dropped = { lines[1], lines[3] }
		dropped[2] = (function() local c = {} for k, v in pairs(lines[3]) do c[k] = v end c.seq = 2 return c end)()
		local _, err = event_log.decode(text_of(dropped))
		assert.matches("chain", err)
		local rewritten = {}
		for k, v in pairs(lines[2]) do rewritten[k] = v end
		rewritten.payload = { answer = "forged" }
		assert.matches("chain", select(2, event_log.decode(text_of({ lines[1], rewritten, lines[3] }))))
	end)

	it("cannot see a cut tail by itself, but the head it reports no longer matches an outside record", function()
		local log = sample(3)
		local text, head = log:encode(), log:head()
		local cut = text:match("^(.-\n.-\n)")
		local shorter = assert(event_log.decode(cut))
		assert.is_not.equal(head, shorter:head())
	end)

	it("refuses an unchained legacy log, and migrates one into an identical chained log", function()
		local events = sample(3):events()
		local legacy = {}
		for i, e in ipairs(events) do legacy[i] = canonical.encode(e) .. "\n" end
		legacy = table.concat(legacy)
		local _, err = event_log.decode(legacy)
		assert.matches("unchained", err)
		local migrated = assert(event_log.migrate(legacy))
		assert.equal(sample(3):encode(), migrated:encode())
		assert.is_nil(event_log.migrate(migrated:encode()))
	end)
end)
