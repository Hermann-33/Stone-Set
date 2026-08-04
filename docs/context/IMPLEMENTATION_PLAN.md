# Stone Set Implementation Plan

Updated: 2026-08-04
Status: `PLANNING BASELINE — IMPLEMENTATION NOT AUTHORIZED`
Task: `TASK-PD-008`

## Purpose

This document defines the planned implementation sequence for Stone Set after the remaining implementation constraints are accepted.

It does not create code, schema, a Supabase project, credentials, infrastructure, accounts, or deployment.

## Accepted starting point

- Flutter mobile application.
- Separate Flutter Web routine-management dashboard.
- Shared Dart domain and data packages.
- Supabase Auth and Postgres.
- Row Level Security on user-owned data.
- Two provisioned accounts initially; public registration disabled.
- User-owned immutable routine versions.
- Accepted application workflow in `docs/product/APPLICATION_WORKFLOW.md`.
- Accepted rank configuration: `rank-v6`.
- Accepted scheduling configuration: `schedule-v3`.
- Four through six workout days per supported routine.
- Equal maximum weekly RR opportunity through normalized daily-item pools.
- Server-authoritative rewards, penalties, wallet transitions, and finalization.

## Remaining implementation authorization gate

Implementation may begin only after all of the following are accepted:

1. Concrete reward-eligibility and anti-triviality rules for user-created routines.
2. Local in-progress-workout persistence behavior.
3. Offline submission and server-finalization behavior.
4. Initial mobile release targets: Android only or Android and iOS.
5. Dashboard hosting target.
6. Production Supabase backup, recovery, and operator-access expectations.
7. The bounded `TASK-IMP-001` execution packet.

## Target architecture

```text
Flutter mobile app
  -> authenticated workout execution and history

Flutter Web dashboard
  -> user-owned routine drafting and publication

Shared Dart packages
  -> models, validation, repositories, and Supabase adapters

Supabase Auth
  -> credentials, sessions, account identity

Supabase Postgres + Data API/RPC
  -> RLS-protected user data, immutable ledgers, atomic transitions
```

Clients may calculate previews. The backend alone commits RR, XP, rank, penalties, milestones, wallet balances, and weekly-finalization results.

## Planned repository layout

```text
/apps/mobile/                 Flutter mobile application
/apps/dashboard/              Flutter Web dashboard
/packages/domain/             Pure domain rules and models
/packages/data/               Repository contracts and Supabase adapters
/packages/ui/                 Shared design tokens and widgets
/supabase/migrations/         Versioned database migrations
/supabase/seed.sql            Non-secret local seed data
/supabase/tests/              Database, RLS, and transaction tests
/docs/                        Product, architecture, decisions, plans, and audits
```

Responsibility boundaries are authoritative; exact package names may be refined during the foundation task.

## Planned data domains

### Identity

- profiles;
- username and display name;
- units and reward timezone;
- authorization metadata.

### Routine management

- routine definitions;
- immutable routine versions;
- day prescriptions;
- exercise prescriptions;
- exercise catalog and user-defined variants;
- validation and publication audit.

### Weekly planning

- weekly plans;
- seven dated plan items;
- `rank-v6` daily RR and base-XP allocations;
- 95 RR missed-penalty allocations;
- swaps, locks, and schedule snapshots.

### Workout execution

- sessions;
- exercise instances;
- working sets;
- timers;
- local synchronization identifiers;
- completion and protection states.

### Rank and rewards

- rank state;
- lifetime XP;
- daily awards;
- weekly-capped PR awards;
- perfect-week bonuses;
- multiplier top-ups;
- milestones;
- penalties and failed-week decay;
- immutable rank transactions.

### Free-swap wallet

- wallet snapshot;
- monthly grants;
- consumptions;
- swap payments;
- exact-instrument reversals.

### Audit and protection

- protected periods;
- correction events;
- immutable weekly evaluations;
- configuration versions.

## Security baseline

