# Stone Set

Stone Set is a private two-user muscle-growth training system with independently managed routines,
exercise guidance, and a shared normalized rank economy.

The repository is authoritative for product decisions, architecture, implementation state,
verification evidence, and handoff context. Chat history is not authoritative.

## Current state

- Phase 0 planning: `COMPLETE`
- Phase 1 foundation: `COMPLETE`
- Active packet: [`TASK-IMP-002A`](docs/tasks/TASK-IMP-002A.md) — `PARTIAL`, dependency approval required
- Branch: `codex/task-imp-002a-identity-sessions`
- External infrastructure: none created or linked

The repository now contains:

- a native Dart Pub workspace for the Android app, Web dashboard, and shared packages;
- an Android-only accessible Flutter foundation shell;
- a Web-only accessible Flutter dashboard shell and static SPA rewrite;
- pure Dart `domain` and `data` package foundations plus a neutral Flutter `ui` foundation;
- local-only Supabase configuration, an empty seed, and a pgTAP runner smoke test;
- exact tool/dependency locks, non-secret configuration examples, repository checks, and root commands;
- least-privilege GitHub Actions foundation CI for repository, Flutter/Dart, and local Supabase checks.

This branch contains unaccepted partial identity/session work: Auth configuration, a candidate local
migration and tests, trusted operator tooling, shared identity contracts, and Android/dashboard Auth
presentation sources. The approved Dart dependency pins do not resolve, so generated sources,
analysis, tests, release builds, local database replay and CI acceptance remain incomplete. None of
that partial work is represented as merged or production-ready behavior.

## Exact tool pins

The machine-readable source is [`tool/tool_versions.json`](tool/tool_versions.json).

```text
Flutter       3.44.7
Dart          3.12.2
Node.js       24.11.1
Supabase CLI  2.111.0
```

Direct Dart tooling is also pinned, including `args 2.7.0`, `yaml 3.1.3`, `test 1.31.0`, and
`flutter_lints 6.0.0`. Resolved Dart and npm dependency versions are recorded in the root
`pubspec.lock` and `package-lock.json`; workspace members must not contain nested lockfiles.

On this partial branch, `pubspec.lock` intentionally remains the merged foundation lockfile and does
not satisfy the newly approved identity dependency declarations. `dart pub get --enforce-lockfile`
must fail until a coordinated compatible pin amendment is approved; do not add overrides.

## Prerequisites

- Flutter 3.44.7 with bundled Dart 3.12.2;
- Node.js 24.11.1 and npm;
- an Android SDK with `ANDROID_HOME` configured for Android APK builds;
- Docker Desktop, Podman, or another Supabase-compatible container runtime for local database gates.

When Flutter is not on `PATH`, set `FLUTTER_ROOT` to the Flutter SDK directory. The repository
commands resolve Flutter from that variable on Windows and Linux CI.

## Setup from the repository root

Restore the exact locked dependency graph:

```text
dart pub get --enforce-lockfile
npm ci
```

Verify tool pins and repository boundaries:

```text
dart run bin/stone_set.dart tool-version-check
dart run bin/stone_set.dart repository-check
```

## Root development commands

```text
dart run bin/stone_set.dart restore --enforce-lockfile
dart run bin/stone_set.dart format-check
dart run bin/stone_set.dart analyze
dart run bin/stone_set.dart test
dart run bin/stone_set.dart build-android
dart run bin/stone_set.dart build-dashboard

dart run bin/stone_set.dart supabase-start
dart run bin/stone_set.dart supabase-reset
dart run bin/stone_set.dart supabase-test
dart run bin/stone_set.dart supabase-lint
dart run bin/stone_set.dart supabase-stop --no-backup

dart run bin/stone_set.dart verify
```

`verify` runs repository checks, locked restore, tool-version checks, formatting, analysis, all
unit/widget tests, Android and Web release builds, and the local Supabase start/reset/test/lint
sequence. It requires both the Android SDK and a compatible container runtime.

## Current verification evidence

Passing locally:

- locked root dependency resolution;
- tool-version and repository-hygiene checks;
- formatting and strict static analysis;
- all Dart unit tests and Flutter widget tests;
- Flutter Web release build;
- secret/configuration and dependency-boundary review.

Environment notes:

- this Windows host cannot repeat the Android release build until an Android SDK/`ANDROID_HOME` is
  configured;
- this Windows host cannot repeat local Supabase lifecycle checks until Docker/Podman is available;
- GitHub Actions run `31003516689` passed repository, Flutter/Dart, Android/Web build, and local
  Supabase lifecycle gates;
- pull request #5 is merged at `3d0830767fd5320f33a4b7a209d937d2b59f7a6e`;
- `TASK-IMP-001` is complete and merged.

## Start here

1. Read [`AGENTS.md`](AGENTS.md).
2. Use [`docs/context/NEW_CHAT_BOOTSTRAP.md`](docs/context/NEW_CHAT_BOOTSTRAP.md) for a new task.
3. Read the mandatory canonical context under [`docs/context/`](docs/context/).
4. Read accepted product baselines under [`docs/product/`](docs/product/).
5. Read accepted ADRs under [`docs/decisions/`](docs/decisions/).
6. Implement only through the approved packet under [`docs/tasks/`](docs/tasks/).

## Exact next action

Approve a coordinated dependency-pin amendment for `TASK-IMP-002A`, update the packet, and resume
verification on the same branch.

```text
branch: codex/task-imp-002a-identity-sessions
packet: docs/tasks/TASK-IMP-002A.md
```

Do not execute `TASK-IMP-002B` or `TASK-IMP-002C`. Installing an Android SDK and Docker-compatible
runtime remains necessary for complete local parity after the dependency blocker is resolved.
