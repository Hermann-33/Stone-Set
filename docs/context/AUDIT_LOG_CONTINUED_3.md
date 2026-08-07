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

## 2026-08-06 — TASK-IMP-002A — Resumed identity/session implementation completion

### Resumption and dependency result

- verified and merged updated `main` at `52ec1886e5ed5080e129c1f3d22523c0019f07b1`, the pull request
  #8 merge containing `TASK-PD-015` commit `ac3d18f23901c0ae684b26086363a8b32486d2f9`;
- merged that baseline into `codex/task-imp-002a-identity-sessions` without rewriting history;
- applied the approved exact coordinated pins: flutter_riverpod 3.3.2, riverpod_annotation 4.0.3,
  riverpod_generator 4.0.4, riverpod_lint 3.1.4, go_router 17.4.0, go_router_builder 4.4.0,
  supabase_flutter 2.17.1 and build_runner 2.15.1;
- resolved Analyzer 12.1.0, test 1.31.0, test_api 0.7.11, build 4.0.7 and source_gen 4.2.4 with no
  override and exactly one root Dart workspace lockfile;
- generated Riverpod providers and typed routes in both clients; clean generation followed by a
  second pass wrote zero outputs.

### Identity, client and operator boundary

- implemented shared identity contracts/repository/error/cache layers and accessible Android/Web
  login, required-password-change, checking, disabled/revoked, expired and authenticated routes;
- implemented initial recovery, refresh success/failure, foreground/browser revalidation, password
  update, logout, involuntary signout quarantine and private-cache clearing behavior;
- added trusted dry-run-first operator provisioning/reset/disable/revocation tooling with explicit
  local/staging/production selection, production confirmation and environment-only credentials;
- non-local provisioning rejects synthetic/reserved alias domains unless a controlled domain or
  supported no-op/custom delivery strategy is configured; the internal alias is not a contact email.

Global public signup and anonymous signup are disabled. Email/password remains enabled because
trusted operator-created users must be able to sign in; runtime tests prove that public and anonymous
account creation remain denied. There is no client-accessible account-creation surface.

### Database and security boundary

The local identity migration creates profiles, preferences, capabilities, compatibility,
application-session/revocation and password-proof state. Every exposed object has explicit grants or
revocations. Data API object access, RLS row authorization and function `EXECUTE` are treated as
independent controls and verified through catalog and behavioral matrices. Exposed identity tables
use RLS with authenticated ownership checks; anonymous, cross-user, disabled-profile, privileged
field mutation and direct password-flag clearing are denied.

First-password-change completion requires a successful Supabase Auth password update followed by a
server operation that validates `auth.uid()`, a live application session and a fresh unconsumed Auth
audit event. Postgres does not inspect the password. The proof establishes an accepted Auth update
for that identity, not password contents or guaranteed same-client origin; this limitation is
documented and tested. A real local Auth lifecycle test denies pre-update completion and direct flag
mutation, performs the password update, observes the audit proof, completes the flag and confirms
bootstrap state.

Session deletion/revocation is not represented as instantaneous JWT invalidation. Local JWT expiry
is one hour. Bootstrap/protected RPCs enforce active profile and current application-session state,
clients revalidate on foreground/refresh, and tests model stale tokens without false instant-expiry
claims.

### Verification and review result

GitHub Actions run `31092177135` passed:

```text
Documentation and repository checks  PASS
Flutter and Dart                     PASS
Local Supabase                       PASS
```

This includes exact restore/lockfile verification, generated-source freshness, formatting, strict
analysis with the Riverpod analysis-server plugin, all Dart/Flutter/widget/browser tests, Android and
Web release builds, local Supabase clean reset/migration replay, pgTAP object/RLS/function allow-deny
matrices, database lint, public/anonymous signup denial, the real password-change lifecycle proof,
operator dry-run tests, client-bundle/no-secret review and clean tracked-tree verification.

The bounded security threat model was updated. Source/accessibility review found no task-blocking
issue: shared semantics, focus, one-primary-action layout, light/dark behavior and 200% text/narrow
layout tests pass. Later product visual system and shell refinement remain owned by 002B/002C and
were not implemented.

No remote Supabase or other remote infrastructure was accessed or modified. No real identity,
secret, credential, token, password, private key or personal data was committed. Later product
schema/UI, Storage, routines, workouts, rewards and deployment remain unimplemented.

### Verdict and exact next action

```text
TASK-IMP-002A COMPLETE ON DRAFT PR #7; PENDING REVIEW AND MERGE
```

