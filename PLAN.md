# PLAN

Architecture and contracts: docs/ARCHITECTURE.md. Evidence reviews: docs/evidence/. Experiments vs tradition and evidence: docs/policy/DIVERGENCES.md. Completed items: docs/PLAN_LOG.md.

## Now

- [ ] Unseen, no-feedback checkpoints at 1/7/30 days, separate from practice

- [x] Challenges settled by the solver, never the stored key: upheld = answer.corrected per score plus challenge.settled{upheld} for the scrutiny axis to credit; rejected = proof shown, no penalty (done 2026-10-14 14:45 EDT)

- [x] Add Mechatron Prime CI (the project's continuous-integration service) for the flake check, with README badge (done 2026-10-14 14:32 EDT)

## Next: king-and-pawn dogfood

- [ ] Counterfeits and scrutiny axis, design agreed 2026-09-30 (context: docs/plan_context/counterfeit_scrutiny.md)
- [ ] Misconception loop: deterministic signals + evaluator AI propose (misconception.proposed), engine confirms via diagnostic items or a short learner dialog, confirmed ones steer reviews
- [ ] "Try it": play your own idea against the solver on the board (no AI needed; works for the child)
- [ ] FSRS-style model plus moving-average baseline, scored by log loss on the learner's own reviews once enough data exists
- [ ] Challenges on wording or facts: verifier model proposes a ruling, BDFN confirms; no credit granted by a model alone
- [ ] "Talk it over" tutor panel grounded in solver facts: typed for BDFN first; cannot change scores
- [ ] Instructor approval workflow for oracle tier 3-4 items (docs/policy/ORACLES.md)

## Platform

- [ ] Conform to the cross-platform project build convention: ./build, ./run, PF naming, declared platform matrix (context: docs/plan_context/build_arch_conformance.md)
- [ ] Encode the evidence table as versioned policy data (evidence-policy/1) that lesson policies must cite
- [x] Hide event_log internals behind closures; entries and the id index are unreachable by field access (done 2026-10-23 14:22 EDT, b3f33b3)
- [ ] Tamper evidence for persisted logs (hash chain over canonical lines)
- [x] curriculum-node/1 graph with prerequisite validation (cycles, dangling ids) and the king-and-pawn graph (done 2026-10-23 14:24 EDT, 150b2ff)
- [x] mastery-estimate/1: versioned BKT estimator recomputed from events, independent-only by default, corrections applied (done 2026-10-23 14:26 EDT)
- [ ] Model gateway + role-call/1 envelope; role outputs become proposal events only
- [ ] Sandbox runner for generated LuaJIT activities (restricted env, instruction hooks, OS limits, no network)
- [ ] Privacy, sandbox and learner-facing failure controls before testing with other learners or generated activities
- [ ] Terminal interface as a user-selectable alternative to the web client
- [ ] Question types: spoken/text prompt with drawn, tapped, typed, rubric-judged free-text and spoken answers; accessibility via spoken input and output
- [ ] Timed items: limit, fail or hint-then-retry, late-correct as its own outcome, server-clock authoritative (context: docs/plan_context/timed_items.md)
- [ ] Game-mode lessons per docs/evidence/GAMES_AND_TYPING_2026-09-28.md: sparse visuals, adaptive pace, no competition, untimed path, learning measured outside the game
- [ ] Typing lessons: touch typing for adults now; handwriting first for the child (evidence: GAMES_AND_TYPING review)
- [ ] Image artifacts with provenance labels; AI images labeled, fact-checked and never used as evidence or grading keys (context: docs/plan_context/history_images.md)

## Child track (deferred until the child reads; no child data until BDFN decides retention and audio)

- [ ] BDFN decides child-data retention, deployment and audio policy before any collection
- [ ] Prototype reading jump-start: letters, letter sounds, short words (evidence: docs/evidence/EARLY_LITERACY_NUMERACY_2026-09-28.md)
- [ ] Finger-written letter capture on iOS web page, $P shape scoring plus formation checks, parent as canonical judge (context: docs/plan_context/handwriting_capture.md)
- [ ] Pre-rendered, approved, content-addressed spoken instructions (context: docs/plan_context/spoken_audio.md)
- [ ] Spoken tutor panel for the child, after reading and audio decisions

## Recently done

- [x] Web-first stack (thin fixed client, LuaJIT server) live on the private network for BDFN's dogfood (done 2026-09-30 12:07 EDT, reconciled 2026-10-14)
- [x] One-week king-and-pawn course: three lessons on days 0-2 with unaided checks, day-7 delayed check with a transfer item (done 2026-09-30 11:35 EDT, reconciled 2026-10-14)
- [x] Lessons drafted ahead, solver-verified, frozen and versioned in content/kpk_week.lua with deterministic scoring (done 2026-09-30 13:35 EDT, reconciled 2026-10-14)
- [x] File-backed NDJSON log adapter (src/ai_edu/log_file.lua); SQLite dropped as unneeded (done 2026-09-30, reconciled 2026-10-14)
- [x] Reading jump-start ideas proposed with evidence review (done 2026-09-28, reconciled 2026-10-14)
- [x] First cohort, subject and deployment chosen: BDFN self-dogfood, king-and-pawn endgames, private network (done 2026-09-28, reconciled 2026-10-14)
- [x] Bold refactor: session and course are pure transitions; http_app is the imperative shell (done 2026-09-30 15:51 EDT)
- [x] Published as public github.com/pmarreck/ai_edu after removing private details (done 2026-10-09 17:07 EDT)
