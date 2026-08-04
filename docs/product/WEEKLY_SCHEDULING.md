# Stone Set Weekly Scheduling and Session Swaps

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PD-004`

## Purpose

This document defines how the fixed weekly hypertrophy program may be rearranged inside a single calendar week without changing the program itself.

The feature exists for weeks where the owner cannot train on the originally planned day but can still complete the session later in that same week.

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

The limit resets when the next Monday–Sunday week begins.

# 3. Rank cost

Every confirmed swap deducts:

```text
-5 rankRR
```

Rules:

- the deduction applies immediately when the swap is confirmed;
- it affects `rankRR` only;
- it does not reduce `lifetimeXP`;
- the consistency multiplier never increases the deduction;
- the penalty is the same for workout-to-rest and workout-to-workout exchanges;
- the maximum swap cost in one week is `-10 RR`;
- `rankRR` is clamped at zero.

The cost exists because the user deviated from the original weekly plan while still preserving a less severe consequence than missing the session entirely.

# 4. Wednesday-to-Sunday example

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

Immediate rank transaction:

```text
swap penalty = -5 RR
```

If the Sunday session is completed, there is no missed-session penalty.

If the Sunday session is missed, the user also receives the specialization-session missed penalty:

```text
swap penalty = -5 RR
missed specialization session = -15 RR
total direct loss = -20 RR
```

# 5. Perfect-week and consistency behavior

Swapping dates does not reduce completion credit by itself.

If all five scheduled sessions are fully completed after the rearrangement:

- the week is still classified as perfect;
- the week still contributes `1.0` consistency credit;
- the perfect-week streak may continue;
- the normal perfect-week bonus is still awarded;
- the swap penalty remains deducted.

This avoids double punishment. The swap cost accounts for schedule deviation; session completion still counts as adherence to the weekly program.

# 6. Locking rules

A day cannot participate in a swap after it becomes locked.

A day becomes locked when any of the following occurs:

1. its scheduled workout is started;
2. its scheduled workout is completed, partially completed, invalidated, protected, or finalized;
3. local time passes 23:59 on that date;
4. the week is finalized.

Therefore:

- a Wednesday session may be swapped with Sunday at any point before Wednesday locks;
- the app cannot retroactively turn a past missed Wednesday into a rest day on Thursday or later;
- a completed workout cannot be moved to another date;
- a past rest day cannot be exchanged after that day closes.

# 7. Confirmation behavior

Before confirmation, the app must show:

- both selected days;
- each day's current scheduled item;
- the schedule after the exchange;
- the `-5 RR` deduction;
- swaps remaining after confirmation;
- recovery warnings produced by the resulting order.

The user must explicitly confirm the transaction.

A canceled preview does not consume a swap and does not deduct RR.

# 8. Recovery warnings

Any-day swapping is allowed, but the app must warn when the resulting sequence may reduce recovery quality, including:

- Upper A and Upper B on consecutive days;
- Lower A and Lower B on consecutive days;
- four or more consecutive resistance-training days;
- a lower session immediately before another demanding lower session;
- moving a session so close to the next week's related session that recovery may be compromised.

Warnings are advisory. They do not block a valid swap because the accepted requirement permits any unlocked day to be exchanged with any other unlocked day.

# 9. Undo and second swaps

A confirmed swap has no free undo.

To restore the previous order, the user must perform another valid swap:

- it consumes the second weekly swap;
- it deducts another `5 RR`;
- it is blocked if either day has become locked.

Only a system correction for an accidental duplicate transaction, corrupted record, or invalid application may void a swap without consuming another user swap. The correction must restore the exact stored RR deduction and create an audit event.

# 10. Interaction with missed-session penalties

At weekly finalization, missed-session evaluation uses the final post-swap schedule.

The session identity travels with the workout:

- a moved main session still has a `-20 RR` missed penalty;
- the moved specialization session still has a `-15 RR` missed penalty;
- a moved rest day remains non-punitive.

A swap penalty and a later missed-session penalty are separate transactions and may both apply.

# 11. Protected states and deloads

- Programmed rest days remain non-punitive after being moved.
- A prescribed deload session may be swapped under the same two-swap limit and still costs `5 RR`.
- A later protected pause does not automatically refund a previously confirmed user swap.
- A swap penalty is reversed only when the swap itself is voided through an auditable correction.
- The app must not use medical judgment to decide whether the user is fit to train.

# 12. Anti-exploit rules

1. Swaps cannot cross Monday–Sunday week boundaries.
2. Swaps cannot create duplicate sessions.
3. Swaps cannot remove a required session from the week.
4. Swaps cannot add a third rest day or sixth rewarded workout.
5. A confirmed swap consumes one of two weekly allowances.
6. Swapping back is not free.
7. A past or started day cannot be swapped.
8. A rest-to-rest no-op cannot consume a swap.
9. Session rewards remain attached to session identity, not weekday name.
10. Weekly finalization uses the final immutable schedule snapshot.

# 13. Required records

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
  requestedPenaltyRR: 5,
  appliedPenaltyRR,
  rankRRBefore,
  rankRRAfter,
  confirmedAt,
  scheduleConfigVersion,
  rankConfigVersion,
  voidedAt,
  voidReason,
  restoredRR
}
```

The record stores both requested and actually applied RR because rank cannot fall below zero.

# 14. Weekly finalization order

Scheduling must resolve before session penalties and weekly rank evaluation.

```text
1. Lock the week's final schedule.
2. Validate the two-swap limit and swap records.
3. Apply approved corrections and protected states.
4. Resolve every scheduled session against its final assigned date.
5. Apply missed-session penalties where required.
6. Classify the week.
7. Apply consistency, streak, weekly reward, and failed-week decay rules.
8. Store the immutable weekly schedule and evaluation snapshots.
```

## Non-negotiable rules

1. Maximum two confirmed swaps per week.
2. Any two distinct unlocked days in the active week may be exchanged.
3. Each confirmed swap costs `5 RR`.
4. Swap penalties never reduce lifetime XP.
5. Swap penalties are never multiplied.
6. Swaps change dates, not the number or identity of sessions.
7. A fully completed swapped week can still be perfect.
8. Retroactive swaps are prohibited.
9. A second swap is required to restore a confirmed swap.
10. All swap and correction transactions are auditable.