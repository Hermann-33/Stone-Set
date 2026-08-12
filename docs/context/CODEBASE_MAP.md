# Stone Set Codebase Map

Updated: 2026-08-13

## Current repository

| Path | Responsibility |
|---|---|
| `README.md` | Project state, pinned prerequisites and root setup/verification commands |
| `AGENTS.md` | Mandatory repository/agent rules |
| `pubspec.yaml` / `pubspec.lock` | Native Dart workspace membership and exact shared dependency resolution |
| `analysis_options.yaml` | Shared strict Dart/Flutter analysis policy and Riverpod analysis-server plugin pin |
| `package.json` / `package-lock.json` | Exact project-local Supabase CLI installation |
| `tool/tool_versions.json` | Machine-readable Flutter, Dart, Node.js and Supabase CLI pins |
| `bin/stone_set.dart` / `lib/src/tooling/` | Cross-platform restore, checks, tests, builds and local Supabase commands |
| `apps/mobile/` | Android identity/session, owner-scoped SQLite cache/workout drafts, synchronization coordinator, Home/Week/Progress/Profile shell, workouts/guidance and TASK-IMP-009 presentation |
| `apps/dashboard/` | Web identity/session, adaptive shell, exercise/guidance/media and routine authoring, production dashboard workflows |
| `packages/domain/` | Pure Dart product models, validation and repository contracts shared by clients |
| `packages/data/` | Supabase repository/service/error implementations depending on `domain` |
| `packages/ui/` | Shared accessible Auth, semantic themes/components and rank presentation |
| `config/` | Non-secret public-client configuration example and usage boundary |
| `supabase/` | Tracked migrations, local config, synthetic seed and database/RLS/Storage tests |
| `tool/operator/` | Trusted operator CLI and tests; excluded from clients |
| `.github/workflows/foundation-ci.yml` | Repository, generated source, Flutter/Dart, goldens, Android API 24, release build and local-Supabase gates |
| `.github/workflows/private-release.yml` | Trusted exact-main permanent-signed Android verification and Firebase App Distribution |
| `docs/security/Stone-Set-threat-model.md` | Bounded Auth/session/guidance/media/Storage/YouTube threat model and residual risks |
| `docs/context/` | Current architecture, status, handoff, code map and append-only audit state |
| `docs/product/` | Accepted user/product behavior and UI specifications |
| `docs/decisions/` | Accepted ADRs, including ADR-0010 offline-first mobile caching/synchronization |
| `docs/tasks/` | Completed/planned/approved/partial bounded execution packets |
| `assets/ranks/` | Canonical source for 20 rank-v6 assets and provenance |

## TASK-IMP-013A mobile ownership

### Local persistence

```text
apps/mobile/lib/features/local/data/mobile_local_database.dart
apps/mobile/lib/features/local/data/mobile_snapshot_store.dart
apps/mobile/lib/features/local/data/mobile_snapshot_codec.dart
apps/mobile/lib/features/local/data/sqflite_mobile_snapshot_store.dart
apps/mobile/lib/features/local/providers/mobile_local_providers.dart
```

Responsibilities:

- open the existing `stone_set_workout.db`;
- migrate database v1→v2 without replacing workout tables;
- persist owner-scoped schema-versioned bootstrap/Week/Progress snapshots;
- persist synchronization generation/freshness/error metadata;
- atomically promote coherent Week+Progress generations;
- reject wrong-owner/malformed cached payloads.

Existing workout durability remains in:

```text
apps/mobile/lib/features/workout/data/sqflite_workout_local_store.dart
apps/mobile/lib/features/workout/data/workout_local_store.dart
apps/mobile/lib/features/workout/data/workout_private_work.dart
```

### Cached authentication

```text
apps/mobile/lib/features/identity/controllers/mobile_session_controller.dart
apps/mobile/lib/features/identity/providers/identity_providers.dart
```

Responsibilities:

- recover persisted Supabase session locally;
- render only same-owner eligible cached bootstrap before network refresh;
- preserve cached protected shell across recoverable transport failure;
- reject password-change/access-denied/maintenance/incompatible cached authorization;
- quarantine/preserve owner-scoped pending workout work on logout/session loss.

### Synchronization coordinator

```text
apps/mobile/lib/features/sync/controllers/mobile_sync_controller.dart
apps/mobile/lib/features/sync/providers/mobile_sync_dependencies.dart
```

Responsibilities:

- single-flight synchronization;
- auth/session revalidation;
- pending supported workout mutation sync before final reads;
- authoritative Week/wallet then Progress/rank/history fetches;
- owner validation and coherent cache commit;
- generation/freshness/error state publication.

### Cache-backed presentation and lifecycle

```text
apps/mobile/lib/features/home/...
apps/mobile/lib/features/week/...
apps/mobile/lib/features/progress/...
apps/mobile/lib/features/shell/views/mobile_authenticated_shell.dart
```

Responsibilities:

- Home/Week/Progress cache-first rendering;
- native pull-to-refresh through the central coordinator;
- cached UI preservation on recoverable failure;
- mounted Home rank/RR generation updates without restart;
- startup/resume best-effort synchronization.

### Verification ownership

