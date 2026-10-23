local approvals = require("ai_edu.approvals")
local canonical = require("ai_edu.canonical")

local function it_(id, tier)
	return { schema = "item/1", id = id, skill_ids = { "s" }, prompt = { text = id },
		response = { kind = "choice", choices = { { id = "a", label = "a" }, { id = "b", label = "b" } } },
		key = { choice = "a" }, provenance = { policy_version = "p", oracle_tier = tier } }
end

local function decision(type_, item, hash)
	return { type = type_, actor = "parent", learner_id = "L",
		payload = { item_id = item.id, item_hash = hash or approvals.item_hash(item), approver = "BDFN" } }
end

describe("approvals", function()
	it("hashes the item's full canonical content with BLAKE3", function()
		local x = it_("x", 3)
		assert.equal(require("blake3").blake3(canonical.encode(x)), approvals.item_hash(x))
		local y = it_("x", 3); y.key = { choice = "b" }
		assert.is_not.equal(approvals.item_hash(x), approvals.item_hash(y))
	end)

	it("needs approval only at oracle tier 3 or 4", function()
		assert.same({ false, false, false, true, true },
			{ approvals.required(it_("a")), approvals.required(it_("a", 1)), approvals.required(it_("a", 2)),
			  approvals.required(it_("a", 3)), approvals.required(it_("a", 4)) })
	end)

	it("grades approved items, keeps unapproved ones practice-only, and drops rejected ones", function()
		local items = { it_("t1", 1), it_("ok", 3), it_("pending", 4), it_("no", 3), it_("stale", 3) }
		local old_stale = it_("stale", 3); old_stale.prompt = { text = "older wording" }
		local events = {
			decision("item.approved", items[2]),
			decision("item.rejected", items[4]),
			decision("item.approved", items[5], approvals.item_hash(old_stale)),
		}
		local gated = approvals.gate(items, events)
		local got = {}
		for _, x in ipairs(gated) do got[x.id] = x.graded == false and "practice" or "graded" end
		assert.same({ t1 = "graded", ok = "graded", pending = "practice", stale = "practice" }, got)
		assert.is_nil(items[3].graded)
	end)

	it("lets the latest decision on the same content win", function()
		local x = it_("x", 3)
		local events = { decision("item.rejected", x), decision("item.approved", x) }
		assert.equal(1, #approvals.gate({ x }, events))
		events[3] = decision("item.rejected", x)
		assert.equal(0, #approvals.gate({ x }, events))
	end)

	it("lists what is waiting for review", function()
		local items = { it_("t1", 1), it_("ok", 3), it_("pending", 4) }
		assert.same({ { item_id = "pending", item_hash = approvals.item_hash(items[3]) } },
			approvals.pending(items, { decision("item.approved", items[2]) }))
	end)
end)
