# Stone Set Audit Log — Continued, Volume 3

This volume continues material audit history after `AUDIT_LOG_CONTINUED_2.md` and preserves earlier audit files unchanged.

## 2026-08-05 — TASK-PD-013 — Final implementation-readiness audit

### Scope

- review every planned Android, dashboard and Supabase aspect;
- research current official implementation/security/platform guidance;
- identify unresolved planning gaps;
- choose client state/routing architecture;
- define implementation-grade relational/server plan;
- create missing identity packet;
- synchronize roadmap, implementation and UI plans;
- preserve Phase 1 as not started.

### Starting state

- product/rank/scheduling/auth/media/offline/operations decisions existed;
- complete mobile/dashboard UI plan existed;
- rank assets existed;
- foundation packet was approved but unexecuted;
- identity work was referenced as `TASK-IMP-002A` but no packet file existed;
- database entities, RPC boundaries, concurrency, cron, compatibility, lifecycle and observability were distributed assumptions rather than one canonical plan;
- mobile UI packet still named the obsolete `History` tab instead of `Progress`.

### Research reviewed

Primary current sources included:

- Flutter application architecture, offline-first, SQL, Web and deployment guidance;
- go_router and Riverpod documentation;
- Supabase Auth, RLS, functions, migrations, pgTAP, Storage, Cron, logs, backups and production guidance;
- Vercel rewrites, headers, deployment protection and production checklist;
- Android WorkManager, notifications, alarms and storage guidance;
- WCAG 2.2;
- OWASP ASVS 5.0 and MASVS.

### Accepted technology decisions

1. Flutter and Dart remain both client technologies.
2. Riverpod is the single state/DI system.
3. go_router typed routes/stateful shells own client navigation.
4. Client architecture uses views/view models, repositories and services.
5. Domain stays independent of Flutter/Supabase.
6. SQLite/sqflite stores Android active draft/snapshot/outbox data.
7. Dashboard draft recovery uses an IndexedDB-backed adapter.
8. WorkManager provides best-effort constrained retry only.
9. No continuous polling or Supabase Realtime requirement in MVP.
10. Standard Flutter Web release build is initial baseline; Wasm is evaluated later.
11. No exact-alarm permission in MVP.
12. ASVS/MASVS/WCAG are verification baselines.

### Accepted database/server decisions

- explicit `public`, unexposed `private`, managed `auth`, `storage` and `cron` boundaries;
- complete identity, guidance, routine, schedule, workout, rank and correction domains;
- UUID/timestamptz/IANA-timezone conventions;
- immutable published/materialized/finalized records;
- append-only RR/XP/wallet/audit ledgers and exact reversal links;
- RLS on every exposed private relation;
- security invoker by default and hardened security definer only where necessary;
- explicit function grants;
- unique idempotency constraints, expected draft revisions and transaction locks;
- idempotent Cron for materialization/grants/rest/grace/finalization/cleanup;
- application-triggered catch-up for missed jobs;
- client compatibility/read-only/maintenance configuration;
- structured redacted correlation logging;
- export, deactivation and hard-delete runbook;
- phase-owned migration map and pgTAP matrix.

### Accepted synchronization decisions

- online authoritative workout start;
- immutable server session snapshot;
- transactional local autosave;
- versioned outbox with sequence and idempotency;
- sync on foreground/connectivity/explicit retry/submission/background best effort;
- pending completion remains non-authoritative;
- conflict never silently discards local work;
- same-account quarantine on session loss;
- dashboard offline support protects drafts only, not authority-changing actions.

### Security/operations decisions

- no secrets/service-role in Flutter clients;
- operator Auth actions through trusted tooling only;
- no sensitive payloads in logs;
- Vercel SPA rewrites, preview protection, CSP/security headers and cache control;
- standard build before Wasm/COOP/COEP adoption;
- migrations in Git and no remote schema edits;
- Logs Explorer/Cron/advisors initial observability;
- managed DB backup plus independent encrypted DB/Storage exports;
- Storage manifest/hash reconciliation;
- RPO 24 hours, RTO 4 hours and restore drills;
- no analytics/crash SDK without a separate decision.

### Files created

- `docs/context/TECHNOLOGY_BASELINE.md`
- `docs/context/DATABASE_AND_SERVER_PLAN.md`
- `docs/context/SYSTEM_IMPLEMENTATION_READINESS_AUDIT.md`
- `docs/context/AUDIT_LOG_CONTINUED_3.md`
- `docs/tasks/TASK-PD-013.md`
- `docs/tasks/TASK-IMP-002A.md`

