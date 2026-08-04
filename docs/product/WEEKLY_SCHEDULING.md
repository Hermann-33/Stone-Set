# Stone Set Weekly Scheduling, Routine Versions, and Session Swaps

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PD-008`
Scheduling configuration: `schedule-v3`

## Purpose

This document defines Stone Set's authoritative weekly scheduling behavior for user-specific routines.

A user owns versioned routines. Each materialized Monday-Sunday week contains seven dated plan items made from the published routine version effective for that week. The schedule may be rearranged through controlled same-week exchanges without changing item identity, reward allocation, or historical data.

Rank Rating, daily-item awards, penalties, consistency, and PR consequences are defined in `docs/product/RANK_SYSTEM.md`.

# 1. Supported routine structure

A reward-eligible MVP routine contains:

```text
week length = 7 days
minimum workout days = 4
maximum workout days = 6
minimum programmed rest days = 1
```

Each day contains exactly one plan item:

```text
weeklyPlanItem.type = "workout" | "rest"
```

A workout item owns a complete exercise prescription. A rest item owns programmed recovery and cannot become an extra rewarded workout.

The five-session routine in `docs/product/HYPERTROPHY_ROUTINE.md` remains the accepted initial routine for the repository owner, but it is no longer the only supported schedule shape.

# 2. Routine ownership and versioning

Each account owns its routine drafts and published versions.

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

1. Drafts are editable by their owner.
2. Published versions are immutable.
3. Ordinary users cannot read or edit another user's private routine data.
4. Publication creates a new version rather than mutating the current published version.
5. A new version becomes effective no earlier than the next unlocked Monday.
6. Materialized, active, and historical weeks retain the routine version used at creation.
7. Routine publication cannot alter historical schedules, rewards, penalties, or PR records.
8. Frequency changes and publication events are auditable.
9. Users cannot edit rank pools, weights, thresholds, penalties, multiplier values, or wallet rules.
10. A draft must pass reward-eligibility validation before publication.

The exact anti-triviality validation criteria must be accepted before implementation.

# 3. Week definition and materialization

A week runs from Monday 00:00 through Sunday 23:59 in the account's reward timezone.

At or before the beginning of a week, the system atomically:

1. materializes any due monthly free-swap grant;
2. selects the published routine version effective for the week;
3. creates seven dated plan items;
4. stores workout or rest identity and prescription identity;
5. stores daily RR and base-XP allocations under `rank-v6`;
6. stores missed-workout penalty allocations;
7. stores the immutable base schedule;
8. creates the mutable pre-lock current schedule;
9. stores reward timezone, week boundary, `rankConfigVersion`, and `scheduleConfigVersion`.

Materialization is idempotent. The same account and week cannot produce duplicate weekly plans.

Once materialized, later routine changes cannot regenerate the week's plan items or allocations.

# 4. Weekly schedule records

```text
weeklySchedule = {
  weekId,
  userId,
  routineVersionId,
  rewardTimezone,
  weekStart,
  weekEnd,
  baseSchedule,
  currentSchedule,
  confirmedSwapCount,
  maximumSwapCount: 2,
  rankConfigVersion: "rank-v6",
  scheduleConfigVersion: "schedule-v3",
  finalizedAt
}
```

```text
weeklyPlanItem = {
  weeklyPlanItemId,
  weekId,
  scheduledDate,
  itemType: "workout" | "rest",
  prescriptionId,
  allocatedRR,
  allocatedBaseXP,
  allocatedMissedPenaltyRR,
  lockState,
  resolutionState,
  originalDate,
  currentDate
}
```

Reward and penalty allocations travel with the item. They do not belong to the weekday name.

# 5. Swap definition

A swap exchanges the complete scheduled contents of two distinct unlocked dates inside the same active week.

```text
swap(dayA, dayB)

