# Stone Set Workout Rank and RR System

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PD-003`

## Purpose

This document defines how Stone Set rewards workout consistency, valid personal records, complete logging, and long-term adherence while directly penalizing unprotected missed scheduled workouts.

The system takes inspiration from the Quest Tracker model supplied by the owner, especially:

- separate lifetime achievement and current-rank tracks;
- rank thresholds;
- stored award and penalty records;
- rank demotion;
- streak rewards;
- rank-local decay.

The gym version rejects daily decay, daily attendance streaks, and rewards for unscheduled extra training. Those mechanics would punish prescribed rest and encourage junk volume.

## Design objectives

1. Consistency must be the largest controllable source of RR.
2. A missed scheduled workout must directly reduce RR.
3. Valid PRs must accelerate progress without becoming mandatory every week.
4. Higher consistency must increase RR earned from valid workouts.
5. Rest days and prescribed recovery must never count as failure.
6. Random extra workouts must not farm RR.
7. One missed session must hurt without destroying months of progress.
8. Repeated low adherence must cause meaningful demotion pressure.
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

Missed-session penalties and inactivity decay affect `rankRR` only.

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

# 3. Scheduled session types

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

## Formula

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

## Finalization rule

The penalty is not applied immediately at the original start time.

A scheduled workout may be rescheduled within the same calendar week. The penalty is applied once when the week is finalized and the session remains missed or invalid.

## Consequences of missing one main session

A 4-of-5 week with one missed main session causes all of the following:

- `-20 RR` direct penalty;
- no perfect-week bonus;
- only `0.5` consistency credit;
- the consecutive perfect-week streak ends;
- the unearned session, logging, and PR rewards are lost.

This is intentionally stricter than opportunity cost alone.

## Lifetime XP

Missed-session penalties never reduce `lifetimeXP`.

# 6. Complete logging reward

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

# 7. PR validation

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

# 8. Consistency multiplier

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

Five perfect weeks are the fastest route to `1.50x`. The multiplier becomes active after the fifth week is finalized, so it applies from Week 6.

# 9. Session reward formula

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

# 10. Weekly classification and rewards

## Perfect week: 5 of 5

- awards `+25 RR` and `+25 lifetimeXP`;
- contributes `1.0` consistency credit;
- advances the perfect-week streak;
- receives no missed-session penalties.

## Compliant week: 4 of 5

- contributes `0.5` consistency credit;
- receives no perfect-week bonus;
- breaks the perfect-week streak;
- applies the direct penalty for the one missed session.

## Weak week: 3 of 5

- contributes no consistency credit;
- receives no perfect-week bonus;
- breaks the perfect-week streak;
- applies direct penalties for both missed sessions;
- does not trigger additional failed-week decay.

## Failed week: 0-2 of 5

- contributes no consistency credit;
- receives no perfect-week bonus;
- breaks the perfect-week streak;
- applies a direct penalty for every missed session;
- also triggers rank-local failed-week decay.

# 11. Consecutive perfect-week milestones

Milestones are awarded once per account lifetime.

| Consecutive perfect weeks | RR | Lifetime XP |
|---:|---:|---:|
| 2 | 25 | 25 |
| 4 | 60 | 60 |
| 8 | 150 | 150 |
| 12 | 250 | 250 |
| 24 | 600 | 600 |
| 52 | 1,500 | 1,500 |

A compliant week breaks the perfect-week streak but remains useful to the rolling multiplier.

Protected pause weeks freeze the streak. They neither extend nor break it.

# 12. Failed-week rank decay

There is no daily decay.

Additional rank-local decay applies only after an unprotected failed week with fewer than three fully completed scheduled sessions.

```text
rankLocalRR = max(0, rankRR - currentRank.minimumRR)
weeklyDecay = baseDecay + round(rankLocalRR * localDecayRate)
rankRR = max(0, rankRR - weeklyDecay)
```

Direct missed-session penalties are applied first. Failed-week decay is calculated from the resulting RR.

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

The two layers serve different purposes:

- missed-session penalty: accountability for each scheduled workout skipped;
- failed-week decay: demotion pressure when adherence collapses across the week.

Neither affects lifetime XP.

# 13. Recovery and protected states

## Programmed rest days

- award nothing;
- cost nothing;
- never break consistency;
- never count as missed training.

## Approved reschedule

A session moved to another day in the same calendar week:

- receives no penalty when completed;
- occupies the original scheduled slot;
- cannot be duplicated for extra rewards.

## Prescribed deload

- reduced sessions count when the reduced prescription is completed;
- normal base and logging rewards apply;
- PR rewards are disabled;
- the perfect-week streak may continue.

## Protected pause

A pause may cover illness, injury, travel, or gym closure.

During an approved pause:

- no session reward is awarded;
- no missed-session penalty is applied;
- no failed-week decay is applied;
- the perfect-week streak is frozen;
- affected time is excluded from the consistency window.

Backdating requires an auditable correction event.

# 14. Anti-farming rules

1. Only scheduled sessions earn base RR.
2. One scheduled slot can award once.
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
13. Rescheduling is allowed within the week; duplicating sessions is not.
14. Finishing faster than 60 minutes gives no extra RR.
15. A missed session can create only one direct penalty record.

# 15. Records and reversals

## Session award record

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
  rankConfigVersion,
  voidedAt,
  voidReason
}
```

