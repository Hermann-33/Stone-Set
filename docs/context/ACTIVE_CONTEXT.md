# Stone Set Active Context

Updated: 2026-08-07

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
- native Dart Pub workspace with one root lockfile;
- Android-only and Web-only accessible Flutter foundation shells;
- pure Dart domain/data and Flutter UI foundation packages with tested dependency boundaries;
- local-only Supabase configuration, empty seed and pgTAP runner smoke test;
- pinned cross-platform repository tooling and GitHub Actions foundation CI configuration;
- merged `TASK-IMP-002A` identity clients, local Auth/database migration, pgTAP/config/lifecycle
  tests and trusted operator tooling through pull request #7;
- merged `TASK-IMP-002B` shared themes, fixture-driven mobile shell/Home, canonical-rank staging,
  reviewed Linux goldens and bounded API 24 verification through pull request #10;
- merged `TASK-IMP-002C` fixture-only adaptive dashboard shell/Overview, productivity surfaces,
  responsive primitives, reviewed Linux goldens and browser/API 24 verification through pull
  request #12;
- bounded 003A exercise/guidance schema, contracts, dashboard authoring and IndexedDB recovery are
  implemented on the task branch pending final-head CI and merge;
- no media/Storage, routine, schedule, workout, scoring, remote Supabase/Vercel project or
  deployment.

## Phase

```text
Phase 0 — COMPLETE
Phase 1 — COMPLETE
Phase 2A — COMPLETE
Phase 2B — COMPLETE
Phase 2C — COMPLETE
```

Completed foundation task:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
Verdict: COMPLETE AND MERGED
Pull request: #5 — MERGED
Merge commit: 3d0830767fd5320f33a4b7a209d937d2b59f7a6e
```

The foundation was merged through pull request #5. Root resolution, tool pins, repository checks,
formatting, analysis, all Dart/Flutter tests, the Web release build and security review passed
locally. Foundation CI run `31003516689` passed its repository, Flutter/Dart, Android/Web build and
local Supabase lifecycle jobs. This Windows host lacks an Android SDK and Docker/Podman, so the
Android and Supabase CI-proven gates cannot currently be repeated on this host.

`TASK-PD-014` was merged through pull request #6 at
`c371f9c8ad28dc90bef86739c2c9aa87e5450f27`. `TASK-PD-015` then corrected the dependency family and
merged through pull request #8 at `52ec1886e5ed5080e129c1f3d22523c0019f07b1`. `TASK-IMP-002A` then
merged through pull request #7 at `2281be745b75116e70d2fed9ccf85c60e79bc4aa`: exact restore,
generation freshness, strict analysis, tests, release builds, local Supabase
replay/security/lifecycle checks and bundle review pass in final CI run `31093560109`. The
implementation remains local-only and creates no remote infrastructure.

`TASK-IMP-002B` merged through pull request #10 at
`1ab0fc56543dbd64500a9319dd6a3f014c4ccc90`. Its final-head GitHub Actions run `31109946478`
passed documentation/repository, Flutter/Dart, Android API 24 profile and local Supabase jobs. The
implementation is fixture-only presentation and does not add authoritative schedules, workouts,
rank/wallet behavior or remote infrastructure.

`TASK-IMP-002C` merged through pull request #12 at
`be0f57eee35066da0590e0cf2a3f55d6193231af`. Its final-head GitHub Actions run `31165238497`
passed documentation/repository, Flutter/Dart, browser, Android release/API 24 profile and local
Supabase jobs. `TASK-IMP-003A` builds the first real product-content vertical on that foundation;
media, routines and remote infrastructure remain absent.

## Implemented foundation pins

```text
Flutter       3.44.7
Dart          3.12.2
Node.js       24.11.1
Supabase CLI  2.111.0
test          1.31.0
flutter_lints 6.0.0
```

Exact machine-readable tool pins are in `tool/tool_versions.json`; the resolved Dart and npm
graphs are in the root `pubspec.lock` and `package-lock.json`.

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
TASK-IMP-001  Foundation — COMPLETE AND MERGED
TASK-IMP-002A Identity/sessions — COMPLETE AND MERGED
TASK-IMP-002B Shared UI/mobile shell/Home — COMPLETE AND MERGED
TASK-IMP-002C Dashboard shell/Overview — COMPLETE AND MERGED
TASK-IMP-003A Exercise/guidance — IMPLEMENTED; FINAL-HEAD CI AND MERGE PENDING
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

Complete final-head verification and merge the implemented exercise-library and
structured-guidance packet.

```text
task: TASK-IMP-003A
branch: codex/task-imp-003a-exercise-guidance
packet: docs/tasks/TASK-IMP-003A.md
action: draft PR -> path-sensitive CI -> merge (Linux goldens reviewed and committed)
```

Implement only the packet's owner-scoped exercise, structured-guidance, immutable-publication and
browser-recovery scope. Media/YouTube, routines/review and later packets remain unapproved.
