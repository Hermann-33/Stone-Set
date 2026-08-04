# Stone Set Roadmap

Updated: 2026-08-04

## Completion rule

A phase is complete only when every applicable product, UI, application, persistence, security, testing, documentation, and Git track is implemented or conclusively closed for that phase.

## Phase 0 — Product discovery, architecture, and implementation planning

Status: `ACTIVE`

### Goal

Produce a precise, secure, testable implementation baseline before generating code or external infrastructure.

### Foundational single-routine logic milestone

Status: `COMPLETE`

Closed:

- initial evidence-informed five-session routine;
- 60-minute cap;
- rank ladder and consistency behavior;
- missed penalties and failed-week decay;
- weekly swaps and monthly free-swap credits.

### Multi-user architecture milestone

Status: `COMPLETE`

Closed:

- Flutter mobile client;
- Flutter Web dashboard;
- shared Dart packages;
- Supabase Auth and Postgres;
- RLS isolation;
- server-authoritative rank and wallet transitions;
- two provisioned initial accounts;
- no application-table password storage.

### Multi-user normalized product milestone

Status: `COMPLETE`
Task: `TASK-PD-008`

Closed:

- accepted `rank-v6`;
- accepted `schedule-v3`;
- accepted end-to-end application workflow;
- user-owned immutable routine versions;
- future-week routine activation;
- four-to-six workout days per supported routine;
- seven plan items per week;
- equal maximum weekly RR opportunity;
- weekly RR pools of 110, 167, 220, and 277;
- workout/rest weights of 4:1;
- weekly base-XP item pool of 110;
- lower automatic programmed-rest awards;
- 95 RR weekly missed-workout penalty pool;
- maximum two rewarded PRs per week;
- failed-week threshold below 60% workout completion;
- accepted 1.46-week maximum synthetic mean variance;
- preserved Adonis at `5,500 RR`;
- preserved 5/10/15 multiplier ladder;
- preserved two weekly swaps and monthly bankable free credits.

### Remaining required outcomes

- concrete reward-eligible routine validation and anti-triviality rules;
- local in-progress-workout persistence behavior;
- offline submission and server-finalization behavior;
- Android/iOS release scope;
- dashboard hosting target;
- production Supabase backup and restore expectations;
- production operator-access boundary;
- bounded `TASK-IMP-001` packet.

### Completion criteria

Phase 0 completes only when all remaining outcomes are accepted, synchronized, and no material ambiguity blocks foundation implementation.

## Phase 1 — Repository and quality foundation

Status: `BLOCKED BY PHASE 0`

Expected first task:

`TASK-IMP-001 — Create Flutter and Supabase project foundation`

Expected scope:

- Flutter mobile and dashboard shells;
- shared Dart packages;
- local Supabase configuration;
- environment templates without secrets;
- formatting, analysis, tests, builds, and CI;
- local setup documentation.

Phase 1 is not started and is not complete.

## Phase 2 — Identity and ownership

Status: `PLANNED`

Expected outcome:

- provisioned Supabase Auth sign-in;
- profiles;
- reward timezone;
- RLS ownership;
- cross-user denial tests;
- session and logout behavior.

## Phase 3 — Routine management

Status: `PLANNED`

Expected outcome:

- user-owned drafts;
- concrete reward-eligibility validation;
- immutable publication;
- future effective weeks;
- routine history and audit.

## Phase 4 — Weekly planning and allocations

Status: `PLANNED`

Expected outcome:

- seven materialized plan items;
- deterministic `rank-v6` RR and XP allocations;
- 95 RR penalty allocations;
- monthly grants;
- schedule snapshots and locks;
- timezone and idempotency tests.

## Phase 5 — Workout execution

Status: `PLANNED`

Expected outcome:

- session and rest timers;
- set logging;
- local draft recovery;
- completion resolution;
- protected and correction states;
- server-returned provisional awards.

## Phase 6 — Swaps, wallet, rank, and finalization

Status: `PLANNED`

Expected outcome:

- swap preview and payment;
- wallet ledger;
- daily awards and penalties;
- weekly PR cap;
- consistency and top-ups;
- milestones and failed-week decay;
- idempotent weekly finalization;
- transparent rank history.

## Phase 7 — Progression and exceptions

Status: `PLANNED`

Expected outcome:

- double-progression recommendations;
- user overrides;
- substitutions and pain flags;
- protected periods;
- exact-value corrections and audit history.

## Phase 8 — Release hardening

Status: `PLANNED`

Expected outcome:

- end-to-end verification;
- RLS and security audit;
- migration and database-advisor review;
- performance and failure-state checks;
- backup restoration;
- dashboard deployment;
- mobile release packaging;
- operational runbook.

## Current position

`Phase 0 — Product discovery, architecture, and implementation planning`

Current workstream:

`TASK-PL-002 — Close implementation constraints and authorize the foundation task`

## Reopening rule

A completed milestone or baseline must reopen when later evidence invalidates its requirements, calculations, security assumptions, or completion evidence.