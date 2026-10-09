# Evidence Review: Games, Gamification and Typing 2026-09-28

Policy version: `evidence-policy/1`
Review date: 2026-09-28
Reviewer: Claude (agent), for PLAN items "Game-mode lessons (answer to act, e.g. Missile Command style), pending evidence review" and "Typing tutor as its own lesson type, pending evidence review", and meta-prompt section 1.4 ("Gamification is a tool, not a religion").

Learner context: two learners. (1) An adult (the maintainer, dogfooding). (2) A young child, not yet reading, with full use expected once reading unlocks it. The maintainer's question: what does the data say about gamified lessons where correct answers act inside a game (type the right answer to target a missile), and about typing tutors?

Method: For each topic, searched for meta-analyses and systematic reviews first, then RCTs and controlled experiments. Abstracts were read from primary indexes (Crossref, OpenAlex, ERIC API, Europe PMC, Semantic Scholar). Every DOI below was checked against https://api.crossref.org/works/<doi> for title, authors, year and venue, and for Crossref `updated-by` notices (retraction, correction, erratum); OpenAlex `is_retracted` was checked for the same DOIs. No retractions were found; one erratum is noted (Hanus and Fox 2015). A number is recorded only if it appeared in a primary abstract or full text that was retrieved. Items seen only in snippets or secondary sources are listed under "Unverified / not found".

Full text read: Clark, Tanner-Smith, Killingsworth 2016 (PMC4748544, Tables 2-3 and moderator sections), Alotaibi 2024 (PMC11018941, results section), Kiefer et al. 2015 (PMC4710970, methods). Everything else is abstract-level.

Limits: Most game and gamification studies are with adolescents and undergraduates (average participant age 13.4 in Clark 2016). Studies of 5-year-olds are few and mostly app studies, not games with a separate play mechanic. Moderator results in meta-analyses are between-study comparisons and are confounded. Newer gamification meta-analyses report larger pooled effects than older ones with no clear reason; that pattern is a warning sign, not evidence that gamification has improved. Typing research is thin: much of it is unpublished ERIC reports, quasi-experiments without random assignment, or pre-post designs without a control group.

Tier key (meta-prompt 2.2): A high confidence, B moderate with boundary conditions, C promising/experimental, D unsupported/disfavored.

---

## 1. Gamification (game elements added to instruction)

- Tier: B for a small-to-moderate positive effect on short-term cognitive outcomes, with large heterogeneity. C for motivational and behavioral outcomes (less stable under rigorous designs). C for any claim about specific elements.
- Population: mostly higher education; K-12 represented; no synthesis restricted to young children found.
- Outcomes: course or test performance, self-reported motivation, behavior (attempts, usage), nearly all measured during or right after the intervention.
- Effect sizes seen:
  - Sailer and Homner (random effects): cognitive g = .49 [0.30, 0.69], k = 19, N = 1,686; motivational g = .36 [0.18, 0.54], k = 16; behavioral g = .25 [0.04, 0.46], k = 9. The cognitive effect held in a high-rigor subsplit; the motivational and behavioral effects were less stable.
  - Huang et al. 2020: 30 studies, N = 3,083, g = 0.464 [0.244, 0.684]; 14 gamification elements examined, each with different effects (values not in abstract).
  - Bai, Hew, Huang 2020: 30 interventions from 24 studies, 3,202 participants, g = 0.504 [0.284, 0.723].
  - Li, Ma, Shi 2023: 41 studies, 49 samples, more than 5,071 participants, g = 0.822 [0.567, 1.078]; moderators included user type, discipline, design principles, duration of the "gameful" experience and learning environment.
  - Zeng et al. 2024: 22 experimental studies, g = 0.782.
- Moderators: game fiction and social interaction moderated behavioral outcomes; combining competition with collaboration was particularly effective for behavioral outcomes (Sailer and Homner). In an RCT with an online simulation, badges, leaderboards and performance graphs raised competence-need satisfaction and perceived task meaningfulness; avatars, stories and teammates raised social relatedness; perceived decision freedom did not change (Sailer et al. 2017).
- Novelty: Rodrigues et al. 2022 (quasi-experiment, N = 756 Brazilian CS1 students, 14 weeks, behavioral measures): the gamified version's effect began falling after four weeks, stayed down for two to six weeks, then partly recovered between weeks six and ten. One study, one population, behavioral measures only.
- Uncertainty: moderate for direction on immediate cognitive outcomes; high for size. The pooled g roughly doubles from the 2019-2020 syntheses (about 0.46-0.50) to the 2023-2024 ones (about 0.78-0.82).
- Differs from prior: consistent with "gamification is a tool, not a religion". Adds: effects are measured almost entirely on immediate outcomes, and motivational gains are the least stable part.
- Citations:
  - Sailer, Homner (2019). The gamification of learning: a meta-analysis. Educational Psychology Review. doi:10.1007/s10648-019-09498-w
  - Huang, Ritzhaupt, Sommer, Zhu, Stephen, Valle, Hampton, Li (2020). The impact of gamification in educational settings on student learning outcomes: a meta-analysis. Educational Technology Research and Development 68(4):1875-1901. doi:10.1007/s11423-020-09807-z (abstract via ERIC EJ1266144)
  - Bai, Hew, Huang (2020). Does gamification improve student learning outcome? Educational Research Review 30:100322. doi:10.1016/j.edurev.2020.100322
  - Li, Ma, Shi (2023). Examining the effectiveness of gamification as a tool promoting teaching and learning in educational settings: a meta-analysis. Frontiers in Psychology 14. doi:10.3389/fpsyg.2023.1253549
  - Zeng, Sun, Looi, Fan (2024). Exploring the impact of gamification on students' academic performance: a comprehensive meta-analysis of studies from the year 2008 to 2023. British Journal of Educational Technology 55(6):2478-2502. doi:10.1111/bjet.13471
  - Sailer, Hense, Mayr, Mandl (2017). How gamification motivates: an experimental study of the effects of specific game design elements on psychological need satisfaction. Computers in Human Behavior 69:371-380. doi:10.1016/j.chb.2016.12.033
  - Rodrigues et al. (2022). Gamification suffers from the novelty effect but benefits from the familiarization effect. International Journal of Educational Technology in Higher Education 19(1). doi:10.1186/s41239-021-00314-6

