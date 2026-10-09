# Meta-Prompt: Build an Evidence-Adaptive AI Education System

## Mission

You are to design and, when tooling permits, implement a **general-purpose, longitudinal, evidence-adaptive AI education system** capable of teaching a learner across arbitrary domains and progressions of topics over months or years.

The system's governing principle is:

> **Thinking Augmentation > Thinking Automation**

The system exists to increase the learner's durable knowledge, transferable reasoning, independence, curiosity, epistemic hygiene, and desire to keep learning. It must not optimize merely for task completion, answer production, screen time, superficial engagement, or short-term test performance.

The generative AI is a component of the system, **not the system of record and not the ultimate authority over learner state**.

The architecture must be future-proof so that the generative model can be replaced by a better model without losing curriculum state, learner history, mastery estimates, experimental results, schedules, validated learning artifacts, or parent/teacher notes.

---

# 1. Non-Negotiable Design Principles

## 1.1 Augment cognition; do not replace it

The tutor should preferentially make the learner think, predict, retrieve, explain, manipulate, compare, debug, construct, simulate, test, or teach back.

Before supplying a final answer, the tutor should normally prefer this escalation ladder:

1. Ask for an attempt or prediction.
2. Ask the learner to explain current reasoning.
3. Give a small hint.
4. Give a stronger hint.
5. Reveal a relevant principle or partial step.
6. Show a worked example on an analogous problem.
7. Give the solution only when continued struggle is no longer educationally productive.
8. After giving a solution, require reconstruction, explanation, or a new independent problem.

Do not fetishize struggle. Productive struggle is useful; pointless frustration is not.

Assisted success and independent mastery are different variables and MUST be tracked separately.

## 1.2 Optimize long-term learning, not immediate fluency

Prefer durable retention and transfer over making today's activity feel easy.

Use, when appropriate:

- retrieval practice,
- spaced/distributed practice,
- interleaving,
- worked examples followed by fading guidance,
- formative assessment,
- corrective feedback,
- varied practice,
- prediction before observation,
- self-explanation when evidence and context favor it,
- comparison and discrimination among confusable concepts,
- transfer problems,
- occasional desirable difficulty,
- mastery-based progression.

Do not blindly apply any technique. Instruction must depend on prior knowledge, domain, age, cognitive load, fatigue, and evidence from this learner's actual outcomes.

## 1.3 Do not encode "learning styles" as identities

Never classify the learner as permanently "visual," "auditory," "kinesthetic," etc.

Preferences may be logged, but instructional decisions must be based primarily on **measured outcomes**.

Acceptable conclusion:

> "For this learner, prediction followed by simulation has recently produced better seven-day transfer on causal-mechanical concepts than explanation-first instruction."

Unacceptable conclusion:

> "This learner is a visual learner."

## 1.4 Preserve curiosity

A learning system that increases scores while making the learner hate the subject has failed.

Optimize jointly for:

- durable learning,
- transfer,
- confidence calibration,
- curiosity,
- autonomy,
- willingness to persist,
- intellectual honesty,
- willingness to challenge the tutor,
- enjoyment appropriate to the learner and subject.

Do not turn every activity into a game. Gamification is a tool, not a religion.

## 1.5 The learner may challenge the system

The student-facing interface MUST make it easy to say:

- "I think you're wrong."
- "Prove it."
- "I don't understand."
- "Show me another way."
- "This is too easy."
- "This is too hard."
- "I'm bored."
- "I need a break."
- "This isn't working right."

None of these actions may count as academic failure.

Detecting an error in the tutor can itself constitute evidence of mastery or epistemic skill.

---

# 2. Evidence Policy

## 2.1 Refresh the evidence before major implementation work

If web/research tools are available, review the current evidence before implementing or materially revising pedagogy policy.

Prioritize, in order:

1. systematic reviews and meta-analyses,
2. preregistered randomized controlled trials,
3. large field experiments,
4. replicated experimental findings,
5. smaller controlled studies,
6. observational evidence,
7. expert opinion only when better evidence is unavailable.

For each pedagogical technique maintain:

- evidence tier,
- target population,
- domain(s),
- outcome(s),
- known moderators,
- uncertainty,
- date last reviewed,
- citations/provenance.

Do not silently transform correlational findings into causal rules.

## 2.2 Evidence tiers

Use a versioned classification such as:

- **A: high confidence** — robust convergent experimental/meta-analytic support.
- **B: moderate confidence** — generally supported, important boundary conditions remain.
- **C: promising/experimental** — plausible or early evidence; use conservatively and instrument outcomes.
- **D: unsupported/disfavored** — do not deploy as a general principle.

Pedagogical policy changes must be versioned so historical learner outcomes can be interpreted against the policy in force at the time.

## 2.3 Current 2026 anchor principles

Treat these as initial priors, NOT eternal truths:

- Spaced/distributed practice is generally superior to massed practice for durable retention.
- Retrieval practice is useful, especially when corrective feedback is available, but should not automatically displace every elaborative strategy.
- Formative assessment has a modest positive average effect in K-12 research.
- Worked examples are particularly useful during initial acquisition of complex procedural skills, with guidance faded as competence increases.
- Active breaks can benefit some executive-function outcomes in children, but there is no universal magic interval.
- Simulation-based learning can be valuable, especially when scaffolding and progression are adapted appropriately.
- Matching teaching to fixed learner "styles" is insufficiently supported for use as a general personalization strategy.
- GenAI itself is not reliably beneficial; pedagogy and whether AI augments versus substitutes for cognition matter greatly.

---

# 3. System Architecture

Use a client/server architecture with a **thin student-facing client** and a server-side learning engine.

Conceptually:

```text
Student Client
      |
      v
Learning Server
  |-- curriculum graph
  |-- mastery engine
  |-- scheduler
  |-- fatigue/break engine
  |-- experiment allocator
  |-- lesson state machine
  |-- scoring engine
  |-- event log
  |-- artifact library
  |
  +--> Planner LLM
  +--> Tutor LLM
  +--> Evaluator LLM
  +--> Verifier/Critic LLM
  +--> Research/Policy LLM
```

These roles MAY be served by one underlying model, but their contexts, permissions, and outputs must remain logically separate.

## 3.1 Fundamental rule

> **LLMs interpret and generate. Algorithms remember and govern canonical state.**

The LLM may propose:

- a misconception,
- a lesson plan,
- an explanation,
- a rubric judgment,
- a new simulation,
- a candidate mastery observation.

The deterministic/statistical learning engine decides:

- what gets persisted,
- what changes mastery,
- what is due for review,
- whether prerequisites are satisfied,
- whether an experiment is assigned,
- whether a skill is considered mastered,
- whether a lesson exceeds limits,
- whether an artifact is safe to deploy.

Never permit a conversational model to directly mutate canonical learner state.

---

# 4. Implementation Language Policy

## 4.1 Core language

All newly authored application logic, lesson-generation tooling, evaluators, schedulers, experiment logic, backend services, sandbox runners, and generated executable educational demos SHOULD be written in **LuaJIT**, unless impossible for the target environment.

Use LuaJIT idiomatically. Favor small pure functions where practical, explicit data flow, testability, and simple state boundaries even though Lua is mutable.

## 4.2 Browser constraint

LuaJIT does not natively target ordinary browser WebAssembly environments.

Therefore:

- keep the browser thin;
- prefer HTML/CSS and declarative trusted components;
- keep any unavoidable browser runtime small, fixed, audited, and NOT generated per lesson;
- execute AI-generated LuaJIT activities server-side or in an isolated native sandbox where practical;
- for rich client interactions, prefer composing prebuilt trusted browser components from declarative schemas rather than generating JavaScript;
- if non-Lua glue is unavoidable, isolate it behind a stable interface and minimize it.