## Missed-session penalty record

```text
missedSessionPenalty = {
  scheduledSessionId,
  sessionType,
  penaltyRR,
  originalScheduledDate,
  finalizedAt,
  reason: "unprotected_missed_session",
  rankConfigVersion,
  reversedAt,
  reversalReason
}
```

## Reversal

Undo and correction use stored values. They never recalculate using the current multiplier or current configuration.

Voiding an invalid workout reverses its stored lifetime XP and RR.

Approving a previously penalized protection or correction restores the exact stored penalty RR and creates a correction event.

# 16. Weekly evaluation order

```text
1. Finalize all sessions for the closing week.
2. Apply approved reschedules, protected states, and corrections.
3. Determine full, partial, missed, invalid, and protected session states.
4. Apply one direct RR penalty for each unprotected missed or invalid session.
5. Determine weekly result: perfect, compliant, weak, failed, or protected.
6. Update the rolling six-week consistency history.
7. Evaluate the consecutive perfect-week streak.
8. Award any first-time streak milestone.
9. Award the perfect-week bonus when eligible.
10. Apply rank-local decay only for an unprotected failed week.
11. Store an immutable weekly evaluation record.
12. Expose the new rank snapshot.
```

# 17. Required state

```text
lifetimeXP
rankRR
rankHistory
sessionAwards
missedSessionPenalties
weeklyEvaluations
rollingConsistencyWeeks
perfectWeekStreak
awardedMilestones
exercisePRRecords
protectedPeriods
correctionEvents
rankConfigVersion
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
  pendingMissedSessionPenalties,
  projectedFailedWeekDecay
}
```

The UI must consume one canonical snapshot rather than reproducing rank math independently.

# 19. Calibration examples

## Perfect week at maximum multiplier without PRs

```text
4 main sessions: 4 * round(23 * 1.50) = 140 RR
1 specialization: round(18 * 1.50) = 27 RR
perfect-week bonus = 25 RR
total = 192 RR
```

## Compliant week missing one main session

Assume the four completed sessions are fully logged and the multiplier is `1.50x`:

```text
3 main sessions = 3 * 35 = 105 RR
1 specialization = 27 RR
missed main penalty = -20 RR
perfect-week bonus = 0
weekly net before PRs = 112 RR
```

The user still progresses because four sessions were completed, but the missed workout creates an actual RR loss and damages future multiplier credit.

## Weak week missing two main sessions

```text
two direct penalties = -40 RR
no perfect-week bonus
no consistency credit
no additional failed-week decay
```

## Failed week completing only two sessions

```text
three missed-session penalties are applied
then rank-local failed-week decay is applied
```

# 20. Non-negotiable rules

1. Rank is based on `rankRR`, not lifetime XP.
2. Lifetime XP does not decay from missed training.
3. Every unprotected missed scheduled workout directly reduces RR.
4. Main-session miss equals `-20 RR`.
5. Specialization-session miss equals `-15 RR`.
6. Penalties are not multiplied by consistency.
7. Rest days never cause penalties.
8. Approved reschedules avoid penalties.
9. Daily gym streaks and daily decay do not exist.
10. More consistency increases earned RR up to `1.50x`.
11. PR rewards are capped and validated.
12. Extra volume and extra workouts earn no RR.
13. Failed weeks receive direct penalties plus rank-local decay.
14. Deload completion counts; deload PRs do not.
15. Protected pauses freeze rather than reward progress.
16. Award and penalty reversal uses stored values.
17. All score changes are auditable.
18. Rank configuration must be versioned before future tuning.

## Honest limitation

These values are product-balance parameters, not physiological laws. They must be simulated and later tuned from actual usage data without silently rewriting historical awards. Future balance changes require a new rank-config version and an explicit migration policy.