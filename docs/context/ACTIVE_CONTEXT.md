# Stone Set Active Context

Updated: 2026-08-05

## Current state

Stone Set is a private multi-user hypertrophy training system with complete accepted MVP planning for:

- Android Flutter application;
- Flutter Web management dashboard;
- Supabase Auth/Postgres/Storage backend;
- offline workout drafts and synchronization;
- routine/guidance/media authoring and independent review;
- weekly scheduling, swaps and grants;
- rank, XP, wallet, finalization and corrections;
- deployment, security, accessibility, observability and recovery.

Implemented repository content:

- accepted specifications/ADRs/task packets;
- 20 rank-v6 emblem assets and generator/manifest;
- no Flutter runtime, product schema, remote Supabase/Vercel project or CI foundation yet.

## Phase

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

Latest planning task:

```text
TASK-PD-013 — Final implementation-readiness audit and system plan
```

The readiness audit found and closed the final material planning gap: the repository now contains a canonical database/server-operation plan and selected client architecture.

## Accepted technology baseline

```text
Android/dashboard UI         Flutter + Dart
State/DI                     Riverpod
Routing                      go_router typed routes/stateful shells
Architecture                 views/view models, repositories, services
Authentication               Supabase Auth
Database                     Supabase Postgres
Private images               Supabase Storage
Authoritative operations     Postgres functions/RPC
Recurring jobs               Supabase Cron / pg_cron
Android local data           SQLite / sqflite
Background sync retry        WorkManager integration
Dashboard draft recovery     IndexedDB-backed adapter
Dashboard hosting            Vercel static SPA
CI/CD                        GitHub Actions + Supabase CLI
Security/accessibility       ASVS 5.0, MASVS, WCAG 2.2
```

Flutter 3.44.7 remains the approved foundation pin and is reverified at task start.

## Accepted client architecture

- Views are declarative and consume immutable state.
- Riverpod controllers/view models orchestrate presentation.
- Repositories are the client source of truth and coordinate services.
- Widgets never call Supabase, SQLite or Storage directly.
- Domain models do not import Flutter/Supabase.
- go_router owns auth guards, deep links, browser history and stateful mobile branches.
- No second global state/routing framework.

## Android information architecture

```text
Home | Week | Progress | Profile
```

- Home: full-circle authoritative rank progress, today action, week summary and metrics.
- Week: seven-day plan, locks, allocations, swaps and protection.
- Progress: calendar/history, exercise trends, rank/XP/wallet transactions and corrections.
- Profile: account/preferences/accessibility/cache/export/session/logout.
- Context routes: workout overview/logger/guidance/result, rank detail, swap and correction/protection.

## Dashboard information architecture

```text
Overview | Routines | Exercises | Reviews | Activity | Settings
```

- adaptive drawer/rail/sidebar;
- attention-first Overview and resumable drafts;
- search, command palette and shortcuts;
- structured guidance/media editor;
- seven-day routine editor, validation, mobile preview and review diff;
- explicit save/offline/conflict/version states.

## Database/server baseline

Canonical plan: `docs/context/DATABASE_AND_SERVER_PLAN.md`.

Domains are accounted for:

- profiles/preferences/capabilities/compatibility;
- exercises/muscles/guidance/media/YouTube;
- routine drafts/validation/submission/review/versions;
- training weeks/items/snapshots/swaps/credit ledger;
- sessions/exercises/sets/sync/submission/results;
- performance/PR/progression;
- RR/XP/rank/wallet/finalization/milestones;
- protection/pain/substitution/correction;
- activity/audit/export/account lifecycle.

Protected guarantees:

- RLS on exposed private data;
- security-invoker by default;
- hardened, explicitly granted security-definer functions only when necessary;
- append-only ledgers and exact reversal corrections;
- immutable published/materialized/finalized history;
- idempotency keys, revision checks, unique constraints and locks;
- cron plus catch-up for recurring operations;
- UTC timestamps plus IANA reward timezone/local date evidence.

## Offline and synchronization baseline

- A workout starts online and is server locked.
- Android stores immutable session snapshot, active draft and outbox in internal SQLite.
- Each mutation has idempotency key, payload version and sequence.
- Autosave is transactional; offline continuation is supported.
- WorkManager may perform best-effort constrained retry; no continuous polling.
- Offline completion remains pending until server validation.
- Session expiry quarantines unsynchronized work for same-account reauthentication.
- Dashboard IndexedDB protects draft edits but review/publication/media authority requires connectivity.
- Supabase Realtime is not required for MVP.

## Media and web baseline

- private `exercise-media` bucket;
- JPEG/PNG/static WebP, six images, 5 MB processed maximum;
- EXIF/GPS stripping, orientation/resize/re-encode/hash/alt text;
- immutable paths and Storage API deletion;
- official YouTube embeds only;
- standard Flutter Web release build initially;
- Wasm evaluated later because COOP/COEP and cross-origin integrations require testing;
- Vercel SPA rewrite, preview protection, CSP/security headers and explicit caching.

## Operations baseline

- local/staging/production isolation;
- migrations in Git only;
- pgTAP/RLS/function/concurrency tests in CI;
- compatibility/read-only/maintenance controls;
- Supabase Logs Explorer/Cron/advisors and redacted correlation IDs;
- no analytics/crash SDK without separate privacy/cost decision;
- managed DB backups plus independent encrypted DB and Storage exports;
- Storage hash manifest reconciliation;
- RPO 24 hours, RTO 4 hours, release and quarterly restore drills;
- user-owned CSV/JSON export and operator-managed deactivation/deletion runbook.

## Packet sequence

```text
TASK-IMP-001  Foundation — APPROVED, NEXT
TASK-IMP-002A Identity/sessions — PLANNED
TASK-IMP-002B Shared UI/mobile shell/Home — PLANNED
TASK-IMP-002C Dashboard shell/Overview — PLANNED
TASK-IMP-003A Exercise/guidance — PLANNED
TASK-IMP-003B Media/YouTube — PLANNED
TASK-IMP-003C Routine/review/publication — PLANNED
TASK-IMP-004  Weekly schedule/swaps/grants — PLANNED
TASK-IMP-005A Workout logger/SQLite/sync — PLANNED
TASK-IMP-005B Workout guidance/media — PLANNED
TASK-IMP-006  Rank/wallet/Progress/finalization — PLANNED
TASK-IMP-007  Progression/protection/corrections — PLANNED
TASK-IMP-008  Production/release/recovery/export — PLANNED
```

## Deliberate exclusions

No public signup/recovery, social/public profiles, nutrition, sleep, wearables, AI coach, camera form analysis, marketplace, direct video upload, iOS initial release, offline workout start, client-authoritative rewards, full offline dashboard, Realtime requirement, analytics/ads or unrestricted rewarded extra workouts.

## Exact next action

Review and merge Pull Request #2, then execute:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
branch: codex/task-imp-001-foundation
```

Do not begin later packets until prerequisites are merged and the packet is reverified/promoted to `APPROVED`.
