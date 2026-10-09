# Architecture (v0, 2026-09-28)

Scope: the smallest architecture that satisfies section 27 of the [founding prompt](evidence_adaptive_ai_education_meta_prompt.md). Only the event log and replay are implemented; every other box is a contract sketch so later slices have a fixed target.

## Environment and constraints (measured on the x86_64-linux development machine, 2026-09-28)

- Runtime: LuaJIT 2.1.1785763465 via `luajit.withPackages` (busted, cjson, luafilesystem, sqlite). FFI available. Outputs evaluate for aarch64-linux and aarch64-darwin but have only been built on x86_64-linux.
- Browser: LuaJIT cannot run in a browser. The client stays thin HTML/CSS plus a small, fixed, hand-audited component set rendered from declarative schemas. Lesson-specific JavaScript is never generated. Candidate options (Fengari, a Lua-in-WASM build, server-rendered HTML with htmx-style partials) are undecided and blocked on the UI/deployment choice BDFN owns.
- Sandbox for generated LuaJIT activities: this host has `systemd-run` (cgroup CPU/memory/tasks limits), `prlimit`, and `unshare` (network namespace). It lacks `bwrap`, `nsjail`, `firejail` and landlock tooling. macOS has none of these; `sandbox-exec` is deprecated. Plan: run untrusted Lua in a separate LuaJIT process with a stripped environment (no `ffi`, `io`, `os`, `debug`, `require`, `load` of bytecode), instruction-count hooks for CPU, a memory ceiling from the OS, and no network namespace on Linux. Nothing generated reaches a learner until that runner exists and is tested (prompt section 12).
- No real learner data exists or may be collected until BDFN decides cohort, subject, deployment and retention.

## Components

```text
thin client ──► learning server (LuaJIT)
                 ├─ event log            (implemented: append-only, validated)
                 ├─ projections          (implemented: learner-projection/1 via replay)
                 ├─ curriculum graph     (contract only)
                 ├─ mastery estimator    (contract only; BKT candidate)
                 ├─ scheduler            (contract only)
                 ├─ lesson state machine (contract only)
                 ├─ artifact library + sandbox runner (contract only)
                 └─ model gateway ──► planner / tutor / evaluator / verifier / research roles
```

Hexagonal split, functional core and imperative shell: the core is pure Lua over tables (no I/O, no clock reads, timestamps injected, inputs never mutated). `session` and `course` are pure transitions that return a new state plus the events to append; `http_app` is the shell that reads the clock, appends those events to the log and keeps the current state. Storage, HTTP, model vendors and the sandbox are adapters.

## Canonical-state rule, as code

Every event carries an `actor`: `learner`, `engine`, `parent`, or `llm:<role>`. An LLM actor may only emit proposal-class events (`lesson.planned`, `tutor.response`, `misconception.proposed`, `observation.proposed`). State-bearing events (`answer.scored`, `observation.accepted`, `misconception.confirmed`, ...) are engine-only. `event.validate` rejects violations before they reach the log, so an LLM cannot write canonical learner state even through a buggy caller. The allowed actor/type matrix is tested exhaustively.

## Versioned contracts

Each record carries a `schema` string. A version bump is required for any field meaning change; old versions stay readable.

- `event/1` (implemented, `src/ai_edu/event.lua`): `schema`, `id` (caller-unique string), `type`, `actor`, `learner_id`, `occurred_at` (integer ms since epoch, injected), `payload` (table), `provenance` (`policy_version` required; `model`, `prompt_version`, `artifact_version` optional). The log assigns `seq`.
- `learner-projection/1` (implemented, `src/ai_edu/learner_projection.lua`): per learner, per skill: independent and assisted attempt/correct counts, `last_independent_success_at`, `last_seq`. Deliberately no mastery probability yet; that belongs to a versioned estimator.
- `curriculum-node/1` (sketch): `id`, `title`, `prerequisites` (ids), `related` (ids), `objective`, `age_range`, `sources` (provenance).
- `mastery-estimate/1` (sketch): `skill_id`, `estimator` (`name@version` + params), `p_mastery`, `interval` (uncertainty), `evidence_count`, `independent_only` (bool), computed from events, never stored as truth.
- `lesson-plan/1` (sketch): lesson graph of typed nodes and edges (section 9.1), `objective`, `evidence_sought`, `expected_misconceptions`, `techniques`, `modality`, `estimated_minutes`, `fallbacks`, `transfer_check`, `break_policy`, `needs_code`, `experiment_arm`.
- `artifact/1` (sketch): content hash, metadata of section 13, `test_suite` hash, `sandbox_limits`, `validation` record, `generator` provenance, fallback ladder.
- `role-call/1` (sketch): model gateway request/response envelope: `role`, `input_schema`, `output_schema`, `model`, `prompt_version`, raw output, parsed output, parse errors. Role outputs become proposal events only.

## First slice acceptance (this commit series)

1. Events are validated against `event/1`, including the actor/type matrix.
2. The log is append-only: no mutation API, returned events are copies, duplicate ids are rejected, `seq` is dense and monotonic.
3. Replay is deterministic: same events give byte-identical canonical encodings of the projection; replay of a prefix equals the projection at that point; replay from the serialized log equals replay from memory.
4. Vendor independence (metamorphic): rewriting every `provenance.model` leaves the projection unchanged.