### Files materially synchronized

- `docs/context/ACTIVE_CONTEXT.md`
- `docs/context/CODEBASE_MAP.md`
- `docs/context/ROADMAP.md`
- `docs/context/IMPLEMENTATION_PLAN.md`
- `docs/context/UI_IMPLEMENTATION_PLAN.md`
- `docs/context/HANDOFF.md`
- `docs/tasks/TASK-IMP-002B.md`
- `docs/tasks/TASK-IMP-002C.md`
- Pull Request #2 description/title.

### Readiness verdict

```text
Android application      ACCOUNTED FOR
Web dashboard            ACCOUNTED FOR
Database/backend         ACCOUNTED FOR
Authorization            ACCOUNTED FOR
Offline/sync             ACCOUNTED FOR
Media                    ACCOUNTED FOR
Cron/finalization        ACCOUNTED FOR
Security/accessibility   ACCOUNTED FOR
Testing/CI               ACCOUNTED FOR
Deployment/operations    ACCOUNTED FOR
Backup/lifecycle/export  ACCOUNTED FOR
```

### Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

### Exact next action

Merge planning Pull Request #2 after review, then execute `TASK-IMP-001` on `codex/task-imp-001-foundation`.

### Verdict

`COMPLETE`

Stone Set has a complete implementation-ready MVP plan. General discovery does not need to reopen unless scope or official platform evidence materially changes.

## 2026-08-05 — TASK-IMP-001 — Foundation implementation audit

### Scope

- create the native Dart Pub workspace;
- scaffold Android-only and Web-only Flutter applications;
- create neutral domain/data/ui package foundations;
- create local-only Supabase configuration and a pgTAP runner smoke test;
- add exact tool/dependency pins, root commands, hygiene checks and GitHub Actions CI;
- preserve all authentication, product, media, persistence and deployment exclusions.

### Implemented foundation

- workspace members are `apps/mobile`, `apps/dashboard`, `packages/domain`, `packages/data` and
  `packages/ui` with one root lockfile;
- mobile uses Android only, application ID `io.github.hermann33.stoneset`, API 24 and debug signing;
- dashboard uses Web only and contains the static Vercel SPA rewrite without project linkage;
- package direction is `data -> domain`, `ui -> Flutter`, `domain -> Dart SDK`;
- both applications and the neutral shared UI primitive have accessibility semantics tests;
- local Supabase contains non-secret configuration, an empty seed and one pgTAP smoke test;
- cross-platform Dart commands cover restore, formatting, analysis, tests, builds, repository checks
  and local Supabase lifecycle;
- `.github/workflows/foundation-ci.yml` contains independent repository, Flutter/Dart and Supabase jobs.

### Exact pins

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

### Verification result

Passing local evidence:

- locked root resolution;
- machine-readable tool-version check;
- repository structure, dependency direction, generated-file and secret-path checks;
- formatting and strict analysis;
- root tooling, pure Dart and Flutter widget tests;
- Flutter Web release build;
- bounded secret/configuration/dependency security review.

Environment-specific evidence before CI:

- this Windows host could not build the Android release APK because its Android SDK/`ANDROID_HOME`
  is absent;
- this Windows host could not run the Supabase lifecycle because no Docker/Podman-compatible
  container runtime is available.

No APK or local database result was inferred from scaffold presence. GitHub Actions run
`31002750225` subsequently provided the required execution evidence:

- documentation and repository checks passed;
- Flutter/Dart versions, restore, formatting, strict analysis and all unit/widget tests passed;
- Android release APK and Flutter Web release builds passed;
- local Supabase start, clean reset, pgTAP, lint and targeted stop passed;
- checks/builds left tracked files unchanged;
- commit `7d595d5` was pushed and draft pull request #5 was opened.

### Security and workflow review

- no secrets, credentials, accounts, personal data, signing material or private media were added;
- no Supabase/Vercel project was created, linked or deployed;
- the foundation CI uses pinned action commits, `contents: read` and checkout without persisted credentials;
- the pre-existing rank-asset workflow retains writable contents permission and unpinned major action
  tags. This medium risk was not introduced by `TASK-IMP-001` and is recorded as a deferred exception.

### Explicit non-implementation

