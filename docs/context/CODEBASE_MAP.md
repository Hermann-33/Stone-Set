# Stone Set Codebase Map

Updated: 2026-08-13

## Current repository

| Path | Responsibility |
|---|---|
| `README.md` | Project state, pinned prerequisites and root setup/verification commands |
| `AGENTS.md` | Mandatory repository/agent rules |
| `pubspec.yaml` / `pubspec.lock` | Native Dart workspace and exact shared dependency resolution |
| `analysis_options.yaml` | Shared strict Dart/Flutter analysis policy |
| `package.json` / `package-lock.json` | Exact project-local Supabase CLI installation |
| `tool/tool_versions.json` | Machine-readable Flutter, Dart, Node.js and Supabase CLI pins |
| `bin/stone_set.dart` / `lib/src/tooling/` | Cross-platform restore, checks, tests, builds and local Supabase commands |
| `apps/mobile/` | Android identity/session, owner-scoped SQLite cache/workout drafts, synchronization, Home/Week/Progress/Profile, workout execution and guidance consumption |
| `apps/dashboard/` | Web identity/session, adaptive shell, exercise/guidance/media and routine authoring, publication and production dashboard workflows |
| `packages/domain/` | Pure Dart product models, validation and repository contracts |
| `packages/data/` | Supabase repository/service/error implementations |
| `packages/ui/` | Shared accessible Auth, semantic themes/components and rank presentation |
| `supabase/` | Tracked migrations, local config, synthetic seed and database/RLS/Storage tests |
| `tool/operator/` | Trusted operator CLI and tests; excluded from clients |
| `.github/workflows/foundation-ci.yml` | Path-sensitive repository, Flutter/Dart, golden, Web/Android and Local Supabase verification |
| `.github/workflows/private-release.yml` | Trusted exact-main permanent-signed Android verification and Firebase App Distribution |
| `docs/product/` | Accepted product behavior |
| `docs/decisions/` | Accepted ADRs |
| `docs/tasks/` | Bounded execution packets |
| `docs/context/` | Current architecture/status/handoff/code map and append-only audit history |
| `assets/ranks/` | Canonical rank-v6 assets/provenance |

## TASK-IMP-014 guidance publication freshness ownership

### Dashboard publication feedback

```text
apps/dashboard/lib/src/features/exercises/controllers/dashboard_guidance_media_controller.dart
apps/dashboard/lib/src/features/exercises/views/dashboard_youtube_preview.dart
apps/dashboard/lib/src/features/exercises/views/dashboard_youtube_preview_platform_web.dart
apps/dashboard/test/src/features/exercises/dashboard_guidance_publication_freshness_test.dart
```

Responsibilities:

- expose `preview_required` as a specific publication blocker;
- fail locally before reservation when the loaded draft already requires preview;
- preserve server authority for missing/expired one-hour YouTube preview evidence;
- retain the real YouTube IFrame playable callback as the only successful-preview validation path;
- never fabricate validation or publication.

### New-workout guidance activation

```text
supabase/migrations/20260812180500_latest_published_guidance_for_new_workouts.sql
supabase/tests/database/guidance_publication_freshness.test.sql
supabase/tests/database/workout_execution.test.sql
```

Responsibilities:

- keep immutable routine prescription guidance IDs as historical prescription evidence;
- on a new `workout_session_exercises` insert, resolve the latest owner/exercise published guidance revision backed by a finalized media manifest;
- use the supplied routine revision as fallback if no eligible bundle exists;
- never rewrite already-created workout-session snapshots after later publication;
- verify resolver installation, latest-selection behavior and snapshot immutability through pgTAP;
- preserve the existing `start_workout_v1` execution regression unchanged.

### Mobile consumption boundary

```text
apps/mobile/lib/features/workout/guidance/workout_guidance_loader.dart
```

Mobile continues to load the exact `guidance_revision_id` pinned into the workout-session exercise snapshot. TASK-IMP-014 deliberately does not add a client-side `latest` lookup. This keeps active-session offline behavior and history deterministic.

## TASK-IMP-013A mobile offline-first ownership

```text
apps/mobile/lib/features/local/...
apps/mobile/lib/features/sync/...
apps/mobile/lib/features/identity/controllers/mobile_session_controller.dart
apps/mobile/lib/features/home/...
apps/mobile/lib/features/week/...
apps/mobile/lib/features/progress/...
apps/mobile/lib/features/shell/views/mobile_authenticated_shell.dart
apps/mobile/lib/features/workout/data/...
```

Responsibilities include owner-scoped SQLite v2 read snapshots, cached authenticated shell restoration, coherent mobile synchronization, cache-first Home/Week/Progress, native pull-to-refresh, mounted rank refresh and safe owner-scoped pending workout work.

