# Stone Set Active Context

Updated: 2026-08-04

## Current state

Stone Set is a private two-user muscle-growth training system with accepted product, architecture, operational, and implementation-planning baselines.

The repository remains documentation-only. There is no Flutter project, Supabase project, schema, account, Vercel project, deployment, CI workflow, or runtime.

## Active phase

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

`TASK-PL-002` closed the remaining implementation constraints and approved the bounded foundation packet at `docs/tasks/TASK-IMP-001.md`.

## Accepted product baseline

- Initial provisioned users: 2; account count not hardcoded.
- Public registration excluded from MVP.
- User-owned draft routines and immutable published versions.
- Independent review required before a routine becomes reward eligible.
- `routine-validator-v1` defines hard structural limits and review evidence.
- Supported routines: 4–6 workout days, 1–3 rest days, 7 total plan items.
- Active rank configuration: `rank-v6`.
- Active scheduling configuration: `schedule-v3`.
- Highest rank: Adonis at `5,500 RR`.
- Weekly daily-item RR pools: 110, 167, 220, and 277.
- Workout/rest allocation weight: 4:1.
- Weekly ordinary base-XP item pool: 110.
- Weekly missed-workout penalty pool: 95 RR.
- Maximum rewarded PRs: 2 per week.
- Failed week: unprotected workout-completion ratio below 60%.
- Consistency multipliers: 1.00x, 1.50x, 2.00x, and 2.50x at Weeks 0, 5, 10, and 15.
- Maximum swaps: 2 per week.
- Monthly free-swap grant: 2 non-expiring, uncapped credits.
- Unscheduled extra workouts and sets earn no RR or XP.

## Accepted architecture

### Clients

- Flutter Android mobile application.
- Separate Flutter Web management dashboard.
- Shared Dart packages in a native Pub workspace.
- Initial mobile target: Android API 24+ only.
- iOS deferred until a real user need, macOS/Xcode environment, signing, and tests are accepted.

### Backend and authorization

- Supabase Auth manages credentials and sessions.
- Supabase Postgres is authoritative for persistent product state.
- RLS isolates user-owned rows.
- Server operations authoritatively perform routine publication, schedule materialization, swaps, rewards, penalties, wallet changes, and finalization.
- Clients never contain service-role or database secrets and never set authoritative scores.

### Local and offline behavior

- Mobile local drafts use SQLite through `sqflite`.
- Starting a workout requires connectivity so the server can validate and lock the item.
- A server-started workout may continue offline with transactional autosave and an idempotent outbox.
- Finishing offline creates `pending_submission`; no RR or XP is committed until server validation succeeds.
- Started sessions receive a 24-hour post-week synchronization grace.
- Logout with unsynchronized data requires sync, cancellation, or explicit discard.

### Hosting and operations

- Flutter Web dashboard target: Vercel static deployment.
- GitHub Actions will build and test an exact artifact before preview and production promotion.
- Preview deployments connect to staging, never production.
- Environments: local, hosted staging, hosted production.
- Production Supabase target: Pro with managed daily backups and seven-day retention.
- Independent encrypted weekly logical exports are retained as 12 weekly and 12 month-end copies.
- Recovery targets: RPO 24 hours; RTO 4 hours for the expected small dataset.
- Restore drill required before release and quarterly afterward.
- Two distinct Supabase Owner accounts, MFA enforcement, backup factors, and least-privileged collaborators.

## Accepted decisions

- ADR-0001: Flutter mobile and Flutter Web clients.
- ADR-0002: Supabase backend, Auth, Postgres, and RLS.
- ADR-0003: SQLite drafts and online authoritative finalization.
- ADR-0004: Android-first release and Vercel dashboard hosting.
- ADR-0005: Supabase production operations and recovery.

## Implemented versus documented

### Documented and accepted

Product rules, workflow, architecture, security, offline behavior, release targets, operations, phased plan, and the first implementation packet.

### Implemented

Only repository documentation and Git history.

## Exact next action

Execute:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
branch: codex/task-imp-001-foundation
packet: docs/tasks/TASK-IMP-001.md
```

The task creates scaffolding, local Supabase configuration, tests, builds, and CI only.

## Do-not-touch boundaries

- Do not claim Phase 1 has started until the task branch contains implementation work.
- Do not create remote Supabase or Vercel infrastructure in `TASK-IMP-001`.
- Do not add real keys, accounts, project references, signing secrets, or personal data.
- Do not implement authentication, product schema, routines, workouts, SQLite drafts, rank, wallet, or deployment in the foundation task.
- Do not change `rank-v6`, `schedule-v3`, Adonis at `5,500 RR`, the 5/10/15 multiplier ladder, swap limit, or bankable credits.
- Do not store passwords in application tables or expose privileged credentials to clients.
