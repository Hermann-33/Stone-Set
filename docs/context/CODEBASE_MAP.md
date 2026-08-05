# Stone Set Codebase Map

Updated: 2026-08-05

## Repository root

| Path | Responsibility |
|---|---|
| `README.md` | Entry point, phase, architecture summary, and next action |
| `AGENTS.md` | Mandatory human and agent rules |
| `docs/context/` | Current state, architecture, roadmaps, workflows, plans, handoff, and audit history |
| `docs/product/` | Accepted product and UI/UX specifications and analyses |
| `docs/decisions/` | Accepted ADRs and decision index |
| `docs/tasks/` | Approved, completed, and planned bounded packets |
| `assets/ranks/` | Curated textless `rank-v6` PNG masters, mapping manifest, provenance, and review sheet |
| `tools/generate_rank_assets.py` | Reproducible CC0 source retrieval, rank-emblem generation, metadata, and validation |

## Context documents

| Path | Responsibility |
|---|---|
| `docs/context/NEW_CHAT_BOOTSTRAP.md` | Repository-backed conversation loading prompt |
| `docs/context/ACTIVE_CONTEXT.md` | Present state, active decisions, boundaries, and next action |
| `docs/context/PROJECT_BRIEF.md` | Product purpose, users, outcomes, scope, and maturity |
| `docs/context/ARCHITECTURE.md` | Accepted target architecture, authentication, media, security, and operations |
| `docs/context/CODEBASE_MAP.md` | Canonical file and future module ownership |
| `docs/context/ROADMAP.md` | Product phase state, gates, and implementation sequence |
| `docs/context/UI_IMPLEMENTATION_PLAN.md` | Complete Android, dashboard, and shared-design-system UI workstream |
| `docs/context/WORKFLOW.md` | Planning, task, verification, audit, and Git process |
| `docs/context/IMPLEMENTATION_PLAN.md` | Accepted phased implementation plan |
| `docs/context/HANDOFF.md` | Latest task result and exact continuation point |
| `docs/context/AUDIT_LOG.md` | Original historical audit volume through `TASK-WF-002` |
| `docs/context/AUDIT_LOG_CONTINUED.md` | Audit continuation from `TASK-PD-008` through `TASK-ASSET-001` |
| `docs/context/AUDIT_LOG_CONTINUED_2.md` | Audit continuation beginning with `TASK-PD-011` |

## Product documents

| Path | Responsibility |
|---|---|
| `docs/product/HYPERTROPHY_ROUTINE.md` | Initial owner routine and training constraints |
| `docs/product/AUTHENTICATION_AND_SESSION_UX.md` | Mobile and dashboard login, provisioning, sessions, logout, expiry, and recovery UX |
| `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md` | Android Home hierarchy, full-circle rank hero, authoritative/provisional display, motion, accessibility, responsive behavior, and staged integration |
| `docs/product/COMPLETE_UI_UX_SYSTEM.md` | Complete Android app, dashboard, shared design system, screen inventory, states, accessibility, and cross-surface interaction baseline |
| `docs/product/ROUTINE_ELIGIBILITY.md` | Reward-eligible routine validator, peer review, and anti-triviality controls |
| `docs/product/EXERCISE_GUIDANCE_AND_MEDIA.md` | Workout explanations, exercise content, muscles, images, YouTube, versioning, offline behavior, and media recovery |
| `docs/product/RANK_SYSTEM.md` | Canonical `rank-v6` economy |
| `docs/product/WEEKLY_SCHEDULING.md` | Canonical `schedule-v3` routine versioning, weekly plans, swaps, wallet, and locks |
| `docs/product/APPLICATION_WORKFLOW.md` | Accepted end-to-end workflow |
| `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md` | Accepted rank-normalization analysis |

## Decisions

| Path | Responsibility |
|---|---|
| `ADR-0001` | Flutter mobile/Web clients and shared Dart packages |
| `ADR-0002` | Supabase Auth/Postgres, RLS, credentials, and server authority |
| `ADR-0003` | SQLite drafts, online start, outbox sync, and online finalization |
| `ADR-0004` | Android-first release and Vercel dashboard hosting |
| `ADR-0005` | Supabase environments, access, backup, and recovery |
| `ADR-0006` | Private exercise-image Storage, media recovery, and YouTube embedding |

No new ADR was required for `TASK-PD-011` or `TASK-PD-012`; both are reversible product-interface decisions inside the accepted Flutter/Supabase architecture.

## Task packets

| Path | Status |
|---|---|
| `docs/tasks/TASK-IMP-001.md` | Approved, not executed; foundation only |
| `docs/tasks/TASK-ASSET-001.md` | Complete; curated assets only, no application integration |
| `docs/tasks/TASK-PD-011.md` | Complete; Home and rank-progress planning only |
| `docs/tasks/TASK-PD-012.md` | Complete; full app/dashboard UI research and planning only |
| `docs/tasks/TASK-IMP-002B.md` | Planned, blocked by `TASK-IMP-001` and `TASK-IMP-002A`; shared design system, authenticated mobile shell, fixture-driven Home and rank hero; amend `History` to `Progress` before approval |
| `docs/tasks/TASK-IMP-002C.md` | Planned, blocked by foundation/authentication/shared tokens; responsive dashboard shell and fixture-driven Overview |

## Application code and infrastructure

No application code or external infrastructure. Supporting rank assets and accepted complete UI/UX specifications exist; Phase 1 remains ready but not started.

## Planned ownership after foundation

