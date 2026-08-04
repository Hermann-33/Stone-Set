# Stone Set Implementation Plan

Updated: 2026-08-04
Status: `PLANNING BASELINE — IMPLEMENTATION NOT AUTHORIZED`
Task: `TASK-PL-001`

## Purpose

This document defines the planned implementation sequence for Stone Set after the remaining product decisions are accepted.

It is not an implementation task. No code, schema, Supabase project, credentials, package configuration, infrastructure, or deployment is created by this plan.

## Verified starting point

- Foundational single-routine product logic is accepted as `rank-v5` and `schedule-v2`.
- The repository contains documentation only.
- Flutter is selected for the mobile application.
- Flutter Web is selected for the internal routine-management dashboard.
- Supabase is selected for authentication and Postgres persistence.
- Two accounts will be provisioned initially.
- Public registration is excluded from MVP.
- The multi-user variable-routine and normalized daily-RR model remains proposed as `rank-v6` and `schedule-v3`.

## Implementation authorization gate

Implementation may begin only after all of the following are accepted:

1. `docs/product/APPLICATION_WORKFLOW.md` is promoted from proposed to accepted.
2. `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md` is audited and activated as `rank-v6` and `schedule-v3`.
3. `docs/product/RANK_SYSTEM.md` and `docs/product/WEEKLY_SCHEDULING.md` are synchronized to the accepted formulas.
4. Connectivity and local in-progress-workout persistence behavior are accepted.
5. Dashboard hosting and mobile release targets are decided.
6. The first implementation task packet is approved.

## Target architecture

```text
Flutter mobile app
  -> authenticated user execution and workout logging

Flutter Web dashboard
  -> user-owned routine drafting and publication

Shared Dart packages
  -> domain models, validation, repositories, Supabase adapters

Supabase Auth
  -> credentials, sessions, account identity

Supabase Postgres + Data API/RPC
  -> user-owned records, immutable ledgers, atomic transitions, RLS
```

The database is authoritative for persistent state and reward calculations. Clients may calculate previews but cannot authoritatively set RR, XP, rank, penalty, credit, or finalization values.

## Planned repository layout

```text
/apps/mobile/                 Flutter mobile application
/apps/dashboard/              Flutter Web dashboard
/packages/domain/             Pure domain models and validation
/packages/data/               Repository interfaces and Supabase adapters
/packages/ui/                 Shared design tokens and reusable widgets
/supabase/migrations/         Versioned database migrations
/supabase/seed.sql            Non-secret local development seed data
/supabase/tests/              Database and RLS verification
/docs/                        Product, architecture, decisions, plans, audits
```

The exact package names may change during the foundation task, but responsibility boundaries must remain equivalent.

## Planned data domains

### Identity

- `profiles`
- account settings and reward timezone
- authorization role metadata

### Routine management

- routine definitions
- immutable routine versions
- day prescriptions
- exercise prescriptions
- exercise catalog and user-defined variants
- substitutions and priority metadata

### Weekly planning

- weekly plans
- dated plan items
- daily reward allocations
- missed-penalty allocations
- swaps and schedule snapshots

### Workout execution

- workout sessions
- exercise instances
- working sets
- timers and completion state
- local-to-server synchronization identifiers

### Rank and rewards

- rank state
- lifetime XP
- daily awards
- PR awards
- perfect-week bonuses
- multiplier top-ups
- streak milestones
- penalties and decay
- immutable rank transactions

### Free-swap wallet

- wallet snapshot
- monthly grants
- consumptions
- swap payments
- reversals

### Protection and audit

- protected periods
- correction events
- routine publication audit
- immutable weekly evaluations
- configuration versions

## Planned security model

1. Supabase Auth manages passwords and sessions.
2. Public self-registration is disabled.
3. Two initial accounts are provisioned administratively.
4. `profiles.id` references `auth.users.id`.
5. Every exposed user-owned table has RLS enabled.
6. Policies require authenticated ownership checks.
7. Users can read and edit only their own permitted rows.
8. Published routine versions and finalized ledger entries are immutable through ordinary client CRUD.
9. Sensitive multi-table transitions run atomically through narrowly scoped database operations.
10. No public client contains a service-role or secret key.
11. Authorization data is not trusted from user-editable metadata.
12. The client never supplies an authoritative reward amount.
13. Correction operations create audit records and restore stored values only.

