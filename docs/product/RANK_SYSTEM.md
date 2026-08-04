# Stone Set Workout Rank and RR System

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PD-008`
Rank configuration: `rank-v6`

## Purpose

This document defines Stone Set's authoritative Rank Rating and lifetime-XP behavior for user-specific weekly routines.

The rank system normalizes weekly opportunity across supported routines containing four, five, or six workout days. Every week contains seven dated plan items. Workout items receive a larger share of the weekly reward pool; programmed rest items receive a smaller share. Users with different routine frequencies retain the same maximum weekly rank opportunity.

Scheduling, routine versioning, weekly-plan materialization, swaps, and free-swap credits are defined in `docs/product/WEEKLY_SCHEDULING.md`.

## Design objectives

1. Equal maximum weekly RR opportunity across supported routine frequencies.
2. Consistency remains the strongest controllable source of RR.
3. Any unprotected non-perfect week resets the consistency multiplier.
4. Missed workout items directly reduce RR.
5. Programmed recovery receives less RR than training but creates no fake check-in obligation.
6. A confirmed swap consumes either one free-swap credit or up to `5 RR`.
7. PR opportunity is normalized per week rather than per session.
8. Extra workouts and extra sets cannot farm RR.
9. Lifetime achievement does not decay from inactivity.
10. Every award, penalty, payment, correction, and configuration version is auditable.
11. Defined decent consistency remains approximately a ten-month path to Adonis.

# 1. Supported weekly routines

A reward-eligible MVP routine must contain:

```text
week length = 7 days
minimum workout days = 4
maximum workout days = 6
minimum programmed rest days = 1
```

Every user-owned routine is versioned. A weekly plan stores the exact published routine version and configuration versions used when the week is materialized.

The rank formulas assume the routine has passed reward-eligibility validation. The exact anti-triviality publication rules must be finalized before implementation; users cannot publish arbitrary empty or meaningless routines and receive a full weekly pool.

# 2. Progression tracks

| Track | Field | Meaning | Can decrease? |
|---|---|---|---|
| Lifetime XP | `lifetimeXP` | Valid historical adherence and performance | Only when invalid or duplicate data is voided |
| Rank Rating | `rankRR` | Current competitive training standing | Yes |

```text
lifetimeXP = historical valid achievement
rankRR = current rank position
```

Missed-workout penalties, paid-swap penalties, and failed-week decay affect `rankRR` only.

# 3. Rank ladder

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
localRR = rankRR - currentRank.minimumRR
rankSpan = nextRank.minimumRR - currentRank.minimumRR
progressPercent = clamp(localRR / rankSpan, 0, 1) * 100
rrToNextRank = max(0, nextRank.minimumRR - rankRR)
```

# 4. Weekly daily-item reward pools

The weekly daily-item RR pool depends on the active consistency multiplier.

| Active multiplier | Daily-item RR pool | Perfect-week bonus | Maximum no-PR weekly RR |
|---:|---:|---:|---:|
| 1.00x | 110 | 25 | 135 |
| 1.50x | 167 | 25 | 192 |
| 2.00x | 220 | 25 | 245 |
| 2.50x | 277 | 25 | 302 |

The unmultiplied lifetime-XP daily-item pool is always:

```text
weeklyBaseXPItemPool = 110
```

Consistency changes RR, not the base lifetime-XP value of ordinary daily items.

# 5. Daily allocation formula

Allocation weights:

```text
workout item weight = 4
rest item weight = 1
```

For pool `P`:

```text
totalWeight =
  workoutItemCount * 4
  + restItemCount * 1

exactAllocation = P * itemWeight / totalWeight
```

Integer allocation uses the largest-remainder method:

1. floor each exact allocation;
2. calculate the undistributed remainder;
3. add one RR to items with the largest fractional remainders;
4. break equal fractional remainders by earlier calendar date;
5. store and verify that all seven allocations sum exactly to `P`.

