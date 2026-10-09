# Divergences: where this design is an experiment

Every place where ai_edu departs from traditional pedagogy or from what the reviewed evidence favors, with the reason and how we will find out whether it helps. A divergence is not a flaw; it is an open experiment. Each one names its measurement so the data can promote it, revise it or retire it. Tiers refer to the reviews in `docs/evidence/`.

Columns per entry: **Ours** (what we do), **Tradition** (common practice), **Evidence** (what the reviews say, with tier), **Why** (our justification), **Measure** (how we will know), **Status**.

## Departs from the evidence

### Hidden counterfeits in grading
- Ours: some sets contain planted scoring errors at a variable rate, disclosed as a rule and revealed at the end of each set.
- Tradition: feedback is always meant to be correct.
- Evidence: erroneous-example studies flag the errors (g = .136, B); none hides errors in the grader. False feedback lowered later correct recall by 40% in one experiment and reduces trust in the source afterwards (B). ERRONEOUS_EXAMPLES_2026-09-30.
- Why: learners must check authorities, including AI; planted errors train and measure that under controlled, disclosed conditions ("run toward the problem").
- Measure: scrutiny hits, false alarms and d'; delayed retention of counterfeited items against untouched ones; challenge rate on genuine items as a trust signal; A/B against sets with no counterfeits.
- Status: approved by BDFN 2026-09-30; not built.

### "Wrong answer marked right" from the start
- Ours: counterfeits may confirm a wrong answer, tracked separately from "correct marked wrong".
- Tradition: never.
- Evidence: uptake of false information is highest right after the learner's own error (B).
- Why: doubting your own confirmed answer is the harder and more valuable habit; stakes are low for an adult dogfood learner.
- Measure: hit rate and later retrieval for this direction, analyzed on its own.
- Status: approved by BDFN 2026-09-30; not built.

### Variable-rate counterfeit schedule
- Ours: 0, 1 or occasionally 2 planted errors per set; the rate is an experiment arm.
- Tradition: not applicable.
- Evidence: variable-ratio reinforcement has no learning-outcome evidence; mostly animal and lab operant work (D).
- Why: a fixed count of one would let learners stop checking after finding it.
- Measure: hit rate by item position within a set; trust signal; retention.
- Status: approved; not built.

### Expanding starting ladder before per-learner fitting
- Ours: review gaps of about 1, 3, 7, 16 and 35 days until the scheduler is fitted to the learner.
- Tradition: fixed review days or none.
- Evidence: expanding and uniform schedules give similar delayed retention (B); this exact ladder is a derived guess, not tested. SPACED_REVIEW_2026-09-30.
- Why: a reasonable default that errs toward waiting, which costs less than reviewing too early.
- Measure: fitted model prediction error; delayed checkpoint accuracy.
- Status: approved 2026-09-30; not built.

## Departs from tradition (evidence-aligned or untested)

### Scoring challenges on a separate scrutiny axis, with a false-alarm penalty
- Ours: an upheld "I think you're wrong" scores +1 (planted or genuine error), an unfounded one -0.5, only the first two per set count; "Prove it" is free; d' is recorded alongside. Never part of mastery.
- Tradition: no credit for challenging the grader.
- Evidence: inoculation games increased "fake" responses without better discrimination (C), so volume of accusations must not look like skill. With a planted rate p, a random accusation is worth p - 0.5(1 - p), negative below p = 1/3.
- Why: reward telling real from planted, not suspicion.
- Measure: d' over time; accusation rate; genuine-error hits.
- Status: approved by BDFN 2026-09-30; not built.

### Lessons unlocked by calendar day
- Ours: the next lesson opens on the next calendar day.
- Tradition: self-paced, or set by a class timetable.
- Evidence: spacing beats massing for retention (A).
- Why: enforce the spacing the evidence supports.
- Measure: day-7 and later checkpoint accuracy.
- Status: live.

### Any winning move is correct
- Ours: move items accept every move the solver says keeps the win, not one book move.
- Tradition: one keyed answer from the author.
- Evidence: not reviewed; follows from the solver being the authority.
- Why: a correct but unexpected move is still correct; marking it wrong would teach a falsehood.
- Measure: none needed beyond solver agreement.
- Status: live.

### AI-authored content with a machine oracle
- Ours: an LLM writes positions and text; the solver derives every answer key and rejects contradicted claims.
- Tradition: human experts author and key items.
- Evidence: not reviewed.
- Why: independent, mechanical verification (MFIC) is stronger than trusting any single author, human or AI.
- Measure: challenge outcomes on content; errors found by learners in explanation text.
- Status: live for king-and-pawn content.
