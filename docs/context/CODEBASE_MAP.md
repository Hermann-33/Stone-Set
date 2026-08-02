# Stone Set Codebase Map

Updated: 2026-08-03

## Repository root

| Path | Responsibility |
|---|---|
| `README.md` | Repository entry point and maturity statement |
| `AGENTS.md` | Mandatory rules for humans and coding agents |
| `docs/context/` | Product, architecture, workflow, roadmap, status, handoff, and audit context |
| `docs/decisions/` | Architecture Decision Records and ADR guidance |

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
- Product proposals must not be represented as implemented facts.
- Future code ownership must be added here when modules are introduced or responsibilities move.

## Do not touch without explicit scope

- authority order in `WORKFLOW.md`;
- completion rules in `AGENTS.md`;
- accepted ADR status or history;
- Git history, branch protection, secrets, external services, or destructive infrastructure.
