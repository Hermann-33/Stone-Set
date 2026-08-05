# Stone Set Latest Handoff

Updated: 2026-08-05

## Current task result

```text
Task ID: TASK-IMP-001
Title: Create Flutter and Supabase project foundation
Verdict: COMPLETE
Branch: codex/task-imp-001-foundation
Implementation commit: 7d595d5c881906b46bd4d8854c26614415c342a3
Pull request: #5 — draft
CI result: PASS — run 31002750225
```

Phase 1 is `COMPLETE`. The foundation is implemented, pushed, open for review, and all required
GitHub Actions jobs passed.

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

CI-only verification on this host:

```text
Flutter Android release APK                 PASS in CI — local Android SDK absent
local Supabase start/reset/test/lint/stop    PASS in CI — local Docker/Podman absent
GitHub Actions repository job                PASS
GitHub Actions Flutter/Dart job              PASS
GitHub Actions local Supabase job            PASS
commit/push/draft pull request                PASS
```

The Android build reaches Flutter's environment check and exits before Gradle with:

```text
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
```

The local Supabase runtime cannot start on this Windows host without a compatible container engine,
so reset, pgTAP and database lint are not claimed as host-local results. GitHub Actions run
`31002750225` executed those commands against a local CI stack and stopped only the Stone Set stack.
The same run built the Android release APK with the packet's debug/default signing constraint.

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

1. Review and merge draft pull request #5.
2. After merge, re-read repository authority and reverify the new `main` starting state.
3. Explicitly promote one bounded Phase 2 packet to `APPROVED` before implementation.
4. Optionally configure an Android SDK/`ANDROID_HOME` and Docker/Podman for full local CI parity.

Do not begin a later implementation packet until this pull request is merged and that packet is
reverified and promoted to `APPROVED`.
