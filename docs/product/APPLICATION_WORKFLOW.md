# Stone Set End-to-End Application Workflow

Updated: 2026-08-04
Status: `PROPOSED PRODUCT WORKFLOW`
Task: `TASK-PL-001`

## Purpose

This document defines the complete planned user workflow for the Stone Set mobile application and web routine-management dashboard.

It is documentation only. No application, database, authentication system, dashboard, or runtime behavior exists yet.

The workflow remains proposed because the multi-user variable-routine scheduling and normalized daily-RR model must be accepted as `schedule-v3` and `rank-v6` before implementation begins.

## Product surfaces

### Flutter mobile application

The mobile application is the execution surface for:

- authentication;
- viewing the current week;
- viewing the free-swap balance and rank state;
- previewing and confirming schedule swaps;
- starting and completing workouts;
- entering working-set results;
- viewing provisional and finalized rewards;
- reviewing progression recommendations;
- submitting protected-interruption and correction requests.

### Flutter Web dashboard

The web dashboard is the management surface for:

- viewing the user's own routine versions;
- creating and editing routine drafts;
- configuring workout days, rest days, exercises, sets, repetitions, RIR, rest periods, priority, and exercise variants;
- validating a draft before publication;
- previewing the next weekly schedule and normalized RR allocation;
- publishing a routine version for a future week;
- reviewing historical routine versions and audit history.

The dashboard does not permit one ordinary user to edit another user's routine or rank state.

### Supabase backend

Supabase is planned as the authoritative persistence and authentication platform.

The backend owns:

- user identity and sessions;
- user-owned routine versions;
- weekly plans and immutable schedule snapshots;
- workout logs and set records;
- rank, RR, XP, PR, swap, free-credit, penalty, consistency, and correction ledgers;
- server-authoritative validation and finalization.

## Actors and account model

- Initial provisioned users: `2`.
- Public self-registration: disabled for MVP.
- Account count must not be hardcoded into the data model.
- Each account owns its routine, schedule, logs, rank state, and history.
- Passwords are managed by Supabase Auth and are never stored in an application table.
- A public profile stores a unique username, display name, timezone, and non-sensitive account settings.

## 1. Account provisioning and sign-in

1. An authorized operator creates the two initial accounts through Supabase Auth.
2. A matching application profile is created for each Auth user.
3. The user signs in through the mobile app or web dashboard.
4. The client receives an authenticated session.
5. Every subsequent data request is restricted to the authenticated user's rows.
6. A failed or expired session returns the user to sign-in without exposing cached private data to another account.

## 2. First-use setup

1. The user confirms display name, username, reward timezone, and unit preferences.
2. The system selects or imports an initial routine version.
3. The routine is validated before it becomes reward eligible.
4. The first weekly plan is materialized from the published routine.
5. The current calendar month's free-swap grant is materialized once.
6. The initial rank snapshot starts under the active accepted rank configuration.

## 3. Routine draft and publication workflow

1. The user opens the web dashboard.
2. The dashboard loads the currently published routine and its version history.
3. The user creates a new draft instead of editing the published version in place.
4. The user may edit:
   - training and rest days;
   - workout names and order;
   - exercise identity and equipment variant;
   - exercise order and priority;
   - prescribed working sets;
   - repetition ranges;
   - RIR targets;
   - rest duration;
   - permitted substitutions and notes.
5. Validation checks that the draft:
   - contains exactly seven day slots;
   - stays inside the supported workout-frequency boundary;
   - contains at least one programmed rest day;
   - contains no duplicate day or exercise-order positions;
   - has valid set, repetition, RIR, and rest values;
   - can generate a deterministic weekly reward allocation;
   - does not alter historical weeks.
6. The dashboard previews:
   - the resulting weekly schedule;
   - workout and rest-day RR allocations;
   - the fixed weekly RR ceiling;
   - recovery warnings;
   - the effective week.
7. The user publishes the draft.
8. Publication creates a new immutable routine version.
9. By default, the new version becomes effective on the next Monday that has not been materialized or locked.
10. Existing and historical weeks continue to reference the version used when they were created.

## 4. Weekly plan materialization

At or before the start of a Monday-Sunday week:

1. Materialize any due monthly free-swap grant idempotently.
2. Select the published routine version effective for the week.
3. Create the seven dated weekly plan items.
4. Assign each item its workout or rest identity.
5. Calculate and store the week's daily RR allocations under the active rank configuration.
6. Calculate and store missed-workout penalty allocations.
7. Store the rank and schedule configuration versions.
8. Store the reward timezone and week boundary.
9. Expose the immutable base schedule and mutable pre-lock current schedule.

Once any day locks, the weekly reward allocation cannot be regenerated from a later routine edit.

## 5. Mobile home workflow

After sign-in, the home screen shows:

- today's plan item;
- the seven-day schedule;
- day lock status;
- swaps used and remaining;
- free-swap balance;
- current RR, rank, and progress to the next rank;
- current consecutive-perfect-week count and multiplier;
- provisional rewards and pending penalties;
- the next required action.

The app must distinguish provisional values from finalized ledger entries.

## 6. Schedule-swap workflow

1. The user selects two distinct unlocked days in the active week.
2. The app verifies that the exchange is legal under the active scheduling configuration.
3. The app previews:
   - both current items;
   - the post-swap order;
   - recovery warnings;
   - swaps remaining;
   - free-swap balance before and after;
   - `Use 1 free swap` and `Pay 5 RR` options when applicable.
