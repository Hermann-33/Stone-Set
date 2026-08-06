# Stone Set

Stone Set is a private two-user muscle-growth training system with independently managed routines,
exercise guidance, and a shared normalized rank economy.

The repository is authoritative for product decisions, architecture, implementation state,
verification evidence, and handoff context. Chat history is not authoritative.

## Current state

- Phase 0 planning: `COMPLETE`
- Phase 1 foundation: `COMPLETE`
- Identity packet: [`TASK-IMP-002A`](docs/tasks/TASK-IMP-002A.md) — `COMPLETE AND MERGED` through PR #7
- Mobile presentation packet: [`TASK-IMP-002B`](docs/tasks/TASK-IMP-002B.md) — `IMPLEMENTED — AWAITING MERGE`
- Implementation branch: `codex/task-imp-002b-mobile-shell-home`
- External infrastructure: none created or linked

The repository now contains:

- a native Dart Pub workspace for the Android app, Web dashboard, and shared packages;
- an Android-only accessible Flutter foundation shell;
- a Web-only accessible Flutter dashboard shell and static SPA rewrite;
- pure Dart `domain` and `data` package foundations plus a neutral Flutter `ui` foundation;
- local-only Supabase Auth configuration, identity migration, synthetic seed, pgTAP security tests,
  and real local Auth lifecycle tests;
- exact tool/dependency locks, non-secret configuration examples, repository checks, and root commands;
- least-privilege GitHub Actions foundation CI for repository, Flutter/Dart, and local Supabase checks.
- a fixture-driven Android Home/Week/Progress/Profile shell, shared semantic themes and primitives,
  all 20 rank emblems, full-circle rank progress, accessibility coverage and reviewed Linux goldens.

The merged repository contains the verified bounded identity/session implementation: provisioned private Auth,
profiles/preferences/capabilities, guarded client sessions, first-password-change proof, explicit
Data API/RLS/function privileges, and trusted operator tooling. Final CI run `31093560109` passed.
The work remains local-only; it is not production infrastructure or later product UI.

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

The coordinated identity dependency family resolves with Analyzer 12.1.0, `test` 1.31.0 and
`test_api` 0.7.11. The root `pubspec.lock` is current, there are no workspace-member lockfiles, and
no dependency override is used.

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
dart run bin/stone_set.dart stage-rank-assets
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

`assets/ranks/` is the only canonical rank source. `stage-rank-assets` validates its manifest and
copies exactly the 20 listed PNGs into the ignored mobile `.dart_tool` build input; the root test and
Android-build commands perform this staging automatically.

## Current verification evidence

Passing locally:

- locked root dependency resolution;
- tool-version and repository-hygiene checks;
- formatting and strict static analysis;
- all Dart unit tests and Flutter widget tests;
- Flutter Web release build;
- Android release build and local Supabase lifecycle/security gates through CI;
- secret/configuration, generated-source and client-bundle review.

Environment notes:

- this Windows host cannot repeat the Android release build until an Android SDK/`ANDROID_HOME` is
  configured;
- this Windows host cannot repeat local Supabase lifecycle checks until Docker/Podman is available;
- GitHub Actions run `31003516689` passed repository, Flutter/Dart, Android/Web build, and local
  Supabase lifecycle gates;
- GitHub Actions run `31093560109` passed the final `TASK-IMP-002A` repository, Flutter/Dart,
  Android/Web build, browser-test, local Supabase, signup-denial, lifecycle and security gates;
- pull request #5 is merged at `3d0830767fd5320f33a4b7a209d937d2b59f7a6e`;
- `TASK-IMP-001` is complete and merged.
- pull request #7 is merged at `2281be745b75116e70d2fed9ccf85c60e79bc4aa`;
- `TASK-IMP-002A` is complete and merged.
- GitHub Actions run `31108585023` passed the `TASK-IMP-002B` repository, Flutter/Dart, committed
  golden, Android release/rank-bundle, physical 360x800 API 24 profile, dashboard and local
  Supabase gates.

## Start here

1. Read [`AGENTS.md`](AGENTS.md).
2. Use [`docs/context/NEW_CHAT_BOOTSTRAP.md`](docs/context/NEW_CHAT_BOOTSTRAP.md) for a new task.
3. Read the mandatory canonical context under [`docs/context/`](docs/context/).
4. Read accepted product baselines under [`docs/product/`](docs/product/).
5. Read accepted ADRs under [`docs/decisions/`](docs/decisions/).
6. Implement only through the approved packet under [`docs/tasks/`](docs/tasks/).

## Exact next action

Review and merge the completed bounded mobile presentation pull request after all required checks pass.

```text
task: TASK-IMP-002B merge gate
pull request: #10
branch: codex/task-imp-002b-mobile-shell-home
```

Do not execute `TASK-IMP-002C`; it remains unapproved. After PR #10 merges, rerun the bounded
orchestrator to perform post-merge verification and planning before any later packet is executable.