## 2. Digital game-based learning (learning happens inside a game) vs conventional instruction

- Tier: B for a small positive effect over nongame instruction, conditional on multiple sessions. C for children under about 7 (app evidence is positive; game evidence is thin and one meta-analysis is low quality).
- Population: K-16 (Clark 2016, average age 13.4, range 5-21); adult trainees (Sitzmann 2011); PreK-12 math (Tokac 2019).
- Effect sizes seen:
  - Clark, Tanner-Smith, Killingsworth 2016 (full text): games vs nongame g = 0.33 [0.19, 0.48], k = 57; augmented vs standard game designs g = 0.34 [0.17, 0.51], k = 20.
  - Wouters et al. 2013: learning d = 0.29 (k = 77, N = 5,547), retention d = 0.36; games were not more motivating than conventional instruction (d = 0.26, p > .05, k = 31).
  - Sitzmann 2011 (k = 65, N = 6,476, simulation games in training): declarative knowledge 11% higher, procedural 14% higher, retention 9% higher, with "strong evidence of publication bias".
  - Wouters and van Oostendorp 2013: adding instructional support inside games d = 0.34 (k = 107); journal studies d = 0.44 vs proceedings 0.08 and unpublished 0.14, a publication-bias signal.
  - Wang et al. 2022 (STEM, 33 studies, N = 3,894): ES = 0.667 [0.520, 0.814].
  - Tokac, Novak, Thompson 2019 (24 studies, PreK-12 math): "small but marginally significant" effect; value not in the abstract as retrieved.
- Moderators (Clark 2016 full text unless noted):
  - Sessions: single session g = 0.08 [-0.24, 0.39] vs multiple sessions 0.44 [0.29, 0.59]; significant difference. Wouters 2013 also found multiple sessions better. Total play time (mean 347 minutes over 11 sessions and 38 days) was not associated with effect size.
  - Player structure: single player without competition g = 0.45 [0.29, 0.61], k = 44; single player with competition -0.06 [-0.61, 0.48], k = 4; collaborative team competition 0.22, k = 3. Single noncompetitive play beat single competitive play after controlling for other game features. Small k in the competitive cells.
  - Visual realism: schematic 0.48, cartoon 0.32, realistic -0.01; the schematic-realistic difference became marginal after controls. A composite "contextualization" score (realism, anthropomorphism, story depth) had a small negative relation with learning.
  - Scaffolding: success/fail/points only 0.26; enhanced scaffolding 0.48; teacher-provided 0.58.
  - Design: quasi-experiments showed larger effects than RCTs.
  - Sitzmann 2011: games helped more as a supplement than as stand-alone instruction, and did worse than comparison methods that were themselves active. Vogel et al. 2006: when the computer dictated the sequence, results favored traditional teaching.
- Young children:
  - Alotaibi 2024 (full text): reports 136 studies and 1,426 participants with a median sample of 40, which cannot both be true (136 x 40 is far above 1,426); pooled cognitive g = 0.46, motivation 0.40, engagement 0.44; puzzle games 0.63 vs other 0.31. Treat as low quality.
  - Outhwaite et al. 2019 (pupil-level RCT, 389 UK children aged 4-5, 12 weeks): interactive math apps raised math gains over standard practice, both as an add-on and as a time-equivalent replacement for a small-group activity; gains generalized to reasoning and problem-solving measures. These are instructional apps, not answer-unlocks-play games.
  - Griffith et al. 2019 systematic review (35 controlled studies, mean age under 6): learning benefits across studies, particularly early math; risk of bias often unclear.
  - Berkowitz et al. 2015 (randomized field experiment, 587 first graders): parent-child math story problems via an iPad app raised school-year math achievement over a reading control, especially where parents were math-anxious.
