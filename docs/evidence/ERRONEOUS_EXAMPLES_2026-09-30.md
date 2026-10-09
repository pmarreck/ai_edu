# Evidence Review: Erroneous Examples, Unreliable Feedback and Planted Errors 2026-09-30

Policy version: `evidence-policy/1`
Review date: 2026-09-30
Reviewer: Claude (agent), for the planted-counterfeit and scrutiny-axis design in `docs/plan_context/counterfeit_scrutiny.md` ("Evidence check first: erroneous examples, feedback reliability, planted errors").

Design under review: an adult learner is told that some quiz sets contain deliberately planted errors (a correct answer marked wrong, a wrong answer marked right, or a false statement in an explanation), at a variable rate that includes zero per set, always revealed at the end of the set. The learner can say "I think you're wrong" (two scored per set) or "Prove it" (unlimited). Catches score on an informational scrutiny axis, never in mastery.

Method: For each question, searched for meta-analyses and systematic reviews first, then RCTs and controlled experiments. Abstracts were read from primary indexes (OpenAlex, Europe PMC, ERIC API, Semantic Scholar, arXiv API, and one repository page for Bahner et al.). Every DOI below was checked against https://api.crossref.org/works/<doi> for title, authors, year and venue, and for `updated-by` notices; OpenAlex `is_retracted` was checked for all 46 DOIs. No retractions were found; one correction exists (Heemsoth and Heinze, noted in place). A number is recorded only if it appeared in a primary abstract or full text that was retrieved. Items seen only in search-engine summaries are listed under "Unverified / not found".

Full text read: Li et al. 2025 (author PDF, methods and results), Metcalfe and Eich 2019 (PMC6374496, results of Experiments 1-5, skimmed), Jamison, Karlan, Schechter 2008 (abstract and introduction from the author PDF). Everything else is abstract-level.

Limits: No study tests the design as a whole: planted, unflagged errors inside the grading channel of a tutor, disclosed in advance, at a variable rate, with a separate detection score. The closest literatures each match one feature. Erroneous-example studies almost always tell the learner that the example contains an error; the design does not say which item is wrong. Automation-bias studies match the "unreliable authority" feature but use decision tasks, not learning outcomes. The erroneous-example meta-analysis (Alemdağ 2025) full text was blocked, so its moderator results beyond the abstract are unknown. Most erroneous-example trials are with children aged about 9-14 in mathematics; the design targets adults. Several AI-education studies are 2025-2026 preprints.

Tier key (meta-prompt 2.2): A high confidence, B moderate with boundary conditions, C promising/experimental, D unsupported/disfavored.

---

## 1. Erroneous examples (find, explain and fix errors in worked solutions)

- Tier: B for a small positive effect over correct examples or problem solving, conditional on error-explanation support. C for a delayed-test advantage (one replicated pair of studies). Prior-knowledge moderation is contested (C).
- Population: mostly grades 4-8 mathematics; some university students (probability, Große and Renkl) and adults in other domains.
- Outcomes: procedural and conceptual knowledge, immediate and one-week delayed tests, far transfer in one study.
- Effect sizes seen: Alemdağ, Eichelmann, Narciss 2025 (42 papers, 177 effect sizes, robust variance estimation): g = .136 overall. Self-explanation prompts or instructional explanations of the error improved learning from erroneous examples more than no error explanation. McLaren, Adams, Mayer 2015 (N = 390 middle-school students, replication of Adams et al. 2014 with 208): no difference on the immediate post-test; erroneous-example group better on a test one week later, d = .33 for gain scores. The problem-solving group liked the intervention more (d = .21) and found the interface easier (d = .37).
- Moderators, with conflicting results on prior knowledge:
  - Große and Renkl 2007 (university, probability, two experiments): mixed correct and incorrect solutions improved far transfer only for learners with good prior knowledge; learners with poor prior knowledge did better with correct solutions only. Incorrect solutions reduced principle-based self-explanations. The design crossed highlighted vs unhighlighted errors; the abstract does not report that factor's effect.
  - Heemsoth and Heinze 2013 (N = 195 grade 6, fractions, field experiment): only advanced students gained from incorrect examples; low-prior-knowledge students learned more from correct ones. (Correction published: doi:10.1007/s11251-014-9313-x, content not read.)
  - Durkin and Rittle-Johnson 2012 (N = 74 grades 4-5, decimals): comparing incorrect with correct examples beat comparing two correct examples on procedures and concepts, with no prior-knowledge interaction.
  - Barbieri and Booth 2016 (N = 125 middle school, algebra): low-prior-knowledge students benefited most from reflecting on highlighted errors.
  - Booth et al. 2013 (two in vivo Cognitive Tutor experiments): incorrect examples, alone or combined with correct ones, helped conceptual understanding most.
