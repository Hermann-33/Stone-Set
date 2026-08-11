# Stone Set

Stone Set is a private two-user muscle-growth training system with independently managed routines,
exercise guidance, and a shared normalized rank economy.

The repository is authoritative for product decisions, architecture, implementation state,
verification evidence, and handoff context. Chat history is not authoritative.

## Current state

- Phase 0 planning: `COMPLETE`
- Phase 1 foundation: `COMPLETE`
- Identity packet: [`TASK-IMP-002A`](docs/tasks/TASK-IMP-002A.md) — `COMPLETE AND MERGED` through PR #7
- Mobile presentation packet: [`TASK-IMP-002B`](docs/tasks/TASK-IMP-002B.md) — `COMPLETE AND MERGED` through PR #10
- Dashboard presentation packet: [`TASK-IMP-002C`](docs/tasks/TASK-IMP-002C.md) — `COMPLETE AND MERGED` through PR #12
- Exercise/guidance packet: [`TASK-IMP-003A`](docs/tasks/TASK-IMP-003A.md) — `COMPLETE AND MERGED` through PR #14
- Exercise media packet: [`TASK-IMP-003B`](docs/tasks/TASK-IMP-003B.md) — `IMPLEMENTED; AWAITING FINAL-HEAD CI AND MERGE`
- Current implementation branch: `codex/task-imp-003b-exercise-media-youtube`
- External infrastructure: none created or linked

The repository now contains:

- a native Dart Pub workspace for the Android app, Web dashboard, and shared packages;
- an Android-only accessible Flutter foundation shell;
- a Web-only accessible Flutter dashboard shell and static SPA rewrite;
- pure Dart `domain` and `data` package foundations plus a neutral Flutter `ui` foundation;
- local-only Supabase Auth configuration, identity migration, synthetic seed, pgTAP security tests,
  and real local Auth lifecycle tests;
- exact tool/dependency locks, non-secret configuration examples, repository checks, and root commands;
- least-privilege, fail-closed path-sensitive GitHub Actions CI for repository, Flutter/Dart,
  Android, dashboard and local Supabase checks.
- owner-scoped exercises and structured guidance, immutable publication, safe optimistic conflicts,
  typed dashboard authoring routes, and private user-partitioned IndexedDB recovery merged through
  PR #14.
- a local 003B candidate with the private `exercise-media` bucket, upload intents, immutable media
  manifests, Storage/Postgres publication compensation, image processing, official user-initiated
  YouTube preview, dashboard authoring and reconciliation foundations.
- a fixture-driven Android Home/Week/Progress/Profile shell, shared semantic themes and primitives,
  all 20 rank emblems, full-circle rank progress, accessibility coverage and reviewed Linux goldens.
- a fixture-only responsive dashboard shell and Overview with stable path routes, search, command
  palette, shortcut help, theme controls, status surfaces and reusable dashboard primitives.

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

The 003B dashboard candidate adds exact direct pins `image 4.9.1`, `file_selector 1.1.0`, and
`web 1.1.1` while preserving `supabase_flutter 2.17.1` as the only Storage client.

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
- GitHub Actions run `31109946478` passed the final `TASK-IMP-002B` repository, Flutter/Dart, committed
  golden, Android release/rank-bundle, physical 360x800 API 24 profile, dashboard and local
  Supabase gates.
- pull request #10 is merged at `1ab0fc56543dbd64500a9319dd6a3f014c4ccc90`;
- `TASK-IMP-002B` is complete and merged.
- GitHub Actions run `31165238497` passed the final `TASK-IMP-002C` repository, Flutter/Dart,
  Chrome, Android release/API 24 profile, Web release and local Supabase gates.
- pull request #12 is merged at `be0f57eee35066da0590e0cf2a3f55d6193231af`;
- `TASK-IMP-002C` is complete and merged.
- GitHub Actions run `31258974949` passed the final `TASK-IMP-003A` repository, Flutter/Dart,
  Chrome, Android release, Web release and local Supabase gates; path-sensitive policy correctly
  skipped the API 24 profile because the final diff did not affect mobile runtime performance.
- pull request #14 is merged at `eb59a3b4707ff12c154594408f1f7902555f39e0`;
- `TASK-IMP-003A` is complete and merged.

## Start here

1. Read [`AGENTS.md`](AGENTS.md).
2. Use [`docs/context/NEW_CHAT_BOOTSTRAP.md`](docs/context/NEW_CHAT_BOOTSTRAP.md) for a new task.
3. Read the mandatory canonical context under [`docs/context/`](docs/context/).
4. Read accepted product baselines under [`docs/product/`](docs/product/).
5. Read accepted ADRs under [`docs/decisions/`](docs/decisions/).
6. Implement only through the approved packet under [`docs/tasks/`](docs/tasks/).

## Exact next action

Execute the approved private Android automatic distribution packet.

```text
task: TASK-IMP-012
branch: codex/task-imp-012-private-android-distribution
packet: docs/tasks/TASK-IMP-012.md
action: implement permanent signing and trusted private Firebase App Distribution
```

TASK-IMP-011's approved media population remains independently pending; never fabricate its inputs.
