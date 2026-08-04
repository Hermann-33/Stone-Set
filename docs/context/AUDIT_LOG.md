# Stone Set Audit Log

## 2026-08-03 — TASK-WF-001 — Initial repository governance audit

### Scope

- inspect repository metadata and initial state;
- evaluate the supplied Markdown governance model for use in Stone Set;
- establish the minimum viable context system without fabricating product or technical facts.

### Findings

1. The repository was completely empty.
2. Stone Set was identified only as a personal app project; its actual problem and workflow were undefined.
3. Copying the full source governance system blindly would create technology-specific and project-specific garbage.
4. Product discovery must precede architecture and scaffolding.
5. A mandatory repository authority hierarchy was required because future planning will occur in chat while implementation will be delegated to Codex.

### Fixes performed

- initialized the repository;
- created the minimum viable governance and context documents;
- adapted terminology to Stone Set;
- omitted technology-specific data status files because no persistence or infrastructure exists;
- omitted fabricated ADRs;
- added explicit Codex task and completion-report contracts;
- added completion verdicts and anti-drift boundaries.

### Verification

- repository metadata inspected through the connected GitHub application;
- initial empty state confirmed;
- generated documentation reviewed against the supplied governance model;
- all implementation and architecture claims remain explicitly unset.

### Risks remaining

- product definition is absent;
- no accepted architecture exists;
- no branch protection or CI exists;
- the governance documents must be updated with implementation rather than treated as decorative paperwork.

### Verdict

`COMPLETE`

The repository context baseline is sufficient to begin structured product discovery. It is not sufficient to begin application implementation.

---

## 2026-08-03 — TASK-PD-001 — Hypertrophy routine evidence and time-cap audit

### Scope

- inspect only the workout-routine sections of the supplied weekly muscle-growth plan;
- evaluate split structure, exercise selection, weekly set exposure, frequency, repetition ranges, rest intervals, proximity to failure, progression, and exercise order;
- redesign sessions around a hard maximum of 60 minutes;
- preserve the limited-equipment boundary;
- establish the first product-domain baseline for Stone Set.

### Research reviewed

Primary resistance-training trials were reviewed for:

- low, moderate, and high training volume;
- volume-equated training frequency;
- failure versus repetitions in reserve;
- one-minute versus three-minute inter-set rest;
- traditional sets versus multi-joint supersets;
- low-load versus high-load hypertrophy;
- exercise order;
- bench-press contribution to anterior-deltoid and triceps hypertrophy;
- standing versus seated calf-raise hypertrophy.

PubMed identifiers and the specific application of each study are recorded in `docs/product/HYPERTROPHY_ROUTINE.md`.

### Findings

1. The original split was competent and covered all major movement patterns.
2. The split itself was not uniquely superior; its value was distributing weekly work across five shorter sessions.
3. The original 75-minute main-session allocation violated the new 60-minute constraint.
4. Rushing rest intervals to preserve every original set would degrade repetition performance and training quality.
5. Wednesday shoulder pressing was redundant under the time and recovery constraints because two weekly bench sessions already train the anterior deltoids and triceps.
6. Three hard Bulgarian split-squat sets per leg were disproportionately time-expensive and fatiguing.
7. The original weekly volume was broadly usable, but some lower-body accessory volume could be reduced without creating an obvious hypertrophy gap.
8. Heavy compound supersets were not the correct default solution; accessory antagonist pairings were a better time-saving compromise.
9. The research does not justify claiming one exact routine is universally optimal.

### Fixes performed

- established a 60-minute hard stop including warm-up;
- reduced Upper A to 16 working sets;
- reduced Lower A to 15 working sets;
- removed the Wednesday shoulder press and retained direct side- and rear-delt work;
- reduced Bulgarian split squats to two hard sets per leg;
- retained moderate weekly exposure for every major muscle group;
- preserved longer rest for compounds and shorter rest for isolation work;
- allowed only defined accessory antagonist pairings;
- retained double progression and RIR-based effort control;
- documented an eight-week observation block and controlled adjustment rules;
- updated repository product and current-state documentation.

### Verification

- all exercises remain inside the equipment boundary shown by the source routine;
- weekly direct-set exposure was recalculated;
- every session was time-budgeted below 60 minutes under the stated rest protocol;
- no nutrition, sleep, timetable, architecture, implementation, or production claim was added;
- repository context was synchronized with the accepted product direction.

### Risks remaining