Each weekly item stores:

- its active-multiplier RR allocation;
- its 1.00x base-XP allocation;
- its day type;
- the rank configuration version;
- the allocation order and exact share.

Allocations are immutable after weekly-plan materialization.

## Reference 1.00x allocations

| Workout days | Workout allocations | Rest allocations | Total |
|---:|---|---|---:|
| 4 | 23, 23, 23, 23 | 6, 6, 6 | 110 |
| 5 | 20, 20, 20, 20, 20 | 5, 5 | 110 |
| 6 | 18, 18, 18, 18, 17, 17 | 4 | 110 |

The exact dates receiving any one-point remainder are determined by the stored calendar-date tie-break.

# 6. Workout-item resolution

## Fully completed and fully logged

A workout item earns 100% of its stored daily RR and base-XP allocations when:

1. every priority exercise is completed;
2. at least 90% of prescribed working sets are completed;
3. every required working set records exercise variant, load, repetitions, RIR, and completion status;
4. the 60-minute rule is respected or the accepted final low-priority-set time-cap removal applies;
5. the record is not fabricated, duplicated, or invalid.

```text
completionFactor = 1.00
```

## Fully completed with incomplete logging

```text
completionFactor = 0.85
```

The item is not perfect-week eligible because complete logging is required for a perfect week.

## Partially completed

For 70-89% of prescribed working sets:

```text
completionFactor = 0.50
```

A partial item receives no direct missed-workout penalty but breaks perfect-week consistency.

## Missed or invalid

Below 70% completion, or unresolved at weekly finalization:

```text
completionFactor = 0
```

The item earns no ordinary RR or XP and receives its stored missed-workout penalty unless protected.

## Ordinary award formula

```text
awardedDailyRR =
  roundHalfUp(storedDailyRRAllocation * completionFactor)

awardedDailyLifetimeXP =
  roundHalfUp(storedBaseXPAllocation * completionFactor)
```

# 7. Programmed-rest resolution

A valid programmed-rest item:

- finalizes automatically at local day close;
- earns 100% of its lower stored RR allocation;
- earns 100% of its lower stored base-XP allocation;
- has no direct missed-workout penalty;
- cannot generate PR rewards;
- does not create another workout slot;
- does not require a manual rest check-in.

An unscheduled workout performed on a rest item earns no additional RR or XP.

A protected full week follows the protected-pause rules and does not award ordinary daily items or the perfect-week bonus.

# 8. Equal weekly missed-workout penalty pool

The maximum direct missed-workout exposure is normalized to:

```text
weeklyMissedWorkoutPenaltyPool = 95 RR
```

The pool is divided equally across workout items only, using floor-plus-largest-remainder allocation with earlier calendar date as the tie-break.

| Workout days | Stored penalties | Weekly maximum |
|---:|---|---:|
| 4 | 24, 24, 24, 23 | 95 |
| 5 | 19, 19, 19, 19, 19 | 95 |
| 6 | 16, 16, 16, 16, 16, 15 | 95 |

Penalties:

- apply once at weekly finalization after swaps, protections, and corrections;
- are never multiplied;
- never reduce lifetime XP;
- use the exact stored item value during reversal.

```text
rankRR = max(0, rankRR - storedMissedPenaltyRR)
```

# 9. PR validation and reward

The first comparable performance establishes a baseline and is not a PR.

A valid PR must use the same exercise and equipment variant with comparable technique, range of motion, repetition target, and RIR standard.

## Load PR

A heavier load than the previous best, completed within the prescribed repetition and RIR targets.

## Rep PR

More repetitions than the previous best at the same load, completed at the same or stricter RIR without exceeding the programmed ceiling solely to farm RR.

## Non-qualifying events

- warm-up sets;
- assisted or partial repetitions;
- changed variants;
- looser technique or reduced range of motion;
- manually entered historical records;
- duplicate PR labels;
- PRs during a prescribed deload.

