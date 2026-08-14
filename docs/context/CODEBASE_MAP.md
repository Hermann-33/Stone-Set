# Stone Set Codebase Map

Updated: 2026-08-14
Active audit volume: `docs/context/AUDIT_LOG_CONTINUED_6.md`

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

## TASK-IMP-015 ownership — deployed

Week browsing and swap interaction:

```text
apps/mobile/lib/features/week/views/week_screen.dart
apps/mobile/lib/features/week/views/week_day_detail_sheet.dart
apps/mobile/test/week_screen_test.dart
```

Responsibilities:

- normal tap opens read-only day detail;
- workout days expose prescriptions and guidance;
- rest days remain inspectable and explicitly contain no prescribed exercises;
- swap selection is long-press-only;
- confirmation is single-flight and selection clears after authoritative acceptance.

Workout start switching:

```text
apps/mobile/lib/features/workout/controllers/workout_controller.dart
apps/mobile/test/workout_switching_test.dart
```

Responsibilities:

- synchronize pending different-workout edits before switching;
- preserve pending data if synchronization fails;
- clear only synchronized stale local workout state;
- then invoke the existing server-authoritative online workout start;
- never delete/rewrite server workout-session history.

Week detail server contract:

```text
supabase/migrations/20260813042000_training_week_item_detail.sql
supabase/tests/database/training_week_item_detail.test.sql
```

Production migration history:

```text
20260814080728_training_week_item_detail
```

Responsibilities:

- `public.get_training_week_item_detail_v1(uuid)` is owner-scoped by `auth.uid()`;
- security invoker, authenticated execute only;
- left join preserves rest-item detail;
- read-only guidance lookup may resolve the latest finalized published bundle without rewriting materialized history.

Deployment evidence:

```text
PR #56                  MERGED
runtime main            d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
Foundation CI #414      PASS
Private Android #73     PASS
release                 0.1.0 (1000073), Firebase 3evhve7djjghg
```

## TASK-IMP-014 ownership — deployed

Dashboard publication feedback:

```text
apps/dashboard/lib/src/features/exercises/controllers/dashboard_guidance_media_controller.dart
apps/dashboard/lib/src/features/exercises/views/dashboard_youtube_preview.dart
apps/dashboard/lib/src/features/exercises/views/dashboard_youtube_preview_platform_web.dart
apps/dashboard/test/src/features/exercises/dashboard_guidance_publication_freshness_test.dart
```

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

Mobile consumption boundary:

```text
apps/mobile/lib/features/workout/guidance/workout_guidance_loader.dart
```

TASK-IMP-014 engineering is deployed; affected owner drafts still require genuine preview validation and explicit Publish.

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
| `TASK-IMP-015` | Complete and deployed | Week-day details, deliberate long-press swaps and reliable workout start |
| `TASK-IMP-016` | Complete and deployed | Vercel preview-build suppression/main-only production policy |

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
- Week day detail is an authenticated read surface only and cannot mutate schedule/workout authority.
- RLS protects exposed private data.
- Service-role, management, deployment, signing and backup secrets never enter Flutter clients/source.

## Fragile invariants

- `rank-v6`, Adonis 5,500 RR and multiplier ladder;
- `schedule-v3` and swap/payment/free-credit rules;
- authoritative online workout start/finalization;
- no local fabrication of rank/ledger authority;
- wrong-owner state must never be exposed;
- pending local workout edits must not be silently discarded;
- direct owner routine publication; no independent-review resurrection;
- published/historical content and started workout guidance snapshots remain immutable;
- Android application ID/permanent signer/Firebase architecture remain unchanged.