Review and merge pull request #7, then perform post-merge verification and separately approve the
next bounded implementation packet. `TASK-IMP-002B` and `TASK-IMP-002C` are not executable.

## 2026-08-06 — TASK-PD-016 — Post-merge identity verification and 002B approval

### Merge and final-CI verification

- updated clean `main` to `2281be745b75116e70d2fed9ccf85c60e79bc4aa`;
- verified that commit is pull request #7's merge commit and that the verified source head was
  `165ba9259bac2d36ca0641fc03d1a00a67466033`;
- verified final GitHub Actions run `31093560109` passed Documentation and repository checks,
  Flutter and Dart, and Local Supabase;
- inspected the merged clients, domain/data/UI packages, migration, Auth configuration, operator
  tooling, tests and CI rather than relying only on the earlier branch report.

The merged implementation preserves the approved boundaries: private provisioned Auth, public and
anonymous signup denial, protected mobile/dashboard bootstrap and guards, server-verifiable
password-update proof, explicit Data API/RLS/function privileges, live application-session checks,
operator-only credentials and local-only infrastructure. The proof does not reveal password
contents or guarantee same-client origin. Revoked access JWTs remain cryptographically valid until
expiry, so protected operations continue to enforce live session, revocation and active-profile
state. Local JWT expiry remains 3,600 seconds.

### Compatibility and repository corrections

The merged application workspace remains one root lock graph with no overrides:

```text
flutter_riverpod       3.3.2
riverpod_annotation    4.0.3
riverpod_generator     4.0.4
go_router              17.4.0
go_router_builder      4.4.0
supabase_flutter       2.17.1
build_runner           2.15.1
analyzer               12.1.0
test                   1.31.0
test_api               0.7.11
```

Inspection found that the merged `analysis_options.yaml` selects `riverpod_lint 3.1.8`, while the
002A planning packet and technology baseline had recorded `3.1.4`. Current Dart analyzer-plugin
configuration resolves that plugin separately from the application workspace lock graph. Final CI
proved exact restore, generation and strict analysis with `3.1.8`; canonical current-state
documentation now records the actual verified configuration without rewriting earlier audit
history. Current official package evidence was rechecked; no package upgrade is authorized by this
planning task.

Stale canonical statements that called PR #7 open/unmerged, identity absent, Phase 2A partial or the
old dependency conflict active were corrected. The identity threat-model evidence now cites the
final CI and merge. The active append-only audit volume remains this file.

### Mobile packet and asset findings

All 20 `stone-set-ranks-v1` PNGs are present, 256x256 RGBA, digest-valid and in manifest order with
the accepted `rank-v6` thresholds and CC0 provenance. The manifest does not define machine IDs and
the root assets are not yet registered in a Flutter bundle. `TASK-IMP-002B` now defines a closed
presentation-only ID set, preserves `assets/ranks/` as the canonical source, assigns mobile asset
registration to the lead and requires manifest/hash/bundle verification.

The accepted mobile Home document's obsolete permanent `History` destination conflicted with the
later accepted `Progress` label. It was corrected to `Progress`, which contains the history surface.
No product behavior changed.

The packet now includes the verified merged starting state, existing identity integration points,
cross-user shell reset, exact branch/Git/documentation/CI gates, fixture-authority boundaries,
operational golden policy, API 24 profile method and thresholds, accessibility/lifecycle evidence,
complete build/regression checks and an exact completion report. It remains presentation-only and
does not authorize schedules, workout execution, SQLite, synchronization, RR/XP/wallet authority,
rank finalization or remote persistence.

### Verdict and exact next action

```text
TASK-PD-016    COMPLETE
TASK-IMP-002B  APPROVED — NOT EXECUTED
TASK-IMP-002C  PLANNED — NOT AUTHORIZED
```

After the `TASK-PD-016` planning pull request merges:

```text
Execute TASK-IMP-002B
branch: codex/task-imp-002b-mobile-shell-home
packet: docs/tasks/TASK-IMP-002B.md
```

This task changed documentation only. It changed no runtime, dependency/lockfile, Supabase, CI,
rank asset or remote infrastructure state and introduced no secret or personal data.

## 2026-08-06 — TASK-IMP-002B — Shared design system and Android shell/Home

### Starting state and coordination

- verified `TASK-PD-016` planning pull request #9 merged and started from clean `main` at
  `e90a5e2f0842bb1281a644cc7758dbbc3bcfcc86`;
- executed the approved packet on `codex/task-imp-002b-mobile-shell-home` with bounded shared-UI,
  mobile-runtime and verification subagents under lead-owned integration, Git and documentation;
