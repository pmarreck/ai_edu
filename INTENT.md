# AI Education System: Intent

## Purpose

Build a general-purpose, longitudinal educational system that helps learners retain knowledge, transfer it to new problems, reason independently, and remain curious. Its governing preference is **thinking augmentation over thinking automation**. The full source brief is [the founding meta-prompt](docs/evidence_adaptive_ai_education_meta_prompt.md); this file summarizes its durable purpose, not every design detail.

## Intended users and outcomes

- Learners across domains and ages, with age-appropriate interaction and explicit safeguards for children.
- Parents and teachers who can inspect evidence, adaptations, uncertainty, and failures without treating an AI model as the authority on a learner.
- Developers who can change the underlying generative model without losing curriculum state, event history, mastery estimates, or validated artifacts.

Success means demonstrable independent performance, delayed retention, transfer, calibrated confidence, and sustained curiosity. Assisted success must remain distinct from independent mastery.

## Constraints

- LuaJIT is the default implementation language for application logic and educational demos. The browser, if any, stays thin; unavoidable non-Lua glue must be small and isolated.
- Immutable educational events are the source of truth. Deterministic/statistical code owns canonical learner state; LLMs propose interpretations and content but cannot directly mutate it.
- Preserve provenance, policy/model versions, uncertainty, replayability, privacy, and a parent/teacher audit path.
- Generated executable activities must pass tests and run within explicit resource and network limits before a learner sees them.
- Prefer small, tested vertical slices. The initial slice is an event schema, append/replay, and a derived learner-state projection independent of any LLM vendor.

## Non-goals

- A monolithic AI tutor built from the meta-prompt in one pass.
- Maximizing screen time, task completion, superficial engagement, or immediate answer fluency at the expense of learning.
- Permanent “learning style” labels, diagnostic claims inferred from telemetry, or generated browser JavaScript as a convenience shortcut.

## Open decisions

- First learner: BDFN (Benevolent Dictator For Now, the project's maintainer), an adult dogfooding one short bounded concept. Second: a young child who does not read yet; full use is expected once reading unlocks it, with early literacy as a possible first direction.
- Interface, deployment location, and data-retention defaults still require BDFN's direction before any child learner data is collected.
- Current evidence behind pedagogy policies must be checked and provenance recorded before materially implementing those policies.
- Pedagogy priors are versioned in docs/policy/PEDAGOGY_PRIORS.md (supersedes founding prompt 2.3) and re-reviewed every 4-6 months.
