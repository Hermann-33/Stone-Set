# Stone Set Codebase Map

Updated: 2026-08-04

## Repository root

| Path | Responsibility |
|---|---|
| `README.md` | Repository entry point and maturity statement |
| `AGENTS.md` | Mandatory rules for humans and coding agents |
| `docs/context/` | Product, architecture, workflow, roadmap, status, handoff, and audit context |
| `docs/product/` | Accepted product-domain specifications and behavioral baselines |
| `docs/decisions/` | Architecture Decision Records and ADR guidance |

## Product-domain documents

| Path | Responsibility |
|---|---|
| `docs/product/HYPERTROPHY_ROUTINE.md` | Accepted limited-equipment hypertrophy routine, timing constraint, progression rules, and evidence basis |
| `docs/product/RANK_SYSTEM.md` | Accepted lifetime-XP, rank-RR, consistency, PR, swap-penalty, missed-session, weekly evaluation, decay, and reversal rules |
| `docs/product/WEEKLY_SCHEDULING.md` | Accepted weekly schedule, two-swap limit, day locking, recovery warnings, schedule integrity, swap records, and finalization rules |

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
- Accepted ADR history must not be rewritten.
- Accepted product-domain baselines must not be changed silently.
- Rank and scheduling configuration changes must be versioned and must not silently rewrite historical transactions.
- The scheduling specification owns day-exchange mechanics; the rank specification owns RR effects.
- Product proposals must not be represented as implemented facts.
- Future code ownership must be added here when modules are introduced or responsibilities move.

## Do not touch without explicit scope

- authority order in `WORKFLOW.md`;
- completion rules in `AGENTS.md`;
- accepted ADR status or history;
- accepted workout-program constraints;
- accepted rank, RR, swap-limit, and scheduling formulas;
- Git history, branch protection, secrets, external services, or destructive infrastructure.