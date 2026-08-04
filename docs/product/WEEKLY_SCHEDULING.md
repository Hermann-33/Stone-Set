# Stone Set Weekly Scheduling and Session Swaps

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PD-007`
Scheduling configuration: `schedule-v2`

## Purpose

This document defines how the fixed weekly hypertrophy program may be rearranged inside one calendar week without changing the program itself.

The feature exists for weeks where the owner cannot train on the originally planned day but can still complete the session elsewhere in that week.

## Base weekly schedule

| Day | Scheduled item |
|---|---|
| Monday | Upper A |
| Tuesday | Lower A |
| Wednesday | Delts and Forearms |
| Thursday | Rest |
| Friday | Upper B |
| Saturday | Lower B |
| Sunday | Rest |

A week runs from Monday 00:00 through Sunday 23:59 in the user's configured local timezone.

# 1. Swap definition

A swap exchanges the complete scheduled contents of two distinct days inside the same active week.

```text
swap(dayA, dayB)

dayA.after = dayB.before
dayB.after = dayA.before
```

The operation moves schedule items. It does not copy, delete, duplicate, or recreate them.

## Allowed combinations

- workout session with rest day;
- main session with specialization session;
- main session with another main session;
- any two distinct unlocked days in the same active week.

A rest-to-rest or otherwise identical no-op exchange is not confirmable because it changes nothing.

# 2. Weekly limit

```text
maximum confirmed swaps per week = 2
```

Each confirmed exchange counts as one swap operation even though two dates change.

Examples:

- Wednesday ↔ Sunday = one swap;
- Monday ↔ Friday = one swap;
- swapping the same pair back later = a second swap;
- after two confirmed swaps, no further swap is allowed in that week.

The weekly limit resets at the beginning of the next Monday-Sunday week.

Free-swap credits waive RR cost. They do not increase the two-swap weekly limit.

# 3. Monthly free-swap credits

Every calendar month grants:

```text
monthlyFreeSwapGrant = 2 credits
```

Rules:

- one credit pays for one confirmed swap without deducting RR;
- credits never expire;
- unused credits carry forward indefinitely;
- there is no maximum stored balance;
- grants occur regardless of whether the user trained, paused, or used swaps during the previous month;
- a new account receives the current calendar month's two-credit grant once;
- a credit cannot be converted into RR, lifetime XP, cash, or another reward;
- credits cannot be transferred between users.

## Grant timing

The monthly grant becomes effective at 00:00 on the first day of the month in the account's reward timezone.

The application may materialize the grant when it next opens, but the grant record must retain the effective month and month-boundary timestamp.

Each grant is idempotent and uniquely keyed by:

```text
(accountId, grantMonth)
```

where `grantMonth` is `YYYY-MM`.

A timezone change does not produce a second grant for a month already granted. Reward-timezone changes become effective for monthly grants from the next ungranted calendar month.

# 4. Paying for a confirmed swap

A confirmed swap uses exactly one payment method.

## Free-credit payment

When the balance is at least one and the user chooses to spend a credit:

```text
freeSwapBalance -= 1
appliedPenaltyRR = 0
```

The swap still:

- counts toward the weekly two-swap limit;
- follows every locking and schedule-integrity rule;
- remains separate from missed-session evaluation.

## RR payment

When the user chooses not to spend a credit, or the balance is zero:

```text
rankRR = max(0, rankRR - 5)
appliedPenaltyRR = min(5, rankRRBefore)
```

The deduction affects Rank Rating only and is never multiplied by consistency.

## User choice

Available free credits are not consumed silently.

Before confirmation, the user chooses:

- `Use 1 free swap` — zero RR loss; or
- `Pay 5 RR` — preserve the credit balance.

This permits long-term credit collection even when the user occasionally prefers to pay RR.

# 5. Wednesday-to-Sunday examples

Before:

| Day | Item |
|---|---|
| Wednesday | Delts and Forearms |
| Sunday | Rest |

After one confirmed swap:

| Day | Item |
|---|---|
| Wednesday | Rest |
| Sunday | Delts and Forearms |

## Using a free credit

```text
free-swap credits before = 4
credit consumed = 1
free-swap credits after = 3
swap RR penalty = 0
```

## Paying RR

```text
free-swap credits remain unchanged
swap RR penalty = -5 RR
```

If the Sunday specialization session is completed, no missed-session penalty applies.

If it is missed:

```text
free-credit swap + missed specialization = 0 - 15 RR
paid swap + missed specialization = -5 - 15 RR
```

A free credit waives only the swap charge. It never protects a later missed workout.

# 6. Perfect-week and consistency behavior

Swapping dates does not reduce completion credit by itself.

If all five scheduled sessions are fully completed after rearrangement:

- the week remains perfect;
- the perfect-week consistency streak may continue;
- the normal perfect-week bonus remains eligible;
- any consumed free credit remains consumed;
- any paid swap penalty remains deducted.

# 7. Locking rules

A day cannot participate in a swap after it becomes locked.

A day becomes locked when any of the following occurs:

1. its scheduled workout is started;
2. its scheduled workout is completed, partially completed, invalidated, protected, or finalized;
3. local time passes 23:59 on that date;
4. the week is finalized.

Therefore:

- a Wednesday session may be swapped with Sunday before Wednesday locks;
- the app cannot retroactively turn a past missed Wednesday into a rest day;
- a completed workout cannot be moved to another date;
- a past rest day cannot be exchanged after that date closes.

# 8. Confirmation behavior

Before confirmation, the app must show:

- both selected days;
- each day's current scheduled item;
- the schedule after exchange;
- free-swap balance before and after;
- available payment methods;
- RR deduction, if RR payment is selected;
- swaps remaining after confirmation;
- recovery warnings produced by the resulting order.

The user must explicitly confirm the schedule change and payment method.

A canceled preview:

- consumes no weekly swap;
- consumes no free credit;
- deducts no RR.

# 9. Recovery warnings

Any-day swapping is allowed, but the app must warn when the resulting sequence may reduce recovery quality, including:

- Upper A and Upper B on consecutive days;
- Lower A and Lower B on consecutive days;
- four or more consecutive resistance-training days;
- one demanding lower session immediately before another;
- moving a session too close to the following week's related session.

Warnings are advisory and do not block an otherwise valid swap.

# 10. Undo, restoration, and corrections

A confirmed user swap has no free undo.

To restore the previous order, the user must perform another valid swap:

- it consumes the second weekly swap;
- it requires another free credit or another `5 RR` payment;
- it is blocked if either day has become locked.

Only an auditable system correction may void a confirmed swap without consuming another weekly swap.

Correction restores the exact payment instrument used:

- a free-credit swap restores one free credit;
- a paid swap restores the exact stored RR deduction;
- no correction may restore both.

A duplicate monthly grant may be voided only through an audit event. If its credits were already consumed, the related consumptions must be corrected before the duplicate grant is removed; free-swap balance may never become negative.

# 11. Interaction with missed-session penalties

Weekly finalization evaluates the final post-swap schedule.

The session identity travels with the workout:

- moved main session: `-20 RR` if missed;
- moved specialization session: `-15 RR` if missed;
- moved rest day: no missed-session penalty.

Free-swap credits waive only the `5 RR` schedule-change cost. Missed-session penalties, failed-week decay, and consistency resets remain fully applicable.

# 12. Protected states and deloads

- Programmed rest days remain non-punitive after being moved.
- A prescribed deload session may be swapped under the same weekly limit.
- A free credit may be used for a deload-session swap.
- A later protected pause does not automatically refund a confirmed swap or consumed credit.
- A credit or RR deduction is restored only if the swap itself is voided through an auditable correction.
- The app must not use medical judgment to decide whether the user is fit to train.

# 13. Anti-exploit rules

1. Swaps cannot cross Monday-Sunday week boundaries.
2. Swaps cannot create duplicate sessions.
3. Swaps cannot remove a required session.
4. Swaps cannot add a third rest day or sixth rewarded workout.
5. Every confirmed swap consumes one of two weekly allowances.
6. Free credits do not create additional weekly allowances.
7. Swapping back is a second confirmed swap.
8. A past, started, or resolved day cannot be swapped.
9. A rest-to-rest no-op cannot consume a swap or credit.
10. Each calendar month can create exactly one two-credit grant per account.
11. Timezone changes cannot duplicate a monthly grant.
12. Credits cannot be converted, transferred, sold, or manually exchanged for RR.
13. Free-credit balance cannot become negative.
14. Session rewards remain attached to session identity, not weekday name.
15. Weekly finalization uses the final immutable schedule snapshot.

# 14. Required records

```text
freeSwapWallet = {
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
weeklySchedule = {
  weekId,
  timezone,
  baseSchedule,
  currentSchedule,
  confirmedSwapCount,
  maximumSwapCount: 2,
  swapRecords,
  finalizedAt
}
```

```text
swapRecord = {
  swapId,
  weekId,
  swapNumber,
  firstDate,
  secondDate,
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

# 15. Scheduling and finalization order

```text
1. Materialize any due monthly free-swap grant idempotently.
2. Preview the schedule exchange and payment methods.
3. Confirm the swap, consume one weekly allowance, and apply the selected payment.
4. Lock the week's final schedule at weekly finalization.
5. Validate the two-swap limit, grant ledger, credit balance, and swap records.
6. Apply approved corrections and protected states.
7. Resolve every scheduled session against its final assigned date.
8. Apply missed-session penalties where required.
9. Classify the week and apply rank consistency, rewards, and failed-week decay.
10. Store immutable schedule, wallet, and weekly-evaluation snapshots.
```

## Non-negotiable rules

1. Maximum two confirmed swaps per week.
2. Any two distinct unlocked days in the active week may be exchanged.
3. Two free-swap credits are granted each calendar month.
4. Free-swap credits never expire and have no balance cap.
5. One free credit waives one swap's `5 RR` cost.
6. The user may preserve credits and pay `5 RR` instead.
7. Free credits do not increase the weekly swap limit.
8. Swap payment never affects lifetime XP and is never multiplied.
9. Swaps change dates, not session count or identity.
10. A fully completed swapped week can still be perfect.
11. Retroactive and cross-week swaps are prohibited.
12. Restoring a confirmed schedule requires another swap unless the original transaction is voided as an auditable correction.
13. All grants, consumptions, swaps, payments, restorations, and corrections are auditable.
