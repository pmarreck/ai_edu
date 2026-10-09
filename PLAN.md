# PLAN

Architecture and contracts: docs/ARCHITECTURE.md. Evidence reviews: docs/evidence/. Experiments vs tradition and evidence: docs/policy/DIVERGENCES.md.

## Now


## Next

- [x] Published as public github.com/pmarreck/ai_edu after removing private details; full local history kept in backup branches (done 2026-10-09 17:07 EDT)
- [ ] Add Mechatron Prime CI (the project's continuous-integration service) for the flake check
- [ ] Dogfood: BDFN learns king-and-pawn endgames (opposition, square of the pawn, key squares), served on the tailnet
	- [x] Day-7 check gains a starting-rank square item, solver-verified (done 2026-09-30 11:35 EDT)
	- [x] Move items: solver-generated refutation for each wrong move, revealed only for the move played (done 2026-09-30 12:05 EDT; deployed 12:07)
	- [x] Resume an in-progress lesson after a server restart; deployed (done 2026-09-30 12:07 EDT, 8f7bed1)
	- [ ] Challenges: solver-settled; upheld = answer.corrected + "caught an error" skill credit, rejected = proof shown, never a penalty (BDFN 2026-09-30)
	- [ ] Challenges on wording or facts: verifier model proposes a ruling, BDFN confirms; no credit granted by a model alone
	- [ ] Counterfeits and scrutiny axis, design agreed 2026-09-30 (context: docs/plan_context/counterfeit_scrutiny.md)
	- [x] Scheduler core: pure log fold, relearning criterion 2 then 1, ladder@1 model behind a swappable interface, due list (done 2026-09-30 13:37 EDT)
	- [x] Review sessions from due skills: fresh never-seen positions, interleaved, plan logged for identical resume (done 2026-09-30 13:45 EDT)
	- [ ] Unseen, no-feedback checkpoints at 1/7/30 days, separate from practice
	- [ ] FSRS-style model plus moving-average baseline, scored by log loss on the learner's own reviews once enough data exists
	- [x] Bold refactor: session and course are pure transitions; http_app is the imperative shell (done 2026-09-30 15:51 EDT)
	- [ ] Instructor approval workflow for oracle tier 3-4 items (docs/policy/ORACLES.md)
	- [x] random 0.3.0 LuaJIT DRBG pinned as a flake input; ai_edu.rng now draws from it (done 2026-09-30 15:05 EDT)
	- [x] Solver-generated, concept-verified fresh positions per KPK concept, kept distinct between concepts (done 2026-09-30 13:35 EDT)
	- [ ] Misconception loop: deterministic signals + evaluator AI propose (misconception.proposed), engine confirms via diagnostic items or a short learner dialog, confirmed ones steer lessons and reviews (BDFN: general principle)
	- [ ] "Try it": play your own idea against the solver on the board (no AI needed; works for the child)
	- [ ] "Talk it over" tutor panel grounded in solver facts: typed for BDFN first, voice for the child after reading and audio/retention decisions; cannot change scores
	- [x] Evidence check on planted errors; revisions accepted with both directions from the start (done 2026-09-30 12:45 EDT)
	- [ ] Web-first (BDFN, 2026-09-28 18:16 EDT; supersedes terminal-first): thin fixed client, LuaJIT server, proves the whole stack
	- [ ] LLM drafts lessons and items ahead; verified, frozen, versioned; deterministic scoring, rubric-only LLM judging of free text
	- [ ] About a week: 3 short lessons days 0-2, unaided check after each, delayed retrieval around day 7, one transfer item
- [ ] Encode the evidence table as versioned policy data (evidence-policy/1) that lesson policies must cite
- [ ] Propose (then prototype) reading jump-start ideas for a young pre-reader

- [ ] Terminal interface as a user-selectable alternative to the web client
- [ ] Question types: spoken/text prompt with drawn, tapped, typed, AI-judged free-text and spoken answers; accessibility via spoken input and output
- [ ] Timed items: limit, fail or hint-then-retry, late-correct as its own outcome, server-clock authoritative (context: docs/plan_context/timed_items.md)
- [ ] Game-mode lessons per docs/evidence/GAMES_AND_TYPING_2026-09-28.md: sparse visuals, adaptive pace, no competition, untimed path, learning measured outside the game
- [ ] Typing lessons: touch typing for adults now; handwriting first for the child, revisit typing near age 7 (evidence: GAMES_AND_TYPING review)
- [ ] Child track: finger-written letter capture on iOS web page, $P shape scoring plus formation checks, parent as canonical judge (context: docs/plan_context/handwriting_capture.md)
- [ ] Child track: pre-rendered, approved, content-addressed spoken instructions (context: docs/plan_context/spoken_audio.md)
- [ ] Image artifacts with provenance labels; AI images labeled, fact-checked and never used as evidence or grading keys (context: docs/plan_context/history_images.md)
- [ ] Hide event_log internals behind closures; `_entries` is still reachable by direct field access
- [ ] Tamper evidence for persisted logs (hash chain over canonical lines)
- [ ] File/SQLite storage adapter for the canonical NDJSON log
- [ ] curriculum-node/1 graph with prerequisite validation (cycles, dangling ids)
- [ ] mastery-estimate/1: versioned BKT estimator recomputed from events, independent-only by default
- [ ] Model gateway + role-call/1 envelope; role outputs become proposal events only
- [ ] Sandbox runner for generated LuaJIT activities (restricted env, instruction hooks, OS limits, no network)
- [ ] Establish privacy, sandbox, and learner-facing failure controls before testing with real learners or generated activities.
- [ ] Ask BDFN to choose the first learner cohort, subject, deployment, and retention defaults before collecting learner data.
