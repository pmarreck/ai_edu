-- Drives a session through the public HTTP API exactly as the browser client does
-- (POST /api/next, then POST /api/submit), with answers from a simulated learner.
-- Must run inside a cqueues coroutine; lua-http requests yield.
local http_request = require("http.request")
local cjson = require("cjson")

local sim_client = {}

local REQUEST_TIMEOUT_S = 5
local MAX_TURNS = 10000

local function post(base_url, path, value)
	local req = http_request.new_from_uri(base_url .. path)
	req.headers:upsert(":method", "POST")
	req.headers:upsert("content-type", "application/json")
	req:set_body(cjson.encode(value))
	local headers, stream = req:go(REQUEST_TIMEOUT_S)
	if not headers then return nil, "request failed: " .. tostring(stream) end
	local body = stream:get_body_as_string(REQUEST_TIMEOUT_S)
	local status = headers:get(":status")
	if status ~= "200" then return nil, path .. " -> " .. status .. " " .. tostring(body) end
	return cjson.decode(body)
end

-- Returns a transcript { {item_id, answer, modality, correct}, ... } or nil plus a reason.
function sim_client.run(base_url, learner)
	local transcript = {}
	for _ = 1, MAX_TURNS do
		local nxt, err = post(base_url, "/api/next", {})
		if not nxt then return nil, err end
		if nxt.done then return transcript end
		local reply = learner:answer(nxt.item)
		local result, submit_err = post(base_url, "/api/submit", {
			item_id = nxt.item.id, answer = reply.answer, modality = reply.modality, hint_level = reply.hint_level,
		})
		if not result then return nil, submit_err end
		transcript[#transcript + 1] = { item_id = nxt.item.id, answer = reply.answer,
			modality = reply.modality, correct = result.correct }
	end
	return nil, "session did not finish within " .. MAX_TURNS .. " turns"
end

return sim_client
