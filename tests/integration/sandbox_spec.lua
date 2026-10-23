local sandbox = require("ai_edu.sandbox")

local LIMITS = { instructions = 2000000, memory_kb = 32768, cpu_seconds = 2, wall_seconds = 5, address_space_mb = 512 }

local function run(code, input) return sandbox.run({ code = code, input = input or {}, limits = LIMITS }) end

describe("sandbox.command (pure)", function()
	it("wraps the child in a fresh user and network namespace, OS limits and a wall clock", function()
		local argv = sandbox.command({ child = "c.lua", code = "a b", input = "in", out = "o", limits = LIMITS, luajit = "luajit" })
		assert.same({ "unshare", "--user", "--map-root-user", "--net", "--",
			"prlimit", "--as=536870912", "--cpu=2", "--nproc=64", "--",
			"timeout", "--kill-after=1", "5",
			"luajit", "c.lua", "a b", "in", "o", "2000000", "32768" }, argv)
	end)
end)

describe("sandbox.run", function()
	if jit.os ~= "Linux" then
		it("refuses to run where the OS controls are unavailable", function()
			local res = run("return 1")
			assert.is_false(res.ok)
			assert.equal("unavailable", res.error)
		end)
		return
	end

	it("has every required OS control on Linux", function()
		assert.same({ ok = true }, sandbox.available())
	end)

	it("runs an activity on its input and returns its JSON-safe result", function()
		assert.same({ ok = true, result = { sum = 6, word = "abc" } },
			run("local s = 0 for _, x in ipairs(input.xs) do s = s + x end return { sum = s, word = string.rep('abc', 1) }", { xs = { 1, 2, 3 } }))
	end)

	it("strips every escape hatch from the activity's environment", function()
		local names = { "io", "os", "ffi", "jit", "debug", "require", "load", "loadstring", "loadfile", "dofile",
			"package", "module", "collectgarbage", "coroutine", "getfenv", "setfenv", "rawset", "rawget",
			"rawequal", "newproxy", "print", "_G", "getmetatable" }
		local probe, expected = {}, {}
		for _, n in ipairs(names) do
			probe[#probe + 1] = string.format("[%q] = (%s ~= nil)", n, n)
			expected[n] = false
		end
		probe[#probe + 1] = '["string.dump"] = (string.dump ~= nil)'
		expected["string.dump"] = false
		local res = run("return { " .. table.concat(probe, ", ") .. " }")
		assert.is_true(res.ok, res.message)
		assert.same(expected, res.result)
	end)

	it("stops a runaway loop at the instruction limit", function()
		assert.same("instructions", run("while true do end").error)
	end)

	it("cannot swallow the limit with pcall", function()
		assert.same("instructions", run("while true do pcall(function() while true do end end) end").error)
	end)

	it("stops memory growth at the heap limit", function()
		assert.same("memory", run("local t = {} for i = 1, 1e8 do t[i] = string.rep('x', 100) .. i end").error)
	end)

	it("reports compile errors and refuses precompiled bytecode", function()
		assert.equal("compile", run("return +").error)
		assert.equal("compile", run(string.dump(function() return 1 end)).error)
	end)

	it("reports runtime errors and non-JSON results", function()
		local res = run("error('nope')")
		assert.equal("runtime", res.error)
		assert.matches("nope", res.message)
		assert.equal("result", run("return function() end").error)
	end)
end)
