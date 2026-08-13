# TASK-IMP-016 — Vercel Rate-Limit Repair

Status: `COMPLETE`
Date: 2026-08-13
Decision: `ADR-0014-main-only-vercel-git-deployment.md`
Superseded attempt: `ADR-0013-ci-controlled-vercel-production-deployment.md`

## Problem

Vercel Git integration created deployment activity for every intermediate PR commit. The project reached the Vercel Hobby build rate limit even though Foundation CI remained healthy, leaving a failed Vercel commit status on `main` and wasting quota on preview builds that were later canceled.

## Root cause

Recent implementation and documentation branches generated many Vercel preview build attempts in rapid succession. The first TASK-IMP-016 repair disabled all Git deployments and introduced a post-CI prebuilt workflow, but its first exact-main run failed closed before deployment because the repository has no `VERCEL_TOKEN` secret. No production state was changed by that failed workflow.

## Implemented outcome

- Feature and PR branch Git events can still produce a Vercel deployment record, but the checked-in wildcard-off rule cancels those records before a preview build runs.
- Only `main` is enabled to run the Vercel Git production build.
- `stone-set.vercel.app` and the existing authorized Vercel project are preserved.
- No new deployment token or manual secret provisioning is required.
- Vercel configuration remains inside Foundation CI's dashboard validation lane.
- `ignoreCommand = "bash tool/vercel/ignore-build.sh"` remains active on `main`, so non-dashboard/shared main changes are ignored before the Flutter Web build command.

## Implementation

- `vercel.json`:
  - `git.deploymentEnabled["*"] = false`;
  - `git.deploymentEnabled.main = true`;
  - `ignoreCommand = "bash tool/vercel/ignore-build.sh"`.
- `.github/workflows/vercel-production.yml` and its `VERCEL_TOKEN` dependency were removed.
- `vercel.json` and `tool/vercel/**` remain recognized as dashboard-validation inputs in `tool/ci/change-classifier.mjs`.
- Regression tests assert main-only deployment rules, ignored-build preservation, and absence of the token-dependent workflow.
- ADR-0013 is superseded by ADR-0014.

## Verification evidence

Initial stronger attempt, PR #51:

```text
PR head: 5369ead3d28d2dbf05a633bec24d89acb7f72f88
Foundation CI #395 / 31669715336 — PASS
Merged main: 9f567fb29b3ba062149f31a457b8e307f02f27ee
Foundation CI #396 / 31670122647 — PASS
Vercel Production #1 / 31670486531 — FAIL CLOSED at missing VERCEL_TOKEN
```

The failed workflow stopped at credential preflight. No Vercel build or production deployment occurred from that workflow.

Superseding no-secret rollout, PR #52:

```text
PR head: 45fd13f8e7929b159a581f2cd1ac2b1a0063be9f
Foundation CI #397 / 31670860407 — PASS
Merged main: ffd046f61935e3f7d277a6e9f6a93a0f69811471
Foundation CI #398 / 31671279508 — PASS
Production deployment: dpl_GLkNcyTUXHtC3XFxrkgAicXXe9vY — READY
```

Observed Vercel behavior for PR #52:

- six feature-branch deployment records were initially queued while the account was rate-limited;
- all six resolved to `CANCELED` under the wildcard-off branch rule;
- none became a preview build;
- the merge produced one `main` production deployment only;
- that production deployment reached `READY` from exact main SHA `ffd046f61935e3f7d277a6e9f6a93a0f69811471`;
- the Vercel project still owns `stone-set.vercel.app`.

## Acceptance gates

1. Exact PR-head Foundation CI for the main-only configuration — PASS (#397).
2. Feature-branch Vercel records cancel before preview build execution — PASS (six observed PR #52 records).
3. Main-only configuration merged — PASS (PR #52).
4. Exact-main Foundation CI — PASS (#398).
5. Merge push followed only the permitted `main` production build path — PASS.
6. Production deployment from exact merged main reached `READY` — PASS (`dpl_GLkNcyTUXHtC3XFxrkgAicXXe9vY`).
7. Production project/domain preserved — PASS (`stone-set.vercel.app`).
8. Non-dashboard main commit ignored before Flutter Web build — verified by the docs-only completion closeout merge after this packet update.

## Operational note

Any older open branch created before this repair must be refreshed from current `main` before its next push so it inherits the main-only `vercel.json` rule. This includes the active TASK-IMP-015 Week/workout branch.

## Out of scope

- Vercel plan upgrade.
- Changing hosting provider.
- Creating/managing a Vercel API token.
- Supabase deployment changes.
- Android/Firebase distribution changes.
