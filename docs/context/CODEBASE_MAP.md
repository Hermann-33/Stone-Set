# Stone Set Codebase Map

Updated: 2026-08-13

## Current repository

| Path | Responsibility |
|---|---|
| `README.md` | Project state, prerequisites and root verification commands |
| `AGENTS.md` | Mandatory repository/agent rules |
| `apps/mobile/` | Android identity/session, owner-scoped SQLite cache/workout drafts, synchronization, Home/Week/Progress/Profile, workout execution and guidance consumption |
| `apps/dashboard/` | Web identity/session, adaptive shell, exercise/guidance/media and routine authoring/publication |
| `packages/domain/` | Pure Dart models, validation and repository contracts |
| `packages/data/` | Supabase repository/service/error implementations |
| `packages/ui/` | Shared accessible UI/theme/rank primitives |
| `supabase/` | Tracked migrations, local config and database/RLS/Storage tests |
| `tool/operator/` | Trusted operator tooling; excluded from clients |
| `.github/workflows/foundation-ci.yml` | Path-sensitive repository, Flutter/Dart, Web/Android and Local Supabase verification |
| `.github/workflows/private-release.yml` | Trusted exact-main Android Firebase distribution |
| `docs/product/` | Accepted product behavior |
| `docs/decisions/` | Accepted ADRs |
| `docs/tasks/` | Bounded execution packets |
| `docs/context/` | Current architecture/status/handoff/code map and append-only audit history |

## TASK-IMP-014 ownership — deployed

Dashboard publication feedback:

```text
apps/dashboard/lib/src/features/exercises/controllers/dashboard_guidance_media_controller.dart
apps/dashboard/lib/src/features/exercises/views/dashboard_youtube_preview.dart
apps/dashboard/lib/src/features/exercises/views/dashboard_youtube_preview_platform_web.dart
apps/dashboard/test/src/features/exercises/dashboard_guidance_publication_freshness_test.dart
```

Responsibilities:

- expose `preview_required` as an actionable publication blocker;
- locally stop before reservation when the loaded draft already requires preview;
- preserve server authority for missing/expired one-hour preview evidence;
- retain genuine IFrame playable state as the validation source;
- never fabricate validation/publication.

Server activation:

```text
supabase/migrations/20260812180500_latest_published_guidance_for_new_workouts.sql
supabase/tests/database/guidance_publication_freshness.test.sql
supabase/tests/database/workout_execution.test.sql
```

Production migration history:

```text
20260812190919_latest_published_guidance_for_new_workouts
```

Responsibilities:

- preserve immutable routine prescription guidance IDs as historical evidence;
- on a new `workout_session_exercises` insert, resolve the latest owner/exercise published revision backed by a finalized media manifest;
- use the supplied routine revision as fallback when no eligible bundle exists;
- never rewrite already-created workout snapshots after later publication.

Mobile consumption boundary:

```text
apps/mobile/lib/features/workout/guidance/workout_guidance_loader.dart
```

Mobile loads the exact `guidance_revision_id` pinned into the workout-session snapshot. TASK-IMP-014 adds no client-side `latest` lookup and therefore requires no Android app update.

Deployment evidence:

```text
PR #48                  MERGED
main                     7c805c085761605363e5d266940449a0c8400647
Foundation CI #390       PASS
Vercel deployment        dpl_ApzpAb69cf6pe5BuL3jY5q6jYmAp — READY production
production alias         stone-set.vercel.app
```

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

TASK-IMP-013A merged through PR #47 at `ec8fb9324ecadc90654e011f242e523e8f517ca0`; exact-main Foundation CI #372 passed. Real-device airplane-mode acceptance remains independent.

## Current task packets

| Packet | Status | Scope |
|---|---|---|
| `TASK-IMP-001`–`TASK-IMP-010` | Complete and merged | Foundation through private release, presentation and consistency work |
| `TASK-IMP-011` | Partial; approved content pending | Exercise-detail media integration/content population |
| `TASK-IMP-012` | Partial; backup/phone confirmation pending | Permanent Android signing/private distribution |
| `TASK-IMP-013A` | Merged; physical acceptance residual | Offline-first cached read shell, central sync and Home refresh |
| `TASK-IMP-014` | Partial only at owner publish boundary; engineering/deployment complete | Guidance/media publication feedback and latest-published activation for new workouts |

## Dependency direction

```text
mobile -> domain, data, ui
dashboard -> domain, data, ui
data -> domain
ui -> Flutter
domain -> Dart SDK
```

## Authority boundaries

- Supabase Auth owns credentials/sessions.
- Postgres owns authoritative product/publication/workout/schedule/reward state.
- Storage owns private image bytes; Postgres owns media metadata/manifests.
- SQLite owns non-authoritative local workout durability and owner-scoped read cache.
- Published guidance/media, routine versions/materialized weeks and completed/history records are immutable.
- New workout-session creation may resolve newer finalized content-only guidance under ADR-0011; once created, the session revision is immutable.
- RLS protects exposed private data.
- Service-role, management, deployment, signing and backup secrets never enter Flutter clients/source.

## Fragile invariants

- `rank-v6`, Adonis 5,500 RR and multiplier ladder;
- `schedule-v3` and swap/payment/free-credit rules;
- authoritative online workout start/finalization;
- no local fabrication of rank/ledger authority;
- wrong-owner state must never be exposed;
- direct owner routine publication; no independent-review resurrection;
- published/historical content and started workout guidance snapshots remain immutable;
- Android application ID/permanent signer/Firebase architecture remain unchanged by TASK-IMP-014.
