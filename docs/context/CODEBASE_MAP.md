# Stone Set Codebase Map

Updated: 2026-08-05

## Repository root

| Path | Responsibility |
|---|---|
| `README.md` | Entry point, phase, architecture summary, and next action |
| `AGENTS.md` | Mandatory human and agent rules |
| `docs/context/` | Current state, architecture, roadmap, workflow, plan, handoff, and audit history |
| `docs/product/` | Accepted product specifications and analyses |
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
| `docs/context/ROADMAP.md` | Phase state, gates, and implementation sequence |
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
| `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md` | Android Home hierarchy, radial rank hero, authoritative/provisional display, motion, accessibility, responsive behavior, and staged integration |
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

No new ADR was required for the reversible mobile Home presentation decision in `TASK-PD-011`.

## Task packets

| Path | Status |
|---|---|
| `docs/tasks/TASK-IMP-001.md` | Approved, not executed; foundation only |
| `docs/tasks/TASK-ASSET-001.md` | Complete; curated assets only, no application integration |
| `docs/tasks/TASK-PD-011.md` | Complete; mobile Home and rank-progress planning only |
| `docs/tasks/TASK-IMP-002B.md` | Planned, blocked by `TASK-IMP-001` and `TASK-IMP-002A`; mobile design system, authenticated shell, and fixture-driven rank hero |

## Application code and infrastructure

No application code or external infrastructure. Supporting rank-emblem assets and accepted mobile-UI specifications exist; Phase 1 remains ready but not started.

## Planned ownership after foundation

| Planned path | Responsibility |
|---|---|
| `apps/mobile/` | Android login, authenticated shell, Home composition, week/history/profile routes, workout execution, guidance, media playback, and local recovery |
| `apps/dashboard/` | Web login, protected routing, routine, exercise-library, guidance, image, and YouTube management |
| `packages/domain/` | Pure identity, product rules, rank/schedule identities, version identities, and models |
| `packages/data/` | Auth, repository, Supabase, Storage, synchronization, and media adapters |
| `packages/ui/` | Shared tokens, rank-progress hero primitives, cards, chips, metrics, skeletons, and limited reusable widgets |
| `config/` | Non-secret public-client configuration, including internal auth alias domain |
| `supabase/migrations/` | Versioned profiles, RLS, product schema, Storage policies, and server operations |
| `supabase/seed.sql` | Synthetic local-only seed data |
| `supabase/tests/` | Auth linkage, database RLS, Storage, transaction, and idempotency tests |

## Planned mobile UI ownership

| Component/domain | Planned owner |
|---|---|
| `StoneSetTheme` and semantic UI tokens | `packages/ui/` |
| `RankProgressHero`, ring painter, emblem resolver, metric tiles | `packages/ui/` |
| immutable rank-progress presentation model | pure presentation/domain boundary, resolved during `TASK-IMP-002B` without backend authority |
| authenticated bottom-navigation shell | `apps/mobile/` |
| Home header, conditional status banner, today's card, week strip, composition, and animation orchestration | `apps/mobile/` |
| real weekly-plan binding | `TASK-IMP-004` through mobile/data/domain boundaries |
| real workout-state binding | `TASK-IMP-005A` through mobile/data/local-draft boundaries |
| authoritative rank snapshot and event binding | `TASK-IMP-006` through server/data/domain boundaries |

## Planned product domains

| Domain | Responsibility |
|---|---|
| Identity | Auth provisioning, username alias, login, session, password change, profiles, units, timezone, and ownership |
| Mobile presentation | Authenticated shell, Home hierarchy, rank-progress presentation, responsive/accessibility behavior, and fixture-to-real-data replacement boundaries |
| Exercise library | Stable user-owned exercise identities and clone behavior |
| Guidance revisions | Immutable text, muscles, image/video metadata, hashes, and history |
| Media storage | Private immutable image objects and access policies |
| Routine management | Reviewed reward-bearing prescriptions and workout-day summaries |
| Weekly planning | Materialized schedule, pinned guidance, allocations, locks, and swaps |
| Workout execution | Session start, timers, set logging, local draft, guidance cache, and sync |
| Rank and wallet | Immutable RR, XP, PR, consistency, penalty, and credit transactions |
| Operations | Environment isolation, Auth controls, database and Storage backups, restore, and access |

## Fragile boundaries

- Accepted ADR and audit history is preserved rather than rewritten.
- Supabase Auth owns passwords and sessions; application tables never store passwords.
- Both clients share accounts but maintain independent sessions.
- Login errors remain generic and no public username directory exists.
- Session expiry must not silently discard unsynchronized mobile workout data.
- The mobile rank hero is presentation only; it never awards RR or selects authoritative rank.
- Solid ring progress represents finalized authoritative RR; provisional and pending states remain distinct.
- `rank-v6`, `schedule-v3`, Adonis at `5,500 RR`, and the multiplier ladder require explicit versioned decisions to change.
- `stone-set-ranks-v1` filenames and mapping remain stable unless a later asset-version decision replaces them.
- Routine publication requires `routine-validator-v1` and independent approval.
- Guidance content is versioned separately; prescription or PR-comparability changes remain reviewed routine changes.
- Historical plans retain exact routine, guidance, validator, rank, and scheduling versions.
- Supabase Storage holds image bytes; Postgres holds authoritative media metadata and references.
- Database backups do not protect Storage object bytes.
- SQLite stores drafts and active-session guidance caches, not authoritative score state.
- Workout start and finalization remain server-authoritative.
- YouTube video is embedded, never downloaded or rewarded.
- Preview deployments cannot connect to production identities, data, or media.
- External projects and secrets require explicit implementation scope.
