# TASK-IMP-016 — Vercel Rate-Limit Repair

Status: `IN PROGRESS — GLOBSTAR CORRECTION`
Date: 2026-08-13
Decision: `ADR-0014-main-only-vercel-git-deployment.md`
Superseded attempt: `ADR-0013-ci-controlled-vercel-production-deployment.md`

## Problem

Vercel Git integration created preview build activity for intermediate commits until the Hobby build rate limit was reached. Foundation CI remained healthy, but Vercel reported `Deployment rate limited — retry in 24 hours.`

## Root causes and corrections

1. **Initial Git integration behavior:** every pushed branch commit could build a Vercel preview.
2. **Token-dependent repair:** PR #51 disabled Git deployments and added a post-CI prebuilt deploy, but the repository had no `VERCEL_TOKEN`; the workflow failed closed before touching production.
3. **Main-only repair:** PR #52 restored the existing Vercel Git authorization with branch rules and retained `ignore-build.sh`. Production recovered and feature branches with simple names canceled before build.
4. **Slash-branch gap:** the initial rule used `"*": false`. Vercel documents these patterns as minimatch; live push `6838821cbeafa112880c302f3f004d300775e792` on `agent/task-imp-015-week-interaction-workout-start` entered `BUILDING`, showing a single-star rule does not cover that slash-containing branch name.
5. **Final correction:** use `"**": false` plus `"main": true` so globstar covers all feature/PR branch names, including `/`.

## Final configuration

```json
{
  "git": {
    "deploymentEnabled": {
      "**": false,
      "main": true
    }
  },
  "ignoreCommand": "bash tool/vercel/ignore-build.sh"
}
```

- `.github/workflows/vercel-production.yml` remains removed.
- No `VERCEL_TOKEN` is required.
- `vercel.json` and `tool/vercel/**` remain dashboard-validation inputs for Foundation CI.
- Non-dashboard main pushes are ignored before the Flutter Web build command.

## Verified history

PR #51:

```text
Foundation CI #395 / 31669715336 — PASS
Merged main: 9f567fb29b3ba062149f31a457b8e307f02f27ee
Foundation CI #396 / 31670122647 — PASS
Vercel Production #1 / 31670486531 — FAIL CLOSED at missing VERCEL_TOKEN
```

PR #52:

```text
PR head: 45fd13f8e7929b159a581f2cd1ac2b1a0063be9f
Foundation CI #397 / 31670860407 — PASS
Merged main: ffd046f61935e3f7d277a6e9f6a93a0f69811471
Foundation CI #398 / 31671279508 — PASS
Production deployment: dpl_GLkNcyTUXHtC3XFxrkgAicXXe9vY — READY
```

Observed for PR #52:
- six feature-branch deployment records resolved `CANCELED`;
- none became a preview build;
- merge produced one READY production build;
- `stone-set.vercel.app` resolves to the READY production deployment.

PR #53 docs-only closeout:

```text
Merged main: 51015af1f71f865649a33dabd09173459b25fa78
Foundation CI #400 / 31671866252 — PASS
Vercel record dpl_HAmRazvhAtSiHEoW3PbSVLVg7CQn — CANCELED/ignored
```

The docs-only main push did not replace production. `stone-set.vercel.app` continued returning HTTP 200 from `dpl_GLkNcyTUXHtC3XFxrkgAicXXe9vY`.

## Remaining acceptance gate

The globstar correction is complete only when:

1. exact PR-head Foundation CI passes;
2. the correction merges to `main`;
3. exact-main Foundation CI passes;
4. a real slash-containing `agent/...` branch containing `"**": false` produces a Vercel record that resolves `CANCELED` before preview build execution;
5. the production alias remains on a READY deployment.

## Out of scope

- Vercel plan upgrade.
- Changing hosting provider.
- Creating/managing a Vercel API token.
- Supabase deployment changes.
- Android/Firebase distribution changes.
