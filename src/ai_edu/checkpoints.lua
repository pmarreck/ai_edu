-- Delayed retention checkpoints (docs/plan_context/checkpoints.md): which skills owe an unaided,
-- no-feedback check today, folded from the log. A pure function of events and `now`.
local checkpoints = {}

checkpoints.OFFSETS = { 1, 7, 30 }

-- Due checkpoints as { {skill, offset} } sorted by skill. Each skill is anchored on its first
-- unaided practice attempt; only the largest due offset not yet taken is offered, so missed
-- smaller ones are skipped rather than taken late.
function checkpoints.due(events, learner_id, now, day_index)
	local anchor, taken = {}, {}
	for _, e in ipairs(events) do
		local p = e.payload
		if e.type == "answer.scored" and e.learner_id == learner_id then
			if p.checkpoint then
				taken[p.skill_id] = math.max(taken[p.skill_id] or 0, p.checkpoint)
			elseif p.hint_level == 0 and not anchor[p.skill_id] then
				anchor[p.skill_id] = day_index(e.occurred_at)
			end
		end
	end
	local today, out = day_index(now), {}
	for skill, day0 in pairs(anchor) do
		local best
		for _, k in ipairs(checkpoints.OFFSETS) do
			if today >= day0 + k and k > (taken[skill] or 0) then best = k end
		end
		if best then out[#out + 1] = { skill = skill, offset = best } end
	end
	table.sort(out, function(a, b) return a.skill < b.skill end)
	return out
end

return checkpoints
