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
| `docs/context/ARCHITECTURE.md` | Accepted target architecture and operational boundaries |
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

## Approved task packets

| Path | Status |
|---|---|
| `docs/tasks/TASK-IMP-001.md` | Approved, not executed |

## Application code and infrastructure

None. Phase 1 is ready but not started.

## Planned ownership after foundation

| Planned path | Responsibility |
|---|---|
| `apps/mobile/` | Android Flutter workout-execution client |
| `apps/dashboard/` | Flutter Web routine-management client |
| `packages/domain/` | Pure product rules and models |
| `packages/data/` | Repository contracts and adapters |
| `packages/ui/` | Shared tokens and limited reusable widgets |
| `config/` | Non-secret public-client configuration templates |
| `supabase/migrations/` | Versioned database schema and behavior |
| `supabase/tests/` | Database, RLS, transaction, and idempotency tests |

## Fragile boundaries

- Accepted ADR and audit history is preserved rather than rewritten.
- `rank-v6`, `schedule-v3`, Adonis at `5,500 RR`, and the multiplier ladder require explicit versioned decisions to change.
- Routine publication requires `routine-validator-v1` and independent approval.
- Historical plans retain exact routine, validator, rank, and scheduling versions.
- Supabase Auth owns credentials; clients use publishable values only.
- SQLite stores drafts, not authoritative score state.
- Workout start and finalization remain server-authoritative.
- Preview deployments cannot connect to production data.
- External projects and secrets require explicit implementation scope.
