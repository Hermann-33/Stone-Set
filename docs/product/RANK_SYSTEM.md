# Stone Set Workout Rank and RR System

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PD-002`

## Purpose

This document defines how Stone Set rewards workout consistency, valid personal records, complete logging, and long-term adherence.

The system takes inspiration from the Quest Tracker model supplied by the owner, especially:

- separate lifetime achievement and current-rank tracks;
- rank thresholds;
- stored award records;
- rank demotion;
- streak rewards;
- rank-local decay.

The gym version deliberately rejects daily decay, daily workout streaks, and rewards for unscheduled extra training. Those mechanics would punish prescribed rest and encourage garbage behavior.

## Design objectives

1. Consistency must be the largest controllable source of RR.
2. Valid PRs must accelerate progress without becoming mandatory every week.
3. Higher consistency must increase the RR earned from the same valid workout.
4. Rest days and prescribed recovery must never count as failure.
5. Random extra workouts must not farm RR.
6. Missing one session must not destroy months of progress.
7. Repeated low adherence must eventually reduce current rank.
8. Lifetime achievement must not decay.
9. Incorrect or fraudulent records must be reversible from stored award data.
10. The system must remain explainable from a single award breakdown.

# 1. Two progression tracks

| Track | Field | Meaning | Can decrease? |
|---|---|---|---|
| Lifetime XP | `lifetimeXP` | Valid achievement accumulated across the full account history | Only when an invalid or duplicate record is voided |
| Rank Rating | `rankRR` | Current training consistency and performance level | Yes |

```text
lifetimeXP = historical valid work
rankRR = current competitive training standing
```

`lifetimeXP` is immune to inactivity decay and missed-week penalties. It is not immune to correction of fake, duplicate, or mistakenly recorded workouts.

Rank is determined only from `rankRR`.

# 2. Rank structure

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
| 20 | Titan | 27,300 |

The thresholds are calibrated as a long-term system. Under near-perfect adherence without extraordinary PR frequency, Titan should take roughly three years rather than a few months.

## Rank calculation

```text
currentRank = highest rank whose minimumRR <= rankRR
```

## Rank progress

```text
localRR = rankRR - currentRank.minimumRR
rankSpan = nextRank.minimumRR - currentRank.minimumRR
progressPercent = clamp(localRR / rankSpan, 0, 1) * 100
rrToNextRank = max(0, nextRank.minimumRR - rankRR)
```

# 3. Scheduled session types

The accepted hypertrophy plan contains:

- four main sessions: Upper A, Lower A, Upper B, Lower B;
- one specialization session: Delts and Forearms;
- two programmed non-lifting days.

| Session type | Base XP | Base RR |
|---|---:|---:|
| Main session | 20 | 20 |
| Specialization session | 15 | 15 |
| Programmed rest day | 0 | 0 |
| Unscheduled extra workout | 0 | 0 |

An extra workout may be logged for history, but it earns no rank reward unless it was added to the active program before the session began.

# 4. Valid session completion

## Full completion

A session is fully complete when:

1. every priority exercise is completed;
2. at least 90% of prescribed working sets are completed;
3. the session respects the 60-minute hard cap;
4. no fabricated set data is present.

A valid time-cap removal of the final low-priority isolation set may still satisfy the 90% rule.

Full completion earns the full base reward and counts toward weekly adherence.

## Partial completion

A session with 70-89% of prescribed working sets completed:

- earns 50% of base XP and base RR;
- does not count as a completed scheduled session for perfect-week evaluation;
- may still retain logged performance history;
- may award a valid PR only when the PR set itself satisfies all validation rules.

## Invalid or abandoned session

A session below 70% completion:

- earns no base XP or base RR;
- does not count toward weekly adherence;
- does not receive a logging bonus;
- does not receive PR RR.

Pain-related termination is not penalized individually, but the session remains incomplete unless replaced or rescheduled under an approved plan change.

# 5. Logging reward

A fully completed session earns:

```text
+3 raw RR
+3 lifetime XP
```

only when every working set includes:

- exercise identity and equipment variant;
- load;
- repetitions;
- RIR;
- completion status.

This reward exists because the application cannot evaluate progression from incomplete data.

# 6. PR validation

A PR is exercise- and variant-specific.

The following are separate records:

- Smith incline bench press and Smith flat bench press;
- wide-grip and neutral-grip pulldowns;
- cable stacks with different machine calibration;
- different dumbbell increments;
- materially different range-of-motion or assistance variants.

The first logged performance establishes a baseline. It is not a PR.

## Qualifying PR types

### Load PR

A heavier load than the previous best, completed:

- within the exercise's prescribed repetition range;
- at or inside the prescribed RIR target;
- with comparable range of motion and technique.

### Rep PR

More repetitions than the previous best at the same load, completed:

- at the same or stricter RIR;
- with comparable range of motion and technique;
- without exceeding the prescribed repetition ceiling solely to farm RR.

## Non-qualifying events

- warm-up sets;
- assisted repetitions;
- partial repetitions presented as full repetitions;
- changed equipment or exercise variant;
- looser technique;
- materially shorter range of motion;
- body English introduced to move more load;
- manually entered historical records;
- multiple PR labels for the same exercise in one session;
- PRs during a prescribed deload.

## PR reward

```text
qualified PR = +5 raw RR and +5 lifetime XP
maximum rewarded PRs per session = 2
maximum PR reward per session = 10 raw RR
```

If one exercise creates both a load PR and rep PR in the same session, only the highest single PR reward is applied for that exercise.

# 7. Consistency multiplier

Consistency is evaluated from the six most recent eligible calendar weeks.

Each week contributes:

| Weekly result | Consistency credit |
|---|---:|
| Perfect: 5 of 5 scheduled sessions fully completed | 1.0 |
| Compliant: 4 of 5 fully completed | 0.5 |
| Weak: 3 of 5 fully completed | 0 |
| Failed: 0-2 of 5 fully completed | 0 |
| Protected pause week | excluded |

## Formula

```text
consistencyCredit =
  perfectWeeksInLast6
  + (0.5 * compliantWeeksInLast6)