- Uncertainty: moderate. Publication bias is flagged in three syntheses; comparison conditions vary.
- Citations:
  - Clark, Tanner-Smith, Killingsworth (2016). Digital games, design, and learning: a systematic review and meta-analysis. Review of Educational Research 86(1):79-122. doi:10.3102/0034654315582065
  - Wouters, van Nimwegen, van Oostendorp, van der Spek (2013). A meta-analysis of the cognitive and motivational effects of serious games. Journal of Educational Psychology 105(2):249-265. doi:10.1037/a0031311
  - Sitzmann (2011). A meta-analytic examination of the instructional effectiveness of computer-based simulation games. Personnel Psychology 64(2):489-528. doi:10.1111/j.1744-6570.2011.01190.x
  - Wouters, van Oostendorp (2013). A meta-analytic review of the role of instructional support in game-based learning. Computers and Education 60(1):412-425. doi:10.1016/j.compedu.2012.07.018 (abstract via ERIC EJ1006979)
  - Vogel et al. (2006). Computer gaming and interactive simulations for learning: a meta-analysis. Journal of Educational Computing Research 34(3):229-243. doi:10.2190/FLHV-K4WA-WPVQ-H0YM
  - Wang, Chen, Hwang, Guan, Wang (2022). Effects of digital game-based STEM education on students' learning achievement: a meta-analysis. International Journal of STEM Education 9(1). doi:10.1186/s40594-022-00344-0
  - Tokac, Novak, Thompson (2019). Effects of game-based learning on students' mathematics achievement: a meta-analysis. Journal of Computer Assisted Learning 35(3):407-420. doi:10.1111/jcal.12347
  - Alotaibi (2024). Game-based learning in early childhood education: a systematic review and meta-analysis. Frontiers in Psychology 15. doi:10.3389/fpsyg.2024.1307881
  - Outhwaite, Faulder, Gulliford, Pitchford (2019). Raising early achievement in math with interactive apps: a randomized control trial. Journal of Educational Psychology 111(2):284-298. doi:10.1037/edu0000286
  - Griffith, Hagan, Heymann, Heflin, Bagner (2019). Apps as learning tools: a systematic review. Pediatrics 145(1):e20191579. doi:10.1542/peds.2019-1579
  - Berkowitz et al. (2015). Math at home adds up to achievement in school. Science 350(6257):196-198. doi:10.1126/science.aac7427

## 3. Intrinsic integration (content is the core mechanic) vs extrinsic (answers unlock unrelated play)

- Tier: C. Direction is mixed across the two controlled comparisons found, and the meta-analytic moderator is not significant.
- Findings:
  - Habgood and Ainsworth 2011 (Zombie Division, ages 7-11): Study 1, 58 children played intrinsic, extrinsic or control variants for 2 hours with teacher support; children learned more from the intrinsic version. Study 2, 16 children given free choice spent 7 times longer on the intrinsic version.
  - Vandercruysse et al. 2017 (64 vocational-track students, proportional reasoning, game "Zeldenrust"): contrary to the authors' expectations, the extrinsically integrated version produced higher learning gains, motivational gains and perceived usefulness.
  - Clark et al. 2016 (full text): only one game in the corpus was fully extrinsic. "Simplistically intrinsic" games, where answering is the single mechanic for both learning and play, g = 0.49 [0.27, 0.71], k = 23; complex intrinsic designs 0.19 [-0.02, 0.41], k = 24; mixed designs 0.33. The categories did not differ significantly.
  - Echeverria et al. 2012: a physics game redesigned by an intrinsic-integration method beat the original; fantasy vs non-fantasy versions did not differ.
  - Ke 2016 (systematic review of 69 articles): qualitative themes on how learning is embedded in game mechanics; no effect sizes.
- Classification note for this project: a Missile-Command-style mode where typing or selecting the answer is what fires at the target sits closest to Clark's "simplistically intrinsic" category (answering is the action). It is extrinsic in Habgood and Ainsworth's stricter sense if the answer's content (for example, 7 x 8 = 56) has no relation to the aiming geometry. Neither study tested this exact design.
- Uncertainty: high. Two small studies point in opposite directions with different ages and content.
- Citations:
  - Habgood, Ainsworth (2011). Motivating children to learn effectively: exploring the value of intrinsic integration in educational games. Journal of the Learning Sciences 20(2):169-206. doi:10.1080/10508406.2010.508029
  - Vandercruysse, ter Vrugte, de Jong, Wouters, van Oostendorp, Verschaffel, Elen (2017). Content integration as a factor in math-game effectiveness. Educational Technology Research and Development 65(5):1345-1368. doi:10.1007/s11423-017-9530-5 (abstract via ERIC EJ1155625)
  - Echeverria, Barrios, Nussbaum, Amestica, Leclerc (2012). The atomic intrinsic integration approach. Computers and Education 59(2):806-816. doi:10.1016/j.compedu.2012.03.025 (abstract via ERIC EJ967019)
  - Ke (2016). Designing and integrating purposeful learning in game play: a systematic review. Educational Technology Research and Development 64(2):219-244. doi:10.1007/s11423-015-9418-1
  - Clark et al. (2016), as above.

## 4. Drill-and-practice and fact-fluency games; time pressure and anxiety

