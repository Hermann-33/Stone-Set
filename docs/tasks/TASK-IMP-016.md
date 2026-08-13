# TASK-IMP-016 — Vercel Rate-Limit Repair

Status: `IN PROGRESS`
Date: 2026-08-13
Decision: `ADR-0014-main-only-vercel-git-deployment.md`
Superseded attempt: `ADR-0013-ci-controlled-vercel-production-deployment.md`

## Problem

Vercel Git integration created deployment activity for every intermediate PR commit. The project reached the Vercel Hobby build/deployment rate limit even though Foundation CI remained healthy, leaving a failed Vercel commit status on `main` and wasting quota on canceled preview deployments.

## Root cause

Recent implementation and documentation branches generated many Vercel previews in rapid succession. The first TASK-IMP-016 repair disabled all Git deployments and introduced a post-CI prebuilt workflow, but its first exact-main run failed closed before deployment because the repository has no `VERCEL_TOKEN` secret. No production state was changed by that failure.

## Required outcome

- Feature and PR branches must not create Vercel deployments.
- Preserve `stone-set.vercel.app` and the existing authorized Vercel project.
- Require no new deployment token or manual secret provisioning.
- Keep Vercel deployment configuration inside Foundation CI's dashboard validation lane.
- Allow only `main` to use the existing Vercel Git deployment authorization.
- Retain path-based ignored builds on `main` so non-dashboard changes do not run the Flutter Web build.

## Implementation

- `vercel.json`:
  - `git.deploymentEnabled["*"] = false`;
  - `git.deploymentEnabled.main = true`;
  - restore `ignoreCommand = "bash tool/vercel/ignore-build.sh"`.
- Remove `.github/workflows/vercel-production.yml` and the `VERCEL_TOKEN` dependency.
- Keep `vercel.json` and `tool/vercel/**` recognized as dashboard-validation inputs in `tool/ci/change-classifier.mjs`.
- Regression tests assert main-only deployment rules, ignored-build preservation, and absence of the token-dependent workflow.
- ADR-0013 is superseded by ADR-0014.

## Verified history

Initial PR #51:

```text
PR head: 5369ead3d28d2dbf05a633bec24d89acb7f72f88
Foundation CI #395 / 31669715336 — PASS
Merged main: 9f567fb29b3ba062149f31a457b8e307f02f27ee
Foundation CI #396 / 31670122647 — PASS
Vercel Production #1 / 31670486531 — FAIL CLOSED at missing VERCEL_TOKEN
```

The failed workflow stopped at its credential preflight. No Vercel build or production deployment occurred.

## Acceptance gates

1. Exact PR-head Foundation CI passes for the main-only configuration.
2. The repair branch creates no Vercel preview deployment.
3. Merge the main-only configuration to `main`.
4. Exact-main Foundation CI passes.
5. Vercel creates no feature/PR deployment for subsequent branches that contain the main-only rule.
6. The merge push follows only the permitted `main` Git deployment path; no branch-preview burst occurs.
7. Production domain remains `stone-set.vercel.app` on a READY deployment once Vercel's current rate-limit window permits the build.

## Operational note

Any older open branch created before this repair must be refreshed from `main` before its next push so it inherits the main-only `vercel.json` rule. This includes the active TASK-IMP-015 Week/workout branch.

## Out of scope

- Vercel plan upgrade.
- Changing hosting provider.
- Creating/managing a Vercel API token.
- Supabase deployment changes.
- Android/Firebase distribution changes.
