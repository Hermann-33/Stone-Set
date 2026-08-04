# Stone Set Workout Rank and RR System

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PD-007`
Rank configuration: `rank-v5`

## Purpose

This document defines how Stone Set rewards valid scheduled training, complete logging, legitimate personal records, and uninterrupted weekly consistency while penalizing missed sessions, paid schedule swaps, and collapsed adherence.

Scheduling mechanics and free-swap-credit rules are defined in `docs/product/WEEKLY_SCHEDULING.md`. This document owns the Rank Rating consequences.

## Design objectives

1. Consistency must be the strongest controllable source of RR.
2. Long uninterrupted consistency must materially accelerate rank progression.
3. Any unprotected non-perfect week must reset the consistency multiplier.
4. A missed scheduled workout must directly reduce RR.
5. A confirmed schedule swap must consume either one banked free-swap credit or `5 RR`.
6. Monthly free-swap credits must provide flexibility without increasing the weekly swap limit.
7. Valid PRs must accelerate progress without becoming mandatory every week.
8. Programmed rest, prescribed deloads, and approved protected pauses must not be treated as failure.
9. Extra workouts and extra sets must not farm RR.
10. Lifetime achievement must not decay from inactivity.
11. A user with defined decent consistency should reach Adonis in approximately ten months.
12. Every score and credit change must be explainable, versioned, and auditable.

# 1. Progression tracks

| Track | Field | Meaning | Can decrease? |
|---|---|---|---|
| Lifetime XP | `lifetimeXP` | Valid historical training achievement | Only when invalid or duplicate data is voided |
| Rank Rating | `rankRR` | Current competitive training standing | Yes |

```text
lifetimeXP = historical valid work
rankRR = current rank position
```

Missed-session penalties, paid-swap penalties, and failed-week decay affect `rankRR` only.

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

# 6. Swap payment and RR effect

Each confirmed swap uses one of two payment methods.

## Free-swap credit

When the user explicitly chooses to consume one available credit:

```text
freeSwapBalance -= 1
appliedPenaltyRR = 0
```

The credit waives only the normal swap charge. It does not waive:

- missed-session penalties;
- failed-week decay;
- consistency reset;
- the weekly two-swap limit.

## Rank Rating payment

When the user preserves their credit balance or has no credit available:

```text
requestedSwapPenaltyRR = 5
appliedSwapPenaltyRR = min(5, rankRRBefore)
rankRR = max(0, rankRR - 5)
```

## Shared rules

- maximum two confirmed swaps per week;
- free credits never increase the weekly limit;
- paid penalties are immediate and never multiplied;
- free-credit swaps produce no RR transaction;
- neither payment method affects lifetime XP;
- swapping back is a second confirmed swap and requires another credit or another `5 RR` payment;
- a canceled preview consumes nothing;
- a completed swapped week may still be perfect;
- an auditable void restores exactly the instrument used: one credit or the exact stored RR deduction, never both.

# 7. Monthly free-swap grant

The scheduling system grants two credits each calendar month.

```text
monthlyFreeSwapGrant = 2
```

Rank-system implications:

- unused credits never expire;
- the balance has no cap;
- grants do not award RR or lifetime XP;
- credits cannot be converted into RR;
- a monthly grant does not alter rank, consistency, or streak state;
- grant and consumption records must be auditable and idempotent.

# 8. Complete logging reward

A fully completed session earns:

```text
+3 raw RR
+3 lifetime XP
```

only when every working set records exercise variant, load, repetitions, RIR, and completion status.

# 9. PR validation and reward

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

# 10. Resettable consistency multiplier

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

A protected pause freezes the streak and multiplier. A swapped week remains perfect when all five final scheduled sessions are fully completed, regardless of whether its swaps used credits or RR.

# 11. Session reward formula

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

# 12. Weekly completion reward

A perfect week awards:

```text
+25 rankRR
+25 lifetimeXP
```

The bonus is not multiplied.

A non-perfect week receives no perfect-week bonus and resets the consistency multiplier unless the week is protected.

# 13. Consecutive perfect-week milestones

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

# 14. Failed-week decay

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

# 15. Recovery and schedule protection

## Programmed rest

Rest days award nothing, cost nothing, and never affect consistency.

## Approved swaps

A valid swap changes dates, not session identity. Completing all five final sessions preserves a perfect week.

Its schedule-change payment is either:

- one consumed free-swap credit and `0 RR`; or
- a stored paid-swap deduction of up to `5 RR`.

## Prescribed deload

Completing the reduced prescription counts as a fully completed scheduled session. Base and logging rewards apply; PR rewards are disabled.

## Protected pause

An approved pause:

- awards no session or weekly reward;
- applies no missed-session penalty or failed-week decay;
- freezes the perfect-week streak and multiplier;
- is excluded from streak progression;
- does not stop monthly free-swap grants;
- requires auditable backdating when entered after the fact.

# 16. Anti-farming rules

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
15. Each account receives exactly one two-credit grant per calendar month.
16. Free credits cannot be converted, transferred, sold, or exchanged for RR.
17. Credit balance cannot become negative.
18. All manual score and credit corrections create audit events.

# 17. Required records

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

## Penalty and swap-payment records

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
swapPayment = {
  swapId,
  paymentMethod: "free_credit" | "rank_rr",
  requestedPenaltyRR: 5,
  appliedPenaltyRR,
  freeSwapConsumptionId,
  appliedAt,
  rankConfigVersion,
  voidedAt,
  voidReason,
  restoredRR,
  restoredFreeCredits
}
```