- Tier: B for fact-fluency interventions in general (children with math difficulties). C/D for wrapping drill in an arcade-game format as an improvement over plain drill. C for adaptive high-success practice. Timed practice causing math anxiety: no experimental evidence found in either direction.
- Fluency interventions:
  - Douglas et al. 2026 (35 group-design studies, 178 effect sizes, students with math difficulties, RVE): g = 0.76 with a prediction interval of -0.60 to 2.12; significant moderators were grouping, total sessions, operation focus and outcome measure.
  - Codding, Burns, Lukito 2011 (17 single-case studies, 55 participants): drill and practice with modeling gave the largest effects; more than 3 components beat fewer.
  - Poncy, McCallum, Schmitt 2010 (one second-grade class, alternating treatments): Cover, Copy and Compare raised subtraction fluency and gains held two months later; a constructivist activity set did not differ from control.
- Game format vs plain drill:
  - Christensen and Gerber 1990 (30 learning-disabled and 30 nondisabled students): learning-disabled students were relatively disadvantaged by practicing addition facts in an arcade-like game rather than plain drill; authors attribute this to selective-attention demands.
  - Okolo 1992 (41 learning-disabled students, grades 4-6, four sessions): both formats improved fact proficiency equally; the game format raised continuing motivation for students with low initial attitudes toward math.
- Adaptive speeded practice (Math Garden):
  - Klinkenberg, Straatemeier, van der Maas 2011: Elo-based adaptive practice whose scoring rule counts both accuracy and response time; items sampled at a 0.75 success probability; 3,648 children answered over 3.5 million problems in ten months, about 33% outside school.
  - Jansen et al. 2013 (207 children, grades 3-6, six weeks, control plus three preset success-rate conditions): math anxiety improved equally in all conditions, including control; math performance improved only in the practice conditions; higher preset success rates led to more problems attempted and larger performance gains.
- Time pressure and anxiety:
  - Namkung, Peng, Lin 2019 (131 studies, 478 effect sizes): math anxiety correlates with performance r = -.34; stronger for multistep tasks and for measures that affect grades. Correlational.
  - Ramirez et al. 2013 (154 first and second graders): math anxiety related to lower achievement only among children with higher working memory. Math anxiety is measurable by grade 1.
  - Tsui and Mazzocco 2006 (mathematically gifted sixth graders): performance was worse under timed testing only when the timed test came first; children with higher anxiety or perfectionism showed a smaller timed-untimed gap, not a larger one.
  - Caviola et al. 2017 (review, 19 articles on time pressure, stress and strategy selection): literature too sparse to answer; no clear associations.
  - Ashcraft and Moore 2009 (narrative review): math anxiety produces an "affective drop" under timed, high-stakes conditions.
- Uncertainty: moderate for fluency practice itself; high for game wrapping and for time pressure. Every anxiety finding above is correlational or a within-test manipulation; none randomizes children to timed vs untimed practice and measures later anxiety.
- Citations:
  - Douglas, Myers, Mason, Powell, Lariviere (2026). A meta-analysis of mathematics fact fluency interventions for students with mathematics difficulties. Journal of Learning Disabilities 59(3):135-160. doi:10.1177/00222194261424914 (abstract via ERIC EJ1502940)
  - Codding, Burns, Lukito (2011). Meta-analysis of mathematic basic-fact fluency interventions: a component analysis. Learning Disabilities Research and Practice 26(1):36-47. doi:10.1111/j.1540-5826.2010.00323.x (abstract via ERIC EJ927934)
  - Poncy, McCallum, Schmitt (2010). A comparison of behavioral and constructivist interventions for increasing math-fact fluency in a second-grade classroom. Psychology in the Schools 47(9):917-930. doi:10.1002/pits.20514 (abstract via ERIC EJ903129)
  - Christensen, Gerber (1990). Effectiveness of computerized drill and practice games in teaching basic math facts. Exceptionality 1(3):149-165. doi:10.1080/09362839009524751
  - Okolo (1992). The effect of computer-assisted instruction format and initial attitude on the arithmetic facts proficiency and continuing motivation of students with learning disabilities. Exceptionality 3(4):195-211. doi:10.1080/09362839209524815
  - Klinkenberg, Straatemeier, van der Maas (2011). Computer adaptive practice of maths ability using a new item response model for on the fly ability and difficulty estimation. Computers and Education 57(2):1813-1824. doi:10.1016/j.compedu.2011.02.003 (abstract via ERIC EJ925823)
  - Jansen et al. (2013). The influence of experiencing success in math on math anxiety, perceived math competence, and math performance. Learning and Individual Differences 24:190-197. doi:10.1016/j.lindif.2012.12.014 (abstract via ERIC EJ1008332)
  - Namkung, Peng, Lin (2019). The relation between mathematics anxiety and mathematics performance among school-aged students: a meta-analysis. Review of Educational Research 89(3):459-496. doi:10.3102/0034654319843494
  - Ramirez, Gunderson, Levine, Beilock (2013). Math anxiety, working memory, and math achievement in early elementary school. Journal of Cognition and Development 14(2):187-202. doi:10.1080/15248372.2012.664593 (abstract via ERIC EJ1011797)
  - Tsui, Mazzocco (2006). Effects of math anxiety and perfectionism on timed versus untimed math testing in mathematically gifted sixth graders. Roeper Review 29(2):132-139. doi:10.1080/02783190709554397
  - Caviola, Carey, Mammarella, Szucs (2017). Stress, time pressure, strategy selection and math anxiety in mathematics: a review of the literature. Frontiers in Psychology 8. doi:10.3389/fpsyg.2017.01488
  - Ashcraft, Moore (2009). Mathematics anxiety and the affective drop in performance. Journal of Psychoeducational Assessment 27(3):197-205. doi:10.1177/0734282908330580 (abstract via ERIC EJ845128)

