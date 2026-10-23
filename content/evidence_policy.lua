-- evidence-policy/1 for pedagogy-priors/2 (docs/policy/PEDAGOGY_PRIORS.md). One entry per
-- technique a lesson may cite; tiers and DOIs come from the dated review each entry names.
-- use: default (apply unless the learner's data says otherwise), conditional (only in the stated
-- scope), experiment (an instrumented arm), never (a lesson citing it fails the build).
local R = "docs/evidence/EVIDENCE_2026-09-28.md"

local function e(id, prior, tier, use, section, claim, sources, extra)
	local out = { id = id, prior = prior, tier = tier, use = use, claim = claim,
		review = { file = R, section = section }, sources = sources }
	for k, v in pairs(extra or {}) do out[k] = v end
	return out
end

return {
	schema = "evidence-policy/1",
	policy_version = "pedagogy-priors/2",
	entries = {
		e("spacing", 1, "A", "default", "## 1. Spaced / distributed practice",
			"Spaced practice beats massed practice for durable retention; schedule shape is an experiment arm",
			{ "10.1037/0033-2909.132.3.354", "10.1007/s10648-020-09572-8", "10.1007/s10648-025-10035-1" }),
		e("retrieval_feedback", 2, "A", "default", "## 2. Retrieval practice (with / without feedback)",
			"Retrieval practice with corrective feedback helps retention of facts and concepts",
			{ "10.1037/bul0000309", "10.1037/a0037559" }),
		e("interleaving", 3, "B", "conditional", "## 3. Interleaving",
			"Interleave when discriminating confusable categories or problem types, not on first exposure",
			{ "10.1037/bul0000209" }),
		e("worked_examples", 4, "A", "default", "## 4. Worked examples and fading (expertise reversal)",
			"Worked examples help novices acquire complex procedures, with guidance faded as competence rises",
			{ "10.1007/s10648-023-09745-1" }),
		e("formative_assessment", 5, "B", "default", "## 5. Formative assessment (K-12)",
			"Formative assessment has a small positive average effect in K-12",
			{ "10.1111/j.1745-3992.2011.00220.x", "10.1080/13803611.2024.2363831" }),
		e("self_explanation", 6, "B", "conditional", "## 6. Self-explanation",
			"Self-explanation helps when context favors it; not stacked on worked examples in math by default",
			{ "10.1007/s10648-018-9434-x" }),
		e("explanation_first", 7, "B", "default", "## 7. Prediction before observation; generation; problem solving before instruction",
			"Explanation before practice; the default below about grade 6, where instruction-first won",
			{ "10.3102/00346543211019105" }),
		e("problem_first", 7, "B", "experiment", "## 7. Prediction before observation; generation; problem solving before instruction",
			"Problem solving before instruction for older learners; an instrumented arm for younger ones",
			{ "10.3102/00346543211019105", "10.3758/s13423-021-01904-1" }),
		e("mastery_gating", 8, "B", "default", "## 12. Mastery learning, intelligent tutoring, Bayesian Knowledge Tracing",
			"Mastery gating helps when mastery is measured on unaided, delayed items",
			{ "10.3102/00346543060002265" }),
		e("breaks", 9, "C", "conditional", "## 8. Active breaks and executive function in children",
			"Breaks on well-being, behavior and learner request; no universal interval",
			{ "10.1007/s00431-026-07341-3" }),
		e("simulation", 10, "B", "conditional", "## 9. Simulation-based learning",
			"Simulation-based learning is B in higher education and C for children",
			{ "10.3102/0034654320933544" }),
		e("learning_styles", 11, "D", "never", "## 10. Learning-styles matching (meshing hypothesis)",
			"Matching instruction to fixed learner styles is not supported",
			{ "10.1111/j.1539-6053.2009.01038.x", "10.3389/fpsyg.2024.1428732" }),
		e("genai_answer_giving", 12, "D", "never", "### 11a. Unguarded, answer-giving LLM access during practice",
			"Answer-giving GenAI during practice harms unaided skill",
			{ "10.1073/pnas.2422633122" }),
		e("guarded_ai_tutor", 12, "C", "experiment", "### 11b. Pedagogically constrained AI tutors or AI-assisted human tutors",
			"Guarded, answer-withholding AI tutoring; benefit claims count only on unaided, delayed outcomes",
			{ "10.1038/s41598-025-97652-6" }),
	},
}