- individual recoverable volume is unknown until training data exists;
- RIR accuracy may be poor initially;
- gym crowding may invalidate planned accessory pairings;
- the user's workout execution and logging workflow remains undefined;
- no application implementation is authorized.

### Verdict

`COMPLETE`

The evidence-backed workout baseline is sufficient to proceed to detailed application workflow discovery. It is not evidence that the routine is uniquely optimal for every user or that Stone Set is ready for implementation.

---

## 2026-08-04 — TASK-PD-002 — Workout rank and RR system audit

### Scope

- inspect the supplied Quest Tracker rank-system brief;
- identify portable mechanics and domain-specific garbage;
- define Stone Set rewards for scheduled workout consistency, complete logging, and valid PRs;
- define rank progression, demotion, recovery protection, corrections, and anti-farming behavior;
- preserve the accepted workout program and 60-minute constraint.

### Source mechanics reviewed

- permanent lifetime XP versus dynamic current-level XP;
- 20-rank threshold ladder;
- reward tiers and multipliers;
- stored award records;
- undo using stored values;
- daily rank-local decay;
- missed-task penalties;
- daily streak boss rewards;
- flow bonuses;
- holiday-mode snapshots.

### Findings

1. Separating lifetime achievement from current rank is the correct foundation.
2. Stored award records and exact-value reversal are mandatory for auditability.
3. Rank-local decay is better than full-score percentage decay.
4. Daily decay is invalid for a gym app because rest days are prescribed behavior.
5. Daily attendance streaks would reward overtraining rather than program adherence.
6. Rank-tier reward suppression is a poor fit because legitimate PRs naturally become less frequent as training age increases.
7. Consistency should amplify valid session rewards through a rolling weekly adherence model.
8. PR rewards require strict exercise-variant, load, repetition, RIR, range-of-motion, and technique comparability.
9. PR rewards must be capped so beginner progression cannot overwhelm adherence.
10. Extra sets and extra workouts must not generate RR.
11. Deloads, illness, injury, travel, and gym closure require explicit non-punitive states.
12. Lifetime XP should be permanent against inactivity but reversible when an invalid or duplicate record is voided.

### Accepted corrections

- replaced `totalXP/currentLevelXP` terminology with `lifetimeXP/rankRR`;
- retained 20 ranks but changed the top rank to Titan;
- replaced daily decay with weekly rank-local decay after materially failed unprotected weeks;
- replaced daily streaks with scheduled-week consistency;
- defined a rolling six-week multiplier from 1.00x to 1.50x;
- defined main-session and specialization-session base rewards;
- added complete-logging rewards;
- defined +5 RR per valid PR with a two-PR session cap;
- defined perfect-week rewards and once-per-account consecutive-week milestones;
- defined protected pause and deload behavior;
- prohibited RR from random extra workouts, extra sets, and programmed rest days;
- defined immutable award records and correction events;
- defined rank threshold, weekly evaluation, and decay calculations;
- required future rank-config versioning.

### Verification

- maximum ordinary session reward was bounded;
- maximum-consistency weekly RR was calculated from the accepted five-session program;
- threshold pacing was checked against multi-year adherence rather than rapid novelty progression;
- one imperfect week does not zero the consistency multiplier;
- one failed week at high rank costs roughly one strong training week rather than destroying the account;
- rest days and deloads cannot trigger penalties;
- fake volume and duplicate-session farming are blocked at the specification level;
- the repository context, brief, roadmap, map, and handoff were synchronized.

### Risks remaining

- reward and threshold numbers require simulation and eventual real-use tuning;
- RIR and technique are self-reported unless future validation exists;
- protected-pause backdating can be abused without correction history;
- exercise variant identity must be precise;
- future balance versions need explicit historical migration policy;
- no app workflow, data schema, architecture, or implementation exists.

### Verdict

`COMPLETE`

The rank-system baseline is coherent enough to proceed to detailed workout execution and award-flow discovery. It is not authorization to implement before Phase 0 closes.

---

## 2026-08-04 — TASK-PD-003 — Direct missed-session RR penalty audit

### Scope

- evaluate the owner's requirement that every missed scheduled workout should directly reduce RR;
- correct the accepted rank system without penalizing programmed recovery;
- define penalty timing, values, protected states, reversal behavior, and interaction with weekly decay;
- synchronize repository context.

### Finding

The previous baseline treated a missed workout primarily as lost opportunity, lost weekly bonus, weaker consistency credit, and a broken streak. Direct RR loss occurred only when the week fell below three completed sessions.

