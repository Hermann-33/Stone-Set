# Stone Set Codebase Map

Updated: 2026-08-11

## Current repository

| Path | Responsibility |
|---|---|
| `README.md` | Project state, pinned prerequisites and root setup/verification commands |
| `AGENTS.md` | Mandatory repository/agent rules |
| `pubspec.yaml` / `pubspec.lock` | Native Dart workspace membership and exact shared dependency resolution |
| `analysis_options.yaml` | Shared strict Dart/Flutter analysis policy and Riverpod analysis-server plugin pin |
| `package.json` / `package-lock.json` | Exact project-local Supabase CLI installation |
| `tool/tool_versions.json` | Machine-readable Flutter, Dart, Node.js and Supabase CLI pins |
| `bin/stone_set.dart` / `lib/src/tooling/` | Cross-platform root restore, canonical-rank staging, check, test, build and local Supabase commands |
| `apps/mobile/` | Android identity/session, four-branch shell, Home/rank, Week/swaps, active workout/guidance, Progress/progression and Profile presentation; TASK-IMP-009 visual modernization merged |
| `apps/dashboard/` | Web identity/session, adaptive shell, exercise/guidance/media and routine authoring, and production dashboard workflows |
| `packages/domain/` | Pure Dart product models, canonicalization and repository contracts shared by both clients |
| `packages/data/` | Supabase repository/service/error implementations depending on `domain` |
| `packages/ui/` | Shared accessible Auth, semantic themes/components, mobile visual tokens, rank presentation and responsive dashboard primitives |
| `config/` | Non-secret public-client configuration example and usage boundary |
| `supabase/config.toml` | Local Auth configuration with public/anonymous signup disabled and private `exercise-media` bucket limits |
| `supabase/migrations/20260806000100_identity_sessions.sql` | Verified local 002A identity/session schema, RLS, RPC and operator functions |
| `supabase/migrations/20260807104329_exercise_guidance.sql` | Verified local 003A muscle/exercise/guidance schema, grants, RLS, immutable revisions and narrow RPCs |
| `supabase/migrations/20260808134609_exercise_media_youtube.sql` | Exercise-media metadata, upload intents, immutable manifests, Storage policies and narrow RPCs |
| `supabase/migrations/20260811045337_authoritative_consistency_multiplier.sql` | TASK-IMP-010 server-owned base multiplier and progress payload contract |
| `supabase/migrations/20260811060051_create_guidance_media_draft_from_revision_v1.sql` | TASK-IMP-011 atomic owner-scoped editable guidance/media draft materialization |
| `supabase/seed.sql` | Synthetic local compatibility seed only |
| `supabase/tests/` | Auth checks plus identity, guidance and 003B media schema/security/Storage integration coverage |
| `tool/operator/` | Trusted Node operator CLI, dry-run boundary and tests; excluded from clients |
| `.github/workflows/foundation-ci.yml` | Repository, generated source, Flutter/Dart, Linux mobile/dashboard goldens, browser/build/bundle, API 24 and local Supabase gates |
| `.github/workflows/private-release.yml` | Trusted post-CI permanent-signed Android verification and private Firebase App Distribution |
| `docs/security/Stone-Set-threat-model.md` | Bounded Auth/session/guidance/media/Storage/YouTube threat model and residual risks |
| `docs/context/` | Current architecture, technology, data, roadmap, implementation, handoff and audit state |
| `docs/product/` | Accepted user/product behavior and UI specifications |
| `docs/decisions/` | Accepted ADRs |
| `docs/tasks/` | Completed/planned/approved bounded packets |
| `assets/ranks/` | Single canonical source for 20 textless rank-v6 PNG assets, manifest/provenance/review |
| `tools/generate_rank_assets.py` | Reproducible rank asset generation/verification |