- reported and corrected the stale `IMPLEMENTATION_PLAN.md` Phase 2B blocker before editing it;
- opened draft pull request #10 and did not merge, enable auto-merge or advance to `TASK-PD-017`;
- retained `TASK-IMP-002C` as planned, unapproved and non-executable.

### Implemented presentation boundary

- added shared system/light/dark semantic themes, rank-family/state tokens, typography, spacing,
  shape, motion and the packet-bounded reusable primitives;
- added an explicit closed mapping for all 20 accepted rank presentation IDs to the canonical
  `assets/ranks/` source, full-circle 12-o'clock-clockwise progress geometry and seamless exact-100
  behavior;
- added the guarded typed go_router Home/Week/Progress/Profile stateful shell while retaining the
  identity/password-change/compatibility/quarantine/logout boundaries from `TASK-IMP-002A`;
- rebuilds and disposes user-owned routing state when the authenticated user ID changes or logout
  completes;
- added immutable fixture-only Home models, repository/service/controller, accepted today/week/
  metric states, fixture rank detail/gallery routes and event-driven/reduced-motion presentation;
- added no real schedule, workout start/log/sync/result, SQLite/outbox, RR/XP/rank/wallet authority,
  dashboard shell, remote persistence or infrastructure behavior.

### Compatibility, assets and verification findings

- preserved the proven dependency family and one root Dart lockfile; added only Flutter SDK's
  `integration_test` development dependency and its resolved root-lock entries;
- exact restore, second-pass zero-output generation, formatting and fatal-info analysis passed;
- shared UI tests passed 14/14 and mobile non-golden tests passed 34/34;
- all 20 canonical rank PNGs passed count/order/name/threshold/dimension/digest verification;
- visually reviewed 12 Linux golden baselines covering 360x800 and 412x915, light/dark, 100/200
  percent text, all 20 emblems, reduced motion and the accepted progress/state contact sheet;
- corrected nondeterministic image decode by explicit asynchronous precaching and committed the
  reviewed Linux artifacts; Windows shows expected platform pixel differences and is not used to
  rewrite Linux baselines;
- an external duplicate `apps/mobile/assets/ranks/` tree appeared during verification. Each file
  was digest-identical to the canonical source and the duplicate was moved recoverably outside the
  repository. A later package-asset experiment reproduced the same copy side effect and was likewise
  quarantined; no duplicate rank tree remains in the repository;
- Flutter's Android packager did not include assets registered directly from the repository-root
  relative path. The final design keeps `assets/ranks/` as the only canonical source and uses a
  manifest-validated root command to stage exactly 20 safe-basename PNGs into the ignored
  `apps/mobile/.dart_tool/stone_set_assets/ranks/` build input before tests/builds. Tooling tests,
  a local Flutter bundle inspection and CI APK inspection enforce that boundary;
- CI now loads all 20 bundle keys in the API 24 app and inspects the release APK for exactly 20
  unique rank PNG entries.

### CI correction record

- upgraded the commit-pinned Android emulator action from the incompatible v2.9.0 source to peeled
  v2.38.0 commit `a421e43855164a8197daf9d8d40fe71c6996bb0d`;
- corrected the action's per-line script execution, disabled DDS after Flutter's VM-service error,
  and retained the approved frame thresholds rather than weakening them;
- the first valid 1080x1920 software-rendered API 24 sample proved build performance healthy
  (2.965 ms average, 8.581 ms worst) but raster performance below the approved gate (36.679 ms
  average, 47.06 percent below 32 ms). A logical 360x800 override on the same 1080x1920 framebuffer
  improved raster performance to 23.619 ms average and 65.71 percent below 32 ms but still failed;
- the accepted profile configures a physical 360x800 emulator skin, two emulator cores and records
  model/API/ABI/physical size/density/tool/command evidence. CI run `31108585023` passed with 35
  measured frames: build 2.095 ms average / 7.596 ms worst and raster 9.560 ms average / 16.560 ms
  worst, with 100 percent of both samples below 32 ms. No threshold was weakened;
- implementation-head CI run `31108585023`: `PASS` across repository, Flutter/Dart, committed
  goldens, Android release and exact 20-entry bundle inspection, API 24 profile, dashboard Web/
  Chrome and local Supabase jobs.

### Security and authority review