That did not satisfy the owner's intended accountability model.

### Accepted correction

- each unprotected missed main session deducts `20 RR`;
- each unprotected missed specialization session deducts `15 RR`;
- the penalty equals the session's unmultiplied base RR;
- consistency multipliers affect rewards but never increase penalties;
- penalties apply once at weekly finalization after reschedules and protected states are resolved;
- partial sessions at 70-89% completion receive reduced rewards but no missed-session penalty;
- sessions below 70% completion are treated as missed unless protected;
- programmed rest days, approved reschedules, prescribed deloads, and protected interruptions do not create penalties;
- failed weeks with zero to two completed sessions receive direct per-session penalties and then rank-local failed-week decay;
- lifetime XP remains unchanged by missed training;
- every penalty and reversal stores exact values and an audit reason.

### Verification

- 5/5 week: zero penalties;
- 4/5 week: one direct penalty, no perfect-week bonus, half consistency credit, streak break;
- 3/5 week: two direct penalties, no failed-week decay;
- 0-2/5 week: direct penalties plus failed-week decay;
- a missed main session always costs 20 RR regardless of multiplier;
- a missed specialization session always costs 15 RR regardless of multiplier;
- rest and protected states cannot produce negative RR;
- same-week rescheduling prevents the penalty when completed;
- restoring a corrected protected state reverses the exact stored penalty;
- repository product and current-state documents were synchronized.

### Risks remaining

- direct penalties plus failed-week decay create intentionally strict low-adherence outcomes and require simulation;
- protected-state backdating remains an abuse risk;
- partial-completion and pain-interruption workflows are not yet designed;
- configuration versioning and historical migration remain undefined;
- no application implementation is authorized.

### Verdict

`COMPLETE`

The rank baseline now directly penalizes every unprotected missed scheduled workout while preserving programmed recovery and approved exceptions.

---

## 2026-08-04 — TASK-PD-004 — Weekly session swap and RR penalty audit

### Scope

- define controlled same-week day swapping;
- permit any two unlocked days to exchange scheduled contents;
- limit swap availability;
- assign a direct RR consequence;
- preserve workout identities, rest days, perfect-week logic, and missed-session penalties;
- prevent retroactive and cross-week manipulation.

### Findings

1. Same-week flexibility is useful because a schedule conflict does not necessarily mean the user cannot complete the weekly program.
2. A move-only model risks duplicate or missing sessions; an exchange model preserves exactly seven day slots, five workouts, and two rest days.
3. Free unlimited swapping would make the original schedule meaningless.
4. Treating a completed swapped session as missed would be excessive because the training work was still completed.
5. A flat penalty is clearer and less exploitable than rank-scaled swap costs.
6. Retroactive swapping after a day passes would allow missed-session penalty evasion.
7. Any-day swapping can create poor recovery order, so the app needs warnings without blocking the owner's stated flexibility.

### Accepted behavior

- a swap exchanges all scheduled contents between two distinct days in the same active Monday–Sunday week;
- workout-to-rest and workout-to-workout swaps are allowed;
- maximum confirmed swaps per week: `2`;
- each confirmed swap deducts `5 RR` immediately;
- maximum weekly swap cost: `10 RR`;
- swap penalties affect `rankRR` only and are never multiplied;
- a fully completed swapped week may still be perfect and preserve its streak;
- a confirmed swap has no free undo;
- restoring the schedule requires another valid swap and another `5 RR` deduction;
- a day locks when its workout starts, resolves, the date ends, or the week finalizes;
- locked, past, completed, cross-week, and no-op swaps are prohibited;
- the final post-swap schedule controls missed-session evaluation;
- moved sessions retain their original reward and missed-penalty values;
- recovery warnings are advisory rather than blocking;
- every swap, penalty, void, and restoration is auditable.

### Verification

- Wednesday Delts and Forearms exchanged with Sunday Rest produces Wednesday Rest and Sunday Delts and Forearms;
- the exchange costs exactly `5 RR`;
- completing Sunday avoids the `15 RR` missed-session penalty;
- missing Sunday creates an additional `15 RR` penalty;
- two confirmed swaps cost `10 RR` and block a third;
- swapping two workout days counts as one swap operation;
- swapping back consumes the second allowance and another penalty;
- five completed sessions after swaps still produce a perfect week;
- no swap can duplicate or remove a session;
- a canceled preview creates no transaction;
- historical and cross-week penalty evasion is blocked at the specification level;
- repository product and context documents were synchronized.

### Risks remaining

