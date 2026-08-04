# ADR-0002: Supabase backend, authentication, and persistence

## Status

Accepted

- Date: 2026-08-04
- Type: Backend, authentication, persistence, and security architecture
- Supersedes: None
- Preserves: Auditable rank history, configuration versioning, protected product baselines, and repository governance

## Context

Stone Set requires persistent multi-user accounts, separate user-owned routines, weekly schedules, workout logs, immutable rank transactions, free-swap ledgers, and correction history.

The owner selected Supabase as the database platform and requested username-and-password accounts for two initial users.

Directly storing usernames and passwords in an ordinary application table would be insecure and would duplicate authentication responsibilities that Supabase Auth already provides.

## Decision criteria

- secure password handling;
- low infrastructure and maintenance burden;
- strong Flutter support;
- transactional Postgres persistence;
- row-level authorization;
- auditable immutable ledgers;
- local development and migration support;
- ability to begin with two users without hardcoding a two-user limit;
- no custom always-on backend unless justified later.

## Options considered

### Option A — Supabase Auth and Postgres

Advantages:

- managed credential handling and sessions;
- Postgres transactions and constraints;
- Row Level Security;
- generated client APIs and Flutter SDK;
- versioned migrations and local development;
- lower operational burden.

Disadvantages:

- security depends on correct RLS and privilege design;
- complex reward transitions may require carefully designed database functions;
- platform behavior and APIs can change and require documentation checks.

### Option B — Custom API and self-managed database

Advantages:

- full control over authentication and business logic;
- no platform-specific API constraints.

Disadvantages:

- substantially higher security and operational burden;
- password, session, deployment, backup, and patching responsibilities;
- unjustified complexity for two users.

### Option C — Store username and password records directly in an application table

Advantages:

- superficially simple.

Disadvantages:

- unsafe credential ownership;
- password hashing, reset, session, revocation, and brute-force protection must be built correctly;
- ordinary client access to credential records would be catastrophic;
- duplicates Supabase Auth.

This option is rejected.

## Decision

Stone Set will use hosted Supabase for:

- Supabase Auth;
- Postgres persistence;
- generated Data API access where explicitly granted;
- Row Level Security;
- migration-managed schema;
- narrowly scoped database operations for atomic state transitions.

### Account policy

- Public self-registration is disabled for MVP.
- The two initial users are provisioned administratively.
- Authentication uses Supabase Auth password credentials.
- Passwords are never stored in `public` application tables and are never readable by either client.
- Each Auth user has a `public.profiles` row keyed by `auth.users.id`.
- The profile may contain a unique username, display name, reward timezone, unit preferences, and non-sensitive settings.
- The application may present a username-oriented interface, but the underlying authentication mechanism remains Supabase Auth.

### Authorization policy

- Every table in an exposed schema has RLS enabled.
- Every user-owned row includes an immutable `user_id` or equivalent ownership path.
- Policies use authenticated ownership predicates, not UI visibility.
- Update policies require both existing-row and resulting-row ownership checks.
- User-editable metadata is not trusted for authorization.
- Authorization roles, if introduced, use server-controlled metadata or protected database records.
- Ordinary users may manage only their own routine drafts and data.

### Client credential policy

- Flutter mobile and Flutter Web use publishable client credentials only.
- Service-role and secret keys never appear in either client, repository, logs, screenshots, or documentation.
- Privileged administration is performed through controlled operational tooling, not public client code.

### Data-access policy

- Simple user-owned draft CRUD may use the Data API under RLS.
- New tables are exposed only through explicit grants required by the implementation.
- Sensitive multi-table transitions use atomic database operations with the narrowest possible privileges.
- `SECURITY INVOKER` is preferred where RLS can authorize the complete operation.
- Any necessary privileged function must live outside exposed schemas, validate `auth.uid()`, revoke default public execution, and receive a dedicated security review.
- Clients never submit authoritative RR, XP, rank, penalty, credit, balance, milestone, or finalization totals.

### Source-of-truth policy

Postgres is authoritative for:

- published routine versions;
- materialized weekly plans;
- workout and set records after synchronization;
- swaps and wallet transactions;
- rank and lifetime-XP ledgers;
- daily and weekly evaluations;
- configuration versions;
- corrections and audit history.

A local mobile draft may protect in-progress set entry, but it does not become authoritative until synchronized and validated.

## Consequences

### Positive

- passwords and sessions remain inside a dedicated authentication system;
- Postgres transactions can protect rank and wallet integrity;
- RLS provides per-user data isolation;
- one backend supports mobile and dashboard clients;
- no custom server deployment is required for the first architecture;
- the data model can grow beyond two users.

### Negative

- RLS and function privileges require rigorous tests;
- Supabase platform changes require active maintenance;
- complex SQL transitions may be harder to maintain than application-language services;
- local offline behavior requires a separate client-side persistence decision;
- vendor migration would require replacing Auth, APIs, and deployment workflows.

## Security, privacy, data, and operational impact

- User workout data is private by default.
- No cross-user data access is permitted for ordinary accounts.
- Credential material is excluded from application tables.
- Immutable transaction and correction records are required for all score and wallet changes.
- Database migrations, RLS policies, grants, functions, and tests must be committed.
- Backup, restore, and production access procedures are required before release.
- Data API exposure must be explicit rather than assumed.

## Scope boundaries

This ADR does not authorize:

- creation of a Supabase project;
- schema migrations;
- account creation;
- secrets or environment values;
- Edge Functions;
- Realtime;
- Storage;
- analytics;
- production deployment;
- a specific offline database;
- direct acceptance of `rank-v6` or `schedule-v3`.

## Rollback or supersession rule

A later ADR may introduce an application service or Edge Functions if database-only transitions become unsafe, untestable, or unmaintainable.

A migration away from Supabase requires an ADR covering identity migration, password-reset consequences, schema export, ledger integrity, downtime, rollback, and client compatibility.

## Activation evidence

`TASK-PL-001` records this architecture decision. No Supabase project or runtime activation exists yet.
