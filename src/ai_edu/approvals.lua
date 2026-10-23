-- Instructor approval for items whose answer key has no mechanical oracle (docs/policy/ORACLES.md
-- tiers 3 and 4). A human decision is a parent event naming the BLAKE3 hash of the item's exact
-- canonical content, so any later edit needs a fresh approval. Pure functions over items and events.
local canonical = require("ai_edu.canonical")
local blake3 = require("blake3").blake3

local approvals = {}

local FIRST_GATED_TIER = 3

function approvals.item_hash(it) return blake3(canonical.encode(it)) end

function approvals.required(it)
	return (it.provenance and it.provenance.oracle_tier or 1) >= FIRST_GATED_TIER
end

-- Latest decision per item hash: "approved" or "rejected".
local function decisions(events)
	local out = {}
	for _, e in ipairs(events) do
		if e.type == "item.approved" then out[e.payload.item_hash] = "approved"
		elseif e.type == "item.rejected" then out[e.payload.item_hash] = "rejected" end
	end
	return out
end

local function copy(t)
	local c = {}
	for k, v in pairs(t) do c[k] = v end
	return c
end

-- Items as they may be administered: approved or ungated items unchanged, undecided ones as
-- practice-only copies (graded = false), rejected ones left out. Inputs are never mutated.
function approvals.gate(items, events)
	local d, out = decisions(events), {}
	for _, it in ipairs(items) do
		if not approvals.required(it) then
			out[#out + 1] = it
		else
			local state = d[approvals.item_hash(it)]
			if state == "approved" then out[#out + 1] = it
			elseif state ~= "rejected" then
				local practice = copy(it)
				practice.graded = false
				out[#out + 1] = practice
			end
		end
	end
	return out
end

-- Gated items with no decision on their current content, for a review queue.
function approvals.pending(items, events)
	local d, out = decisions(events), {}
	for _, it in ipairs(items) do
		if approvals.required(it) then
			local h = approvals.item_hash(it)
			if not d[h] then out[#out + 1] = { item_id = it.id, item_hash = h } end
		end
	end
	return out
end

return approvals