- Affect: Richey et al. 2019 (reanalysis of the McLaren data) found erroneous examples produced more confusion and frustration; that affect was negatively correlated with post-test and delayed scores in both conditions, less so for erroneous examples. The authors conclude students learned despite the confusion, not because of it.
- Memory cost: Pillai et al. 2020 (undergraduates, two experiments): studied incorrect examples were rated slightly more correct a week later, but this did not spread to unstudied examples or problem solving.
- Comparison with generating errors oneself: Wong 2023 (three experiments, N = 120 undergraduates): deliberately generating and correcting one's own errors improved far transfer more than spotting and correcting the same errors made by peers. Wong 2025 (N = 208) and Qiang and Ma 2026 (N = 96 and 103) report related "deliberate erring" benefits; learners underrated the method in all three.
- Uncertainty: moderate for direction, high for size in adults. The pooled effect is small.
- Differs from prior: the design doc assumes erroneous examples support planting. They do, weakly, and mainly when the error is explained afterwards. The studies flag that an error exists; they do not test errors hidden in the grader.
- Citations:
  - Alemdağ, Eichelmann, Narciss (2025). A framework for learning from erroneous examples and meta-analysis of empirical research. Review of Educational Research. doi:10.3102/00346543251390901
  - Große, Renkl (2007). Finding and fixing errors in worked examples: can this foster learning outcomes? Learning and Instruction 17(6):612-634. doi:10.1016/j.learninstruc.2007.09.008 (abstract via ERIC EJ780439)
  - Durkin, Rittle-Johnson (2012). The effectiveness of using incorrect examples to support learning about decimal magnitude. Learning and Instruction 22(3):206-214. doi:10.1016/j.learninstruc.2011.11.001
  - Booth, Lange, Koedinger, Newton (2013). Using example problems to improve student learning in algebra. Learning and Instruction 25:24-34. doi:10.1016/j.learninstruc.2012.11.002
  - Heemsoth, Heinze (2013). The impact of incorrect examples on learning fractions. Instructional Science 42(4):639-657. doi:10.1007/s11251-013-9302-5
  - Barbieri, Booth (2016). Support for struggling students in algebra: contributions of incorrect worked examples. Learning and Individual Differences 48:36-44. doi:10.1016/j.lindif.2016.04.001
  - Adams, McLaren, Durkin, Mayer, Rittle-Johnson, Isotani, van Velsen (2014). Using erroneous examples to improve mathematics learning with a web-based tutoring system. Computers in Human Behavior 36:401-411. doi:10.1016/j.chb.2014.03.053 (abstract not retrieved; described only through McLaren 2015)
  - McLaren, Adams, Mayer (2015). Delayed learning effects with erroneous examples. International Journal of Artificial Intelligence in Education 25(4):520-542. doi:10.1007/s40593-015-0064-x
  - Richey et al. (2019). More confusion and frustration, better learning: the impact of erroneous examples. Computers and Education 139:173-190. doi:10.1016/j.compedu.2019.05.012
  - Pillai, Loehr, Yeo, Hong, Fazio (2020). Are there costs to using incorrect worked examples in mathematics education? Journal of Applied Research in Memory and Cognition 9(4):519-531. doi:10.1016/j.jarmac.2020.06.007
  - Wong (2023). Deliberate erring improves far transfer of learning more than errorless elaboration and spotting and correcting others' errors. Educational Psychology Review 35. doi:10.1007/s10648-023-09739-z
  - Wong (2025). Learning by teaching with deliberate errors promotes argumentative reasoning. Journal of Educational Psychology 117(7):1013-1038. doi:10.1037/edu0000934
  - Qiang, Ma (2026). The advantages of deliberate errors in promoting college students' memory retention and transfer. British Journal of Educational Psychology 96(2):922-944. doi:10.1111/bjep.70058

