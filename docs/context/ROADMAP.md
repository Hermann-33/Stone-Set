# Stone Set Roadmap

Updated: 2026-08-04

## Completion rule

A phase is complete only when every applicable product, architecture, security, operations, testing, documentation, and Git gate is implemented or conclusively closed for that phase.

## Phase 0 — Product discovery, architecture, and implementation planning

Status: `COMPLETE`
Completed by: `TASK-PL-002`

Closed outcomes:

- evidence-informed initial hypertrophy routine and 60-minute cap;
- `rank-v6`, `schedule-v3`, and normalized multi-user fairness;
- swaps, free-credit wallet, penalties, PRs, consistency, and finalization;
- reviewed reward-eligible routine rules through `routine-validator-v1`;
- accepted end-to-end workflow;
- Flutter Android mobile and Flutter Web dashboard architecture;
- Supabase Auth/Postgres/RLS and server authority;
- SQLite local drafts, online start, offline continuation, and online finalization;
- Android-first release and Vercel dashboard target;
- local, staging, and production environment model;
- backup, restore, access, and operational controls;
- approved bounded foundation packet.

No application code or external infrastructure was created during Phase 0.

## Phase 1 — Repository and quality foundation

Status: `READY — NOT STARTED`

Approved packet:

```text
docs/tasks/TASK-IMP-001.md
```

Goal:

- Android Flutter shell;
- Flutter Web dashboard shell;
- shared native Pub workspace packages;
- local Supabase configuration;
- non-secret configuration templates;
- formatting, analysis, tests, Android/Web builds, database checks, and CI;
- accurate implemented-state documentation.

Phase 1 excludes authentication, product schema, routines, workouts, rank behavior, SQLite feature implementation, remote projects, credentials, and deployment.

## Phase 2 — Identity and ownership

Status: `PLANNED`

- provisioned Supabase Auth sign-in;
- profiles, units, and reward timezone;
- RLS ownership and cross-user denial tests;
- session, logout, and cache cleanup behavior.

## Phase 3 — Reviewed routine management

Status: `PLANNED`

- draft editor;
- `routine-validator-v1`;
- submission, independent review, rejection, approval hash, and audit;
- immutable publication and future activation;
- routine history.

## Phase 4 — Weekly planning and allocations

Status: `PLANNED`

- seven materialized plan items;
- deterministic RR, XP, and penalty allocations;
- monthly grants;
- schedule snapshots, locks, swaps, timezone, and idempotency.

## Phase 5 — Android workout execution

Status: `PLANNED`

- online session start;
- timers and set logging;
- SQLite active draft and outbox;
- offline continuation and pending submission;
- server completion validation and provisional result presentation.

## Phase 6 — Rank, wallet, and finalization

Status: `PLANNED`

- daily awards and penalties;
- weekly PR cap;
- consistency, top-ups, milestones, and decay;
- swaps and wallet ledger;
- idempotent weekly finalization and transparent history.

## Phase 7 — Progression and exceptions

Status: `PLANNED`

- double-progression recommendations and overrides;
- substitutions and pain flags;
- protected periods;
- exact-value corrections and audit history.

## Phase 8 — Release hardening

Status: `PLANNED`

- end-to-end and security verification;
- database advisors and migration review;
- restore drill;
- staging and production setup;
- Vercel preview/production deployment;
- signed Android release;
- operational runbook.

## Current position

```text
Phase 0 complete
Phase 1 ready, not started
```

## Exact next action

Execute `TASK-IMP-001` on branch `codex/task-imp-001-foundation`.

## Reopening rule

A completed decision or phase reopens only when later evidence invalidates its requirements, security assumptions, operations, or completion evidence.
