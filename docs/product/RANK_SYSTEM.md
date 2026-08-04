# Stone Set Workout Rank and RR System

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PD-004`

## Purpose

This document defines how Stone Set rewards workout consistency, valid personal records, complete logging, and long-term adherence while penalizing unprotected missed sessions and confirmed schedule swaps.

The scheduling mechanics are defined in `docs/product/WEEKLY_SCHEDULING.md`. This document owns the RR consequences.

## Design objectives

1. Consistency must be the largest controllable source of RR.
2. A missed scheduled workout must directly reduce RR.
3. A confirmed weekly schedule swap must reduce RR without being treated as severely as missing the workout.
4. Valid PRs must accelerate progress without becoming mandatory every week.
5. Higher consistency must increase RR earned from valid workouts.
6. Rest days and prescribed recovery must never count as failure.
7. Random extra workouts and extra sets must not farm RR.
8. Repeated low adherence must create demotion pressure.
9. Lifetime achievement must not decay from inactivity.
10. Every score change must be explainable and auditable.

# 1. Two progression tracks

| Track | Field | Meaning | Can decrease? |
|---|---|---|---|
| Lifetime XP | `lifetimeXP` | Valid achievement accumulated across account history | Only when invalid or duplicate data is voided |
| Rank Rating | `rankRR` | Current training consistency and performance level | Yes |

```text
lifetimeXP = historical valid work
rankRR = current competitive training standing
```

Missed-session penalties, swap penalties, and failed-week decay affect `rankRR` only.

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

Under near-perfect adherence without extraordinary PR frequency, Titan should require years rather than months.

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

# 3. Session types and base values

The accepted program contains four main sessions, one specialization session, and two programmed non-lifting days.

| Session type | Base XP | Base RR | Missed-session penalty |
|---|---:|---:|---:|
| Main session | 20 | 20 | -20 RR |
| Specialization session | 15 | 15 | -15 RR |
| Programmed rest day | 0 | 0 | 0 |
| Unscheduled extra workout | 0 | 0 | 0 |

The missed-session penalty equals the unmultiplied base RR of that session.

The consistency multiplier never amplifies penalties.

# 4. Session resolution states

Every scheduled workout must finish the week in exactly one state.

## Fully completed

A session is fully completed when:

1. every priority exercise is completed;
2. at least 90% of prescribed working sets are completed;
3. the session respects the 60-minute cap;
4. required set data is not fabricated.

A legitimate time-cap removal of the final low-priority isolation set may still satisfy the 90% rule.

Full completion earns full base rewards and counts toward weekly adherence.

## Partially completed

A session with 70-89% of prescribed working sets completed:

- earns 50% of base XP and base RR;
- receives no logging bonus unless all completed sets are fully logged;
- does not count as fully completed for perfect-week evaluation;
- does not receive a missed-session penalty;
- may award a valid PR when the PR set satisfies every validation rule.

## Missed or invalid

A scheduled session below 70% completion, or not started by weekly finalization:

- earns no base XP or RR;
- earns no logging bonus;
- earns no PR reward;
- receives the session's direct missed-session penalty;
- does not count as completed for weekly adherence.

## Protected interruption

A workout stopped because of pain, acute illness, gym closure, or another approved protected event:

- earns no reward unless it meets partial-completion requirements;
- receives no missed-session penalty;
- requires a recorded reason;
- does not allow the app to diagnose medical fitness.

# 5. Missed-session penalty

```text
missedSessionPenaltyRR = scheduledSession.baseRR
rankRR = max(0, rankRR - missedSessionPenaltyRR)
```

Examples:

```text
missed Upper A = -20 RR
missed Lower A = -20 RR
missed Delts and Forearms = -15 RR
missed Upper B = -20 RR
missed Lower B = -20 RR
```

The penalty is applied once at weekly finalization after the final post-swap schedule, protected states, and corrections are resolved.

A 4-of-5 week missing one main session causes:

- `-20 RR` direct penalty;
- no perfect-week bonus;
- only `0.5` consistency credit;
- perfect-week streak termination;
- loss of the unearned session, logging, and PR rewards.

Missed-session penalties never reduce `lifetimeXP`.

# 6. Confirmed-swap penalty

Weekly swap mechanics are defined in `docs/product/WEEKLY_SCHEDULING.md`.

Each confirmed swap deducts:

```text
swapPenaltyRR = 5
rankRR = max(0, rankRR - 5)
```

Rules:

- maximum confirmed swaps per week: `2`;
- maximum direct swap cost per week: `10 RR`;
- the penalty applies immediately when the swap is confirmed;
- it affects `rankRR` only;
- it never reduces `lifetimeXP`;
- it is never multiplied by consistency;
- one swap operation costs `5 RR` whether it exchanges workout-to-rest or workout-to-workout;
- swapping the same two days back is a second swap and costs another `5 RR`;
- a canceled preview does not consume a swap or deduct RR;
- only an auditable system correction may void a confirmed swap and restore its exact stored RR.

## Perfect-week interaction

A week with one or two swaps can still be perfect when all five scheduled sessions are fully completed on their final assigned dates.

Such a week:

- receives `1.0` consistency credit;
- may advance the perfect-week streak;
- may receive the perfect-week bonus;
- retains every applied swap penalty.

The swap penalty accounts for schedule deviation. Completion credit still reflects adherence to the full weekly program.

## Swap followed by a miss

A swap penalty and missed-session penalty are separate.

Example: Delts and Forearms moves from Wednesday to Sunday.

```text
confirmed swap = -5 RR
Sunday specialization session missed = -15 RR
total direct loss = -20 RR
```

# 7. Complete logging reward

A fully completed session earns:

```text
+3 raw RR
+3 lifetime XP
```

only when every working set records:

- exercise and equipment variant;
- load;
- repetitions;
- RIR;
- completion status.

# 8. PR validation

A PR is exercise- and variant-specific.

The first logged performance establishes a baseline. It is not a PR.

## Load PR

A heavier load than the previous best, completed:

- within the prescribed repetition range;
- at or inside the prescribed RIR target;
- with comparable range of motion and technique.

## Rep PR

More repetitions than the previous best at the same load, completed:

- at the same or stricter RIR;
- with comparable range of motion and technique;
- without exceeding the prescribed repetition ceiling solely to farm RR.

## Non-qualifying events

- warm-up sets;
- assisted or partial repetitions;
- changed equipment or exercise variants;
- looser technique or materially shorter range of motion;
- manually entered historical records;
- multiple PR labels for the same exercise in one session;
- PRs during a prescribed deload.

## PR reward

```text
qualified PR = +5 raw RR and +5 lifetime XP
maximum rewarded PRs per session = 2
maximum PR reward per session = 10 raw RR
```

One exercise can earn only one PR reward in a session even if it creates both a load and repetition record.

# 9. Consistency multiplier

Consistency is evaluated from the six most recent eligible calendar weeks.

| Weekly result | Consistency credit |
|---|---:|
| Perfect: 5 of 5 fully completed | 1.0 |
| Compliant: 4 of 5 fully completed | 0.5 |
| Weak: 3 of 5 fully completed | 0 |
| Failed: 0-2 of 5 fully completed | 0 |
| Protected pause week | Excluded |

```text
consistencyCredit =
  perfectWeeksInLast6
  + (0.5 * compliantWeeksInLast6)

