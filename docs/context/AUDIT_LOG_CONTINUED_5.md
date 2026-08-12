# Stone Set Audit Log — Continued, Volume 5

This volume continues material audit history after `AUDIT_LOG_CONTINUED_4.md`. Earlier audit files remain unchanged and append-only.

## 2026-08-13 — TASK-IMP-014 — Guidance/media publication freshness production deployment

### Reported defect

The owner reported that exercise media and guidance text changed in the Web dashboard did not update the Android workout experience after Publish.

### Root cause

Production read-only investigation found 25 published guidance revisions with maximum version 1, two editable drafts, at least one draft with unpublished text changes and two draft YouTube references at `preview_required`.

Two independent defects were established:

1. atomic guidance/media publication correctly rejected the missing successful-preview evidence, but the dashboard collapsed `preview_required` into a generic media failure, hiding the real remediation;
2. `start_workout_v1` originally populated new workout-session exercise snapshots from the immutable routine prescription's old guidance revision, so a later successful content-only revision would not reach newly started workouts.

The real Web YouTube IFrame playable callback was inspected and remained correctly wired. No synthetic validation path was added.

### Accepted decision

`ADR-0011 — Latest published guidance for newly started workouts` preserves immutable routine/version/week evidence and already-started workout snapshots while allowing content-only publication to activate at creation of a new workout-session exercise snapshot.

### Implemented repair

Dashboard:

- loaded `preview_required` fails before publication reservation with explicit instructions;
- server `ExerciseMediaErrorCode.previewRequired`, including expired one-hour evidence, maps to the same remediation;
- genuine IFrame playable evidence remains required;
- no owner draft or validation evidence is fabricated.

Server:

```text
supabase/migrations/20260812180500_latest_published_guidance_for_new_workouts.sql
```

The migration adds `private.resolve_latest_workout_guidance_revision_v1()` plus a `BEFORE INSERT` trigger on `public.workout_session_exercises`. New snapshots resolve the latest owner-matching finalized published guidance/media bundle; the routine revision remains fallback. Existing session rows are never rewritten.

Android remains unchanged and consumes the exact session-pinned revision.

### Verification and merge evidence

```text
implementation candidate   c82b33f7fda5edc515d16133a3ddf28fb91ea6d5
candidate CI               31628667732 (#382), attempt 2 — PASS
final PR head              8133ac40cbd9b336ac9d65cb484474f7fb61a319
final-head CI              31630001696 (#389) — PASS
PR                         #48 — MERGED
main                       7c805c085761605363e5d266940449a0c8400647
exact-main CI              31630620692 (#390) — PASS
```

Passing applicable checks included repository/docs, generated sources, formatting, strict analysis, dashboard goldens, dashboard unit/widget and Chrome tests, production Web build/credential-marker review, Local Supabase reset, Auth/private Storage lifecycle, full pgTAP and database lint.

One earlier Local Supabase attempt encountered external Docker/Supabase rate limiting/upstream HTTP 502 during reset. Retrying only that failed job on the identical code head passed the complete database lane; no code change was made for the external infrastructure failure.

### Production Supabase deployment

The exact committed migration was applied through migration history to project `pjltldrernuvrjsnmcqg` and recorded as:

```text
20260812190919_latest_published_guidance_for_new_workouts
```

Post-deploy verification:

```text
resolver function exists                         true
resolver trigger exists                          true
anon direct execute                              false
authenticated direct execute                     false
workout_session_exercises count                  11 (unchanged)
guidance_drafts count                             2 (unchanged)
guidance_revisions count                         25 (unchanged)
max guidance version                              1 (unchanged)
preview_required draft YouTube count              2 (unchanged)
```

No historical workout session, draft or published guidance row was rewritten by deployment.

### Production Vercel deployment

```text
deployment   dpl_ApzpAb69cf6pe5BuL3jY5q6jYmAp
state        READY
target       production
Git SHA      7c805c085761605363e5d266940449a0c8400647
alias        stone-set.vercel.app
```

The production dashboard therefore serves the exact merged guidance-publication feedback fix.

### Security and immutability review

- owner UUID constrains latest-guidance resolution;
- the private trigger function is not directly executable by anonymous/authenticated clients;
- routine versions/prescriptions/materialized weeks remain immutable;
- existing workout-session snapshots are never backfilled/rewritten;
- Android remains deterministic on one server-pinned revision;
- no rank/schedule/reward/signing/Firebase behavior changed;
- no draft was auto-published;
- no YouTube preview evidence was fabricated;
- no secrets/private content were added to source.

### Verdict

`PARTIAL` only at the owner-controlled content-publication boundary.

Engineering implementation, CI, merge, exact-main verification, production database migration and production Vercel deployment are complete.

The remaining action requires genuine owner input: open each affected draft, play the YouTube preview until validation succeeds, then click Publish within one hour. If a video is no longer wanted, remove its reference and publish the remaining valid guidance/media.

After publication, the next newly started workout receives the newest finalized guidance/media bundle. Already-started workouts intentionally keep their prior immutable snapshot. No Android app update is required for TASK-IMP-014.
