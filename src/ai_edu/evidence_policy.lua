-- evidence-policy/1: the pedagogy priors as data. Every lesson cites the techniques it uses by
-- entry id, and a lesson citing an unknown or forbidden technique is rejected, so a policy change
-- reaches lessons mechanically instead of by rereading prose.
local evidence_policy = {}

evidence_policy.SCHEMA = "evidence-policy/1"

local TIERS = { A = true, B = true, C = true, D = true }
local USES = { default = true, conditional = true, experiment = true, never = true }

local function nonempty_string(s) return type(s) == "string" and s ~= "" end

local function entry_error(en)
	if not nonempty_string(en.id) then return "id required" end
	if type(en.prior) ~= "number" then return "prior number required" end
	if not TIERS[en.tier] then return "tier must be A, B, C or D" end
	if not USES[en.use] then return "use must be default, conditional, experiment or never" end
	-- tier D may be used only as a recorded divergence experiment, or never
	if en.tier == "D" and en.use ~= "never" and not (en.use == "experiment" and nonempty_string(en.divergence)) then
		return "tier D needs use = never, or an experiment with a DIVERGENCES entry"
	end
	if not nonempty_string(en.claim) then return "claim required" end
	if type(en.review) ~= "table" or not nonempty_string(en.review.file) or not nonempty_string(en.review.section) then
		return "review = { file, section } required"
	end
	if type(en.sources) ~= "table" or #en.sources == 0 then return "at least one source DOI required" end
	for _, doi in ipairs(en.sources) do
		if type(doi) ~= "string" or not doi:match("^10%.%d%d%d%d+/%S+$") then return "bad DOI " .. tostring(doi) end
	end
end

-- Returns true, or nil plus the first problem found.
function evidence_policy.validate(policy)
	if type(policy) ~= "table" or policy.schema ~= evidence_policy.SCHEMA then
		return nil, "schema must be " .. evidence_policy.SCHEMA
	end
	if not nonempty_string(policy.policy_version) then return nil, "policy_version required" end
	if type(policy.entries) ~= "table" then return nil, "entries required" end
	local seen = {}
	for i, en in ipairs(policy.entries) do
		local err = entry_error(en)
		if err then return nil, "entry " .. tostring(en.id or i) .. ": " .. err end
		if seen[en.id] then return nil, "duplicate entry " .. en.id end
		seen[en.id] = true
	end
	return true
end

-- Every lesson must cite at least one technique, each a known entry not marked never.
-- Returns true, or nil plus a reason naming the lesson.
function evidence_policy.check_lessons(policy, lessons)
	local by_id = {}
	for _, en in ipairs(policy.entries) do by_id[en.id] = en end
	for _, l in ipairs(lessons) do
		if type(l.techniques) ~= "table" or #l.techniques == 0 then return nil, "lesson " .. l.id .. " cites no evidence" end
		for _, t in ipairs(l.techniques) do
			local en = by_id[t]
			if not en then return nil, "lesson " .. l.id .. " cites unknown technique " .. tostring(t) end
			if en.use == "never" then return nil, "lesson " .. l.id .. " uses " .. t .. ", which the policy forbids" end
		end
	end
	return true
end

return evidence_policy
