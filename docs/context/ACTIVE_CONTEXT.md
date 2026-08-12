# Stone Set Active Context

Updated: 2026-08-13

## Current position

Stone Set is a private hypertrophy training application with an Android Flutter client, Vercel-hosted Flutter Web dashboard, Supabase Auth/Postgres/Storage backend and private Android Firebase distribution.

Implementation mode remains **FAST PRIVATE RELEASE**. Preserve Auth/RLS/private-data boundaries, immutable history and server authority.

## TASK-IMP-014 — engineering/deployment complete

```text
Task          TASK-IMP-014 — Guidance/media publication freshness
ADR           ADR-0011
PR            #48 — MERGED
main          7c805c085761605363e5d266940449a0c8400647
main CI       Foundation CI #390 / 31630620692 — PASS
status        PARTIAL only because owner preview/publish action remains
```

### Root cause

Production had 25 published guidance revisions with maximum version 1, two editable drafts, at least one unpublished text change and two draft YouTube references at `preview_required`.

Atomic publication was correctly rejecting missing YouTube preview evidence, but the dashboard hid that precise blocker behind a generic media error. Separately, newly started workouts were copying the immutable routine prescription's old guidance revision, so a later successful content-only publication still would not reach future workouts.

### Production repair

Dashboard:

- loaded `preview_required` fails before publication reservation with explicit remediation;
- server `previewRequired`, including expired one-hour evidence, maps to the same message;
- genuine IFrame playable evidence remains mandatory; no validation/publication is fabricated.

Supabase:

```text
tracked migration   20260812180500_latest_published_guidance_for_new_workouts.sql
production history  20260812190919_latest_published_guidance_for_new_workouts
```

`private.resolve_latest_workout_guidance_revision_v1()` now resolves the latest owner-matching finalized published guidance/media bundle when a **new** `workout_session_exercises` snapshot is inserted. The routine-pinned revision remains fallback. Existing workout snapshots are never rewritten.

Post-deploy verification:

```text
resolver function/trigger             present
anon/authenticated direct execute     denied
workout_session_exercises             11, unchanged
guidance drafts                        2, unchanged
guidance revisions                    25, unchanged
max guidance version                   1, unchanged
preview_required YouTube drafts        2, unchanged
```

Vercel production:

```text
deployment   dpl_ApzpAb69cf6pe5BuL3jY5q6jYmAp
state        READY
target       production
Git SHA      7c805c085761605363e5d266940449a0c8400647
alias        stone-set.vercel.app
```

No Android code change or app update is required for TASK-IMP-014; mobile already consumes the exact server-pinned workout-session guidance revision.

## Exact next owner action

For each affected production draft:

1. open the exercise in `stone-set.vercel.app`;
2. load/play the YouTube preview until Stone Set records successful validation;
3. click **Publish** within the one-hour validation window.

If a video is no longer wanted, remove that YouTube reference and publish the remaining valid guidance/media.

After successful publication, the **next newly started workout** containing that exercise uses the newest published bundle. An already-started workout intentionally keeps its immutable earlier snapshot.

## Preserved boundaries

- routine versions/prescriptions/materialized weeks remain immutable historical evidence;
- published guidance/media revisions remain immutable;
- started workout snapshots remain immutable;
- online authoritative workout start remains required;
- Android never selects authoritative `latest` guidance itself;
- `rank-v6`, `schedule-v3`, reward authority, Android app ID/signing and Firebase architecture are unchanged;
- no draft was auto-published and no YouTube preview evidence was fabricated.

## Recent mobile slice

TASK-IMP-013A merged through PR #47 at `ec8fb9324ecadc90654e011f242e523e8f517ca0`; exact-main Foundation CI #372 passed. Its real-device airplane-mode acceptance remains an independent physical gate.

## Production topology

```text
dashboard            https://stone-set.vercel.app
Supabase project      pjltldrernuvrjsnmcqg
Firebase project      stone-set
Android Firebase app  1:263990431224:android:fe2bf52c3f622047225a0d
tester group          stone-set-testers
```

Direct owner routine publication remains authoritative: `Create/Edit → Save → Validate → Publish`. Do not reintroduce the retired independent review/approval lifecycle without a new explicit decision.
