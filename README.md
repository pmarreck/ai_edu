# ai_edu

[![Mechatron Prime CI](https://img.shields.io/endpoint?url=https%3A%2F%2Fthelio-nixos.tail66c90.ts.net%2Fbadges%2Fai_edu.json&style=for-the-badge)](https://thelio-nixos.tail66c90.ts.net/mechatron-prime/)

An evidence-adaptive education system intended to augment a learner's thinking, not automate it. The [INTENT](INTENT.md) states the durable goal; the [founding prompt](docs/evidence_adaptive_ai_education_meta_prompt.md) supplies the detailed architecture and pedagogy requirements.

It is written in LuaJIT. Learner history is an append-only event log; mastery, schedules and scores are deterministic folds over that log, and language models may only propose, never write canonical learner state. Answer keys come from independent oracles where one exists (the first course, king-and-pawn chess endgames, is keyed by an exhaustive retrograde solver checked against the Syzygy tablebase).

- Purpose and scope: [INTENT.md](INTENT.md)
- Architecture and versioned contracts: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Rules every change follows: [RULES.md](RULES.md)
- Evidence reviews and pedagogy policy: [docs/evidence/](docs/evidence/), [docs/policy/](docs/policy/)
- Open work: [PLAN.md](PLAN.md)

## Running

Requires Nix with flakes.

```sh
./test     # full suite, built and run in the Nix sandbox
./serve    # local web server on 127.0.0.1:8420 (see ./serve --help)
```

Continuous integration runs on Mechatron Prime CI, a self-hosted Nix build service that builds the targets listed in `.mechatron-prime/targets` for every push to `yolo`.

No real learner data should be collected until the privacy and retention decisions in [PLAN.md](PLAN.md) are resolved.
