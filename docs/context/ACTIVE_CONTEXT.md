# Stone Set Active Context

Updated: 2026-08-11

## Current position

Stone Set is a private hypertrophy training application with:

- Android Flutter client;
- Flutter Web dashboard hosted on Vercel;
- Supabase Auth/Postgres/Storage backend.

Implementation mode remains **FAST PRIVATE RELEASE**. Preserve Auth/RLS/private-data boundaries, but do not add enterprise workflow or hardening that the private app does not need.

## Product implementation status

All planned implementation phases through TASK-IMP-008 are complete. The production dashboard is hosted at `https://stone-set.vercel.app` and uses the single hosted Supabase project `pjltldrernuvrjsnmcqg`.

## Latest completed bounded task

`TASK-IMP-009 — Android visual system and motion modernization` is complete and merged through
pull request #31 at `e59303d5acd4dbfe6706822b100913c531dc9297` from final implementation head
`f3f41bd95294e73b00c10f42f24ea43c4571411c`. It upgrades mobile theme tokens, typography,
shared components, Home/rank, Week, active workout/guidance, Progress, Profile and identity
presentation with event-driven motion, deterministic reduced-motion behavior and reviewed Linux
goldens within `docs/tasks/TASK-IMP-009.md`.

It did not authorize backend, persistence, Auth/RLS, Storage, RPC, SQLite, navigation meaning,
rank, RR, XP, PR, penalty, wallet, scheduling, swap, workout, progression, protection, correction,
routine-publication or other product-semantics changes. Direct owner routine publication remains
authoritative. The completed implementation branch was:

```text
codex/task-imp-009-mobile-ui-polish
```

## Next approved bounded task

`TASK-IMP-010 — Authoritative consistency multiplier` is merged through PR #34 at
`12eb3010064a7e17774c5c1ce564badce8b68d6a`. Its exact final head passed Foundation CI and Private
Release, including Local Supabase, Android release, Linux goldens and API 24. The code removes the
authenticated Home fixture leak and exposes a server-owned base `1.00×` through the existing
progress account contract.

Overall verdict remains **PARTIAL** because the production migration is not deployed. The current
workspace has no authenticated Supabase CLI session, operator credential environment or
linked-project metadata. Remote production state was not changed. The full rank-v6 perfect-week
streak evaluator remains deferred because persisted data is insufficient to reconstruct truthful
weekly history.

```text
branch: codex/task-imp-010-consistency-multiplier
packet: docs/tasks/TASK-IMP-010.md
```

Do not seed any account at `1.50×`, infer historical perfect weeks, change weekly/swap behavior, or
begin TASK-IMP-011 until the TASK-IMP-010 production migration is deployed and verified.

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
- private Android APK sideload;
- no staging environment;
- no Play Store/AAB requirement;
- tracked public Supabase client configuration only; never commit service-role/database secrets.

## Engineering rule

When changing routine authoring, preserve **direct owner publication**. Do not reintroduce independent review, approval queues, or reviewer-only publication unless the product owner explicitly requests that policy again.
