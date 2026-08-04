# Stone Set Active Context

Updated: 2026-08-04

## Current state

Stone Set is a private two-user muscle-growth training system with accepted product, architecture, media, operational, and implementation-planning baselines.

The repository remains documentation-only. There is no Flutter project, Supabase project, schema, Storage bucket, account, Vercel project, deployment, CI workflow, or runtime.

## Active phase

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

`TASK-PD-009` extended the accepted product plan with workout explanations, exercise guidance, product-hosted images, and YouTube demonstrations without changing the approved foundation scope.

## Accepted product baseline

- Initial provisioned users: 2; account count not hardcoded.
- Public registration excluded from MVP.
- User-owned draft routines and immutable published versions.
- Independent review required before a routine becomes reward eligible.
- `routine-validator-v1` defines hard structural limits and review evidence.
- Supported routines: 4–6 workout days, 1–3 rest days, 7 total plan items.
- Dashboard-managed workout-day summaries and user-owned exercise guidance.
- Published guidance revisions are immutable and pinned to materialized weeks.
- Guidance contains explanation, muscles, instructions, ordered images, and one optional YouTube video.
- Viewing guidance never awards RR or XP and is never required for completion.
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

### Exercise guidance and media

- The dashboard is the primary routine and exercise-content management surface.
- Exercise guidance is user-owned and versioned separately from reward-bearing prescriptions.
- Private exercise images are stored in Supabase Storage, not the Vercel static build.
- Images are immutable, owner-scoped, MIME-restricted, size-limited, metadata-stripped, and protected by Storage RLS.
- The app uses the official YouTube IFrame Player API in an OS-provided Android WebView.
- YouTube playback is user-initiated, online-only, and never downloaded, cached, background-played, or rewarded.
- Workout-start snapshots include pinned guidance identifiers, text, image references, and normalized YouTube references.
- Guidance text and successfully prefetched images remain available for the active offline session.

### Backend and authorization

- Supabase Auth manages credentials and sessions.
- Supabase Postgres is authoritative for persistent product state and media metadata.
- Supabase Storage is authoritative for exercise image bytes.
- RLS isolates user-owned database rows and Storage objects.
- Server operations authoritatively perform routine publication, schedule materialization, swaps, rewards, penalties, wallet changes, and finalization.
- Clients never contain service-role or database secrets and never set authoritative scores.

### Local and offline behavior

- Mobile local drafts use SQLite through `sqflite`.
- Starting a workout requires connectivity so the server can validate and lock the item.
- A server-started workout may continue offline with transactional autosave and an idempotent outbox.
- Finishing offline creates `pending_submission`; no RR or XP is committed until server validation succeeds.
- Started sessions receive a 24-hour post-week synchronization grace.
- Logout with unsynchronized data requires sync, cancellation, or explicit discard.
- Cached private guidance media is removed under account logout and cache-cleanup rules.

### Hosting and operations

- Flutter Web dashboard target: Vercel static deployment.
- GitHub Actions will build and test an exact artifact before preview and production promotion.
- Preview deployments connect to staging data and staging media, never production.
- Environments: local, hosted staging, hosted production.
- Production Supabase target: Pro with managed daily database backups and seven-day retention.
- Independent encrypted weekly logical database exports and Storage object exports are retained as 12 weekly and 12 month-end copies.
- Recovery targets: RPO 24 hours; RTO 4 hours for the expected small dataset.
- Restore drills must reconcile database media metadata with the restored Storage object manifest.
- Two distinct Supabase Owner accounts, MFA enforcement, backup factors, and least-privileged collaborators.

## Accepted decisions

- ADR-0001: Flutter mobile and Flutter Web clients.
- ADR-0002: Supabase backend, Auth, Postgres, and RLS.
- ADR-0003: SQLite drafts and online authoritative finalization.
- ADR-0004: Android-first release and Vercel dashboard hosting.
- ADR-0005: Supabase production operations and recovery.
- ADR-0006: private exercise-media Storage and YouTube embedding.

## Implemented versus documented

### Documented and accepted

Product rules, workout and exercise guidance, media ownership, workflow, architecture, security, offline behavior, release targets, operations, phased plan, and the first implementation packet.

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
- Do not create remote Supabase, Storage, or Vercel infrastructure in `TASK-IMP-001`.
- Do not add real keys, accounts, project references, signing secrets, media, or personal data.
- Do not implement authentication, product schema, routine management, exercise media, YouTube playback, workouts, SQLite drafts, rank, wallet, or deployment in the foundation task.
- Do not change `rank-v6`, `schedule-v3`, Adonis at `5,500 RR`, the 5/10/15 multiplier ladder, swap limit, or bankable credits.
- Do not store passwords in application tables or expose privileged credentials to clients.