```text
apps/mobile/test/mobile_local_database_test.dart
apps/mobile/test/mobile_snapshot_codec_test.dart
apps/mobile/test/mobile_session_controller_test.dart
apps/mobile/test/mobile_sync_controller_test.dart
apps/mobile/test/mobile_shell_home_test.dart
apps/mobile/test/mobile_authentication_test.dart
apps/mobile/test/week_screen_test.dart
apps/mobile/test/progress_screen_test.dart
apps/mobile/test/workout/workout_controller_test.dart
apps/mobile/integration_test/mobile_shell_profile_test.dart
```

Exact runtime candidate `51474a6e8d3157bfbdad9c9e1de3fa57a468a758` passed Foundation CI run `31621647343` (#365), including the affected mobile suite, Android release APK and Android API 24 profile.

## Canonical context documents

| Path | Responsibility |
|---|---|
| `ACTIVE_CONTEXT.md` | Present accepted state and exact next action |
| `ARCHITECTURE.md` | System/client/backend/environment boundaries; accepted ADRs supersede stale historical descriptions where noted |
| `TECHNOLOGY_BASELINE.md` | Flutter, Riverpod, go_router, persistence, hosting and verification choices |
| `DATABASE_AND_SERVER_PLAN.md` | Relational domains, RLS, RPC, cron, sync, lifecycle and migration map |
| `SYSTEM_IMPLEMENTATION_READINESS_AUDIT.md` | Implementation-readiness coverage audit |
| `IMPLEMENTATION_PLAN.md` | Canonical phase/packet sequence |
| `UI_IMPLEMENTATION_PLAN.md` | UI-specific milestone ownership |
| `ROADMAP.md` | Phase state and gates |
| `WORKFLOW.md` | Planning/task/verification/Git process |
| `HANDOFF.md` | Latest result and continuation point |
| `AUDIT_LOG*.md` | Append-only material decision/task history; active volume is `AUDIT_LOG_CONTINUED_4.md` |

## Primary product documents

| Path | Responsibility |
|---|---|
| `AUTHENTICATION_AND_SESSION_UX.md` | Provisioned login/password/session/logout/recovery behavior |
| `COMPLETE_UI_UX_SYSTEM.md` | Complete Android/dashboard UI/UX baseline |
| `MOBILE_HOME_AND_RANK_PROGRESS_UI.md` | Home/rank behavior and motion |
| `APPLICATION_WORKFLOW.md` | End-to-end workflow |
| `EXERCISE_GUIDANCE_AND_MEDIA.md` | Guidance/images/YouTube/version/offline behavior |
| `ROUTINE_ELIGIBILITY.md` | Routine validator rules; retired review policy must not be reintroduced |
| `WEEKLY_SCHEDULING.md` | Routine versions, weeks, locks, swaps and grants |
| `RANK_SYSTEM.md` | rank-v6 economy, rewards, penalties, consistency and finalization |
| `HYPERTROPHY_ROUTINE.md` | Initial owner routine |

## Current task packets

| Packet | Status | Scope |
|---|---|---|
| `TASK-IMP-001`–`TASK-IMP-008` | Complete and merged | Foundation through minimal private release |
| `TASK-IMP-009` | Complete and merged through PR #31 | Android visual/accessibility/motion modernization |
| `TASK-IMP-010` | Complete | Authoritative base consistency multiplier and Home fixture correction |
| `TASK-IMP-011` | Partial; approved content pending | Exercise-detail media integration/content population |
| `TASK-IMP-012` | Partial; backup/phone confirmation pending | Permanent Android signing and private distribution |
| `TASK-IMP-013A` | Partial; runtime green, merge/distribution/device acceptance pending | Offline-first cached read shell, central sync and Home refresh |

## Implemented foundation workspace

```text
apps/
  mobile/
  dashboard/
packages/
  domain/
  data/
  ui/
config/
supabase/
bin/
lib/src/tooling/
tool/
tools/
.github/workflows/
docs/
assets/
```

## Dependency direction

```text
mobile -> domain, data, ui
dashboard -> domain, data, ui
data -> domain
ui -> Flutter
domain -> Dart SDK
```

Rules:

- widgets do not call Supabase/SQLite/Storage directly when a repository/provider boundary owns the operation;
- domain has no Flutter/Supabase dependency;
- Riverpod is the single application state/DI system;
- go_router owns client navigation;
- public clients contain publishable configuration only;
- cached mobile state is owner-scoped/private but non-authoritative;
- clients never authoritatively set RR, XP, rank, penalties, wallet, swaps or finalization.

## Authority boundaries

- Supabase Auth owns credentials/sessions.
- Postgres owns authoritative product records and server-calculated reward/scheduling state.
- Storage owns private image bytes; Postgres owns media metadata.
- SQLite owns local active workout durability plus TASK-IMP-013A owner-scoped cached read snapshots.
- Cached mobile snapshots never replace server authority.
- Published/materialized/finalized history remains immutable.
- RR/XP/wallet changes remain server-owned append-only transactions/reversals.
- RLS protects exposed private relations/objects.
- Service-role, management, deployment, signing and backup secrets never enter Flutter clients or tracked source.

## Fragile invariants

- `rank-v6`, 20-rank ladder, Adonis 5,500 RR and multiplier ladder;
- `schedule-v3`, seven materialized items, swap/payment/free-credit rules;
- authoritative online workout start and server finalization;
- pending/local workout work cannot fabricate authoritative rank/ledger state;
- wrong-owner cache/workout state must never be exposed;
- direct owner routine publication; no independent-review resurrection;
- rank assets/mapping remain stable;
- no historical recalculation using newer configuration;
- Android application ID and permanent signer remain unchanged by TASK-IMP-013A.