```text
rawPRRR = 5
PRLifetimeXP = 5
maximum rewarded PRs per week = 2
maximum raw weekly PR RR = 10
```

Each accepted PR receives consistency multiplication for RR:

```text
awardedPRRR = roundHalfUp(5 * activeConsistencyMultiplier)
awardedPRLifetimeXP = 5
```

One exercise can earn at most one rewarded PR in a week.

# 10. Resettable consistency multiplier

Consistency is based on consecutive perfect weeks.

A perfect week requires:

- every scheduled workout item fully completed;
- every required workout field fully logged;
- all seven final plan items valid after swaps and protections;
- no unprotected partial, missed, or invalid workout item.

| Consecutive perfect weeks | RR multiplier |
|---:|---:|
| 0-4 | 1.00x |
| 5-9 | 1.50x |
| 10-14 | 2.00x |
| 15+ | 2.50x |

The multiplier remains capped at `2.50x` while the perfect-week streak continues.

## Milestone-week top-up

Weekly plans use the multiplier active at the start of the week. If finalization confirms the fifth, tenth, or fifteenth consecutive perfect week, the system awards the exact difference between the old and newly unlocked multiplier.

Daily-item pool differences:

| Milestone | Old pool | New pool | Daily-item top-up |
|---:|---:|---:|---:|
| Week 5 | 110 | 167 | 57 RR |
| Week 10 | 167 | 220 | 53 RR |
| Week 15 | 220 | 277 | 57 RR |

Eligible PRs from that milestone week also receive the difference between their old- and new-multiplier RR values.

The perfect-week bonus and once-per-account streak milestones are excluded from the top-up.

## Reset rule

Any unprotected non-perfect week resets:

```text
consecutivePerfectWeeks = 0
activeConsistencyMultiplier = 1.00x
```

RR and XP validly earned in earlier finalized weeks are never clawed back.

A protected full-week pause freezes the streak and multiplier. A fully completed swapped week remains perfect.

# 11. Perfect-week reward

A perfect week awards:

```text
+25 rankRR
+25 lifetimeXP
```

The bonus is not multiplied.

A non-perfect week receives no perfect-week bonus and resets consistency unless protected.

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

A reset does not revoke an earned milestone and cannot make it awardable again.

# 13. Normalized failed-week decay

There is no daily rank decay.

```text
workoutCompletionRatio =
  fullyCompletedWorkoutItems / scheduledWorkoutItems

failedWeek =
  unprotected AND workoutCompletionRatio < 0.60
```

Only fully completed workout items count in the numerator. Partial items do not.

Direct missed-workout penalties apply before failed-week decay.

```text
rankLocalRR = max(0, rankRR - currentRank.minimumRR)
weeklyDecay = baseDecay + roundHalfUp(rankLocalRR * localDecayRate)
rankRR = max(0, rankRR - weeklyDecay)
```

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

# 14. Swap-payment and free-credit RR effects

Every confirmed swap consumes one weekly swap allowance and exactly one payment method.

## Free-credit payment

```text
freeSwapBalance -= 1
appliedPenaltyRR = 0
```

## RR payment

```text
requestedSwapPenaltyRR = 5
appliedSwapPenaltyRR = min(5, rankRRBefore)
rankRR = max(0, rankRR - 5)
```

Shared rules:

- maximum two confirmed swaps per week;
- free credits never increase that limit;
- paid penalties are immediate and never multiplied;
- neither method affects lifetime XP;
- swapping back is another swap and another payment;
- canceled previews consume nothing;
- corrections restore only the original stored payment instrument.

# 15. Recovery and protected states

## Prescribed deload

A completed reduced prescription may earn its normal daily allocation under the accepted completion rule. PR rewards are disabled.

## Protected item

An approved protected workout item:

- creates no missed-workout penalty;
- awards no ordinary item RR or XP unless a later accepted rule explicitly defines partial protected credit;
- requires an auditable reason;
- does not allow medical diagnosis by the application.