## 5. Seductive details, extraneous game elements and extrinsic rewards

- Tier: B that interesting but irrelevant additions reduce learning (small effect). A/B that expected tangible rewards reduce later free-choice engagement in lab tasks, with a live dispute over size. C for whether game points and badges behave like those rewards.
- Seductive details:
  - Rey 2012 (39 experimental effects): small-to-medium harm to retention, medium harm to transfer.
  - Sundararajan and Adesope 2020: seductive details hinder learning; moderated by image type, delivery format, language, subject, learner pacing, question type and manipulation checks (pooled value not in the ERIC abstract).
  - Cheng et al. 2026 (50 studies, 177 effect sizes, multilevel and MASEM): g = -0.16 overall; comprehension -0.19, recall -0.17, transfer -0.12; the harm ran through extraneous cognitive load, not intrinsic or germane load.
  - Game-specific: in Clark 2016, realistic and highly contextualized games did worse than schematic ones (section 2). Christensen and Gerber 1990 (section 4) is a direct case of game elements hurting drill for children with attention difficulties.
- Extrinsic rewards and intrinsic motivation:
  - Deci, Koestner, Ryan 1999 (128 studies): engagement-, completion- and performance-contingent rewards reduced free-choice intrinsic motivation (d = -0.40, -0.36, -0.28); positive feedback raised free-choice behavior (d = 0.33) and interest (d = 0.31); tangible rewards were more harmful for children than for college students, and verbal rewards less helpful for children.
  - Cameron and Pierce 1994 (96 studies): overall no decrease; the only negative effect was a minimal one for expected tangible rewards given simply for doing a task; verbal praise increased intrinsic motivation. Deci, Koestner, Ryan 2001 argue the 1994 analysis was seriously flawed. Cameron, Banko, Pierce 2001 replied (abstract not retrieved).
  - Cerasoli, Nicklin, Ford 2014 (k = 183, N = 212,468): intrinsic motivation predicted performance (rho = .21-.45) with or without incentives; incentives predicted quantity of performance better, intrinsic motivation predicted quality better; intrinsic motivation mattered less when incentives were tied directly to performance.
  - Lepper, Greene, Nisbett 1973 (field experiment with children): children who agreed to an activity to earn an expected award later showed less interest in it than unexpected-award and no-award children.
- Transfer to games: Okolo, Hinsey, Yousefian 1990 (18 learning-disabled high schoolers, 7 hours of keyboarding) found game format did not change skill acquisition but had a detrimental effect on continuing motivation to practice. Okolo 1992 found the opposite for low-attitude students in math facts. No meta-analysis testing points or badges against the undermining effect was found with a readable abstract.
- Uncertainty: moderate for seductive details; high for game rewards specifically.
- Citations:
  - Rey (2012). A review of research and a meta-analysis of the seductive detail effect. Educational Research Review 7(3):216-237. doi:10.1016/j.edurev.2012.05.003 (abstract via ERIC EJ986386)
  - Sundararajan, Adesope (2020). Keep it coherent: a meta-analysis of the seductive details effect. Educational Psychology Review 32(3):707-734. doi:10.1007/s10648-020-09522-4 (abstract via ERIC EJ1263249)
  - Cheng, Wu, Wang, Wang (2026). Seductive details, cognitive load, and learning outcomes: a multi-level meta-analysis and MASEM. Educational Psychology Review 38(1). doi:10.1007/s10648-025-10099-z (abstract via ERIC EJ1510171)
  - Deci, Koestner, Ryan (1999). A meta-analytic review of experiments examining the effects of extrinsic rewards on intrinsic motivation. Psychological Bulletin 125(6):627-668. doi:10.1037/0033-2909.125.6.627
  - Cameron, Pierce (1994). Reinforcement, reward, and intrinsic motivation: a meta-analysis. Review of Educational Research 64(3):363-423. doi:10.3102/00346543064003363
  - Deci, Koestner, Ryan (2001). Extrinsic rewards and intrinsic motivation in education: reconsidered once again. Review of Educational Research 71(1):1-27. doi:10.3102/00346543071001001
  - Cameron, Banko, Pierce (2001). Pervasive negative effects of rewards on intrinsic motivation: the myth continues. The Behavior Analyst 24(1):1-44. doi:10.1007/BF03392017 (abstract not retrieved)
  - Cerasoli, Nicklin, Ford (2014). Intrinsic motivation and extrinsic incentives jointly predict performance: a 40-year meta-analysis. Psychological Bulletin 140(4):980-1008. doi:10.1037/a0035661
  - Lepper, Greene, Nisbett (1973). Undermining children's intrinsic interest with extrinsic reward. Journal of Personality and Social Psychology 28(1):129-137. doi:10.1037/h0035519
  - Okolo, Hinsey, Yousefian (1990). Learning disabled students' acquisition of keyboarding skills and continuing motivation under drill-and-practice and game conditions. Learning Disabilities Research and Practice 5(2):100-109. doi:10.1177/093889829000502a06

