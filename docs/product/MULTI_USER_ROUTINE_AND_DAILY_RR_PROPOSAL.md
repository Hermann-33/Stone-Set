# Stone Set Multi-User Routine and Daily RR Proposal

Updated: 2026-08-04
Status: `PROPOSED PRODUCT CHANGE`
Task: `TASK-PL-001`
Proposed rank configuration: `rank-v6`
Proposed scheduling configuration: `schedule-v3`

## Purpose

This document proposes the product changes required to support two users with different weekly routines while preserving equal weekly rank opportunity.

This is not a minor adjustment. It changes the reward unit from session type to daily plan item, changes missed-workout penalty allocation, changes the PR cap, and generalizes scheduling beyond the accepted fixed five-session routine.

Until this proposal is separately audited and accepted:

- `docs/product/RANK_SYSTEM.md` and `rank-v5` remain authoritative;
- `docs/product/WEEKLY_SCHEDULING.md` and `schedule-v2` remain authoritative;
- programmed rest days continue to award zero RR under the accepted system;
- implementation remains blocked.

## Problem

The accepted product assumes one fixed routine:

- four main sessions;
- one specialization session;
- two rest days.

The requested product now requires:

- two provisioned users;
- a separate routine for each user;
- dashboard-managed routine changes;
- potentially different numbers of workout and rest days;
- the same maximum weekly RR opportunity for both users;
- lower RR for rest days than workout days.

Keeping session-type rewards would produce unequal weekly opportunity when users have different routine frequencies. Allowing users to edit their own routines without reward normalization would also make the rank system trivial to exploit.

## Fairness definition

The proposal guarantees:

- equal maximum weekly base RR opportunity;
- equal perfect-week bonus;
- equal multiplier ladder;
- equal maximum weekly PR opportunity;
- equal maximum weekly direct missed-workout penalty exposure;
- equal rank thresholds and milestone rewards.

It does not claim that two different routines require equal physical effort. Score opportunity can be normalized; physiological difficulty cannot be guaranteed by arithmetic.

## User and ownership model

- Initial provisioned accounts: `2`.
- The data model must support more than two accounts without redesign.
- Public registration remains disabled for MVP.
- Each user owns one or more versioned routines.
- Each user may edit only their own routine drafts.
- Historical routine versions are immutable.
- A published routine edit applies to a future week and never rewrites an active or finalized week.

## Routine-frequency boundary

Proposed MVP boundary:

```text
minimum workout days per week = 4
maximum workout days per week = 6
minimum programmed rest days = 1
week length = 7 days
```

This boundary prevents a user from reducing the routine to one trivial workout while retaining a full weekly RR budget.

A future change outside the four-to-six-day range requires a new product decision and rank calibration.

## Routine versioning

```text
routineVersion = {
  routineVersionId,
  userId,
  versionNumber,
  status: "draft" | "published" | "archived",
  effectiveWeekStart,
  workoutDayCount,
  restDayCount,
  createdAt,
  publishedAt,
  supersedesRoutineVersionId
}
```

Rules:

1. Drafts are editable.
2. Published versions are immutable.
3. A newly published version becomes effective no earlier than the next unlocked Monday.
4. A materialized week retains the routine version used at creation.
5. Routine edits cannot alter historical reward allocations.
6. Frequency changes are auditable.
7. The dashboard cannot edit weekly RR budgets, multiplier values, rank thresholds, or penalty pools.

## Daily plan items

Every week contains seven daily plan items:

```text
dailyPlanItem.type = "workout" | "rest"
```

A workout item contains the complete workout prescription for that day.

A rest item represents programmed recovery. It does not create a workout slot and cannot be converted into extra RR through unscheduled training.

## Fixed weekly daily-RR pools

The accepted `rank-v5` perfect-week totals without PRs are preserved exactly.

| Active multiplier | Daily-item RR pool | Perfect-week bonus | Perfect-week total |
|---:|---:|---:|---:|
| 1.00x | 110 | 25 | 135 |
| 1.50x | 167 | 25 | 192 |
| 2.00x | 220 | 25 | 245 |
| 2.50x | 277 | 25 | 302 |

The fixed pool replaces session-type base and logging awards for the week.

## Allocation weights

```text
workout day weight = 4
rest day weight = 1
```

For a weekly pool `P`:

```text
totalWeight = (workoutDayCount * 4) + (restDayCount * 1)
exactDayAllocation = P * dayWeight / totalWeight
```

