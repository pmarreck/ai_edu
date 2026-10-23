-- Child side of the activity sandbox; run only by sandbox.run inside OS limits. Loads one
-- activity as source text into a stripped environment, interprets it with the JIT off so the
-- instruction-count hook sees every instruction, and writes a JSON outcome to the out file.
-- argv: code_file input_file out_file max_instructions max_heap_kb
jit.off()
local cjson = require("cjson")

local function read(path)
	local f = assert(io.open(path, "rb"))
	local s = f:read("*a")
	f:close()
	return s
end

local code_file, input_file, out_file = arg[1], arg[2], arg[3]
local max_instructions, max_kb = tonumber(arg[4]), tonumber(arg[5])

local function emit(outcome)
	local f = assert(io.open(out_file, "wb"))
	f:write(cjson.encode(outcome))
	f:close()
	os.exit(0)
end

local function copy(t)
	local c = {}
	for k, v in pairs(t) do c[k] = v end
	return c
end

-- Hook granularity: the limit is enforced to within this many VM instructions.
local CHUNK = 1000
local used, tripped = 0, nil

local function check()
	if tripped then error(tripped .. " limit", 0) end
end

-- pcall and xpcall that re-raise once a limit has tripped, so activity code cannot swallow it.
local function guarded(f, ...)
	local r = { pcall(f, ...) }
	check()
	return unpack(r, 1, table.maxn(r))
end
local function guarded_x(f, handler, ...)
	local args, n = { ... }, select("#", ...)
	local r = { xpcall(function() return f(unpack(args, 1, n)) end, handler) }
	check()
	return unpack(r, 1, table.maxn(r))
end

local string_lib = copy(string)
string_lib.dump = nil
local env = {
	assert = assert, error = error, ipairs = ipairs, next = next, pairs = pairs, select = select,
	tonumber = tonumber, tostring = tostring, type = type, unpack = unpack, setmetatable = setmetatable,
	pcall = guarded, xpcall = guarded_x,
	math = copy(math), string = string_lib, table = copy(table),
}

local code = read(code_file)
if code:byte(1) == 27 then emit({ ok = false, error = "compile", message = "precompiled bytecode is refused" }) end
local fn, compile_err = load(code, "=activity", "t", env)
if not fn then emit({ ok = false, error = "compile", message = compile_err }) end

local input = cjson.decode(read(input_file))
env.input = input

debug.sethook(function()
	used = used + CHUNK
	if used > max_instructions then tripped = "instructions" end
	if not tripped and collectgarbage("count") > max_kb then tripped = "memory" end
	check()
end, "", CHUNK)
local ok, result = pcall(fn, input)
debug.sethook()

if tripped then emit({ ok = false, error = tripped }) end
if not ok then emit({ ok = false, error = "runtime", message = tostring(result) }) end
local encodable, encoded = pcall(cjson.encode, { ok = true, result = result })
if not encodable then emit({ ok = false, error = "result", message = "result is not JSON-safe" }) end
local f = assert(io.open(out_file, "wb"))
f:write(encoded)
f:close()