No authentication/login/profile/session behavior, product schema/RLS, Storage, routines, guidance,
workouts, SQLite synchronization, RR/XP/rank/wallet behavior, media, YouTube playback, remote
infrastructure, deployment, production signing or iOS support is implemented.

### Verdict

`COMPLETE`

Every packet acceptance track has executable evidence. Host-local Android and Supabase repetition
remains unavailable, but the same required commands passed in the isolated GitHub Actions jobs.

### Exact next action

Review and merge draft pull request #5. After merge, re-read repository authority and explicitly
approve the next bounded implementation packet before Phase 2 work begins. Configure an Android SDK
and Docker-compatible runtime when full local parity with CI is needed.

## 2026-08-06 — TASK-PD-014 — Post-merge verification and identity packet approval

### Scope

- verify the merged `TASK-IMP-001` foundation and its CI evidence;
- recheck current official Flutter, Dart, Riverpod, go_router and Supabase compatibility;
- perform a bounded identity/Auth/RLS threat review;
- correct current repository authority and merged-foundation references;
- tighten and conditionally approve `TASK-IMP-002A` without implementing runtime behavior.

### Foundation verification

- pull request #5 is merged;
- merge commit is `3d0830767fd5320f33a4b7a209d937d2b59f7a6e`;
- `TASK-IMP-001` is complete and merged;
- Phase 1 is complete;
- Foundation CI run `31003516689` passed repository, Flutter/Dart and Local Supabase jobs;
- the post-merge starting tree was clean and contained the expected application, package,
  Supabase and CI foundations.

### Repository-authority corrections

`AGENTS.md` still stated that Phase 1 had not started and named `TASK-IMP-001` as the current
approved packet. That governing conflict caused the initial `TASK-PD-014` review to return
`PARTIAL`. Explicit authorization was then provided to correct it. The current phase boundary now
records Phase 0 and Phase 1 as complete and names `TASK-IMP-002A` as the next approved packet without
claiming that any identity behavior exists.

The request originally named `AUDIT_LOG_CONTINUED.md`, but `CODEBASE_MAP.md` identifies
`AUDIT_LOG_CONTINUED_3.md` as the active append-only volume. Explicit continuation authorization
confirmed that this volume must be used. Earlier audit history above remains unchanged.

### Official compatibility findings

Flutter 3.44.7, Dart 3.12.2 and the native Pub workspace remain compatible with the reviewed stack.
The approved direct pins are:

```text
flutter_riverpod       3.4.2
riverpod_annotation    4.0.6
riverpod_generator     4.0.8
riverpod_lint          3.1.8
go_router              17.4.0
go_router_builder      4.4.0
supabase_flutter       2.17.1
build_runner           2.16.0
```

The compatible analyzer/build constraints intersect under Dart 3.12.2. Riverpod lint uses the
current analysis-server plugin configuration rather than obsolete `custom_lint` configuration. The
packet requires official evidence and pins to be reverified at implementation start if they change.

Supabase CLI 2.111.0 still exposes the required local imperative migration, clean reset, pgTAP and
database-lint workflows. No local or remote Supabase state was changed during this planning task.

### Security and packet corrections

- public and anonymous signup must be disabled and verified in each environment; only trusted
  operator tooling may provision accounts;
- the first-password-change flag cannot be cleared from a client report alone; implementation must
  document and test a supported server-verifiable proof boundary without pretending Postgres can
  inspect a password;
- Data API object access, RLS row authorization and function `EXECUTE` privilege are independent
  gates with explicit least-privilege grants and independent tests;
- exposed identity tables require RLS, `TO authenticated` plus indexed ownership predicates, both
  `USING` and `WITH CHECK` for updates, active-profile enforcement and no editable-metadata
  authorization;
- session deletion, disabling or revocation does not necessarily invalidate an issued JWT
  immediately; the packet now requires an explicit expiry tolerance, revalidation, stale-token
  handling and tests that do not claim instant invalidation;
- internal aliases require a controlled domain or documented supported no-op/custom delivery hook;
  a non-routable value is permitted only for synthetic local tests;
- operator secrets remain confined to trusted tooling and are prohibited from clients, bundles,
  logs, CI artifacts and committed files;
- the packet now includes exact dependency, build, database, RLS, privilege, signup, session,
  operator-tool and Git verification gates.

The bounded threat review prioritized account creation bypass, cross-user data access, privileged
function abuse, premature password-change completion, stale-token use and operator-secret exposure.
The clarified packet provides implementation and test gates for each risk while preserving the
accepted two-user private-product model and server authority boundaries.

