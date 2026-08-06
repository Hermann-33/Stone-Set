# Stone Set Latest Handoff

Updated: 2026-08-06

## Current task result

```text
Task ID: TASK-IMP-002A
Title: Implement identity, login, sessions, profiles and ownership
Verdict: PARTIAL
Branch: codex/task-imp-002a-identity-sessions
Foundation: TASK-IMP-001 — COMPLETE AND MERGED through PR #5
Approval task: TASK-PD-014 — COMPLETE AND MERGED through PR #6
PR #6 merge commit: c371f9c8ad28dc90bef86739c2c9aa87e5450f27
Blocker: approved exact Dart dependency graph is unsatisfiable
```

Phase 1 remains complete. `TASK-IMP-002A` started from the merged approval commit and produced
bounded partial implementation, but no identity behavior is accepted or represented as complete.

## Partial work present

- local Auth configuration disables public/email and anonymous signup and applies the 12-character
  password policy;
- candidate identity/session migration defines profiles, preferences, a bounded capability,
  compatibility state, audit events, application session revocation, RLS and narrow RPCs;
- password-change completion requires a matching post-requirement Supabase Auth audit event for the
  authenticated identity and never inspects or stores a password;
- trusted Node operator tooling provides dry-run-first provision, status, activation, reset and
  session-revocation flows with explicit environment/production confirmation boundaries;
- shared identity models/repository abstractions and partial Android/dashboard Auth/session UI,
  route and widget test sources exist;
- CI changes add generation freshness, client tests/builds, local database tests, and runtime public
  signup denial.

These files require dependency resolution, generated output, analysis, tests, builds, local database
replay and CI before acceptance.

## Dependency blocker

The exact approved pins cannot resolve with the merged foundation and Flutter SDK:

```text
riverpod_generator 4.0.8 -> analyzer ^13.0.0
build_runner 2.16.0       -> analyzer >=13.3.0
test 1.31.0               -> analyzer >=8.0.0 <13.0.0
Flutter 3.44.7 flutter_test -> test_api 0.7.11
test 1.31.1               -> test_api 0.7.12
```

A temporary analyzer override was used only to diagnose the builder graph; it failed in the
transitive Mockito builder and has been removed. The final manifests retain the exact approved pins,
the analysis-server `riverpod_lint` plugin is restored, and `pubspec.lock` remains identical to
`main` because no valid approved resolution exists.

The smallest coherent family found for a separately approved evaluation is:

```text
flutter_riverpod       3.3.2
riverpod_annotation    4.0.3
riverpod_generator     4.0.4
riverpod_lint          3.1.8
build_runner           2.15.1
```

This comparison is evidence, not authorization to change pins.

## Verification evidence

```text
branch/merged starting state                    PASS
Node Auth-config/operator tests                 PASS — 14
runtime signup tests                            SKIPPED — no local stack
exact Dart dependency restore                   FAIL — approved analyzer conflict
code generation                                BLOCKED — dependency conflict
strict analysis/Dart/Flutter tests              BLOCKED — dependency conflict
Android release build                          BLOCKED — dependency conflict; SDK absent locally
dashboard release Web build                    BLOCKED — dependency conflict
local Supabase reset/pgTAP/lint                 BLOCKED — Docker/Podman absent locally
remote Supabase                                 NOT ACCESSED
```

The bounded security review found no committed credential path or client/operator dependency, but
database/runtime controls remain provisional until migration replay, pgTAP, integration tests and CI
pass. Issued JWTs may remain cryptographically valid until expiry; the candidate database enforces
Stone Set authorization using live session evidence and an application revocation ledger at each
protected operation.

## Explicitly not implemented

No accepted remote accounts, hosted Supabase project, production/staging alias strategy, product
schema, Storage, routine/guidance/media, workout/SQLite/outbox, RR/XP/rank/wallet, later mobile Home
or dashboard productivity shell, deployment, production signing or iOS work exists.

## Exact next action

Approve a coordinated compatible dependency family, update `docs/tasks/TASK-IMP-002A.md`, then
resume generation and complete verification on:

```text
branch: codex/task-imp-002a-identity-sessions
packet: docs/tasks/TASK-IMP-002A.md
```

Do not execute `TASK-IMP-002B` or `TASK-IMP-002C`.