## 6. Delayed retention and transfer from games

- Tier: C. Retention measures exist and are positive, but most game evidence is immediate.
- Findings: Clark 2016's media comparisons had a mean posttest delay of 0.66 weeks. Wouters 2013 reported retention d = 0.36 alongside learning d = 0.29. Sitzmann 2011 reported retention 9% higher for simulation games, with strong publication bias. Gamification syntheses above report no delayed-test pooled estimate in their abstracts. Outhwaite 2019 reported generalization to untrained reasoning measures. Transfer tests are the exception in this literature, and Rey 2012 found seductive details hurt transfer more than retention.
- Uncertainty: high for anything beyond a few weeks.
- Differs from prior: matches the GenAI anchor in the first review. Outcomes should be measured unaided, delayed and outside the game.

## 7. Typing: touch-typing instruction, age, and typing vs handwriting for letters

- Tier: C that touch-typing instruction raises typing speed and accuracy (pre-post and quasi-experimental designs). C that consistent finger-to-key mapping matters more than the ten-finger system as such. No evidence establishes a minimum age; C/D for touch-typing instruction before about age 7. B/C that handwriting beats typing for letter learning at age 5 (four small studies, same direction). D for game-format typing tutors being better than plain drill.
- Adults:
  - Weigelt-Marom and Weintraub 2015 (higher education, 44 with learning disabilities and 30 without, 14 lessons with keystroke logging, no untrained control): at the end of the program the normally achieving students typed slower than at pretest; three months later both groups were significantly faster than at pretest; accuracy stayed above 95%.
  - Feit, Weir, Oulasvirta 2016 (transcription task, motion capture): self-taught typists can match touch typists, even with fewer fingers; predictors of speed were a consistent letter-to-finger mapping, preparing upcoming keystrokes, and minimal global hand motion.
  - Logan, Ulrich, Lindsey 2016: nonstandard typists were slower and less accurate than standard typists, especially when keys were unlabeled or the keyboard covered; both groups showed similar automatic hierarchical control.
  - Dhakal et al. 2018 (168,000 online volunteers): eight typist clusters differing in speed, accuracy, finger use and rollover; letter pairs typed by different hands or fingers predicted speed.
- Children:
  - van Weerdenburg, Tesselhof, van der Meijden 2018 (207 students, grades 4-6, 154 course vs 53 control, not stated as randomized): the course group progressed more in typing, and in spelling and narrative writing on the computer.
  - Donica, Giroux, Faust 2018 (quasi-experiment, kindergarten-grade 5): a structured curriculum beat free web activities on speed and accuracy mainly in upper grades and on method in lower grades.
  - Connelly, Gee, Walsh 2007 (300 UK primary children, no typing instruction): handwriting was faster than keyboarding at every age; only a small minority in years 5-6 typed faster than they wrote; keyboarded compositions were up to two years behind handwritten ones.
  - Feng et al. 2017 (meta-analytic review): handwriting and keyboarding fluency are related; writing quality was similar across modes; keyboarding allowed faster writing.
  - Kosir et al. 2024 (12-13-year-olds): learning trends for touch typing did not differ between students with dyslexia and typical peers, though the dyslexia group was slower throughout.
  - Age: a 1989 ERIC report (four children aged 5-6, not peer reviewed) found they did not acquire proficient touch typing, kept inconsistent fingering and kept glancing at the keys. No controlled study found of touch-typing instruction for ages 5-7.
- Typing vs handwriting for letter learning (links to section 5 of EARLY_LITERACY_NUMERACY_2026-09-28.md, tier C there):
  - Kiefer et al. 2015 (full text: 23 German kindergartners, mean age 5 years 6 months; 16 sessions over four weeks; eight letters): no advantage of typing on any measure; handwriting was better for word writing and, as a trend, word reading.
  - Mayer et al. 2020 (147 kindergartners, 16 letters, seven weeks, follow-up four to five weeks later): pencil beat virtual-keyboard training on letter recognition and visuo-spatial skills; keyboard beat tablet-stylus writing on word reading and writing but not pencil.
  - Longcamp et al. 2008 (adults, novel characters): handwriting gave stronger and longer-lasting (several weeks) recognition than typing.
  - Longcamp et al. 2005 (in the prior review): handwriting beat typing for letter recognition in the older preschoolers only.