Because RR is integer-valued, the final allocation uses the largest-remainder method:

1. floor every exact allocation;
2. calculate the undistributed remainder;
3. award one additional RR to the largest fractional remainders;
4. resolve equal fractional remainders by earlier calendar date;
5. verify that the seven stored allocations sum exactly to `P`.

The allocation is materialized once for the week and stored. It is not recalculated from later configuration changes.

## Example: five workout days and two rest days

At `1.00x`:

```text
totalWeight = (5 * 4) + (2 * 1) = 22
workout allocation = 110 * 4 / 22 = 20 RR
rest allocation = 110 * 1 / 22 = 5 RR
```

Weekly result:

```text
5 workout days * 20 RR = 100 RR
2 rest days * 5 RR = 10 RR
daily-item pool = 110 RR
perfect-week bonus = 25 RR
perfect-week total = 135 RR
```

## Example: four workout days and three rest days

At `1.00x`, largest-remainder allocation produces:

```text
4 workout days * 23 RR = 92 RR
3 rest days * 6 RR = 18 RR
daily-item pool = 110 RR
perfect-week bonus = 25 RR
perfect-week total = 135 RR
```

The four-day and five-day users have the same weekly ceiling despite different daily values.

## Allocation travels with the plan item

A confirmed swap moves the complete plan item, including:

- workout or rest identity;
- prescription identity;
- daily RR allocation;
- missed-workout penalty allocation;
- completion and lock state.

The allocation belongs to the item, not the weekday name.

## Workout-item resolution

### Fully completed and fully logged

A workout item earns `100%` of its stored daily allocation when:

- every priority exercise is completed;
- at least 90% of prescribed working sets are completed;
- required set data is complete;
- the 60-minute rule is respected or the accepted time-cap removal rule applies;
- data is not fabricated or duplicated.

### Fully completed with incomplete logging

Proposed award:

```text
roundHalfUp(storedDailyAllocation * 0.85)
```

This preserves a meaningful logging requirement without creating a separate per-session bonus that would favor higher-frequency routines.

### Partially completed

For 70-89% completion:

```text
roundHalfUp(storedDailyAllocation * 0.50)
```

The item breaks perfect-week consistency but does not receive a direct missed-workout penalty.

### Missed or invalid

Below 70% completion:

- daily award: `0`;
- direct missed-workout penalty: the item's stored unmultiplied penalty allocation;
- no logging or PR reward;
- the week is non-perfect unless protected.

## Rest-item resolution

A valid programmed rest item:

- earns its stored lower daily allocation;
- finalizes automatically at local day close;
- has no direct missed-workout penalty;
- cannot generate PR rewards;
- does not create another workout slot;
- remains non-punitive if the week is protected.

An unscheduled workout on a rest day earns no additional RR.

## Equal weekly missed-workout penalty pool

The accepted five-session routine has maximum direct missed-session exposure of:

```text
4 main misses * 20 RR + 1 specialization miss * 15 RR = 95 RR
```

The proposal preserves this weekly maximum:

```text
weeklyMissedWorkoutPenaltyPool = 95 RR
```

The pool is divided only across workout items using equal weights and the largest-remainder method.

Examples:

| Workout days | Stored missed penalties | Weekly maximum |
|---:|---|---:|
| 4 | 24, 24, 24, 23 | 95 |
| 5 | 19, 19, 19, 19, 19 | 95 |
| 6 | 16, 16, 16, 16, 16, 15 | 95 |

Penalties are never multiplied and never reduce lifetime XP.

## Normalized failed-week rule

The accepted fixed rule of fewer than three fully completed sessions is not valid for variable routine frequency.

Proposed rule:

```text
workoutCompletionRatio =
  fullyCompletedWorkoutItems / scheduledWorkoutItems

failedWeek =
  unprotected AND workoutCompletionRatio < 0.60
```

Direct missed-workout penalties apply before existing rank-local failed-week decay.

## PR fairness

The accepted cap of two rewarded PRs per session favors users with more workout days.

Proposed `rank-v6` rule:

```text
qualified PR = +5 raw RR and +5 lifetime XP
maximum rewarded PRs per week = 2
maximum weekly PR reward = 10 raw RR
```

All existing PR validation rules remain:

- first result is a baseline;
- same exercise and equipment variant;
- comparable technique and range of motion;
- valid load or repetition improvement;
- no warm-up, assisted, partial, historical, duplicate, or deload PR;
- one reward per exercise per week.

## Consistency and milestones

Preserved:

- 1.00x before five consecutive perfect weeks;
- 1.50x at Week 5;
- 2.00x at Week 10;
- 2.50x at Week 15+;
- milestone-week top-up after perfect-week confirmation;
- any unprotected non-perfect week resets the streak and multiplier;
- protected pauses freeze rather than reset;
- a fully completed swapped week remains perfect;
- perfect-week bonus remains `25 RR` and `25 lifetime XP`;
- existing once-per-account streak milestones remain unchanged.

A perfect week requires all scheduled workout items to be fully completed and fully logged after valid swaps and protection resolution. Programmed rest items finalize automatically and do not create extra user check-in obligations.

## Swap and free-credit rules

Preserved without change:

- maximum two confirmed swaps per week;
- one free credit or up to `5 RR` per confirmed swap;
- user explicitly selects payment;
- two free credits granted monthly;
- credits never expire and have no balance cap;
- free credits do not increase the weekly swap limit;
- no retroactive or cross-week swaps;
- exact-instrument restoration during auditable correction.

## Anti-gaming rules

1. Users cannot edit rank weights, weekly pools, penalties, thresholds, or multipliers.
2. Published routines are immutable.
3. Routine changes apply only to future unlocked weeks.
4. MVP routine frequency is limited to four through six workout days.
5. A weekly plan's allocations are immutable after materialization.
6. Reducing exercises or sets does not rewrite historical prescriptions.
7. Extra workouts and extra sets earn no RR.
8. Rest days cannot be converted into extra rewarded sessions.
9. The client cannot submit RR, XP, penalty, rank, or wallet balances.
10. All awards and reversals use stored values and configuration versions.
11. A routine version with invalid or trivial prescriptions cannot be published as reward eligible.
12. Manual corrections require an audit event.

## Required proposed records

```text
dailyRewardAllocation = {
  weeklyPlanItemId,
  dayType,
  dayWeight,
  activeMultiplier,
  weeklyDailyPool,
  exactShare,
  allocatedRR,
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
  completionFactor,
  awardedRR,
  awardedLifetimeXP,
  finalizedAt,
  rankConfigVersion,
  voidedAt,
  voidReason
}
```

## Preliminary calibration

A deterministic-seed Monte Carlo check used `50,000` synthetic users for each supported routine frequency while preserving:

- Adonis at `5,500 RR`;
- the accepted 72% perfect, 23% compliant, and 5% weak week profile;
- the accepted swap-frequency profile;
- bankable monthly free swaps;
- expected PR frequency;
- existing multipliers, milestones, perfect-week bonus, and rank ladder.

Preliminary results:

| Workout days | Mean weeks | Median | 25th percentile | 75th percentile | 90th percentile |
|---:|---:|---:|---:|---:|---:|
| 4 | 42.87 | 43 | 40 | 46 | 49 |
| 5 | 42.00 | 42 | 39 | 45 | 48 |
| 6 | 41.41 | 42 | 39 | 45 | 47 |

The maximum perfect-week opportunity is exactly equal. The remaining synthetic mean spread is approximately `1.46 weeks`, caused primarily by discrete workout counts in compliant and weak weeks.

This is sufficient to show that the formula is directionally viable. It is not sufficient to activate `rank-v6` without a dedicated balance audit and explicit acceptance threshold for cross-routine variance.

## Migration

No production migration is currently required because Stone Set has no runtime, accounts, persisted routines, schedules, or rank transactions.

If implementation begins under `rank-v6` and `schedule-v3`, every historical record must retain its configuration version. Future changes must never recalculate finalized history from a new formula.

## Acceptance conditions

This proposal becomes authoritative only after a dedicated product audit confirms:

1. the four-to-six-day frequency boundary;
2. the rest-day reward behavior;
3. the 110/167/220/277 weekly pools;
4. the 4:1 workout-to-rest weight;
5. the 95 RR weekly missed-workout penalty pool;
6. the weekly two-PR cap;
7. the normalized failed-week threshold;
8. acceptable cross-routine calibration variance;
9. routine publication and anti-gaming controls;
10. synchronized updates to `RANK_SYSTEM.md`, `WEEKLY_SCHEDULING.md`, context documents, and audit history.