dayA.after = dayB.before
dayB.after = dayA.before
```

The operation moves plan items. It does not copy, delete, duplicate, recreate, or alter them.

The following move with each item:

- workout or rest identity;
- prescription identity;
- daily RR allocation;
- base-XP allocation;
- missed-workout penalty allocation;
- item history and configuration versions.

## Allowed combinations

- workout with rest;
- workout with workout;
- any two distinct unlocked dates in the active week.

A rest-to-rest or otherwise identical no-op exchange is not confirmable because it changes nothing.

# 6. Weekly swap limit

```text
maximum confirmed swaps per week = 2
```

Each confirmed exchange counts as one swap even though two dates change.

- swapping the same pair back is a second swap;
- after two confirmed swaps, no third swap is allowed;
- the limit resets with the next Monday-Sunday week;
- free-swap credits waive RR cost but never increase the limit.

# 7. Monthly free-swap credits

Every account receives:

```text
monthlyFreeSwapGrant = 2 credits
```

Rules:

- one credit pays for one confirmed swap without deducting RR;
- credits never expire;
- unused credits carry forward indefinitely;
- there is no maximum balance;
- grants continue during inactivity and protected pauses;
- a new account receives the current month's grant once;
- credits cannot be converted into RR, XP, cash, or another reward;
- credits cannot be transferred between users.

## Grant timing and identity

The grant is effective at 00:00 on the first day of the month in the reward timezone.

```text
unique grant key = (accountId, grantMonth)
grantMonth = YYYY-MM
```

The application may materialize the grant later, but the record retains the effective month and boundary timestamp.

Timezone changes cannot duplicate an already granted month. A changed timezone applies from the next ungranted calendar month.

# 8. Paying for a swap

A confirmed swap uses exactly one payment method.

## Free-credit payment

When the balance is at least one and the user explicitly chooses it:

```text
freeSwapBalance -= 1
appliedPenaltyRR = 0
```

## RR payment

When the user preserves credits or has no credit:

```text
requestedPenaltyRR = 5
appliedPenaltyRR = min(5, rankRRBefore)
rankRR = max(0, rankRRBefore - 5)
```

Available credits are never consumed silently.

Before confirmation, the user chooses:

- `Use 1 free swap`; or
- `Pay 5 RR`.

Payment never affects lifetime XP and is never multiplied by consistency.

# 9. Swap preview and confirmation

Before confirmation, the application must show:

- both selected dates;
- each date's current item;
- the complete post-swap order;
- free-swap balance before and after;
- available payment methods;
- applied RR deduction when RR is selected;
- swaps remaining after confirmation;
- recovery warnings;
- lock conflicts.

The user explicitly confirms the schedule exchange and payment method.

A canceled preview:

- consumes no weekly allowance;
- consumes no credit;
- deducts no RR;
- changes no schedule record.

Confirmation is atomic. Schedule exchange, allowance consumption, selected payment, and audit records either all succeed or all fail.

# 10. Day locking

A date cannot participate in a swap after it becomes locked.

A date locks when any of the following occurs:

1. its workout item starts;
2. its item is completed, partially completed, invalidated, protected, or finalized;
3. local time passes 23:59 on that date;
4. the week is finalized.

Therefore:

- a past missed workout cannot be retroactively converted into rest;
- a completed item cannot be moved;
- a past rest item cannot be exchanged;
- a started workout cannot be moved;
- cross-week swaps are prohibited.

# 11. Recovery warnings

Any unlocked dates may be swapped, but the application warns when the resulting sequence may reduce recovery quality.

Warnings include:

- related upper-body sessions on consecutive days;
- related lower-body sessions on consecutive days;
- four or more consecutive resistance-training days;
- two demanding lower sessions without adequate separation;
- a moved workout placed too close to the next week's related workout;
- prescription-specific recovery conflicts defined by routine metadata.

Warnings are advisory. They do not block an otherwise valid swap.

# 12. Rest-item behavior

A programmed rest item:

- remains a real schedule item;
- receives the lower stored `rank-v6` allocation;
- finalizes automatically at local day close;
- has no missed-workout penalty;
- cannot generate PR rewards;
- cannot be converted into another rewarded workout through unscheduled activity.

A rest item moved through a swap retains its identity and allocation.

# 13. Perfect-week and consistency interaction

Swapping dates does not reduce completion credit by itself.

If every final scheduled workout item is fully completed and fully logged, and all rest items remain valid:

- the week can remain perfect;
- the consistency streak can continue;
- the perfect-week bonus remains eligible;
- a consumed credit remains consumed;
- a paid-swap penalty remains deducted.

The final post-swap schedule controls weekly evaluation.

# 14. Undo, restoration, and corrections

A confirmed user swap has no free undo.

Restoring the previous order requires another valid swap:

- it consumes the second weekly allowance when available;
- it requires another free credit or another `5 RR` payment;
- it is blocked if either date has locked.

Only an auditable system correction may void a confirmed swap without consuming another weekly allowance.

Correction restores exactly the original payment instrument:

- one credit for a free-credit swap; or
- the exact stored RR deduction for a paid swap;
- never both.

A duplicate monthly grant may be voided only through an audit event. Related consumptions must be corrected before removing already spent duplicate credits. Balance can never become negative.

# 15. Protected states and deloads

- A prescribed deload workout may be swapped under the same weekly limit.
- A free credit may pay for a deload-item swap.
- A later protected state does not automatically refund an earlier valid swap.
- A swap payment is restored only if the swap itself is voided.
- Programmed rest remains non-punitive after being moved.
- The application does not make medical fitness decisions.

# 16. Anti-exploit rules

1. Swaps cannot cross Monday-Sunday boundaries.
2. Swaps cannot create duplicate or missing plan items.
3. Swaps cannot add a rewarded workout or remove a required workout.
4. Every confirmed swap consumes one of two weekly allowances.
5. Free credits never create extra allowances.
6. Swapping back is another confirmed swap.
7. Past, started, resolved, or finalized dates cannot be swapped.
8. No-op exchanges cannot consume a swap or payment.
9. Each month creates exactly one two-credit grant per account.
10. Timezone changes cannot duplicate grants or weeks.
11. Credits cannot be converted, transferred, sold, or exchanged for RR.
12. Wallet balance cannot become negative.
13. Item rewards remain attached to item identity.
14. Published routine versions are immutable.
15. Routine edits apply only to future unlocked weeks.
16. Materialized allocations cannot be edited by the user.
17. Weekly finalization uses the final immutable schedule snapshot.
18. Clients cannot authoritatively set schedule counters, wallet balances, RR deductions, or finalization state.

# 17. Required wallet and swap records

```text
freeSwapWallet = {
  userId,
  balance,
  lifetimeGranted,
  lifetimeConsumed,
  rewardTimezone,
  updatedAt
}
```

```text
monthlyFreeSwapGrant = {
  grantId,
  accountId,
  grantMonth,
  quantity: 2,
  effectiveAt,
  materializedAt,
  rewardTimezone,
  scheduleConfigVersion,
  voidedAt,
  voidReason
}
```

```text
freeSwapConsumption = {
  consumptionId,
  swapId,
  quantity: 1,
  balanceBefore,
  balanceAfter,
  consumedAt,
  scheduleConfigVersion,
  restoredAt,
  restorationReason
}
```

```text
swapRecord = {
  swapId,
  weekId,
  swapNumber,
  firstDate,
  secondDate,
  firstItemId,
  secondItemId,
  firstItemBefore,
  secondItemBefore,
  firstItemAfter,
  secondItemAfter,
  paymentMethod: "free_credit" | "rank_rr",
  requestedPenaltyRR: 5,
  appliedPenaltyRR,
  freeSwapConsumptionId,
  rankRRBefore,
  rankRRAfter,
  confirmedAt,
  scheduleConfigVersion,
  rankConfigVersion,
  voidedAt,
  voidReason,
  restoredRR,
  restoredFreeCredits
}
```

# 18. Scheduling and weekly-finalization order

```text
1. Materialize any due monthly grant idempotently.
2. Select the published routine version effective for the week.
3. Materialize seven plan items and stored reward and penalty allocations.
4. Preview and confirm legal swaps with explicit payment selection.
5. Freeze the final schedule at weekly finalization.
6. Validate swap count, grant ledger, wallet balance, and item integrity.
7. Apply approved corrections and protected states.
8. Resolve every plan item against its final assigned date.
9. Apply missed-workout penalties where required.
10. Apply rank consistency, rewards, milestones, and failed-week decay.
11. Store immutable schedule, wallet, rank, and weekly-evaluation snapshots.
```

# 19. Configuration activation

`schedule-v3` supersedes `schedule-v2` for all new Stone Set implementation and future persisted records.

Preserved:

- Monday-Sunday week boundaries;
- any-two-unlocked-dates exchange semantics;
- maximum two swaps per week;
- explicit free-credit versus `5 RR` payment choice;
- two non-expiring, uncapped monthly credits;
- no free undo;
- locking, no-retroactive-swap, and cross-week prohibitions;
- recovery warnings and exact-instrument corrections.

Changed:

- scheduling supports user-specific versioned routines;
- weekly frequency may contain four through six workout days;
- seven plan items store normalized reward and penalty allocations;
- published routine versions activate only for future unlocked weeks;
- the fixed five-session schedule becomes an initial routine, not the universal schedule.

No production migration is required because no runtime, accounts, weekly plans, or schedule history exists.

## Non-negotiable rules

1. A week contains exactly seven plan items.
2. Supported MVP routines contain four through six workout items and at least one rest item.
3. Published routine versions are immutable.
4. Routine edits affect future unlocked weeks only.
5. Maximum two confirmed swaps per week.
6. Any two distinct unlocked dates may exchange complete plan items.
7. Two free-swap credits are granted each calendar month.
8. Credits never expire and have no balance cap.
9. One credit waives one swap's `5 RR` cost.
10. Users may preserve credits and pay RR.
11. Credits never increase the weekly swap limit.
12. Swaps change dates, not item count, identity, prescription, or allocations.
13. Fully completed swapped weeks may remain perfect.
14. Retroactive, started-item, resolved-item, and cross-week swaps are prohibited.
15. Restoring a confirmed order requires another swap unless corrected as a system error.
16. All routine versions, plans, grants, consumptions, swaps, payments, restorations, and corrections are auditable.
17. Future scheduling changes require a new configuration version and migration policy.