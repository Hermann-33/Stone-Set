# Stone Set Codebase Map

Updated: 2026-08-04

## Repository root

| Path | Responsibility |
|---|---|
| `README.md` | Repository entry point and maturity statement |
| `AGENTS.md` | Mandatory rules for humans and coding agents |
| `docs/context/` | Current state, architecture, workflow process, roadmap, implementation plan, handoff, audit history, and bootstrap |
| `docs/product/` | Accepted product specifications plus clearly marked product proposals |
| `docs/decisions/` | Accepted Architecture Decision Records and ADR guidance |

## Context documents

| Path | Responsibility |
|---|---|
| `docs/context/NEW_CHAT_BOOTSTRAP.md` | Reusable prompt directing a new agent to authoritative repository context |
| `docs/context/ACTIVE_CONTEXT.md` | Present project state, accepted facts, proposals, blockers, boundaries, and exact next action |
| `docs/context/PROJECT_BRIEF.md` | Product purpose, users, scope, maturity, accepted outcomes, and discovery criteria |
| `docs/context/ARCHITECTURE.md` | Accepted planning architecture and explicit non-implemented state |
| `docs/context/IMPLEMENTATION_PLAN.md` | Documentation-only phased implementation sequence and task dependencies |
| `docs/context/ROADMAP.md` | Phase position and completion gates |
| `docs/context/WORKFLOW.md` | Operating, decision, implementation, verification, Git, and handoff process |
| `docs/context/HANDOFF.md` | Latest task result, evidence, risks, and continuation point |
| `docs/context/AUDIT_LOG.md` | Historical material findings and verdicts |

## Product-domain documents

| Path | Responsibility | Status |
|---|---|---|
| `docs/product/HYPERTROPHY_ROUTINE.md` | Limited-equipment five-session hypertrophy routine, 60-minute cap, progression, and evidence basis | Accepted |
| `docs/product/RANK_SYSTEM.md` | Current lifetime-XP, rank-RR, consistency, PR, penalty, decay, calibration, and reversal rules | Accepted as `rank-v5` |
| `docs/product/WEEKLY_SCHEDULING.md` | Current fixed weekly schedule, swaps, free-credit wallet, locking, records, and finalization | Accepted as `schedule-v2` |
| `docs/product/APPLICATION_WORKFLOW.md` | Planned mobile, dashboard, routine, workout, reward, finalization, progression, and correction workflow | Proposed |
| `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md` | Proposed user-specific routines, normalized daily RR, rest-day rewards, penalty allocation, PR cap, and anti-gaming model | Proposed as `rank-v6` / `schedule-v3` |

## Decision records

| Path | Responsibility | Status |
|---|---|---|
| `docs/decisions/ADR-0001-flutter-client-platforms.md` | Flutter mobile and Flutter Web client architecture | Accepted |
| `docs/decisions/ADR-0002-supabase-backend-auth-and-persistence.md` | Supabase Auth, Postgres, RLS, credential, and persistence architecture | Accepted |

## Planned application paths

The following paths are planning targets only and do not exist yet:

| Planned path | Planned responsibility |
|---|---|
| `apps/mobile/` | Flutter mobile application |
| `apps/dashboard/` | Flutter Web routine-management dashboard |
| `packages/domain/` | Shared pure domain models and validation |
| `packages/data/` | Repository contracts and Supabase adapters |
| `packages/ui/` | Shared design tokens and selected reusable widgets |
| `supabase/migrations/` | Versioned database migrations |
| `supabase/tests/` | Database, RLS, transaction, and idempotency tests |

## Application code

None.

## Tests

None.

The Monte Carlo figures in the proposed daily-RR document are planning evidence, not an application test suite.

## Build and configuration

None.

## Data and migrations

None.

No Supabase project, local configuration, schema, table, function, policy, grant, account, or credential exists in the repository.

## Deployments and infrastructure

None.

## Active runtime

None.

## Ownership boundaries

- `RANK_SYSTEM.md` owns accepted rank and RR behavior.
- `WEEKLY_SCHEDULING.md` owns accepted schedule, swap, and free-credit behavior.
- Product proposals do not supersede accepted baselines until explicitly activated.
- `ARCHITECTURE.md` owns the accepted current target architecture.
- ADRs own durable architecture rationale and supersession history.
- `IMPLEMENTATION_PLAN.md` owns planned sequencing, not current implementation facts.
- Future database functions must own authoritative reward transitions; Flutter clients must not own final RR totals.
- Supabase Auth owns passwords and sessions; public application tables do not.

## Fragile boundaries

- Repository context must remain internally consistent.
- `ACTIVE_CONTEXT.md` represents the present, not a changelog.
- Accepted ADR history must not be rewritten.
- Planned paths must not be represented as existing code.
- Accepted product baselines must not be changed silently.
- Rank and scheduling changes require new configuration versions and migration rules.
- Historical routine versions and ledger transactions must remain immutable.
- Product proposals must not be represented as accepted or implemented behavior.
- User data isolation must be enforced in the database, not only in the UI.
- Service-role and secret keys must never enter public clients or Git history.

## Do not touch without explicit scope

- authority order in `WORKFLOW.md`;
- completion rules in `AGENTS.md`;
- accepted ADR status or history;
- accepted workout-program constraints;
- accepted `rank-v5` and `schedule-v2` formulas;
- the `5,500 RR` Adonis threshold and multiplier ladder;
- Git history, secrets, production accounts, external services, or destructive infrastructure;
- proposed `rank-v6` or `schedule-v3` activation before its required audit.
