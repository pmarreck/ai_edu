# Pedagogical oracles

An oracle is an independent source of truth that scores answers and verifies authored content, so that neither an LLM nor a hurried human author is trusted on their own (MFIC: the author of an item must not be the thing that checks it). Proposed by BDFN, 2026-09-30, generalizing the king-and-pawn solver.

## Preference order

Use the strongest available tier. An item records its oracle and tier in `provenance`.

1. **Existing trusted tool or data set.** A library, binary or curated data set with its own track record, used as-is or as a differential reference. Examples: a chess endgame tablebase; a computer algebra system for symbolic math; a compiler plus a test suite for programming; the CMU Pronouncing Dictionary for phonics keys; a physics engine; curated geographic data.
2. **Known algorithm implemented here.** A published algorithm we implement (the KPK retrograde solver, exact arithmetic, a unit converter), verified against tier 1 where a reference exists (differential tests) and otherwise by exhaustive, metamorphic or property tests.
3. **AI-constructed simulation or checker.** Built on the fly for an instructive purpose from known principles and any tier 1 or 2 pieces. Untrusted until it passes its own tests (founding prompt section 12), and it needs instructor approval before any item it scores is administered as a graded question.
4. **No mechanical oracle.** Sourced facts, rubric judgments of free text, contested interpretations. An LLM may propose a score against an explicit rubric; a second pass or a human confirms consequential judgments. Such items may be practiced but do not gate mastery until a human has reviewed them.

## Consequences

- **Instructor approval workflow.** Items at tier 3 or 4, and any tier 3 simulation, enter a review queue and are administered as graded items only after approval. Approval is an event with the approver and date. Tier 1 and 2 items are approved by their oracle. Implemented in `src/ai_edu/approvals.lua`: a parent `item.approved` or `item.rejected` event names the BLAKE3 hash of the item's exact canonical content, so an edited item needs a new decision; until approved an item is practice-only (feedback, no score), and a rejected one is never shown. The review-queue entry point is still open in PLAN.md.
- **Claims are checked, not trusted.** Authored text states its claims in machine-checkable form where possible (the `claim` fields in `content/kpk_week.lua`), and the build fails on disagreement.
- **Challenges are settled by the oracle.** A learner's "I think you're wrong" is adjudicated against the oracle, not against the stored key, so a wrong key is exposed rather than defended.
- **Oracles carry versions.** A changed oracle version can re-verify old items and re-score logged answers.
