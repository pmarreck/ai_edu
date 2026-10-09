-- File-backed event log: replays an existing canonical NDJSON file on open (re-validating
-- every event), then appends one flushed line per accepted event. Rejected events write nothing.
local event_log = require("ai_edu.event_log")
local canonical = require("ai_edu.canonical")

local log_file = {}

local FileLog = {}
FileLog.__index = FileLog

function log_file.open(path)
	local text = ""
	local existing = io.open(path, "rb")
	if existing then
		text = existing:read("*a")
		existing:close()
	end
	local log, err = event_log.decode(text)
	if not log then return nil, path .. ": " .. err end
	local file, open_err = io.open(path, "ab")
	if not file then return nil, open_err end
	return setmetatable({ log = log, file = file }, FileLog)
end

function FileLog:append(e)
	local seq, err = self.log:append(e)
	if not seq then return nil, err end
	-- complexity: O(size of e); encode a shallow copy plus seq, not a copy of the whole log.
	local entry = {}
	for k, v in pairs(e) do entry[k] = v end
	entry.seq = seq
	assert(self.file:write(canonical.encode(entry), "\n"))
	assert(self.file:flush())
	return seq
end

function FileLog:events() return self.log:events() end
function FileLog:count() return self.log:count() end
function FileLog:close() self.file:close() end

return log_file
