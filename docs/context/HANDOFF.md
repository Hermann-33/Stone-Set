# Stone Set Latest Handoff

Updated: 2026-08-13

## Current task

```text
TASK-IMP-014 — Guidance/media publication freshness
ADR-0011
branch: agent/task-imp-014-guidance-publication-freshness
PR: #48
status: PARTIAL — implementation candidate green; final docs/merge/deploy pending
```

## Root cause established

Production currently has 25 published guidance revisions with maximum version 1, plus two editable guidance/media drafts. At least one draft contains unpublished text changes. Both current draft YouTube references are `preview_required`.

Atomic guidance/media publication therefore rejects before creating v2, but the dashboard previously reported only a generic media failure instead of explaining that a real successful YouTube preview is required and that preview evidence expires after one hour.

Separately, workout start originally copied the immutable routine prescription's `guidance_revision_id`. That meant a future successfully published v2 still would not reach a newly started workout if its routine had been published while guidance was v1.

## Implemented fix

Dashboard controller:

- locally fast-fails a loaded `preview_required` reference before publication reservation;
- maps server `previewRequired` to the same explicit remediation, covering missing/expired evidence;
- preserves the real IFrame playable callback as the only validation path;
- does not fabricate preview evidence or auto-publish content.

Server migration:

```text
supabase/migrations/20260812180500_latest_published_guidance_for_new_workouts.sql
```

It installs `private.resolve_latest_workout_guidance_revision_v1()` as a `BEFORE INSERT` trigger on `public.workout_session_exercises`.

A newly inserted workout-session exercise resolves the latest owner-matching finalized published guidance/media bundle. The supplied immutable routine revision is fallback only when no eligible bundle exists. Existing workout-session rows are never updated, so already-started sessions remain pinned to their original guidance.

Android remains unchanged: it continues loading exactly the revision ID pinned into the workout-session snapshot.

## Exact green candidate evidence

```text
candidate head       c82b33f7fda5edc515d16133a3ddf28fb91ea6d5
Foundation CI        31628667732 (#382), attempt 2 — PASS
PR                   #48 — draft during evidence recording
```

Passing gates:

- repository/docs and changed-path classification;
- generated source and locked tool/dependency checks;
- formatting and strict analysis;
- dashboard goldens;
- dashboard unit/widget tests;
- dashboard Chrome tests;
- production Web build and privileged-marker review;
- Local Supabase start/reset;
- Auth/private Storage lifecycle checks;
- full pgTAP suite including `guidance_publication_freshness.test.sql`;
- database lint and clean local stop.

The first Local Supabase attempt failed only because the external Docker/Supabase runtime returned rate-limit/upstream HTTP 502 during reset. Retrying that failed job alone on the identical code head passed the complete database lane. No product code was changed for the infrastructure failure.

## Exact next action

1. Commit the canonical TASK-IMP-014 context/audit completion evidence.
2. Obtain Foundation CI success on that exact final documentation head.
3. Mark PR #48 ready for review.
4. Merge PR #48 only with the exact green expected head.
5. Verify Foundation CI on the exact resulting `main` SHA.
6. Apply the exact committed migration through Supabase migration history to production project `pjltldrernuvrjsnmcqg`.
7. Verify production function/trigger installation and confirm existing sessions/drafts were not rewritten.
8. Verify Vercel production serves the dashboard built from the merged main revision.

## Remaining owner action after deployment

Engineering must **not** fake this step:

1. open each affected guidance/media draft in the production dashboard;
2. load/play the YouTube preview until Stone Set records successful validation;
3. click Publish within the one-hour validation window.

After successful publication, the next newly started workout containing that exercise will receive the latest published guidance/media bundle. A workout that was already started before publication intentionally keeps its original snapshot.

## Preserved boundaries

- routine versions, routine prescriptions and materialized week evidence remain immutable;
- published guidance/media revisions remain immutable;
- started workout snapshots remain immutable;
- online authoritative workout start remains required;
- no rank-v6, schedule-v3, reward, signing/application-ID or Firebase architecture change;
- no existing production draft is auto-published or auto-validated.

## Recent mobile state

TASK-IMP-013A merged through PR #47 at `ec8fb9324ecadc90654e011f242e523e8f517ca0`; exact-main Foundation CI #372 passed. Its physical airplane-mode acceptance remains a separate external device gate and is not part of TASK-IMP-014.
