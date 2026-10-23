local evidence_policy = require("ai_edu.evidence_policy")

local function read(path) local f = assert(io.open(path, "rb")); local s = f:read("*a"); f:close(); return s end

local POLICY = dofile("content/evidence_policy.lua")

local function entry(over)
	local e = { id = "x", prior = 1, tier = "A", use = "default", claim = "c",
		review = { file = "docs/evidence/EVIDENCE_2026-09-28.md", section = "## 1. Spaced / distributed practice" },
		sources = { "10.1037/0033-2909.132.3.354" } }
	for k, v in pairs(over or {}) do if v == "nil" then e[k] = nil else e[k] = v end end
	return e
end

local function policy_with(entries)
	return { schema = "evidence-policy/1", policy_version = "pedagogy-priors/2", entries = entries }
end

describe("evidence_policy.validate", function()
	it("accepts the policy in force", function()
		assert.is_true(evidence_policy.validate(POLICY))
		assert.equal("pedagogy-priors/2", POLICY.policy_version)
	end)

	it("classifies a set of policies exactly", function()
		local cases = {
			good = { policy_with({ entry() }), true },
			bad_tier = { policy_with({ entry({ tier = "E" }) }), false },
			bad_use = { policy_with({ entry({ use = "sometimes" }) }), false },
			d_as_default = { policy_with({ entry({ tier = "D", use = "default" }) }), false },
			d_never = { policy_with({ entry({ tier = "D", use = "never" }) }), true },
			d_experiment_without_divergence = { policy_with({ entry({ tier = "D", use = "experiment" }) }), false },
			d_experiment_with_divergence = { policy_with({ entry({ tier = "D", use = "experiment", divergence = "### Variable-rate counterfeit schedule" }) }), true },
			no_sources = { policy_with({ entry({ sources = {} }) }), false },
			bad_doi = { policy_with({ entry({ sources = { "not-a-doi" } }) }), false },
			duplicate_id = { policy_with({ entry(), entry() }), false },
			no_review = { policy_with({ entry({ review = "nil" }) }), false },
			wrong_schema = { { schema = "x", policy_version = "p", entries = {} }, false },
		}
		local expected, got = {}, {}
		for name, c in pairs(cases) do
			expected[name] = c[2]
			got[name] = evidence_policy.validate(c[1]) == true
		end
		assert.same(expected, got)
	end)

	it("cites only sections and DOIs that exist in the reviewed documents", function()
		local missing = {}
		for _, e in ipairs(POLICY.entries) do
			local text = read(e.review.file)
			if not text:find("\n" .. e.review.section .. "\n", 1, true) then missing[#missing + 1] = e.id .. " section" end
			for _, doi in ipairs(e.sources) do
				if not text:find("doi:" .. doi, 1, true) then missing[#missing + 1] = e.id .. " " .. doi end
			end
			if e.divergence and not read("docs/policy/DIVERGENCES.md"):find("\n" .. e.divergence .. "\n", 1, true) then
				missing[#missing + 1] = e.id .. " divergence"
			end
		end
		assert.same({}, missing)
	end)

	it("covers every numbered prior in docs/policy/PEDAGOGY_PRIORS.md", function()
		local priors, covered = {}, {}
		for n in read("docs/policy/PEDAGOGY_PRIORS.md"):gmatch("\n(%d+)%. ") do priors[tonumber(n)] = true end
		for _, e in ipairs(POLICY.entries) do covered[e.prior] = true end
		assert.same(priors, covered)
	end)
end)

describe("evidence_policy.check_lessons", function()
	local policy = policy_with({ entry({ id = "spacing" }), entry({ id = "styles", tier = "D", use = "never" }) })

	it("requires every lesson to cite known, permitted evidence", function()
		assert.is_true(evidence_policy.check_lessons(policy, { { id = "a", techniques = { "spacing" } } }))
		local cases = {
			uncited = { { id = "a" } },
			empty = { { id = "a", techniques = {} } },
			unknown = { { id = "a", techniques = { "vibes" } } },
			never = { { id = "a", techniques = { "spacing", "styles" } } },
		}
		for name, lessons in pairs(cases) do
			local ok, err = evidence_policy.check_lessons(policy, lessons)
			assert.is_nil(ok, name)
			assert.matches("a", err, name)
		end
	end)

	it("passes the real king-and-pawn week", function()
		assert.is_true(evidence_policy.check_lessons(POLICY, dofile("content/kpk_week.lua")))
	end)
end)
