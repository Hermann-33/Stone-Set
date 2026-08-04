# Stone Set Current Architecture

Updated: 2026-08-04
Status: `ACCEPTED PLANNING ARCHITECTURE — NOT IMPLEMENTED`

## Current implemented system

```text
GitHub repository
  -> governance and context Markdown
  -> accepted product specifications
  -> accepted architecture decisions
  -> implementation plan
```

There is no application runtime, database, authentication system, infrastructure, or deployment.

## Accepted target system

```text
Flutter mobile application
  -> workout execution, schedule, swaps, rank, history

Flutter Web dashboard
  -> user-owned routine drafting and publication

Shared Dart packages
  -> domain models, validation, repositories, adapters

Supabase Auth
  -> credentials, sessions, account identity

Supabase Postgres + Data API/RPC
  -> RLS-protected persistence
  -> immutable routine, schedule, reward, wallet, and audit records
  -> atomic server-authoritative transitions
```

## Accepted clients

### Flutter mobile

Owns user-facing workout execution and history presentation.

It does not authoritatively calculate or persist RR, XP, penalties, wallet balances, rank, milestones, or finalization results.

### Flutter Web dashboard

Owns user-facing routine drafting, validation, publication, preview, and history.

It is a separate application with desktop-appropriate interaction and accessibility behavior. It does not allow ordinary cross-user management.

### Shared Dart packages

Planned shared responsibilities:

- domain models;
- pure validation;
- repository contracts;
- Supabase adapters;
- shared design tokens and reusable widgets where appropriate.

Mobile and dashboard presentation state remains separate.

## Accepted backend

Supabase is the accepted backend platform.

### Authentication

- Supabase Auth manages credentials and sessions.
- Initial accounts are provisioned administratively.
- Public registration is disabled for MVP.
- Passwords are never stored in application tables.
- Public clients use publishable credentials only.

### Persistence

Supabase Postgres is authoritative for:

- profiles;
- user-owned routine versions;
- weekly plans and plan items;
- workout sessions and sets;
- daily reward and penalty allocations;
- rank, XP, PR, milestone, decay, and correction ledgers;
- free-swap grants, consumption, and payments;
- protected periods and weekly evaluations;
- configuration versions.

### Authorization

- Every exposed user-owned table uses RLS.
- Policies combine authentication with row ownership.
- Authorization never trusts user-editable metadata.
- One user cannot read or mutate another user's private data.
- Published versions and finalized ledgers are immutable through ordinary CRUD.

### Server-authoritative operations

Atomic backend operations own:

- routine publication;
- weekly-plan materialization;
- normalized RR, XP, and penalty allocation;
- swap confirmation and payment;
- monthly grant materialization;
- workout completion resolution;
- PR validation and weekly cap;
- consistency top-ups;
- penalties and decay;
- weekly finalization;
- exact-value corrections.

The client may display previews but cannot submit final score totals.

## Accepted product configurations

- Rank: `rank-v6`.
- Scheduling: `schedule-v3`.
- Supported routine frequencies: 4-6 workout days.
- Weekly plan items: 7.
- Weekly RR pools: 110, 167, 220, 277.
- Weekly base-XP pool: 110.
- Weekly missed-workout penalty pool: 95 RR.
- Maximum rewarded PRs: 2 per week.
- Maximum swaps: 2 per week.
- Monthly free swaps: 2 non-expiring, uncapped credits.

Canonical formulas remain in the product specifications, not this architecture summary.

## Planned repository structure

```text
/apps/mobile/
/apps/dashboard/
/packages/domain/
/packages/data/
/packages/ui/
/supabase/migrations/
/supabase/seed.sql
/supabase/tests/
/docs/
```

No part of this structure exists yet.

## Data integrity boundaries

- Published routine versions are immutable.
- Routine changes activate only for future unlocked weeks.
- Weekly plans retain their routine and configuration versions.
- Reward and penalty allocations are stored when the week materializes.
- Finalized transactions are append-only or voided through auditable corrections.
- Historical results are never recalculated from new formulas.
- Idempotency is required for grants, materialization, completion, swaps, and finalization.
- Corrections restore exact stored values.

## Security boundaries

- No service-role or secret key in Flutter clients.
- No plaintext or application-managed password table.
- RLS on every exposed user-owned table.
- No `TO authenticated` policy without an ownership condition.
- Update policies require both access and ownership-preserving checks.
- Privileged database functions require narrow scope, explicit authentication checks, and restricted execution.
- User-editable metadata cannot grant authorization.
- Secret and environment files are excluded from Git.

## Connectivity boundary

The authoritative database is Supabase Postgres.

Local in-progress-workout persistence and offline finalization remain undecided. Implementation must not invent an offline-first architecture before `TASK-PL-002` closes this boundary.

## Deployment boundary

- Mobile release target: undecided.
- Dashboard hosting: undecided.
- Production Supabase project: not created.
- Backup and restore policy: undecided.
- Operational access: undecided.

## Accepted ADRs

- `ADR-0001-flutter-client-platforms.md`
- `ADR-0002-supabase-backend-auth-and-persistence.md`

## Implementation boundary

Architecture selection does not authorize scaffolding.

Implementation begins only after:

1. reward-eligible routine validation is accepted;
2. offline/local persistence behavior is accepted;
3. release, hosting, backup, and operator-access constraints are accepted;
4. `TASK-IMP-001` is approved.