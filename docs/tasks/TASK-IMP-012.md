# TASK-IMP-012 — Private Android automatic distribution

Updated: 2026-08-11
Status: `APPROVED — NOT EXECUTED`
Branch: `codex/task-imp-012-private-android-distribution`

## Objective

Replace manual debug-signed APK transfer with permanent signing and automatic private Firebase App
Distribution for verified mobile-relevant commits on `main`.

## Mandatory repository reads

Read AGENTS and canonical context in order, then APPLICATION_WORKFLOW, ADR-0003/0004/0007/0009,
TASK-IMP-005A/008, TASK-PD-024, PRIVATE_RELEASE, Android Gradle, release workflow/script, classifier,
workflow tests and ignore rules. Re-check official Firebase ADC/App Distribution, Google WIF, GitHub
Actions security and Android signing/versioning documentation before external configuration.

## Verified starting state

```text
accepted main                 d1ad274a6fb63092a150f8e07be67c6f88dc8ffa
application ID                io.github.hermann33.stoneset
mobile package version        0.1.0+1
release signing               debug
automatic phone distribution  none
Firebase repository config    none
GitHub release secrets        none
local Firebase/gcloud auth    unavailable
repository visibility         public
```

## Exact scope

### Signing, identity and versioning

- generate exactly one strong permanent JKS outside Git with random passwords and stable alias;
- configure fail-closed Gradle release signing from temporary environment/file inputs and remove
  debug signing from release;
- store keystore/passwords/alias only in GitHub encrypted release-environment secrets; never log,
  cache, artifact, commit or embed them;
- retain the original until two independent operator backups and password-manager storage are
  confirmed; never delete the sole copy;
- record only the public certificate SHA-256 and verify it before/after every build;
- keep `io.github.hermann33.stoneset` and human-readable versionName stable;
- use `versionCode = 1,000,000 + github.run_number` via `--build-number`; assert positive, below
  2,100,000,000 and above the permanent-release baseline. Workflow replacement raises the base.

### Trusted path-sensitive workflow

- refactor Private Release into `Private Android Distribution`; do not duplicate dashboard/full CI;
- automatically run only after Foundation CI succeeds for exact current trusted main;
- allow owner dispatch for current main only, never arbitrary refs;
- independently classify the exact diff and distribute only when `mobile_build` is true; manual
  dispatch may explicitly force current main; missing/unknown history fails closed;
- pin third-party actions by SHA; use only `contents: read` and required `id-token: write`;
- never use `pull_request_target`, PR heads, untrusted artifacts/caches or release secrets in PRs;
- prevent overlapping distributions from racing without cancelling after Firebase receives an APK;
- restore exact locks, stage rank assets, reconstruct/verify/delete JKS, build once and distribute the
  exact verified APK;
- verify package, versionName/code, signer/fingerprint, size and SHA-256 with Android build tools;
- generate safe notes/summary; no tester email, secret, public Release, or public-repo APK artifact.

### Firebase and tester channel

- reuse a suitable Firebase project/app or create one minimum dedicated project and exactly one
  Android registration for `io.github.hermann33.stoneset`;
- enable only App Distribution/required APIs; add no runtime Firebase SDK or unrelated product;
- create/reuse least-privilege CI service account and GitHub OIDC WIF restricted to numeric repo ID,
  exact repository, main and release workflow;
- use short-lived ADC with pinned Google auth action; create no JSON key unless WIF is proven
  unsupported and the residual risk is documented;
- keep only non-secret identifiers in repository/environment variables and sensitive values in secrets;
- create/reuse private `stone-set-testers`, add only authorized tester externally, never log email;
- use pinned Firebase CLI `appdistribution:distribute` with app/group/safe notes;
- perform and inspect a real smoke distribution when authenticated.

### Migration and operations

- document: no active workout, no pending sync, server current; uninstall old debug app once; install
  first Firebase build; sign in; verify Home, Week, Progress, Profile and workout history;
- document later in-place updates, tester enrollment, key backup/restore/rotation and failure recovery;
- content/backend/dashboard-only changes remain outside APK distribution.

## Non-goals and protected behavior

No Play Store/AAB, public APK, iOS, self-updater, silent install, dangerous permission, unrelated
Firebase product, paid purchase, runtime/dependency/product/Supabase change, weakened CI/API-24/Auth/
RLS/privacy, or TASK-IMP-011 content invention.

## Acceptance criteria

1. Release Gradle never uses debug signing and fails closed without permanent inputs.
2. JKS is untracked, recoverable and available only through protected secrets.
3. APK has stable ID, expected certificate and increasing versionCode.
4. Required CI passes before exact-main distribution.
5. Mobile/unknown or trusted manual events release; docs/dashboard/content/server-only diffs do not.
6. Firebase receives the verified APK only for `stone-set-testers`.
7. Summaries contain safe integrity evidence; PR/fork/branch code cannot access secrets.
8. Workout-safe one-time migration is documented and future releases update in place.
9. No unrelated behavior, backend, paid, public-distribution or secret change occurs.

## Required verification

- repository/links/packet/audit, workflow YAML, pinned-action/security tests, classifier tests,
  `git diff --check`, exact restores, clean tree and secret/personal-data scans;
- trusted CI Android release build with explicit build number and permanent signing inputs;
- apksigner certificate verification, package/version inspection, APK size and SHA-256;
- relevant Flutter checks only if runtime Dart changes; final-head Foundation/release workflows;
- Firebase project/app/API/IAM/provider/group and CLI smoke inspection without tester-email exposure;
- two-backup recovery evidence without displaying secrets; complete diff/artifact/log review.

## Required documentation updates

Update only owned facts in AGENTS, ACTIVE_CONTEXT, ROADMAP, HANDOFF, CODEBASE_MAP if ownership changes,
PRIVATE_RELEASE, task/ADR indexes, this packet and append-only active audit. Preserve TASK-IMP-011.

## Git requirements

```text
branch: codex/task-imp-012-private-android-distribution
no main work or history rewriting; commits contain TASK-IMP-012
push, draft PR, complete diff, exact final-head CI, verified merge, sync/ancestry proof
```

## External gates and verdict

Complete repository/GitHub work first. Use PARTIAL only for unavoidable Google authorization, tester
acceptance or confirmed independent key backup. Never request secrets in chat or claim phone install.

## Required completion report

Report verdict/task/main/branch/commit/PR; app ID/version/code/signing/fingerprint/backup; Firebase
project/app/group/upload/release; workflow trigger/filter/trust; APK path/size/SHA; one-time migration;
future update flow; files/external changes/checks/CI/security/secrets; blocker and exact next action.
