# Pedagogy priors

Current version: `pedagogy-priors/2`, in force from 2026-09-28. Approved by BDFN 2026-09-28.

`pedagogy-priors/1` is section 2.3 of the [founding prompt](../evidence_adaptive_ai_education_meta_prompt.md), which stays byte-for-byte unmodified as the historical source. Version 2 supersedes it. Learner events record the policy version in force (`provenance.policy_version`), so outcomes stay interpretable against the priors that produced them.

These are starting priors. This learner's measured outcomes override them where the data are sufficient, and the recurring review below revises them.

## Priors (evidence: [EVIDENCE_2026-09-28](../evidence/EVIDENCE_2026-09-28.md))

1. Spaced practice beats massed practice for durable retention (A; B in math, smaller gains there). Expanding intervals are not generally better than uniform ones, so schedule shape is an experiment arm, not a rule.
2. Retrieval practice with corrective feedback helps retention of facts and concepts (A). In math, retrieval alone is not established; pair it with spacing and worked examples. It does not displace every elaborative strategy.
3. Interleaving helps when discriminating confusable categories or problem types (B). Do not interleave word lists or first exposure to new material.
4. Worked examples help novices acquire complex procedures (A), with guidance faded as competence rises (B). Do not stack self-explanation prompts on worked examples by default in math.
5. Formative assessment has a small positive average effect in K-12, about 0.20-0.25 SD (B).
6. Self-explanation helps when context favors it (B), with the worked-example boundary above.
7. Young learners get instruction first. Below about grade 6, the default is explanation-first; prediction-first and problem-solving-first are instrumented experiment arms only (instruction-first won for grades 2-5). For older learners, problem-solving-before-instruction is B.
8. Mastery gating helps (B), with mastery measured on unaided, delayed items. The mastery estimator (BKT or other) is C until validated against delayed unaided outcomes.
9. Breaks are justified by well-being, behavior and learner request. Executive-function benefits of active breaks are C and the newest syntheses disagree; there is no universal interval.
10. Simulation-based learning is B in higher education and C for children, where it is an extrapolation needing local measurement.
11. Matching instruction to fixed learner "styles" is D. Never used.
12. GenAI that gives answers during practice is D when unaided skill is the goal. Guarded, answer-withholding tutor designs are C (positive but short RCTs). AI benefit claims count only when measured on unaided, delayed outcomes.

Most of this evidence comes from adolescents and adults. For children under about 7 a tier does not carry over automatically; age-specific evidence is tracked in separate reviews under `docs/evidence/`.

The same priors are encoded as data in `content/evidence_policy.lua` (`evidence-policy/1`). Every lesson cites the entries it uses; a lesson citing an unknown entry or one marked `never` is rejected, and a test checks every cited section and DOI against the review it names. Change both together.

## Recurring evidence review

- A full review of every prior runs every 4 to 6 months. The next one is due 2027-02-28 and must finish by 2027-03-28.
- A targeted review also runs before any pedagogy policy is materially implemented or changed (founding prompt 2.1).
- Each review lands as `docs/evidence/EVIDENCE_<date>.md` under the same method: primary sources, numbers only from sources actually read, unverified claims listed apart, DOIs confirmed.
- Changes produce a new `pedagogy-priors/<n>` with a dated changelog entry here. BDFN approves each version before it is in force. Nothing rewrites policy silently.

## Changelog

- `pedagogy-priors/2` (2026-09-28): added interleaving, mastery gating and the young-learner instruction-first default; split GenAI into answer-giving (D) and guarded tutoring (C); math caveats on retrieval and worked-example self-explanation; weakened the active-break claim; scoped simulation evidence by population.
- `pedagogy-priors/1`: founding prompt section 2.3.
