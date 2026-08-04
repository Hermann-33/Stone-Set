# Stone Set Current Architecture

Updated: 2026-08-04
Status: `ACCEPTED PLANNING ARCHITECTURE — NOT IMPLEMENTED`

## Current implemented system

```text
GitHub repository
  -> governance and context Markdown
  -> accepted product baselines
  -> accepted architecture decisions
  -> proposed workflow and implementation plan
```

There is still no application runtime, client project, database schema, Supabase project, deployment, or test suite.

## Accepted target system

```text
Flutter mobile application
  -> workout execution, logging, weekly schedule, swaps, rank feedback

Flutter Web dashboard
  -> user-owned routine drafting, validation, publication, and history

Shared Dart packages
  -> domain models, validation, repositories, Supabase adapters

Supabase Auth
  -> password credentials, sessions, user identity

Supabase Postgres
  -> profiles, routine versions, weekly plans, logs, rank and wallet ledgers

RLS + narrowly scoped atomic database operations
  -> ownership enforcement and server-authoritative state transitions
```

Accepted ADRs:

- `docs/decisions/ADR-0001-flutter-client-platforms.md`
- `docs/decisions/ADR-0002-supabase-backend-auth-and-persistence.md`

## Client applications

### Mobile

Planned as a dedicated Flutter application for Android and iOS-capable code. Initial release targets remain to be decided before implementation.

The mobile application owns user interaction for:

- sign-in and session handling;
- current-week and current-day presentation;
- workout execution and set logging;
- session and rest timers;
- schedule swaps and payment selection;
- rank, RR, XP, streak, wallet, and history presentation;
- progression, protection, and correction workflows.

### Dashboard

Planned as a separate Flutter Web application.

The dashboard owns:

- user-owned routine drafts;
- prescription editing;
- validation and preview;
- immutable routine publication;
- future effective dates;
- routine-version and audit history.

Ordinary users may not edit another user's routine or rank state.

## Shared client architecture

The planned Flutter structure follows separation of concerns:

- views render state and forward user actions;
- view models coordinate UI state;
- repositories expose authoritative domain data;
- services isolate Supabase and platform APIs;
- use cases encapsulate complex or reused domain transitions.

Shared code is limited to responsibilities that are genuinely common. Mobile and dashboard workflows remain separate applications.

No state-management, router, dependency-injection, offline-database, or deployment package has been selected.

## Backend and persistence

Supabase is the accepted backend platform for:

- Supabase Auth;
- hosted Postgres;
- explicitly granted Data API access;
- Row Level Security;
- versioned database migrations;
- atomic database operations for sensitive transitions.

Postgres is planned as the authoritative persistent source for:

- profiles and user settings;
- immutable routine versions;
- weekly plans and schedule snapshots;
- workout sessions and sets;
- daily and weekly reward records;
- lifetime XP and Rank Rating transactions;
- PR history;
- swap and free-credit ledgers;
- consistency, milestone, penalty, decay, protection, and correction history;
- rank and schedule configuration versions.

## Authentication and authorization

- Public signup is disabled for MVP.
- Two initial accounts are provisioned administratively.
- The account count is not hardcoded into the schema.
- Supabase Auth owns passwords and sessions.
- Application tables never store plaintext passwords or application-managed password hashes.
- `profiles` references `auth.users` and contains non-sensitive user-facing fields.
- Every exposed user-owned table has RLS enabled.
- Policies enforce row ownership using authenticated identity.
- User-editable metadata is not trusted for authorization.
- Public clients use publishable credentials only.
- Service-role and secret keys never appear in client applications.

## Server-authoritative behavior

Clients may calculate previews, but they do not authoritatively set:

- RR or lifetime XP;
- rank or consistency state;
- daily or weekly awards;
- missed penalties or decay;
- swap payments;
- free-swap balances;
- milestone state;
- correction values;
- finalization status.

Simple owner-only draft CRUD may use the Data API under RLS.

Sensitive multi-row transitions must execute atomically through narrowly scoped database operations. `SECURITY INVOKER` is preferred. Any privileged function requires explicit authorization checks, restricted execution privileges, and a security review.

## Local state and connectivity

The mobile app is planned to persist an in-progress workout draft locally so app termination or temporary connectivity loss does not discard set entries.

The exact local persistence technology is deferred.

The server remains authoritative for final submission, PR validation, rewards, penalties, wallet state, and weekly finalization.

## Product-configuration boundary

Current accepted product configurations remain:

- `rank-v5`;
- `schedule-v2`.

The multi-user variable-routine and normalized daily-RR model is proposed in:

- `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md`.

Implementation of weekly planning, daily rewards, variable routine frequency, or rest-day RR is blocked until `rank-v6` and `schedule-v3` are accepted and the canonical product documents are synchronized.

## APIs and external services

No custom API service, Edge Function, Realtime channel, Storage bucket, analytics platform, payment provider, wearable integration, or external service is accepted for MVP.

A later ADR is required before introducing any of them.

## Deployment

Not selected.

The dashboard hosting provider, mobile release targets, production Supabase project, backup procedure, and operational access model remain Phase 0 decisions.

## Planned repository layout

```text
/apps/mobile/
/apps/dashboard/
/packages/domain/
/packages/data/
/packages/ui/
/supabase/migrations/
/supabase/tests/
/docs/
```

This layout is planned but does not exist yet.

## Architectural boundaries

- Do not scaffold before the product-change gate passes.
- Do not store passwords in public application tables.
- Do not expose service-role or secret credentials to Flutter clients.
- Do not rely on hidden UI controls as authorization.
- Do not permit client-authored score or wallet totals.
- Do not mutate published routine versions or finalized ledger entries.
- Do not recalculate historical transactions from current formulas.
- Do not introduce a custom backend, Edge Functions, Realtime, Storage, analytics, or deployment without an ADR.
- Do not represent planned repository paths as implemented files.
- Do not activate `rank-v6` or `schedule-v3` from this architecture document alone.

## Exact architecture continuation

1. Audit and accept or reject the multi-user routine and normalized daily-RR proposal.
2. Synchronize the canonical product baselines if accepted.
3. Decide connectivity, local-draft persistence, hosting, and release constraints.
4. Approve `TASK-IMP-001` as the first bounded implementation task.
5. Only then create application scaffolding and Supabase configuration.