## Phase 0 — Decision closure

Status: `BLOCKING`

### Objective

Close the product and operational decisions that still make implementation ambiguous.

### Required outputs

- accepted `rank-v6` and `schedule-v3`, or explicit rejection of the proposal;
- accepted workflow baseline;
- accepted offline and synchronization boundary;
- accepted dashboard hosting target;
- accepted Android/iOS release scope;
- accepted first implementation task.

### Verification

- cross-routine RR calibration;
- anti-gaming review;
- workflow state-transition review;
- architecture and security review;
- context synchronization.

## Phase 1 — Repository and quality foundation

Status: `PLANNED`

### Objective

Create the minimum executable repository structure and automated quality gates without implementing product features.

### Planned task

`TASK-IMP-001 — Create Flutter and Supabase project foundation`

### Scope

- create mobile and dashboard Flutter applications;
- create shared Dart packages;
- initialize Supabase local-development configuration;
- establish environment configuration templates without secrets;
- add formatting, analysis, unit-test, database-test, and build commands;
- add CI for documentation checks, Flutter checks, and database verification;
- document local setup.

### Acceptance criteria

- both Flutter targets build placeholder shells;
- shared packages compile;
- local Supabase starts from committed configuration;
- no product behavior is falsely claimed;
- CI passes from a clean checkout;
- secrets are absent;
- architecture and codebase-map documents match the created structure.

## Phase 2 — Identity, profiles, and ownership

Status: `PLANNED`

### Planned task

`TASK-IMP-002 — Implement provisioned-account authentication and RLS ownership`

### Scope

- Supabase Auth email/password sign-in;
- disabled public signup;
- profile creation linked to Auth users;
- unique username and display name;
- reward timezone;
- session handling in mobile and dashboard;
- RLS policies and tests;
- logout and expired-session behavior.

### Acceptance criteria

- each provisioned user can sign in;
- invalid credentials fail without information leakage;
- one user cannot read or mutate another user's rows;
- no password is stored in application tables;
- public clients use only publishable credentials;
- RLS tests cover select, insert, update, and delete paths.

## Phase 3 — Routine drafting, validation, and publication

Status: `PLANNED`

### Planned task

`TASK-IMP-003 — Implement user-owned versioned routine management`

### Scope

- exercise and prescription data model;
- dashboard routine list and editor;
- draft validation;
- immutable published versions;
- effective-week scheduling;
- routine history;
- future-week preview;
- publication audit.

### Acceptance criteria

- users can edit only their own drafts;
- publishing creates a new immutable version;
- active and historical weeks are unchanged;
- invalid or trivial reward-eligible routines are blocked;
- the supported workout-frequency boundary is enforced;
- publication is covered by database and UI tests.

## Phase 4 — Weekly plans and normalized allocation

Status: `PLANNED — BLOCKED BY RANK-V6/SCHEDULE-V3`

### Planned task

`TASK-IMP-004 — Materialize weekly schedules and deterministic reward allocations`

### Scope

- Monday-Sunday week boundaries;
- routine-version selection;
- seven dated plan items;
- daily RR allocation using stored configuration;
- missed-penalty allocation;
- monthly free-credit grant materialization;
- immutable base schedule;
- current schedule and lock state;
- idempotency and timezone handling.

### Acceptance criteria

- all seven items materialize once;
- allocations sum exactly to the configured weekly pools;
- four-, five-, and six-day examples match the accepted formula;
- duplicate monthly grants are impossible;
- timezone changes cannot duplicate grants or weeks;
- later routine edits cannot modify materialized allocations.

## Phase 5 — Mobile workout execution and logging

Status: `PLANNED`

### Planned task

`TASK-IMP-005 — Implement the complete workout execution flow`

### Scope

- today and weekly schedule UI;
- start-session locking;
- 60-minute session timer;
- rest timers;
- set entry for load, repetitions, RIR, completion, and notes;
- autosaved local in-progress draft;
- connection recovery;
- completion calculation;
- full, partial, invalid, protected, and pending-correction states;
- server-returned provisional award display.