## 2. Wrong feedback and trust in a feedback source

### 2a. What false or misleading feedback does to memory

- Tier: B that false feedback and uncorrected exposure to wrong answers cause some later errors; B that corrective feedback, including delayed feedback, reduces that harm.
- Findings:
  - Metcalfe and Eich 2019 (five experiments, general-knowledge questions): when false feedback followed an initially correct answer, participants did not encode it the way they encode corrections to their errors, and often reverted to their original correct answer on the final test. There was still a cost: in Experiment 1, final factually correct performance on initially correct items declined by 40% as a function of false feedback (full text), and in a later experiment recall was higher after true than false feedback on initially correct items. When false feedback followed an error, participants were susceptible to it. Telling people whether the feedback was right or wrong made little difference.
  - Roediger and Marsh 2005: reading more multiple-choice lures without feedback increased production of those lures as wrong answers on a later test. Butler and Roediger 2008: immediate and delayed feedback both raised later correct responses and reduced lure intrusions.
  - Fazio, Huelser, Johnson, Marsh 2010: bare right/wrong feedback did not aid error correction; it helped retention of low-confidence correct answers only. Being told the answer or reviewing material was far more useful.
  - Metcalfe 2017 (review): errors followed by corrective feedback can benefit learning; high-confidence errors are corrected more readily. Metcalfe et al. 2024 (two cohorts of about 88 students, Algebra 1 Regents preparation): a learning-from-errors condition produced a higher rate of learning per unit of teacher time than explicit instruction, inconsistently across teachers.
- Uncertainty: moderate. General-knowledge and prose studies; none used a disclosed-planting rule.

### 2b. Unreliable decision aids: reliance, complacency and trust after errors

- Tier: B that aid reliability strongly determines whether an aid helps; B that seeing an aid err lowers later use of it; C that exposing people to aid failures during training reduces complacency.
- Findings:
  - Wickens and Dixon 2007 (20 studies, 35 data points): benefit rose linearly with aid reliability; below a reliability of 0.70, unreliable automation was worse than none.
  - Parasuraman and Manzey 2010 (review): automation bias produces omission and commission errors with imperfect aids, occurs in naive and expert users, and "cannot be prevented by training or instructions".
  - Goddard, Roudsari, Wyatt 2012 (74 studies): mitigators included training, emphasizing user accountability, and displaying updated confidence levels with the aid's output.
  - Bahner, Hüper, Manzey 2008 (lab, N = 24, process control): exposing operators to automation failures during training significantly decreased complacency (less verification-skipping), though it did not remove it.
  - Dietvorst, Simmons, Massey 2015 (5 studies): people who saw an algorithm make forecasts lost confidence in it faster than in a human making the same mistakes, and chose it less often even when they had seen it outperform the human.
