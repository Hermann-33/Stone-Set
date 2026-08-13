# ADR-0013: CI-controlled Vercel production deployment

## Status

Accepted

- Date: 2026-08-13
- Type: Deployment / CI governance
- Supersedes: Vercel Git-triggered deployment behavior from ADR-0004
- Preserves: ADR-0004 Vercel hosting target, ADR-0007 path-sensitive fail-closed CI

## Context

Stone Set's Vercel Git integration created a deployment for each pushed commit, including intermediate implementation commits and documentation-only closeout commits. On the Hobby plan this exhausted Vercel's build/deployment rate allowance even when GitHub Foundation CI remained green. Ignored or canceled preview builds still created unnecessary Vercel deployment activity.

The dashboard is a Flutter Web static application whose production bundle is already built and inspected in Foundation CI for dashboard-relevant changes.

## Decision criteria

The deployment path must:

1. preserve exact-main Foundation CI as the release gate;
2. avoid Vercel activity for unaffected commits;
3. avoid remote Vercel builds for production deployment;
4. keep production deployment credentials out of the repository;
5. fail closed if the candidate is not the current `main` SHA;
6. preserve the existing Vercel project and production aliases.

## Decision

1. `vercel.json` disables automatic Git deployments with `git.deploymentEnabled=false`.
2. A dedicated GitHub Actions workflow runs only after a successful push-triggered Foundation CI completion on `main` from this repository.
3. The workflow checks out and verifies the exact Foundation-CI head SHA against current `main`.
4. The shared path classifier determines whether the exact main commit is dashboard-deployment relevant. Unaffected commits do not call Vercel.
5. For relevant commits, GitHub Actions uses pinned Flutter/Node tooling and pinned Vercel CLI `58.0.0` to create Vercel Build Output locally.
6. Production deployment uses `vercel deploy --prebuilt --prod`; Vercel receives the already-built output instead of running a remote build.
7. The workflow requires repository secret `VERCEL_TOKEN`. Vercel organization/project IDs are non-secret verified project identifiers.
8. The prebuilt public output is scanned again for privileged credential markers before deployment.
9. Deployment concurrency is serialized and never cancels an in-progress production deployment.

## Consequences

- PR and documentation commits no longer consume Vercel Git-build quota.
- A dashboard-relevant main commit creates at most one CI-controlled production deployment after Foundation CI succeeds.
- Documentation-only, Supabase-only, and mobile-only main commits do not call Vercel.
- Production deployment depends on a valid `VERCEL_TOKEN` GitHub Actions secret; absence fails explicitly without changing production.
- Preview deployments are no longer automatically created by Vercel Git integration.

## Security, privacy, data, and operational impact

No application data, authentication model, Supabase policy, or runtime secret is changed. `VERCEL_TOKEN` remains a GitHub secret and is never printed or committed. The exact-main and same-repository checks prevent untrusted pull-request heads from reaching the deployment credential.

## Scope boundaries

This decision does not change the Vercel project, production domain, Flutter Web application behavior, Firebase Android distribution, Supabase deployment, or Foundation CI quality gates.

## Rollback or supersession rule

A later ADR may restore Git-triggered previews or adopt another hosting/deployment system only if it preserves an explicit post-CI production gate and controls deployment quota. Immediate rollback is to remove the CI deployment workflow and restore the previous `vercel.json` Git behavior.

## Activation evidence

Activation requires:

- exact PR-head Foundation CI green;
- merge to `main`;
- exact-main Foundation CI green;
- the post-CI Vercel Production workflow either skips an unaffected commit or produces one successful prebuilt production deployment for a relevant commit.
