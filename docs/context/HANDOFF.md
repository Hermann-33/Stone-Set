# Stone Set Latest Handoff

Updated: 2026-08-06

## Current task result

```text
Task ID: TASK-PD-016
Title: Verify merged identity and approve mobile shell/Home packet
Verdict: COMPLETE
Branch: codex/task-pd-016-approve-imp-002b
Identity pull request: #7 — MERGED
Identity merge: 2281be745b75116e70d2fed9ccf85c60e79bc4aa
Identity CI run: 31093560109 — PASS
Packet result: TASK-IMP-002B APPROVED — NOT EXECUTED
```

`TASK-IMP-002A` is complete and merged through pull request #7 at
`2281be745b75116e70d2fed9ccf85c60e79bc4aa`. Post-merge inspection confirmed its bounded identity,
session, database, operator and client controls. `TASK-PD-016` revalidated the next presentation
packet without implementing it.

## Implemented boundary

- coordinated exact Riverpod/go_router/Supabase/build dependency family with Analyzer 12.1.0,
  `test` 1.31.0 and `test_api` 0.7.11;
- one root Dart lockfile, no overrides, reproducible generated providers and typed routes;
- private provisioned Auth only, deterministic username aliases and no client signup surface;
- Android and Web login, required-password-change, bootstrap, refresh/revalidation, disabled/revoked,
  expiry, logout and cache-clearing flows;
- local profiles, preferences, capabilities, compatibility, session/revocation and password-proof
  schema with explicit object grants, RLS and function execution grants;
- trusted, dry-run-first operator provisioning, reset, disable and revocation tooling;
- local-only migrations, pgTAP security matrices, runtime signup denial and real Auth password-update
  lifecycle proof.

## Verification evidence

Final identity GitHub Actions run `31093560109` passed all three required jobs:

```text
Documentation and repository checks  PASS
Flutter and Dart                     PASS
Local Supabase                       PASS
```

The run includes exact restore and lockfile checks, zero-output regeneration, formatting, strict
analysis, Dart/Flutter/widget/browser tests, Android and Web release builds, bundle secret review,
clean local Supabase reset, migrations, pgTAP grants/RLS/function matrices, runtime public and
anonymous signup denial, and a real Auth password-update/audit-proof lifecycle test.

This Windows host passed the locally available restore, generation, analysis, unit/widget and Web
build gates. Android and Docker-backed Supabase verification are CI-proven because this host lacks
an Android SDK and Docker/Podman.

## Security and operational boundaries

- global public signup and anonymous signup are disabled; email/password remains enabled so
  operator-provisioned users can sign in;
- a client cannot directly clear `must_change_password`; completion consumes server-side Auth audit
  evidence bound to the authenticated identity and a live application session;
- Postgres does not inspect passwords; the proof confirms an accepted Auth password-update event,
  not password contents or same-client origin;
- Data API object access, RLS row authorization and function `EXECUTE` are independently granted and
  tested;
- JWTs are not claimed to invalidate instantly; local expiry is one hour and protected bootstrap/RPC
  paths revalidate active profile and application-session state;
- service-role/management credentials remain trusted-tool environment inputs and never enter Flutter
  clients, bundles, committed files or logs;
- non-local provisioning is blocked without a controlled alias domain or supported delivery hook;
- no remote Supabase, Vercel or production account was created or changed.

## Explicitly not implemented

Later product UI/shells, routines, exercises/guidance/media, Storage, weekly scheduling, workouts,
offline SQLite/outbox behavior, RR/XP/rank/wallet/finalization, deployment and production provisioning
remain outside `TASK-IMP-002A`.

## Exact next action

After the `TASK-PD-016` planning pull request merges, execute:

```text
task: TASK-IMP-002B
branch: codex/task-imp-002b-mobile-shell-home
packet: docs/tasks/TASK-IMP-002B.md
```

`TASK-IMP-002C` remains planned, unapproved and non-executable.
