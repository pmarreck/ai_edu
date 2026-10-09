# Rules

- Functions return new values; they never mutate tables passed in by the caller (BDFN, 2026-09-30). Mutation is allowed only for private state an object owns and in I/O adapters. Hot folds may use structural sharing (copy only the changed path).
- LLMs propose; deterministic code decides canonical learner state. No model output changes mastery, scores or schedules directly.
- Every answer key comes from the strongest available oracle (`docs/policy/ORACLES.md`); items without a mechanical oracle need human approval before they gate mastery.
- No real child learner data is collected until BDFN decides retention, deployment and audio policy.
- Automate procedures instead of repeating them by hand.