TASK-IMP-013A merged through PR #47 at main commit `ec8fb9324ecadc90654e011f242e523e8f517ca0`; exact-main Foundation CI #372 passed.

## Canonical context documents

| Path | Responsibility |
|---|---|
| `ACTIVE_CONTEXT.md` | Present accepted state and exact next action |
| `ARCHITECTURE.md` | Current system/client/backend/environment boundaries |
| `TECHNOLOGY_BASELINE.md` | Flutter, Riverpod, go_router, persistence, hosting and verification choices |
| `DATABASE_AND_SERVER_PLAN.md` | Relational domains, RLS, RPC, cron, sync, lifecycle and migration map |
| `IMPLEMENTATION_PLAN.md` | Canonical implementation sequence |
| `ROADMAP.md` | Phase state and gates |
| `WORKFLOW.md` | Planning/task/verification/Git process |
| `HANDOFF.md` | Latest result and continuation point |
| `AUDIT_LOG*.md` | Append-only material decision/task history; active volume is `AUDIT_LOG_CONTINUED_4.md` |

## Primary product documents

| Path | Responsibility |
|---|---|
| `AUTHENTICATION_AND_SESSION_UX.md` | Provisioned login/password/session/logout/recovery behavior |
| `COMPLETE_UI_UX_SYSTEM.md` | Android/dashboard UI/UX baseline |
| `MOBILE_HOME_AND_RANK_PROGRESS_UI.md` | Home/rank behavior and motion |
| `APPLICATION_WORKFLOW.md` | End-to-end workflow |
| `EXERCISE_GUIDANCE_AND_MEDIA.md` | Guidance/images/YouTube/versioning/activation/offline behavior |
| `WEEKLY_SCHEDULING.md` | Routine versions, weeks, locks, swaps and grants |
| `RANK_SYSTEM.md` | rank-v6 economy, rewards, penalties, consistency and finalization |
| `HYPERTROPHY_ROUTINE.md` | Initial owner routine |

## Current task packets

| Packet | Status | Scope |
|---|---|---|
| `TASK-IMP-001`–`TASK-IMP-010` | Complete and merged | Foundation through private release, later presentation and consistency work |
| `TASK-IMP-011` | Partial; approved content pending | Exercise-detail media integration/content population |
| `TASK-IMP-012` | Partial; backup/phone confirmation pending | Permanent Android signing/private distribution |
| `TASK-IMP-013A` | Merged; physical acceptance residual | Offline-first cached read shell, central sync and Home refresh |
| `TASK-IMP-014` | Partial; green candidate, merge/deployment pending | Guidance/media publication feedback and latest-published activation for newly started workouts |

## Dependency direction

```text
mobile -> domain, data, ui
dashboard -> domain, data, ui
data -> domain
ui -> Flutter
domain -> Dart SDK
```

Rules:

- widgets use repository/provider boundaries rather than direct Supabase/SQLite/Storage authority;
- domain has no Flutter/Supabase dependency;
- Riverpod is the application state/DI system;
- go_router owns client navigation;
- public clients contain publishable configuration only;
- clients never authoritatively set RR, XP, rank, penalties, wallet, swaps, guidance publication or workout finalization.

## Authority boundaries

- Supabase Auth owns credentials/sessions.
- Postgres owns authoritative product records, publication state, workout snapshots and server-calculated reward/scheduling state.
- Storage owns private image bytes; Postgres owns media metadata/manifests.
- SQLite owns local active-workout durability and owner-scoped cached read snapshots; it is non-authoritative.
- Published guidance/media revisions, routine versions/materialized weeks and completed/history records are immutable.
- Routine/version rows retain their historical guidance revision; new workout-session snapshot creation may resolve a newer finalized content-only guidance bundle under ADR-0011.
- Once a workout-session exercise snapshot exists, later publication cannot rewrite its pinned guidance revision.
- RLS protects exposed private relations/objects.
- Service-role, management, deployment, signing and backup secrets never enter Flutter clients or tracked source.

## Fragile invariants

- `rank-v6`, 20-rank ladder, Adonis 5,500 RR and multiplier ladder;
- `schedule-v3`, seven materialized items and swap/payment/free-credit rules;
- authoritative online workout start and server finalization;
- pending/local work cannot fabricate authoritative rank/ledger state;
- wrong-owner cache/workout/guidance state must never be exposed;
- direct owner routine publication; no independent-review resurrection;
- published/historical content remains immutable;
- started workout guidance snapshots remain immutable;
- Android application ID/permanent signer and Firebase architecture remain unchanged by TASK-IMP-014.
