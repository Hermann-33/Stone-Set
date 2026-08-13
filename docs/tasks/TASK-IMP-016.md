# TASK-IMP-016 — CI-Controlled Vercel Production Deployment

Status: `IN PROGRESS`
Date: 2026-08-13
Decision: `ADR-0013-ci-controlled-vercel-production-deployment.md`

## Problem

Vercel Git integration creates deployment activity for intermediate PR commits and non-dashboard commits. The project reached the Vercel Hobby build/deployment rate limit even though Foundation CI remained healthy, leaving a failed Vercel commit status on `main` and wasting quota on canceled previews.

## Required outcome

- Disable automatic Vercel Git deployments.
- Preserve `stone-set.vercel.app` and the existing Vercel project.
- Trigger production deployment only after successful push-triggered Foundation CI on exact current `main`.
- Skip Vercel entirely when the exact main commit has no dashboard-deployment-relevant paths.
- Build Vercel output in GitHub Actions with pinned tooling and deploy only prebuilt output.
- Fail closed if exact-main verification or deployment authentication fails.
- Keep privileged credential scanning before production deployment.

## Implementation

- `vercel.json`: `git.deploymentEnabled=false`; remove ignored-build command.
- `tool/ci/change-classifier.mjs`: recognize Vercel dashboard paths and expose `dashboard_deploy`.
- `.github/workflows/vercel-production.yml`: trusted post-CI exact-main, path-sensitive, serialized prebuilt production deployment.
- `test/ci/change_classifier.test.mjs`: regression coverage for classification and deployment workflow invariants.

## Credentials

The workflow requires GitHub repository secret `VERCEL_TOKEN`. Its value must never be committed or logged. Verified non-secret project identifiers:

- team: `team_4faE2fFiuWJ9dbJS8spoIQLr`
- project: `prj_h2naidoe8o1phyd77yILGVXrsXSW`

## Acceptance gates

1. Exact PR-head Foundation CI passes.
2. Vercel no longer creates automatic preview deployments for branch commits carrying `git.deploymentEnabled=false`.
3. Merge to `main`.
4. Exact-main Foundation CI passes.
5. Post-CI Vercel Production workflow runs from the exact main SHA.
6. For this deployment-relevant change, one prebuilt production deployment reaches `READY` and retains the production alias.
7. A later non-dashboard main commit is demonstrably skipped without calling Vercel.

## Out of scope

- Vercel plan upgrade.
- Changing hosting provider.
- Restoring automatic PR preview deployments.
- Supabase deployment changes.
- Android/Firebase distribution changes.
