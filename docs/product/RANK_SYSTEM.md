# Stone Set Workout Rank and RR System

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PD-005`

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
10. Every score change must be explainable, versioned, and auditable.

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
| 2 | Bronze II | 150 |
| 3 | Bronze III | 300 |
| 4 | Silver I | 600 |
| 5 | Silver II | 900 |
| 6 | Silver III | 1,200 |
| 7 | Gold I | 1,800 |
| 8 | Gold II | 2,400 |
| 9 | Gold III | 3,000 |
| 10 | Platinum I | 3,900 |
| 11 | Platinum II | 4,800 |
| 12 | Platinum III | 6,000 |
| 13 | Diamond I | 7,500 |
| 14 | Diamond II | 9,000 |
| 15 | Diamond III | 10,800 |
| 16 | Elite | 12,900 |
| 17 | Champion | 15,600 |
| 18 | Apex | 18,900 |
| 19 | Prodigy | 22,800 |
| 20 | Adonis | 27,300 |

```text
currentRank = highest rank whose minimumRR <= rankRR
```

```text
localRR = rankRR - currentRank.minimumRR
rankSpan = nextRank.minimumRR - currentRank.minimumRR
progressPercent = clamp(localRR / rankSpan, 0, 1) * 100
rrToNextRank = max(0, nextRank.minimumRR - rankRR)
```

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

Consistency is based on consecutive perfect weeks, not a rolling six-week window.

A perfect week means all five scheduled sessions are fully completed after valid swaps and protected-state resolution.

| Consecutive perfect weeks | Session RR multiplier |
|---:|---:|
| 0-4 | 1.00x |
| 5-9 | 1.50x |
| 10-14 | 2.00x |
| 15+ | 2.50x |

The multiplier is capped permanently at `2.50x` while the perfect-week streak continues.

## Milestone-week top-up

The fifth, tenth, and fifteenth perfect weeks must receive the newly unlocked multiplier without granting the higher multiplier to a week that later fails.

During the week, sessions earn using the multiplier active at the beginning of the week. At weekly finalization:

1. if the week is not perfect, no top-up is awarded and the streak resets;
2. if the week is perfect and reaches week 5, 10, or 15, the app awards a consistency top-up equal to the difference between session RR already awarded and the RR those sessions would have earned at the newly unlocked multiplier;
3. the newly unlocked multiplier then remains active for following weeks while the streak continues.

```text
consistencyTopUpRR =
  sum(sessionRRAtNewMultiplier - sessionRRAwarded)
```

The perfect-week bonus and streak milestone rewards are not multiplied and are excluded from the top-up.

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

The reset occurs at weekly finalization. RR validly earned in earlier finalized weeks is never clawed back.

A protected pause freezes the streak and multiplier. It does not advance or reset either value.

A swapped week remains perfect when all five final scheduled sessions are fully completed.

# 10. Session reward formula

```text
rawSessionRR =
  baseSessionRR
  + loggingBonusRR
  + qualifiedPRBonusRR

awardedSessionRR =
  round(rawSessionRR * activeConsistencyMultiplier)

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
| 2 | 25 | 25 |
| 4 | 60 | 60 |
| 8 | 150 | 150 |
| 12 | 250 | 250 |
| 24 | 600 | 600 |
| 52 | 1,500 | 1,500 |

A reset does not revoke an already earned milestone and does not allow it to be farmed again.

# 13. Failed-week decay

There is no daily decay.

Additional rank-local decay applies only after an unprotected failed week with fewer than three fully completed scheduled sessions.

```text
rankLocalRR = max(0, rankRR - currentRank.minimumRR)
weeklyDecay = baseDecay + round(rankLocalRR * localDecayRate)
rankRR = max(0, rankRR - weeklyDecay)
```

Direct missed-session penalties are applied before failed-week decay.

| Rank band | Base decay | Local rate |
|---|---:|---:|
| Bronze | 0 | 0% |
| Silver | 10 | 1.00% |
| Gold | 20 | 1.25% |
| Platinum | 35 | 1.50% |
| Diamond | 50 | 1.75% |
| Elite | 75 | 2.00% |
| Champion | 100 | 2.25% |
| Apex | 130 | 2.50% |
| Prodigy | 170 | 3.00% |
| Adonis | 220 | 3.50% |

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
  projectedFailedWeekDecay
}
```

# 20. Adonis calibration

Assumptions for the clean baseline calculation:

- every week is perfect;
- every working set is completely logged;
- no PR rewards;
- no swaps;
- no missed-session penalties;
- existing one-time streak milestones remain active.

## Weekly RR without PRs

| Multiplier | Weekly RR |
|---:|---:|
| 1.00x | 135 |
| 1.50x | 192 |
| 2.00x | 245 |
| 2.50x | 302 |

The calculation includes four main sessions, one specialization session, complete logging, and the unmultiplied `25 RR` perfect-week bonus.

## Fastest no-PR path

Under uninterrupted perfect adherence:

- cumulative RR after Week 15: `3,512`;
- cumulative RR after Week 52: `16,786`;
- cumulative RR after Week 86: `27,054`;
- cumulative RR after Week 87: `27,356`.

Therefore the current `27,300 RR` Adonis threshold is reachable in approximately:

```text
87 perfect weeks
about 20 months
```

Valid PRs can reduce the time modestly. Frequent resets increase it substantially.

## Cost of one reset at 2.50x

A 4-of-5 week missing one main session at `2.50x`, before PRs:

```text
completed-session RR = 219
missed-session penalty = -20
weekly net = 199 RR
```

A perfect `2.50x` week produces `302 RR`, so the immediate difference is `103 RR`.

Rebuilding through the first fourteen perfect weeks after reset produces approximately `1,503 RR` less than remaining at `2.50x` for those weeks.

Approximate total effect:

```text
one reset near maximum multiplier = about 1,606 RR of lost progress
approximately 5-6 additional perfect weeks
```

## Practical interpretation

- Perfect or near-perfect adherence with ordinary PRs: roughly `19-22 months`.
- An occasional isolated reset: approximately `2 years` or slightly longer.
- A missed week around every 12 weeks: approximately `3 years`.
- A missed week around every 8 weeks: approximately `3.4 years`.
- A missed week around every 5 weeks: approximately `4.3 years`.

Adonis is realistically reachable. The new multiplier makes it materially easier than the previous design. The threshold should be increased later only if the owner wants Adonis to remain a three-year minimum even under perfect consistency.

# 21. Non-negotiable rules

1. Rank is based on `rankRR`, not lifetime XP.
2. Highest rank is `Adonis` at `27,300 RR`.
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
18. Future balance changes require a new rank-config version and explicit migration policy.

## Honest limitation

These values are game-balance parameters, not physiological laws. The 19-22 month projection assumes unusually strong adherence. Real use must be simulated and later tuned without silently rewriting historical awards.