- Typing tutor games: Okolo, Hinsey, Yousefian 1990 (section 5) found no acquisition difference between game and drill formats and worse continuing motivation with the game. A 2000 ERIC practitioner report on middle schoolers credited hand covers plus a game-based program (not peer reviewed; not used).
- Uncertainty: high throughout; no RCT of touch-typing instruction in children was found.
- Citations:
  - Weigelt Marom, Weintraub (2015). The effect of a touch-typing program on keyboarding skills of higher education students with and without learning disabilities. Research in Developmental Disabilities 47:208-217. doi:10.1016/j.ridd.2015.09.014
  - Feit, Weir, Oulasvirta (2016). How we type: movement strategies and performance in everyday typing. Proceedings of CHI 2016:4262-4273. doi:10.1145/2858036.2858233
  - Logan, Ulrich, Lindsey (2016). Different (key)strokes for different folks: how standard and nonstandard typists balance Fitts' law and Hick's law. Journal of Experimental Psychology: Human Perception and Performance 42(12):2084-2102. doi:10.1037/xhp0000272
  - Dhakal, Feit, Kristensson, Oulasvirta (2018). Observations on typing from 136 million keystrokes. Proceedings of CHI 2018:1-12. doi:10.1145/3173574.3174220
  - van Weerdenburg, Tesselhof, van der Meijden (2018). Touch-typing for better spelling and narrative-writing skills on the computer. Journal of Computer Assisted Learning 35(1):143-152. doi:10.1111/jcal.12323 (abstract via ERIC EJ1203138)
  - Donica, Giroux, Faust (2018). Keyboarding instruction: comparison of techniques for improved keyboarding skills in elementary students. Journal of Occupational Therapy, Schools and Early Intervention 11(4):396-410. doi:10.1080/19411243.2018.1512067
  - Connelly, Gee, Walsh (2007). A comparison of keyboarded and handwritten compositions and the relationship with transcription speed. British Journal of Educational Psychology 77(2):479-492. doi:10.1348/000709906x116768
  - Feng, Lindner, Ji, Malatesha Joshi (2017). The roles of handwriting and keyboarding in writing: a meta-analytic review. Reading and Writing 32(1):33-63. doi:10.1007/s11145-017-9749-x (abstract via ERIC EJ1203330)
  - Kosir, Kosir, Podlesek, Kosak Babuder (2024). Typing fluencies of 12-13-year-old students with dyslexia and peers with typical development. Reading and Writing Quarterly 40(6):600-618. doi:10.1080/10573569.2024.2304758 (abstract via ERIC EJ1446515)
  - Comparing children's typing skills using the Dvorak and QWERTY keyboards on a microcomputer (1989). ERIC ED313002 (report; authors not verified)
  - Kiefer, Schuler, Mayer, Trumpp, Hille, Sachse (2015). Handwriting or typewriting? Advances in Cognitive Psychology 11:136-146. doi:10.5709/acp-0178-7
  - Mayer, Wallner, Budde-Spengler, Braunert, Arndt, Kiefer (2020). Literacy training of kindergarten children with pencil, keyboard or tablet stylus. Frontiers in Psychology 10. doi:10.3389/fpsyg.2019.03054
  - Longcamp, Boucard, Gilhodes, Anton, Roth, Nazarian, Velay (2008). Learning through hand- or typewriting influences visual recognition of new graphic shapes. Journal of Cognitive Neuroscience 20(5):802-815. doi:10.1162/jocn.2008.20504
  - Okolo, Hinsey, Yousefian (1990), as above.

---

## Differences from meta-prompt priors

1. Meta-prompt 1.4 ("do not turn every activity into a game") holds. Games and gamification show small-to-moderate immediate gains, but motivation effects are the least stable part, and games were not more motivating than conventional instruction in Wouters 2013.
2. No 2.3 anchor exists for games. Proposed: game mode at tier B/C as a practice format for material already taught, used across multiple sessions, with schematic visuals and no head-to-head competition; its value to be measured on delayed, out-of-game items.
3. Intrinsic integration is not a settled design rule. The two controlled comparisons disagree; treat intrinsic vs extrinsic as an experiment arm.
4. Timed practice: the claim that timed drills cause math anxiety has no experimental support in what was found, and neither does the claim that they are harmless. The project's timed-items design (late-correct as its own outcome) is consistent with this; keep an untimed path.
5. Typing: no evidence supports teaching touch typing to a 5-year-old, and letter learning at 5 favors handwriting over typing.

## Unverified / not found

- Hanus, Fox (2015). Assessing the effects of gamification in the classroom. Computers and Education 80:152-161. doi:10.1016/j.compedu.2014.08.019 (erratum doi:10.1016/j.compedu.2018.09.019, content not read). Findings (less motivation, satisfaction and empowerment over a semester, lower final exam scores mediated by intrinsic motivation) were seen only in a search-engine summary; abstract not retrieved from a primary index. Not used above.
- Mekler, Bruhlmann, Tuch, Opwis (2017). Computers in Human Behavior 71:525-534. doi:10.1016/j.chb.2015.08.048: abstract not retrieved; its findings on points, levels and leaderboards vs intrinsic motivation not used.
- Weigelt-Marom, Weintraub (2018). Computers and Education 117:132-140. doi:10.1016/j.compedu.2017.10.008: abstract not retrieved.
- Tokac et al. 2019 and Byun and Joung 2018 pooled effect sizes: not in retrieved abstracts (an ES of about 0.13 for Tokac is from memory, not recorded). Byun, Joung (2018). School Science and Mathematics 118(3-4):113-126. doi:10.1111/ssm.12271.
- Sundararajan and Adesope 2020 pooled g: not in the ERIC abstract.
- Sailer and Homner moderator values for intervention duration and for competition vs collaboration on cognitive outcomes: publisher full text blocked.
- Huang et al. 2020 per-element effect sizes (leaderboards, badges and others): not in abstract.
- Wouters 2013 visual-realism and narrative moderators: seen only as summarized in Clark 2016's full text.
- No RCT found that assigns children to timed vs untimed practice and measures later math anxiety.
- No controlled study found of touch-typing instruction for children aged 5-7, and no RCT of touch typing at any child age.
- No study found testing a Missile-Command-style answer-to-shoot game specifically, or comparing typed vs selected answers inside a game.
- ERIC practitioner reports on typing software (ED443386, ED443389, ED381132) were located, not peer reviewed, and not used.