Never allow an LLM to casually emit arbitrary browser JavaScript merely because it is convenient.

---

# 5. Programming-Language Curriculum Policy

When the learner begins programming instruction:

1. The **first programming language shall be LuaJIT**, barring a later explicit policy change by a parent/administrator.
2. Emphasize immediate creation, experimentation, games/simulations, debugging, data structures, functions, composition, and the relationship between programs and real systems.
3. Teach good habits without burying the beginner beneath ceremony.
4. Introduce functional ideas naturally inside Lua before making functional programming a language-level identity.

## 5.1 Roc reevaluation policy

Roc is a preferred candidate for a later functional language, but do not assume its ecosystem maturity.

Periodically reevaluate Roc when either:

- the learner approaches readiness for a second serious language, OR
- a configurable review interval elapses.

Evaluate at least:

- compiler stability,
- release cadence,
- package ecosystem,
- tooling/editor support,
- debugger quality,
- documentation,
- platform stability,
- language semantic stability,
- quality of educational material,
- native deployment experience,
- community maintenance health.

If Roc becomes sufficiently mature, prefer it as the next functional language. Otherwise choose the best available functional language that satisfies the educational goals, but record why.

---

# 6. Learner Model

Maintain a persistent learner model derived from immutable events.

For every skill/concept node track, where applicable:

- mastery probability/estimate,
- independent mastery,
- assisted performance,
- number and quality of evidence events,
- most recent success,
- most recent independent success,
- delayed-retrieval results,
- transfer results,
- known/candidate misconceptions,
- response-time distribution,
- confidence calibration,
- prerequisite dependencies,
- review schedule,
- modality/pedagogy outcome history,
- uncertainty in all estimates.

Do not reduce a domain to a single "skill score."

Use a graph of prerequisites and related concepts.

Example:

```text
number_sense
  |-- counting
  |-- magnitude_comparison
  `-- place_value
       |-- tens_ones
       `-- carrying
```

Mastery estimates MUST be reconstructable from the event history when feasible.

---

# 7. Immutable Interaction/Event Log

Record educationally relevant interactions as append-only events.

Examples:

```text
session.started
lesson.planned
activity.presented
student.response
student.prediction
student.self_explanation
hint.requested
hint.given
tutor.response
simulation.parameter_changed
answer.submitted
answer.scored
misconception.proposed
misconception.confirmed
break.offered
break.started
break.ended
activity.failure_reported
artifact.fallback_used
lesson.completed
assessment.completed
retrieval.scheduled
```

Each event should include enough metadata for later statistical analysis and replay/recomputation.

Store, when relevant:

- learner ID,
- session ID,
- lesson ID,
- activity ID,
- skill/objective IDs,
- timestamps,
- elapsed active time,
- response latency,
- response content or reference,
- expected answer/rubric version,
- correctness,
- assistance/hint level,
- model/vendor/version,
- prompt/policy version,
- artifact version,
- pedagogy technique tags,
- modality tags,
- planned duration,
- actual duration,
- fatigue estimate,
- engagement signals,
- experiment arm and assignment probability,
- mastery estimate before/after,
- confidence/self-report where collected,
- failure/fallback state.

Never rely on years of raw chat transcript as the only memory mechanism.

---

# 8. Private System Notes vs Student Surface

The student-facing surface should remain focused on learning.

Server-side private educational state may include:

- mastery estimates,
- candidate misconceptions,
- experimental assignments,
- fatigue estimates,
- tutor hypotheses,
- pedagogical-effect estimates,
- review scheduling,
- artifact reliability,
- uncertainty.

These are NOT shown automatically to the learner.

However, they are not "secret dossiers."

Provide a parent/teacher/admin audit surface capable of inspecting:

- learner model,
- evidence behind conclusions,
- raw interactions where retention policy allows,
- experiments performed,
- pedagogical adaptations,
- model versions,
- confidence/uncertainty,
- artifact failures,
- why a lesson or progression decision was made.

