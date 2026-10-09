-- Server entrypoint: wires the real clock, file-backed log, solver-built course, static client
-- files and the lua-http adapter. All decisions live in the pure modules this composes.
local ffi = require("ffi")
local cqueues = require("cqueues")

local VERSION = "0.1.0"
local USAGE = [[
Usage: serve [options]

Serve the ai_edu learning web app.

Options:
  --host HOST     Address to bind (default 127.0.0.1; use 0.0.0.0 or a tailnet IP to share)
  --port PORT     Port to bind (default 8420; 0 picks a free port)
  --data DIR      Directory for the learner event log (default ./data)
  --learner ID    Learner id recorded on events (default learner)
  -h, --help      Show this help
  --about         One-line description, version and platform
]]

ffi.cdef [[
	typedef struct { long tv_sec; long tv_nsec; } ai_edu_timespec;
	int clock_gettime(int clk_id, ai_edu_timespec *tp);
]]
local CLOCK_REALTIME = 0

-- Wall-clock milliseconds since the Unix epoch (adapter-only; the core receives this injected).
local function now_ms()
	local ts = ffi.new("ai_edu_timespec")
	ffi.C.clock_gettime(CLOCK_REALTIME, ts)
	return tonumber(ts.tv_sec) * 1000 + math.floor(tonumber(ts.tv_nsec) / 1e6)
end

-- Local calendar day number for a timestamp, using that timestamp's own UTC offset (DST-safe).
local function local_day_index(ms)
	local secs = math.floor(ms / 1000)
	local l, u = os.date("*t", secs), os.date("!*t", secs)
	u.isdst = l.isdst
	local offset = os.difftime(os.time(l), os.time(u))
	return math.floor((secs + offset) / 86400)
end

local function parse_args(argv)
	local opts = { host = "127.0.0.1", port = 8420, data = "data", learner = "learner" }
	local i = 1
	while i <= #argv do
		local a = argv[i]
		if a == "-h" or a == "--help" or a == "/?" then opts.help = true
		elseif a == "--about" then opts.about = true
		elseif a == "--host" or a == "--port" or a == "--data" or a == "--learner" then
			local v = argv[i + 1]
			if not v then return nil, a .. " needs a value" end
			opts[a:sub(3)] = v
			i = i + 1
		else return nil, "unknown argument " .. a end
		i = i + 1
	end
	opts.port = tonumber(opts.port)
	if not opts.port then return nil, "--port must be a number" end
	return opts
end

local function read_file(path)
	local f = assert(io.open(path, "rb"))
	local s = f:read("*a")
	f:close()
	return s
end

local STATIC = {
	["/"] = { file = "web/index.html", type = "text/html; charset=utf-8" },
	["/app.js"] = { file = "web/app.js", type = "text/javascript; charset=utf-8" },
	["/style.css"] = { file = "web/style.css", type = "text/css; charset=utf-8" },
}

local function main(argv)
	local opts, err = parse_args(argv)
	if not opts then
		io.stderr:write("serve: ", err, "\n", USAGE)
		return 2
	end
	if opts.help then io.stdout:write(USAGE); return 0 end
	if opts.about then
		io.stdout:write(string.format("ai_edu serve %s: evidence-adaptive learning web app (%s %s, %s)\n",
			VERSION, jit.os, jit.arch, jit.version))
		return 0
	end

	local kpk = require("ai_edu.kpk")
	local kpk_content = require("ai_edu.kpk_content")
	local log_file = require("ai_edu.log_file")
	local course = require("ai_edu.course")
	local http_app = require("ai_edu.http_app")
	local web_server = require("ai_edu.web_server")

	local lessons = assert(kpk_content.build(kpk.shared(), dofile("content/kpk_week.lua")))
	os.execute("mkdir -p '" .. opts.data:gsub("'", "'\\''") .. "'")
	local log = assert(log_file.open(opts.data .. "/events.ndjson"))
	local reviews = require("ai_edu.kpk_review").new({ solved = kpk.shared(), lessons = lessons,
		learner_id = opts.learner, day_index = local_day_index })
	local c = course.define({ lessons = lessons, learner_id = opts.learner,
		policy_version = "pedagogy-priors/2", day_index = local_day_index, reviews = reviews })
	local static = {}
	for path, spec in pairs(STATIC) do static[path] = { type = spec.type, body = read_file(spec.file) } end
	local app = http_app.new({ course = c, log = log, clock = now_ms, static = static })
	local server = assert(web_server.listen({ host = opts.host, port = opts.port,
		handler = function(req) return app:handle(req) end }))
	local _, host, port = server:localname()
	io.stderr:write(string.format("serving on http://%s:%d (log: %s/events.ndjson, %d events)\n",
		host, port, opts.data, log:count()))
	local cq = cqueues.new()
	cq:wrap(function() assert(server:loop()) end)
	assert(cq:loop())
	return 0
end

os.exit(main(arg))
