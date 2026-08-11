# ADR-0009: Permanent signing and private Android app distribution

## Status

Accepted

- Date: 2026-08-11
- Type: Android release, signing, and distribution architecture
- Supersedes: ADR-0004's temporary debug-signed private APK delivery
- Preserves: Android-first scope, stable application ID, private release, ADR-0007 gates

## Context

Stone Set currently produces debug-signed release APKs that are transferred manually. Hosted-runner
debug keys are unstable and cannot form a reliable update channel. The owner has authorized a
permanent private Android release identity and Firebase App Distribution.

## Decision criteria

- future APKs update the installed application in place;
- signing and distribution credentials never enter Git or untrusted workflows;
- required verification completes before distribution;
- only binary-relevant changes trigger release;
- the phone receives releases through a private tester channel;
- signing-key loss is recoverable.

## Decision

Stone Set uses one permanent repository-external Android JKS and Firebase App Distribution.

- Application ID remains `io.github.hermann33.stoneset`.
- Release builds use only the permanent identity; debug signing is retired for release.
- GitHub reconstructs the JKS from encrypted release-environment secrets only for an exact verified
  trusted `main` commit.
- Every APK must match the recorded public certificate SHA-256 fingerprint.
- The key has two operator-controlled backups outside Git; passwords live only in a password manager
  or protected secret store.
- `versionName` remains human-readable. `versionCode` is a stable base plus the persistent release
  workflow `run_number`, supplied with Flutter `--build-number`. Workflow replacement requires a
  deliberately higher base.
- Firebase App Distribution and private group `stone-set-testers` are the delivery channel. The
  public repository does not publish a GitHub Release or APK artifact.
- CI uses short-lived GitHub OIDC Workload Identity Federation through a least-privilege service
  account when supported, restricted to the numeric repository identity, release workflow and main.
- Relevant trusted main changes distribute after required CI. Owner manual release targets current
  main only; arbitrary refs cannot access secrets.

The debug-signed installation requires one final uninstall only after confirming no active workout,
no pending synchronization, and current authoritative server state. Later releases update in place.

## Consequences

- Releases arrive through Firebase without PC transfer.
- The signing key is a critical long-lived operational asset.
- Firebase/Google IAM and one tester enrollment become release dependencies.
- Content, dashboard, docs and server-only changes do not create APKs.

## Security, privacy, data, and operational impact

- PR/fork code never receives signing or Firebase credentials; `pull_request_target` is prohibited.
- Release jobs use pinned actions and least permissions.
- Temporary credentials/signing files are deleted and never cached or uploaded.
- Summaries expose only safe commit/version/build, APK size/hash, app ID and certificate fingerprint.
- Firebase is used only for App Distribution; no runtime SDK or unrelated product is introduced.

## Scope boundaries

No Play Store, public APK, iOS, silent updater, paid purchase, product behavior, or Supabase change.
External resources and signing-key creation require TASK-IMP-012.

## Rollback or supersession rule

Automation may be disabled without rotating the signing identity. A replacement must preserve the
key, app ID, increasing versionCode, private access, exact-candidate checks and trusted boundary.

## Activation evidence

TASK-PD-024 accepts this decision. TASK-IMP-012 supplies implementation and external evidence.