Do not infer medical, psychiatric, personality, or developmental diagnoses from educational telemetry.

---

# 9. Lesson Lifecycle

## 9.1 Before a lesson

The planner receives a CURATED state, not the entire learner history.

At minimum:

- target objective(s),
- prerequisite status,
- current mastery estimates,
- known/candidate misconceptions,
- retrieval items due,
- recent examples and themes,
- recent pedagogical techniques,
- recent fatigue/break history,
- interests relevant to engagement,
- session time budget,
- experimental condition if assigned,
- available trusted components,
- artifact reliability thresholds.

Generate a structured **lesson graph**, not only prose.

Example:

```text
INTRO
  -> PREDICTION
  -> INTERACTIVE_ACTIVITY
       |-- expected_error -> TARGETED_REMEDIATION
       |-- unknown_error  -> LIVE_TUTOR
       `-- success        -> EXPLANATION
  -> INDEPENDENT_PROBLEM
  -> TRANSFER_PROBLEM
  -> RETRIEVAL_ITEM
  -> REFLECTION
```

Every lesson should state:

- objective,
- mastery evidence sought,
- expected misconceptions,
- pedagogy technique(s),
- activity modality,
- estimated duration,
- fallback plan,
- assessment strategy,
- transfer check,
- break policy,
- whether code generation is needed.

## 9.2 During a lesson

Use deterministic code for:

- timers,
- multiple choice,
- exact numerical scoring,
- simulation state,
- known-answer tasks,
- hint counters,
- break scheduling,
- event logging,
- state transitions.

Invoke an LLM when semantic/generative ability adds value, such as:

- interpreting a free-form explanation,
- answering an unanticipated question,
- generating an analogy,
- recognizing a misconception,
- creating a new challenge,
- adapting an explanation,
- evaluating open reasoning against a rubric,
- engaging in Socratic dialogue.

Do not call an LLM merely to decide facts that code already knows.

## 9.3 After important interactions

The tutor's interpretation is not canonical.

Use an evaluator/verifier role to produce structured candidate observations with uncertainty.

Example:

```json
{
  "skill": "orbital_motion.tangential_velocity",
  "evidence_strength": 0.82,
  "candidate_mastery_delta": 0.06,
  "candidate_misconceptions": [],
  "reasoning_quality": "causal",
  "requires_human_review": false
}
```

The learning engine validates and applies only allowed state changes.

---

# 10. Teaching Cycle

For a new or partially mastered objective, prefer the following general cycle, modified as domain evidence warrants:

1. **Diagnose** relevant prerequisite knowledge.
2. **State or imply a small concrete objective** appropriate to age.
3. **Elicit before telling** where productive: prediction, attempted solution, classification, explanation, etc.
4. **Teach minimally**, using the least explanation needed to unblock useful cognition.
5. **Interact** through manipulation, simulation, dialogue, construction, experimentation, code, physical activity, or worked examples when appropriate.
6. **Require generation/retrieval** from the learner.
7. **Give timely corrective feedback**.
8. **Fade scaffolding** as competence increases.
9. **Test independently** without AI assistance.
10. **Test transfer** in a meaningfully different context.
11. **Schedule spaced retrieval**.
12. **Revisit misconceptions**.
13. **Reflect/metacognate** briefly when appropriate.

The lesson must not confuse "the learner completed an activity" with "the learner learned the concept."

---

# 11. Interactive and Simulation-First Policy

When a concept is naturally learnable by manipulation, experimentation, prediction, or construction, prefer those over exposition.

Examples:

- physics: predict -> manipulate parameters -> observe -> explain,
- probability: simulated dice/cards/random processes,
- mathematics: manipulatives, number lines, geometric transforms,
- biology: classification, ecosystems, inheritance simulations,
- economics: small markets/agents,
- history: evidence comparison, timelines, competing causal accounts,
- language: conversation, roleplay, production,
- logic: puzzles, counterexamples, adversarial cases,
- programming: executable code, debugging, modification,
- writing: drafting and revision rather than lectures about writing.

Do NOT turn every lesson into an elaborate simulation.

Choose the simplest interaction that materially improves learning.

Novelty is useful, but deliberate reuse is also useful for retrieval and comparison.

---

# 12. Generated Executable Demos: TDD Is Mandatory

Any executable educational demo generated on the fly MUST be created using test-driven development.

No exceptions.

## 12.1 Required TDD loop

For each behavior:

1. Specify intended educational behavior.
2. Write the smallest failing automated test.
3. Run it and confirm failure for the expected reason.
4. Write the minimum implementation required to pass.
5. Run the test and confirm success.
6. Refactor without changing behavior.
7. Repeat for the next behavior.

Do not write the entire implementation and then manufacture tests afterward.

## 12.2 Required validation before student exposure

At minimum perform, where applicable:

- unit tests,
- deterministic/state-transition tests,
- property/invariant tests,
- boundary tests,
- reset/restart tests,
- smoke launch,
- automated interaction test,
- render/viewport sanity test,
- expected educational-state test,
- malformed-input test,
- timeout/resource limits,
- answer-leakage check.

The demo runs in a sandbox with explicit CPU/time/memory/network limits.

If the demo cannot be validated, DO NOT show it to the learner.

## 12.3 Runtime failure control

The student interface must include a prominent, age-appropriate:

> **This isn't working right**

control.

Offer subcategories when useful:

- It's broken.
- I don't know what I'm supposed to do.
- This is too complicated.
- This is too easy.
- Something else.

Automatically capture reproducible context. Do not ask the learner to perform technical diagnostics.

A reported demo failure must not reduce mastery or engagement scores.

## 12.4 Fallback ladder

Every generated demo must have fallback representations.

Typical ladder:

```text
ambitious generated simulation
  -> simpler generated simulation
  -> trusted component composition
  -> animated/static visualization
  -> manipulable diagram
  -> guided thought experiment
  -> ordinary explanation / physical activity
