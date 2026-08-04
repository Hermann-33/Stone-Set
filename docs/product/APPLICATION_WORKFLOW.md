# Stone Set End-to-End Application Workflow

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT WORKFLOW`
Task: `TASK-PD-008`
Rank configuration: `rank-v6`
Scheduling configuration: `schedule-v3`

## Purpose

This document defines the accepted user workflow for the Stone Set Flutter mobile application and Flutter Web routine-management dashboard.

It is a product and implementation-planning baseline. No application, database, authentication runtime, dashboard, or deployment exists yet.

## Product surfaces

### Flutter mobile application

The mobile application is the execution surface for:

- authentication;
- viewing the current week;
- viewing free-swap balance and rank state;
- previewing and confirming schedule swaps;
- starting and completing workouts;
- entering working-set results;
- viewing provisional and finalized rewards;
- reviewing progression recommendations;
- submitting protected-interruption and correction requests.

### Flutter Web dashboard

The dashboard is the management surface for:

- viewing the user's own routine versions;
- creating and editing routine drafts;
- configuring workout days, rest days, exercises, sets, repetitions, RIR, rest periods, priority, and variants;
- validating a draft before publication;
- previewing the next weekly schedule and normalized RR allocation;
- publishing a routine version for a future week;
- reviewing historical routine versions and audit history.

An ordinary user cannot edit another user's routine, rank, wallet, or history.

### Supabase backend

Supabase is the accepted authentication and persistence platform.

The backend owns:

- user identity and sessions;
- user-owned routine versions;
- weekly plans and immutable schedule snapshots;
- workout logs and set records;
- RR, XP, PR, swap, free-credit, penalty, consistency, and correction ledgers;
- server-authoritative validation and finalization.

## Actors and account model

- Initial provisioned users: `2`.
- Public self-registration: disabled for MVP.
- Account count is not hardcoded into the data model.
- Each account owns its routine, schedule, logs, rank state, and history.
- Passwords are managed by Supabase Auth and never stored in application tables.
- A profile stores unique username, display name, timezone, units, and non-sensitive preferences.

## 1. Account provisioning and sign-in

1. An authorized operator creates the initial accounts through Supabase Auth.
2. A matching profile is created for each Auth user.
3. The user signs in through mobile or dashboard.
4. The client receives an authenticated session.
5. Every data request is restricted to the authenticated user's permitted rows.
6. Failed or expired sessions return to sign-in without exposing another account's cached private data.

## 2. First-use setup

1. The user confirms display name, username, reward timezone, and unit preferences.
2. The system selects or imports an initial routine version.
3. The routine passes reward-eligibility validation before publication.
4. The first weekly plan is materialized from the published routine.
5. The current month's free-swap grant is materialized once.
6. The rank snapshot starts under `rank-v6` and `schedule-v3`.

## 3. Routine draft and publication

1. The user opens the dashboard.
2. The dashboard loads the current published routine and version history.
3. The user creates a draft rather than editing a published version in place.
4. The user may edit:
   - training and rest days;
   - workout names and order;
   - exercise identity and equipment variant;
   - exercise order and priority;
   - working sets;
   - repetition ranges;
   - RIR targets;
   - rest duration;
   - permitted substitutions and notes.
5. Validation checks that the draft:
   - contains exactly seven day slots;
   - contains four through six workout days;
   - contains at least one programmed rest day;
   - has valid item and exercise ordering;
   - has valid set, repetition, RIR, and rest values;
   - passes the accepted anti-triviality reward-eligibility rules;
   - can generate deterministic RR, XP, and penalty allocations;
   - cannot alter historical weeks.
6. The dashboard previews:
   - resulting schedule;
   - workout and rest allocations;
   - fixed weekly RR ceiling;
   - recovery warnings;
   - effective week.
7. The user publishes the draft.
8. Publication creates a new immutable routine version.
9. The version becomes effective on the next Monday that has not been materialized or locked.
10. Existing and historical weeks retain their original routine version and allocations.

## 4. Weekly plan materialization

At or before a Monday-Sunday week:

1. Materialize any due monthly free-swap grant idempotently.
2. Select the published routine version effective for the week.
3. Create seven dated plan items.
4. Store each item's workout or rest identity and prescription.
5. Calculate and store `rank-v6` RR and base-XP allocations.
6. Calculate and store missed-workout penalty allocations.
7. Store `rank-v6` and `schedule-v3` configuration versions.
8. Store reward timezone and week boundary.
9. Expose the immutable base schedule and mutable pre-lock current schedule.

Later routine edits cannot regenerate a materialized week's plan items or allocations.

## 5. Mobile home

After sign-in, the home screen shows:

- today's plan item;
- seven-day schedule;
- day lock state;
- swaps used and remaining;
- free-swap balance;
- current RR, rank, and next-rank progress;
- consecutive-perfect-week count and multiplier;
- provisional awards and pending penalties;
- next required action.

Provisional values must be visually distinguished from finalized ledger entries.

## 6. Schedule swap

1. The user selects two distinct unlocked dates in the active week.
2. The app verifies legality under `schedule-v3`.
3. The preview shows:
   - current items;
   - post-swap order;
   - recovery warnings;
   - swaps remaining;
   - free-swap balance before and after;
   - `Use 1 free swap` and `Pay 5 RR` when applicable.
4. The user selects the payment method.
5. The user confirms.
6. The backend atomically:
   - exchanges the plan items;
   - preserves item identity and allocations;
   - consumes one weekly allowance;
   - consumes one credit or applies the stored RR deduction;
   - writes audit records.
7. A canceled preview changes nothing.
8. User-initiated restoration requires another legal swap and another payment.

## 7. Workout execution

1. The user opens today's workout item.
2. The app shows prescription, previous comparable results, targets, RIR, rest periods, and recommendation.
3. The user starts the session.
4. Starting locks the date and starts the 60-minute timer.
5. The user records each working set:
   - exercise and equipment variant;
   - load;
   - repetitions;
   - RIR;
   - completion status;
   - optional note or pain flag.
6. Rest timers use prescribed values and may be adjusted without mutating the routine version.
7. The app autosaves an in-progress local draft and synchronizes when connected.
8. The app warns at the time cap and applies the accepted final low-priority-set removal rule.
9. The user ends the session.
10. The backend validates completion, priority exercises, logging completeness, time-cap compliance, PR evidence, and duplication.
11. The item becomes fully completed, incomplete-logging, partial, missed/invalid, protected, or pending correction.
12. The app displays the server-returned provisional award.

The client never submits an authoritative reward amount.

## 8. Programmed rest

1. A rest item remains visible as today's plan.
2. No workout or manual rest check-in is required.
3. The item finalizes automatically at local day close.
4. It earns its stored lower RR and base-XP allocations.
5. It has no direct missed-workout penalty.
6. An unscheduled workout earns no additional RR or XP.

## 9. Daily reward processing

For every plan item:

1. The weekly plan already contains stored allocations.
2. The backend resolves the item from verified state.
3. The backend writes an immutable ordinary award or zero-award record.
4. Missed workout penalties use stored penalty allocations and are never multiplied.
5. PR rewards use validation evidence and the weekly two-PR cap.
6. Corrections reverse stored values rather than recalculating history with current formulas.

Daily values remain provisional until weekly finalization completes all dependent rules.

## 10. Weekly finalization

After Sunday 23:59 in the reward timezone, or through an authorized finalization operation:

1. Confirm monthly grant ledger integrity.
2. Freeze the final post-swap schedule.
3. Apply approved protected states and corrections.
4. Resolve all seven plan items.
5. Validate and cap PR awards.
6. Apply direct missed-workout penalties.
7. Calculate workout-completion ratio.
8. Classify the week as perfect, non-perfect, failed, or protected.
9. Increment, freeze, or reset consistency.
10. Apply Week 5, 10, or 15 top-ups when eligible.
11. Apply first-time streak milestones.
12. Apply the perfect-week bonus.
13. Apply rank-local decay only for an unprotected failed week.
14. Store immutable schedule, wallet, reward, rank, and weekly-evaluation snapshots.
15. Expose finalized rank and next-week state.

Finalization is idempotent. Re-running it cannot duplicate a grant, award, penalty, PR, milestone, top-up, or decay transaction.

## 11. Progression recommendation

After a valid completed workout:

1. Compare the result with the previous comparable exercise variant.
2. Apply double progression.
3. Recommend holding load, adding repetitions, increasing load, or maintaining the prescription.
4. Never mutate the published routine automatically.
5. The user may accept or reject the next-session recommendation.
6. An override records its selected value and reason.
7. Pain flags stop normal recommendation generation for the movement and enter substitution or protected-interruption handling without medical diagnosis.

## 12. Protected interruptions and corrections

Protected events include approved pain, acute illness, gym closure, travel, or equivalent interruption.

The workflow must:

- require an auditable reason;
- avoid medical diagnosis;
- distinguish an item-level protection from a protected full week;
- freeze consistency only when the accepted full-week rule applies;
- avoid missed penalties and failed-week decay for protected obligations;
- preserve monthly free-swap grants;
- avoid automatically refunding a valid earlier swap;
- record backdated changes as corrections;
- reverse only stored transactions affected by the correction.

## 13. History and transparency

Users can inspect:

- routine versions and effective dates;
- weekly schedules and swaps;
- workout and set history;
- PR evidence;
- daily awards;
- RR and lifetime-XP transactions;
- free-swap grants and consumption;
- penalties, decay, milestones, and top-ups;
- protected periods and corrections;
- configuration versions used for every historical result.

## MVP boundary

The MVP includes:

- two provisioned accounts;
- Flutter mobile application;
- Flutter Web routine dashboard;
- Supabase Auth and Postgres;
- user-owned versioned routines;
- weekly plan materialization;
- swaps and free-swap wallet;
- workout execution and logging;
- daily and weekly reward finalization;
- rank history and audit records;
- basic progression recommendations;
- protected-state and correction records.

## Explicit MVP exclusions

- public registration;
- social login;
- coach or organization accounts;
- one ordinary user editing another user's routine;
- nutrition or sleep tracking;
- chat, feeds, leaderboards, or public profiles;
- payments or subscriptions;
- wearable integration;
- automatic medical or injury decisions;
- arbitrary extra-workout rewards;
- production analytics beyond operational error logging;
- unversioned historical recalculation.

## Implementation prerequisites

This workflow is accepted. Implementation remains blocked until:

1. concrete anti-triviality reward-eligibility rules are accepted for user-created routines;
2. local in-progress-workout persistence and offline finalization boundaries are accepted;
3. mobile release targets are accepted;
4. dashboard hosting is accepted;
5. production backup and operational-access expectations are accepted;
6. the first bounded implementation task packet is approved.