# Planted counterfeits and the scrutiny axis (BDFN, 2026-09-30)

- Disclosed rule: some quizzes contain planted scoring or explanation errors. The number per set varies (0, 1, occasionally 2); the planting rate is an experiment arm. Every set ends with a reveal, including "this set had none".
- Counterfeits may go either way (a correct answer marked wrong, or a wrong answer marked right) or sit in explanation text. Direction is logged; hit rates are analyzed per direction.
- Two challenge kinds: "Prove it" (asserts nothing, unlimited, never a false alarm, counts positively) and "I think you're wrong" (asserts an error; always adjudicated and logged; only the first two per set score on the axis).
- A hit is any upheld error claim, planted or genuine (+1). An unfounded "I think you're wrong" scores -0.5 on the scrutiny axis (BDFN, 2026-09-30); "Prove it" is never penalized. d' is recorded alongside the points. Misses are recorded separately.
- The axis is `scrutiny` internally and "Scrutiny / Critical Engagement" in the interface (BDFN, 2026-09-30). It is informational for humans only and never feeds mastery.
- The log always holds the truth: the true score, a counterfeit.planted event with provenance, and the planted item excluded from official score and mastery.
- Adults and older learners only; off for the child until he reads and only on skills he has mastered.
- Evidence check first: erroneous examples, feedback reliability, planted errors. Then an A/B test against no counterfeits, judged on delayed retention.

## Evidence-driven revisions pending BDFN (review: docs/evidence/ERRONEOUS_EXAMPLES_2026-09-30.md)

- Decided (BDFN, 2026-09-30): both "correct answer marked wrong" and "wrong answer marked right" from the start, each tracked and analyzed separately. Explanation-text lies stay excluded for now (continued-influence risk).
- The end-of-set reveal explains why the planted verdict was wrong (solver-backed), because corrections that supply an alternative explanation reduce continued influence. Counterfeited items get a later retrieval check to measure residual effects.
- BDFN's hypothesis to test in the data: scrutiny is trainable, so hits on "wrong marked right" should rise and residual effects shrink over weeks.
- Keep feedback reliability near 90% (0, 1, rarely 2 per ~10 items); aids below 0.70 reliability did worse than none.
- Candidate: a per-answer confidence rating before feedback (per-item cues beat general warnings; also measures calibration).
- Candidate: "Prove it" first asks why the learner doubts the answer, then shows the proof (explanations the learner is given add little on their own).
- Track trust in genuine feedback directly (challenge rate on real items, time on feedback) as a harm signal.