### Approval result

```text
TASK-IMP-002A — APPROVED — NOT EXECUTED
```

No application/package runtime, dependency manifest, lockfile, Supabase file, workflow or remote
infrastructure changed. No identity, login, profile, session, RLS or operator-tool behavior was
implemented.

### Verdict

`COMPLETE`

### Exact next action

Execute `TASK-IMP-002A`.

```text
branch: codex/task-imp-002a-identity-sessions
packet: docs/tasks/TASK-IMP-002A.md
```

## 2026-08-06 — TASK-PD-015 — Identity dependency-baseline correction

### Scope and starting evidence

- started from merged `main` commit `c371f9c8ad28dc90bef86739c2c9aa87e5450f27` on
  `codex/task-pd-015-identity-dependency-baseline`;
- draft pull request #7 remained open, draft and unmerged at head
  `7b383c1ca1fee083dfc23da755d594cf2f4c0f29`;
- Foundation CI run `31059367454` showed repository and Flutter/Dart failures at exact Pub restore;
  Local Supabase passed;
- no pull request #7 code, remote Supabase state or other remote infrastructure was changed.

### Original incompatible approval

The prior approved pins included:

```text
flutter_riverpod       3.4.2
riverpod_annotation    4.0.6
riverpod_generator     4.0.8
riverpod_lint          3.1.8
build_runner           2.16.0
test                   1.31.0
```

The real solver reproduced the conflict: riverpod_generator 4.0.8 and riverpod_lint 3.1.8 require
Analyzer 13, build_runner 2.16.0 requires Analyzer 13.3 or newer, and test 1.31.0 requires Analyzer
below 13. A test-only upgrade is also invalid because Flutter 3.44.7 pins flutter_test to test_api
0.7.11 while test 1.31.1 requires test_api 0.7.12.

### Alternatives considered

1. The minimum coordinated fallback resolved and preserved Riverpod generation, Riverpod lint and
   typed go_router generation.
2. Removing Riverpod generation resolved a manifest-only graph but failed generation against pull
   request #7 because both clients materially use generated providers/controllers. It would require
   a runtime rewrite and weaken lint coverage, so it was rejected.
3. Retaining Analyzer-13 packages and upgrading test failed at Flutter's test_api pin. A broad SDK
   upgrade would reopen the foundation boundary and was rejected.

No `dependency_overrides`, SDK change, extra workspace lockfile or test-coverage reduction was
accepted.

### Selected exact set and solver evidence

```text
flutter_riverpod       3.3.2
riverpod_annotation    4.0.3
riverpod_generator     4.0.4
riverpod_lint          3.1.4
go_router              17.4.0
go_router_builder      4.4.0
supabase_flutter       2.17.1
build_runner           2.15.1

analyzer               12.1.0
test                   1.31.0
test_api               0.7.11
build                  4.0.7
source_gen             4.2.4
riverpod               3.3.2
```

Current official package metadata reported every selected exact release as non-retracted. The
selected stable Riverpod generator/lint family transitively uses the vendor prerelease-named
`riverpod_analyzer_utils 1.0.0-dev.10`; it is non-retracted and is not directly pinned by Stone Set.
Riverpod lint 3.1.4 is the matching Analyzer-12/Riverpod-3.3.2 analysis-server plugin release and
does not require obsolete `custom_lint` configuration.

Disposable proof used the real workspace topology and produced exactly one root lockfile. Pub
restore, dependency graph and outdated review passed. Riverpod and typed go_router generation
passed in both clients; a second generation pass wrote zero outputs. Formatting, strict analysis,
root/domain Dart tests and data/UI/mobile/dashboard Flutter tests passed in the compatibility
fixture. Generation also passed against the full pull request #7 source. Existing runtime-source
analysis/test defects in that partial branch remain implementation work and were not changed here.

### Planning result and continuation

```text
TASK-PD-015   COMPLETE
TASK-IMP-002A APPROVED — PARTIALLY EXECUTED
PR #7         OPEN DRAFT, UNMERGED
```

This task changed planning/context/audit documentation only. It made no runtime, manifest, lockfile,
Supabase, migration, workflow, operator-tool, secret, personal-data or remote-infrastructure change.

Exact continuation:

```text
Resume TASK-IMP-002A
branch: codex/task-imp-002a-identity-sessions
packet: docs/tasks/TASK-IMP-002A.md
pull request: #7
```