- Uncertainty: moderate. Decision and monitoring tasks with adults; learning outcomes not measured.
- Differs from prior: the design assumes disclosure keeps trust intact. Dietvorst suggests visible errors lower later reliance on an otherwise accurate source; the scrutiny design deliberately makes errors visible. Bahner is the one result pointing the other way (fewer unchecked acceptances after experienced failures), and it has N = 24.
- Citations:
  - Metcalfe, Eich (2019). Memory and truth: correcting errors with true feedback versus overwriting correct answers with errors. Cognitive Research: Principles and Implications 4. doi:10.1186/s41235-019-0153-8
  - Roediger, Marsh (2005). The positive and negative consequences of multiple-choice testing. JEP: Learning, Memory, and Cognition 31(5):1155-1159. doi:10.1037/0278-7393.31.5.1155
  - Butler, Roediger (2008). Feedback enhances the positive effects and reduces the negative effects of multiple-choice testing. Memory and Cognition 36(3):604-616. doi:10.3758/mc.36.3.604
  - Fazio, Huelser, Johnson, Marsh (2010). Receiving right/wrong feedback: consequences for learning. Memory 18(3):335-350. doi:10.1080/09658211003652491
  - Metcalfe (2017). Learning from errors. Annual Review of Psychology 68:465-489. doi:10.1146/annurev-psych-010416-044022 (abstract via ERIC ED574569)
  - Metcalfe, Xu, Vuorre, Siegler, Wiliam, Bjork (2024). Learning from errors versus explicit instruction in preparation for a test that counts. British Journal of Educational Psychology 95(1):11-25. doi:10.1111/bjep.12651
  - Wickens, Dixon (2007). The benefits of imperfect diagnostic automation: a synthesis of the literature. Theoretical Issues in Ergonomics Science 8(3):201-212. doi:10.1080/14639220500370105
  - Parasuraman, Manzey (2010). Complacency and bias in human use of automation. Human Factors 52(3):381-410. doi:10.1177/0018720810376055
  - Goddard, Roudsari, Wyatt (2012). Automation bias: a systematic review. JAMIA 19(1):121-127. doi:10.1136/amiajnl-2011-000089
  - Bahner, Hüper, Manzey (2008). Misuse of automated decision aids: complacency, automation bias and the impact of training experience. International Journal of Human-Computer Studies 66(9):688-699. doi:10.1016/j.ijhcs.2008.06.001 (abstract via commons.wmu.se)
  - Dietvorst, Simmons, Massey (2015). Algorithm aversion: people erroneously avoid algorithms after seeing them err. JEP: General 144(1):114-126. doi:10.1037/xge0000033

## 3. Detecting errors in AI output; warnings; target prevalence

- Tier: B that people over-rely on wrong AI output and detect few of its errors; C that per-item cues (uncertainty wording, highlighting, forcing functions) reduce over-reliance; C/D that a general up-front warning alone improves detection; B that rare targets are missed more often.
- Findings:
  - Vaccaro, Almaatouq, Malone 2024 (preregistered, 106 experiments, 370 effect sizes): human-AI combinations did worse than the best of humans or AI alone, g = -0.23 [-0.39, -0.07]; losses when the AI outperformed humans alone.
  - Li, Song, Sundaram, Karahalios 2025 (quasi-experiment, 177 adult online learners plus 26 interviewees, STEM topics; full text): participants were told the chatbot "may make mistakes" and paid $0.20 per report, yet identified 19.77% and 24.62% of planted factual errors (with and without a logical fallacy). An undetected relevant error cut practice accuracy sharply (odds ratio about 0.18); direct feedback on practice removed or shrank that harm; learners who detected and reported errors were not harmed on the post-test. Lower prior knowledge made detection harder. One interviewee, after seeing an error, began reporting correct responses too.
  - Teng et al. 2026 (randomized, N = 111 novice medical students, registered ChiCTR2500111932): misleading AI explanations lowered diagnostic accuracy; correct explanations gave no significant gain over no explanation; confidence did not separate right from wrong answers.
  - Si et al. 2024 (80 crowdworkers): LLM explanations made fact-checking faster at similar accuracy but led to over-reliance when wrong; showing arguments for both true and false reduced over-reliance.
  - Kim et al. 2024 (preregistered, N = 404): first-person uncertainty wording ("I'm not sure, but...") lowered agreement with the system and raised accuracy, with over-reliance reduced but not eliminated; general-perspective wording had weaker, nonsignificant effects.
  - Spatharioti et al. (arXiv 2023; published CHI 2025): confidence-based color highlighting substantially raised the rate at which users spotted incorrect LLM information.
  - Buçinca, Malaya, Gajos 2021 (N = 199): cognitive forcing designs reduced over-reliance compared with simple explanations; participants rated the most effective designs least favorably; benefits were larger for people high in need for cognition. Vasconcelos et al. 2023 (5 studies, N = 731): over-reliance fell when explanations lowered the cost of verifying the AI.
  - Nagashima, Hladký, Rief 2026 (preprint, 252 school students, math tutor with no actual errors): a warning that the agent may make mistakes increased hint requests without improving or impairing immediate performance.
  - Weijers et al. 2025 (preprint, N = 165): students told an AI "Peer" could be wrong on up to 40% of questions scored 10.5 percentage points higher on a post-test than a control that discussed physics history. The control differs in content, so the effect of the warning or of the errors is not isolated.
  - Wolfe et al. 2007: miss rates were much higher at 1-2% target prevalence than at 50%. The effect was a criterion shift, not a sensitivity loss; exhortations to change criterion failed; brief retraining blocks at high prevalence with full feedback let observers hold a better criterion at low prevalence.
  - Marsh and Fazio 2006: warnings about errors in fiction did not reduce later reliance on those errors; pressing a key each time an error was detected reduced but did not eliminate it.
