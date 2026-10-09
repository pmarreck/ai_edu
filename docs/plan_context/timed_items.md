# Timed items (BDFN, 2026-09-28)

- Optional `timing` on item/1: `limit_ms` and `on_timeout` = `fail` or `hint_then_retry` (hint raises hint_level, so a later success counts as assisted, which the projection already tracks).
- The server clock is authoritative: elapsed time is measured from the logged presentation to the logged submission or timeout. The client countdown only displays time.
- Outcomes stay distinct: correct in time, correct but late (accurate, not yet fluent), wrong, and timed out without an answer. A late correct answer is not recorded as a plain fail.
- Latency is already logged for every answer, so fluency can be measured without a visible timer. Visible countdown versus silent measurement is an experiment arm, not a default.
- Use timing for fluency practice once accuracy is established (a common instructional sequence; expert opinion, not in the evidence reviews). Off by default for the child track. Break, "too hard" and "this isn't working right" controls stop the clock and never count as a timeout.
