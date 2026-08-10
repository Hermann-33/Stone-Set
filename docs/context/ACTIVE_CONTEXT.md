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

## Next authorized bounded task

`TASK-IMP-009 — Android visual system and motion modernization` is `APPROVED — NOT EXECUTED`.
It is a deliberate post-release presentation, accessibility and event-driven-motion pass for the
existing Flutter Android client. It may improve theme tokens, typography, shared components,
mobile surfaces, transitions, microinteractions, reduced-motion behavior and visual evidence only
within `docs/tasks/TASK-IMP-009.md`.

It does not authorize backend, persistence, Auth/RLS, Storage, RPC, SQLite, navigation meaning,
rank, RR, XP, PR, penalty, wallet, scheduling, swap, workout, progression, protection, correction,
routine-publication or other product-semantics changes. Direct owner routine publication remains
authoritative. The authorized implementation branch is:

```text
codex/task-imp-009-mobile-ui-polish
```

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
