# Delayed checkpoints

Unseen, unaided, no-feedback checks at 1, 7 and 30 days, kept separate from practice so they can measure retention and later validate the mastery estimator (pedagogy prior 8: mastery is measured on unaided, delayed items).

- Anchor: a skill's first unaided scored attempt in a lesson (not a review or checkpoint) sets day 0 for that skill.
- Due: on calendar day `day0 + k` for k in {1, 7, 30}. Only the largest due offset not yet taken is offered; smaller untaken offsets are skipped, so a learner returning on day 8 takes the 7-day check rather than a late 1-day one.
- Items: fresh solver-generated positions never shown before, two per skill, interleaved; the plan is logged at session start like reviews.
- No feedback: submissions are recorded and scored (`answer.scored` carries `checkpoint = k`), but the response reveals nothing; the client shows that the answer was recorded.
- Separation: the review scheduler and the mastery estimator ignore checkpoint scores. The learner projection keeps them in a separate `checkpoint` bucket, never in `independent`.
- Open for BDFN on return: whether to show checkpoint results after completion (currently never shown in the session).
