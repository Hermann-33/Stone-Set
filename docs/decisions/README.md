# Stone Set Architecture Decision Records

This directory stores durable accepted decisions. It must not be used as a dumping ground for brainstorming.

## Status values

- `Proposed`
- `Accepted`
- `Superseded`
- `Rejected`
- `Deprecated`

## Naming

```text
ADR-0001-short-decision-title.md
ADR-0002-short-decision-title.md
```

Use sequential numbers. Never reuse a number or rewrite accepted history to make a later decision look original.

## ADR trigger

Create an ADR before durable changes to architecture, public contracts, persistence ownership, authentication, authorization, material security or privacy controls, external services, deployment, or repository governance.

## ADR template

```markdown
# ADR-XXXX: Decision title

## Status

Proposed | Accepted | Superseded | Rejected | Deprecated

- Date: YYYY-MM-DD
- Type:
- Supersedes:
- Preserves:

## Context

What concrete problem, constraint, or conflict requires a durable decision?

## Decision criteria

What factors determine the correct choice?

## Options considered

### Option A

### Option B

### Option C

## Decision

What exactly is authorized?

## Consequences

What becomes easier, harder, safer, more expensive, or less reversible?

## Security, privacy, data, and operational impact

## Scope boundaries

What does this decision not authorize?

## Rollback or supersession rule

## Activation evidence

Which task, commit, tests, migration, or deployment activated the decision?
```

## Current accepted decisions

| ADR | Decision | Status |
|---|---|---|
| `ADR-0001-flutter-client-platforms.md` | Separate Flutter mobile and Flutter Web clients with shared Dart domain and data packages | Accepted |
| `ADR-0002-supabase-backend-auth-and-persistence.md` | Hosted Supabase Auth and Postgres with RLS and no application-table password storage | Accepted |

These ADRs authorize planning architecture only. They do not authorize scaffolding, Supabase project creation, schema changes, credentials, deployment, or activation of the proposed `rank-v6` and `schedule-v3` product changes.