4. The user explicitly selects the payment method.
5. The user confirms.
6. The backend atomically:
   - exchanges the schedule items;
   - preserves item identity and reward allocation;
   - consumes one weekly swap allowance;
   - consumes one free credit or applies the stored RR deduction;
   - writes the audit records.
7. A canceled preview changes nothing.
8. A user-initiated reversal requires another legal swap and another payment.

## 7. Workout execution workflow

1. The user opens today's workout item.
2. The app shows the prescribed exercises, previous comparable results, target ranges, RIR, rest periods, and progression recommendation.
3. The user starts the session.
4. Starting locks the day and starts the 60-minute session timer.
5. The user records each working set:
   - exercise and equipment variant;
   - load;
   - repetitions;
   - RIR;
   - completion status;
   - optional note or pain flag.
6. Rest timers run from the prescribed values and may be adjusted without changing the prescription record.
7. The app autosaves an in-progress draft locally and synchronizes it when connected.
8. The app warns at the time cap and applies the accepted low-priority-set removal rule.
9. The user ends the session.
10. The backend validates completion percentage, priority exercises, logging completeness, time-cap compliance, PR eligibility, and duplication.
11. The session becomes fully completed, partially completed, missed/invalid, protected, or pending correction.
12. A provisional daily award is displayed from server-returned stored values.

The client never submits an authoritative RR amount.

## 8. Rest-day workflow

1. A programmed rest item remains visible as today's plan.
2. No workout is required and no workout may be fabricated to earn additional RR.
3. Under the proposed normalized daily-RR model, the rest item finalizes automatically at local day close if it remains a valid programmed rest item.
4. A rest item earns its stored lower RR allocation.
5. A rest item has no direct missed-session penalty.
6. An unscheduled extra workout earns no RR and does not create another rewarded slot.

## 9. Daily reward workflow

For every daily plan item:

1. The weekly plan already contains a stored RR allocation.
2. The backend resolves the item from verified workout or rest state.
3. The backend writes an immutable daily award, partial award, or zero-award record.
4. Missed workout penalties use the week's stored penalty allocation and are never multiplied.
5. PR rewards use stored validation evidence and the active configuration cap.
6. Corrections reverse stored values rather than recalculating historical values from current configuration.

Daily awards remain provisional until all required weekly rules are finalized.

## 10. Weekly finalization workflow

After Sunday 23:59 in the reward timezone, or when an authorized finalization operation runs:

1. Confirm the monthly grant ledger.
2. Freeze the final post-swap schedule.
3. Apply approved protected states and corrections.
4. Resolve all seven daily plan items.
5. Apply direct missed-workout penalties.
6. Determine workout-completion ratio.
7. Classify the week as perfect, non-perfect, failed, or protected.
8. Increment, freeze, or reset consecutive-perfect-week state.
9. Apply milestone-week multiplier top-ups when eligible.
10. Apply first-time streak milestone rewards.
11. Apply the perfect-week bonus when eligible.
12. Apply rank-local decay only when the normalized failed-week condition is met.
13. Store immutable schedule, reward, wallet, rank, and weekly-evaluation snapshots.
14. Expose the finalized rank and next-week state.

Finalization is idempotent. Re-running it cannot duplicate a grant, award, penalty, milestone, or decay transaction.

## 11. Progression recommendation workflow

After a valid completed workout:

1. Compare the current exercise result with the previous comparable exercise variant.
2. Apply double-progression rules.
3. Recommend holding load, adding repetitions, increasing load, or maintaining the prescription.
4. Do not automatically change the published routine.
5. The user may accept or reject the next-session recommendation.
6. A user override records the selected value and reason.
7. Pain flags stop recommendation generation for the affected movement and direct the user to a substitution or protected-interruption flow without medical diagnosis.

## 12. Protected interruptions and corrections

Protected events include approved pain, acute illness, gym closure, travel, or equivalent interruption.

The workflow must:

- require an auditable reason;
- avoid medical diagnosis;
- distinguish a protected item from a protected full week;
- freeze rather than reset consistency only when the accepted protection rule applies;
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
- Supabase Auth and Postgres persistence;
- user-owned versioned routines;
- weekly plan materialization;
- swaps and free-swap wallet;
- workout execution and set logging;
- daily and weekly reward finalization;
- rank history and audit records;
- basic progression recommendations;
- protected-state and correction records.

## Explicit MVP exclusions

- public registration;
- social login;
- coach or organization accounts;
- one user editing another user's routine;
- nutrition or sleep tracking;
- chat, social feeds, leaderboards, or public profiles;
- payments or subscriptions;
- wearable integration;
- automatic medical or injury decisions;
- arbitrary extra-workout rewards;
- production analytics or telemetry beyond operational error logging;
- unversioned historical recalculation.

## Acceptance gate

This workflow cannot become an accepted implementation baseline until:

1. the multi-user variable-routine scheduling proposal is accepted;
2. the normalized daily-RR proposal is calibrated and accepted as `rank-v6`;
3. `schedule-v3` defines routine-frequency, day-locking, and routine-version activation rules;
4. platform connectivity and local-draft persistence constraints are accepted;
5. the first bounded implementation task is approved.
