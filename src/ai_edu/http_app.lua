-- Imperative shell over the pure core: owns the event log, the clock and the current session
-- state. Each API request reads the time once, calls a pure transition, appends the events it
-- returns and keeps the new state. Static files come only from an in-memory allowlist, so no
-- request path can reach the filesystem.
local cjson = require("cjson")
local course = require("ai_edu.course")
local session = require("ai_edu.session")

local http_app = {}

-- Only same-origin scripts, styles, media and fetches; no inline script, no framing.
local SECURITY_HEADERS = {
	["content-security-policy"] = "default-src 'self'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'",
	["x-content-type-options"] = "nosniff",
	["referrer-policy"] = "no-referrer",
}

local function response(status, content_type, body)
	local headers = { ["content-type"] = content_type, ["cache-control"] = "no-store" }
	for k, v in pairs(SECURITY_HEADERS) do headers[k] = v end
	return { status = status, headers = headers, body = body }
end

local function json(status, value)
	return response(status, "application/json", cjson.encode(value))
end

local function decode_object(body)
	local ok, value = pcall(cjson.decode, body or "")
	if not ok or type(value) ~= "table" then return nil end
	return value
end

local App = {}
App.__index = App

-- Append a transition's events to the log and keep its new session state.
function App:_commit(st, events)
	for _, e in ipairs(events) do assert(self.log:append(e)) end
	self.session = st
end

local function no_session() return json(409, { error = "no lesson started" }) end

local routes = {}

routes["/api/lessons"] = function(self)
	local open = self.session and not self.session.completed and self.session.lesson_id or nil
	return json(200, { lessons = course.status(self.course, self.log:events(), self.clock()), in_progress = open })
end

routes["/api/start"] = function(self, req)
	local body = decode_object(req.body)
	if not body or type(body.lesson_id) ~= "string" then return json(400, { error = "expected {lesson_id}" }) end
	local st, events = course.start(self.course, self.log:events(), self.clock(), body.lesson_id)
	if not st then return json(400, { error = events }) end
	self:_commit(st, events)
	return json(200, { lesson_id = body.lesson_id })
end

routes["/api/next"] = function(self)
	if not self.session then return no_session() end
	local st, events, view, done = session.next(self.session, self.clock())
	self:_commit(st, events)
	if done then return json(200, { done = true }) end
	return json(200, { item = view, progress = session.progress(st) })
end

routes["/api/submit"] = function(self, req)
	if not self.session then return no_session() end
	local body = decode_object(req.body)
	if not body or type(body.item_id) ~= "string" or type(body.answer) ~= "table" then
		return json(400, { error = "expected {item_id, answer, modality, hint_level}" })
	end
	local st, events, result = session.submit(self.session, body.item_id, body.answer,
		{ modality = body.modality, hint_level = body.hint_level }, self.clock())
	if not st then return json(400, { error = events }) end
	self:_commit(st, events)
	return json(200, result)
end

routes["/api/report"] = function(self, req)
	if not self.session then return no_session() end
	local body = decode_object(req.body)
	if not body then return json(400, { error = "expected {kind, item_id, note}" }) end
	local st, events = session.report(self.session, body.kind, body.item_id, body.note, self.clock())
	if not st then return json(400, { error = events }) end
	self:_commit(st, events)
	return json(200, { ok = true })
end

-- opts: course (course.define result), log, clock (ms), static = { [path] = { type, body } }.
-- After a restart the learner's unfinished lesson is resumed from the log.
function http_app.new(opts)
	return setmetatable({ course = opts.course, log = opts.log, clock = opts.clock, static = opts.static,
		session = course.resume(opts.course, opts.log:events()) }, App)
end

function App:handle(req)
	local route = routes[req.path]
	if route then
		if req.method ~= "POST" then return json(405, { error = "POST required" }) end
		return route(self, req)
	end
	local file = self.static[req.path]
	if file then
		if req.method ~= "GET" then return json(405, { error = "GET required" }) end
		return response(200, file.type, file.body)
	end
	return json(404, { error = "not found" })
end

return http_app
