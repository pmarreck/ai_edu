package.path = "tests/support/?.lua;" .. package.path
local projection = require("ai_edu.learner_projection")
local event_log = require("ai_edu.event_log")
local canonical = require("ai_edu.canonical")
local fx = require("fixtures")

local function logged(events)
	local log = event_log.new()
	for _, e in ipairs(events) do assert(log:append(e)) end
	return log:events()
end

local function scored(id, t, skill, correct, hint_level)
	return fx.event({ id = id, actor = "engine", type = "answer.scored", occurred_at = t,
		payload = { item_id = "item-" .. id, skill_id = skill, correct = correct, hint_level = hint_level } })
end

local SEEDS = {}
for s = 1, 50 do SEEDS[s] = s * 7919 end

describe("learner_projection.replay", function()
	it("starts empty", function()
		assert.same({ schema = "learner-projection/1", last_seq = 0, learners = {} }, projection.replay({}))
	end)

	it("tracks independent and assisted performance separately", function()
		local p = projection.replay(logged({
			scored("a", 100, "carrying", true, 0),
			scored("b", 200, "carrying", true, 2),
			scored("c", 300, "carrying", false, 0),
			scored("d", 400, "carrying", true, 1),
		}))
		assert.same({
			independent = { attempts = 2, correct = 1 },
			assisted = { attempts = 2, correct = 2 },
			last_independent_success_at = 100,
		}, p.learners.L1.skills.carrying)
		assert.equal(4, p.last_seq)
	end)

	it("does not let assisted success count as an independent success", function()
		local p = projection.replay(logged({ scored("a", 100, "counting", true, 3) }))
		assert.is_nil(p.learners.L1.skills.counting.last_independent_success_at)
	end)

	-- The log now rejects these; replay keeps its own check for logs written before that rule.
	it("refuses a malformed answer.scored payload and names its seq", function()
		for _, payload in ipairs({
			{ correct = true, hint_level = 0 },
			{ skill_id = "s", correct = "yes", hint_level = 0 },
			{ skill_id = "s", correct = true, hint_level = -1 },
			{ skill_id = "s", correct = true, hint_level = 0.5 },
		}) do
			local e = scored("a", 1, "s", true, 0); e.payload = payload; e.seq = 1
			local p, err = projection.replay({ e })
			assert.is_nil(p)
			assert.matches("seq 1", err)
		end
	end)

	it("is byte-identical across repeated replays and a serialize/decode round trip", function()
		for _, seed in ipairs(SEEDS) do
			local log = event_log.new()
			for _, e in ipairs(fx.random_events(seed, 120)) do assert(log:append(e)) end
			local first = canonical.encode(projection.replay(log:events()))
			assert.equal(first, canonical.encode(projection.replay(log:events())))
			local decoded = assert(event_log.decode(log:encode()))
			assert.equal(first, canonical.encode(projection.replay(decoded:events())), "seed " .. seed)
		end
	end)

	it("matches the incrementally maintained projection at every prefix", function()
		local events = logged(fx.random_events(42, 80))
		local live = projection.empty()
		for k = 1, #events do
			live = assert(projection.step(live, events[k]))
			local prefix = {}
			for i = 1, k do prefix[i] = events[i] end
			assert.equal(canonical.encode(projection.replay(prefix)), canonical.encode(live), "prefix " .. k)
		end
	end)

	it("ignores LLM proposals entirely (metamorphic: dropping them changes nothing)", function()
		for _, seed in ipairs(SEEDS) do
			local all = logged(fx.random_events(seed, 120))
			local without, llm_count = {}, 0
			for _, e in ipairs(all) do
				if e.actor:match("^llm:") then llm_count = llm_count + 1 else without[#without + 1] = e end
			end
			assert.is_true(llm_count > 0, "seed " .. seed .. " must include proposals")
			assert.equal(canonical.encode(projection.replay(all).learners),
				canonical.encode(projection.replay(without).learners), "seed " .. seed)
		end
	end)

	it("is independent of the model vendor (metamorphic: rewriting provenance.model changes nothing)", function()
		for _, seed in ipairs(SEEDS) do
			local events = logged(fx.random_events(seed, 120))
			local before = canonical.encode(projection.replay(events))
			for _, e in ipairs(events) do e.provenance.model = "some-future-vendor/model-" .. e.seq end
			assert.equal(before, canonical.encode(projection.replay(events)), "seed " .. seed)
		end
	end)
end)

describe("learner_projection.step purity", function()
	it("returns a new projection and leaves the one passed in untouched", function()
		local events = logged(fx.random_events(77, 60))
		local before = projection.replay({ table.unpack and table.unpack(events, 1, 30) or unpack(events, 1, 30) })
		local snapshot = canonical.encode(before)
		local after = assert(projection.step(before, events[31]))
		assert.equal(snapshot, canonical.encode(before))
		assert.are_not.equal(before, after)
		assert.equal(31, after.last_seq)
	end)
end)