- Uncertainty: moderate for over-reliance; high for any training effect on detection, since no study found trains error detection and then tests unwarned detection later.
- Differs from prior: the design expects disclosure plus a reward to produce scrutiny. Li 2025 had both and saw roughly one in five errors caught. Per-item prompts had more support than a general warning.
- Citations:
  - Vaccaro, Almaatouq, Malone (2024). When combinations of humans and AI are useful. Nature Human Behaviour 8(12):2293-2303. doi:10.1038/s41562-024-02024-1
  - Li, Song, Sundaram, Karahalios (2025). Can learners navigate imperfect generative pedagogical chatbots? L@S '25:151-163. doi:10.1145/3698205.3729550
  - Teng, Tan, Cao, Xia, Zhang, Li, Zhao (2026). Impact of AI misinformation on diagnostic accuracy and confidence calibration in novice medical students. npj Digital Medicine 9. doi:10.1038/s41746-026-02547-z
  - Si et al. (2024). Large language models help humans verify truthfulness, except when they are convincingly wrong. NAACL 2024:1459-1474. doi:10.18653/v1/2024.naacl-long.81 (abstract via arXiv:2310.12558)
  - Kim, Liao, Vorvoreanu, Ballard, Vaughan (2024). "I'm not sure, but...". FAccT 2024:822-835. doi:10.1145/3630106.3658941 (abstract via arXiv:2405.00623)
  - Spatharioti, Rothschild, Goldstein, Hofman (2025). Effects of LLM-based search on decision making. CHI 2025. doi:10.1145/3706598.3714082 (abstract read from arXiv:2307.03744, an earlier version)
  - Buçinca, Malaya, Gajos (2021). To trust or to think. PACM HCI 5(CSCW1). doi:10.1145/3449287 (abstract via arXiv:2102.09692)
  - Vasconcelos et al. (2023). Explanations can reduce overreliance on AI systems during decision-making. PACM HCI 7(CSCW1). doi:10.1145/3579605 (abstract via arXiv:2212.06823)
  - Nagashima, Hladký, Rief (2026, preprint). Warning about AI fallibility increases help-seeking in an intelligent tutoring system. arXiv:2606.03822
  - Weijers et al. (2025, preprint). From intuition to understanding: using AI peers to overcome physics misconceptions. arXiv:2504.00408
  - Wolfe, Horowitz, Van Wert, Kenner, Place, Kibbi (2007). Low target prevalence is a stubborn source of errors in visual search tasks. JEP: General 136(4):623-638. doi:10.1037/0096-3445.136.4.623
  - Marsh, Fazio (2006). Learning errors from fiction. Memory and Cognition 34(5):1140-1149. doi:10.3758/bf03193260

