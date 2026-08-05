# Stone Set

Stone Set is a private two-user muscle-growth training system with independently managed routines,
exercise guidance, and a shared normalized rank economy.

The repository is authoritative for product decisions, architecture, implementation state,
verification evidence, and handoff context. Chat history is not authoritative.

## Current state

- Phase 0 planning: `COMPLETE`
- Phase 1 foundation: `IN PROGRESS — PARTIAL`
- Active packet: [`TASK-IMP-001`](docs/tasks/TASK-IMP-001.md)
- Branch: `codex/task-imp-001-foundation`
- External infrastructure: none created or linked

The repository now contains:

- a native Dart Pub workspace for the Android app, Web dashboard, and shared packages;
- an Android-only accessible Flutter foundation shell;
- a Web-only accessible Flutter dashboard shell and static SPA rewrite;
- pure Dart `domain` and `data` package foundations plus a neutral Flutter `ui` foundation;
- local-only Supabase configuration, an empty seed, and a pgTAP runner smoke test;
- exact tool/dependency locks, non-secret configuration examples, repository checks, and root commands;
- least-privilege GitHub Actions foundation CI for repository, Flutter/Dart, and local Supabase checks.

This is scaffolding only. Authentication, login, profiles, product schema, Storage, routines,
workouts, rank behavior, media, YouTube, deployment, production signing, and iOS are not
implemented.

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

Open gates:

- Android release APK: blocked locally because no Android SDK/`ANDROID_HOME` is configured;
- Supabase reset, pgTAP test, and lint: blocked locally because Docker/Podman is unavailable;
- GitHub Actions CI: workflow is present in the working tree but has not run yet;
- Git: the task has not yet been committed, pushed, or opened as a draft pull request.

## Start here

1. Read [`AGENTS.md`](AGENTS.md).
2. Use [`docs/context/NEW_CHAT_BOOTSTRAP.md`](docs/context/NEW_CHAT_BOOTSTRAP.md) for a new task.
3. Read the mandatory canonical context under [`docs/context/`](docs/context/).
4. Read accepted product baselines under [`docs/product/`](docs/product/).
5. Read accepted ADRs under [`docs/decisions/`](docs/decisions/).
6. Implement only through the approved packet under [`docs/tasks/`](docs/tasks/).

## Exact next action

The coordinator must inspect the final diff, commit and push `codex/task-imp-001-foundation`, open
a draft pull request, and obtain CI results. Configure an Android SDK and a Docker-compatible
runtime to close the remaining local APK and Supabase gates. Do not begin a later packet until
`TASK-IMP-001` satisfies every completion gate.
