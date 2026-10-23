local curriculum = require("ai_edu.curriculum")
local rng = require("ai_edu.rng")

local function node(id, prerequisites, related)
	return { schema = "curriculum-node/1", id = id, title = id, objective = "know " .. id,
		prerequisites = prerequisites or {}, related = related or {}, sources = { "test" } }
end

local function graph(edges)
	local out = {}
	for _, e in ipairs(edges) do out[#out + 1] = node(e[1], e[2], e[3]) end
	return out
end

describe("curriculum.validate", function()
	it("classifies a set of graphs exactly: only well-formed acyclic graphs pass", function()
		local cases = {
			empty = { {}, true },
			chain = { graph({ { "a" }, { "b", { "a" } }, { "c", { "b" } } }), true },
			diamond = { graph({ { "a" }, { "b", { "a" } }, { "c", { "a" } }, { "d", { "b", "c" } } }), true },
			related_cycle_ok = { graph({ { "a", {}, { "b" } }, { "b", {}, { "a" } } }), true },
			self_loop = { graph({ { "a", { "a" } } }), false },
			two_cycle = { graph({ { "a", { "b" } }, { "b", { "a" } } }), false },
			long_cycle = { graph({ { "a", { "c" } }, { "b", { "a" } }, { "c", { "b" } }, { "d" } }), false },
			dangling_prereq = { graph({ { "a", { "zz" } } }), false },
			dangling_related = { graph({ { "a", {}, { "zz" } } }), false },
			duplicate_id = { graph({ { "a" }, { "a" } }), false },
			duplicate_prereq = { graph({ { "a" }, { "b", { "a", "a" } } }), false },
			wrong_schema = { { (function() local n = node("a"); n.schema = "x"; return n end)() }, false },
			no_objective = { { (function() local n = node("a"); n.objective = nil; return n end)() }, false },
			empty_id = { { node("") }, false },
			not_a_list = { { (function() local n = node("a"); n.prerequisites = "b"; return n end)() }, false },
		}
		local expected, got = {}, {}
		for name, c in pairs(cases) do
			expected[name] = c[2]
			got[name] = curriculum.validate(c[1]) == true
		end
		assert.same(expected, got)
	end)

	it("names every problem it finds", function()
		local ok, errs = curriculum.validate(graph({ { "a", { "b" } }, { "b", { "a" } }, { "c", { "zz" } } }))
		assert.is_nil(ok)
		local text = table.concat(errs, "\n")
		assert.matches("cycle", text)
		assert.matches("zz", text)
	end)

	it("orders random DAGs so every prerequisite comes first, and catches one added back edge", function()
		for seed = 1, 200 do
			local rand = rng.new(seed)
			local n, edges = 2 + math.floor(rand() * 12), {}
			for i = 1, n do
				local pre = {}
				for j = 1, i - 1 do if rand() < 0.3 then pre[#pre + 1] = "n" .. j end end
				edges[i] = { "n" .. i, pre }
			end
			-- shuffle input order so the sort, not the input, provides the order
			for i = n, 2, -1 do
				local j = 1 + math.floor(rand() * i)
				edges[i], edges[j] = edges[j], edges[i]
			end
			local g = graph(edges)
			local order = assert(curriculum.order(g))
			local pos = {}
			for i, id in ipairs(order) do pos[id] = i end
			assert.equal(n, #order)
			for _, nd in ipairs(g) do
				for _, p in ipairs(nd.prerequisites) do assert.is_true(pos[p] < pos[nd.id]) end
			end
			-- an edge from the first node in order back to the last always closes a cycle when they are connected
			local first, last = order[1], order[n]
			local reach = {}
			for _, nd in ipairs(g) do
				if nd.id == first then
					local copy = {}
					for _, p in ipairs(nd.prerequisites) do copy[#copy + 1] = p end
					copy[#copy + 1] = last
					nd.prerequisites = copy
				end
			end
			local depends_on_first = false
			local by_id = {}
			for _, nd in ipairs(g) do by_id[nd.id] = nd end
			local function reaches(id, target, seen)
				if id == target then return true end
				if seen[id] then return false end
				seen[id] = true
				for _, p in ipairs(by_id[id].prerequisites) do if reaches(p, target, seen) then return true end end
				return false
			end
			depends_on_first = reaches(last, first, reach)
			assert.equal(not depends_on_first, curriculum.validate(g) == true, "seed " .. seed)
		end
	end)

	it("does not mutate the nodes it is given", function()
		local g = graph({ { "b", { "a" } }, { "a" } })
		local before = require("ai_edu.canonical").encode(g)
		curriculum.order(g)
		curriculum.validate(g)
		assert.equal(before, require("ai_edu.canonical").encode(g))
	end)
end)

describe("king-and-pawn curriculum", function()
	it("is a valid graph whose ids are exactly the skills the week's items score", function()
		local nodes = dofile("content/kpk_curriculum.lua")
		assert.is_true(curriculum.validate(nodes))
		local lessons = assert(require("ai_edu.kpk_content").build(require("ai_edu.kpk").shared(), dofile("content/kpk_week.lua")))
		local scored, ids = {}, {}
		for _, l in ipairs(lessons) do
			for _, it in ipairs(l.items) do
				if it.response.kind ~= "info" then for _, s in ipairs(it.skill_ids) do scored[s] = true end end
			end
		end
		for _, nd in ipairs(nodes) do ids[nd.id] = true end
		assert.same(scored, ids)
	end)
end)