- `5 RR` is a balance parameter and requires simulation;
- day locking and timezone boundaries require exact implementation tests;
- advisory recovery warnings need clear UX;
- protected-state and correction backdating remain abuse risks;
- rank and schedule configuration migration remain undefined;
- no application implementation is authorized.

### Verdict

`COMPLETE`

The weekly scheduling baseline now permits controlled two-swap flexibility while preserving a direct rank consequence and the integrity of the five-session program.

---

## 2026-08-04 — TASK-PD-005 — Adonis rename and consistency multiplier recalibration

### Scope

- rename the highest rank from Titan to Adonis;
- replace the rolling six-week consistency model;
- define 1.50x, 2.00x, and 2.50x multiplier milestones at five, ten, and fifteen consecutive perfect weeks;
- reset consistency after any unprotected non-perfect week;
- preserve protected pauses, swapped perfect weeks, existing penalties, PR rewards, and streak milestones;
- determine whether Adonis remains realistically reachable at 27,300 RR.

### Findings

1. Renaming Titan to Adonis does not require a threshold or rank-count change.
2. A 2.50x cap materially accelerates progression compared with the previous 1.50x maximum.
3. Applying a new multiplier at the start of a milestone week would allow an ultimately failed week to exploit the higher rate.
4. Delaying the multiplier until the following week would not satisfy the requested Week 5, Week 10, and Week 15 milestones.
5. An auditable weekly consistency top-up resolves both problems: ordinary session awards remain immediate, but the milestone week receives the exact additional RR only after being confirmed perfect.
6. A strict reset creates substantially more volatility than the previous rolling model.
7. The existing 27,300 RR threshold remains reachable and is no longer a three-year minimum under perfect adherence.

### Accepted behavior

- highest rank renamed to `Adonis`;
- Adonis threshold remains `27,300 RR`;
- weeks 0-4 use `1.00x`;
- weeks 5-9 use `1.50x`;
- weeks 10-14 use `2.00x`;
- week 15 onward uses `2.50x`;
- 2.50x remains active while the perfect-week streak continues;
- Weeks 5, 10, and 15 receive a stored RR top-up after weekly finalization;
- any unprotected non-perfect week resets consecutive perfect weeks to zero and the active multiplier to 1.00x;
- previously finalized RR, lifetime XP, and once-earned milestone rewards are not revoked by a reset;
- a protected pause freezes the streak and multiplier;
- a five-of-five swapped week remains perfect;
- penalties remain unmultiplied;
- the threshold was not silently increased.

### Calibration

Weekly RR without PRs:

- 1.00x: `135 RR`;
- 1.50x: `192 RR`;
- 2.00x: `245 RR`;
- 2.50x: `302 RR`.

The calculation includes four main sessions, one specialization session, complete logging, and the unmultiplied perfect-week bonus.

With every week perfect, no PRs, no swaps, no misses, and existing one-time streak milestones:

- Week 15: `3,512 RR`;
- Week 52: `16,786 RR`;
- Week 86: `27,054 RR`;
- Week 87: `27,356 RR`.

Adonis is therefore reached in `87 perfect weeks`, approximately `20 months`.

At the 2.50x tier, one 4-of-5 week missing a main session creates about `103 RR` of immediate loss versus a perfect week. Rebuilding the multiplier over the next fourteen perfect weeks creates about `1,503 RR` of additional opportunity loss, for approximately `1,606 RR` total impact or five to six extra perfect weeks.

### Practical projection

- perfect or near-perfect with ordinary PRs: roughly `19-22 months`;
- occasional isolated reset: approximately `2 years` or slightly longer;
- one missed week around every 12 weeks: approximately `3 years`;
- one missed week around every 8 weeks: approximately `3.4 years`;
- one missed week around every 5 weeks: approximately `4.3 years`.

### Verification

- rank count remains 20;
- only the final rank name changed;
- multiplier values were calculated against the accepted five-session reward structure;
- one-time streak milestones were included in the highest-rank projection;
- Week 86 remains below the Adonis threshold;
- Week 87 exceeds the threshold;
- swap, miss, PR, logging, deload, protected-pause, and failed-week rules remain coherent;
- current-state, product, roadmap, README, handoff, and audit documents were synchronized;
- no application code or architecture was introduced.

### Risks remaining

- milestone top-ups increase transaction-model and UI complexity;
- full reset may feel excessively punitive after a long streak;
- the 2.50x cap makes the highest rank faster than the previous long-term pacing target;
- PR and reset frequency projections are balance estimates rather than guarantees;
- protected-state backdating remains an abuse risk;
- historical rank-configuration migration remains undefined;
- no application implementation is authorized.

