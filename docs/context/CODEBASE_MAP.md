# Stone Set Codebase Map

Updated: 2026-08-06

## Current repository

| Path | Responsibility |
|---|---|
| `README.md` | Project state, pinned prerequisites and root setup/verification commands |
| `AGENTS.md` | Mandatory repository/agent rules |
| `pubspec.yaml` / `pubspec.lock` | Native Dart workspace membership and exact shared dependency resolution |
| `analysis_options.yaml` | Shared strict Dart/Flutter analysis policy |
| `package.json` / `package-lock.json` | Exact project-local Supabase CLI installation |
| `tool/tool_versions.json` | Machine-readable Flutter, Dart, Node.js and Supabase CLI pins |
| `bin/stone_set.dart` / `lib/src/tooling/` | Cross-platform root restore, check, test, build and local Supabase commands |
| `apps/mobile/` | Android-only accessible Flutter foundation shell and widget test |
| `apps/dashboard/` | Web-only accessible Flutter foundation shell, widget test and Vercel SPA rewrite |
| `packages/domain/` | Pure Dart domain foundation marker and unit test |
| `packages/data/` | Pure Dart foundation repository boundary depending only on `domain` |
| `packages/ui/` | Theme-driven, foundation-only Flutter placeholder primitive and widget test |
| `config/` | Non-secret public-client configuration example and usage boundary |
| `supabase/config.toml` | Local-only Supabase project configuration |
| `supabase/seed.sql` | Intentionally empty foundation seed |
| `supabase/tests/database/` | pgTAP runner smoke test; no product schema tests yet |
| `.github/workflows/foundation-ci.yml` | Least-privilege repository, Flutter/Dart and local Supabase CI gates |
| `docs/context/` | Current architecture, technology, data, roadmap, implementation, handoff and audit state |
| `docs/product/` | Accepted user/product behavior and UI specifications |
| `docs/decisions/` | Accepted ADRs |
| `docs/tasks/` | Completed/planned/approved bounded packets |
| `assets/ranks/` | 20 textless rank-v6 PNG assets, manifest/provenance/review |
| `tools/generate_rank_assets.py` | Reproducible rank asset generation/verification |

Executable foundation shells and local tooling exist. No authentication, product runtime/schema,
remote infrastructure, Vercel linkage or deployment exists.

## Canonical context documents

| Path | Responsibility |
|---|---|
| `ACTIVE_CONTEXT.md` | Present accepted state and exact next action |
| `ARCHITECTURE.md` | System/client/backend/environment boundaries |
| `TECHNOLOGY_BASELINE.md` | Flutter, Riverpod, go_router, persistence, hosting and verification choices |
| `DATABASE_AND_SERVER_PLAN.md` | Relational domains, RLS, RPC, cron, sync, lifecycle and migration map |
| `SYSTEM_IMPLEMENTATION_READINESS_AUDIT.md` | Final coverage audit and readiness verdict |
| `IMPLEMENTATION_PLAN.md` | Canonical phase/packet sequence across app/dashboard/database |
| `UI_IMPLEMENTATION_PLAN.md` | UI-specific milestone ownership |
| `ROADMAP.md` | Phase state and gates |
| `WORKFLOW.md` | Planning/task/verification/Git process |
| `HANDOFF.md` | Latest result and continuation point |
| `AUDIT_LOG*.md` | Append-only material decision/task history; active volume is `AUDIT_LOG_CONTINUED_3.md` |

## Primary product documents

| Path | Responsibility |
|---|---|
| `AUTHENTICATION_AND_SESSION_UX.md` | Provisioned login/password/session/logout/recovery behavior |
| `COMPLETE_UI_UX_SYSTEM.md` | Complete Android/dashboard UI/UX baseline |
| `MOBILE_HOME_AND_RANK_PROGRESS_UI.md` | Home/rank full-circle behavior and motion |
| `APPLICATION_WORKFLOW.md` | End-to-end workflow |
| `EXERCISE_GUIDANCE_AND_MEDIA.md` | Guidance/images/YouTube/version/offline behavior |
| `ROUTINE_ELIGIBILITY.md` | Validator/review/anti-triviality |
| `WEEKLY_SCHEDULING.md` | Routine versions, weeks, locks, swaps and grants |
| `RANK_SYSTEM.md` | rank-v6 economy, rewards, penalties, consistency and finalization |
| `HYPERTROPHY_ROUTINE.md` | Initial owner routine |

## Task packets

