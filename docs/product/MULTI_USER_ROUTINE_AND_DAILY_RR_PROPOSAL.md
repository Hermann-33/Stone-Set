# Stone Set Multi-User Routine and Daily RR Activation Analysis

Updated: 2026-08-04
Status: `ACCEPTED SUPPORTING ANALYSIS`
Task: `TASK-PD-008`
Activated rank configuration: `rank-v6`
Activated scheduling configuration: `schedule-v3`

## Purpose

This document preserves the analysis used to replace the fixed five-session reward model with a normalized multi-user model.

The authoritative active rules are now:

- `docs/product/RANK_SYSTEM.md` for `rank-v6`;
- `docs/product/WEEKLY_SCHEDULING.md` for `schedule-v3`.

This document is supporting evidence, not a competing canonical specification.

## Decision

The proposed model was accepted by the product owner and activated through `TASK-PD-008`.

The accepted MVP supports:

```text
4-6 workout days per week
1-3 programmed rest days
7 total weekly plan items
```

Every user has the same maximum weekly RR opportunity despite routine-frequency differences.

## Accepted normalization

### Weekly RR pools

| Multiplier | Daily-item pool | Perfect-week bonus | Maximum no-PR weekly RR |
|---:|---:|---:|---:|
| 1.00x | 110 | 25 | 135 |
| 1.50x | 167 | 25 | 192 |
| 2.00x | 220 | 25 | 245 |
| 2.50x | 277 | 25 | 302 |

### Allocation weights

```text
workout item weight = 4
rest item weight = 1
```

Allocations use a largest-remainder calculation with earlier calendar date as the deterministic tie-break.

### Lifetime XP

The ordinary weekly base-XP item pool remains `110` regardless of consistency multiplier. Rank RR accelerates through consistency; ordinary lifetime XP does not.

### Missed-workout penalties

```text
weeklyMissedWorkoutPenaltyPool = 95 RR
```

The pool is divided across workout items only.

| Workout days | Penalty allocation | Total |
|---:|---|---:|
| 4 | 24, 24, 24, 23 | 95 |
| 5 | 19, 19, 19, 19, 19 | 95 |
| 6 | 16, 16, 16, 16, 16, 15 | 95 |

### PR normalization

```text
valid PR = 5 raw RR and 5 lifetime XP
maximum rewarded PRs per week = 2
```

PR RR remains consistency-multiplied. PR lifetime XP remains unmultiplied.

### Failed-week normalization

```text
workoutCompletionRatio =
  fullyCompletedWorkoutItems / scheduledWorkoutItems

failedWeek =
  unprotected AND workoutCompletionRatio < 0.60
```

## Rest-item decision

A programmed rest item:

- receives a smaller stored RR and base-XP allocation;
- finalizes automatically at local day close;
- requires no fake check-in;
- has no missed-workout penalty;
- cannot produce PRs;
- cannot become an extra rewarded workout.

This rewards adherence to the complete prescribed week rather than rewarding inactivity in isolation.

## Routine ownership decision

- Initial provisioned accounts: two.
- The data model must not hardcode a maximum of two accounts.
- Public registration is excluded from MVP.
- Each user manages only their own routine drafts.
- Published routine versions are immutable.
- Routine changes apply only to future unlocked weeks.
- Materialized schedules and historical reward allocations are never recalculated from later routine edits.

## Fairness verification

The perfect-week ceiling is exactly equal across all supported frequencies.

A deterministic-seed preliminary simulation used 50,000 synthetic users for each frequency while preserving the accepted consistency, swap, PR, milestone, and rank assumptions.

| Workout days | Mean weeks | Median | 25th percentile | 75th percentile | 90th percentile |
|---:|---:|---:|---:|---:|---:|
| 4 | 42.87 | 43 | 40 | 46 | 49 |
| 5 | 42.00 | 42 | 39 | 45 | 48 |
| 6 | 41.41 | 42 | 39 | 45 | 47 |

The maximum synthetic mean spread is approximately `1.46 weeks`.

This variance was accepted because:

1. maximum weekly opportunity is identical;
2. the difference arises from discrete workout counts in imperfect weeks;
3. medians remain within one week;
4. all frequencies remain approximately aligned with the ten-month target;
5. the model is simpler and more auditable than frequency-specific rank ladders.

The simulation remains synthetic balance evidence, not observed user data.

## Preserved product behavior

- 20 ranks ending at Adonis;
- Adonis at `5,500 RR`;
- 1.50x, 2.00x, and 2.50x at Weeks 5, 10, and 15;
- exact milestone-week top-ups;
- full reset after an unprotected non-perfect week;
- protected full-week freezes;
- perfect-week and streak-milestone rewards;
- two weekly swaps;
- two monthly non-expiring, uncapped free-swap credits;
- explicit credit-versus-`5 RR` payment choice;
- rank-local failed-week decay;
- no daily decay;
- no RR or XP for unscheduled extra workouts or sets;
- stored-value reversals and configuration versioning.

## Remaining implementation blocker

The normalized economics are accepted. Implementation still requires concrete reward-eligibility validation for user-created routines. Without it, a user could publish an empty or trivial workout prescription and receive the same weekly pool.

That validation must be closed before routine publication or reward materialization is implemented.

## Activation result

- `rank-v6` supersedes `rank-v5`.
- `schedule-v3` supersedes `schedule-v2`.
- No migration is required because Stone Set has no runtime, accounts, schedules, or persisted rank history.
- Future balance changes require new configuration versions and explicit migration behavior.