### Verdict

`COMPLETE`

Adonis is realistically reachable under the accepted system. Under perfect no-PR adherence it takes approximately 87 weeks; inconsistent adherence extends the timeline substantially.

---

## 2026-08-04 — TASK-PD-006 — Ten-month Adonis rank recalibration audit

### Scope

- change the RR and rank system so Adonis is reached in approximately ten months under decent consistency;
- define decent consistency explicitly;
- preserve the accepted workout, multiplier, penalty, swap, PR, and protected-pause behavior where possible;
- recalibrate the complete rank ladder, streak milestones, and failed-week decay;
- version the new balance before implementation exists.

### Findings

1. Keeping Adonis at `27,300 RR` would require multiplying ordinary positive rewards several times, making workout payouts and penalties difficult to understand.
2. Compressing rank thresholds is cleaner because the accepted session economics remain stable.
3. A purely proportional threshold cut made early ranks too small and allowed several rank jumps in the first week.
4. A custom increasing-span ladder provides fast early feedback while preserving larger late-rank gaps.
5. Existing 24- and 52-week milestone rewards were oversized relative to the compressed ladder and could skip late ranks.
6. Existing failed-week base decay values were also oversized relative to the compressed rank spans.
7. No observed Stone Set user data exists, so the term decent consistency requires an explicit synthetic calibration profile.

### Accepted calibration profile

- 72% perfect weeks with 5 of 5 sessions;
- 23% compliant weeks with 4 of 5 sessions;
- 5% weak weeks with 3 of 5 sessions;
- approximately 93% scheduled-session completion;
- no failed 0-2-session weeks in the baseline profile;
- 76% of weeks with no swap, 22% with one swap, and 2% with two swaps;
- average rewarded PR frequency of 0.5 per week for Weeks 1-20 and 0.3 afterward;
- complete logging on all completed working sets.

### Accepted changes

- current rank configuration set to `rank-v4`;
- Adonis threshold changed from `27,300 RR` to `5,500 RR`;
- all 20 rank thresholds replaced with an increasing-span ladder;
- base session rewards, logging reward, PR reward, perfect-week bonus, multiplier tiers, reset behavior, missed-session penalties, and swap penalties retained;
- streak milestones changed to 10, 25, 50, 100, 250, and 600 RR at 2, 4, 8, 12, 24, and 52 consecutive perfect weeks;
- failed-week base decay changed to 0, 5, 10, 15, 20, 25, 30, 35, 40, and 50 RR across the rank bands;
- local decay percentages retained;
- no historical migration required because the product has no runtime or persisted scores.

### Simulation

A deterministic-seed Monte Carlo calibration used `50,000` synthetic users.

Results:

- mean time to Adonis: `42.7 weeks`;
- median: `43 weeks`;
- 25th percentile: `40 weeks`;
- 75th percentile: `46 weeks`;
- 90th percentile: `48 weeks`.

Reference pacing:

- perfect, no PRs, no swaps: approximately `23 weeks`;
- excellent consistency: approximately `30-31 weeks`;
- good consistency: approximately `36-37 weeks`;
- defined decent consistency: approximately `42-43 weeks`;
- inconsistent but regular training: approximately `52-53 weeks`.

### Verification

- rank count remains 20;
- rank names remain unchanged from Bronze I through Adonis;
- threshold gaps generally increase through the ladder;
- the defined decent profile averages approximately 93% session completion;
- 42.7 weeks is consistent with an approximately ten-month target;
- existing 5/10/15 multiplier behavior remains intact;
- non-perfect weeks still reset the multiplier;
- penalties remain unmultiplied;
- swaps and protected pauses remain coherent;
- milestone and failed-week values were checked against the compressed ladder;
- no application code, architecture, persistence, external service, or production claim was introduced.

### Risks remaining

- the ten-month result is a synthetic balance estimate rather than observed behavior;
- a perfect user can reach Adonis in approximately 23 weeks;
- strict resets may create large variation between users with similar session totals;
- PR self-reporting and protected-state backdating remain abuse risks;
- future historical migration remains undefined until persistence is designed;
- no application implementation is authorized.

### Verdict

`COMPLETE`

The `rank-v4` ladder reaches Adonis in approximately ten months on average under the explicitly defined decent-consistency profile while preserving the accepted workout reward and penalty mechanics.