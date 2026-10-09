-- lua-http adapter: binds a socket and translates HTTP streams to and from the pure
-- handler contract ({method, path, body} -> {status, headers, body}). No app logic here.
local http_server = require("http.server")
local http_headers = require("http.headers")

local web_server = {}

local DEFAULT_MAX_BODY = 64 * 1024
local IO_TIMEOUT_S = 10

local function reply(stream, status, headers, body)
	local h = http_headers.new()
	h:append(":status", tostring(status))
	for k, v in pairs(headers or {}) do h:append(k, v) end
	assert(stream:write_headers(h, body == ""))
	if body ~= "" then assert(stream:write_chunk(body, true)) end
end

-- Read the request body, refusing anything over max_body bytes.
local function read_body(stream, max_body)
	local parts, size = {}, 0
	while true do
		local chunk = stream:get_next_chunk(IO_TIMEOUT_S)
		if not chunk then break end
		size = size + #chunk
		if size > max_body then return nil end
		parts[#parts + 1] = chunk
	end
	return table.concat(parts)
end

-- opts: host, port (0 = ephemeral), handler, max_body. Returns a bound lua-http server.
function web_server.listen(opts)
	local max_body = opts.max_body or DEFAULT_MAX_BODY
	local server = http_server.listen({
		host = opts.host, port = opts.port,
		onstream = function(_, stream)
			local req_headers = assert(stream:get_headers(IO_TIMEOUT_S))
			local method = req_headers:get(":method")
			local path = (req_headers:get(":path") or "/"):match("^[^?#]*")
			local body = read_body(stream, max_body)
			if not body then return reply(stream, 413, { ["content-type"] = "text/plain" }, "request body too large") end
			local res = opts.handler({ method = method, path = path, body = body })
			reply(stream, res.status, res.headers, res.body or "")
		end,
	})
	local ok, err = server:listen()
	if not ok then return nil, err end
	return server
end

return web_server
