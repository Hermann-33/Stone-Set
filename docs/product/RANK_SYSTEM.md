# Stone Set Workout Rank and RR System

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PD-006`
Rank configuration: `rank-v4`

## Purpose

This document defines how Stone Set rewards valid scheduled training, complete logging, legitimate personal records, and uninterrupted weekly consistency while penalizing schedule swaps, missed sessions, and collapsed adherence.

Scheduling mechanics are defined in `docs/product/WEEKLY_SCHEDULING.md`. This document owns all RR consequences.

## Design objectives

1. Consistency must be the strongest controllable source of RR.
2. Long uninterrupted consistency must materially accelerate rank progression.
3. Any unprotected non-perfect week must reset the consistency multiplier.
4. A missed scheduled workout must directly reduce RR.
5. A confirmed schedule swap must cost RR but remain less severe than missing the workout.
6. Valid PRs must accelerate progress without becoming mandatory every week.
7. Programmed rest, prescribed deloads, and approved protected pauses must not be treated as failure.
8. Extra workouts and extra sets must not farm RR.
9. Lifetime achievement must not decay from inactivity.
10. A user with defined decent consistency should reach Adonis in approximately ten months.
11. Every score change must be explainable, versioned, and auditable.

# 1. Progression tracks

| Track | Field | Meaning | Can decrease? |
|---|---|---|---|
| Lifetime XP | `lifetimeXP` | Valid historical training achievement | Only when invalid or duplicate data is voided |
| Rank Rating | `rankRR` | Current competitive training standing | Yes |

```text
lifetimeXP = historical valid work
rankRR = current rank position
```

Missed-session penalties, swap penalties, and failed-week decay affect `rankRR` only.

# 2. Rank ladder

| CL | Rank | Minimum RR |
|---:|---|---:|
| 1 | Bronze I | 0 |
| 2 | Bronze II | 100 |
| 3 | Bronze III | 200 |
| 4 | Silver I | 325 |
| 5 | Silver II | 475 |
| 6 | Silver III | 650 |
| 7 | Gold I | 825 |
| 8 | Gold II | 1,025 |
| 9 | Gold III | 1,250 |
| 10 | Platinum I | 1,500 |
| 11 | Platinum II | 1,775 |
| 12 | Platinum III | 2,075 |
| 13 | Diamond I | 2,400 |
| 14 | Diamond II | 2,750 |
| 15 | Diamond III | 3,125 |
| 16 | Elite | 3,525 |
| 17 | Champion | 3,950 |
| 18 | Apex | 4,400 |
| 19 | Prodigy | 4,900 |
| 20 | Adonis | 5,500 |

```text
currentRank = highest rank whose minimumRR <= rankRR
```

```text
localRR = rankRR - currentRank.minimumRR
rankSpan = nextRank.minimumRR - currentRank.minimumRR
progressPercent = clamp(localRR / rankSpan, 0, 1) * 100
rrToNextRank = max(0, nextRank.minimumRR - rankRR)
```

The ladder is deliberately compressed compared with the previous `27,300 RR` design. Session rewards remain understandable; the target duration is controlled primarily through rank thresholds rather than inflated workout payouts.

# 3. Session values

| Session type | Base XP | Base RR | Missed penalty |
|---|---:|---:|---:|
| Main session | 20 | 20 | -20 RR |
| Specialization session | 15 | 15 | -15 RR |
| Programmed rest day | 0 | 0 | 0 |
| Unscheduled extra workout | 0 | 0 | 0 |

The consistency multiplier affects earned session RR only. It never multiplies a penalty.

# 4. Session resolution

## Fully completed

A session is fully completed when:

1. every priority exercise is completed;
2. at least 90% of prescribed working sets are completed;
3. the session respects the 60-minute cap;
4. required set data is not fabricated.

A legitimate time-cap removal of the final low-priority isolation set may still satisfy the 90% requirement.

## Partially completed

A session with 70-89% of prescribed working sets completed:

- earns 50% of base XP and base RR;
- does not receive a missed-session penalty;
- does not count as fully completed for weekly consistency;
- resets the perfect-week consistency streak at weekly finalization;
- may award a valid PR when the PR set satisfies every validation rule.

## Missed or invalid

A session below 70% completion, or not started by weekly finalization:

- earns no base XP or RR;
- earns no logging or PR reward;
- receives its direct missed-session penalty;
- does not count as completed for weekly consistency.

## Protected interruption

An approved pain, acute-illness, gym-closure, travel, or equivalent protected event:

- creates no missed-session penalty;
- requires an auditable reason;
- freezes rather than resets the consistency streak when the full week is protected;
- does not allow the app to diagnose medical fitness.

# 5. Missed-session penalties

```text
missedSessionPenaltyRR = scheduledSession.baseRR
rankRR = max(0, rankRR - missedSessionPenaltyRR)
```

```text
missed main session = -20 RR
missed specialization session = -15 RR
```

Penalties apply once at weekly finalization after the final post-swap schedule, approved protections, and corrections are resolved.

Missed training never reduces `lifetimeXP`.

# 6. Swap penalties

Every confirmed same-week day swap deducts:

```text
swapPenaltyRR = 5
rankRR = max(0, rankRR - 5)
```

Rules:

- maximum two confirmed swaps per week;
- maximum weekly swap cost: `10 RR`;
- swap penalties are immediate and never multiplied;
- swapping back is a second swap and costs another `5 RR`;
- a canceled preview creates no transaction;
- a week may still be perfect after swaps when all five sessions are fully completed;
- only an auditable correction may void a confirmed swap and restore its exact stored RR.

# 7. Complete logging reward

A fully completed session earns:

```text
+3 raw RR
+3 lifetime XP
```

only when every working set records exercise variant, load, repetitions, RIR, and completion status.

# 8. PR validation and reward

The first recorded performance establishes a baseline and is not a PR.

A valid PR must use the same exercise and equipment variant with comparable technique and range of motion.

## Load PR

A heavier load than the previous best, completed within the prescribed repetition and RIR targets.

## Rep PR

More repetitions than the previous best at the same load, completed at the same or stricter RIR without exceeding the programmed ceiling solely to farm RR.

## Non-qualifying events

- warm-up sets;
- assisted or partial repetitions;
- changed equipment or exercise variants;
- looser technique or reduced range of motion;
- manually entered historical records;
- multiple PR labels for the same exercise in one session;
- PRs during a prescribed deload.

```text
qualified PR = +5 raw RR and +5 lifetime XP
maximum rewarded PRs per session = 2
maximum PR reward per session = 10 raw RR
```

One exercise can earn only one PR reward in a session.

# 9. Resettable consistency multiplier

Consistency is based on consecutive perfect weeks.

A perfect week means all five scheduled sessions are fully completed after valid swaps and protected-state resolution.

| Consecutive perfect weeks | Session RR multiplier |
|---:|---:|
| 0-4 | 1.00x |
| 5-9 | 1.50x |
| 10-14 | 2.00x |
| 15+ | 2.50x |

The multiplier remains capped at `2.50x` while the perfect-week streak continues.

## Milestone-week top-up

The fifth, tenth, and fifteenth perfect weeks receive the newly unlocked multiplier only after weekly finalization confirms the week is perfect.

```text
consistencyTopUpRR =
  sum(sessionRRAtNewMultiplier - sessionRRAwarded)
