local cqueues = require("cqueues")
local http_request = require("http.request")
local web_server = require("ai_edu.web_server")

-- Stub handler: the adapter's only job is faithful translation of requests and responses.
local seen = {}
local function handler(req)
	seen[#seen + 1] = req
	return { status = 201, headers = { ["content-type"] = "text/plain", ["x-probe"] = "yes" },
		body = req.method .. " " .. req.path .. " " .. (req.body or "") }
end

describe("web_server (lua-http adapter)", function()
	it("round-trips method, path, body, status and headers over a real socket", function()
		local server = assert(web_server.listen({ host = "127.0.0.1", port = 0, handler = handler }))
		local _, host, port = server:localname()
		local cq = cqueues.new()
		local results = {}
		cq:wrap(function() assert(server:loop()) end)
		cq:wrap(function()
			local req = http_request.new_from_uri(string.format("http://%s:%d/api/next?x=1", host, port))
			req.headers:upsert(":method", "POST")
			req:set_body('{"a":1}')
			local headers, stream = assert(req:go(5))
			results.status = headers:get(":status")
			results.probe = headers:get("x-probe")
			results.body = assert(stream:get_body_as_string())
			server:close()
		end)
		assert(cq:loop(10))
		assert.equal("201", results.status)
		assert.equal("yes", results.probe)
		assert.equal('POST /api/next {"a":1}', results.body)
		assert.equal("/api/next", seen[1].path)
	end)

	it("rejects bodies over the size limit with 413 before calling the handler", function()
		local calls = 0
		local server = assert(web_server.listen({ host = "127.0.0.1", port = 0, max_body = 16,
			handler = function() calls = calls + 1; return { status = 200, headers = {}, body = "" } end }))
		local _, host, port = server:localname()
		local cq, status, body = cqueues.new(), nil, nil
		cq:wrap(function() assert(server:loop()) end)
		cq:wrap(function()
			local req = http_request.new_from_uri(string.format("http://%s:%d/api/submit", host, port))
			req.headers:upsert(":method", "POST")
			req:set_body(string.rep("x", 17))
			local headers, stream = assert(req:go(5))
			-- Consume the response; an unread body holds the keep-alive connection open until timeout.
			body = stream:get_body_as_string()
			status = headers:get(":status")
			server:close()
		end)
		assert(cq:loop(10))
		assert.equal("413", status)
		assert.equal("request body too large", body)
		assert.equal(0, calls)
	end)
end)
