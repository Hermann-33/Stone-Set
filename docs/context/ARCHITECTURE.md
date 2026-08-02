# Stone Set Current Architecture

Updated: 2026-08-03
Status: No application architecture accepted

## Current implemented system

```text
GitHub repository
  -> governance and context Markdown
  -> future planning and decision records
  -> future bounded implementation tasks
```

There is no application runtime or technical architecture yet.

## Active repository components

- `README.md`: repository entry point and current maturity statement
- `AGENTS.md`: mandatory operating rules for developers and coding agents
- `docs/context/`: durable and current project context
- `docs/decisions/`: accepted decision records and ADR guidance

## Runtime

None.

## Client applications

None.

## APIs and services

None.

## Persistence and external state

None.

## Authentication and authorization

None selected or implemented.

## External integrations

None selected or implemented.

## Deployment

None selected or implemented.

## Current architectural boundaries

- Do not infer a stack from the repository name or personal-project status.
- Do not create code scaffolding before product requirements and platform constraints are documented.
- Do not treat a discussed option as accepted architecture.
- Architecture proposals must identify trade-offs, operational burden, privacy impact, cost, reversibility, and migration risk.
- Durable architecture choices require an accepted ADR before implementation.

## Required architecture decision sequence

1. Define the product problem and primary workflow.
2. Define platform, connectivity, persistence, privacy, cost, and maintenance constraints.
3. Compare viable architecture options against those constraints.
4. Record accepted choices in ADRs.
5. Update this file to describe the accepted current system.
6. Create the first bounded implementation task.

## Deferred architecture

All application architecture is deferred until discovery establishes enough evidence to choose it responsibly.