```

The perfect-week bonus and streak milestone rewards are excluded from the top-up.

## Reset rule

Any unprotected non-perfect week resets:

```text
consecutivePerfectWeeks = 0
activeConsistencyMultiplier = 1.00x
```

Resetting events include:

- 4 of 5 completed;
- 3 of 5 completed;
- 0-2 of 5 completed;
- any unprotected partial, missed, or invalid scheduled session.

RR validly earned in earlier finalized weeks is never clawed back.

A protected pause freezes the streak and multiplier. A swapped week remains perfect when all five final scheduled sessions are fully completed.

# 10. Session reward formula

```text
rawSessionRR =
  baseSessionRR
  + loggingBonusRR
  + qualifiedPRBonusRR

awardedSessionRR =
  roundHalfUp(rawSessionRR * activeConsistencyMultiplier)

awardedLifetimeXP = rawSessionRR
```

## Normal main session

| Multiplier | RR |
|---:|---:|
| 1.00x | 23 |
| 1.50x | 35 |
| 2.00x | 46 |
| 2.50x | 58 |

## Normal specialization session

| Multiplier | RR |
|---:|---:|
| 1.00x | 18 |
| 1.50x | 27 |
| 2.00x | 36 |
| 2.50x | 45 |

# 11. Weekly completion reward

A perfect week awards:

```text
+25 rankRR
+25 lifetimeXP
```

The bonus is not multiplied.

A non-perfect week receives no perfect-week bonus and resets the consistency multiplier unless the week is protected.

# 12. Consecutive perfect-week milestones

Milestones are awarded once per account lifetime.

| Consecutive perfect weeks | RR | Lifetime XP |
|---:|---:|---:|
| 2 | 10 | 10 |
| 4 | 25 | 25 |
| 8 | 50 | 50 |
| 12 | 100 | 100 |
| 24 | 250 | 250 |
| 52 | 600 | 600 |

A reset does not revoke an already earned milestone and does not allow it to be farmed again.

These values were reduced with the compressed ladder so one milestone does not skip several late ranks.

# 13. Failed-week decay

There is no daily decay.

Additional rank-local decay applies only after an unprotected failed week with fewer than three fully completed scheduled sessions.

```text
rankLocalRR = max(0, rankRR - currentRank.minimumRR)
weeklyDecay = baseDecay + roundHalfUp(rankLocalRR * localDecayRate)
rankRR = max(0, rankRR - weeklyDecay)
```

Direct missed-session penalties are applied before failed-week decay.

| Rank band | Base decay | Local rate |
|---|---:|---:|
| Bronze | 0 | 0% |
| Silver | 5 | 1.00% |
| Gold | 10 | 1.25% |
| Platinum | 15 | 1.50% |
| Diamond | 20 | 1.75% |
| Elite | 25 | 2.00% |
| Champion | 30 | 2.25% |
| Apex | 35 | 2.50% |
| Prodigy | 40 | 3.00% |
| Adonis | 50 | 3.50% |

# 14. Recovery and schedule protection

## Programmed rest

Rest days award nothing, cost nothing, and never affect consistency.

## Approved swaps

A valid swap changes dates, not session identity. Completing all five final sessions preserves a perfect week, but each confirmed swap retains its `-5 RR` cost.

## Prescribed deload

Completing the reduced prescription counts as a fully completed scheduled session. Base and logging rewards apply; PR rewards are disabled.

## Protected pause

An approved pause:

- awards no session or weekly reward;
- applies no missed-session penalty or failed-week decay;
- freezes the perfect-week streak and multiplier;
- is excluded from streak progression;
- requires auditable backdating when entered after the fact.

# 15. Anti-farming rules

1. Only scheduled sessions earn base RR.
2. A scheduled slot can award once.
3. Extra sets and extra workouts earn no RR.
4. Rest days award and lose no RR.
5. A PR can award once per exercise per session.
6. A maximum of two PRs are rewarded per session.
7. The first record is a baseline, not a PR.
8. Changed variants maintain separate PR histories.
9. Deload PRs are disabled.
10. Duplicate or invalid records reverse stored rewards.
11. Swaps cannot duplicate or erase sessions.
12. A missed session creates at most one direct penalty.
13. Consistency milestones are awarded once.
14. A reset cannot be avoided by retroactively swapping a locked day.
15. All manual score corrections create audit events.

# 16. Required records

## Session award

```text
sessionAward = {
  sessionId,
  scheduledSessionId,
  sessionType,
  rawSessionRR,
  consistencyMultiplier,
  awardedLifetimeXP,
  awardedRankRR,
  prAwards[],
  completedAt,
  rankConfigVersion,
  voidedAt,
  voidReason
}
```

## Consistency top-up

```text
consistencyTopUp = {
  weekId,
  milestoneWeek,
  previousMultiplier,
  unlockedMultiplier,
  eligibleSessionAwardIds[],
  topUpRR,
  finalizedAt,
  rankConfigVersion
}
```

## Penalty records

```text
missedSessionPenalty = {
  scheduledSessionId,
  penaltyRR,
  finalizedAt,
  reason,
  rankConfigVersion,
  reversedAt,
  reversalReason
}
```

```text
swapPenalty = {
  swapId,
  penaltyRR: 5,
  appliedAt,
  rankConfigVersion,
  voidedAt,
  voidReason
}
```

Reversal always uses stored values. It never recalculates using the current multiplier or configuration.

# 17. Weekly evaluation order

```text
1. Finalize the post-swap schedule.
2. Apply approved protected states and corrections.
3. Resolve every scheduled session.
4. Apply direct penalties for unprotected missed or invalid sessions.
5. Determine whether the week is perfect, non-perfect, failed, or protected.
6. If perfect, increment the consecutive-perfect-week streak.
7. If perfect and reaching week 5, 10, or 15, award the exact consistency top-up.
8. If non-perfect, reset the streak and multiplier to zero weeks / 1.00x.
9. Award first-time streak milestones when eligible.
10. Award the perfect-week bonus when eligible.
11. Apply rank-local decay only for an unprotected failed week.
12. Store an immutable weekly evaluation.
13. Expose the new rank snapshot.
```

# 18. Required state

```text
lifetimeXP
rankRR
rankHistory
sessionAwards
consistencyTopUps
missedSessionPenalties
swapPenalties
weeklyEvaluations
consecutivePerfectWeeks
activeConsistencyMultiplier
awardedMilestones
exercisePRRecords
protectedPeriods
correctionEvents
rankConfigVersion
```

# 19. Rank snapshot

```text
rankSnapshot = {
  lifetimeXP,
  rankRR,
  currentRankName,
  currentCL,
  nextRankName,
  rrToNextRank,
  progressPercent,
  consecutivePerfectWeeks,
  activeConsistencyMultiplier,
  nextMultiplierUnlockWeek,
  perfectWeekStreak,
  pendingPenalties,
  projectedFailedWeekDecay,
  rankConfigVersion
}
```

# 20. Ten-month Adonis calibration

Ten months is modeled as approximately `43 weeks`.

This is a synthetic product-balance profile, not observed population data.

## Defined decent-consistency profile

Across many simulated weeks:

- 72% of weeks are perfect: 5 of 5 sessions;
- 23% are compliant: 4 of 5 sessions;
- 5% are weak: 3 of 5 sessions;
- no failed 0-2-session weeks are included in the baseline profile;
- expected scheduled-session completion is approximately 93%;
- 76% of weeks use no swap, 22% use one swap, and 2% use two swaps;
- expected rewarded PR frequency is 0.5 per week for Weeks 1-20 and 0.3 per week afterward;
- all completed working sets are fully logged.

## Simulation result

A deterministic-seed Monte Carlo calibration using `50,000` simulated users produced:

| Result | Weeks to Adonis |
|---|---:|
| Mean | 42.7 |
| Median | 43 |
| 25th percentile | 40 |
| 75th percentile | 46 |
| 90th percentile | 48 |

Therefore `Adonis = 5,500 RR` satisfies the requested average target of approximately ten months under the defined decent-consistency profile.

## Reference pacing

| Profile | Approximate mean time |
|---|---:|
| Perfect, no PRs, no swaps | 23 weeks |
| Excellent consistency | 30-31 weeks |
| Good consistency | 36-37 weeks |
| Defined decent consistency | 42-43 weeks |
| Inconsistent but still training regularly | 52-53 weeks |

These are balance estimates, not guarantees. Actual time depends on completed sessions, resets, PR frequency, swaps, penalties, and failed-week decay.

# 21. Configuration activation

`rank-v4` supersedes the previous pre-implementation rank balance.

No historical migration is required because Stone Set has no application runtime, persisted user score, or production award history yet.

Future balance changes must create a new rank configuration version and an explicit migration policy before historical data exists.

# 22. Non-negotiable rules

1. Rank is based on `rankRR`, not lifetime XP.
2. Highest rank is `Adonis` at `5,500 RR`.
3. Maximum consistency multiplier is `2.50x`.
4. Five perfect weeks unlock `1.50x`.
5. Ten perfect weeks unlock `2.00x`.
6. Fifteen perfect weeks unlock `2.50x`.
7. Any unprotected non-perfect week resets the streak and multiplier.
8. Protected pauses freeze rather than reset consistency.
9. Completed swapped weeks may remain perfect.
10. Main-session misses cost `20 RR`; specialization misses cost `15 RR`.
11. Confirmed swaps cost `5 RR` each, maximum two per week.
12. Penalties are never multiplied.
13. PR rewards are capped and validated.
14. Extra volume and extra workouts earn no RR.
15. Failed weeks receive direct penalties plus rank-local decay.
16. Award and penalty reversals use stored values.
17. All score changes are auditable.
18. Future balance changes require a new rank configuration version and explicit migration policy.

## Honest limitation

The ten-month target depends on the stated synthetic definition of decent consistency. Stone Set has no real usage data yet. The model must be reviewed after enough actual weeks have been logged, without silently rewriting historical awards.