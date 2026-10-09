local event = require("ai_edu.event")

-- Independent oracle: which actor may emit which type. Kept here, not imported,
-- so a change to the module's table cannot silently change the expectation.
local LEARNER = {
	"student.response", "student.prediction", "student.self_explanation", "hint.requested",
	"answer.submitted", "activity.failure_reported", "challenge.raised", "break.requested",
}
local ENGINE = {
	"session.started", "activity.presented", "hint.given", "answer.scored",
	"observation.accepted", "observation.rejected", "misconception.confirmed",
	"break.offered", "break.started", "break.ended", "artifact.fallback_used",
	"lesson.completed", "retrieval.scheduled",
}
local PARENT = { "annotation.added" }
local LLM = { "lesson.planned", "tutor.response", "misconception.proposed", "observation.proposed" }
local LLM_ROLES = { "planner", "tutor", "evaluator", "verifier", "research" }

local function valid_event(overrides)
	local e = {
		schema = "event/1", id = "e1", type = "answer.submitted", actor = "learner",
		learner_id = "L1", occurred_at = 1790000000000, payload = {},
		provenance = { policy_version = "policy/0" },
	}
	for k, v in pairs(overrides or {}) do e[k] = v end
	return e
end

describe("event.validate", function()
	it("accepts a well-formed event", function()
		assert.is_true(event.validate(valid_event()))
	end)

	it("classifies the full actor x type set exactly as the canonical-state rule requires", function()
		local allowed = {}
		local function allow(actor, types) for _, t in ipairs(types) do allowed[actor .. "|" .. t] = true end end
		allow("learner", LEARNER); allow("engine", ENGINE); allow("parent", PARENT)
		local actors = { "learner", "engine", "parent", "admin", "llm:", "llm:bogus", "tutor" }
		for _, r in ipairs(LLM_ROLES) do
			actors[#actors + 1] = "llm:" .. r
			allow("llm:" .. r, LLM)
		end
		local types = { "no.such_type", "" }
		for _, set in ipairs({ LEARNER, ENGINE, PARENT, LLM }) do
			for _, t in ipairs(set) do types[#types + 1] = t end
		end
		local mismatches, checked = {}, 0
		for _, a in ipairs(actors) do
			for _, t in ipairs(types) do
				checked = checked + 1
				local payload = t == "answer.scored" and { item_id = "i", skill_id = "s", correct = true, hint_level = 0 } or {}
				local ok = event.validate(valid_event({ actor = a, type = t, payload = payload })) == true
				if ok ~= (allowed[a .. "|" .. t] == true) then
					mismatches[#mismatches + 1] = a .. "|" .. t .. " -> " .. tostring(ok)
				end
			end
		end
		assert.equal(12 * 28, checked)
		assert.same({}, mismatches)
	end)

	it("never lets an LLM role emit state-bearing engine events", function()
		for _, r in ipairs(LLM_ROLES) do
			for _, t in ipairs(ENGINE) do
				local ok, err = event.validate(valid_event({ actor = "llm:" .. r, type = t }))
				assert.is_nil(ok)
				assert.matches("may not emit", err)
			end
		end
	end)

	it("rejects each missing required field", function()
		for _, field in ipairs({ "schema", "id", "type", "actor", "learner_id", "occurred_at", "payload", "provenance" }) do
			local e = valid_event(); e[field] = nil
			local ok, err = event.validate(e)
			assert.is_nil(ok, field)
			assert.matches(field, err)
		end
	end)

	it("rejects wrong schema version, non-integer time, empty id and missing policy version", function()
		local bad = {
			valid_event({ schema = "event/2" }),
			valid_event({ occurred_at = 1.5 }),
			valid_event({ occurred_at = "2026-09-28" }),
			valid_event({ id = "" }),
			valid_event({ provenance = {} }),
			valid_event({ payload = "text" }),
		}
		for i, e in ipairs(bad) do
			assert.is_nil(event.validate(e), "case " .. i)
		end
	end)

	it("rejects a caller-supplied seq, which only the log may assign", function()
		assert.is_nil(event.validate(valid_event({ seq = 7 })))
	end)
end)

describe("event.validate answer.scored payload", function()
	local function scored(payload)
		return valid_event({ actor = "engine", type = "answer.scored", payload = payload })
	end

	it("classifies a set of payloads exactly: only well-formed scores enter the log", function()
		local cases = {
			good = { { item_id = "i", skill_id = "s", correct = true, hint_level = 0 }, true },
			assisted = { { item_id = "i", skill_id = "s", correct = false, hint_level = 3 }, true },
			no_skill = { { item_id = "i", correct = true, hint_level = 0 }, false },
			empty_skill = { { item_id = "i", skill_id = "", correct = true, hint_level = 0 }, false },
			no_item = { { skill_id = "s", correct = true, hint_level = 0 }, false },
			string_correct = { { item_id = "i", skill_id = "s", correct = "yes", hint_level = 0 }, false },
			negative_hint = { { item_id = "i", skill_id = "s", correct = true, hint_level = -1 }, false },
			fractional_hint = { { item_id = "i", skill_id = "s", correct = true, hint_level = 0.5 }, false },
			empty = { {}, false },
		}
		local expected, got = {}, {}
		for name, c in pairs(cases) do
			expected[name] = c[2]
			got[name] = event.validate(scored(c[1])) == true
		end
		assert.same(expected, got)
	end)
end)
