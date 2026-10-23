local session = require("ai_edu.session")
local event_log = require("ai_edu.event_log")
local projection = require("ai_edu.learner_projection")
local canonical = require("ai_edu.canonical")

local function bank()
	return {
		{
			schema = "item/1", id = "b-sound", skill_ids = { "letters.b" },
			prompt = { text = "Which letter says /b/?" },
			response = { kind = "choice", choices = { { id = "d", label = "d" }, { id = "b", label = "b" } } },
			key = { choice = "b" }, provenance = { policy_version = "pedagogy-priors/2" },
		},
		{
			schema = "item/1", id = "legs", skill_ids = { "counting", "animals" },
			prompt = { text = "How many legs does a spider have?" },
			response = { kind = "typed" }, key = { accepted = { "8" } },
			provenance = { policy_version = "pedagogy-priors/2" },
		},
	}
end

local function init(items)
	return assert(session.init({ items = items or bank(), learner_id = "L1", session_id = "S1",
		policy_version = "pedagogy-priors/2" }))
end

-- Shell for tests: append a transition's events to a log and return the new state.
local function commit(log, st, events)
	for _, e in ipairs(events) do assert(log:append(e)) end
	return st
end

local TAP = { modality = "tap", hint_level = 0 }

describe("session (pure transitions)", function()
	it("rejects an invalid item bank", function()
		local items = bank(); items[1].key.choice = "nope"
		local st, err = session.init({ items = items, learner_id = "L1", session_id = "S1", policy_version = "p" })
		assert.is_nil(st)
		assert.matches("b%-sound", err)
	end)

	it("presents a key-free view and emits the presentation event", function()
		local st, events, view = session.present(init(), "b-sound", 1000)
		assert.is_nil(view.key)
		assert.equal(1, #events)
		local e = events[1]
		assert.same({ "activity.presented", "engine", 1000 }, { e.type, e.actor, e.occurred_at })
		assert.same({ item_id = "b-sound", session_id = "S1" }, e.payload)
		assert.truthy(event_log.new():append(e))
		assert.is_table(st)
	end)

	it("never changes the state it is given", function()
		local s0 = init()
		local before = canonical.encode(s0)
		local s1 = session.present(s0, "b-sound", 1)
		local after_present = canonical.encode(s1)
		session.submit(s1, "b-sound", { choice = "b" }, TAP, 2)
		session.report(s1, "wrong", "b-sound", "", 3)
		session.next(s1, 4)
		assert.equal(before, canonical.encode(s0))
		assert.equal(after_present, canonical.encode(s1))
	end)

	it("scores a submission, emitting learner and engine events with latency", function()
		local st = session.present(init(), "b-sound", 1000)
		local _, events, result = session.submit(st, "b-sound", { choice = "b" }, TAP, 4500)
		assert.same({ correct = true, reveal = { choice = "b" } }, result)
		assert.equal(2, #events)
		assert.same({ "answer.submitted", "learner" }, { events[1].type, events[1].actor })
		assert.same({ item_id = "b-sound", session_id = "S1", answer = { choice = "b" }, modality = "tap", latency_ms = 3500 },
			events[1].payload)
		assert.same({ "answer.scored", "engine" }, { events[2].type, events[2].actor })
		assert.same({ item_id = "b-sound", skill_id = "letters.b", correct = true, hint_level = 0 }, events[2].payload)
	end)

	it("emits one scored event per skill, which the projection replays", function()
		local log = event_log.new()
		local st = commit(log, session.present(init(), "legs", 1))
		st = commit(log, session.submit(st, "legs", { text = "eight" }, { modality = "type", hint_level = 1 }, 2))
		local p = projection.replay(log:events())
		assert.same({ attempts = 1, correct = 0 }, p.learners.L1.skills.counting.assisted)
		assert.same({ attempts = 1, correct = 0 }, p.learners.L1.skills.animals.assisted)
	end)

	it("refuses answers to items not currently presented, and a second answer to one presentation", function()
		assert.is_nil(session.submit(init(), "b-sound", { choice = "b" }, TAP, 1))
		assert.is_nil(session.present(init(), "no-such-item", 1))
		local st = session.present(init(), "b-sound", 1)
		st = session.submit(st, "b-sound", { choice = "d" }, TAP, 2)
		local again, err = session.submit(st, "b-sound", { choice = "b" }, TAP, 3)
		assert.is_nil(again)
		assert.matches("not presented", err)
	end)

	it("emits nothing for a malformed answer and keeps the presentation open", function()
		local st = session.present(init(), "b-sound", 1)
		assert.is_nil(session.submit(st, "b-sound", { text = "b" }, { modality = "type", hint_level = 0 }, 2))
		assert.truthy(session.submit(st, "b-sound", { choice = "b" }, { modality = "speak", hint_level = 0 }, 3))
	end)

	it("rejects unknown modalities and bad hint levels", function()
		local st = session.present(init(), "b-sound", 1)
		assert.is_nil(session.submit(st, "b-sound", { choice = "b" }, { modality = "telepathy", hint_level = 0 }, 2))
		assert.is_nil(session.submit(st, "b-sound", { choice = "b" }, { modality = "tap", hint_level = -1 }, 2))
	end)
end)

describe("session.next", function()
	it("presents unanswered items in bank order, re-presents an unanswered one, then reports done", function()
		local st, _, view = session.next(init(), 1)
		assert.equal("b-sound", view.id)
		st, _, view = session.next(st, 2)
		assert.equal("b-sound", view.id)
		st = session.submit(st, "b-sound", { choice = "d" }, TAP, 3)
		st, _, view = session.next(st, 4)
		assert.equal("legs", view.id)
		st = session.submit(st, "legs", { text = "8" }, { modality = "type", hint_level = 0 }, 5)
		local _, events, done_view, done = session.next(st, 6)
		assert.is_nil(done_view)
		assert.is_true(done)
		assert.same({}, events)
	end)

	it("emits lesson.completed exactly once for a lesson session", function()
		local st = assert(session.init({ items = { bank()[1] }, learner_id = "L1", session_id = "S1",
			policy_version = "p", lesson_id = "L" }))
		st = session.next(st, 1)
		st = session.submit(st, "b-sound", { choice = "b" }, TAP, 2)
		local st2, first = session.next(st, 3)
		local _, second = session.next(st2, 4)
		assert.equal("lesson.completed", first[1].type)
		assert.same({ lesson_id = "L", session_id = "S1" }, first[1].payload)
		assert.same({}, second)
	end)
end)

describe("info cards", function()
	it("are acknowledged without scoring, so they never count toward mastery", function()
		local log = event_log.new()
		local st = init({ { schema = "item/1", id = "intro", skill_ids = { "kpk.square" },
			prompt = { text = "Draw the square of the pawn." }, response = { kind = "info" }, key = {},
			provenance = { policy_version = "p" } } })
		local view
		st, _, view = session.next(st, 1)
		assert.equal("intro", view.id)
		local events, result
		st, events, result = session.submit(st, "intro", { ack = true }, TAP, 2)
		assert.same({ ack = true }, result)
		assert.same({ "student.response" }, { events[1].type })
		commit(log, st, events)
		assert.same({}, projection.replay(log:events()).learners)
		local _, _, _, done = session.next(st, 3)
		assert.is_true(done)
	end)
end)

describe("session.report", function()
	it("emits challenges and failure reports as learner events that never touch scores", function()
		local st = session.present(init(), "b-sound", 1)
		local _, wrong = session.report(st, "wrong", "b-sound", "I think b is not the answer", 2)
		local _, broken = session.report(st, "broken", "b-sound", "", 3)
		assert.same({ "challenge.raised", "activity.failure_reported" }, { wrong[1].type, broken[1].type })
		assert.is_nil(session.report(st, "bogus", "b-sound", "", 4))
		assert.truthy(session.submit(st, "b-sound", { choice = "b" }, TAP, 5))
	end)
end)

describe("session.progress", function()
	it("reports the 1-based position of the next unanswered item and the total", function()
		local st = init()
		assert.same({ position = 1, total = 2 }, session.progress(st))
		st = session.submit(session.present(st, "b-sound", 1), "b-sound", { choice = "b" }, TAP, 2)
		assert.same({ position = 2, total = 2 }, session.progress(st))
		st = session.submit(session.present(st, "legs", 3), "legs", { text = "8" }, { modality = "type", hint_level = 0 }, 4)
		assert.same({ position = 2, total = 2 }, session.progress(st))
	end)
end)

describe("session.restore", function()
	it("rebuilds answered, open and id-counter state from logged events", function()
		local log = event_log.new()
		local st = commit(log, session.next(init(), 1))
		st = commit(log, session.submit(st, "b-sound", { choice = "b" }, TAP, 2))
		st = commit(log, session.next(st, 3))
		local restored = session.restore(init(), log:events())
		assert.same(session.progress(st), session.progress(restored))
		local _, events = session.submit(restored, "legs", { text = "8" }, { modality = "type", hint_level = 0 }, 4)
		for _, e in ipairs(events) do assert(log:append(e)) end
	end)
end)

describe("session.challenge", function()
	-- Oracle stand-ins: one agrees with the stored key, one says "d" is the sound of /b/.
	local function agrees(it, answer) return { correct = answer.choice == "b", proof = "b says /b/." } end
	local function disagrees(it, answer) return { correct = answer.choice == "d", proof = "the oracle says d." } end
	local oracle = { name = "test-oracle" }

	local function answered(choice, log)
		local st, ev = session.present(init(), "b-sound", 1)
		if log then commit(log, st, ev) end
		local st2, ev2 = session.submit(st, "b-sound", { choice = choice }, TAP, 2)
		if log then commit(log, st2, ev2) end
		return st2
	end

	it("settles a challenge against the oracle; a rejected one shows proof and changes no score", function()
		local st = answered("d")
		local st2, events, out = assert(session.challenge(st, "b-sound", "d sounds right to me", agrees, oracle, 3))
		assert.same({ "challenge.raised", "challenge.settled" }, { events[1].type, events[2].type })
		assert.same({ "learner", "engine" }, { events[1].actor, events[2].actor })
		assert.same({ item_id = "b-sound", upheld = false, oracle = "test-oracle", proof = "b says /b/.", session_id = "S1" },
			events[2].payload)
		assert.same({ upheld = false, correct = false, proof = "b says /b/." }, out)
		assert.is_not.equal(st, st2)
	end)

	it("an upheld challenge corrects the named score in both directions and is then settled", function()
		local log = event_log.new()
		local st = answered("b", log)
		local st2, events, out = assert(session.challenge(st, "b-sound", "", disagrees, oracle, 3))
		commit(log, st2, events)
		assert.same({ upheld = true, correct = false, proof = "the oracle says d." }, out)
		local corr = events[3]
		assert.same({ "answer.corrected", "engine" }, { corr.type, corr.actor })
		assert.same({ item_id = "b-sound", skill_id = "letters.b", correct = false, was_correct = true, hint_level = 0,
			corrects = "S1:3" }, corr.payload)
		local p = assert(projection.replay(log:events()))
		assert.same({ attempts = 1, correct = 0 }, p.learners.L1.skills["letters.b"].independent)
		local _, again, out2 = assert(session.challenge(st2, "b-sound", "", disagrees, oracle, 4))
		assert.is_false(out2.upheld)
		assert.equal(2, #again)
	end)

	it("refuses unanswered items and items the oracle cannot judge, emitting nothing", function()
		local st = session.present(init(), "b-sound", 1)
		assert.is_nil(session.challenge(st, "b-sound", "", agrees, oracle, 2))
		local function no_oracle() return nil, "no oracle" end
		local st2, err = session.challenge(answered("d"), "b-sound", "", no_oracle, oracle, 3)
		assert.is_nil(st2)
		assert.matches("no oracle", err)
	end)

	it("survives a restart: restore recovers the answer, score ids and earlier corrections", function()
		local log = event_log.new()
		local st = answered("b", log)
		commit(log, st, select(2, session.challenge(st, "b-sound", "", disagrees, oracle, 3)))
		local restored = session.restore(init(), log:events())
		local _, events, out = assert(session.challenge(restored, "b-sound", "", disagrees, oracle, 4))
		assert.is_false(out.upheld)
		assert.equal("S1:7", events[1].id)
	end)
end)

describe("session without feedback (checkpoints)", function()
	local function checkpoint_init()
		local items = bank()
		items[1].checkpoint = 7
		return assert(session.init({ items = items, learner_id = "L1", session_id = "C1",
			policy_version = "pedagogy-priors/2", feedback = false }))
	end

	it("records and scores an answer but reveals nothing, tagging the score with its checkpoint", function()
		local st = session.present(checkpoint_init(), "b-sound", 1)
		local _, events, out = session.submit(st, "b-sound", { choice = "d" }, TAP, 2)
		assert.same({ recorded = true }, out)
		assert.same({ item_id = "b-sound", skill_id = "letters.b", correct = false, hint_level = 0, checkpoint = 7 },
			events[2].payload)
	end)

	it("refuses challenges, since nothing was revealed to challenge", function()
		local st = session.present(checkpoint_init(), "b-sound", 1)
		local st2 = session.submit(st, "b-sound", { choice = "d" }, TAP, 2)
		local function judge() return { correct = true, proof = "p" } end
		local ok, err = session.challenge(st2, "b-sound", "", judge, { name = "o" }, 3)
		assert.is_nil(ok)
		assert.matches("checkpoint", err)
	end)

	it("leaves untagged items untagged", function()
		local st = session.present(checkpoint_init(), "legs", 1)
		local _, events = session.submit(st, "legs", { text = "8" }, TAP, 2)
		assert.is_nil(events[2].payload.checkpoint)
	end)
end)

describe("session practice-only items", function()
	it("gives feedback on an ungraded item but writes no score", function()
		local items = bank()
		items[1].graded = false
		local st = assert(session.init({ items = items, learner_id = "L1", session_id = "S1", policy_version = "p" }))
		st = session.present(st, "b-sound", 1)
		local _, events, out = session.submit(st, "b-sound", { choice = "b" }, TAP, 2)
		assert.same({ "answer.submitted" }, { events[1].type })
		assert.equal(1, #events)
		assert.is_true(out.correct)
		assert.is_true(out.practice)
	end)
end)
