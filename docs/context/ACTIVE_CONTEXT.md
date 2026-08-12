# Stone Set Active Context

Updated: 2026-08-12

## Current position

Stone Set is a private hypertrophy training application with:

- Android Flutter client;
- Flutter Web dashboard hosted on Vercel;
- Supabase Auth/Postgres/Storage backend.

Implementation mode remains **FAST PRIVATE RELEASE**. Preserve Auth/RLS/private-data boundaries, but do not add enterprise workflow or hardening that the private app does not need.

## Product implementation status

All planned implementation phases through TASK-IMP-008 are complete. The production dashboard is hosted at `https://stone-set.vercel.app` and uses the single hosted Supabase project `pjltldrernuvrjsnmcqg`.

## Latest completed bounded task

`TASK-IMP-010 — Authoritative consistency multiplier` is complete. Its implementation merged
through PR #34 at `12eb3010064a7e17774c5c1ce564badce8b68d6a`; Foundation CI `31460872770` and
Private Release `31460872700` passed at final head `3e1e98e522d2d160e1bafca33b8a66bf0e468cb6`.
The exact committed migration was subsequently applied through migration history to production
project `pjltldrernuvrjsnmcqg` and recorded as `20260811054519_authoritative_consistency_multiplier`.

```text
codex/task-imp-010-consistency-multiplier
```

Production verification found one existing rank account, defaulted legitimately to `1.00`; the
progress payload returns a JSON number `1.00`. The exact numeric constraint and default are valid,
RLS remains enabled, authenticated access remains select-only, anonymous access remains denied and
the private payload helper remains unexecutable by client roles. No RR, XP, rank, ledger, workout,
weekly/swap, media, Auth or Storage behavior changed. The full rank-v6 perfect-week streak evaluator
remains deferred because persisted data is insufficient to reconstruct truthful weekly history.

## Active bounded task completion boundary

```text
Complete TASK-IMP-012 external recovery/install gates
branch: main
packet: docs/tasks/TASK-IMP-012.md
```

TASK-PD-024 accepts ADR-0009 and approves permanent Android signing plus trusted path-sensitive
Firebase App Distribution. This release task changes no app/product/backend behavior. The current
debug-signed install requires one workout-safe uninstall; later permanent builds update in place.
No Firebase project or signing secret existed at approval time.

Engineering is merged through PRs #41-#44 at main commit
`357cb3361176d3a58aab1f129e760e3b0c70d835`. One permanent repository-external signer, protected
main-only GitHub signing secrets and certificate fingerprint
`D2FCB14AB458AE0F77D3CC7528E09D0D3C4514A7CAA9981C7F26AD87908C2829` are active. Firebase project
`stone-set` contains Android app `1:263990431224:android:fe2bf52c3f622047225a0d`; a keyless WIF
provider restricted to the numeric GitHub repository/owner and `refs/heads/main` impersonates a
keyless least-privilege distributor service account. Private group `stone-set-testers` contains the
authorized tester.

Private Android Distribution run `31557166241` successfully built, verified and uploaded version
`0.1.0` build `1000062` as Firebase release `5j1j4rhquebu0`. The remaining external gates are an
independent signing-key backup and the workout-safe one-time debug-signed-to-permanent phone
migration/install. Phone installation has not yet been claimed.

## Independent TASK-IMP-011 content boundary

TASK-IMP-011 reuses the existing 003B stack to replace the stale exercise-detail Media placeholder.
Production has 25 active routine exercises with published text-only guidance and no editable drafts,
images, covers or YouTube references. ADR-0008 authorizes one atomic owner-scoped operation to create
an editable guidance/media draft from an immutable revision. Do not change routine usage,
prescriptions, weekly/swap behavior, scoring or historical snapshots; populate only approved media.
PR #38 merged the additive atomic RPC, strict shared binding, truthful dashboard states/actions and
focused tests at `2abf3493f0d0169f090ecf082fcf273d12fe1af5`. Final-head CI passed and production
records the migration as `20260811064653_create_guidance_media_draft_from_revision_v1`. A rollback
smoke proved the authenticated owner flow without retaining a draft. The exact inventory remains 25
published text-only exercises with zero drafts, images, covers or YouTube references. TASK-IMP-011
is partial only at the external approved-content boundary.

## Routine publication policy — authoritative

The original TASK-IMP-003C independent-review workflow is **superseded**.

Routine lifecycle is now:

```text
Create/Edit → Save → Validate → Publish
```

Rules:

- a routine owner publishes their own validated routine directly;
- no submission step is required;
- no reviewer capability is required;
- no second user is required;
- no approval/rejection decision is required;
- no review queue is part of the active product;
- publication creates an immutable `routine_versions` snapshot immediately;
- the published version becomes effective for the current training-week Monday;
- published versions remain immutable; edit by duplicating a version into a new draft.

The legacy `routine_submissions` / `routine_reviews` tables and old review routes may remain temporarily for historical/backward-compatibility purposes, but authenticated application users cannot use the retired review RPCs. Do not build new product behavior on them.

The active publication RPC is:

```text
public.publish_routine_draft_v1(routine_draft_id, expected_revision, idempotency_key)
```

The old submission/review/publication RPC surface is retired from authenticated application users.

## Current production routine

Hermann's accepted `Stone Set Hypertrophy Baseline` is published as immutable version 1 and effective for the training week beginning 2026-08-10.

## Release topology

- single hosted Supabase project;
- single Vercel dashboard project;
- private Android updates through Firebase App Distribution group `stone-set-testers`;
- no staging environment;
- no Play Store/AAB requirement;
- tracked public Supabase client configuration only; never commit service-role/database secrets.

## Engineering rule

When changing routine authoring, preserve **direct owner publication**. Do not reintroduce independent review, approval queues, or reviewer-only publication unless the product owner explicitly requests that policy again.
