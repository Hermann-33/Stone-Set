# Stone Set Codebase Map

Updated: 2026-08-04

## Repository root

| Path | Responsibility |
|---|---|
| `README.md` | Entry point, phase, architecture summary, and next action |
| `AGENTS.md` | Mandatory human and agent rules |
| `docs/context/` | Current state, architecture, roadmap, workflow, plan, handoff, and audit history |
| `docs/product/` | Accepted product specifications and analyses |
| `docs/decisions/` | Accepted ADRs and decision index |
| `docs/tasks/` | Approved bounded implementation packets |

## Context documents

| Path | Responsibility |
|---|---|
| `docs/context/NEW_CHAT_BOOTSTRAP.md` | Repository-backed conversation loading prompt |
| `docs/context/ACTIVE_CONTEXT.md` | Present state, active decisions, boundaries, and next action |
| `docs/context/PROJECT_BRIEF.md` | Product purpose, users, outcomes, scope, and maturity |
| `docs/context/ARCHITECTURE.md` | Accepted target architecture, media, security, and operations |
| `docs/context/CODEBASE_MAP.md` | Canonical file and future module ownership |
| `docs/context/ROADMAP.md` | Phase state, gates, and implementation sequence |
| `docs/context/WORKFLOW.md` | Planning, task, verification, audit, and Git process |
| `docs/context/IMPLEMENTATION_PLAN.md` | Accepted phased implementation plan |
| `docs/context/HANDOFF.md` | Latest task result and exact continuation point |
| `docs/context/AUDIT_LOG.md` | Original historical audit volume through `TASK-WF-002` |
| `docs/context/AUDIT_LOG_CONTINUED.md` | Audit continuation beginning with `TASK-PD-008` |

## Product documents

| Path | Responsibility |
|---|---|
| `docs/product/HYPERTROPHY_ROUTINE.md` | Initial owner routine and training constraints |
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

## Approved task packets

| Path | Status |
|---|---|
| `docs/tasks/TASK-IMP-001.md` | Approved, not executed; foundation only |

## Application code and infrastructure

None. Phase 1 is ready but not started.

## Planned ownership after foundation

| Planned path | Responsibility |
|---|---|
| `apps/mobile/` | Android Flutter workout execution, guidance, media playback, and local recovery |
| `apps/dashboard/` | Flutter Web routine, exercise-library, guidance, image, and YouTube management |
| `packages/domain/` | Pure product rules, version identities, and models |
| `packages/data/` | Repository contracts, Supabase adapters, Storage adapters, and media references |
| `packages/ui/` | Shared tokens and limited reusable widgets |
| `config/` | Non-secret public-client configuration templates |
| `supabase/migrations/` | Versioned database schema, RLS, Storage policies, and server operations |
| `supabase/seed.sql` | Synthetic local-only seed data |
| `supabase/tests/` | Database, RLS, Storage, transaction, and idempotency tests |

## Planned product domains

| Domain | Responsibility |
|---|---|
| Identity | Auth linkage, profiles, units, timezone, and ownership |
| Exercise library | Stable user-owned exercise identities and clone behavior |
| Guidance revisions | Immutable text, muscles, image/video metadata, hashes, and history |
| Media storage | Private immutable image objects and access policies |
| Routine management | Reviewed reward-bearing prescriptions and workout-day summaries |
| Weekly planning | Materialized schedule, pinned guidance, allocations, locks, and swaps |
| Workout execution | Session start, timers, set logging, local draft, guidance cache, and sync |
| Rank and wallet | Immutable RR, XP, PR, consistency, penalty, and credit transactions |
| Operations | Environment isolation, database and Storage backups, restore, and access |

## Fragile boundaries

- Accepted ADR and audit history is preserved rather than rewritten.
- `rank-v6`, `schedule-v3`, Adonis at `5,500 RR`, and the multiplier ladder require explicit versioned decisions to change.
- Routine publication requires `routine-validator-v1` and independent approval.
- Guidance content is versioned separately; prescription or PR-comparability changes remain reviewed routine changes.
- Historical plans retain exact routine, guidance, validator, rank, and scheduling versions.
- Supabase Auth owns credentials; clients use publishable values only.
- Supabase Storage holds image bytes; Postgres holds authoritative media metadata and references.
- Database backups do not protect Storage object bytes.
- SQLite stores drafts and active-session guidance caches, not authoritative score state.
- Workout start and finalization remain server-authoritative.
- YouTube video is embedded, never downloaded or rewarded.
- Preview deployments cannot connect to production data or media.
- External projects and secrets require explicit implementation scope.