`main` contains every merged engineering implementation through TASK-IMP-011 and the minimal private release.
The production dashboard is hosted on Vercel and both clients use the single hosted Supabase
project recorded in `ACTIVE_CONTEXT.md`. Historical merge evidence remains in the task packets and
append-only audit. `TASK-IMP-010` is complete; TASK-IMP-011 engineering/deployment is complete and
its only remaining gate is approved media content.

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
| `TASK-IMP-002A` | Complete and merged through PR #7 | Identity, sessions, profiles, RLS and trusted operator tooling |
| `TASK-IMP-002B` | Complete and merged through PR #10 | Shared UI, Android shell/Home/rank hero |
| `TASK-IMP-002C` | Complete and merged through PR #12 | Fixture-only dashboard shell/Overview/search/productivity primitives |
| `TASK-IMP-003A` | Complete and merged through PR #14 | Exercise/guidance persistence, editor, immutable publication and browser recovery |
| `TASK-IMP-003B` | Complete and merged | Private exercise media and YouTube |
| `TASK-IMP-003C` | Complete and merged; review lifecycle later retired | Routine authoring and direct owner publication |
| `TASK-IMP-004` | Complete and merged | Weeks, allocations, locks, swaps and grants |
| `TASK-IMP-005A/B` | Complete and merged | Workout logger/sync; guidance/media playback |
| `TASK-IMP-006` | Complete and merged | Rank/XP/wallet/Progress/finalization |
| `TASK-IMP-007` | Complete and merged | Progression/protection/corrections |
| `TASK-IMP-008` | Complete and merged | Minimal private release |
| `TASK-IMP-009` | Complete and merged through PR #31 at `e59303d5acd4dbfe6706822b100913c531dc9297` | Android visual system, accessibility and event-driven motion modernization |
| `TASK-IMP-010` | Complete; code merged through PR #34 and production migration verified | Authoritative base consistency multiplier and Home fixture-leak correction |
| `TASK-IMP-011` | Partial; engineering/deployment complete, approved content pending | Exercise-detail media integration, atomic draft materialization and approved content population |
| `TASK-IMP-012` | Approved; implementation candidate in progress | Permanent Android signing and private automatic distribution |

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

Verified 002A identity sources and the 002B fixture presentation sources occupy these
application/package paths. Later product responsibilities below remain future ownership and must
not be read as implemented behavior.

## Planned package ownership

### `apps/mobile`

- native authentication screens (implemented and merged);
- go_router stateful Home/Week/Progress/Profile shell (implemented and merged through PR #10);
- fixture Home composition/rank hero orchestration (implemented and merged through PR #10);
- Week/swap UI;
- workout overview/logger/guidance/result;
- notifications/platform lifecycle;
- SQLite/outbox/cache/recovery integration;
- Android-specific routing and release configuration.

### `apps/dashboard`

- responsive authentication (implemented and merged through PR #7);
- typed go_router guarded path URLs and adaptive drawer/rail/sidebar shell (merged through PR #12);
- deterministic fixture Overview, search, command palette, shortcut help, themes, status surfaces
  and gallery (merged through PR #12);
- exercise/guidance authoring (003A merged) and media/YouTube authoring (003B candidate);
- routine/review persistence and authoring (planned only);
- placeholder fixture routes for Routines/Exercises/Reviews/Activity/Settings (implemented on
  `TASK-IMP-002C` without product persistence);
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

- semantic design tokens/themes (implemented and merged through PR #10);
- shared fields/buttons/cards/banners/dialogs/statuses (bounded set merged through PR #10);
- rank asset resolver/progress primitives (implemented and merged through PR #10);
- responsive/list-detail/supporting-pane/filter/toolbar/state/validation/confirmation/reorder
  primitives (merged through PR #12);
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

Implemented 003A ownership is split across
`supabase/migrations/20260807104329_exercise_guidance.sql`,
`packages/domain/lib/src/exercise_guidance/`, `packages/data/lib/src/exercise_guidance/` and
`apps/dashboard/lib/src/features/exercises/`. Dashboard recovery is implemented by
`dashboard_guidance_draft_cache.dart`; the fixed taxonomy, grants, RLS and RPC authority remain in
the migration. `tool/ci/change-classifier.mjs` and its Node tests own fail-closed path selection for
the foundation workflow.

The 003B candidate adds `packages/domain/lib/src/exercise_media/`,
`packages/data/lib/src/exercise_media/`, dashboard media controller/processor/editor/IFrame views,
`20260808134609_exercise_media_youtube.sql`, private bucket configuration and focused database/
Storage tests. Final-head CI and merge remain required before these are recorded as complete.

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
