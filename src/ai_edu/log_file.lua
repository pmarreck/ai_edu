-- File-backed event log: replays an existing canonical NDJSON file on open (re-validating
-- every event), then appends one flushed line per accepted event. Rejected events write nothing.
local event_log = require("ai_edu.event_log")

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
	local seq, line = self.log:append(e)
	if not seq then return nil, line end
	assert(self.file:write(line))
	assert(self.file:flush())
	return seq
end

function FileLog:events() return self.log:events() end
function FileLog:count() return self.log:count() end
function FileLog:close() self.file:close() end

-- One-time conversion of a pre-chain log file: the original is kept at <path>.pre-chain and the
-- chained version replaces it by rename. Refuses when the backup already exists or the file is
-- already chained or invalid, leaving everything untouched.
function log_file.migrate(path)
	local backup = path .. ".pre-chain"
	local exists = io.open(backup, "rb")
	if exists then exists:close(); return nil, backup .. " already exists" end
	local f, open_err = io.open(path, "rb")
	if not f then return nil, open_err end
	local text = f:read("*a")
	f:close()
	local log, err = event_log.migrate(text)
	if not log then return nil, path .. ": " .. err end
	local tmp = path .. ".chain-tmp"
	local out = assert(io.open(tmp, "wb"))
	assert(out:write(log:encode()))
	assert(out:close())
	assert(os.rename(path, backup))
	assert(os.rename(tmp, path))
	return true
end

return log_file