consistencyMultiplier =
  min(1.50, 1.00 + 0.10 * consistencyCredit)
```

| Consistency credit | Multiplier |
|---:|---:|
| 0 | 1.00x |
| 1 | 1.10x |
| 2 | 1.20x |
| 3 | 1.30x |
| 4 | 1.40x |
| 5 or more | 1.50x |

Five perfect weeks are the fastest route to `1.50x`. The multiplier becomes active after Week 5 is finalized and applies from Week 6.

Swap penalties do not reduce consistency credit when all five sessions are completed.

# 10. Session reward formula

```text
rawSessionRR =
  baseSessionRR
  + loggingBonusRR
  + qualifiedPRBonusRR

awardedSessionRR =
  round(rawSessionRR * consistencyMultiplier)

awardedLifetimeXP = rawSessionRR
```

## Normal main session

```text
base = 20
logging = 3
PR = 0
raw = 23
```

- At `1.00x`: `23 RR`
- At `1.50x`: `35 RR`

## Main session with two valid PRs

```text
base = 20
logging = 3
PR = 10
raw = 33
```

- At `1.50x`: `50 RR`

# 11. Weekly classification and rewards

## Perfect week: 5 of 5

- awards `+25 RR` and `+25 lifetimeXP`;
- contributes `1.0` consistency credit;
- advances the perfect-week streak;
- receives no missed-session penalties;
- may contain up to two valid swaps, whose direct penalties remain applied.

## Compliant week: 4 of 5

- contributes `0.5` consistency credit;
- receives no perfect-week bonus;
- breaks the perfect-week streak;
- applies the direct penalty for the missed session;
- retains any swap penalties already applied.

## Weak week: 3 of 5

- contributes no consistency credit;
- receives no perfect-week bonus;
- breaks the perfect-week streak;
- applies direct penalties for both missed sessions;
- does not trigger additional failed-week decay;
- retains any swap penalties already applied.

## Failed week: 0-2 of 5

- contributes no consistency credit;
- receives no perfect-week bonus;
- breaks the perfect-week streak;
- applies a direct penalty for every missed session;
- triggers rank-local failed-week decay;
- retains any swap penalties already applied.

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

A compliant week breaks the perfect-week streak.

A perfect week containing valid swaps does not break the streak because the full program was completed; the swap deductions already supply the consequence.

Protected pause weeks freeze the streak. They neither extend nor break it.

# 13. Failed-week rank decay

There is no daily decay.

Additional rank-local decay applies only after an unprotected failed week with fewer than three fully completed scheduled sessions.

```text
rankLocalRR = max(0, rankRR - currentRank.minimumRR)
weeklyDecay = baseDecay + round(rankLocalRR * localDecayRate)
rankRR = max(0, rankRR - weeklyDecay)
```

Direct swap penalties and missed-session penalties are applied before failed-week decay. Decay is calculated from the resulting RR.

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

The layers serve different purposes:

- swap penalty: accountability for changing the original weekly schedule;
- missed-session penalty: accountability for skipping a required workout;
- failed-week decay: demotion pressure when adherence collapses across the week.

None affects lifetime XP.

# 14. Recovery and protected states

## Programmed rest days

- award nothing;
- cost nothing;
- never break consistency;
- never count as missed training.

## Confirmed swap

A valid swap:

- follows `docs/product/WEEKLY_SCHEDULING.md`;
- costs `5 RR` immediately;
- changes session dates without changing session identity;
- prevents a missed-session penalty when the moved session is completed;
- does not erase the swap penalty after completion.

## Prescribed deload

- reduced sessions count when the reduced prescription is completed;
- normal base and logging rewards apply;
- PR rewards are disabled;
- the perfect-week streak may continue;
- a user-confirmed date swap during the deload still costs `5 RR`.

## Protected pause

A pause may cover illness, injury, travel, or gym closure.

During an approved pause:

- no session reward is awarded;
- no missed-session penalty is applied;
- no failed-week decay is applied;
- the perfect-week streak is frozen;
- affected time is excluded from the consistency window.

A protected pause does not automatically refund a previously confirmed user swap. A refund requires an auditable correction that voids the swap itself.

# 15. Anti-farming and anti-evasion rules

1. Only scheduled sessions earn base RR.
2. One scheduled session identity can award once.
3. Extra sets do not increase RR.
4. Extra workouts do not increase RR.
5. Rest days do not award or lose RR.
6. A PR can award once per exercise per session.
7. A maximum of two PRs are rewarded per session.
8. The first record is a baseline, not a PR.
9. Changed equipment variants use separate records.
10. Deload PRs are disabled.
11. Deleted duplicates reverse stored rewards.
12. Manual score edits create audit events.
13. Maximum two confirmed swaps per week.
14. Retroactive swaps are prohibited.
15. Swapping back consumes another swap and another `5 RR`.
16. Swaps cannot duplicate, remove, or move sessions across weeks.
17. Finishing faster than 60 minutes gives no extra RR.
18. A missed session can create only one direct penalty record.

# 16. Records and reversals

## Session award record

```text
sessionAward = {
  sessionId,
  scheduledSessionId,
  sessionType,
  finalScheduledDate,
  completionRatio,
  baseXP,
  baseRR,
  loggingBonusXP,
  loggingBonusRR,
  prAwards[],
  rawLifetimeXP,
  rawSessionRR,
  consistencyMultiplier,
  awardedLifetimeXP,
  awardedRankRR,
  completedAt,
  rankConfigVersion,
  scheduleConfigVersion,
  voidedAt,
  voidReason
}
```

## Swap penalty record

```text
swapPenalty = {
  swapId,
  weekId,
  swapNumber,
  firstDate,
  secondDate,
  requestedPenaltyRR: 5,
  appliedPenaltyRR,
  rankRRBefore,
  rankRRAfter,
  confirmedAt,
  rankConfigVersion,
  scheduleConfigVersion,
  reversedAt,
  reversalReason,
  restoredRR
}
```

## Missed-session penalty record

```text
missedSessionPenalty = {
  scheduledSessionId,
  sessionType,
  originalScheduledDate,
  finalScheduledDate,
  penaltyRR,
  finalizedAt,
  reason: "unprotected_missed_session",
  rankConfigVersion,
  scheduleConfigVersion,
  reversedAt,
  reversalReason
}
```

Undo and correction use stored values. They never recalculate using the current multiplier or configuration.

Voiding an invalid workout reverses its stored lifetime XP and RR.

Voiding an invalid swap restores its exact stored applied penalty and creates a correction event.

Approving a previously penalized protection restores the exact stored missed-session penalty and creates a correction event.

# 17. Weekly evaluation order

```text
1. Lock the final post-swap weekly schedule.
2. Validate swap count, swap records, and schedule integrity.
3. Apply approved corrections and protected states.
4. Resolve full, partial, missed, invalid, and protected session states against final dates.
5. Apply one direct RR penalty for each unprotected missed or invalid session.
6. Determine weekly result: perfect, compliant, weak, failed, or protected.
7. Update the rolling six-week consistency history.
8. Evaluate the consecutive perfect-week streak.
9. Award first-time streak milestones.
10. Award the perfect-week bonus when eligible.
11. Apply rank-local decay only for an unprotected failed week.
12. Store immutable schedule and weekly-evaluation records.
13. Expose the new rank snapshot.
```

Swap penalties are applied at confirmation time and referenced during weekly finalization; they are not charged a second time.

# 18. Required state

```text
lifetimeXP
rankRR
rankHistory
sessionAwards
swapPenalties
missedSessionPenalties
weeklySchedules
weeklyEvaluations
rollingConsistencyWeeks
perfectWeekStreak
awardedMilestones
exercisePRRecords
protectedPeriods
correctionEvents
rankConfigVersion
scheduleConfigVersion
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
  consistencyMultiplier,
  rollingSixWeekSummary,
  perfectWeekStreak,
  nextStreakMilestone,
  confirmedSwapsThisWeek,
  swapsRemainingThisWeek,
  swapRRLostThisWeek,
  pendingMissedSessionPenalties,
  projectedFailedWeekDecay
}
```

The UI must consume one canonical snapshot rather than reproducing rank math independently.

# 20. Calibration examples

## Perfect week at maximum multiplier without PRs or swaps

```text
4 main sessions: 4 * round(23 * 1.50) = 140 RR
1 specialization: round(18 * 1.50) = 27 RR
perfect-week bonus = 25 RR
total = 192 RR
```

## Perfect week with one swap

```text
normal perfect-week total = 192 RR
one confirmed swap = -5 RR
net = 187 RR
```

The week remains perfect and the streak continues.

## Perfect week with two swaps

```text
normal perfect-week total = 192 RR
two confirmed swaps = -10 RR
net = 182 RR
```

## Compliant week missing one main session after one swap

Assume the four completed sessions are fully logged and multiplier is `1.50x`:

```text
3 main sessions = 3 * 35 = 105 RR
1 specialization = 27 RR
one swap = -5 RR
missed main penalty = -20 RR
perfect-week bonus = 0
weekly net before PRs = 107 RR
```

## Failed week completing only two sessions

```text
confirmed swap penalties remain
three missed-session penalties are applied
then rank-local failed-week decay is applied
```

# 21. Non-negotiable rules

1. Rank is based on `rankRR`, not lifetime XP.
2. Lifetime XP does not decay from missed training or schedule changes.
3. Every unprotected missed scheduled workout directly reduces RR.
4. Main-session miss equals `-20 RR`.
5. Specialization-session miss equals `-15 RR`.
6. Maximum two confirmed swaps per week.
7. Every confirmed swap equals `-5 RR`.
8. Swap and missed-session penalties are not multiplied by consistency.
9. A fully completed swapped week can still be perfect.
10. Rest days never cause penalties by themselves.
11. Daily gym streaks and daily decay do not exist.
12. More consistency increases earned RR up to `1.50x`.
13. PR rewards are capped and validated.
14. Extra volume and extra workouts earn no RR.
15. Failed weeks receive missed-session penalties plus rank-local decay.
16. Deload completion counts; deload PRs do not.
17. Protected pauses freeze rather than reward progress.
18. Award and penalty reversal uses stored values.
19. All score and schedule changes are auditable.
20. Rank and schedule configurations must be versioned before future tuning.

## Honest limitation

These values are product-balance parameters, not physiological laws. They must be simulated and later tuned from actual usage data without silently rewriting historical awards. Future balance changes require new configuration versions and an explicit migration policy.