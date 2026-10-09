-- Canonical JSON: sorted object keys, integers only, so equal data always
-- yields identical bytes. Replay determinism is asserted on these bytes.
local cjson = require("cjson")

local canonical = {}

local escapes = {
	['"'] = '\\"', ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f",
	["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t",
}

local function encode_string(s)
	return '"' .. s:gsub('[%c"\\]', function(c)
		return escapes[c] or string.format("\\u%04x", c:byte())
	end) .. '"'
end

-- Classify a table as a dense array (n > 0) or an object (n == 0); mixed tables are errors.
local function array_length(t)
	local n, keys = #t, 0
	for _ in pairs(t) do keys = keys + 1 end
	if n > 0 and keys ~= n then error("canonical: mixed array/object table", 0) end
	return n
end

local encode

local function encode_table(t, out)
	local n = array_length(t)
	if n > 0 then
		out[#out + 1] = "["
		for i = 1, n do
			if i > 1 then out[#out + 1] = "," end
			encode(t[i], out)
		end
		out[#out + 1] = "]"
		return
	end
	local keys = {}
	for k in pairs(t) do
		if type(k) ~= "string" then error("canonical: object keys must be strings", 0) end
		keys[#keys + 1] = k
	end
	table.sort(keys)
	out[#out + 1] = "{"
	for i, k in ipairs(keys) do
		if i > 1 then out[#out + 1] = "," end
		out[#out + 1] = encode_string(k)
		out[#out + 1] = ":"
		encode(t[k], out)
	end
	out[#out + 1] = "}"
end

encode = function(v, out)
	local tv = type(v)
	if tv == "table" then
		encode_table(v, out)
	elseif tv == "string" then
		out[#out + 1] = encode_string(v)
	elseif tv == "boolean" then
		out[#out + 1] = tostring(v)
	elseif tv == "number" then
		if v ~= math.floor(v) or v ~= v or math.abs(v) > 2 ^ 53 then
			error("canonical: only safe integers are allowed, got " .. tostring(v), 0)
		end
		out[#out + 1] = string.format("%d", v)
	else
		error("canonical: unsupported type " .. tv, 0)
	end
end

function canonical.encode(v)
	local out = {}
	encode(v, out)
	return table.concat(out)
end

function canonical.decode(s)
	return cjson.decode(s)
end

return canonical
