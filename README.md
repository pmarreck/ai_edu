# ai_edu

An evidence-adaptive education system intended to augment a learner's thinking, not automate it. The [INTENT](INTENT.md) states the durable goal; the [founding prompt](docs/evidence_adaptive_ai_education_meta_prompt.md) supplies the detailed architecture and pedagogy requirements.

The first slice exists: a validated `event/1` contract, an append-only log with canonical NDJSON, and a replayed `learner-projection/1` (see [ARCHITECTURE](docs/ARCHITECTURE.md)). There is no student-facing application yet.

```sh
nix develop -c ./test
nix flake check
```

The first implementation slice is an append-only event log with deterministic replay. No real learner data should be collected until the privacy and retention decisions in [PLAN.md](PLAN.md) are resolved.
