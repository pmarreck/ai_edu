# PLAN log

Completed PLAN.md items retired by plan-retire, oldest retirement first.

## Retired 2026-09-28

- [x] [Now] 2026-09-28 EDT: Preserve and verify the founding prompt without changing its source copy.
- [x] [Now] 2026-09-28 EDT: Verify the LuaJIT flake and project test gate on Linux; keep macOS evaluation available.
- [x] [Now] Specify the smallest vendor-independent architecture and versioned contract list (done 2026-09-28 14:50 EDT, eb391e4)
- [x] [Now] Switch ./test to busted; nix flake check runs it (done 2026-09-28 14:50 EDT, eb391e4)
- [x] [Now] event/1 contract with exhaustively tested actor/type matrix (LLM roles emit proposals only) (done 2026-09-28 14:51 EDT, 40a8fed)
- [x] [Now] Append-only event log with canonical NDJSON round-trip (done 2026-09-28 14:51 EDT, f5e5af0)

## Retired 2026-09-30

- [x] [Now] learner-projection/1 deterministic replay with mutation-checked metamorphic specs (done 2026-09-28 14:53 EDT, 869e5e0)
- [x] [Now] Review current learning-science evidence (docs/evidence/EVIDENCE_2026-09-28.md; 5 DOIs spot-checked via Crossref) (done 2026-09-28 14:59 EDT)
- [x] [Next] Amend the 2.3 priors as docs/policy/PEDAGOGY_PRIORS.md (pedagogy-priors/2; BDFN approved) (done 2026-09-28 17:45 EDT)
- [x] [Next] Recurring full evidence review every 4-6 months written into policy; next due 2027-02-28 (done 2026-09-28 17:45 EDT)
- [x] [Next] Early literacy, numeracy and child-ASR review (docs/evidence/EARLY_LITERACY_NUMERACY_2026-09-28.md; 8 DOIs spot-checked) (done 2026-09-28 18:02 EDT)
- [x] [Next] Browser-free simulated learner driving the real HTTP API (done 2026-09-28 18:40 EDT)
- [x] [Next › Dogfood: BDFN learns king-and-pawn endgames (opposition, sq…] Served at a private network address and notified BDFN (done 2026-09-28 18:50 EDT)
- [x] [Next] Cache the KPK solve across spec files: specs 8 s -> 3.1 s (done 2026-09-28 23:18 EDT, 86de4c7)
- [x] [Next] Client shows question n of m (done 2026-09-28 23:21 EDT, 9b6238a)
- [x] [Next] answer.scored payload contract enforced at the log boundary; BDFN's 21-event log still validates (done 2026-09-28 23:29 EDT)

## Retired 2026-10-09

- [x] [Next › Dogfood: BDFN learns king-and-pawn endgames (opposition, squ…] Client looks fine on UWQHD and iPhone per BDFN (done 2026-09-30 11:27 EDT)

## Retired 2026-10-14

- [x] [Next › Dogfood: BDFN learns king-and-pawn endgames (opposition, squ…] Day-7 check gains a starting-rank square item, solver-verified (done 2026-09-30 11:35 EDT)
- [x] [Next › Dogfood: BDFN learns king-and-pawn endgames (opposition, squ…] Move items: solver-generated refutation for each wrong move, revealed only for the move played (done 2026-09-30 12:05 EDT; deployed 12:07)
- [x] [Next › Dogfood: BDFN learns king-and-pawn endgames (opposition, squ…] Resume an in-progress lesson after a server restart; deployed (done 2026-09-30 12:07 EDT, 8f7bed1)
- [x] [Next › Dogfood: BDFN learns king-and-pawn endgames (opposition, squ…] random 0.3.0 LuaJIT DRBG pinned as a flake input; ai_edu.rng now draws from it (done 2026-09-30 15:05 EDT)
- [x] [Next › Dogfood: BDFN learns king-and-pawn endgames (opposition, squ…] Solver-generated, concept-verified fresh positions per KPK concept, kept distinct between concepts (done 2026-09-30 13:35 EDT)
- [x] [Next › Dogfood: BDFN learns king-and-pawn endgames (opposition, squ…] Evidence check on planted errors; revisions accepted with both directions from the start (done 2026-09-30 12:45 EDT)
- [x] [Recently done] Scheduler core and review sessions from due skills with logged plans (done 2026-09-30 13:45 EDT)

## Retired 2026-10-23

- [x] [Recently done] Web-first stack (thin fixed client, LuaJIT server) live on the private network for BDFN's dogfood (done 2026-09-30 12:07 EDT, reconciled 2026-10-14)
- [x] [Recently done] One-week king-and-pawn course: three lessons on days 0-2 with unaided checks, day-7 delayed check with a transfer item (done 2026-09-30 11:35 EDT, reconciled 2026-10-14)
- [x] [Recently done] Lessons drafted ahead, solver-verified, frozen and versioned in content/kpk_week.lua with deterministic scoring (done 2026-09-30 13:35 EDT, reconciled 2026-10-14)
- [x] [Recently done] File-backed NDJSON log adapter (src/ai_edu/log_file.lua); SQLite dropped as unneeded (done 2026-09-30, reconciled 2026-10-14)
- [x] [Recently done] Bold refactor: session and course are pure transitions; http_app is the imperative shell (done 2026-09-30 15:51 EDT)
- [x] [Recently done] Published as public github.com/pmarreck/ai_edu after removing private details (done 2026-10-09 17:07 EDT)
- [x] [Recently done] Reading jump-start ideas proposed with evidence review (done 2026-09-28, reconciled 2026-10-14)
- [x] [Recently done] First cohort, subject and deployment chosen: BDFN self-dogfood, king-and-pawn endgames, private network (done 2026-09-28, reconciled 2026-10-14)
- [x] [Now] Add Mechatron Prime CI (the project's continuous-integration service) for the flake check, with README badge (done 2026-10-14 14:32 EDT)