```

The learning objective survives; the presentation is disposable.

---

# 13. Artifact Library and Reuse

Successful educational artifacts should be reusable.

Store validated artifacts in a content-addressed/versioned library indexed by metadata such as:

- topic,
- concept/skill objective,
- prerequisites,
- age/level range,
- modality,
- pedagogy tags,
- difficulty,
- duration,
- language,
- test suite,
- sandbox requirements,
- generator model/version,
- policy version,
- reliability history,
- learner outcome history,
- accessibility features,
- last validation date.

Reuse a validated artifact when it is pedagogically appropriate and sufficiently reliable.

Do not regenerate merely for novelty.

## 13.1 Future models may challenge old artifacts

When substantially better generation capabilities become available, the system may generate a candidate replacement.

The new artifact must:

1. pass all inherited regression tests,
2. pass new tests appropriate to new functionality,
3. meet or exceed reliability thresholds,
4. not regress accessibility or clarity,
5. demonstrate plausible pedagogical improvement.

Where possible, compare old and new artifacts empirically before promotion.

Never replace a proven artifact merely because the new model is newer.

---

# 14. Fatigue, Boredom, Frustration, and Break Model

Track these as distinct concepts where possible:

- cognitive fatigue,
- topic fatigue,
- boredom/underchallenge,
- frustration/overchallenge,
- loss of engagement.

Potential signals include:

- response latency relative to personal baseline,
- declining accuracy,
- repeated similar errors,
- increased hints,
- shorter explanations,
- skipping,
- explicit self-report,
- requests to switch topics,
- total active time,
- recent break history.

No single signal may diagnose fatigue.

A slow answer may represent deep thought.

## 14.1 Break policy

Use:

- soft scheduled breaks,
- fatigue-triggered breaks,
- topic-fatigue breaks,
- learner-requested breaks.

Learner-requested breaks should normally be honored immediately.

Prefer active/off-screen breaks when feasible:

- get water,
- stretch,
- walk,
- go outside,
- find a bug,
- find three differently shaped leaves,
- bring back an object matching a property,
- short physical game.

Do not claim a universally optimal work/break interval.

Learn the individual's effective session envelope over time.

For young children, default to shorter uninterrupted periods than adult schedules unless evidence from the learner supports longer sessions.

Breaks are not punishment and should not be contingent on failure.

---

# 15. Empirical Personalization and A/B Testing

The system should experimentally learn which pedagogical choices work well for the learner.

Do NOT make permanent identity claims from preferences.

## 15.1 Micro-randomized trials

When two or more pedagogical approaches are all defensible for a comparable learning situation, the experiment allocator may randomize among them.

Examples:

- prediction-first vs explanation-first,
- worked-example-first vs guided-discovery-first,
- simulation vs diagram,
- Socratic questioning vs concise explanation,
- 12-minute vs 18-minute lesson block,
- immediate feedback vs slightly delayed feedback where evidence permits,
- neutral context vs interest-themed context.

Never randomize the learner into an approach believed to be harmful or clearly inappropriate.

Do not experiment during crises, severe fatigue, high-stakes evaluation, or when prerequisites are absent.

## 15.2 Store treatment metadata

For every experimental assignment store:

- experiment ID,
- hypothesis,
- arm,
- randomization method,
- assignment probability/propensity,
- eligibility conditions,
- prior mastery,
- topic/domain,
- difficulty estimate,
- time of day/session context,
- fatigue state,
- learner age/stage,
- outcome windows,
- policy version.

This is necessary for later causal analysis.

## 15.3 Outcomes

Do not optimize merely for immediate correctness.

Measure combinations of:

- immediate learning,
- independent performance,
- next-day retrieval,
- 7-day retrieval,
- longer delayed retrieval when practical,
- transfer,
- time-to-mastery,
- hints required,
- frustration,
- voluntary continuation,
- confidence calibration,
- curiosity/interest,
- error recurrence.

## 15.4 Adaptive allocation

After sufficient evidence, move from uniform exploration toward a contextual-bandit approach such as Bayesian/Thompson-style allocation.

Context may include:

- topic/domain,
- prior mastery,
- age/stage,
- fatigue,
- session duration,
- task type,
- prior response to pedagogical techniques.

Maintain an exploration floor so early noise does not become destiny.

Do not report false precision from tiny samples.

Prefer statements such as:

> "Evidence currently moderately favors prediction-first simulations for this learner in causal-science topics; continue exploration."

rather than:

> "This learner learns 18.37% better visually."

---

# 16. Mastery and Progression

A skill should not be considered mastered solely because the learner succeeded with hints or AI assistance.

Mastery evidence should preferably include:

- multiple successes,
- independent performance,
- delayed retrieval,
- transfer or variant problems,
- appropriate confidence,
- declining need for scaffolding.

Use an algorithmic/statistical mastery model such as Bayesian Knowledge Tracing, IRT-derived approaches, or a simpler well-calibrated model appropriate to the domain and available data.

The exact model may evolve, but its version and parameters must be recorded.

Historical events should permit recomputation with improved estimators.

Advance when mastery and prerequisites justify it, not because the learner has spent an arbitrary amount of time.

Allow curiosity-driven branches while preserving prerequisite integrity.

---

# 17. Scoring

Use deterministic scoring whenever the answer is objectively machine-checkable.

Examples:

- numeric result,
- exact symbolic expression with normalization,
- code tests,
- multiple choice,
- simulation target state,
- structured classifications.

Use LLM scoring only when semantic judgment is necessary.

For LLM scoring:

- use explicit rubrics,
- request structured output,
- record model/version,
- record confidence,
- use a verifier or second pass for consequential judgments,
- escalate uncertain cases rather than pretending certainty.

When feasible, periodically benchmark LLM scores against human judgments.

---

# 18. Knowledge Reliability and Provenance

For factual material:

- prefer authoritative primary or high-quality secondary sources,
- use current sources when facts can change,
- store source/provenance for generated curriculum content where practical,
- distinguish established fact, inference, controversy, and uncertainty,
- never fabricate citations,
- do not use uncertain claims as grading keys.

For controversial subjects, teach competing evidence and reasoning rather than manipulating the learner toward an ideological conclusion.

Epistemic habits are part of the curriculum:

- "How do you know?"
- "What evidence would change your mind?"
- "Is that source reliable?"
- "Could there be another explanation?"
- "What would falsify this?"

---

# 19. Originality and Lesson Variety

Every newly generated lesson should be a fresh composition responsive to current learner state.

However, "original" does NOT mean gratuitously unique.

The system may intentionally reuse:

- validated simulations,
- retrieval items after appropriate delay,
- familiar representations,
- successful analogies,
- benchmark assessment items where security allows.

Track recent themes/examples to prevent stale repetition.

Vary surface context enough to test abstraction and transfer.

Do not over-theme every lesson around the learner's favorite interests; excessive theming can become distracting and makes transfer harder to distinguish from familiarity.

---

# 20. Parent/Teacher Reporting

Provide a concise audit/report view containing:

- what was learned,
- what remains uncertain,
- independent vs assisted performance,
- notable misconceptions,
- delayed-retention results,
- upcoming review items,
- recent fatigue/break patterns,
- unusual artifact failures,
- current experiments,
- evidence for pedagogical adaptations,
- confidence/uncertainty.

Avoid deterministic personality conclusions.

Permit manual annotations by parent/teacher, but keep them provenance-tagged and distinct from measured learner evidence.

---

# 21. Privacy and Child Safety

For child learners:

- minimize personally identifying data,
- encrypt sensitive persistent state,
- separate learner profiles,
- provide parent-controlled retention/export/deletion policies,
- never sell or exploit learner data,
- never optimize for advertising or compulsive engagement,
- never use emotional dependency as an engagement strategy,
- avoid pretending the AI is a human friend,
- keep educational goals explicit.

If deployed beyond a private household, review current child-privacy, education, and data-protection requirements in the relevant jurisdiction before release.

---

# 22. Failure and Recovery

The system must expect its own failures.

Failures include:

- wrong factual claim,
- broken demo,
- poor explanation,
- ambiguous instructions,
- bad difficulty estimate,
- incorrect scoring,
- hallucinated prerequisite,
- inappropriate experiment,
- model outage,
- unavailable tool.

For each failure type define:

- detection,
- learner-facing recovery,
- fallback,
- logging,
- whether canonical state must be rolled back,
- regression test to prevent recurrence where possible.

Never gaslight the learner into assuming the system must be correct.

---

# 23. Prompt Contracts for AI Roles

## 23.1 Planner role

The planner MUST:

- consume structured learner/context state,
- generate a structured lesson graph,
- respect the assigned pedagogy/experimental arm,
- include independent and transfer checks,
- avoid premature answers,
- include fallbacks,
- choose interaction over exposition when appropriate,
- estimate duration,
- mark any executable artifact requirement,
- avoid repeating recent examples unless deliberate.

## 23.2 Tutor role

The tutor MUST:

- focus only on the current educational interaction,
- ask one cognitively useful thing at a time for young learners,
- adapt language to age without condescension,
- prefer hints over answers,
- correct errors clearly,
- acknowledge uncertainty,
- welcome challenges,
- preserve curiosity,
- never claim mastery authority,
- emit structured side-channel observations separately from student-facing text.

## 23.3 Evaluator role

The evaluator MUST:

- apply explicit rubrics,
- distinguish evidence from inference,
- estimate uncertainty,
- propose rather than directly mutate mastery,
- detect possible misconceptions,
- flag ambiguous answers for another attempt or review.

## 23.4 Verifier/Critic role

The verifier MUST inspect generated lessons/artifacts for:

- factual errors,
- pedagogical answer leakage,
- prerequisite mismatch,
- excessive cognitive load,
- accessibility problems,
- ambiguous instructions,
- unsafe executable behavior,
- failure to implement the assigned experimental condition,
- mismatch between activity and learning objective.

## 23.5 Research/Policy role

Periodically review new education and AI-learning research.

Propose policy changes with:

- evidence summary,
- strength/limitations,
- affected learner populations,
- expected benefit,
- migration implications,
- experiment proposal if uncertainty remains.

Never silently rewrite pedagogy policy.

---

# 24. Build/Implementation Workflow

When asked to implement this system:

1. Restate the smallest viable architecture.
2. Create the domain model and event schema first.
3. Build tests before implementation for each behavior.
4. Implement ONE feature at a time using TDD.
5. Begin with deterministic core functions before LLM integrations.
6. Make all LLM calls go through a model gateway abstraction.
7. Persist model and prompt versions with every relevant event.
8. Build replay/recomputation early.
9. Build the "This isn't working right" recovery flow before ambitious generated demos.
10. Build the artifact test sandbox before allowing generated executable activities.
11. Add experimental personalization only after baseline instrumentation is trustworthy.
12. Prefer boring, inspectable components over clever hidden state.

A suggested implementation order:

```text
A. event log
B. curriculum graph
C. learner/mastery state derivation
D. deterministic session/lesson state machine
E. scheduling + spaced retrieval
F. basic student UI
G. model gateway
H. planner/tutor/evaluator contracts
I. artifact sandbox + TDD pipeline
J. artifact library
K. break/fatigue model
L. experiment allocator
M. parent/audit interface
N. longitudinal analytics
```

---

# 25. Definition of Success

This project succeeds when it can demonstrate, over time, that it helps a learner become:

- more knowledgeable,
- better at retrieving knowledge without assistance,
- better at transferring knowledge to new situations,
- better at reasoning,
- better calibrated about what they know,
- more capable of detecting errors,
- more independent from the AI,
- still curious enough to ask the next question.

A successful tutor should eventually be needed **less** for mastered material, not more.

The ultimate failure mode to avoid is a learner who can produce excellent work only while attached to the AI.

---

# 26. Core Mottoes to Preserve Across Implementations

> **Thinking Augmentation > Thinking Automation**

> **LLMs interpret and generate. Algorithms remember and govern state.**

> **The objective is sacred; the presentation is disposable.**

> **Assisted performance is not independent mastery.**

> **The learner must always be allowed to challenge the teaching system.**

> **Measure what works for this learner; do not stereotype how this learner "learns."**

> **A lesson that teaches well but kills curiosity is not fully successful.**

> **Generated code is untrusted until its tests prove otherwise.**

> **Future models are replaceable; learner history is not.**

---

# 27. Initial Task for the AI Receiving This Meta-Prompt

When this document is supplied to an AI with the intent to build the system, do NOT immediately emit a monolithic implementation.

Instead:

1. Verify the current research and update the evidence table if research access is available.
2. Identify tool/environment constraints, especially browser execution and sandboxing.
3. Produce a concrete architecture consistent with this specification.
4. Define the event schema, learner-state schema, curriculum-node schema, lesson-plan schema, artifact schema, and AI-role interfaces.
5. Define tests for the first implementation slice.
6. Implement the smallest vertical slice in LuaJIT using strict TDD.
7. Demonstrate replayability and independence from any specific LLM vendor.
8. Continue one tested feature at a time.

Do not simplify away the longitudinal model, event provenance, delayed assessment, TDD requirement, experimental metadata, private/audit separation, or augmentation-over-automation principle. These are central requirements, not optional embellishments.
