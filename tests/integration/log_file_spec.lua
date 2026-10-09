package.path = "tests/support/?.lua;" .. package.path
local log_file = require("ai_edu.log_file")
local fx = require("fixtures")

local counter = 0
local function temp_path()
	counter = counter + 1
	return string.format("%s/ai_edu_log_%d_%d.ndjson", os.getenv("TMPDIR") or "/tmp", os.time(), counter)
end

local function read_all(path)
	local f = assert(io.open(path, "rb")); local s = f:read("*a"); f:close(); return s
end

describe("log_file", function()
	it("persists appends and replays them on reopen", function()
		local path = temp_path()
		local log = assert(log_file.open(path))
		assert.equal(1, log:append(fx.event({ id = "a" })))
		assert.equal(2, log:append(fx.event({ id = "b", type = "hint.requested" })))
		log:close()
		local reopened = assert(log_file.open(path))
		assert.equal(2, reopened:count())
		assert.same(log:events(), reopened:events())
		assert.equal(3, reopened:append(fx.event({ id = "c" })))
		reopened:close()
		os.remove(path)
	end)

	it("writes nothing for a rejected event", function()
		local path = temp_path()
		local log = assert(log_file.open(path))
		log:append(fx.event({ id = "a" }))
		local before = read_all(path)
		assert.is_nil(log:append(fx.event({ id = "a" })))
		assert.is_nil(log:append(fx.event({ id = "x", actor = "llm:tutor", type = "answer.scored" })))
		assert.equal(before, read_all(path))
		log:close()
		os.remove(path)
	end)

	it("refuses to open a tampered file", function()
		local path = temp_path()
		local log = assert(log_file.open(path))
		log:append(fx.event({ id = "a" }))
		log:close()
		local f = assert(io.open(path, "ab")); f:write('{"seq":7}\n'); f:close()
		local reopened, err = log_file.open(path)
		assert.is_nil(reopened)
		assert.matches("seq", err)
		os.remove(path)
	end)
end)