## Protected full week

An approved full-week pause:

- awards no ordinary item or perfect-week rewards;
- applies no missed-workout penalties or failed-week decay;
- freezes the perfect-week streak and multiplier;
- does not stop monthly free-swap grants;
- requires auditable backdating when entered after the fact.

# 16. Anti-farming and integrity rules

1. Only materialized weekly plan items earn ordinary RR and XP.
2. A plan item can award once.
3. Extra workouts and sets earn no RR or XP.
4. Rest items cannot be converted into rewarded workouts.
5. Published routine versions are immutable.
6. Routine changes affect future unlocked weeks only.
7. Weekly allocations are immutable after materialization.
8. Users cannot edit weights, pools, penalties, thresholds, or multipliers.
9. A reward-eligible routine must pass publication validation.
10. PR rewards are capped at two per week.
11. The first comparable result is a baseline, not a PR.
12. Deload PRs are disabled.
13. A missed workout creates at most one direct penalty.
14. Consistency milestones are awarded once.
15. Swaps cannot duplicate, erase, or create plan items.
16. Monthly grants are unique per account and month.
17. Free-swap balance cannot become negative.
18. Clients cannot authoritatively submit RR, XP, rank, penalty, wallet, milestone, or finalization totals.
19. All corrections create audit events and restore stored values.
20. Historical records retain `rankConfigVersion` and `scheduleConfigVersion`.

# 17. Required records

```text
dailyRewardAllocation = {
  weeklyPlanItemId,
  dayType,
  dayWeight,
  activeMultiplier,
  weeklyRRPool,
  weeklyBaseXPPool: 110,
  exactRRShare,
  allocatedRR,
  exactBaseXPShare,
  allocatedBaseXP,
  allocationOrder,
  rankConfigVersion
}
```

```text
missedPenaltyAllocation = {
  weeklyPlanItemId,
  weeklyPenaltyPool: 95,
  allocatedPenaltyRR,
  rankConfigVersion
}
```

```text
dailyAward = {
  weeklyPlanItemId,
  resolution,
  allocatedRR,
  allocatedBaseXP,
  completionFactor,
  awardedRR,
  awardedLifetimeXP,
  finalizedAt,
  rankConfigVersion,
  voidedAt,
  voidReason
}
```

```text
prAward = {
  weekId,
  weeklyPlanItemId,
  exerciseVariantId,
  rawPRRR: 5,
  consistencyMultiplier,
  awardedRR,
  awardedLifetimeXP: 5,
  validationEvidence,
  rankConfigVersion,
  voidedAt,
  voidReason
}
```

```text
consistencyTopUp = {
  weekId,
  milestoneWeek,
  previousMultiplier,
  unlockedMultiplier,
  dailyItemTopUpRR,
  prTopUpRR,
  totalTopUpRR,
  finalizedAt,
  rankConfigVersion
}
```

```text
missedWorkoutPenalty = {
  weeklyPlanItemId,
  penaltyRR,
  finalizedAt,
  reason,
  rankConfigVersion,
  reversedAt,
  reversalReason
}
```

Swap-payment and wallet records are defined in `docs/product/WEEKLY_SCHEDULING.md`.

# 18. Weekly evaluation order

```text
1. Materialize any due monthly free-swap grant idempotently.
2. Freeze the final post-swap schedule and stored payment records.
3. Apply approved protected states and corrections.
4. Resolve all seven plan items.
5. Validate and cap weekly PR awards.
6. Apply direct penalties for unprotected missed or invalid workout items.
7. Calculate workoutCompletionRatio.
8. Classify the week as perfect, non-perfect, failed, or protected.
9. If perfect, increment consecutivePerfectWeeks.
10. If perfect at Week 5, 10, or 15, award exact daily-item and PR top-ups.
11. If non-perfect, reset streak and multiplier.
12. Award first-time streak milestones when eligible.
13. Award the perfect-week bonus when eligible.
14. Apply rank-local decay only for an unprotected failed week.
15. Store immutable weekly evaluation and rank snapshot.
16. Expose finalized rank and next-week multiplier state.
```

