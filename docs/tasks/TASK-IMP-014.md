# TASK-IMP-014 — Guidance/media publication freshness

Updated: 2026-08-13
Status: `PARTIAL — implementation candidate green; merge/deployment pending`
Branch: `agent/task-imp-014-guidance-publication-freshness`
Decision: `ADR-0011`
PR: `#48`

## Objective

Fix the end-to-end defect where exercise guidance/media changes made in the Web dashboard do not become visible in newly started Android workouts. Preserve immutable published guidance revisions, immutable routine/version/week evidence, and already-started workout snapshots.

## Verified production starting state

Read-only aggregate verification against production project `pjltldrernuvrjsnmcqg` established:

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

This proved that at least one text edit exists only in an unpublished draft and both current draft YouTube references lack valid successful-preview evidence. Atomic guidance/media publication therefore rejects before creating any immutable v2 revision.

Repository inspection also proved that `start_workout_v1` originally snapshots `routine_version_prescriptions.guidance_revision_id`. Therefore even a future successful v2 publication would not reach a newly started workout while the routine remained pinned to v1.

## Implemented repair

### Dashboard publication feedback

- A loaded draft whose YouTube reference is already `preview_required` fails before publication reservation and shows explicit remediation.
- Server `ExerciseMediaErrorCode.previewRequired`, including expired one-hour validation evidence, maps to the same actionable message.
- The real YouTube IFrame playable callback remains the only way the dashboard records successful preview evidence.
- No YouTube validation is fabricated and no draft is auto-published.

### Server activation

Migration:

```text
supabase/migrations/20260812180500_latest_published_guidance_for_new_workouts.sql
```

It adds private trigger function `private.resolve_latest_workout_guidance_revision_v1()` and a `BEFORE INSERT` trigger on `public.workout_session_exercises`.

For each newly created workout-session exercise snapshot the server resolves the latest owner-matching guidance revision for that exercise with a finalized `guidance_media_manifests` row. If none exists, the revision supplied from the immutable routine prescription remains the fallback.

The trigger runs only on insert. Existing/started workout-session rows are never rewritten by later publication. Routine versions, routine prescriptions and materialized week rows remain immutable historical prescription evidence.

Android continues loading the exact revision pinned into the workout-session snapshot; no client-side `latest` lookup was added.

## Regression coverage

Dashboard regression:

```text
apps/dashboard/test/src/features/exercises/dashboard_guidance_publication_freshness_test.dart
```

Covers:

- loaded `preview_required` fast-fail before reservation;
- server-side `previewRequired` mapping for missing/expired evidence;
- explicit remediation text.

Database regression:

```text
supabase/tests/database/guidance_publication_freshness.test.sql
```

Covers:

- actual resolver trigger is installed on `workout_session_exercises`;
- an insert carrying an older revision resolves to the latest finalized published revision;
- later publication does not rewrite an already-created snapshot;
- the next new snapshot resolves the later publication.

The unchanged existing workout execution pgTAP continues to cover the actual `start_workout_v1` insertion/session path.

## Exact green implementation evidence

```text
implementation candidate   c82b33f7fda5edc515d16133a3ddf28fb91ea6d5
Foundation CI              31628667732 (#382), attempt 2 — PASS
PR                         #48 — DRAFT at candidate verification
```

Passing applicable gates:

- changed-path classification;
- documentation/repository checks;
- locked dependency restore and pinned tool checks;
- generated-source verification;
- Dart formatting;
- strict Flutter/Dart analysis;
- deterministic dashboard goldens;
- dashboard unit/widget tests;
- dashboard Chrome tests;
- production Web bundle build;
- privileged-credential marker review;
- Local Supabase start/reset;
- running Auth/private Storage lifecycle checks;
- full local pgTAP suite including the new freshness regression;
- local database lint and clean stack stop.

The first Local Supabase attempt failed during container reset with external Docker/Supabase rate limiting/upstream HTTP 502 after the migration had already applied. The failed job alone was retried; attempt 2 passed reset, pgTAP and lint on the identical code head. No code change was made for the external infrastructure failure.

Android API 24/mobile build lanes were correctly skipped by ADR-0007 path classification because this repair changes dashboard/server behavior, not mobile runtime/performance code.

## Production deployment authorization

After the final documentation head passes exact-head CI and PR #48 is merged, verify exact-main Foundation CI, then apply the exact committed migration through Supabase migration history to production project `pjltldrernuvrjsnmcqg`.

Do not run divergent ad-hoc production DDL. Current unpublished drafts must remain drafts. Do not mark YouTube preview validation or publish content on behalf of the owner.

Verify the production Vercel dashboard is deployed from the merged main revision so the actionable blocker is live.

## Protected behavior / non-goals

Do not change:

- immutable guidance/media revisions;
- immutable routine versions/materialized prescription evidence;
- already-started workout guidance snapshot;
- online workout start;
- server authority for workout submission, RR, XP, wallet, rank, penalties, PRs or finalization;
- rank-v6 or schedule-v3;
- Android signing/application ID/Firebase architecture;
- YouTube successful-preview requirement;
- private Storage authorization.

## Remaining gates

1. canonical completion/context/audit documentation must pass Foundation CI on its exact new head;
2. merge PR #48 only from that exact green head;
3. verify Foundation CI on the exact resulting `main` SHA;
4. apply/verify the exact migration in production;
5. verify the production Vercel dashboard deployment;
6. owner performs real YouTube preview validation for any affected draft and then publishes it; engineering must not fabricate this evidence.

## Completion report

Return:

- Verdict: COMPLETE | PARTIAL | FAIL
- Root cause
- Task ID / ADR
- Branch / final implementation head / PR
- Final main commit
- Dashboard changes
- Server migration
- New-workout activation behavior
- Started-workout immutability behavior
- Tests and CI runs
- Production migration evidence
- Production dashboard deployment evidence
- Remaining user action, if any
- Known residual risks
