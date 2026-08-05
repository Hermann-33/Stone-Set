# TASK-PD-013 — Final implementation-readiness audit and system plan

Status: `COMPLETE`
Approved by: user request on 2026-08-05
Type: architecture, data and implementation planning only

## Objective

Perform a final research-backed audit of the complete Stone Set Android application, Flutter Web dashboard and Supabase backend before implementation begins. Close any missing architecture, database, synchronization, security, operations or lifecycle decisions and synchronize the implementation plan.

## Mandatory inputs reviewed

- accepted ADRs;
- active context, architecture, roadmap, implementation plan and handoff;
- authentication/session UX;
- complete UI/UX system and UI implementation plan;
- application workflow;
- routine eligibility;
- exercise guidance/media;
- weekly scheduling;
- rank system;
- existing implementation packets;
- current official Flutter, Riverpod, go_router, Supabase, Vercel, Android, W3C and OWASP guidance.

## Starting findings

Already complete:

- product rules and rank/schedule economy;
- Android and dashboard information architecture;
- authentication/session behavior;
- media/YouTube policy;
- offline workout workflow;
- deployment and backup targets;
- phased UI plan.

Material gap:

- no single implementation-grade database/server plan;
- no locked state-management/routing baseline;
- no canonical synchronization, concurrency, cron, compatibility, observability, export and account-lifecycle plan;
- `TASK-IMP-002A` was referenced but did not exist as a packet;
- `TASK-IMP-002B` still used the obsolete `History` destination label.

## Accepted decisions

### Client architecture

- Flutter/Dart for Android and dashboard;
- Flutter-recommended views/view-models, repositories and services;
- Riverpod as the single application state/DI framework;
- go_router typed routes and stateful shells;
- immutable models and explicit DTO/domain mapping;
- no direct Supabase/SQLite access from widgets.

### Persistence and synchronization

- Supabase Postgres remains authoritative;
- SQLite/sqflite stores Android active drafts, snapshots and outbox;
- dashboard uses an IndexedDB-backed recovery cache, not full offline publication;
- idempotency keys, payload versions and sequence numbers are mandatory;
- WorkManager provides best-effort constrained retry only;
- no continuous polling or Supabase Realtime in MVP.

### Server architecture

- RLS-protected client reads;
- atomic authority-changing workflows through narrowly granted Postgres functions;
- security invoker by default;
- hardened security definer only where required;
- append-only RR/XP/wallet/audit ledgers;
- immutable published/materialized/finalized history;
- optimistic concurrency for drafts;
- unique constraints and row locks for idempotency/concurrency.

### Scheduled operations

Supabase Cron/pg_cron owns idempotent:

- week materialization;
- monthly credit grants;
- rest resolution;
- grace expiry;
- weekly finalization;
- bounded cleanup.

Every scheduled operation has an application-triggered catch-up path and observable run history.

### Web and Android platform decisions

- standard Flutter Web build is the production baseline;
- WebAssembly is evaluated later because COOP/COEP and cross-origin integrations require verification;
- Vercel uses SPA rewrites, security headers, preview protection and deliberate cache rules;
- contextual notification permission only;
- no exact-alarm permission;
- internal Android storage for local product data.

### Security and quality

- ASVS 5.0 and MASVS are verification catalogues;
- WCAG 2.2 AA-equivalent dashboard accessibility;
- no analytics/crash SDK until privacy/retention/cost decision;
- structured redacted logs and correlation IDs;
- migrations and pgTAP tests in CI;
- compatibility/read-only controls for rolling client/database changes.

### Data lifecycle

- user-owned CSV/JSON export;
- operator-managed deactivation and hard-delete runbook;
- Storage objects deleted through Storage API;
- historical records corrected by append-only reversals;
- database and Storage backup reconciliation remains mandatory.

## New canonical documents

- `docs/context/TECHNOLOGY_BASELINE.md`
- `docs/context/DATABASE_AND_SERVER_PLAN.md`
- `docs/context/SYSTEM_IMPLEMENTATION_READINESS_AUDIT.md`
- `docs/tasks/TASK-IMP-002A.md`
- `docs/tasks/TASK-PD-013.md`

## Required synchronization

- amend `TASK-IMP-002B` to Home/Week/Progress/Profile and selected architecture;
- align `TASK-IMP-002C` with shared state/routing/data boundaries;
- update active context, codebase map, roadmap, implementation plan, UI implementation plan and handoff;
- append audit history;
- update Pull Request #2 summary.

## Protected boundaries

- no Flutter or Supabase product implementation;
- no external project or credentials;
- no rank-v6 or schedule-v3 change;
- no weakening of server authority, RLS, immutable history or review independence;
- no claim that Phase 1 has started;
- `TASK-IMP-001` remains the exact next implementation action.

## Verification

- Android app, dashboard, backend and operations each have explicit ownership and phase mapping;
- all authoritative domains have planned relational entities and operations;
- every retryable mutation has an idempotency/concurrency approach;
- scheduled work has both cron and catch-up paths;
- local drafts, session expiry, logout and conflicts are covered;
- Storage, backups, export and account lifecycle are covered;
- UI, database, security, accessibility and recovery tests are planned;
- deliberate exclusions are documented;
- no application code or infrastructure is introduced.

## Verdict

`COMPLETE`

Stone Set has an implementation-ready system plan. After the planning pull request is merged, begin `TASK-IMP-001` without reopening general discovery unless product scope or platform evidence materially changes.
