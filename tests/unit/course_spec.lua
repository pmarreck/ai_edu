local course = require("ai_edu.course")
local session = require("ai_edu.session")
local event_log = require("ai_edu.event_log")

local DAY = 1000
local function card(id) return { schema = "item/1", id = id, skill_ids = { "s" }, prompt = { text = id },
	response = { kind = "info" }, key = {}, provenance = { policy_version = "p" } } end

local LESSONS = {
	{ id = "L1", title = "Square", day = 0, items = { card("a"), card("b") } },
	{ id = "L2", title = "Opposition", day = 1, items = { card("c") } },
	{ id = "CHECK", title = "Day 7 check", day = 7, items = { card("d") } },
}

local function define(reviews)
	return course.define({ lessons = LESSONS, learner_id = "learner", policy_version = "p",
		day_index = function(ms) return math.floor(ms / DAY) end, reviews = reviews })
end

local function status_map(def, log, now)
	local out = {}
	for _, l in ipairs(course.status(def, log:events(), now)) do
		out[l.id] = (l.unlocked and "open" or "locked") .. (l.completed and "+done" or "")
	end
	return out
end

-- Start a lesson and run it to completion, appending every event to the log.
local function start(def, log, now, lesson_id)
	local st, events = course.start(def, log:events(), now, lesson_id)
	if not st then return nil, events end
	for _, e in ipairs(events) do assert(log:append(e)) end
	return st
end

local function run(log, st, now)
	while true do
		local nxt, events, view, done = session.next(st, now)
		for _, e in ipairs(events) do assert(log:append(e)) end
		st = nxt
		if done then return st end
		st, events = session.submit(st, view.id, { ack = true }, { modality = "tap", hint_level = 0 }, now)
		for _, e in ipairs(events) do assert(log:append(e)) end
	end
end

