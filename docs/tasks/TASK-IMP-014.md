# TASK-IMP-014 — Guidance/media publication freshness

Updated: 2026-08-13
Status: `APPROVED`
Branch: `agent/task-imp-014-guidance-publication-freshness`
Decision: `ADR-0011`

## Objective

Fix the end-to-end defect where exercise guidance/media edits made in the Web dashboard do not become visible in newly started Android workouts. Preserve immutable published guidance revisions, immutable routine/version/week evidence, and already-started workout snapshots.

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

The zero stale-reference counts do not indicate working propagation: production has no guidance revision above version 1. At least one server draft differs from its published revision, while both draft YouTube references remain unvalidated. The atomic media publication function rejects `preview_required`, so no new immutable revision is created.

Repository inspection also proves that `start_workout_v1` snapshots `routine_version_prescriptions.guidance_revision_id`. Therefore, after a future version 2 is successfully published, the existing routine pin would still prevent that version reaching a newly started workout unless the server resolves the latest eligible publication at session creation.

## Applicable accepted decisions

- ADR-0002 — Supabase backend/Auth/persistence authority.
- ADR-0003 — online workout start and immutable started-workout snapshot.
- ADR-0006 — private media and YouTube preview validation.
- ADR-0008 — atomic guidance/media draft materialization.
- ADR-0011 — latest finalized published guidance resolution for newly started workouts.

## Exact scope

### Dashboard publication feedback

- Keep atomic guidance+media publication.
- Before publication, detect an explicitly `preview_required` YouTube draft and show an actionable message telling the user to load/play the preview successfully before publishing.
- Map server `ExerciseMediaErrorCode.previewRequired` explicitly, including expired validation evidence, instead of reporting a generic media failure.
- Do not fabricate or bypass YouTube playable evidence.
- Make publish messaging clear that an already-started workout keeps its snapshot; future newly started workouts receive the latest published bundle.

### Server activation

- Keep `routine_version_prescriptions.guidance_revision_id` immutable.
- Keep `training_week_items` and routine versions unchanged when content is republished.
- On insertion of a new `workout_session_exercises` snapshot, resolve the latest owner-matching guidance revision for the exercise that has a finalized `guidance_media_manifests` row.
- Fall back to the routine prescription's pinned revision when no eligible finalized bundle exists.
- Once inserted, never rewrite the workout-session guidance revision because of later publication.
- Do not change workout scoring, RR/XP, schedule/swap authority, or offline workout-start policy.

### Tests

- Dashboard controller test: preview-required draft blocks publication locally with clear remediation and does not call reservation/finalization.
- Dashboard controller test: server-side `previewRequired` maps to the same clear remediation.
- Database regression: routine prescription pins guidance v1; manifest-backed v2 exists before start; new workout snapshots v2.
- Database regression: manifest-backed v3 is published after the session starts; repeated start returns the same session still pinned to v2.
- Existing workout execution, media security, dashboard tests and CI remain green.

## Database changes

One additive migration is expected. It may add a private trigger function and `BEFORE INSERT` trigger on `public.workout_session_exercises`. It must not alter existing rows or backfill historical sessions.

No destructive production mutation or content auto-publication is authorized.

## Production deployment

The owner's request explicitly authorizes the complete fix. After the exact implementation head passes required CI, merge the PR, verify exact-main CI, then apply the exact committed migration through Supabase migration history to production project `pjltldrernuvrjsnmcqg`. Do not run ad-hoc production DDL that differs from the committed migration.

Current unpublished guidance/media drafts must remain drafts. Do not mark a YouTube preview validated on behalf of the user and do not auto-publish their content.

## Dashboard deployment

Verify the production Vercel dashboard is built/deployed from the merged main revision so the actionable publication blocker is available to the owner.

## Protected behavior / non-goals

Do not change:

- immutable guidance/media revisions;
- immutable routine versions/materialized prescription evidence;
- already-started workout guidance snapshot;
- online workout start;
- server authority for workout submission, RR, XP, wallet, rank, penalties, PRs or finalization;
- rank-v6 or schedule-v3;
- signing/application ID/Firebase architecture;
- YouTube successful-preview requirement;
- private Storage authorization.

## Verification and CI monitoring

1. repository/docs checks;
2. format and strict Dart/Flutter analysis;
3. dashboard controller/widget tests;
4. data/domain tests affected by error mapping/contracts;
5. local Supabase reset + pgTAP including workout execution regression;
6. relevant Android/API-24/build gates selected by path classifier;
7. exact-head Foundation CI under active monitoring;
8. on any CI failure, inspect the failed job/log, implement the bounded correction and repeat until exact-head green;
9. merge only the exact green head;
10. verify exact-main Foundation CI;
11. deploy exact committed migration and verify production state;
12. verify production dashboard deployment.

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