### Acceptance criteria

- an interrupted app session can resume without losing entered sets;
- final submission is idempotent;
- duplicate set or session submissions do not duplicate rewards;
- client manipulation cannot set RR;
- time-cap and low-priority-set behavior match the product baseline;
- accessibility and keyboard/input behavior are tested on target devices.

## Phase 6 — Swaps, wallet, rank, and weekly finalization

Status: `PLANNED — BLOCKED BY RANK-V6/SCHEDULE-V3`

### Planned task

`TASK-IMP-006 — Implement schedule swaps and the complete rank ledger`

### Scope

- swap preview and warnings;
- free-credit versus RR payment selection;
- two-swap limit and day locking;
- immutable swap records;
- daily awards and missed penalties;
- PR validation and weekly cap;
- consistency reset and milestone top-ups;
- perfect-week bonus and streak milestones;
- failed-week decay;
- weekly finalization;
- rank snapshot and transaction history.

### Acceptance criteria

- all transitions are atomic and idempotent;
- four-, five-, and six-day users have identical configured weekly ceilings;
- a swap moves item identity and stored allocations;
- a third weekly swap is impossible;
- credits never become negative;
- finalization cannot duplicate any transaction;
- reversals restore only the original stored instrument or amount;
- rank history remains explainable from immutable transactions.

## Phase 7 — Progression, protection, and correction workflow

Status: `PLANNED`

### Planned task

`TASK-IMP-007 — Implement progression recommendations and auditable exceptions`

### Scope

- double-progression recommendations;
- user acceptance and override;
- exercise-variant PR history;
- pain and substitution flags;
- protected periods;
- backdated correction requests;
- exact-value reversal;
- audit presentation.

### Acceptance criteria

- recommendations never mutate published routines automatically;
- pain handling does not provide medical diagnosis;
- protected states apply only under accepted rules;
- backdated changes create visible audit events;
- corrected history remains internally consistent.

## Phase 8 — Release hardening

Status: `PLANNED`

### Planned task

`TASK-IMP-008 — Complete release verification and deployment`

### Scope

- full end-to-end tests;
- RLS and authorization audit;
- database advisors and migration review;
- performance and failure-state testing;
- backup and restore procedure;
- production environment configuration;
- dashboard deployment;
- mobile release packaging;
- operational runbook.

### Acceptance criteria

- clean production migration path;
- no exposed secret or service-role credential;
- all security and database advisor findings resolved or explicitly accepted;
- two-user end-to-end workflow passes;
- backup restoration is demonstrated;
- release artifacts match the documented versions;
- final context, handoff, and audit documents are synchronized.

## Testing strategy

### Dart and Flutter

- pure unit tests for domain rules;
- repository and adapter tests;
- widget tests for critical screens;
- integration tests for sign-in, routine publication, workout execution, swaps, and finalization;
- golden tests only where visual stability provides value;
- accessibility checks for mobile and web.

### Postgres and Supabase

- migration verification from an empty database;
- RLS allow and deny tests for both users;
- idempotency tests for grants, plan materialization, session completion, and weekly finalization;
- transaction and concurrency tests;
- immutable-ledger and reversal tests;
- configuration-version tests;
- database advisor review.

### Balance and product logic

- deterministic fixtures for four-, five-, and six-day routines;
- exact weekly-pool sum tests;
- missed-penalty pool tests;
- multiplier milestone top-up tests;
- PR weekly-cap tests;
- swap and free-credit tests;
- long-run synthetic calibration tests.

## Non-goals for the first implementation sequence

- public signup;
- social authentication;
- coach or administrator editing another user's routine;
- nutrition, sleep, social, leaderboard, or payment features;
- wearable integrations;
- generalized multi-tenant organizations;
- analytics-heavy infrastructure;
- microservices;
- realtime synchronization where ordinary refresh is sufficient;
- historical recalculation from current formulas.

## Exact next action

Run a dedicated product-balance task for `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md`.

That task must either:

- accept and activate `rank-v6` and `schedule-v3` with synchronized canonical product documents; or
- reject the proposal and replace it with a different mathematically verified fairness model.

No scaffolding task should begin before that gate passes.
