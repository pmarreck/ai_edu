-- Test-only builders for event/1 records with injected, deterministic timestamps and RNG.
local fixtures = {}

function fixtures.event(overrides)
	local e = {
		schema = "event/1", id = "e1", type = "answer.submitted", actor = "learner",
		learner_id = "L1", occurred_at = 1790000000000, payload = {},
		provenance = { policy_version = "policy/0" },
	}
	for k, v in pairs(overrides or {}) do e[k] = v end
	return e
end

-- Park-Miller minimal-standard PRNG; exact in doubles, so identical on every platform.
function fixtures.rng(seed)
	local state = seed % 2147483647
	if state <= 0 then state = state + 2147483646 end
	return function(n)
		state = (state * 48271) % 2147483647
		return state % n + 1
	end
end

local SKILLS = { "counting", "place_value", "carrying" }
local LEARNERS = { "L1", "L2" }
local MODELS = { "vendor-a/model-1", "vendor-b/model-9" }
local PROPOSALS = { "tutor.response", "misconception.proposed", "observation.proposed", "lesson.planned" }

-- A seeded, valid mix of scored answers, learner events and LLM proposals claiming mastery.
function fixtures.random_events(seed, n)
	local pick, events, t = fixtures.rng(seed), {}, 1790000000000
	for i = 1, n do
		t = t + pick(60000)
		local learner, skill = LEARNERS[pick(#LEARNERS)], SKILLS[pick(#SKILLS)]
		local kind, e = pick(3), nil
		if kind == 1 then
			e = fixtures.event({ actor = "engine", type = "answer.scored",
				payload = { item_id = "item" .. i, skill_id = skill, correct = pick(2) == 1, hint_level = pick(4) - 1 } })
		elseif kind == 2 then
			e = fixtures.event({ type = "hint.requested", payload = { skill_id = skill } })
		else
			e = fixtures.event({ actor = "llm:evaluator", type = PROPOSALS[pick(#PROPOSALS)],
				payload = { skill_id = skill, candidate_mastery_delta = 1, claims = "mastered" } })
		end
		e.id, e.learner_id, e.occurred_at = "ev" .. i, learner, t
		e.provenance = { policy_version = "policy/0", model = MODELS[pick(#MODELS)] }
		events[i] = e
	end
	return events
end

return fixtures