## 4. Planted falsehoods and correction: continued influence

This question was not asked, but it bears directly on the "false statement in an explanation" counterfeit.

- Tier: A/B that corrections reduce but rarely erase misinformation; B that knowing the truth does not fully protect against repeated false statements.
- Findings: Chan et al. 2017 (k = 52, N = 6,878): large effects for presenting misinformation (d = 2.41-3.08) and debunking (d = 1.14-1.33), with persistence after debunking (d = 0.75-1.06); persistence was stronger when audiences generated reasons supporting the misinformation. Walter and Tukachinsky 2019 (32 studies, N = 6,527): correction does not entirely remove the effect (r = -.05); corrections work better from the original source and worse after a time lag or repetition. Fazio et al. 2015: illusory truth effects occurred even when participants knew the correct answer.
- Citations:
  - Chan, Jones, Hall Jamieson, Albarracín (2017). Debunking: a meta-analysis. Psychological Science 28(11):1531-1546. doi:10.1177/0956797617714579
  - Walter, Tukachinsky (2019). A meta-analytic examination of the continued influence of misinformation in the face of correction. Communication Research 47(2):155-177. doi:10.1177/0093650219854600
  - Fazio, Brashier, Payne, Marsh (2015). Knowledge does not protect against illusory truth. JEP: General 144(5):993-1002. doi:10.1037/xge0000098

## 5. Variable or unpredictable reinforcement in learning tasks

- Tier: D for any learning benefit (no evidence found). C for short-term engagement.
- Findings: the evidence is mostly animal and laboratory operant work (partial-reinforcement extinction, which concerns persistence of a response, not learning of content). The one educational line found is Howard-Jones and Demetriou 2008: children aged 10-11 preferred a chance-based reward option in a maths quiz, and adults' electrodermal activity rose when dice were added; no learning outcome was measured.
- Differs from prior: the variable planting rate is justified as unpredictability for scrutiny, not as reinforcement. No evidence supports it as a motivational schedule.
- Citation: Howard-Jones, Demetriou (2008). Uncertainty and engagement with learning games. Instructional Science 37(6):519-536. doi:10.1007/s11251-008-9073-6

## 6. Learner-generated "why" questions and requested explanations

- Tier: B/C for elaborative interrogation (Dunlosky 2013: moderate utility, not adequately evaluated in educational contexts). B for teaching students to generate questions for reading comprehension. C for requested instructional explanations as a learning technique.
- Findings: Rosenshine, Meister, Chapman 1996: teaching question generation produced comprehension gains. Clinton, Alibali, Nathan 2015 (N = 198 undergraduates, posterior probability): elaborative interrogation hurt learning relative to reading twice, possibly because answers were poor. Wittwer and Renkl 2010 (21 studies): instructional explanations add little to example-based learning, more for conceptual than procedural knowledge, and are not better than self-explaining.
- Differs from prior: "Prove it" asks the system to explain, so the learner receives an instructional explanation rather than generating one. The evidence for elaborative interrogation does not transfer to it directly.
- Citations:
  - Dunlosky, Rawson, Marsh, Nathan, Willingham (2013). Psychological Science in the Public Interest 14(1):4-58. doi:10.1177/1529100612453266
  - Rosenshine, Meister, Chapman (1996). Teaching students to generate questions. Review of Educational Research 66(2):181-221. doi:10.3102/00346543066002181 (abstract via ERIC EJ533506)
  - Clinton, Alibali, Nathan (2015). Learning about posterior probability: do diagrams and elaborative interrogation help? Journal of Experimental Education 84(3):579-599. doi:10.1080/00220973.2015.1048847
  - Wittwer, Renkl (2010). How effective are instructional explanations in example-based learning? Educational Psychology Review 22(4):393-409. doi:10.1007/s10648-010-9136-5 (abstract via ERIC EJ906661)

## 7. Deception in research designs and participant trust