| Planned path | Responsibility |
|---|---|
| `apps/mobile/` | Android login, authenticated Home/Week/Progress/Profile shell, workout execution, guidance, results, progress/history, settings, and local recovery |
| `apps/dashboard/` | Responsive web login, Overview, routine/exercise/guidance/review/activity/settings routes, editors, search, command palette, and media management |
| `packages/domain/` | Pure identity, product rules, rank/schedule identities, immutable view data, version identities, and models |
| `packages/data/` | Auth, repository, Supabase, Storage, synchronization, export, and media adapters |
| `packages/ui/` | Shared semantic tokens, themes, navigation primitives, cards, inputs, errors, panes, charts, rank hero, editor primitives, and accessibility behavior |
| `config/` | Non-secret public-client configuration, including internal auth alias domain |
| `supabase/migrations/` | Versioned profiles, RLS, product schema, Storage policies, export support, and server operations |
| `supabase/seed.sql` | Synthetic local-only seed data |
| `supabase/tests/` | Auth linkage, database RLS, Storage, transaction, idempotency, and export-isolation tests |

## Planned mobile UI ownership

| Component/domain | Planned owner |
|---|---|
| semantic themes, typography, spacing, state colors, inputs, cards, errors, charts | `packages/ui/` |
| rank-progress hero, ring painter, emblem resolver, metric tiles | `packages/ui/` |
| immutable UI presentation models | pure domain/presentation boundaries; no backend authority |
| authenticated Home/Week/Progress/Profile navigation shell | `apps/mobile/` |
| Home composition, status banners, today's card, week strip, rank animation orchestration | `apps/mobile/` |
| Week schedule, item detail, swap UI | `TASK-IMP-004` through mobile/data/domain boundaries |
| workout overview, active logger, rest timer, set rows, draft/sync presentation | `TASK-IMP-005A` through mobile/data/local-draft boundaries |
| exercise guidance and media playback | `TASK-IMP-005B` |
| calendar/list history, exercise charts, rank/wallet ledger | `TASK-IMP-006` |
| progression, substitution, protection, correction UI | `TASK-IMP-007` |

## Planned dashboard UI ownership

| Component/domain | Planned owner |
|---|---|
| drawer/rail/sidebar shell, Overview, search, command palette, shortcuts | `TASK-IMP-002C` in `apps/dashboard/` plus shared primitives in `packages/ui/` |
| adaptive exercise list-detail and structured guidance editor | `TASK-IMP-003A` |
| media upload, alt text, ordering, YouTube preview, mobile preview | `TASK-IMP-003B` |
| routine library, three-pane editor, validator summary, review diff, version history | `TASK-IMP-003C` |
| activity/audit views | feature packets that create the underlying events; full hardening in `TASK-IMP-008` |
| user-owned data export settings and download flow | `TASK-IMP-008` unless earlier explicitly approved |

## Planned product domains

| Domain | Responsibility |
|---|---|
| Identity | Auth provisioning, username alias, login, session, password change, profiles, units, timezone, and ownership |
| Shared presentation | Semantic design tokens, adaptive navigation, accessibility, state patterns, motion, validation, search, command, and responsive components |
| Mobile presentation | Home, Week, Progress, Profile, workout logging, guidance, results, and recovery |
| Dashboard presentation | Attention-first Overview, authoring, review, history, activity, and settings workflows |
| Exercise library | Stable user-owned exercise identities and clone behavior |
| Guidance revisions | Immutable text, muscles, image/video metadata, hashes, and history |
| Media storage | Private immutable image objects and access policies |
| Routine management | Reviewed reward-bearing prescriptions and workout-day summaries |
| Weekly planning | Materialized schedule, pinned guidance, allocations, locks, and swaps |
| Workout execution | Session start, timers, set logging, local draft, guidance cache, and sync |
| Rank and wallet | Immutable RR, XP, PR, consistency, penalty, and credit transactions |
| Export | User-owned portable data package with strict ownership and secret exclusion |
| Operations | Environment isolation, Auth controls, database and Storage backups, restore, and access |

## Fragile boundaries

- Accepted ADR and audit history is preserved rather than rewritten.
- Supabase Auth owns passwords and sessions; application tables never store passwords.
- Both clients share accounts but maintain independent sessions.
- Login errors remain generic and no public username directory exists.
- Session expiry must not silently discard unsynchronized mobile workout data.
- The UI never awards RR, selects authoritative rank, publishes routines, approves reviews, or finalizes workouts client-side.
- Solid ring progress represents finalized authoritative RR; provisional and pending states remain distinct.
- Previous/best performance shown in the logger must use accepted comparable-context rules.
- `rank-v6`, `schedule-v3`, Adonis at `5,500 RR`, and the multiplier ladder require explicit versioned decisions to change.
- `stone-set-ranks-v1` filenames and mapping remain stable unless a later asset-version decision replaces them.
- Routine publication requires `routine-validator-v1` and independent approval.
- Guidance content is versioned separately; prescription or PR-comparability changes remain reviewed routine changes.
- Historical plans retain exact routine, guidance, validator, rank, and scheduling versions.
- Published history is immutable; restore produces a new draft.
- Supabase Storage holds image bytes; Postgres holds authoritative media metadata and references.
- Database backups do not protect Storage object bytes.
- SQLite stores drafts and active-session guidance caches, not authoritative score state.
- Workout start and finalization remain server-authoritative.
- YouTube video is embedded, never downloaded or rewarded.
- Search, command palette, exports, and fixtures may never bypass RLS or expose another user's private data.
- Preview deployments cannot connect to production identities, data, or media.
- External projects and secrets require explicit implementation scope.
