-- Runs untrusted (for example, model-generated) LuaJIT activity code in a separate process with
-- layered limits: a fresh user and network namespace (no network), address-space, CPU-time and
-- process-count ceilings (prlimit), a wall clock (timeout), and inside the child a stripped
-- environment with an instruction-count and heap hook (src/ai_edu/sandbox_child.lua).
-- Linux only; elsewhere it refuses rather than run with weaker controls.
local cjson = require("cjson")

local sandbox = {}

local REQUIRED_TOOLS = { "unshare", "prlimit", "timeout" }
local MAX_PROCESSES = 64
local KILL_GRACE_SECONDS = 1
local MB = 1024 * 1024

local here = debug.getinfo(1, "S").source:match("^@(.*)/[^/]*$") or "."
local CHILD = here .. "/sandbox_child.lua"

-- The exact argv for one run (pure, so the wrapping is testable without spawning anything).
-- spec: child, code, input, out (file paths), limits, luajit.
function sandbox.command(spec)
	local l = spec.limits
	return {
		"unshare", "--user", "--map-root-user", "--net", "--",
		"prlimit", "--as=" .. math.floor(l.address_space_mb * MB), "--cpu=" .. l.cpu_seconds, "--nproc=" .. MAX_PROCESSES, "--",
		"timeout", "--kill-after=" .. KILL_GRACE_SECONDS, tostring(l.wall_seconds),
		spec.luajit, spec.child, spec.code, spec.input, spec.out, tostring(l.instructions), tostring(l.memory_kb),
	}
end

local function quote(s) return "'" .. tostring(s):gsub("'", "'\\''") .. "'" end

local function sh(argv)
	local parts = {}
	for i, a in ipairs(argv) do parts[i] = quote(a) end
	return table.concat(parts, " ")
end

local function exit_code(a, b, c)
	-- LuaJIT os.execute returns (true|nil, "exit"|"signal", code) under 5.2 compat, or a status number.
	if type(a) == "number" then return a > 255 and math.floor(a / 256) or a end
	return c
end

-- { ok = true } when every OS control works here, else { ok = false, missing = reason }.
function sandbox.available()
	if jit.os ~= "Linux" then return { ok = false, missing = "Linux namespaces and prlimit" } end
	for _, tool in ipairs(REQUIRED_TOOLS) do
		if exit_code(os.execute("command -v " .. tool .. " >/dev/null 2>&1")) ~= 0 then return { ok = false, missing = tool } end
	end
	if exit_code(os.execute("unshare --user --map-root-user --net -- true >/dev/null 2>&1")) ~= 0 then
		return { ok = false, missing = "unprivileged user and network namespaces" }
	end
	return { ok = true }
end

local function scratch_dir()
	local base = os.getenv("TMPDIR") or "/tmp"
	local p = io.popen("mktemp -d " .. quote(base .. "/ai_edu_sandbox.XXXXXX"))
	local dir = p:read("*l")
	p:close()
	return dir
end

local function write(path, text)
	local f = assert(io.open(path, "wb"))
	assert(f:write(text))
	f:close()
end

-- opts: code (source text), input (JSON-safe table), limits = { instructions, memory_kb,
-- cpu_seconds, wall_seconds, address_space_mb }, luajit (optional interpreter path). Returns { ok = true, result } or
-- { ok = false, error = compile|runtime|result|instructions|memory|killed|unavailable, message? }.
function sandbox.run(opts)
	local avail = sandbox.available()
	if not avail.ok then return { ok = false, error = "unavailable", message = avail.missing } end
	local dir = scratch_dir()
	local files = { code = dir .. "/activity.lua", input = dir .. "/input.json", out = dir .. "/out.json" }
	write(files.code, opts.code)
	write(files.input, cjson.encode(opts.input or {}))
	local argv = sandbox.command({ child = CHILD, code = files.code, input = files.input, out = files.out,
		limits = opts.limits, luajit = opts.luajit or "luajit" })
	local status = exit_code(os.execute(sh(argv) .. " >/dev/null 2>&1"))
	local f = io.open(files.out, "rb")
	local text = f and f:read("*a")
	if f then f:close() end
	for _, path in pairs(files) do os.remove(path) end
	os.remove(dir)
	if status == 0 and text then
		local ok, outcome = pcall(cjson.decode, text)
		if ok and type(outcome) == "table" then return outcome end
	end
	return { ok = false, error = "killed", message = "child ended without an outcome (exit " .. tostring(status) .. ")" }
end

return sandbox
