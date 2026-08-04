# Stone Set Codebase Map

Updated: 2026-08-04

## Repository root

| Path | Responsibility |
|---|---|
| `README.md` | Repository entry point and maturity statement |
| `AGENTS.md` | Mandatory rules for humans and coding agents |
| `docs/context/` | Product, architecture, workflow, roadmap, status, handoff, audit context, and new-chat bootstrap |
| `docs/product/` | Accepted product-domain specifications and behavioral baselines |
| `docs/decisions/` | Architecture Decision Records and ADR guidance |

## Context documents

| Path | Responsibility |
|---|---|
| `docs/context/NEW_CHAT_BOOTSTRAP.md` | Reusable prompt that directs a new agent to load authoritative repository context before acting |
| `docs/context/ACTIVE_CONTEXT.md` | Current project state, verified facts, blockers, boundaries, and exact next action |
| `docs/context/HANDOFF.md` | Latest completed task, verification evidence, risks, and continuation point |

## Product-domain documents

| Path | Responsibility |
|---|---|
| `docs/product/HYPERTROPHY_ROUTINE.md` | Accepted limited-equipment hypertrophy routine, timing constraint, progression rules, and evidence basis |
| `docs/product/RANK_SYSTEM.md` | Accepted lifetime-XP, rank-RR, consistency, PR, swap-payment, missed-session, weekly evaluation, decay, calibration, and reversal rules |
| `docs/product/WEEKLY_SCHEDULING.md` | Accepted weekly schedule, two-swap limit, monthly free-swap wallet, grant and consumption rules, day locking, warnings, schedule integrity, swap records, and finalization rules |

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

## Active runtime

None.

## Fragile boundaries

- Repository context must remain internally consistent.
- `ACTIVE_CONTEXT.md` must represent the present rather than become a changelog.
- `NEW_CHAT_BOOTSTRAP.md` must direct agents to current repository facts rather than duplicate a full stale project summary.
- Accepted ADR history must not be rewritten.
- Accepted product-domain baselines must not be changed silently.
- Rank and scheduling configuration changes must be versioned and must not silently rewrite historical transactions.
- The scheduling specification owns day-exchange mechanics, free-swap grants, wallet state, and credit consumption.
- The rank specification owns RR consequences and score-facing swap-payment behavior.
- Product proposals must not be represented as implemented facts.
- Future code ownership must be added here when modules are introduced or responsibilities move.

## Do not touch without explicit scope

- authority order in `WORKFLOW.md`;
- completion rules in `AGENTS.md`;
- accepted ADR status or history;
- accepted workout-program constraints;
- accepted rank, RR, swap-limit, free-credit, and scheduling formulas;
- Git history, branch protection, secrets, external services, or destructive infrastructure.