- Tier: C. Empirical, but about undisclosed deception in lab studies, not a disclosed rule in instruction.
- Findings: Jamison, Karlan, Schechter 2008 deceived some participants, told them afterwards, and found significant differences in who returned for a later study and, to a lesser extent, in behavior in later games. Ortmann and Hertwig 2002 (systematic review): having been deceived generates suspicion that likely affects the judgments of a non-negligible number of participants; little evidence of reputational spillover to other experimenters.
- Citations:
  - Jamison, Karlan, Schechter (2008). To deceive or not to deceive. Journal of Economic Behavior and Organization 68(3-4):477-488. doi:10.1016/j.jebo.2008.09.002
  - Ortmann, Hertwig (2002). The costs of deception: evidence from psychology. Experimental Economics 5(2):111-131. doi:10.1023/a:1020365204768
  - Hertwig, Ortmann (2008). Deception in experiments: revisiting the arguments in its defense. Ethics and Behavior 18(1):59-92. doi:10.1080/10508420701712990 (abstract states it reviews empirical studies; conclusions not in the abstract)

---

## Differences from design assumptions

1. The erroneous-example benefit is small (g = .136) and depends on explaining the error. The design's end-of-set reveal must include an explanation of each counterfeit, not only a label.
2. No study places unflagged errors in a tutor's grading channel. The nearest evidence (automation bias, algorithm aversion) warns that visible errors lower reliance on the source, which the design must measure rather than assume away.
3. Disclosure plus reward did not produce good detection of real chatbot errors (about 20% caught in Li 2025). Scrutiny scores will likely start low.
4. False statements in explanations carry the best-documented risk: corrections leave residual belief, and belief persists more when the learner has reasoned from the false claim.
5. Variable planting has no support as a reinforcement schedule. Its justification is keeping detection from being predictable.
6. "Prove it" returns an explanation; evidence for learner-generated questions does not carry over.

## Unverified / not found

- Adams et al. 2014 abstract: not retrieved from any index; described only through the McLaren 2015 replication abstract.
- Große and Renkl 2007: the effect of highlighting vs not highlighting errors is not in the abstract; full text not retrieved. Whether flagged or must-find errors work better is therefore unverified.
- Alemdağ et al. 2025 moderators for prior knowledge, age, delay, transfer and error flagging: publisher full text returned HTTP 403.
- Heemsoth and Heinze correction (doi:10.1007/s11251-014-9313-x): exists, content not read.
- Özçelik, Çağıltay, Özçelik (2013). The effect of uncertainty on learning in game-like environments. Computers and Education. doi:10.1016/j.compedu.2013.02.009: abstract not retrieved; not used.
- Dzindolet et al. (2003). The role of trust in automation reliance. doi:10.1016/s1071-5819(03)00038-7: abstract not retrieved; its reported finding that explaining why an aid errs raises trust is from memory and not used.
- Wolfe, Horowitz, Kenner 2005 (Nature, doi:10.1038/435439a): abstract read; miss-rate numbers not retrieved.
- Tsovaltzi et al. 2010 and Isotani et al. 2011 (erroneous examples, EC-TEL): located, not read.
- Hosseini 2026 (arXiv:2605.05472), a design study using AI mistakes in a database course: abstract read; no comparative outcome reported; not used.
- Schaefer et al. 2016 trust-in-automation meta-analysis (doi:10.1177/0018720816634228): abstract read; it pools factors affecting trust and does not isolate aid errors; not used.
- No meta-analysis was found on deliberately incorrect feedback in instruction, on training people to detect AI errors with delayed unwarned tests, or on variable-ratio schedules in academic learning.
- No study was found that discloses planted errors in advance and then measures trust in the tutor's later correct feedback.

---

## Design implications

### Findings (directly supported above, with tier)

