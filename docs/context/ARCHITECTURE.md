# Stone Set Current Architecture

Updated: 2026-08-04
Status: `ACCEPTED TARGET ARCHITECTURE — NOT IMPLEMENTED`

## Implemented system

```text
GitHub repository
  -> governance
  -> accepted product specifications
  -> accepted ADRs
  -> implementation plan and task packets
```

No application runtime, database, account, deployment, or CI exists.

## Target system

```text
Android Flutter app
  -> online workout start
  -> SQLite active draft and outbox
  -> authenticated synchronization

Flutter Web dashboard
  -> reviewed routine drafting and publication
  -> static Vercel deployment

Shared Dart workspace packages
  -> pure domain rules
  -> repository contracts and adapters
  -> limited shared UI assets

Supabase Auth
  -> credentials, sessions, identity

Supabase Postgres
  -> RLS-protected user state
  -> immutable versions and ledgers
  -> atomic server-authoritative operations
```

## Client responsibilities

### Android mobile

- week and rank presentation;
- online session start and schedule locking;
- workout timers and set entry;
- SQLite draft recovery and outbox synchronization;
- pending, provisional, and finalized state presentation;
- swaps, wallet selection, progression, protection, and history.

The client does not calculate authoritative RR, XP, penalties, wallet balances, PR awards, consistency, or finalization.

### Flutter Web dashboard

- user-owned routine drafts;
- server validation feedback;
- submission for independent review;
- approve/reject workflow without reviewer edits;
- future publication preview and history.

The dashboard is a public static client. Supabase Auth and RLS—not hidden URLs—protect data.

### Shared Dart packages

Planned dependency direction:

```text
mobile -> domain, data, ui
dashboard -> domain, data, ui
data -> domain
ui -> Flutter
domain -> Dart SDK
```

Native Pub workspaces provide one root dependency resolution and lockfile.

## Routine integrity

`routine-validator-v1` owns hard eligibility checks. Approval stores the exact submitted content hash, validator result, reviewer, and audit evidence.

- Authors cannot self-approve.
- Reviewers cannot mutate submissions.
- Publication reruns server validation and verifies the content hash.
- Published versions are immutable.
- Historical weeks retain their routine and validator versions.

## Local persistence and synchronization

- SQLite through `sqflite` stores active drafts, cached prescription snapshots, and outbox records.
- A workout must start online.
- The server returns a session ID, immutable prescription, and start timestamp and locks the item.
- A valid started workout may continue and finish locally while offline.
- Offline completion remains `pending_submission` until server validation.
- Sync occurs on foreground, connectivity regain, and explicit retry; no continuous polling.
- Idempotency keys prevent duplicate sessions, sets, or rewards.
- Started sessions receive a 24-hour week-close synchronization grace.
- Logout with unsynchronized data requires sync or explicit discard.

## Backend and authorization

- Supabase Auth owns passwords and sessions.
- Every exposed user-owned table uses RLS with ownership predicates.
- User-editable metadata is not trusted for authorization.
- Routine publication, plan materialization, swaps, grants, completion, rewards, penalties, weekly finalization, and corrections are atomic server operations.
- Privileged functions live outside exposed schemas, validate the authenticated actor, revoke default public execution, and receive security tests.
- Public clients use only the project URL and publishable key.

## Environment and deployment model

```text
local -> Supabase CLI + local runtime
staging -> hosted non-production Supabase
production -> hosted Supabase Pro
```

- Preview dashboard deployments connect only to staging.
- Production Flutter Web output is static and hosted on Vercel.
- GitHub Actions builds and tests the exact artifact before preview and production promotion.
- SPA routes rewrite to `index.html`.
- Initial mobile release is Android API 24+ through a private signed APK; Play internal testing may follow.
- iOS is deferred.

## Backup and operations

- Supabase Pro managed daily backups with seven-day retention.
- Weekly encrypted logical dumps stored independently in private Google Drive and operator-controlled local/removable storage.
- Retention: 12 weekly and 12 month-end exports.
- RPO target: 24 hours.
- RTO target: 4 hours for the expected small dataset.
- Restore drill before release and quarterly thereafter.
- Two distinct Owner accounts with MFA and backup factors.
- Organization MFA enforcement and least-privileged collaborators.
- Production migrations originate from committed history; untracked dashboard edits are prohibited.

## Security boundaries

- No secrets or personal data in Git.
- No service-role key, database password, backup key, Vercel token, or operator token in clients.
- No production data in preview or staging by default.
- No client-authoritative rank or wallet values.
- Local drafts are private but non-authoritative.
- Finalized records are append-only or voided by exact-value audited corrections.
- Historical values are never recalculated from new configurations.

## Accepted ADRs

- ADR-0001 — Flutter clients.
- ADR-0002 — Supabase Auth/Postgres/RLS.
- ADR-0003 — local drafts and online finalization.
- ADR-0004 — Android-first and Vercel hosting.
- ADR-0005 — production operations and recovery.

## Implementation boundary

`TASK-IMP-001` may create scaffolding, local Supabase configuration, tests, builds, and CI only.

It may not create remote infrastructure or implement product features.