The bounded security review found no new server-authoritative mutation or trust boundary. Fixtures
cannot award or persist product state, widgets do not call Supabase, identity guards remain above the
shell, and public signup/password-proof/Data API/RLS/session-revocation/operator-credential controls
remain unchanged. Repository and client-bundle reviews found no credential, token, password,
personal-data or privileged-key addition. No Supabase file, remote Supabase project, Vercel project,
production signing state or other external infrastructure changed.

### Verdict and exact next action

```text
TASK-IMP-002B  IMPLEMENTED; AWAITING MERGE
TASK-IMP-002C  PLANNED — NOT AUTHORIZED
```

After all final-head checks pass, review and merge draft pull request #10. After merge, rerun the
master orchestrator for bounded post-merge verification and planning. Do not start `TASK-IMP-002C`.

## 2026-08-07 — TASK-PD-017 — Verify Phase 2B merge and approve dashboard presentation

### Merge and repository verification

- started from a clean, synchronized `main` at
  `1ab0fc56543dbd64500a9319dd6a3f014c4ccc90`;
- verified pull request #10 is merged, its head
  `97cd43443c8d4b30255ce2db7b39360b4b4ca761` is reachable from `main`, and no conflicting
  `TASK-PD-017`/`TASK-IMP-002C` branch or pull request exists;
- verified final-head GitHub Actions run `31109946478` passed the documentation/repository,
  Flutter/Dart, physical Android API 24 and local Supabase jobs; the manual golden-candidate job was
  intentionally skipped and was not a required implementation gate;
- recorded `TASK-IMP-002B` and Phase 2B as complete and merged through pull request #10.

### Stale authority correction

`AGENTS.md`, README, active context, project maturity, architecture, codebase map, roadmap,
implementation/UI plans, readiness continuation, handoff and task index still instructed the next
agent to review or merge PR #10 and described `TASK-IMP-002C` as unapproved. Those directly
conflicting current-state facts were corrected. Earlier audit entries were preserved verbatim as
append-only history. The active audit volume remains this file.

### Compatibility and packet findings

- the current dashboard remains Web-only and already uses the proven Flutter 3.44.7/Dart 3.12.2,
  Riverpod 3.3.2, go_router 17.4.0, Supabase Flutter 2.17.1 and Analyzer 12.1.0 family with one root
  lockfile and Riverpod analysis-server plugin 3.1.8;
- no new third-party dependency, dependency override, nested lockfile, migration, Supabase change or
  CI change is required for the fixture-only dashboard shell/Overview;
- current official Flutter guidance continues to support an app-centric single-page Flutter Web
  dashboard, available-width adaptive layouts, path URLs with an `index.html` rewrite, standard
  non-Wasm CanvasKit release builds and modern Chrome/Edge/Safari/Firefox support;
- `TASK-IMP-002C` now requires the official path URL strategy, direct-link/refresh/back-forward
  verification, preserved identity/bootstrap/password/compatibility/logout boundaries, complete
  prior-user presentation-state destruction, deterministic responsive/theme/accessibility evidence,
  full existing mobile/Auth/Supabase regressions and final-head CI;
- the approved task remains fixture-only. It may not persist product data, modify Supabase, deploy
  Vercel, weaken identity/session security or represent fixtures as saved records.

### Security review

This planning change adds no trust boundary or runtime operation. It preserves private account
guards, server authority, public-signup denial, first-password proof, explicit Data API/RLS/function
privileges, JWT revocation limitations, operator credential isolation and client bundle secret
controls. Repository review found no secret, credential, personal data or remote-infrastructure
change.

### Verdict and exact next action

```text
TASK-PD-017    COMPLETE
TASK-IMP-002B  COMPLETE AND MERGED
TASK-IMP-002C  APPROVED — NOT EXECUTED
```

After the planning pull request merges:

```text
Execute TASK-IMP-002C
branch: codex/task-imp-002c-dashboard-shell-overview
packet: docs/tasks/TASK-IMP-002C.md
```

This task changed documentation only. It changed no runtime, dependency/lockfile, Supabase, CI,
Android asset, Vercel or other remote infrastructure state. `TASK-IMP-003A` and later packets remain
unapproved.

## 2026-08-07 — TASK-IMP-002C — Implement responsive dashboard shell and Overview

### Repository and implementation boundary

- started the bounded implementation from merged `TASK-PD-017` base
  `76cb3166d4008084900b53b691e4ea80bc0167e9` on
  `codex/task-imp-002c-dashboard-shell-overview`;
- retained the Web-only dashboard, Android-only mobile app, one root Dart lockfile, Flutter 3.44.7,
  Dart 3.12.2, Node.js 24.11.1 and Supabase CLI 2.111.0 baselines;
