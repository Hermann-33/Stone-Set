# TASK-IMP-016 — Vercel Rate-Limit Repair

Status: `COMPLETE`
Date: 2026-08-13
Decision: `ADR-0014-main-only-vercel-git-deployment.md`
Superseded attempt: `ADR-0013-ci-controlled-vercel-production-deployment.md`

## Problem

Vercel Git integration created preview build activity for intermediate commits until the Hobby build rate limit was reached. Foundation CI remained healthy, but Vercel reported `Deployment rate limited — retry in 24 hours.`

## Root causes and corrections

1. **Initial Git integration behavior:** pushed feature/PR commits could build Vercel previews.
2. **Token-dependent repair:** PR #51 disabled Git deployments and added a post-CI prebuilt deploy, but the repository had no `VERCEL_TOKEN`; the workflow failed closed before touching production.
3. **Main-only repair:** PR #52 restored the existing Vercel Git authorization with branch rules and retained `ignore-build.sh`.
4. **Slash-branch gap:** the first catch-all used `"*": false`. Vercel uses minimatch semantics; live push `6838821cbeafa112880c302f3f004d300775e792` on `agent/task-imp-015-week-interaction-workout-start` produced READY preview `dpl_Fc8HTmoKcw6kPy4wv3Ler968BZdr`, proving a single star did not cover slash-containing branch names.
5. **Final correction:** PR #54 changed the catch-all to globstar `"**": false`, retaining `"main": true`.

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

- `.github/workflows/vercel-production.yml` is removed.
- No `VERCEL_TOKEN` is required.
- Feature/PR branches, including `agent/...` names containing `/`, do not execute Vercel preview builds.
- Only `main` is enabled for the Git production path.
- Non-dashboard/shared main commits remain eligible for the existing ignored-build guard before Flutter Web build execution.
- `vercel.json` and `tool/vercel/**` remain dashboard-validation inputs for Foundation CI.

## Final verification evidence

Globstar PR #54:

```text
PR head: 22995c5e08e1597d6b24b4cb22eeae37be23d317
Foundation CI #402 / 31672330536 — PASS
Merged main: d11c3bde5fd8612e75363202e0ddadb210dc0b35
Foundation CI #403 / 31672810958 — PASS
Production deployment: dpl_EFKM4aZXk1zzQ7d2peiJKWPRePFd — READY
```

Production verification:

- `dpl_EFKM4aZXk1zzQ7d2peiJKWPRePFd` targets production and was built from exact main `d11c3bde5fd8612e75363202e0ddadb210dc0b35`;
- aliases include `stone-set.vercel.app`;
- `https://stone-set.vercel.app` returned HTTP 200 after activation.

Slash-containing branch acceptance:

```text
branch: agent/task-imp-015-week-interaction-workout-start
commit with globstar rule: 42f470f9894261ffced30c866d922b624fe0c798
GitHub Foundation CI #404: event received/running
Vercel deployment/status for the commit: none created after repeated checks
```

Because the same slash branch produced a READY preview under the prior `*` rule and produced no Vercel deployment record under `**`, the globstar suppression is directly verified against the real branch shape that exposed the defect.

## Earlier rollout evidence

PR #51:

```text
Foundation CI #395 / 31669715336 — PASS
Merged main: 9f567fb29b3ba062149f31a457b8e307f02f27ee
Foundation CI #396 / 31670122647 — PASS
Vercel Production #1 / 31670486531 — FAIL CLOSED at missing VERCEL_TOKEN
```

PR #52:

```text
Foundation CI #397 / 31670860407 — PASS
Merged main: ffd046f61935e3f7d277a6e9f6a93a0f69811471
Foundation CI #398 / 31671279508 — PASS
Production deployment: dpl_GLkNcyTUXHtC3XFxrkgAicXXe9vY — READY
```

PR #53 docs-only main verification:

```text
Merged main: 51015af1f71f865649a33dabd09173459b25fa78
Foundation CI #400 / 31671866252 — PASS
Vercel record dpl_HAmRazvhAtSiHEoW3PbSVLVg7CQn — CANCELED/ignored
```

That docs-only main push did not replace the READY production alias.

## Acceptance gates

1. Exact PR-head Foundation CI for globstar correction — PASS (#402).
2. Globstar correction merged to `main` — PASS (PR #54).
3. Exact-main Foundation CI — PASS (#403).
4. Real slash-containing `agent/...` branch does not execute/create a Vercel preview deployment — PASS (`42f470f9894261ffced30c866d922b624fe0c798`).
5. One legitimate main production deployment reaches READY — PASS (`dpl_EFKM4aZXk1zzQ7d2peiJKWPRePFd`).
6. Production alias remains healthy — PASS (`stone-set.vercel.app`, HTTP 200).

## Out of scope

- Vercel plan upgrade.
- Changing hosting provider.
- Creating/managing a Vercel API token.
- Supabase deployment changes.
- Android/Firebase distribution changes.