---

## Design implications

### Findings (directly supported above, with tier)

- F1 (B): Games and gamification give small-to-moderate immediate learning gains over nongame instruction (Clark g = 0.33; Sailer cognitive g = .49), with publication bias flagged in three syntheses.
- F2 (B): One game session showed no reliable benefit (g = 0.08); multiple sessions did (0.44). Total play time was not associated with effect size.
- F3 (B/C): Single-player competitive play did worst (g = -0.06, k = 4) and noncompetitive single play best (0.45) in Clark 2016; competition helped mainly when combined with collaboration (Sailer).
- F4 (B/C): Schematic visuals did at least as well as realistic ones; seductive details cost about g = -0.16; plain drill beat an arcade wrapper for children with attention difficulties (Christensen and Gerber).
- F5 (C): Intrinsic vs extrinsic integration: one study favors intrinsic (ages 7-11), one favors extrinsic (vocational students), and the meta-analytic categories do not differ. "Answering is the only mechanic" games averaged g = 0.49.
- F6 (B): Fact-fluency practice works for children with math difficulties (g = 0.76, very wide prediction interval).
- F7 (C): Adaptive practice at high success rates led children to attempt more problems and gain more; anxiety did not change differently across conditions.
- F8 (A/B, dispute on size): Expected, task-contingent tangible rewards reduce later free-choice engagement, more for children; positive informational feedback raises it.
- F9 (C): Game evidence is almost all immediate; delayed and transfer results are sparse.
- F10 (C): Touch-typing courses raise typing speed in grades 4-6 and adults; adults may slow down first. Consistent finger mapping and not looking at keys predict speed.
- F11 (B/C): At age 5, handwriting beats typing for letter recognition; keyboard beat stylus but not pencil.
- F12 (D): Game-format typing tutors did not beat drill on skill and lowered continuing motivation in one small study.

### Inferences for a Missile-Command-style answer-to-act mode (hypotheses; instrument them)

- I1: Use the mode for fluency practice of items already taught and known to be answerable, not for first teaching (F4, F6; section 2 scaffolding results).
- I2: Keep visuals schematic and the screen sparse; no story layer at first (F4; prior review I4).
- I3: No head-to-head leaderboards. Compete against one's own past record or cooperate with the parent (F3).
- I4: Set target speed adaptively from the learner's own recent latencies and aim for a high success rate (Math Garden used 0.75; Jansen found more practice at higher rates). Wrong answers should not end the round (F7).
- I5: Log correct-in-time, correct-late, wrong and timed-out separately, as the timed-items design already does, and keep an untimed mode available at all times. For the 5-year-old, start untimed and watch for avoidance (section 4: no experimental evidence either way).
- I6: Points should report information (accuracy, speed trend) rather than be an expected prize for playing; avoid tangible or unlockable rewards tied to playing time (F8).
- I7: Run intrinsic vs extrinsic variants as an A/B arm for the adult first; for the child, the answer should cause the action directly, since answer-to-unlock-unrelated-play has one negative (Habgood) and one positive (Vandercruysse) result (F5).
- I8: Plan for several short sessions across days, and check whether use drops after about four weeks (F2; Rodrigues).
- I9: Measure mastery outside the game on delayed, unaided items; treat in-game accuracy as practice data, not evidence of learning (F9).
- I10: For a pre-reader, answers must be selected (tapped numerals or pictures) or spoken, not typed (F10, F11); typed answers apply to the adult and later to the child.

### Inferences for a typing lesson type (hypotheses; instrument them)

- I11: Adult: teach a consistent finger-to-key mapping with keys hidden or not looked at; show the expected early slowdown in the UI so a temporary drop is not read as failure; track speed and accuracy per key from keystroke logs (F10).
- I12: Child: no touch-typing curriculum at age 5. Teach letters by handwriting (existing handwriting-capture plan). Reassess touch typing around age 7 or later, starting with short drills and measuring progress, since no study sets a minimum age (F10, F11).
- I13: Deliver typing practice as plain drill with informational feedback; a game layer is optional and should be tested against drill on continuing use (F12).
- I14: Measure typing on untrained text and at a delay, since the one adult study with a follow-up showed gains appearing only at three months (Weigelt-Marom 2015).
