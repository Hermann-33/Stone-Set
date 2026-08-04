# Stone Set Implementation Plan

Updated: 2026-08-04
Status: `IMPLEMENTATION AUTHORIZED FOR APPROVED PACKETS ONLY`
Task: `TASK-PL-002`

## Starting point

Phase 0 is complete. Product, workflow, architecture, security, local persistence, release, hosting, backup, and operator-access decisions are accepted.

The repository still contains no application code or external infrastructure.

## Authorization rule

Implementation proceeds only through approved packets in `docs/tasks/`.

Current approved packet:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
```

Its approval does not authorize product features or external project creation.

## Target architecture

```text
Android Flutter app
  -> online start
  -> SQLite draft/outbox
  -> online authoritative finalization

Flutter Web dashboard
  -> reviewed routine management
  -> static Vercel deployment

Native Pub workspace
  -> domain, data, and UI packages

Supabase Auth + Postgres + RLS
  -> private state and atomic transitions
```

## Phase 1 — Repository and quality foundation

Status: `READY — NOT STARTED`
Packet: `docs/tasks/TASK-IMP-001.md`

Scope:

- pin Flutter and tooling;
- create Android-only mobile shell;
- create web-only dashboard shell;
- create shared native Pub workspace packages;
- initialize local Supabase configuration only;
- add non-secret configuration templates;
- add formatting, analysis, tests, Android/Web builds, database tests, lint, and CI;
- document local setup and actual repository structure.

Exit criteria are defined in the packet. No authentication, product schema, SQLite feature, routine, workout, rank, wallet, remote project, or deployment belongs in Phase 1.

## Phase 2 — Identity and ownership

Planned packet: `TASK-IMP-002`

- administratively provisioned Supabase Auth accounts;
- profiles, usernames, units, and reward timezone;
- mobile and dashboard sessions;
- RLS ownership policies and allow/deny tests;
- logout and private-cache cleanup.

## Phase 3 — Reviewed routine management

Planned packet: `TASK-IMP-003`

- routine schema and drafts;
- hard server validator `routine-validator-v1`;
- submission content hashes;
- independent review and self-approval prevention;
- immutable publication, future activation, rejection, and audit history.

## Phase 4 — Weekly plans and normalized allocations

Planned packet: `TASK-IMP-004`

- routine-version selection;
- seven dated plan items;
- `rank-v6` RR and base-XP allocation;
- 95 RR penalty allocation;
- monthly grants;
- immutable schedule snapshots, locks, timezones, and idempotency.

## Phase 5 — Android workout execution

Planned packet: `TASK-IMP-005`

- home and weekly schedule;
- online session start and lock;
- timers and set entry;
- SQLite active draft and outbox;
- offline continuation;
- pending submission and 24-hour grace;
- server validation and authoritative provisional result.

## Phase 6 — Swaps, wallet, rank, and finalization

Planned packet: `TASK-IMP-006`

- swap preview and payment choice;
- wallet ledger;
- daily awards, missed penalties, and weekly PR cap;
- consistency, top-ups, bonuses, milestones, and decay;
- idempotent weekly finalization and transaction history.

## Phase 7 — Progression, protection, and corrections

Planned packet: `TASK-IMP-007`

- double-progression recommendations;
- user overrides;
- substitution and pain flags without diagnosis;
- protected periods;
- exact-value backdated corrections and audit presentation.

## Phase 8 — Release hardening

Planned packet: `TASK-IMP-008`

- full end-to-end tests;
- RLS, privilege, advisor, and migration audit;
- staging and production setup;
- Supabase Pro backups and encrypted logical export automation;
- demonstrated restore drill;
- Vercel preview and production deployment;
- signed Android APK/private release;
- operational runbook and final context sync.

## Cross-cutting testing strategy

### Dart and Flutter

- pure domain tests;
- repository and adapter tests;
- widget and integration tests;
- Android device behavior;
- web keyboard, focus, semantics, and SPA routing;
- local database migration and recovery tests.

### Supabase and Postgres

- clean migration rebuild;
- RLS allow and deny fixtures;
- function privilege tests;
- transaction and concurrency tests;
- idempotency and immutable-ledger tests;
- database lint and advisors.

### Product integrity

- 4-, 5-, and 6-day allocation fixtures;
- routine eligibility and self-approval rejection;
- content-hash and publication tests;
- PR, swap, consistency, penalty, and correction tests;
- long-run rank calibration checks.

### Operations

- staging isolation;
- no secrets in artifacts;
- backup encryption and retention;
- restore drill evidence;
- release artifact traceability and rollback.

## Exact next action

Execute `docs/tasks/TASK-IMP-001.md` on branch `codex/task-imp-001-foundation`.