Monthly grant and credit-consumption record shapes are owned by `docs/product/WEEKLY_SCHEDULING.md`.

Reversal always uses stored values and restores only the payment instrument originally used.

# 18. Weekly evaluation order

```text
1. Materialize any due monthly free-swap grant idempotently.
2. Finalize the post-swap schedule and stored swap-payment records.
3. Apply approved protected states and corrections.
4. Resolve every scheduled session.
5. Apply direct penalties for unprotected missed or invalid sessions.
6. Determine whether the week is perfect, non-perfect, failed, or protected.
7. If perfect, increment the consecutive-perfect-week streak.
8. If perfect and reaching Week 5, 10, or 15, award the exact consistency top-up.
9. If non-perfect, reset the streak and multiplier to zero weeks / 1.00x.
10. Award first-time streak milestones when eligible.
11. Award the perfect-week bonus when eligible.
12. Apply rank-local decay only for an unprotected failed week.
13. Store an immutable weekly evaluation.
14. Expose the new rank snapshot and free-swap balance.
```

# 19. Required state

```text
lifetimeXP
rankRR
rankHistory
sessionAwards
consistencyTopUps
missedSessionPenalties
swapPayments
weeklyEvaluations
consecutivePerfectWeeks
activeConsistencyMultiplier
awardedMilestones
exercisePRRecords
protectedPeriods
freeSwapWallet
monthlyFreeSwapGrants
freeSwapConsumptions
correctionEvents
rankConfigVersion
scheduleConfigVersion
```

# 20. Rank snapshot

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
  freeSwapBalance,
  pendingPenalties,
  projectedFailedWeekDecay,
  rankConfigVersion
}
```

# 21. Ten-month Adonis calibration

Ten months is modeled as approximately `43 weeks`.

The accepted synthetic decent-consistency profile remains:

- 72% perfect weeks;
- 23% compliant weeks;
- 5% weak weeks;
- approximately 93% scheduled-session completion;
- 76% of weeks with no swap, 22% with one swap, and 2% with two swaps;
- 0.5 rewarded PRs per week for Weeks 1-20 and 0.3 afterward;
- complete logging on completed working sets.

The `rank-v4` Monte Carlo calibration produced a 42.7-week mean and 43-week median when every swap paid RR.

Under the same swap-frequency assumptions:

```text
expected swaps per week = 0.22 + (2 * 0.02) = 0.26
expected paid-swap cost without credits = 0.26 * 5 = 1.30 RR/week
```

Two monthly credits provide roughly 20 credits across ten months, while the profile expects roughly 11 swaps during that period. After normal accumulation, most modeled swaps can therefore be free.

The expected removed swap cost over 42.7 weeks is approximately `56 RR`, equivalent to roughly `0.4` week of average progress. Consequently:

- Adonis remains an approximately ten-month target;
- the expected mean becomes slightly faster, around 42-43 weeks rather than requiring a threshold change;
- no rank threshold or positive reward was changed for `rank-v5`.

This is an expected-value adjustment, not a new Monte Carlo result. Actual time depends on swap clustering, whether the user spends or saves credits, completed sessions, resets, PRs, penalties, and failed-week decay.

# 22. Configuration activation

`rank-v5` supersedes `rank-v4` only for swap-payment behavior and free-credit state.

Preserved from `rank-v4`:

- all 20 rank thresholds;
- Adonis at `5,500 RR`;
- session, logging, PR, and weekly rewards;
- multiplier tiers and reset behavior;
- streak milestones;
- missed-session penalties;
- failed-week decay.

No historical migration is required because Stone Set has no application runtime, persisted user score, credit balance, or production transaction history.

# 23. Non-negotiable rules

1. Rank is based on `rankRR`, not lifetime XP.
2. Highest rank is Adonis at `5,500 RR`.
3. Maximum consistency multiplier is `2.50x`.
4. Five, ten, and fifteen perfect weeks unlock `1.50x`, `2.00x`, and `2.50x`.
5. Any unprotected non-perfect week resets the streak and multiplier.
6. Protected pauses freeze rather than reset consistency.
7. Completed swapped weeks may remain perfect.
8. Main-session misses cost `20 RR`; specialization misses cost `15 RR`.
9. Every confirmed swap consumes one weekly allowance.
10. A confirmed swap costs either one free credit or up to `5 RR`.
11. Two free credits are granted monthly, never expire, and have no balance cap.
12. Free credits never increase the two-swap weekly limit.
13. Penalties are never multiplied.
14. PR rewards are capped and validated.
15. Extra volume and extra workouts earn no RR.
16. Failed weeks receive direct penalties plus rank-local decay.
17. Award, penalty, payment, and credit reversals use stored values.
18. All score and credit changes are auditable.
19. Future balance changes require a new configuration version and explicit migration policy.

## Honest limitation

The ten-month target depends on a synthetic consistency profile, and the free-credit impact is an expected-value estimate. Stone Set has no real usage data yet. The model must be reviewed after enough actual weeks have been logged without silently rewriting historical awards.