1. Supabase Auth manages passwords and sessions.
2. Public signup is disabled.
3. Initial accounts are provisioned administratively.
4. `profiles.id` references `auth.users.id`.
5. Every exposed user-owned table has RLS.
6. Policies combine authentication with ownership checks.
7. Users can access only their permitted rows.
8. Published routine versions and finalized ledgers are immutable through ordinary CRUD.
9. Sensitive multi-table transitions are atomic and narrowly scoped.
10. Public clients never contain service-role or secret keys.
11. Authorization never trusts user-editable metadata.
12. Clients never submit authoritative reward totals.
13. Corrections create audit records and restore stored values only.

# Phase 0 — Remaining decision closure

Status: `ACTIVE — BLOCKING IMPLEMENTATION`

## Objective

Remove remaining ambiguity before repository scaffolding.

## Required outputs

- accepted reward-eligible routine validation;
- accepted offline/local-draft boundary;
- accepted mobile release scope;
- accepted dashboard hosting;
- accepted production backup and operator-access plan;
- approved `TASK-IMP-001` packet.

## Verification

- anti-gaming scenario review;
- routine validation fixtures;
- workflow state-transition review;
- security and architecture review;
- documentation synchronization.

# Phase 1 — Repository and quality foundation

Status: `PLANNED`

## Planned task

`TASK-IMP-001 — Create Flutter and Supabase project foundation`

## Scope

- create mobile and dashboard Flutter applications;
- create shared Dart packages;
- initialize local Supabase configuration;
- add non-secret environment templates;
- add formatting, analysis, unit-test, database-test, and build commands;
- add CI for documentation, Flutter, and database checks;
- document local setup.

## Acceptance criteria

- both Flutter targets build placeholder shells;
- shared packages compile;
- local Supabase starts from committed configuration;
- CI passes from a clean checkout;
- no product feature is falsely claimed;
- no secrets are committed;
- architecture and codebase map match the created structure.

# Phase 2 — Identity, profiles, and ownership

Status: `PLANNED`

## Planned task

`TASK-IMP-002 — Implement provisioned-account authentication and RLS ownership`

## Scope

- Supabase Auth sign-in;
- disabled public signup;
- profiles linked to Auth users;
- unique username and display name;
- reward timezone and units;
- session handling in mobile and dashboard;
- RLS policies and tests;
- logout and expiry behavior.

## Acceptance criteria

- each provisioned user can sign in;
- invalid credentials fail without information leakage;
- cross-user access is denied;
- no password is stored in application tables;
- public clients use only publishable credentials;
- RLS allow and deny paths are tested.

# Phase 3 — Routine drafting and publication

Status: `PLANNED — BLOCKED BY ROUTINE ELIGIBILITY RULES`

## Planned task

`TASK-IMP-003 — Implement user-owned versioned routine management`

## Scope

- exercise and prescription model;
- dashboard routine editor;
- reward-eligibility validation;
- immutable published versions;
- future effective weeks;
- routine history and preview;
- publication audit.

## Acceptance criteria

- users edit only their own drafts;
- publishing creates a new immutable version;
- active and historical weeks remain unchanged;
- empty or trivial routines cannot become reward eligible;
- four-to-six-workout-day boundary is enforced;
- publication is covered by database and UI tests.

# Phase 4 — Weekly plans and normalized allocations

Status: `PLANNED`

## Planned task

`TASK-IMP-004 — Materialize weekly schedules and deterministic allocations`

## Scope

- Monday-Sunday boundaries;
- routine-version selection;
- seven dated plan items;
- `rank-v6` RR and base-XP allocation;
- 95 RR penalty allocation;
- monthly free-credit materialization;
- base and current schedule snapshots;
- lock state, idempotency, and timezone behavior.

## Acceptance criteria

- seven items materialize once;
- RR pools sum exactly to 110, 167, 220, or 277;
- base-XP allocations sum to 110;
- penalty allocations sum to 95;
- four-, five-, and six-day fixtures match canonical formulas;
- duplicate grants and weeks are impossible;
- later routine edits cannot alter materialized history.

# Phase 5 — Mobile workout execution

Status: `PLANNED`

## Planned task