# 19. Required state

```text
lifetimeXP
rankRR
rankHistory
dailyRewardAllocations
dailyAwards
prAwards
consistencyTopUps
missedPenaltyAllocations
missedWorkoutPenalties
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
  freeSwapBalance,
  pendingAwards,
  pendingPenalties,
  projectedFailedWeekDecay,
  rankConfigVersion
}
```

# 21. Calibration and fairness acceptance

The fixed weekly ceiling is exactly equal for four-, five-, and six-workout-day routines.

A deterministic-seed preliminary simulation used 50,000 synthetic users per supported frequency under the accepted decent-consistency profile.

| Workout days | Mean weeks to Adonis | Median | 25th percentile | 75th percentile | 90th percentile |
|---:|---:|---:|---:|---:|---:|
| 4 | 42.87 | 43 | 40 | 46 | 49 |
| 5 | 42.00 | 42 | 39 | 45 | 48 |
| 6 | 41.41 | 42 | 39 | 45 | 47 |

The maximum mean spread is approximately `1.46 weeks`. This variance is accepted for `rank-v6`; it results from discrete completed-workout counts in imperfect weeks, not unequal maximum weekly pools.

The simulation is synthetic balance evidence, not observed user data.

# 22. Configuration activation

`rank-v6` supersedes `rank-v5` for all new Stone Set implementation and future persisted records.

Preserved:

- all 20 rank thresholds;
- Adonis at `5,500 RR`;
- the 5/10/15 multiplier ladder;
- perfect-week bonus and streak milestones;
- rank-local decay values;
- `5 RR` paid swaps and bankable free credits;
- protected-pause principles;
- immutable stored-value reversals;
- no daily decay or extra-workout farming.

Changed:

- session-type awards become normalized daily-item allocations;
- programmed rest items receive lower RR and XP;
- missed penalties use a normalized 95 RR weekly pool;
- PR cap becomes two rewarded PRs per week;
- failed-week status uses a workout-completion ratio below 60%;
- routines may contain four through six workout days.

No production migration is required because no runtime, accounts, or persisted rank history exists.

# 23. Non-negotiable rules

1. Rank is based on `rankRR`, not lifetime XP.
2. Highest rank is Adonis at `5,500 RR`.
3. Supported MVP routines contain four through six workout days.
4. Every week contains seven materialized plan items.
5. Maximum no-PR weekly RR is equal across supported routine frequencies.
6. Workout items receive weight 4; rest items receive weight 1.
7. Weekly daily-item RR pools are 110, 167, 220, and 277.
8. Weekly base-XP item pool is 110.
9. Weekly direct missed-workout penalty pool is 95 RR.
10. Maximum rewarded PRs per week is two.
11. Maximum consistency multiplier is 2.50x.
12. Weeks 5, 10, and 15 unlock 1.50x, 2.00x, and 2.50x.
13. Any unprotected non-perfect week resets consistency.
14. Protected full weeks freeze consistency.
15. Maximum two swaps per week.
16. A swap costs one free credit or up to `5 RR`.
17. Two free credits are granted monthly, never expire, and have no cap.
18. Free credits never increase the weekly swap limit.
19. Penalties are never multiplied.
20. Extra workouts and sets earn no RR or XP.
21. Failed weeks receive direct penalties plus rank-local decay.
22. Every historical transaction retains configuration versions and stored values.
23. Future balance changes require a new rank configuration and explicit migration policy.

## Honest limitation

Equal score opportunity does not prove equal physical effort. User-controlled routine publication creates gaming pressure, so implementation remains blocked until concrete reward-eligibility validation prevents empty or trivial routines from receiving the full weekly pool.