-- Append-only in-memory event log. Events are validated, deep-copied in and out,
-- and serialized as canonical NDJSON so storage adapters persist exact bytes.
local canonical = require("ai_edu.canonical")
local event = require("ai_edu.event")

local event_log = {}

local function deep_copy(v)
	if type(v) ~= "table" then return v end
	local c = {}
	for k, x in pairs(v) do c[k] = deep_copy(x) end
	return c
end

local Log = {}
Log.__index = Log

function event_log.new()
	return setmetatable({ _entries = {}, _ids = {} }, Log)
end

-- Validate and append a copy of e; returns the assigned seq, or nil plus a reason.
function Log:append(e)
	local ok, err = event.validate(e)
	if not ok then return nil, err end
	if self._ids[e.id] then return nil, "duplicate event id " .. e.id end
	local entry = deep_copy(e)
	entry.seq = #self._entries + 1
	self._entries[entry.seq] = entry
	self._ids[e.id] = true
	return entry.seq
end

function Log:count()
	return #self._entries
end

function Log:events()
	return deep_copy(self._entries)
end

function Log:encode()
	local lines = {}
	for i, entry in ipairs(self._entries) do lines[i] = canonical.encode(entry) .. "\n" end
	return table.concat(lines)
end

-- Rebuild a log from canonical NDJSON, re-validating every event and requiring seq 1..n in order.
function event_log.decode(text)
	local log = event_log.new()
	for line in text:gmatch("[^\n]+") do
		local ok, entry = pcall(canonical.decode, line)
		if not ok or type(entry) ~= "table" then return nil, "unparseable line " .. (log:count() + 1) end
		local expected = log:count() + 1
		if entry.seq ~= expected then
			return nil, string.format("seq %s where %d expected", tostring(entry.seq), expected)
		end
		entry.seq = nil
		local seq, err = log:append(entry)
		if not seq then return nil, "seq " .. expected .. ": " .. err end
	end
	return log
end

return event_log
