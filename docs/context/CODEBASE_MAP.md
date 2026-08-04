# Stone Set Codebase Map

Updated: 2026-08-04

## Repository root

| Path | Responsibility |
|---|---|
| `README.md` | Repository entry point, active phase, and implementation boundary |
| `AGENTS.md` | Mandatory operating rules for humans and agents |
| `docs/context/` | Current state, architecture, workflow, roadmap, plan, handoff, and audit history |
| `docs/product/` | Accepted product specifications and supporting analyses |
| `docs/decisions/` | Accepted architecture decisions and ADR guidance |

## Context documents

| Path | Responsibility |
|---|---|
| `docs/context/NEW_CHAT_BOOTSTRAP.md` | Repository-backed new-conversation loading prompt |
| `docs/context/ACTIVE_CONTEXT.md` | Present state, active configurations, blockers, boundaries, and next action |
| `docs/context/PROJECT_BRIEF.md` | Product purpose, users, accepted outcomes, scope, and maturity |
| `docs/context/ARCHITECTURE.md` | Accepted planning architecture and security boundaries |
| `docs/context/CODEBASE_MAP.md` | Canonical file and future module ownership |
| `docs/context/ROADMAP.md` | Phase position, gates, and completion criteria |
| `docs/context/WORKFLOW.md` | Planning, decision, implementation, verification, and Git process |
| `docs/context/IMPLEMENTATION_PLAN.md` | Planned phased implementation sequence and task boundaries |
| `docs/context/HANDOFF.md` | Latest task result, risks, verdict, and exact next action |
| `docs/context/AUDIT_LOG.md` | Historical material findings and verdicts |

## Product documents

| Path | Responsibility |
|---|---|
| `docs/product/HYPERTROPHY_ROUTINE.md` | Accepted initial limited-equipment five-session routine and training rules |
| `docs/product/RANK_SYSTEM.md` | Canonical `rank-v6` RR, XP, daily allocation, PR, consistency, penalty, decay, and reversal rules |
| `docs/product/WEEKLY_SCHEDULING.md` | Canonical `schedule-v3` routine versioning, weekly plans, swaps, wallet, locks, and finalization rules |
| `docs/product/APPLICATION_WORKFLOW.md` | Accepted end-to-end mobile, dashboard, and backend workflow |
| `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md` | Accepted supporting analysis and calibration behind `rank-v6` and `schedule-v3` |

## Decisions

| Path | Responsibility |
|---|---|
| `docs/decisions/ADR-0001-flutter-client-platforms.md` | Flutter mobile, Flutter Web, and shared Dart package decision |
| `docs/decisions/ADR-0002-supabase-backend-auth-and-persistence.md` | Supabase Auth/Postgres, RLS, password, and server-authority decision |
| `docs/decisions/README.md` | ADR rules and accepted-decision index |

## Application code

None.

## Tests

None.

## Build and configuration

None.

## Data and migrations

None.

## Deployments and infrastructure

None.

## Planned ownership after foundation

| Planned path | Responsibility |
|---|---|
| `apps/mobile/` | Flutter workout-execution client |
| `apps/dashboard/` | Flutter Web routine-management client |
| `packages/domain/` | Pure product rules and models |
| `packages/data/` | Repository contracts and Supabase adapters |
| `packages/ui/` | Shared design tokens and reusable widgets |
| `supabase/migrations/` | Versioned schema and database behavior |
| `supabase/tests/` | RLS, allocation, transaction, idempotency, and ledger verification |

These paths do not exist yet.

## Fragile boundaries

- Repository authority and current-state documents must remain synchronized.
- Accepted ADR history must not be rewritten.
- `rank-v6` and `schedule-v3` changes require new configuration versions.
- Historical transactions must retain stored values and configuration versions.
- Routine publication cannot rewrite active or historical weeks.
- Rank specification owns RR, XP, PR, penalty, consistency, and decay economics.
- Scheduling specification owns routine versions, weekly materialization, swaps, wallet state, and locks.
- Application workflow owns user-facing state transitions.
- Supabase Auth owns credentials; application tables never store passwords.
- Clients cannot authoritatively set rank or wallet state.
- Product proposals must not be represented as implemented facts.

## Do not touch without explicit scope

- authority order in `WORKFLOW.md`;
- completion rules in `AGENTS.md`;
- accepted ADR status or history;
- Adonis at `5,500 RR`;
- the 5/10/15 multiplier ladder;
- `rank-v6` pools, weights, penalty pool, and weekly PR cap;
- `schedule-v3` routine-frequency, swap-limit, wallet, and locking rules;
- secrets, credentials, Git history, external services, or destructive infrastructure.