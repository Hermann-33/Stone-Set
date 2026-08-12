# Stone Set Latest Handoff

Updated: 2026-08-13

## Latest engineering result

```text
TASK-IMP-014 — Guidance/media publication freshness
ADR-0011
PR #48 — MERGED
main 7c805c085761605363e5d266940449a0c8400647
Foundation CI #390 / 31630620692 — PASS
```

Engineering and production deployment are complete. The task remains `PARTIAL` only because affected owner content still requires genuine YouTube preview evidence and an explicit owner Publish action.

## Root cause and fix

Production had unpublished guidance text plus two YouTube draft references at `preview_required`. The server correctly blocked atomic publication, but the dashboard hid that specific blocker behind a generic media failure. In addition, new workout sessions copied the immutable routine prescription's older guidance revision, so even a later successful publication would not automatically reach future workouts.

Fixes now live:

- dashboard fast-fails loaded `preview_required` drafts with actionable instructions;
- server-side missing/expired preview evidence maps to the same message;
- genuine YouTube IFrame playable evidence remains mandatory;
- new workout-session exercise snapshots resolve the latest owner-matching finalized published guidance/media bundle;
- already-started workouts remain pinned to their original immutable snapshot;
- routine/version/week history is not rewritten;
- Android remains unchanged and consumes the server-pinned revision.

## Production evidence

Supabase migration history:

```text
20260812190919_latest_published_guidance_for_new_workouts
```

Post-deploy verification confirmed function/trigger installation, denied direct execution for `anon`/`authenticated`, and unchanged production counts for 11 workout-session exercises, 2 guidance drafts, 25 guidance revisions, max version 1 and 2 preview-required draft YouTube references.

Vercel production:

```text
deployment   dpl_ApzpAb69cf6pe5BuL3jY5q6jYmAp
state        READY
target       production
Git SHA      7c805c085761605363e5d266940449a0c8400647
alias        stone-set.vercel.app
```

No Android app update is required for TASK-IMP-014.

## Exact next owner action

For each affected exercise draft:

1. open it in `stone-set.vercel.app`;
2. play the YouTube preview until validation succeeds;
3. click **Publish** within one hour.

If the video is no longer desired, remove the YouTube reference and publish the remaining valid guidance/media.

The next newly started workout containing that exercise will use the newly published bundle. A workout already started before publication intentionally remains on its prior snapshot.

## Independent residuals

- TASK-IMP-013A real-device airplane-mode acceptance remains separate.
- TASK-IMP-012 independent signing-key backup/phone confirmation remains separate.
- Do not fabricate media selections, preview evidence or owner publication actions.
