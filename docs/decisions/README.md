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

## Current accepted decisions

| ADR | Decision | Status |
|---|---|---|
| `ADR-0001-flutter-client-platforms.md` | Separate Flutter mobile and Flutter Web clients with shared Dart packages | Accepted |
| `ADR-0002-supabase-backend-auth-and-persistence.md` | Hosted Supabase Auth and Postgres with RLS and no application-table password storage | Accepted |
| `ADR-0003-local-workout-drafts-and-online-finalization.md` | SQLite local workout drafts, online session start, outbox synchronization, and server-authoritative finalization | Accepted |
| `ADR-0004-android-first-and-vercel-dashboard-hosting.md` | Android-first mobile release and Vercel-hosted static Flutter Web dashboard | Accepted |
| `ADR-0005-supabase-production-operations-and-recovery.md` | Separate environments, Pro daily backups, encrypted logical exports, MFA, least privilege, and restore drills | Accepted |

These ADRs authorize architecture and bounded implementation planning. External project creation, credentials, production deployment, and product feature implementation require an explicit approved task packet.

## Template

```markdown
# ADR-XXXX: Decision title

## Status

Proposed | Accepted | Superseded | Rejected | Deprecated

- Date: YYYY-MM-DD
- Type:
- Supersedes:
- Preserves:

## Context

## Decision criteria

## Options considered

## Decision

## Consequences

## Security, privacy, data, and operational impact

## Scope boundaries

## Rollback or supersession rule

## Activation evidence
```