- added only the official Flutter SDK `flutter_web_plugins` declaration required for path URL
  strategy; no third-party version, lockfile, Supabase or remote-infrastructure state changed;
- preserved the authenticated bootstrap, password-change, compatibility/read-only, revoked or
  disabled profile, logout, cache-clearing and user-ID isolation boundaries from `TASK-IMP-002A`.

### Implemented presentation behavior

- added typed path routes with guarded direct links, safe not-found/error routes and a
  `StatefulShellRoute` for Overview, Routines, Exercises, Reviews, Activity and Settings;
- added compact drawer, medium rail and expanded labeled-sidebar shells selected from available
  content width without changing the current route across safe resizing;
- added a deterministic fixture service/repository/Riverpod controller and attention-first Overview
  states without presenting fixture records as persisted product data;
- added route-agnostic fixture search, command palette, searchable shortcut help, standard browser
  shortcut protection, theme controls, save/offline/conflict surfaces and a comprehensive fixture
  gallery;
- added reusable responsive list-detail, supporting-pane, filter, toolbar, selectable-row, state,
  validation, confirmation, mobile-preview and reorder primitives to `packages/ui`;
- kept all exercise, guidance, media, routine, review, activity and settings product operations as
  explicit placeholders for later approved packets.

### Accessibility, design and verification findings

- reviewed the implementation against the accepted Stone Set product system, Perception-First
  attention hierarchy, Flutter adaptive-layout guidance and the current Vercel Web Interface
  Guidelines; retained semantic controls, visible keyboard focus, labelled actions, deterministic
  empty/error/status states, 200-percent text coverage, reduced-motion fixtures and non-color status
  communication;
- added unit/widget/router tests for shell tiers, guarded direct links, unknown routes, read-only
  state, 200-percent text, idle frames, fixtures, search, commands, status semantics, theme state and
  shared responsive primitives;
- local VM/widget tests, strict fatal-info analysis, formatting, two-pass zero-output generation and
  the standard Flutter Web release build passed;
- the idle-frame regression returned to zero transient callbacks with no scheduled frame after
  navigation and responsive-tier resizing;
- local Windows Chrome tests stall before test progress and were bounded without altering runtime
  behavior; the fresh Linux/Chrome GitHub Actions job is the authoritative browser gate;
- Windows dashboard golden candidates were visually inspected as development evidence only. Six
  compact/medium/expanded light/dark baselines must be regenerated on Linux, visually reviewed and
  committed before final CI and merge;
- the public Web bundle scan found no service-role marker, database URL, private key, secret token,
  committed example credential or privileged operator value. The root lockfile is unchanged.

### Security and external-state review

The bounded review found no new server-authoritative operation or persistence trust boundary.
Fixtures cannot award, publish or persist product state; dashboard feature widgets make no direct
Supabase product calls; client-owned presentation state remains below the authenticated user-keyed
provider boundary. Public-signup denial, first-password proof, Data API/RLS/function grants, JWT
revocation limitations and operator credential isolation remain unchanged. No Supabase migration,
Auth configuration, Storage bucket, remote Supabase project, Vercel project, deployment, production
signing state, secret or personal data changed.

### Current verdict and exact next action

```text
TASK-IMP-002C  IMPLEMENTED — FINAL CI AND MERGE PENDING
TASK-IMP-003A  PLANNED — NOT AUTHORIZED
```

Push the bounded branch, open a draft pull request, generate and visually review Linux dashboard
goldens, replace the Windows candidates, pass every required final-head GitHub Actions check, review
the complete diff and merge. Do not execute `TASK-IMP-003A` until the post-merge planning task.

### Linux dashboard golden promotion

- pushed implementation commit `667c9ca6a73ac10bfe4fb8b110a4e69e68c10dcd` and opened draft
  pull request #12;
- isolated workflow run `31159999651` generated exactly six Linux dashboard candidates from that
  commit and uploaded artifact
  `dashboard-golden-candidates-667c9ca6a73ac10bfe4fb8b110a4e69e68c10dcd-1`;
- visually reviewed compact, medium and expanded Overview layouts in light and dark themes: no
  overflow or clipping, clear navigation selection, stable attention-first hierarchy, consistent
  density and distinguishable focus/status outlines;
- verified the six downloaded artifact digests, copied only those exact PNGs over their Windows
  development counterparts and changed no mobile golden or other asset;
- final-head GitHub Actions, complete diff review and merge remain pending. No runtime authority,
  Supabase, deployment, secret or external-infrastructure boundary changed during promotion.