`TASK-IMP-005 — Implement workout execution and logging`

## Scope

- home and weekly schedule;
- session-start locking;
- 60-minute timer and rest timers;
- load, reps, RIR, status, notes, and pain flags;
- local autosave and recovery;
- completion calculation;
- full, incomplete-logging, partial, invalid, protected, and correction states;
- server-returned provisional awards.

## Acceptance criteria

- interrupted entry can resume without lost sets;
- final submission is idempotent;
- duplicate submissions do not duplicate rewards;
- client manipulation cannot set RR or XP;
- time-cap behavior matches the product baseline;
- target-device accessibility and input behavior are tested.

# Phase 6 — Swaps, wallet, rank, and finalization

Status: `PLANNED`

## Planned task

`TASK-IMP-006 — Implement swaps and the complete rank ledger`

## Scope

- swap preview and warnings;
- credit-versus-RR payment;
- two-swap limit and locks;
- immutable swap records;
- daily awards and missed penalties;
- weekly two-PR cap;
- consistency, top-ups, bonuses, milestones, and decay;
- weekly finalization;
- rank snapshot and transaction history.

## Acceptance criteria

- transitions are atomic and idempotent;
- all supported routine frequencies have equal configured ceilings;
- swaps move item identity and allocations;
- a third swap is impossible;
- credits never become negative;
- finalization cannot duplicate transactions;
- reversals restore only stored original values;
- rank history is explainable from immutable transactions.

# Phase 7 — Progression, protection, and corrections

Status: `PLANNED`

## Planned task

`TASK-IMP-007 — Implement progression recommendations and auditable exceptions`

## Scope

- double-progression recommendations;
- acceptance and overrides;
- PR history;
- substitutions and pain flags;
- protected periods;
- backdated corrections;
- exact-value reversal;
- audit presentation.

## Acceptance criteria

- recommendations never mutate published routines automatically;
- pain handling never provides medical diagnosis;
- protected states follow accepted rules;
- backdated changes create visible audit events;
- corrected history remains internally consistent.

# Phase 8 — Release hardening

Status: `PLANNED`

## Planned task

`TASK-IMP-008 — Complete release verification and deployment`

## Scope

- end-to-end tests;
- RLS and authorization audit;
- migration and database-advisor review;
- performance and failure-state testing;
- backup and restore procedure;
- production configuration;
- dashboard deployment;
- mobile release packaging;
- operational runbook.

## Acceptance criteria

- clean production migration path;
- no exposed secret or service-role credential;
- advisor findings resolved or explicitly accepted;
- two-user end-to-end workflow passes;
- backup restoration is demonstrated;
- release artifacts match documented versions;
- context, handoff, and audit documents are synchronized.

## Testing strategy

### Dart and Flutter

- pure domain unit tests;
- repository and adapter tests;
- widget tests for critical screens;
- integration tests for sign-in, publication, execution, swaps, and finalization;
- accessibility tests for mobile and web.

### Supabase and Postgres

- empty-database migration verification;
- RLS allow and deny tests for both users;
- idempotency tests for grants, plans, completion, and finalization;
- transaction and concurrency tests;
- immutable-ledger and reversal tests;
- configuration-version tests;
- database-advisor review.

### Product balance

- deterministic four-, five-, and six-day fixtures;
- exact RR, XP, and penalty pool sums;
- completion-factor tests;
- multiplier top-up tests;
- weekly PR-cap tests;
- swap and free-credit tests;
- long-run synthetic calibration checks.

## First-sequence non-goals

- public signup;
- social authentication;
- coach or administrator editing another user's routine;
- nutrition, sleep, social, leaderboard, payment, or wearable features;
- generalized organizations;
- microservices;
- unnecessary realtime synchronization;
- historical recalculation using current formulas.

## Exact next action

Run:

`TASK-PL-002 — Close implementation constraints and authorize the foundation task`

It must define reward-eligible routine validation, offline/local-draft behavior, mobile release scope, dashboard hosting, Supabase backup and operator access, and the bounded `TASK-IMP-001` packet.

No scaffolding should begin before that task passes.