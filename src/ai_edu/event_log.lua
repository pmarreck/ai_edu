-- Append-only in-memory event log. Events are validated, deep-copied in and out,
-- and serialized as canonical NDJSON so storage adapters persist exact bytes.
-- Each saved line carries a hash chain (BLAKE3 over the previous line's chain and this
-- entry), so any edit, deletion or reordering of saved lines is detected on decode. Cutting
-- lines off the end is not detectable from the text alone; compare head() with a record kept
-- elsewhere for that.
local canonical = require("ai_edu.canonical")
local event = require("ai_edu.event")
local blake3 = require("blake3").blake3

local event_log = {}

local GENESIS = ""

local function deep_copy(v)
	if type(v) ~= "table" then return v end
	local c = {}
	for k, x in pairs(v) do c[k] = deep_copy(x) end
	return c
end

local function chained(prev, entry)
	return blake3(prev .. "\n" .. canonical.encode(entry))
end

-- The log is a table of closures over private state, so entries and the id index cannot be
-- reached or mutated by field access; only append adds to them.
function event_log.new()
	local entries, lines, ids, head = {}, {}, {}, GENESIS
	local log = {}

	-- Validate and append a copy of e; returns the assigned seq and the saved line (with its
	-- chain hash), or nil plus a reason.
	function log.append(_, e)
		local ok, err = event.validate(e)
		if not ok then return nil, err end
		if ids[e.id] then return nil, "duplicate event id " .. e.id end
		local entry = deep_copy(e)
		entry.seq = #entries + 1
		head = chained(head, entry)
		entry.chain = head
		local line = canonical.encode(entry) .. "\n"
		entry.chain = nil
		entries[entry.seq], lines[entry.seq] = entry, line
		ids[e.id] = true
		return entry.seq, line
	end

	function log.count() return #entries end

	function log.events() return deep_copy(entries) end

	function log.encode() return table.concat(lines) end

	-- The chain hash of the last entry ("" when empty): record it elsewhere to detect a cut tail.
	function log.head() return head end

	return log
end

-- Parse saved lines in order, checking seq and canonical form; calls each(entry, n) for
-- every line, stopping at the first error.
local function each_line(text, each)
	local n = 0
	for line in text:gmatch("[^\n]+") do
		n = n + 1
		local ok, entry = pcall(canonical.decode, line)
		if not ok or type(entry) ~= "table" then return "unparseable line " .. n end
		if entry.seq ~= n then return string.format("seq %s where %d expected", tostring(entry.seq), n) end
		if canonical.encode(entry) ~= line then return "line " .. n .. " is not canonical" end
		local err = each(entry, n)
		if err then return err end
	end
end

-- Rebuild a log from canonical NDJSON, re-validating every event, requiring seq 1..n in order
-- and verifying every chain hash.
function event_log.decode(text)
	local log = event_log.new()
	local err = each_line(text, function(entry, n)
		local chain = entry.chain
		if chain == nil then return "unchained line " .. n .. " (a legacy log: migrate it with tools/chain-log)" end
		entry.seq, entry.chain = nil, nil
		local seq, append_err = log:append(entry)
		if not seq then return "seq " .. n .. ": " .. append_err end
		if log:head() ~= chain then return "chain mismatch at line " .. n .. ": the log was altered" end
	end)
	if err then return nil, err end
	return log
end

-- Convert a pre-chain log (canonical lines without chain hashes) into a chained log holding
-- the same events. Refuses text that already carries chains, so it cannot launder a tampered log.
function event_log.migrate(text)
	local log = event_log.new()
	local err = each_line(text, function(entry, n)
		if entry.chain ~= nil then return "line " .. n .. " is already chained" end
		entry.seq = nil
		local seq, append_err = log:append(entry)
		if not seq then return "seq " .. n .. ": " .. append_err end
	end)
	if err then return nil, err end
	return log
end

return event_log
