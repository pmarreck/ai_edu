-- curriculum-node/1: the skill graph. Prerequisites must form a DAG over known ids; `related`
-- links are informational and may be cyclic. Pure functions; nodes are never mutated.
local curriculum = {}

curriculum.SCHEMA = "curriculum-node/1"

local function nonempty_string(s) return type(s) == "string" and s ~= "" end

local function id_list_error(nd, field)
	local list = nd[field]
	if type(list) ~= "table" then return field .. " must be a list" end
	local seen = {}
	for i = 1, #list do
		if not nonempty_string(list[i]) then return field .. " must hold non-empty ids" end
		if seen[list[i]] then return field .. " repeats " .. list[i] end
		seen[list[i]] = true
	end
	for k in pairs(list) do
		if type(k) ~= "number" or k > #list then return field .. " must be a list" end
	end
end

-- Kahn's algorithm with a sorted ready set, so the order is deterministic for a given graph.
-- Returns the ids in prerequisite-first order and the ids left on a cycle (if any).
local function topological(nodes)
	local indegree, dependents = {}, {}
	for _, nd in ipairs(nodes) do indegree[nd.id] = indegree[nd.id] or 0; dependents[nd.id] = dependents[nd.id] or {} end
	for _, nd in ipairs(nodes) do
		for _, p in ipairs(nd.prerequisites) do
			if dependents[p] then
				indegree[nd.id] = indegree[nd.id] + 1
				table.insert(dependents[p], nd.id)
			end
		end
	end
	local ready, order = {}, {}
	for id, d in pairs(indegree) do if d == 0 then ready[#ready + 1] = id end end
	while #ready > 0 do
		table.sort(ready, function(a, b) return a > b end)
		local id = table.remove(ready)
		order[#order + 1] = id
		for _, dep in ipairs(dependents[id]) do
			indegree[dep] = indegree[dep] - 1
			if indegree[dep] == 0 then ready[#ready + 1] = dep end
		end
	end
	local stuck = {}
	for id, d in pairs(indegree) do if d > 0 then stuck[#stuck + 1] = id end end
	table.sort(stuck)
	return order, stuck
end

-- Returns true, or nil plus a list of every problem: shape, duplicate or dangling ids, cycles.
function curriculum.validate(nodes)
	local errs, ids = {}, {}
	for i, nd in ipairs(nodes) do
		local where = "node " .. i
		if type(nd) ~= "table" or nd.schema ~= curriculum.SCHEMA then
			errs[#errs + 1] = where .. ": schema must be " .. curriculum.SCHEMA
		elseif not nonempty_string(nd.id) then
			errs[#errs + 1] = where .. ": id required"
		else
			where = nd.id
			if ids[nd.id] then errs[#errs + 1] = where .. ": duplicate id" end
			ids[nd.id] = true
			for _, f in ipairs({ "title", "objective" }) do
				if not nonempty_string(nd[f]) then errs[#errs + 1] = where .. ": " .. f .. " required" end
			end
			for _, f in ipairs({ "prerequisites", "related", "sources" }) do
				local err = id_list_error(nd, f)
				if err then errs[#errs + 1] = where .. ": " .. err end
			end
		end
	end
	if #errs > 0 then return nil, errs end
	for _, nd in ipairs(nodes) do
		for _, f in ipairs({ "prerequisites", "related" }) do
			for _, ref in ipairs(nd[f]) do
				if not ids[ref] then errs[#errs + 1] = nd.id .. ": " .. f .. " names unknown id " .. ref end
			end
		end
	end
	local _, stuck = topological(nodes)
	if #stuck > 0 then errs[#errs + 1] = "prerequisite cycle; these ids are on or behind it: " .. table.concat(stuck, ", ") end
	if #errs > 0 then return nil, errs end
	return true
end

-- Ids in an order where every prerequisite precedes its dependents, or nil plus the problems.
function curriculum.order(nodes)
	local ok, errs = curriculum.validate(nodes)
	if not ok then return nil, errs end
	return (topological(nodes))
end

return curriculum