| Packet | Status | Scope |
|---|---|---|
| `TASK-IMP-001` | Complete and merged | Repository/Flutter/Supabase/CI foundation only; pull request #5 merged at `3d0830767fd5320f33a4b7a209d937d2b59f7a6e` |
| `TASK-IMP-002A` | Approved, not executed | Next bounded packet: identity, sessions, profiles, RLS and operator tooling |
| `TASK-IMP-002B` | Planned | Shared UI, Android shell/Home/rank hero |
| `TASK-IMP-002C` | Planned | Dashboard shell/Overview/search/productivity primitives |
| `TASK-IMP-003A/B/C` | Planned in implementation map | Exercise/guidance; media; routine/review |
| `TASK-IMP-004` | Planned | Weeks, allocations, locks, swaps and grants |
| `TASK-IMP-005A/B` | Planned | Workout logger/sync; guidance/media playback |
| `TASK-IMP-006` | Planned | Rank/XP/wallet/Progress/finalization |
| `TASK-IMP-007` | Planned | Progression/protection/corrections |
| `TASK-IMP-008` | Planned | Production hardening/release/export/recovery |

Future packets are created/reverified before authorization if not yet present as files.

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
  config.toml
  tests/database/
  seed.sql
bin/
lib/src/tooling/
tool/
tools/
.github/workflows/foundation-ci.yml
docs/
assets/
```

Only foundation placeholders and tooling are implemented in these application/package paths. The
feature responsibilities below remain future ownership and must not be read as implemented behavior.

## Planned package ownership

### `apps/mobile`

- native authentication screens;
- go_router stateful Home/Week/Progress/Profile shell;
- Home composition/rank hero orchestration;
- Week/swap UI;
- workout overview/logger/guidance/result;
- notifications/platform lifecycle;
- SQLite/outbox/cache/recovery integration;
- Android-specific routing and release configuration.

### `apps/dashboard`

- responsive authentication;
- go_router URL/deep-link shell;
- Overview/search/command palette;
- exercise/guidance/media/routine/review/activity/settings;
- IndexedDB draft recovery;
- browser file/upload/download integration;
- Vercel static configuration.

### `packages/domain`

Pure Dart:

- stable IDs/value objects;
- immutable domain models;
- validation/result/error types;
- units/time/config/version identities;
- repository contracts only where domain-owned;
- no Flutter/Supabase.

### `packages/data`

- repository implementations/contracts as finalized by foundation;
- Supabase Auth/Postgres/Storage services;
- SQLite services/outbox;
- browser draft adapter;
- DTO/domain mapping;
- synchronization and cache orchestration;
- no UI.

### `packages/ui`

- semantic design tokens/themes;
- shared fields/buttons/cards/banners/dialogs/statuses;
- rank asset resolver/progress primitives;
- responsive/list-detail/supporting-pane primitives;
- no feature authority or direct data client.

## Planned Supabase ownership by migration phase

| Phase | Data ownership |
|---|---|
| 002A | Profiles, preferences, capabilities, compatibility, identity audit |
| 003A | Muscles, exercise definitions, guidance drafts/revisions |
| 003B | Media metadata, private bucket/policies, YouTube references |
| 003C | Routine drafts, validation, submissions, reviews, versions |
| 004 | Weeks, plan items, snapshots, swaps, grants/credit ledger |
| 005A/B | Sessions, set entries, sync/submission/results, session guidance snapshots |
| 006 | Rank accounts, RR/XP ledgers, PRs, evaluations, milestones/finalization |
| 007 | Progression, substitutions, pain, protections, corrections |
| 008 | Export/lifecycle/operations hardening |

## Authority boundaries

- Supabase Auth owns credentials/sessions.
- Postgres owns authoritative product records.
- Storage owns private image bytes; Postgres owns media metadata.
- Widgets do not call storage/data services directly.
- Riverpod presentation depends on repository abstractions.
- Local mobile/browser data is private but non-authoritative.
- Published/materialized/finalized history is immutable.
- RR/XP/wallet changes are append-only transactions with exact reversals.
- RLS protects every exposed private relation/object.
- Security-definer functions are exceptional, hardened and explicitly granted.
- Service-role/management/deployment/backup secrets never enter Flutter clients.

## Fragile invariants

- `rank-v6`, `schedule-v3`, Adonis 5,500 RR and multiplier ladder;
- independent review and self-approval denial;
- seven materialized items and 4–6 workout-day eligibility;
- maximum two swaps and bankable two-credit monthly grant;
- authoritative online workout start and server finalization;
- pending local data cannot update authoritative rank UI;
- all rank assets/mapping remain stable;
- no historical recalculation using newer configuration;
- database backups do not include Storage bytes;
- preview/staging never use production identities/data/media.
