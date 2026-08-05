# Stone Set Latest Handoff

Updated: 2026-08-05

## Current task result

```text
Task ID: TASK-IMP-001
Title: Create Flutter and Supabase project foundation
Verdict: PARTIAL
Branch: codex/task-imp-001-foundation
Commit: pending
Pull request: pending
CI result: not run
```

Phase 1 remains `IN PROGRESS`. The foundation is implemented in the working tree, but Android,
local Supabase runtime, CI and Git publication gates remain open.

## Repository structure created

- native Dart Pub workspace with members:
  - `apps/mobile`;
  - `apps/dashboard`;
  - `packages/domain`;
  - `packages/data`;
  - `packages/ui`;
- one root `pubspec.lock` and no member lockfiles;
- Android-only Flutter shell using application ID `io.github.hermann33.stoneset` and minimum API 24;
- Web-only Flutter dashboard shell with static `vercel.json` SPA rewrite;
- pure Dart domain/data foundations and a Flutter-only neutral UI foundation;
- local-only `supabase/config.toml`, empty `supabase/seed.sql` and pgTAP runner smoke test;
- root Dart tooling, exact npm tooling, configuration examples and repository checks;
- `.github/workflows/foundation-ci.yml` with independent repository, Flutter/Dart and Supabase jobs.

## Exact pins

```text
Flutter       3.44.7
Dart          3.12.2
Node.js       24.11.1
Supabase CLI  2.111.0
args          2.7.0
yaml          3.1.3
test          1.31.0
flutter_lints 6.0.0
```

Machine-readable tool pins are in `tool/tool_versions.json`; resolved dependencies are in the root
`pubspec.lock` and `package-lock.json`.

## Behavior implemented

- both Flutter applications render honest, accessible foundation placeholders;
- shared packages compile across the accepted `data -> domain`, `ui -> Flutter`,
  `domain -> Dart SDK` dependency boundaries;
- root commands orchestrate locked restore, format, analysis, tests, release builds, repository
  checks and local Supabase lifecycle checks;
- configuration examples contain public placeholders only;
- foundation CI uses read-only contents permission, pinned action commits and checkout with
  persisted credentials disabled.

## Explicitly not implemented

Authentication, login, provisioned accounts, profiles, sessions, product database schema, RLS,
Storage, routines, guidance, workouts, SQLite, synchronization, RR/XP/rank/wallet behavior, media,
YouTube, remote Supabase/Vercel projects, deployment, production Android signing and iOS remain
unimplemented.

## Verification evidence

Passing locally:

```text
locked Dart/npm resolution                  PASS
tool-version check                          PASS
repository structure/hygiene check          PASS
format check                                PASS
strict analysis                             PASS
root tooling tests                          PASS
domain/data unit tests                      PASS
UI/mobile/dashboard widget tests            PASS
Flutter Web release build                   PASS
secret/config/dependency boundary review    PASS
```

Blocked or pending:

```text
Flutter Android release APK                 BLOCKED — Android SDK/ANDROID_HOME absent
local Supabase start/reset/test/lint         BLOCKED — Docker/Podman absent
GitHub Actions CI                            NOT RUN
final commit/push/draft pull request         PENDING
```

The Android build reaches Flutter's environment check and exits before Gradle with:

```text
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
```

The local Supabase runtime cannot start without a compatible container engine, so reset, pgTAP and
database lint results cannot be claimed locally. The CI workflow is configured to run those gates on
Ubuntu and to stop the Stone Set stack even after failure.

## Security and hygiene review

- no secret, credential, account, personal data, production signing material or private media was added;
- public client examples contain only non-routable placeholders;
- no remote project was created or linked;
- no service-role/database/backup/deployment credential enters either Flutter client;
- the new foundation workflow follows least privilege.

A pre-existing rank-asset generation workflow retains `contents: write` and unpinned major action
tags. This is a medium workflow-hardening risk, was not introduced by `TASK-IMP-001`, and remains an
explicit deferred exception rather than being concealed or expanded.

## Exact next action

1. Inspect the complete working-tree diff and remove unrelated changes.
2. Commit with `TASK-IMP-001`, push `codex/task-imp-001-foundation` and open a draft pull request.
3. Obtain and review all GitHub Actions CI jobs.
4. Configure a compatible Android SDK/`ANDROID_HOME` and rerun the Android release build locally.
5. Configure Docker Desktop, Podman or another compatible runtime and rerun local Supabase
   start/reset/test/lint/stop.
6. Keep the verdict `PARTIAL` until every applicable acceptance, CI, Git and PR gate passes.

Do not begin a later implementation packet until this task is complete, merged, and the next packet
is reverified/promoted to `APPROVED`.
