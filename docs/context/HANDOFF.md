# Stone Set Latest Handoff

Updated: 2026-08-06

## Current task result

```text
Task ID: TASK-IMP-002A
Title: Implement identity, login, sessions, profiles and ownership
Verdict: COMPLETE
Branch: codex/task-imp-002a-identity-sessions
Pull request: #7 — OPEN DRAFT
CI run: 31092177135 — PASS
Merge state: NOT MERGED
```

`TASK-PD-015` was merged through pull request #8 at
`52ec1886e5ed5080e129c1f3d22523c0019f07b1`. The implementation branch merged that baseline and
completed every bounded `TASK-IMP-002A` gate. `main` does not contain the identity implementation
until pull request #7 is reviewed and merged.

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

GitHub Actions run `31092177135` passed all three required jobs:

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

Review and merge draft pull request #7:

```text
branch: codex/task-imp-002a-identity-sessions
packet: docs/tasks/TASK-IMP-002A.md
pull request: #7 — OPEN DRAFT
```

After merge, perform post-merge verification and separately approve the next bounded implementation
packet. `TASK-IMP-002B` and `TASK-IMP-002C` are planned but not executable.
