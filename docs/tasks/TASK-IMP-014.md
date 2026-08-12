# TASK-IMP-014 — Guidance/media publication freshness

Updated: 2026-08-13
Status: `PARTIAL — engineering/deployment complete; owner preview/publish pending`
Implementation branch: `agent/task-imp-014-guidance-publication-freshness`
Completion-evidence branch: `agent/task-imp-014-completion-evidence`
Decision: `ADR-0011`
Implementation PR: `#48 — MERGED`

## Objective

Fix the end-to-end defect where exercise guidance/media changes made in the Web dashboard did not become visible in newly started Android workouts, while preserving immutable published revisions, routine/version/week history and already-started workout snapshots.

## Root cause

Production investigation established two independent problems:

1. At least one guidance text edit was still only in an editable draft. Both current draft YouTube references were `preview_required`, so the atomic guidance/media publisher correctly rejected publication before creating any immutable v2. The dashboard hid that exact blocker behind a generic media failure.
2. `start_workout_v1` originally created `workout_session_exercises` from the immutable routine prescription's `guidance_revision_id`. Therefore a later successful v2 publication would still not reach a new workout while the routine remained pinned to v1.

Verified pre-fix production aggregate state:

```text
published guidance revisions                   25
highest guidance version                       1
published media manifests                      25
routine-version prescriptions                   31
routine prescriptions behind latest revision    0
started session exercises behind latest          0
editable guidance drafts                         2
drafts with unpublished text change              1
draft YouTube references                         2
YouTube draft status                    preview_required (2)
```

## Implemented repair

### Dashboard publication feedback

- Loaded `preview_required` YouTube drafts fail before publication reservation with explicit remediation.
- Server `ExerciseMediaErrorCode.previewRequired`, including expired one-hour validation evidence, maps to the same message.
- The real YouTube IFrame playable callback remains the only accepted path for recording successful preview evidence.
- No validation evidence is fabricated and no owner draft is auto-published.

### New-workout guidance activation

Committed migration:

```text
supabase/migrations/20260812180500_latest_published_guidance_for_new_workouts.sql
```

The migration adds private function `private.resolve_latest_workout_guidance_revision_v1()` and a `BEFORE INSERT` trigger on `public.workout_session_exercises`.

For a newly created workout-session exercise snapshot, the server resolves the newest owner-matching published guidance revision for that exercise with a finalized `guidance_media_manifests` row. The immutable routine revision remains fallback only when no eligible bundle exists.

The trigger runs only on insert. Existing/started workout-session rows are never rewritten by later publication. Routine versions, routine prescriptions and materialized week rows remain immutable historical evidence.

Android remains unchanged and continues loading the exact revision pinned into the workout-session snapshot. No client-side `latest` lookup was added.

## Regression coverage

Dashboard:

```text
apps/dashboard/test/src/features/exercises/dashboard_guidance_publication_freshness_test.dart
```

Covers loaded `preview_required` preflight and server-side missing/expired preview evidence mapping.

Database:

```text
supabase/tests/database/guidance_publication_freshness.test.sql
supabase/tests/database/workout_execution.test.sql
```

Covers resolver trigger installation, latest-finalized revision selection for a new snapshot, immutability after later publication, next-snapshot advancement, and the existing real workout-start execution path.

## CI evidence

Exact green implementation candidate:

```text
c82b33f7fda5edc515d16133a3ddf28fb91ea6d5
Foundation CI 31628667732 (#382), attempt 2 — PASS
```

Final documentation/merge head:

```text
8133ac40cbd9b336ac9d65cb484474f7fb61a319
Foundation CI 31630001696 (#389) — PASS
```

Merged main:

```text
7c805c085761605363e5d266940449a0c8400647
PR #48 — MERGED
Foundation CI 31630620692 (#390) — PASS
```

Applicable gates passed on exact main: repository/docs, generated sources, formatting, strict analysis, dashboard goldens, dashboard unit/widget tests, Chrome tests, production Web build/credential review, Local Supabase reset, Auth/private Storage lifecycle, full pgTAP and database lint. Android/API-24 lanes were correctly skipped by path classification because no mobile runtime/performance path changed.

One earlier candidate Local Supabase attempt hit external Docker/Supabase rate limiting/upstream HTTP 502 during reset. The failed job alone was retried on the identical code head and passed the complete database lane; no product code was changed for the infrastructure failure.

## Production Supabase deployment

The exact committed migration was applied through Supabase migration history to production project `pjltldrernuvrjsnmcqg` and recorded as:

```text
20260812190919_latest_published_guidance_for_new_workouts
```

Post-deploy verification confirmed:

```text
resolver function exists                         true
resolver trigger exists                          true
anon direct execute                              false
authenticated direct execute                     false
workout_session_exercises count                  11 (unchanged)
guidance_drafts count                             2 (unchanged)
guidance_revisions count                         25 (unchanged)
maximum guidance version                          1 (unchanged)
preview_required draft YouTube references         2 (unchanged)
```

No historical workout session, draft or published guidance row was rewritten by deployment.

## Production dashboard deployment

Vercel production deployment:

```text
deployment   dpl_ApzpAb69cf6pe5BuL3jY5q6jYmAp
state        READY
target       production
Git SHA      7c805c085761605363e5d266940449a0c8400647
alias        stone-set.vercel.app
```

The production dashboard therefore contains the actionable preview-required publication feedback from the exact merged main revision.

## Protected behavior / non-goals

Unchanged:

- immutable guidance/media revisions;
- immutable routine versions/materialized prescription evidence;
- already-started workout guidance snapshots;
- online authoritative workout start;
- server authority for submission, RR, XP, wallet, rank, penalties, PRs and finalization;
- `rank-v6` and `schedule-v3`;
- Android application ID/signing/Firebase architecture;
- YouTube successful-preview requirement;
- private Storage authorization.

## Remaining owner action

Engineering and production deployment are complete. The production drafts themselves cannot be legitimately published until the owner supplies the required real playback evidence.

For each affected draft:

1. open the exercise in `stone-set.vercel.app`;
2. load/play the YouTube preview until Stone Set records it as validated;
3. click **Publish** within the one-hour validation window.

If a video is no longer wanted, remove that YouTube reference and publish the remaining valid guidance/media instead.

After a successful publication, the **next newly started workout** containing that exercise receives the latest published guidance/media. A workout that was already started before publication intentionally retains its prior immutable snapshot.

No Android app update is required for TASK-IMP-014 because the mobile client already consumes the server-pinned session revision correctly.

## Verdict

`PARTIAL` only at the owner-controlled content-publication boundary. Engineering, CI, merge, production database deployment and production dashboard deployment are complete and verified.
