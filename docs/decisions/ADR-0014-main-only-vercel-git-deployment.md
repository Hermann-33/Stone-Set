# ADR-0014: Main-only Vercel Git deployment

## Status

Accepted

- Date: 2026-08-13
- Type: Deployment / CI governance
- Supersedes: `ADR-0013-ci-controlled-vercel-production-deployment.md`
- Preserves: ADR-0004 Vercel hosting target, ADR-0007 path-sensitive fail-closed CI

## Context

TASK-IMP-016 first disabled all Vercel Git deployments and added a post-Foundation-CI GitHub Actions workflow that required a `VERCEL_TOKEN` secret. PR #51 and exact-main Foundation CI were green, but the production workflow correctly failed closed because the repository does not have that deployment secret.

Stone Set already has an authorized Vercel Git integration. The quota incident was caused primarily by preview build attempts for every intermediate implementation/documentation commit rather than by the much smaller number of merges to `main`.

Vercel documents branch patterns as minimatch globs. The initial main-only rule used `"*": false`, which suppressed simple branch names but did not cover slash-containing names such as `agent/task-imp-015-week-interaction-workout-start`. Live verification on that branch entered `BUILDING`, proving the single-star rule was insufficient. The final rule therefore uses globstar `"**": false`, with an explicit `main: true` override.

## Decision criteria

The replacement must:

1. eliminate Vercel preview builds from implementation and documentation branches, including slash-containing branch names;
2. require no new secret or manually managed deployment credential;
3. preserve the existing Vercel project and production aliases;
4. retain Foundation CI validation for all merge candidates;
5. avoid remote builds for `main` commits whose dashboard/shared build inputs did not change when possible;
6. remove the permanently failing token-dependent workflow.

## Decision

1. `vercel.json` uses branch-specific deployment rules:

   ```json
   {
     "git": {
       "deploymentEnabled": {
         "**": false,
         "main": true
       }
     }
   }
   ```

2. The globstar false rule covers both simple and slash-containing feature/PR branch names. The explicit `main: true` rule allows the existing Vercel Git integration to create the production deployment for main pushes.
3. `ignoreCommand: "bash tool/vercel/ignore-build.sh"` remains active on main. If dashboard/shared build inputs did not change, the Vercel build is ignored before the Flutter build command runs.
4. `.github/workflows/vercel-production.yml` is removed; no `VERCEL_TOKEN` is required.
5. Foundation CI continues to classify `vercel.json` and `tool/vercel/**` as dashboard-relevant so deployment configuration changes receive Flutter analysis/tests/Web-build validation before merge.
6. Production promotion is controlled by Vercel's existing Git integration. It may begin when a main push is received rather than after the push-triggered Foundation CI completes. Stone Set therefore relies on the mandatory green PR-head Foundation CI/merge process as the pre-production quality gate.

## Consequences

- Intermediate PR commits do not execute Vercel preview builds, including branches named with `/`. Vercel may still create a short-lived deployment record, which should resolve `CANCELED` before build execution.
- A normal task with many implementation commits executes zero Vercel preview builds and at most one main production build when merged.
- No new GitHub secret is required.
- Main-only non-dashboard commits can still create an ignored Vercel deployment record, but `ignore-build.sh` prevents the dashboard build itself when its inputs are unchanged.
- The stronger exact-main post-CI deployment ordering from ADR-0013 is relinquished because it cannot be automated without a deployment credential under the current repository configuration.

## Security, privacy, data, and operational impact

No application data, authentication, Supabase policy, or runtime credential changes. Removing the token-dependent workflow reduces secret-management surface. Feature branches cannot execute Vercel preview builds under the final globstar rule.

## Scope boundaries

This decision does not change the Vercel project, production domain, Flutter dashboard behavior, Firebase Android distribution, Supabase deployment, or Foundation CI test requirements.

## Rollback or supersession rule

If a repository-scoped Vercel deployment credential is intentionally provisioned later, a future ADR may restore exact-main post-CI prebuilt deployments. Any such change must retain branch-preview build suppression or an equivalent quota control.

## Activation evidence

PR #52 established the main-only deployment model:

```text
PR head: 45fd13f8e7929b159a581f2cd1ac2b1a0063be9f
Foundation CI #397 / 31670860407 — PASS
Merged main: ffd046f61935e3f7d277a6e9f6a93a0f69811471
Foundation CI #398 / 31671279508 — PASS
Vercel production: dpl_GLkNcyTUXHtC3XFxrkgAicXXe9vY — READY
```

Six non-slash feature-branch records from PR #52 resolved `CANCELED`; the merge created one READY production deployment. PR #53 then proved a docs-only main commit resolves as a canceled/ignored Vercel deployment while `stone-set.vercel.app` continues to resolve to `dpl_GLkNcyTUXHtC3XFxrkgAicXXe9vY`.

A subsequent push to slash-containing branch `agent/task-imp-015-week-interaction-workout-start` exposed the `*` minimatch gap by entering `BUILDING`. The globstar correction in this ADR is accepted only after a real slash-containing branch is observed to resolve `CANCELED` before build execution.