describe("course (pure)", function()
	it("unlocks only day-0 lessons before the course starts", function()
		assert.same({ L1 = "open", L2 = "locked", CHECK = "locked" }, status_map(define(), event_log.new(), 500))
	end)

	it("refuses to start a locked or unknown lesson and emits nothing", function()
		local st, err = course.start(define(), {}, 500, "L2")
		assert.is_nil(st)
		assert.matches("locked", err)
		assert.is_nil(course.start(define(), {}, 500, "nope"))
	end)

	it("unlocks later lessons by calendar day from the first session, and records completion", function()
		local log = event_log.new()
		run(log, assert(start(define(), log, 2500, "L1")), 2500)
		assert.same({ L1 = "open+done", L2 = "locked", CHECK = "locked" }, status_map(define(), log, 2500))
		assert.same({ L1 = "open+done", L2 = "open", CHECK = "locked" }, status_map(define(), log, 3000))
		assert.same("open", status_map(define(), log, 9000).CHECK)
	end)

	it("numbers sessions per lesson from the log", function()
		local log = event_log.new()
		run(log, assert(start(define(), log, 2500, "L1")), 2500)
		local st2 = assert(start(define(), log, 3100, "L1"))
		assert.equal("L1#2", st2.session_id)
		local ids = {}
		for _, e in ipairs(log:events()) do if e.type == "session.started" then ids[#ids + 1] = e.payload.session_id end end
		assert.same({ "L1#1", "L1#2" }, ids)
	end)
end)

describe("course.resume", function()
	it("rebuilds an unfinished session from the log", function()
		local log = event_log.new()
		local st = assert(start(define(), log, 100, "L1"))
		local nxt, events, view = session.next(st, 100)
		for _, e in ipairs(events) do log:append(e) end
		assert.equal("a", view.id)
		nxt, events = session.submit(nxt, "a", { ack = true }, { modality = "tap", hint_level = 0 }, 100)
		for _, e in ipairs(events) do log:append(e) end
		local resumed = assert(course.resume(define(), log:events()))
		local _, _, v = session.next(resumed, 100)
		assert.equal("b", v.id)
		run(log, resumed, 100)
		local completed = 0
		for _, e in ipairs(log:events()) do if e.type == "lesson.completed" then completed = completed + 1 end end
		assert.equal(1, completed)
	end)

	it("has nothing to resume before any lesson or after the last one finished", function()
		local log = event_log.new()
		assert.is_nil(course.resume(define(), log:events()))
		run(log, assert(start(define(), log, 100, "L1")), 100)
		assert.is_nil(course.resume(define(), log:events()))
	end)
end)

describe("course reviews", function()
	local provider = {
		due = function(_, events)
			for _, e in ipairs(events) do if e.type == "lesson.completed" then return { "s" } end end
			return {}
		end,
		plan = function(_, _, _, due) return { skills = due, count = 1 } end,
		lesson = function(_, plan) return { id = "review", title = "Review", items = { card("r-" .. plan.skills[1]) } } end,
	}
	local function review_row(def, log, now)
		for _, l in ipairs(course.status(def, log:events(), now)) do if l.id == "review" then return l end end
	end

	it("offers a review only when skills are due", function()
		local log = event_log.new()
		assert.is_false(review_row(define(provider), log, 100).unlocked)
		run(log, assert(start(define(provider), log, 100, "L1")), 100)
		local row = review_row(define(provider), log, 100)
		assert.is_true(row.unlocked)
		assert.equal(1, row.due)
	end)

	it("logs the review plan at start and rebuilds the same review on resume", function()
		local log = event_log.new()
		run(log, assert(start(define(provider), log, 100, "L1")), 100)
		local st = assert(start(define(provider), log, 100, "review"))
		local _, _, view = session.next(st, 100)
		assert.equal("r-s", view.id)
		local started
		for _, e in ipairs(log:events()) do if e.type == "session.started" then started = e end end
		assert.same({ skills = { "s" }, count = 1 }, started.payload.plan)
		local resumed = assert(course.resume(define(provider), log:events()))
		local _, _, again = session.next(resumed, 100)
		assert.equal("r-s", again.id)
	end)

	it("refuses a review when nothing is due", function()
		local st, err = course.start(define(provider), {}, 100, "review")
		assert.is_nil(st)
		assert.matches("nothing due", err)
	end)
end)

describe("course checkpoints", function()
	local provider = {
		due = function(_, events)
			for _, e in ipairs(events) do if e.type == "lesson.completed" then return { { skill = "s", offset = 1 } } end end
			return {}
		end,
		plan = function(_, _, _, due) return { due = due } end,
		lesson = function(_, plan)
			local it = card("cp-" .. plan.due[1].skill)
			it.checkpoint = plan.due[1].offset
			return { id = "checkpoint", title = "Checkpoint", feedback = false, items = { it } }
		end,
	}
	local function def() return course.define({ lessons = LESSONS, learner_id = "learner", policy_version = "p",
		day_index = function(ms) return math.floor(ms / DAY) end, checkpoints = provider }) end
	local function row(d, log, now)
		for _, l in ipairs(course.status(d, log:events(), now)) do if l.id == "checkpoint" then return l end end
	end

	it("offers a checkpoint row only when one is due, and starts it without feedback", function()
		local log = event_log.new()
		assert.is_false(row(def(), log, 100).unlocked)
		run(log, assert(start(def(), log, 100, "L1")), 100)
		assert.same({ id = "checkpoint", title = "Checkpoint", day = 0, unlocked = true, completed = false, due = 1 }, row(def(), log, 100))
		local st = assert(start(def(), log, 100, "checkpoint"))
		assert.is_false(st.feedback)
		local resumed = assert(course.resume(def(), log:events()))
		assert.is_false(resumed.feedback)
		local _, _, view = session.next(resumed, 100)
		assert.equal("cp-s", view.id)
	end)

	it("refuses a checkpoint when none is due", function()
		local st, err = course.start(def(), {}, 100, "checkpoint")
		assert.is_nil(st)
		assert.matches("nothing due", err)
	end)
end)

describe("course approval gate", function()
	local approvals = require("ai_edu.approvals")
	local function tier3(id)
		local it = card(id); it.provenance = { policy_version = "p", oracle_tier = 3 }; return it
	end
	local lessons = { { id = "H", title = "History", day = 0, items = { tier3("h1"), card("h2") } } }
	local function def() return course.define({ lessons = lessons, learner_id = "learner", policy_version = "p",
		day_index = function(ms) return math.floor(ms / DAY) end, gate = approvals.gate }) end

	it("starts unapproved tier-3 items as practice-only and graded once approved", function()
		local st = assert(course.start(def(), {}, 100, "H"))
		assert.is_false(st.items.h1.graded)
		assert.is_nil(st.items.h2.graded)
		local approved = { { type = "item.approved", learner_id = "learner",
			payload = { item_id = "h1", item_hash = approvals.item_hash(lessons[1].items[1]), approver = "BDFN" } } }
		local st2 = assert(course.start(def(), approved, 100, "H"))
		assert.is_nil(st2.items.h1.graded)
		local log = event_log.new()
		local st3, events = course.start(def(), {}, 100, "H")
		for _, e in ipairs(events) do log:append(e) end
		assert.is_false(assert(course.resume(def(), log:events())).items.h1.graded)
	end)
end)
