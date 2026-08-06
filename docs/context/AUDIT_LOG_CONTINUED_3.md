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

`AGENTS.md` was narrowly corrected because the newly verified dependency stop conflicted with its
direct-execution wording. No other repository-authority, phase, security or completion rule changed.

## 2026-08-06 — TASK-IMP-002A partial implementation and dependency stop

### Scope and coordination

`TASK-IMP-002A` started from the clean PR #6 merge commit
`c371f9c8ad28dc90bef86739c2c9aa87e5450f27` on the required branch
`codex/task-imp-002a-identity-sessions`. A lead coordinator used three bounded worker tracks:

- local Supabase/database/operator tooling;
- shared packages and Android identity UI;
- dashboard identity UI and CI.

The requested Flutter architecture, Dart test/analysis, Supabase/Postgres, bounded threat-model and
UI/widget-test skills were assigned to the owning tracks. The lead retained root manifests,
lockfiles, security decisions, documentation, verification and Git ownership.

### Compatibility correction and stop condition

The prior `TASK-PD-014` record stated that the analyzer/build constraints intersected. That
historical record is preserved above, but implementation-start resolution proved that conclusion
incorrect for the complete workspace graph:

```text
riverpod_generator 4.0.8 -> analyzer ^13.0.0
build_runner 2.16.0       -> analyzer >=13.3.0
test 1.31.0               -> analyzer >=8.0.0 <13.0.0
Flutter 3.44.7 flutter_test -> test_api 0.7.11
test 1.31.1               -> test_api 0.7.12
```

The exact approved graph therefore cannot resolve. A bounded diagnostic override of analyzer/meta/
dart_style demonstrated that the transitive Mockito builder also fails against analyzer 13.3.0.
Every temporary override was removed, Riverpod's analysis-server plugin was restored, and the root
lockfile was restored byte-for-byte in semantic content to the merged foundation resolution. No
nested lockfile exists.

The minimum coherent family identified for a separately approved evaluation is
`flutter_riverpod 3.3.2`, `riverpod_annotation 4.0.3`, `riverpod_generator 4.0.4`,
`riverpod_lint 3.1.8` and `build_runner 2.15.1`. This comparison is not approval to change pins.

### Partial implementation present

- local public/email and anonymous signup are disabled with static and runtime test coverage;
- a candidate identity/session migration defines profiles, preferences, one bounded capability,
  compatibility config, safe identity events, application revocation state, explicit grants, RLS,
  bootstrap/update/password-completion functions and service-role operator functions;
- the password-completion function requires live authenticated session evidence and a matching
  post-requirement, recent, single-use `user_updated_password` Auth audit event for that user;
- trusted Node operator tooling is environment-explicit, dry-run-first, production-confirmed and
  keeps service-role credentials out of arguments, committed files and Flutter clients;
- shared identity contracts, Supabase repository/cache code, Android/dashboard Auth/session UI,
  route guards and tests are present but generated output and runtime validation are blocked;
- CI adds exact restore, generated-source freshness, client checks/builds, local Supabase replay,
  pgTAP and runtime signup-denial gates.

None of these items is accepted as implemented runtime behavior until generation, analysis, all
tests, builds, local database replay and required CI pass.

### Security review

The bounded repository threat model is recorded in
`docs/security/Stone-Set-threat-model.md`. The highest residual risks are unverified grants/RLS,
Auth-audit proof compatibility, stale-JWT paths that omit application session checks, operator
credential exposure and forced dependency overrides. The candidate migration distinguishes Data API
object grants, RLS row authorization and function `EXECUTE`; operator credentials remain confined to
trusted environment input. Revocation is documented as Stone Set application authorization rather
than instantaneous JWT destruction. The local synthetic alias domain remains prohibited for staging
or production until a controlled domain or supported no-op hook is accepted.

Node Auth-configuration/operator tests passed 14 checks. Runtime signup tests were skipped because
no local stack exists on this host. Docker/Podman and the Android SDK remain unavailable. No remote
Supabase project was linked, queried or changed; no account, secret, token, password or personal data
was committed.

### Verdict

`PARTIAL`

The material approval change required by the dependency baseline prevents a `COMPLETE` verdict.
`TASK-IMP-002B` and `TASK-IMP-002C` remain non-executable.

### Exact next action

Approve a coordinated compatible Riverpod/build_runner family, update
`docs/tasks/TASK-IMP-002A.md`, then resume generation and all verification on:

```text
branch: codex/task-imp-002a-identity-sessions
packet: docs/tasks/TASK-IMP-002A.md
```

## 2026-08-06 — TASK-IMP-002A GitHub Actions follow-up

Draft pull request #7 was opened for the partial branch. Initial GitHub Actions run `31058815335`
confirmed the exact analyzer conflict in both Dart restore jobs. The Local Supabase job reached its
final lint step after successfully starting the local stack, cleanly replaying the migration, proving
runtime signup denial and passing pgTAP; lint then reported one unused local variable in
`private.get_authenticated_bootstrap`.

The requested `gh-fix-ci` workflow inspected the actual logs. A narrow follow-up commit removed only
that unused variable and assignment without changing live-session authorization. Run `31059072713`
then passed every Local Supabase step, including database lint and scoped stack stop. Its repository
and Flutter/Dart jobs fail only at the already documented exact dependency restore:

```text
riverpod_generator 4.0.8 requires analyzer ^13.0.0
test 1.31.0 requires analyzer >=8.0.0 <13.0.0
```

No check was weakened and no pin or override changed. The CI evidence validates the candidate local
migration, RLS/privilege pgTAP suite, Auth configuration, runtime no-signup boundary and operator
safety tests, while the Dart/client acceptance gates remain blocked. Verdict remains `PARTIAL`.