consistencyMultiplier =
  min(1.50, 1.00 + 0.10 * consistencyCredit)
```

Examples:

| Last-six-week history | Credit | Multiplier |
|---|---:|---:|
| No completed history | 0 | 1.00x |
| 1 perfect week | 1.0 | 1.10x |
| 2 perfect + 1 compliant | 2.5 | 1.25x |
| 4 perfect weeks | 4.0 | 1.40x |
| 5+ perfect-equivalent credits | 5.0+ | 1.50x |

This rolling model is intentionally less brittle than resetting all reward power after one imperfect week.

# 8. Session RR formula

```text
rawSessionRR =
  baseSessionRR
  + loggingBonusRR
  + qualifiedPRBonusRR

awardedSessionRR =
  round(rawSessionRR * consistencyMultiplier)
```

Lifetime XP receives the unmultiplied raw amount:

```text
awardedLifetimeXP = rawSessionRR
```

## Example: main session, no PR

```text
base = 20
logging = 3
PR = 0
rawSessionRR = 23
```

At 1.00x consistency:

```text
awardedSessionRR = 23
```

At 1.50x consistency:

```text
awardedSessionRR = round(23 * 1.50) = 35
```

## Example: main session with two valid PRs

```text
base = 20
logging = 3
PR = 10
rawSessionRR = 33
```

At 1.50x consistency:

```text
awardedSessionRR = round(33 * 1.50) = 50
```

This directly satisfies the product requirement: the same valid workout and PR performance produces more RR after sustained consistency.

# 9. Weekly completion reward

A perfect week awards:

```text
+25 rankRR
+25 lifetimeXP
```

The weekly reward is not multiplied. Its purpose is to reward completion of the full program without distorting the consistency multiplier.

A 4-of-5 compliant week receives no weekly bonus but contributes half consistency credit.

A 3-of-5 weak week receives no bonus and no consistency credit, but it does not trigger decay.

# 10. Consecutive perfect-week milestones

Milestone rewards are awarded once per account lifetime.

| Consecutive perfect weeks | RR | Lifetime XP |
|---:|---:|---:|
| 2 | 25 | 25 |
| 4 | 60 | 60 |
| 8 | 150 | 150 |
| 12 | 250 | 250 |
| 24 | 600 | 600 |
| 52 | 1,500 | 1,500 |

A compliant 4-of-5 week breaks the perfect-week streak but remains useful to the rolling consistency multiplier.

Protected pause weeks freeze the streak. They neither extend nor break it.

# 11. Weekly rank decay

There is no daily decay.

Rank decay is evaluated only after an unprotected failed week with fewer than three fully completed scheduled sessions.

```text
rankLocalRR = max(0, rankRR - currentRank.minimumRR)
weeklyDecay = baseDecay + round(rankLocalRR * localDecayRate)
rankRR = max(0, rankRR - weeklyDecay)
```

## Decay configuration

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
| Titan | 220 | 3.50% |

Decay applies to `rankRR` only. It never reduces `lifetimeXP`.

There is no separate per-session RR penalty. Weekly decay already represents current consistency failure; stacking individual penalties would be punitive garbage.

# 12. Recovery, deload, illness, injury, and travel

## Programmed rest days

- award nothing;
- cost nothing;
- never break a streak;
- never count as inactivity.

## Prescribed deload

A deload remains a scheduled training week.

- deload sessions count as completed when the reduced prescription is completed;
- normal session and logging rewards apply;
- PR rewards are disabled;
- the perfect-week streak may continue.

## Protected pause

A training pause may be created for illness, injury, travel, or gym closure.

During the pause:

- no session RR is awarded;
- no weekly bonus is awarded;
- no decay is applied;
- the perfect-week streak is frozen;
- the week is excluded from the six-week consistency window.

A protected pause should be created before the affected week ends. Backdating requires an explicit correction record so the history remains auditable.

The app must never diagnose whether a user is medically fit to train.

# 13. Anti-farming rules

1. Only scheduled sessions earn base RR.
2. One scheduled slot can award base RR once.
3. Extra sets do not increase RR.
4. Extra workouts do not increase RR.
5. Rest days do not award RR.
6. A PR can award once per exercise per session.
7. A maximum of two PRs are rewarded per session.
8. The first recorded performance is a baseline, not a PR.
9. Changed equipment variants use separate records.
10. Deload PRs are disabled.
11. Deleted duplicates reverse stored rewards.
12. Manual score editing must create an audit event.
13. Rescheduling inside the same calendar week is permitted; duplicating the session is not.
14. The 60-minute cap remains a completion condition; finishing faster grants no extra RR.

# 14. Award record

Every completed reward must store the exact values used.

```text
sessionAward = {
  sessionId,
  scheduledSessionId,
  sessionType,
  completionRatio,
  baseXP,
  baseRR,
  loggingBonusXP,
  loggingBonusRR,
  prAwards[],
  rawLifetimeXP,
  rawSessionRR,
  consistencyCredit,
  consistencyMultiplier,
  awardedLifetimeXP,
  awardedRankRR,
  completedAt,
  sourceDataVersion,
  voidedAt,
  voidReason
}
```

Undo and correction use stored values. They never recalculate using the user's current multiplier.

# 15. Reversal rules

## Valid historical workout edited

Minor edits to notes do not alter rewards.

A load, repetition, RIR, completion, variant, or PR change triggers award revalidation and stores a correction event.

## Duplicate, accidental, or invalid workout voided

```text
lifetimeXP -= storedAward.awardedLifetimeXP
rankRR -= storedAward.awardedRankRR
```

Both values are clamped at zero.

This differs from inactivity decay: lifetime XP is permanent against time and missed training, not against invalid data.

# 16. Weekly evaluation order

```text
1. Finalize all sessions for the closing week.
2. Apply approved reschedules and corrections.
3. Determine full, partial, and invalid session states.
4. Determine weekly result: perfect, compliant, weak, failed, or protected.
5. Update rolling six-week consistency history.
6. Evaluate the consecutive perfect-week streak.
7. Award any first-time streak milestone.
8. Award the perfect-week bonus when eligible.
9. Apply rank-local decay only for an unprotected failed week.
10. Store an immutable weekly evaluation record.
11. Expose the new rank snapshot.
```

# 17. Required state

```text
lifetimeXP
rankRR
currentRank
rankHistory
sessionAwards
weeklyEvaluations
rollingConsistencyWeeks
perfectWeekStreak
awardedMilestones
exercisePRRecords
protectedPeriods
correctionEvents
```

# 18. Rank snapshot

```text
rankSnapshot = {
  lifetimeXP,
  rankRR,
  currentRankName,
  currentCL,
  nextRankName,
  rrToNextRank,
  progressPercent,
  consistencyMultiplier,
  rollingSixWeekSummary,
  perfectWeekStreak,
  nextStreakMilestone,
  projectedFailedWeekDecay
}
```

The UI must consume one canonical rank snapshot rather than reproducing rank math independently across screens.

# 19. Calibration examples

## New user, normal main session

```text
base 20 + logging 3 = 23 raw RR
multiplier = 1.00x
award = 23 RR
```

## Consistent user, normal main session

```text
base 20 + logging 3 = 23 raw RR
multiplier = 1.50x
award = 35 RR
```

## Consistent user, two valid PRs

```text
base 20 + logging 3 + PR 10 = 33 raw RR
multiplier = 1.50x
award = 50 RR
```

## Perfect week without PRs at maximum multiplier

```text
4 main sessions: 4 * round(23 * 1.50) = 140 RR
1 specialization: round(18 * 1.50) = 27 RR
perfect-week bonus = 25 RR
total = 192 RR
```

## Expected long-term pacing

With sustained near-perfect adherence and ordinary PR frequency:

- Bronze should be short;
- Silver should require several weeks;
- Gold should reflect several months;
- Platinum and Diamond should reflect long-term adherence;
- Elite and above should represent years of reliable training;
- Titan should not be casually reachable.

# 20. Non-negotiable rules

1. Rank is based on `rankRR`, not lifetime XP.
2. Lifetime XP never decays from inactivity.
3. Rest days never break consistency.
4. Daily gym streaks do not exist.
5. Consistency is evaluated against the scheduled program.
6. More consistency increases the RR multiplier.
7. PR rewards are capped and validated.
8. Additional volume does not generate additional RR.
9. High rank does not require endless PRs.
10. Rank decay occurs only after materially failed unprotected weeks.
11. Deload completion counts; deload PRs do not.
12. Protected pauses freeze rather than reward progress.
13. Award reversal uses stored values.
14. All score changes are auditable.
15. Rank configuration must be versioned before future tuning.

## Honest limitation

These numbers are product-balance parameters, not physiological laws. They must be simulated and later tuned from actual usage data without changing historical awards. Future balance changes require a new rank-config version and an explicit migration policy.