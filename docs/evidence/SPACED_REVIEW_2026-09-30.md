# Evidence Review: Spaced Review Scheduling, Successive Relearning and Misinformation Resistance 2026-09-30

Policy version: `evidence-policy/1`
Review date: 2026-09-30
Reviewer: Claude (agent), for the scheduler item in `PLAN.md` ("predicted-forgetting spaced review, successive relearning, solver-generated varied instances, separate 1/7/30-day checkpoints") and the correction side of `docs/plan_context/counterfeit_scrutiny.md`.

Design under review: a periodic-review scheduler for one adult learner now and a child of about 7 later. Open choices: the memory model (fixed rule, expanding ladder, or a model fitted to the learner's own history), the target recall probability at review time, the initial gaps before enough data exists to fit a learner, the relearning criterion, whether reviews reuse the same item or a new solver-generated instance, and how delayed checkpoints are kept separate from practice. Section 7 tests BDFN's hypothesis that susceptibility to misinformation is trainable, for the counterfeit reveal.

Method: For each question, searched for meta-analyses and systematic reviews first, then randomized experiments and field studies. Candidates were located with the OpenAlex search API, the arXiv API, ERIC and one web search (FSRS). Abstracts were read from OpenAlex, Europe PMC, Semantic Scholar and the ERIC API. Every DOI below was checked against https://api.crossref.org/works/<doi> for title, authors, year and venue, and for `updated-by` notices; OpenAlex `is_retracted` was checked for all 60 cited works (62 DOIs including two correction notices). No retractions were found. Two corrections exist (Roozenbeek and van der Linden 2019; Guess et al. 2020), noted in place; neither correction's content was read. A number is recorded only if it appeared in a primary abstract, the primary full text, or (for the FSRS benchmark, which has no paper) the benchmark's own repository. Items seen only in search results or secondary summaries are listed under "Unverified / not found".

Full text read: Eglington and Pavlik 2020 (PMC7567101, methods and results). Primary non-paper sources read: the `open-spaced-repetition/srs-benchmark` README at commit `bd9110f791` (2026-09-18) and the fsrs4anki wiki page "The Optimal Retention". Everything else is abstract-level.

Limits: Most spacing and relearning evidence uses verbal material (vocabulary, facts, short concepts) with undergraduates or online adults. Evidence for mathematical procedures is weaker and in one case null-to-small. Direct evidence at age 7 is limited to a few small studies. No randomized trial was found that compares FSRS, SM-2 or half-life regression on a delayed learning outcome; the FSRS evidence is about predicting recall. The misinformation literature measures belief in and discernment of news headlines or fictional reports, not correction of planted grading errors in a tutor.

Tier key (meta-prompt 2.2): A high confidence, B moderate with boundary conditions, C promising/experimental, D unsupported/disfavored.

---

## 1. Spacing gap relative to retention interval, and multi-session schedules

- Tier: B that the best gap between two study episodes grows with the retention interval but shrinks as a proportion of it. B that the number of sessions an item appears in matters more than how repetitions are split among them. (Spacing over massing is A, per `EVIDENCE_2026-09-28.md` section 1.)
- Population: adults (online and lab); verbal facts, vocabulary, object names.
- Findings:
  - Cepeda, Vul, Rohrer, Wixted, Pashler 2008 (more than 1,350 participants; gap up to 3.5 months, test delay up to 1 year): at each test delay, lengthening the gap first raised then gradually lowered final performance. The optimal gap rose with test delay, but as a proportion of the delay it fell from about 20-40% of a 1-week delay to about 5-10% of a 1-year delay. Too long a gap costs less than too short a gap (the curve rises sharply and declines gradually).
  - Cepeda et al. 2009 (two three-session lab studies; vocabulary, facts, object names; test delays up to 6 months): an optimal gap improved final recall by up to 150%; the same nonmonotonic shape appeared. The authors conclude cumulative reviews are needed for retention over meaningful periods.
  - Walsh et al. 2022 (declarative knowledge, schedules with increasing, decreasing or constant repetitions across sessions): retention depended strongly on the total number of sessions an item appeared in, not on how repetitions were distributed among those sessions. A computational model (Predictive Performance Equation) accounted for the pattern.
- Uncertainty: moderate. The ridgeline comes from two-episode designs; with many reviews, the per-review "optimal gap" is not a fixed fraction and models (section 4) take over.
- Differs from prior: consistent. Adds a quantitative starting point for gaps and a reason to prefer more sessions over more repetitions per session.
- Citations:
  - Cepeda, Vul, Rohrer, Wixted, Pashler (2008). Spacing effects in learning: a temporal ridgeline of optimal retention. Psychological Science 19(11):1095-1102. doi:10.1111/j.1467-9280.2008.02209.x
  - Cepeda, Coburn, Rohrer, Wixted, Mozer, Pashler (2009). Optimizing distributed practice: theoretical analysis and practical implications. Experimental Psychology 56(4):236-246. doi:10.1027/1618-3169.56.4.236
  - Walsh, Krusmark, Jastrembski, Hansen, Honn, Gunzelmann (2023; online 2022). Enhancing learning and retention through the distribution of practice repetitions across multiple sessions. Memory and Cognition 51(2):455-472. doi:10.3758/s13421-022-01361-8

## 2. Expanding vs uniform schedules

- Tier: B that neither shape is generally superior on a delayed final test. C for the boundary conditions under which expanding helps (weak initial learning, high interference) and for expanding keeping recall higher during the training period.
- Findings:
  - Latimier, Peyre, Ramus 2021 (meta-analysis, already reviewed): expanding vs uniform g = 0.034; expanding helped more as the number of tests rose.
  - Karpicke and Roediger 2007 (three experiments, vocabulary pairs): expanding practice helped at 10 minutes; equal spacing gave better retention 2 days later, with or without feedback. Delaying the first test improved long-term retention regardless of later spacing; expanding the later intervals had little effect. Karpicke and Roediger 2010 (text passages, final test 1 week later): repeated testing beat a single test, feedback helped, and expanding vs equal spacing made no difference.
  - Storm, Bjork, Storm 2010 (three experiments, prose, no feedback): expanding beat uniform at 1 week only when the task between retrievals was highly interfering.
  - Kang, Lindsey, Mozer, Pashler 2014 (foreign vocabulary, sessions over 4 weeks, final test 8 weeks later): expanding and equal-interval sessions gave equivalent final recall, but expanding gave much higher average recallability during training.
  - Gerbier, Toppino, Koenig 2015 (vocabulary; study on days 1-2-13, 1-7-13 or 1-12-13; tests 2, 6 or 13 days later): the expanding schedule generally did best, possibly more so at longer retention intervals. Toppino, Phelan, Gerbier 2018 (multi-day schedules over 13 days, test 2 weeks later): expanding was superior after low initial training (two study trials) but not after high initial training (five rounds of testing with feedback).
- Uncertainty: moderate. Mostly word pairs and short texts with undergraduates.
- Differs from prior: consistent with `PEDAGOGY_PRIORS.md` item 1. Refinement: the multi-day studies (Kang, Gerbier, Toppino) are closer to a scheduler than single-session ones and lean toward expanding when initial learning is weak. The consistent factor is a delayed first retrieval (Karpicke and Roediger 2007), which is a difficulty effect, not a shape effect.
- Citations:
  - Latimier, Peyre, Ramus (2021; online 2020). A meta-analytic review of the benefit of spacing out retrieval practice episodes on retention. Educational Psychology Review 33(3):959-987. doi:10.1007/s10648-020-09572-8 (numbers from the 2026-09-28 review; abstract not re-retrieved today)
  - Karpicke, Roediger (2007). Expanding retrieval practice promotes short-term retention, but equally spaced retrieval enhances long-term retention. JEP: Learning, Memory, and Cognition 33(4):704-719. doi:10.1037/0278-7393.33.4.704
  - Karpicke, Roediger (2010; online 2009). Is expanding retrieval a superior method for learning text materials? Memory and Cognition 38(1):116-124. doi:10.3758/mc.38.1.116
  - Storm, Bjork, Storm (2010). Optimizing retrieval as a learning event: when and why expanding retrieval practice enhances long-term retention. Memory and Cognition 38(2):244-253. doi:10.3758/mc.38.2.244
  - Kang, Lindsey, Mozer, Pashler (2014). Retrieval practice over the long term: should spacing be expanding or equal-interval? Psychonomic Bulletin and Review 21(6):1544-1550. doi:10.3758/s13423-014-0636-z
  - Gerbier, Toppino, Koenig (2015; online 2014). Optimising retention through multiple study opportunities over days: the benefit of an expanding schedule of repetitions. Memory 23(6):943-954. doi:10.1080/09658211.2014.944916
  - Toppino, Phelan, Gerbier (2018). Level of initial training moderates the effects of distributing practice over multiple days with expanding, contracting, and uniform schedules. Memory and Cognition 46(6):969-978. doi:10.3758/s13421-018-0815-7

## 3. Successive relearning (retrieval to criterion in each of several sessions)

- Tier: B for durable retention of verbal and conceptual material, including course exams. C (small effect) for mathematical procedures. B that later relearning sessions override the initial criterion, so a high first-session criterion is inefficient when relearning follows.
- Population: undergraduates in lab and in courses (introductory psychology, biopsychology); one online replication series of 431 students for probability problems.
- Findings:
  - Rawson and Dunlosky 2011 (three experiments, 533 students, conceptual material, over 100,000 hand-scored recalls; tests 1-4 months later): initial criterion (1-4 correct recalls) and relearning (1-5 later sessions to 1 correct recall) were subadditive; the criterion's effect was strong before relearning and diminished as relearning increased. Relearning improved retention at small cost in trials. Authors' prescription: initial criterion of 3 correct recalls, then 3 relearning sessions at widely spaced intervals.
  - Vaughn, Dunlosky, Rawson 2016 (Swahili-English pairs; initial criterion 1-7; four or five weekly relearning sessions to 1 correct recall): the large first-session criterion benefit did not persist across relearning, including after a one-month interval ("relearning override").
  - Rawson, Vaughn, Walsh, Dunlosky 2018 (two experiments): relearning over single-session learning ds = 1.52 to 4.19; initial-lag effects ds = 1.07 to 1.87 before relearning, -0.20 to 0.38 after.
  - Rawson, Dunlosky, Sciartelli 2013 (two course experiments): improvements on course exams and long-term retention tests; the abstract gives no effect sizes.
  - Janes, Dunlosky, Rawson, Jasnow 2020 (two experiments, biopsychology course, flashcard program vs business as usual): at least 10% better on a high-stakes exam, ds 0.54 to 1.10.
  - Higham, Zengel, Bartlett, Hadwin 2022 (introductory psychology, within-student alternating weeks, exposure time matched to restudy; three sessions 2 days apart after each lecture; correct items dropped, wrong ones repeated up to twice): better end-of-semester recall than restudy; students reported it as enjoyable.
  - Rawson, Dunlosky, Janes 2020 (431 students, probability problems, 1 correct per type in each of three sessions vs 3 correct in one session; novel problems 1 week later): pooled d = 0.28 (95% CI 0.08 to 0.49); correctly solving one problem did not raise the chance of solving the next.
  - Higham, Fastrich, Potts, Murayama, Pickering, Hadwin 2023 (three preregistered online experiments, sessions 2 days apart): when learners rated their memory on every trial, restudy beat retrieval; without the ratings, retrieval beat restudy. A per-trial self-rating can change the outcome it is meant to observe.
- Uncertainty: moderate. The field studies are mostly from one research group; designs are within-course and often not randomized at the student level.
- Differs from prior: new to the priors. Adds a concrete relearning rule and a caution about procedures.
- Citations:
  - Rawson, Dunlosky (2011). Optimizing schedules of retrieval practice for durable and efficient learning: how much is enough? JEP: General 140(3):283-302. doi:10.1037/a0023956
  - Vaughn, Dunlosky, Rawson (2016). Effects of successive relearning on recall: does relearning override the effects of initial learning criterion? Memory and Cognition 44(6):897-909. doi:10.3758/s13421-016-0606-y
  - Rawson, Vaughn, Walsh, Dunlosky (2018). Investigating and explaining the effects of successive relearning on long-term retention. JEP: Applied 24(1):57-71. doi:10.1037/xap0000146
  - Rawson, Dunlosky, Sciartelli (2013). The power of successive relearning. Educational Psychology Review 25(4):523-548. doi:10.1007/s10648-013-9240-4 (abstract via ERIC EJ1036741)
  - Janes, Dunlosky, Rawson, Jasnow (2020). Successive relearning improves performance on a high-stakes exam in a difficult biopsychology course. Applied Cognitive Psychology 34(5):1118-1132. doi:10.1002/acp.3699
  - Higham, Zengel, Bartlett, Hadwin (2022). The benefits of successive relearning on multiple learning outcomes. Journal of Educational Psychology 114(5):928-944. doi:10.1037/edu0000693
  - Rawson, Dunlosky, Janes (2020). All good things must come to an end: a potential boundary condition on the potency of successive relearning. Educational Psychology Review 32(3):851-871. doi:10.1007/s10648-020-09528-y (abstract via ERIC EJ1263194)
  - Rawson, Dunlosky (2022). Successive relearning: an underexplored but potent technique. Current Directions in Psychological Science 31(4):362-368. doi:10.1177/09637214221100484
  - Higham, Fastrich, Potts, Murayama, Pickering, Hadwin (2023). Spaced retrieval practice: can restudying trump retrieval? Educational Psychology Review 35(4). doi:10.1007/s10648-023-09809-2

## 4. Algorithmic schedulers fitted to learner data

- Tier: B that fitted models (FSRS, neural models) predict next-review recall better than older fixed models, on Anki data. C that model-driven scheduling produces better learning than a fixed spaced schedule (one classroom study and one online experiment; no FSRS trial). D for claims that FSRS or SM-2 improves learning outcomes: untested, not disproved.
- Prediction evidence:
  - FSRS benchmark (srs-benchmark README, commit bd9110f791; 9,999 Anki collections, about 350 million evaluated reviews, time-ordered train/test split; not peer-reviewed). Log loss, lower is better: FSRS-7 0.3401, FSRS-6 0.3460, FSRS-5 0.3561, HLR 0.4694, ACT-R 0.4033; a zero-parameter moving average of the user's recent outcomes scored 0.3369 and the constant-average baseline 0.3945. AUC: FSRS-7 0.7167, moving average 0.7001, HLR 0.6369. A GRU (503 parameters) reached 0.3328 and a large RWKV model with extra features 0.2773. FSRS-7 with default (unfitted) parameters: 0.3620. SM-2 is not in the current table.
  - Settles and Meeder 2016 (half-life regression, Duolingo data): 45%+ lower error than baselines at predicting recall; in an operational user study, daily engagement rose 12%. Engagement is not learning.
  - Ye, Su, Cao 2022 (KDD; 220 million review logs, MaiMemo): a Markov memory model plus a stochastic-shortest-path scheduler that minimizes review cost; the abstract reports a 12.6% improvement over prior methods in the authors' offline experiments. Su, Ye, Nie, Cao, Chen 2023 (TKDE): 64% less recall-prediction error and 17% less schedule cost than baselines, on logged and simulated data.
- Learning-outcome evidence:
  - Lindsey, Shroyer, Pashler, Mozer 2014 (semester middle-school foreign-language course, time-matched review strategies, cumulative exam after the semester): personalized model-based review gave 16.5% better course retention than massed study and 10.0% better than one-size-fits-all spacing.
  - Eglington and Pavlik 2020 (full text; Experiment 2, 322 MTurk adults, Japanese-English pairs, final test 3 days later): scheduling the item whose predicted recall had fallen just below a threshold of 0.86 or 0.94 beat a conventional fixed spacing schedule by about 40% and beat thresholds of 0.40 and 0.98. The simulation predicted a skewed inverted U with its peak at 0.94; the model included the time cost of wrong answers.
  - Tabibian et al. 2019 (PNAS, Duolingo): learners whose reviews happened to follow the MEMORIZE schedule memorized more effectively than those following heuristic schedules. This is a natural experiment, not randomized.
  - Wilschut et al. 2021: a response-time-based adaptive model beat a Leitner flashcard system on accuracy and response time at the end of a session (efficiency, not delayed retention).
- Uncertainty: high for learning outcomes. The benchmark measures calibration and discrimination of recall predictions; a scheduler also needs the model to be right about how reviewing changes future memory, which prediction metrics do not test. The moving-average result shows much of the log-loss gain is capturing per-user recent performance.
- Differs from prior: the plan's "predicted-forgetting spaced review" is supported as a prediction layer; its learning benefit over a sensible fixed ladder is C.
- Citations:
  - Settles, Meeder (2016). A trainable spaced repetition model for language learning. Proceedings of ACL 2016 (Vol. 1):1848-1858. doi:10.18653/v1/p16-1174
  - Ye, Su, Cao (2022). A stochastic shortest path algorithm for optimizing spaced repetition scheduling. Proceedings of KDD 2022:4381-4390. doi:10.1145/3534678.3539081
  - Su, Ye, Nie, Cao, Chen (2023). Optimizing spaced repetition schedule by capturing the dynamics of memory. IEEE TKDE 35(10):10085-10097. doi:10.1109/tkde.2023.3251721
  - Lindsey, Shroyer, Pashler, Mozer (2014). Improving students' long-term knowledge retention through personalized review. Psychological Science 25(3):639-647. doi:10.1177/0956797613504302
  - Eglington, Pavlik (2020). Optimizing practice scheduling requires quantitative tracking of individual item performance. npj Science of Learning 5. doi:10.1038/s41539-020-00074-4
  - Tabibian, Upadhyay, De, Zarezade, Schölkopf, Gomez-Rodriguez (2019). Enhancing human learning via spaced repetition optimization. PNAS 116(10):3988-3993. doi:10.1073/pnas.1815156116
  - Wilschut, Sense, van der Velde, Fountas, Maaß, van Rijn (2021). Benefits of adaptive learning transfer from typing-based learning to speech-based learning. Frontiers in Artificial Intelligence 4. doi:10.3389/frai.2021.780131
  - open-spaced-repetition/srs-benchmark, README at commit bd9110f791 (2026-09-18), https://github.com/open-spaced-repetition/srs-benchmark (no DOI; not peer-reviewed)

## 5. Target retention and retrieval difficulty

- Tier: B that harder successful retrievals produce better later memory (retrieval effort). C for a specific target retention: one experiment places the best threshold between 0.86 and 0.94 for vocabulary; the FSRS workload tradeoff is a simulation from a non-peer-reviewed source.
- Findings:
  - Pyc and Rawson 2009 (two experiments): longer lags made correct retrieval harder and final performance higher; raising the criterion made retrieval easier with diminishing returns. The abstract gives no effect sizes.
  - Karpicke and Roediger 2007 (section 2): delaying the first retrieval improved long-term retention.
  - Eglington and Pavlik 2020 (section 4): 0.86 and 0.94 thresholds beat 0.40 and 0.98. The authors' simulations with other assumptions indicate the optimal threshold may vary.
  - fsrs4anki wiki, "The Optimal Retention": in FSRS simulations, workload as a function of desired retention has a minimum, because high targets shorten intervals and low targets cause more forgetting and relearning; the page states that the curves come from default parameters and vary among learners, and it gives no numbers.
- Uncertainty: high for the exact target. Both sources use flashcard-type items; how the value transfers to procedural skills is unknown.
- Citations:
  - Pyc, Rawson (2009). Testing the retrieval effort hypothesis: does greater difficulty correctly recalling information lead to higher levels of memory? Journal of Memory and Language 60(4):437-447. doi:10.1016/j.jml.2009.01.004 (abstract via ERIC EJ834321)
  - fsrs4anki wiki, "The Optimal Retention", https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Optimal-Retention (no DOI; not peer-reviewed)

## 6. Varied vs identical items at review; interleaving at review

- Tier: B that retrieval practice transfers to new questions (d = 0.40), mainly under specific moderators. B/C that retrieving with different examples of a concept transfers better than retrieving the same example (one four-experiment paper plus related variability findings). C that the benefit of variation depends on prior knowledge. B for interleaving confusable categories (see `EVIDENCE_2026-09-28.md` section 3).
- Findings:
  - Pan and Rickard 2018 (meta-analysis; 192 effect sizes, 122 experiments, N = 10,382): testing yields transfer vs a nontesting control, d = 0.40 (95% CI 0.31 to 0.50); greatest to application and inference questions, weakest to untested material and rearranged items. Response congruency, elaborated retrieval and initial test performance moderated it. After publication-bias adjustment, predicted transfer was often zero when none of those moderators was present.
  - Butler 2010 (four experiments, prose): repeated testing beat repeated studying on new inferential questions a week later, within and across domains.
  - Butler, Black-Maier, Raley, Marsh 2017 (four experiments, geology lecture clips, final test 2 days later with new application questions): answering three different application questions beat answering the same question three times in all four experiments.
  - Goode, Geraci, Roediger 2008 (anagrams): practicing varied versions beat repeating the tested anagram, even on that anagram.
  - Braithwaite and Goldstone 2015 (mathematical concept): less knowledgeable learners learned better from similar examples, more knowledgeable learners from varied ones; pretraining attention to structure made varied examples work for the former. Raviv, Lupyan, Green 2022 (review): variability makes initial learning harder and generalization better.
  - Firth, Rivers, Boyle 2021 (systematic review; 26 studies, 17 meta-analyzed): interleaving benefit up to g = 0.65 for memory and 0.66 for transfer to novel items, largest when differences between items are subtle, also on delayed tests; mostly undergraduate lab studies.
- Children:
  - Vlach, Sandhofer, Kornell 2008 (3-year-olds): spaced presentation beat massed for memory of identical instances and for category induction from varied instances. Gluckman, Vlach, Sandhofer 2014 (36 early-elementary children, science lessons): spaced lessons improved memory and generalization at 1 week over massed and clumped.
  - Goossens et al. 2016 (grades 2, 3, 4 and 6, regular vocabulary curriculum, tests after 1-11 weeks): no benefit of longer-lag repetition or of retrieval over copying. The authors question the practical value in real primary vocabulary lessons.
- Citations:
  - Pan, Rickard (2018). Transfer of test-enhanced learning: meta-analytic review and synthesis. Psychological Bulletin 144(7):710-756. doi:10.1037/bul0000151
  - Butler (2010). Repeated testing produces superior transfer of learning relative to repeated studying. JEP: Learning, Memory, and Cognition 36(5):1118-1133. doi:10.1037/a0019902
  - Butler, Black-Maier, Raley, Marsh (2017). Retrieving and applying knowledge to different examples promotes transfer of learning. JEP: Applied 23(4):433-446. doi:10.1037/xap0000142
  - Goode, Geraci, Roediger (2008). Superiority of variable to repeated practice in transfer on anagram solution. Psychonomic Bulletin and Review 15(3):662-666. doi:10.3758/pbr.15.3.662
  - Braithwaite, Goldstone (2015). Effects of variation and prior knowledge on abstract concept learning. Cognition and Instruction 33(3):226-256. doi:10.1080/07370008.2015.1067215
  - Raviv, Lupyan, Green (2022). How variability shapes learning and generalization. Trends in Cognitive Sciences 26(6):462-483. doi:10.1016/j.tics.2022.03.007
  - Firth, Rivers, Boyle (2021). A systematic review of interleaving as a concept learning strategy. Review of Education 9(2):642-684. doi:10.1002/rev3.3266
  - Vlach, Sandhofer, Kornell (2008). The spacing effect in children's memory and category induction. Cognition 109(1):163-167. doi:10.1016/j.cognition.2008.07.013
  - Gluckman, Vlach, Sandhofer (2014). Spacing simultaneously promotes multiple forms of learning in children's science curriculum. Applied Cognitive Psychology 28(2):266-273. doi:10.1002/acp.2997
  - Goossens, Camp, Verkoeijen, Tabbers, Bouwmeester, Zwaan (2016). Distributed practice and retrieval practice in primary school vocabulary learning: a multi-classroom study. Applied Cognitive Psychology 30(5):700-712. doi:10.1002/acp.3245

## 7. Continued influence, corrections, and trainable resistance to misinformation

### 7a. Corrections

- Tier: A that corrections reduce but do not eliminate reliance on misinformation. B that detailed, coherent corrections that restate the myth work better than terse ones and do not backfire.
- Findings:
  - Lewandowsky et al. 2012 (review): retractions are often ineffective in memory updating; the review gives recommendations for designing corrections.
  - Walter and Tukachinsky 2020 (32 studies, N = 6,527): correction does not entirely eliminate the misinformation effect (r = -.05, p = .045). Corrections work better when coherent and from the original source; worse when the misinformation was repeated before correction, attributed to a credible source, or when the correction came after a lag.
  - Chan, Jones, Hall Jamieson, Albarracín 2017 (k = 52, N = 6,878): misinformation ds = 2.41-3.08, debunking ds = 1.14-1.33, persistence despite debunking ds = 0.75-1.06. Persistence was stronger when audiences generated reasons for the misinformation. Detailed debunking correlated with larger debunking and, unexpectedly, with larger persistence.
  - Walter and Murphy 2018 (k = 65): corrections moderate belief (r = .35); rebuttals (r = .38) beat forewarnings (r = .16); appeals to coherence (r = .55) beat fact-checking (r = .25).
  - Ecker, Hogan, Lewandowsky 2017: retractions that explicitly repeated the misinformation reduced its effect more than retractions that avoided repeating it. Ecker, Lewandowsky, Chadwick 2020 (three experiments, N = 1,718, 1-week delay): no familiarity backfire even for novel misinformation. Swire, Ecker, Lewandowsky 2017: more explanatory detail sustained belief change; adults over 65 sustained corrections worse; fact affirmations sustained belief change better than myth retractions over 1 week, but not over 3 weeks.
  - Huff and Umanath 2018 (two experiments): warnings alone did not reduce suggestibility; instructions to detect errors plus worked examples of errors let younger adults reduce contradictory misinformation. Additive misinformation (false details added to a true account) resisted all warnings.
  - Chan, Manley, Lang 2017 (review plus two experiments): taking a memory test before exposure to misleading information can increase later uptake of that information (retrieval-enhanced suggestibility), and telling people about their inconsistencies did not remove it.

### 7b. Inoculation and prebunking: effect, measurement dispute, decay

- Tier: B for a small improvement in discernment from inoculation (d about 0.20). C for game-based inoculation improving discrimination, as opposed to shifting toward "fake" responses. B that effects decay within weeks unless rehearsed, and that immediate testing or memory boosters extend them.
- Findings:
  - Banas and Rains 2010 (54 cases, attitudinal inoculation): inoculation beat supportive messages and no treatment; resistance was similar at immediate and moderate delays and decayed after two weeks.
  - Lu, Hu, Li, Bi, Ju 2023 (42 studies, N = 42,530): misinformation credibility d = -0.36, real-information credibility d = 0.20, credibility discernment d = 0.20, sharing discernment d = 0.18; no significant effect on misinformation sharing intention.
  - Roozenbeek and van der Linden 2019 (Bad News, N = 15,000, pre-post without a randomized control): improved spotting of misinformation "irrespective of education, age, political ideology, and cognitive style" (correction published, not read). Roozenbeek et al. 2022 (six preregistered RCTs, n = 6,464, plus a YouTube field study, n = 22,632): short technique videos improved recognition of manipulation techniques and discernment.
  - Modirrousta-Galian and Higham 2023 (ROC reanalysis of five Bad News and Go Viral! studies): with comparable true and fake items, the games did not improve discrimination; they made responses more conservative toward all news.
  - Maertens, Roozenbeek, Basol, van der Linden 2021 (N = 151, 194, 170): with regular testing, the effect lasted at least 3 months; without it, it decayed over 2 months to nonsignificance. Capewell et al. 2024 (N = 503, 673, preregistered): 48 hours after a video, only participants given an immediate posttest still discerned better than control (d = 0.416 vs d = 0.010); study 2 gave evidence that immediate posttests work by strengthening memory of the lesson. Maertens et al. 2025 (five preregistered experiments, N = 11,759): text and video inoculation lasted about a month, games decayed faster, and memory-targeted boosters extended effects.
  - Guess et al. 2020 (preregistered, tips intervention): discernment improved 26.5% in a representative US sample and 17.5% in an educated Indian online sample; measurable weeks later in the US only; no effect in a largely rural northern Indian sample (correction published, not read).
  - Orosz, Faragó, Paskuj, Krekó 2024 (preregistered RCT, N = 1,476 adolescents): immediate d = 0.17, gone after four weeks, except among compliant students high in need for cognition.
  - Rau and Premo 2025 (systematic review of 107 articles on educational interventions) classifies approaches; its abstract reports no pooled effect.
- Education structure: no study was found testing whether how instruction is organized (spaced retrieval, relearning schedules) changes misinformation susceptibility. The closest findings are that rehearsal or an immediate test extends inoculation (Capewell 2024; Maertens 2021, 2025), which matches spacing and testing mechanisms, and that education level did not moderate one uncontrolled game study (Roozenbeek 2019). No inoculation or correction study with children near age 7 was found.
- Citations:
  - Lewandowsky, Ecker, Seifert, Schwarz, Cook (2012). Misinformation and its correction: continued influence and successful debiasing. Psychological Science in the Public Interest 13(3):106-131. doi:10.1177/1529100612451018
  - Walter, Tukachinsky (2020; online 2019). A meta-analytic examination of the continued influence of misinformation in the face of correction. Communication Research 47(2):155-177. doi:10.1177/0093650219854600
  - Chan, Jones, Hall Jamieson, Albarracín (2017). Debunking: a meta-analysis of the psychological efficacy of messages countering misinformation. Psychological Science 28(11):1531-1546. doi:10.1177/0956797617714579
  - Walter, Murphy (2018). How to unring the bell: a meta-analytic approach to correction of misinformation. Communication Monographs 85(3):423-441. doi:10.1080/03637751.2018.1467564
  - Ecker, Hogan, Lewandowsky (2017). Reminders and repetition of misinformation: helping or hindering its retraction? Journal of Applied Research in Memory and Cognition 6(2):185-192. doi:10.1037/h0101809
  - Ecker, Lewandowsky, Chadwick (2020). Can corrections spread misinformation to new audiences? Cognitive Research: Principles and Implications 5. doi:10.1186/s41235-020-00241-6
  - Swire, Ecker, Lewandowsky (2017). The role of familiarity in correcting inaccurate information. JEP: Learning, Memory, and Cognition 43(12):1948-1961. doi:10.1037/xlm0000422
  - Huff, Umanath (2018). Evaluating suggestibility to additive and contradictory misinformation following explicit error detection in younger and older adults. JEP: Applied 24(2):180-195. doi:10.1037/xap0000138
  - Chan, Manley, Lang (2017). Retrieval-enhanced suggestibility: a retrospective and a new investigation. Journal of Applied Research in Memory and Cognition 6(3):213-229. doi:10.1016/j.jarmac.2017.07.003
  - Banas, Rains (2010). A meta-analysis of research on inoculation theory. Communication Monographs 77(3):281-311. doi:10.1080/03637751003758193
  - Lu, Hu, Li, Bi, Ju (2023). Psychological inoculation for credibility assessment, sharing intention, and discernment of misinformation: systematic review and meta-analysis. Journal of Medical Internet Research 25:e49255. doi:10.2196/49255
  - Roozenbeek, van der Linden (2019). Fake news game confers psychological resistance against online misinformation. Palgrave Communications 5. doi:10.1057/s41599-019-0279-9 (correction: doi:10.1057/s41599-019-0294-x, content not read)
  - Roozenbeek, van der Linden, Goldberg, Rathje, Lewandowsky (2022). Psychological inoculation improves resilience against misinformation on social media. Science Advances 8(34). doi:10.1126/sciadv.abo6254
  - Modirrousta-Galian, Higham (2023). Gamified inoculation interventions do not improve discrimination between true and fake news. JEP: General 152(9):2411-2437. doi:10.1037/xge0001395
  - Maertens, Roozenbeek, Basol, van der Linden (2021). Long-term effectiveness of inoculation against misinformation: three longitudinal experiments. JEP: Applied 27(1):1-16. doi:10.1037/xap0000315
  - Capewell, Maertens, Remshard, van der Linden, Compton, Lewandowsky, Roozenbeek (2024). Misinformation interventions decay rapidly without an immediate posttest. Journal of Applied Social Psychology 54(8):441-454. doi:10.1111/jasp.13049
  - Maertens, Roozenbeek, Simons, Lewandowsky, Maturo, Goldberg, Xu, van der Linden (2025). Psychological booster shots targeting memory increase long-term resistance against misinformation. Nature Communications 16. doi:10.1038/s41467-025-57205-x
  - Guess, Lerner, Lyons, Montgomery, Nyhan, Reifler, Sircar (2020). A digital media literacy intervention increases discernment between mainstream and false news in the United States and India. PNAS 117(27):15536-15545. doi:10.1073/pnas.1920498117 (correction: doi:10.1073/pnas.2221752120, content not read)
  - Orosz, Faragó, Paskuj, Krekó (2024). Strategies to combat misinformation: enduring effects of a 15-minute online intervention on critical-thinking adolescents. Computers in Human Behavior 159:108338. doi:10.1016/j.chb.2024.108338
  - Rau, Premo (2025). Systematic review of educational approaches to misinformation. Educational Psychology Review 37(2). doi:10.1007/s10648-025-10012-8

---

## Unverified / not found

- No randomized trial comparing FSRS, SM-2, half-life regression or another fitted scheduler against a fixed schedule on a delayed learning outcome was found. No peer-reviewed FSRS benchmark paper was found; the benchmark numbers come from its repository.
- SM-2 (Woźniak's SuperMemo algorithm): no peer-reviewed primary source located; it is absent from the current benchmark table. Not evaluated.
- Rawson, Dunlosky, Sciartelli 2013 and Pyc and Rawson 2009: effect sizes are not in the abstracts; full texts not retrieved.
- Latimier et al. 2021: abstract not re-retrieved today (OpenAlex and Semantic Scholar returned none); numbers carried from `EVIDENCE_2026-09-28.md`.
- Ecker et al. 2022 (Nature Reviews Psychology, doi:10.1038/s44159-021-00006-y): abstract not retrieved; not used.
- Thomas, Bulevich, Chan 2010 (doi:10.1016/j.jml.2010.04.004) and Wilford, Chan, Tuhn 2014 (doi:10.1037/xap0000001) on retrieval-enhanced suggestibility: located, not read.
- Lindsey et al. 2014: randomization unit and whether review strategies were assigned within student by item were not confirmed beyond "time-matched review strategies".
- Maertens et al. 2025 decay rates by format and the booster schedule used: not in the abstract; full text not read.
- The FSRS workload-vs-retention curve has no numbers in its source; no peer-reviewed study of the workload-retention tradeoff for a fitted scheduler was found.
- No meta-analysis of successive relearning was found. No study of successive relearning or fitted schedulers with children under about 10 was found.
- No study was found on whether education structure (spacing, relearning, retrieval schedules) changes susceptibility to misinformation, or on inoculation or correction with children near age 7.

---

## Design implications

### Findings (directly supported above, with tier)

- F1 (B): The best gap before a review grows with how long the memory must last but falls as a fraction of it, from about 20-40% at 1 week to about 5-10% at 1 year; overshooting costs less than undershooting.
- F2 (B): Retention depends strongly on the number of separate sessions an item appears in, less on repetitions within a session.
- F3 (B): Expanding and uniform schedules give similar delayed retention; expanding keeps recall higher during training and helps after weak initial learning. Delaying the first retrieval helps regardless of shape.
- F4 (B): Successive relearning (to 1 correct in each of several spaced sessions) gives large retention gains for verbal and conceptual material and d = 0.54 to 1.10 on one course's exams; later relearning erases the advantage of a high first-session criterion. Authors' prescription: 3 correct initially, then 3 widely spaced relearning sessions.
- F5 (C): For probability problem procedures, relearning's advantage was small (d = 0.28).
- F6 (B): Fitted models predict next-review recall better than older fixed models (FSRS-7 log loss 0.3401 vs HLR 0.4694), but a simple moving average of recent outcomes comes close (0.3369).
- F7 (C): Model-based review beat fixed spacing on learning in one semester classroom study (10.0%) and one online experiment (about 40% at 3 days).
- F8 (C): In that experiment, reviewing when predicted recall fell to 0.86-0.94 beat 0.40 and 0.98.
- F9 (B): Harder successful retrievals give better later memory.
- F10 (B/C): Retrieving a concept on different examples transfers better than retrieving the same item; testing transfers at d = 0.40, but often not at all without the moderators Pan and Rickard name. Novices may learn better from similar examples first.
- F11 (C): In small child studies, spacing helped memory and generalization; one multi-classroom primary study found no benefit of long-lag repetition or retrieval.
- F12 (A/B): Corrections leave residual belief; corrections that restate the myth, explain the alternative coherently and come promptly work best, and repeating the myth inside a correction did not backfire.
- F13 (B): Inoculation raises discernment modestly (d about 0.20); game effects may be response-bias shifts rather than better discrimination; effects decay over weeks unless rehearsed or tested soon after.

### Inferences for the scheduler and the counterfeit reveal (hypotheses; instrument them)

- I1 Scheduler model: implement the scheduler as a replaceable estimator behind the `scheduler` contract, recorded as `name@version` with parameters, like `mastery-estimate/1`. Start with an FSRS-style model (stability, difficulty, retrievability) with default parameters, and log predicted recall on every review so a moving-average baseline and later models can be scored on the same logs (F6). Do not claim a learning advantage for it; F7 supports model-driven scheduling only at C.
- I2 Target retention default: 0.90 predicted recall, inside the 0.86-0.94 band of F8 and the conventional FSRS default. Treat it as a per-learner experiment arm between about 0.85 and 0.95 and track reviews per day against 30-day checkpoint accuracy. Lower it for the child if session length is the binding limit, with measurement.
- I3 Initial gaps before fitting: use an expanding ladder in days (for example 1, 3, 7, 16, 35) derived from F1 and F3, not a proven sequence. Keep the first gap at a day or more to delay first retrieval (F3, F9). Switch an item to fitted scheduling after enough reviews for per-learner parameters; the threshold is a tunable guess.
- I4 Relearning criterion: in the first session, practice to 2-3 correct recalls; in each later session, to 1 correct, with a missed item repeated in that session after a short delay (F4, Higham 2022 procedure). For procedures (arithmetic, algebra), expect smaller gains (F5) and pair relearning with worked examples. Count sessions per item as a first-class quantity (F2).
- I5 Varied instances: when a solver can generate isomorphic items, review with a new instance by default and keep the exact original item for a fraction of reviews so memory for specific facts is still measured (F10). For a novice or the child, start with near variations and widen surface variety as accuracy rises (Braithwaite and Goldstone). Interleave confusable skills within a review session.
- I6 Measurement checkpoints: 1-, 7- and 30-day checkpoints must use unseen instances, give no feedback until the checkpoint is closed, never update the scheduler's practice state as if they were reviews, and never count as a relearning session. Avoid per-item "will you remember this?" prompts inside practice unless that is the experiment, since such ratings reversed the testing effect in Higham 2023.
- I7 Counterfeit reveal as correction: the reveal should state the planted claim, say plainly that it was false, give the correct answer and a solver-backed reason, and appear at the end of the set with no longer delay (F12). Restating the false verdict inside the reveal is acceptable. Schedule each counterfeited item for a retrieval check on a later day as a normal spaced review, so residual influence is measured and the correction is rehearsed (F13 decay; Capewell 2024).
- I8 Testing BDFN's trainability hypothesis: score scrutiny with signal detection (hits and false alarms per direction), as recommended in `ERRONEOUS_EXAMPLES_2026-09-30.md`, because Modirrousta-Galian and Higham show that "catching more" can be a criterion shift. Evidence that scrutiny is trainable would be rising sensitivity with a stable or falling false-alarm rate across weeks, maintained at a 30-day check without intervening counterfeits. The literature supports trainability only as a small effect that decays unless rehearsed (F13); spaced counterfeit sets act as the rehearsal. Nothing found speaks to a child of 7.
- I9 Risk: retrieval-enhanced suggestibility (Chan 2017) suggests that quizzing an item just before a planted wrong verdict may raise uptake of the false feedback. Keep counterfeits on mastered skills, as designed, and compare residual error on counterfeited items against matched unplanted items at the later check.
