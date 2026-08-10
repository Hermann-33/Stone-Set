# Stone Set Active Context

Updated: 2026-08-10

## Current position

Stone Set is a private two-user hypertrophy training application:

- Android Flutter client;
- Flutter Web dashboard;
- Supabase Auth/Postgres/Storage backend.

Implementation mode: **FAST TWO-USER PRIVATE RELEASE**. Preserve the accepted Auth/RLS/private-data boundaries, but do not add enterprise hardening or release infrastructure that the two users do not need.

## Product implementation complete

```text
TASK-IMP-001  Foundation                           COMPLETE
TASK-IMP-002A Identity/sessions                    COMPLETE
TASK-IMP-002B Shared UI + Android shell/Home       COMPLETE
TASK-IMP-002C Dashboard shell/Overview             COMPLETE
TASK-IMP-003A Exercise library/guidance            COMPLETE
TASK-IMP-003B Private media/YouTube                COMPLETE
TASK-IMP-003C Routine authoring/review/publication COMPLETE
TASK-IMP-004  Weekly plans/free+paid swaps         COMPLETE
TASK-IMP-005A Workout logger/SQLite/sync            COMPLETE
TASK-IMP-005B Workout guidance/media playback       COMPLETE + MERGED
TASK-IMP-006  RR/XP/rank/wallet/Progress            COMPLETE
TASK-IMP-007  Progression/protection/corrections    COMPLETE
```

005B was merged through PR #24 after exact clean-head Foundation CI passed.

## Current task — TASK-IMP-008

```text
Task:   TASK-IMP-008 — Minimal private release
PR:     #25
Branch: codex/task-imp-008-minimal-release
Mode:   FAST TWO-USER PRIVATE RELEASE
```

### Hosted backend

The single connected Supabase project `Stone Set` (`pjltldrernuvrjsnmcqg`) now contains:

- the ten accepted historical migrations through TASK-IMP-007;
- `private_release_config` from TASK-IMP-008;
- a private `exercise-media` bucket with the accepted 5 MB JPEG/PNG/WebP restriction;
- a current non-maintenance `production` compatibility row;
- no synthetic seed users/data.

Production client URL/publishable key are committed in `config/dart_defines.production.json`. No service-role or database secret is committed.

### Release paths

- preferred repeat Android/dashboard build: `tool/release/private-release.ps1`;
- narrow GitHub artifact build: `.github/workflows/private-release.yml`;
- release/provisioning/deploy instructions: `docs/release/PRIVATE_RELEASE.md`;
- existing `apps/dashboard/vercel.json` remains the dashboard SPA routing contract.

Android intentionally uses the existing debug signing configuration for private sideloading. Repeat update APKs should be built on the same Windows account/machine where practical so the signer stays stable.

## Exact-head verification in progress

```text
Private Release run: 31395290560
Foundation CI:       31395290559
Head at trigger:     cc466b74d154b8758f1e21def24cf3d75eb3fdcd
```

Only demonstrated release-specific defects should be fixed.

## Remaining non-code release actions

- Supabase Dashboard: keep public signup and anonymous signup disabled;
- create/provision exactly two users using `docs/release/PRIVATE_RELEASE.md`;
- create/link one Vercel project and deploy the built dashboard if web access is desired;
- perform the short smoke path once after provisioning/deployment.

These are operator/deployment actions, not Codex implementation tasks.

## Codex policy

Codex is fallback only for a concrete local production APK/Web build or signer defect that connected GitHub/Supabase tooling cannot reproduce. Do not use Codex for planning, Supabase deployment, Vercel setup, documentation or broad verification.