- F1 (B): Erroneous examples give a small learning gain (g = .136), larger when the error is explained by the learner or instructor.
- F2 (C): In two middle-school decimal studies, the erroneous-example advantage appeared only on a one-week delayed test (d = .33), while learners liked the method less.
- F3 (C): Prior-knowledge moderation conflicts: two studies favor higher-prior-knowledge learners, one finds no interaction, one favors low prior knowledge with highlighted errors.
- F4 (B): False feedback after a correct answer reduced later correct recall (a 40% decline in one experiment) even though people often reverted to their correct answer; after an error, people accepted false feedback readily.
- F5 (B): Exposure to wrong answers without correction produces later errors; immediate or delayed correct feedback reduces this.
- F6 (B): Aids below about 0.70 reliability did worse than no aid; seeing an algorithm err lowered later use of it even when it was better than the alternative.
- F7 (C): Experiencing aid failures in training reduced complacency (N = 24).
- F8 (B/C): Adults told a chatbot may err caught about 20% of its factual errors; undetected errors harmed learning; detected ones did not.
- F9 (B): Rare targets are missed far more often (1-2% vs 50% prevalence), through criterion shift; periodic high-prevalence blocks with full feedback helped.
- F10 (A/B): Corrections leave residual belief in misinformation, more so when the audience generated supporting reasons or after a delay.
- F11 (C): Spotting others' errors helped far transfer less than generating and correcting one's own errors.
- F12 (D): No evidence that variable reinforcement improves learning.

### Inferences for the planted-counterfeit design (hypotheses; instrument them)

- I1: Planting rate. No study sets one. Two constraints bound it. F9 argues against very rare plants, since detection criteria drift at low prevalence. F6 argues for keeping the tutor's overall feedback reliability high. A per-set rate of 0, 1 or occasionally 2 over about 10 items gives roughly 90% item-level reliability, well above the 0.70 crossover. This is a guess derived from those two findings. Treat rate as the A/B arm, as planned, with at least a "none" arm and one low and one moderate arm.
- I2: Direction. "Correct marked wrong" (F4: learners often keep their answer) is the least harmful direction and the one a confident learner can challenge. "Wrong marked right" confirms a learner's own error, the condition in which F4 and F5 show the most uptake of false information; keep it rare, reveal it with the correct answer, or drop it from the first arm. The design already restricts counterfeits to mastered skills (F3, F8: lower prior knowledge, worse detection).
- I3: False statements in explanations are the riskiest counterfeit (F10). If kept, reveal each one explicitly with the correct statement and its reason, reveal at the end of the set rather than later, never repeat the false statement in the reveal more than once, and exclude such items from later review queues. Consider leaving this kind out of the first A/B arm.
- I4: The reveal is the corrective feedback that makes erroneous examples work (F1, F5). Show the correct answer and a brief explanation for every counterfeit, whether caught or missed.
- I5: Score scrutiny as signal detection: log hits, misses, false alarms and correct acceptances per direction, and report sensitivity and criterion separately (F9 shows prevalence moves criterion, not sensitivity). A raw hit count will rise with the planting rate alone.
- I6: Measure trust directly. After the reveal, track challenge rate on unplanted items and acceptance of genuine feedback over sessions; a rising false-alarm rate or ignored correct feedback is the harm F6 predicts. Add a no-counterfeit control and compare delayed retention, as planned, plus a delayed unwarned detection probe to test whether any scrutiny transfers.
- I7: "Prove it" delivers an instructional explanation (section 6). Its value is informational; do not count it as evidence of elaboration. Consider a variant that asks the learner to state why before the system answers.
- I8: Expect low initial detection (F8) and some frustration (Richey 2019, McLaren 2015 liking results). Keep the axis informational, as designed, and do not attach mastery or rewards to it.
- I9: Periodic higher-rate "calibration" sets with full feedback may keep the learner's detection criterion from drifting (F9). This is untested in learning settings.

Risks that argue against the design: residual belief in planted falsehoods (F10); lower trust in and use of the tutor's genuine feedback after visible errors (F6); cost to later recall even when the learner was right (F4); a small expected learning benefit (F1) that the erroneous-example literature obtained with flagged errors and explanations, not hidden ones; and the finding that spotting others' errors is weaker than generating one's own (F11).
