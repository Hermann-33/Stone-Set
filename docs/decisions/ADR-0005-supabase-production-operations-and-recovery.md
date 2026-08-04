# ADR-0005: Supabase production operations, access, backup, and recovery

## Status

Accepted

- Date: 2026-08-04
- Type: Production operations, security, and disaster recovery
- Supersedes: None
- Preserves: ADR-0002 Supabase ownership, RLS, migration history, and private user data

## Context

Stone Set will store private workout history, immutable rank transactions, routine versions, and wallet records in Supabase Postgres. The production plan must define environment separation, operator access, backups, restore expectations, and credential handling before infrastructure is created.

Supabase provides daily backups on Pro projects with seven-day retention. Point-in-Time Recovery provides finer recovery but carries a large recurring cost relative to a private two-user application.

## Decision criteria

- protect private user data;
- avoid a single-account lockout;
- reproducible migrations;
- documented recovery objectives;
- backup independence from the live database;
- cost proportional to a two-user product;
- no shared operator credentials;
- practical restore testing.

## Options considered

### Option A — Free production project with manual exports only

Advantages:

- lowest cost.

Disadvantages:

- no managed daily backup retention;
- higher dependence on manual operator discipline;
- weaker production recovery posture.

### Option B — Pro production project with daily backups

Advantages:

- managed daily backups;
- seven-day retention;
- organization MFA enforcement;
- suitable recovery for the current write volume.

Disadvantages:

- recurring subscription cost;
- daily recovery point can lose up to approximately one day of writes.

### Option C — Pro production project with Point-in-Time Recovery

Advantages:

- much finer recovery granularity.

Disadvantages:

- substantial add-on cost and minimum compute requirements;
- disproportionate for two initial users.

## Decision

Stone Set uses Option B for production and adds independent logical exports.

### Environment model

```text
local development -> Supabase CLI and Docker-compatible runtime
staging -> separate hosted non-production Supabase project
production -> separate Supabase Pro project
```

Rules:

- Local configuration, migrations, and non-sensitive seed data are committed.
- Staging contains synthetic or designated test data only.
- Production data is never copied into staging by default.
- Preview dashboard deployments connect only to staging.
- Production migrations are applied from committed migration history after dry-run and review.
- Direct production schema editing in Dashboard or SQL Editor is prohibited except documented emergency response followed immediately by migration reconciliation.

### Production backup policy

- Supabase Pro managed daily backups are required.
- Retention target: the available seven daily restore points.
- PITR is not enabled initially.
- A logical backup is produced once per week using `supabase db dump` or `pg_dump`.
- The logical dump is encrypted before leaving the operator machine.
- One encrypted copy is stored in a private Google Drive backup folder.
- A second encrypted copy is stored on an operator-controlled local or removable drive.
- Retain the most recent 12 weekly backups and 12 month-end backups.
- Backup archives, encryption keys, and restore passwords are never committed to Git.

### Recovery objectives

```text
RPO target = 24 hours
RTO target = 4 hours for the small production dataset
```

The release is not production-ready until a restore is demonstrated.

- Perform a restore drill before first production release.
- Repeat the restore drill quarterly.
- Restore into a disposable non-production project.
- Verify migrations, Auth linkage, profiles, routines, workout history, rank ledger, wallet ledger, and configuration versions.
- Record date, backup identifier, duration, result, and defects.

PITR must be reconsidered when any of the following becomes true:

- losing up to 24 hours of writes is no longer acceptable;
- account count or daily writes grow materially;
- operational or contractual requirements demand a smaller RPO;
- the owner explicitly accepts the additional recurring cost.

### Operator access

- The Supabase organization has two distinct Owner accounts: primary and emergency recovery.
- Shared Supabase accounts are prohibited.
- Both Owner accounts enable MFA and register a separate backup TOTP factor.
- Organization-level MFA enforcement is enabled on the Pro organization.
- Additional collaborators receive the least-privileged available role; Owner is not the default collaborator role.
- A user who no longer needs access is removed immediately.
- Supabase personal access tokens are individually issued, scoped by purpose, stored in a password manager or CI secret store, and revoked after use or role change.

### Database and secret controls

- SSL enforcement is enabled for direct database connections.
- Database network restrictions are enabled where compatible with CI and operator access.
- Public clients use only the Supabase URL and publishable key.
- Service-role keys are limited to controlled server or operator tooling and encrypted CI secrets.
- Database passwords are stored in a password manager and rotated after suspected exposure or access changes.
- Production `.env` files and downloaded project linkage state are not committed.
- Codex and public client code never receive dashboard-owner credentials.

### Operational runbook

Before release, document:

1. project and environment identifiers without secrets;
2. migration deployment procedure;
3. backup procedure;
4. restore procedure;
5. access-revocation procedure;
6. key and password rotation procedure;
7. incident triage and rollback procedure;
8. ownership recovery procedure.

## Consequences

### Positive

- managed daily recovery is available;
- a second encrypted backup path protects against project deletion or platform-only loss;
- two owners reduce account-lockout risk;
- MFA and least privilege reduce administrative compromise risk;
- local/staging/production separation protects real user data.

### Negative

- production requires a Pro subscription;
- weekly logical export and quarterly restore drills require operator discipline;
- PITR is not available unless enabled later;
- multiple environments increase configuration management work.

## Security, privacy, data, and operational impact

- Backups contain private user data and must remain encrypted.
- Google Drive or local storage compromise must not reveal plaintext database contents.
- Restore testing uses disposable infrastructure and does not expose production credentials to clients.
- Database backups do not automatically protect future Supabase Storage objects; Storage is outside the current MVP.
- Project deletion remains destructive and requires explicit confirmation and independent backup verification.

## Scope boundaries

This ADR does not authorize:

- creation of any Supabase project;
- purchase of a plan;
- operator invitation;
- credential generation;
- backup execution;
- production data creation;
- PITR activation;
- Storage, Edge Functions, Realtime, or analytics.

## Rollback or supersession rule

A later ADR may move production to another plan or provider only with a tested identity, data, ledger, backup, and rollback migration.

PITR may be added without replacing Supabase only after cost and recovery requirements are explicitly accepted.

## Activation evidence

`TASK-PL-002` accepts this operational baseline. Runtime activation requires release-hardening evidence and a successful restore drill.