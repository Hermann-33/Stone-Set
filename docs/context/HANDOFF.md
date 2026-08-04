# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-PD-009 — Define workout guidance, exercise media, and YouTube playback`

## Starting state

- Phase 0 had been completed by `TASK-PL-002`.
- `TASK-IMP-001` was approved but not executed.
- The dashboard managed routine drafts but had no accepted exercise-content or media contract.
- The mobile workflow had set logging but no accepted workout explanation, muscle, image, or video experience.
- ADR-0002 explicitly excluded Supabase Storage because no Storage requirement existed at that time.
- No application code or external infrastructure existed.

## User requirement

When a user opens a workout, the Android app must provide:

- a brief workout explanation;
- muscles targeted;
- exercise instructions;
- images showing how to perform the exercise;
- an embedded YouTube demonstration.

The user manages these data through the Flutter Web dashboard. Images are product-hosted. Videos remain YouTube links.

## Research and findings

1. Vercel's static deployment output cannot serve as persistent runtime upload storage.
2. Supabase Storage integrates with the accepted Auth and RLS architecture and supports private owner-scoped media.
3. Supabase database backups contain Storage metadata but not Storage object bytes, requiring separate object backup and restore.
4. YouTube requires the official embedded-player behavior, a valid Referer or base URL in WebView integrations, minimum player sizing, visible controls, and no unauthorized overlays or modification.
5. YouTube playback must not be downloaded, background-played, stripped of ads or controls, or rewarded.
6. Essential guidance must remain useful when YouTube or connectivity is unavailable, so structured text is mandatory and active-session images are prefetched where possible.
7. Guidance must be versioned separately from reward-bearing prescriptions so copy corrections do not require rank review while variant or prescription changes still do.
8. A globally mutable shared exercise library would let one user unexpectedly alter another user's routine; user-owned definitions and explicit cloning are safer for MVP.

## Accepted product decisions

### Workout overview

Every workout day may include:

- title and brief purpose;
- primary and secondary muscle groups;
- estimated duration;
- equipment summary;
- optional coach note.

### Exercise guidance

Every prescribed exercise references an immutable guidance revision containing:

- explanation;
- primary and secondary muscles;
- setup and execution steps;
- technique cues;
- common mistakes;
- safety notes;
- ordered images;
- one optional YouTube video.

### Ownership and versioning

- Exercise definitions and guidance are user-owned.
- A user cannot silently edit another user's library.
- Permitted content may be explicitly cloned into a new owned definition.
- Content-only changes may be self-published after validation.
- Changes affecting canonical variant identity, equipment, prescription, progression, or PR comparability remain reviewed routine changes.
- Materialized weeks and started workouts retain their pinned guidance revision.

### Images

- One private Supabase Storage bucket: `exercise-media`.
- Zero through six images per exercise revision.
- JPEG, PNG, and static WebP only.
- Maximum 5 MB per processed image.
- Maximum longest edge 2400 pixels.
- EXIF/GPS removed; MIME and decoded type validated.
- Alt text required.
- Immutable owner-scoped object paths; no in-place overwrite of published assets.
- Images are product-hosted through Supabase Storage, not stored in Vercel's build output.

### YouTube

- At most one optional YouTube video per guidance revision.
- The dashboard normalizes single-video YouTube links and previews the official player before publication.
- The Android app uses the YouTube IFrame Player API in an OS-provided WebView.
- Valid Referer/base URL, standard controls, branding, ads, and sizing are preserved.
- Privacy-enhanced mode is used where compatible.
- No autoplay, background playback, download, caching, extraction, or watch reward.
- Runtime errors provide an external YouTube fallback.

### Offline behavior

- Workout and exercise text is included in the active-session snapshot.
- Instruction images are prefetched and cached for the active session when possible.
- YouTube remains online-only.
- Media failure never blocks set logging or completion.
- Opening guidance does not reset the SQLite draft or timers.

### Backup

- Database backup alone is insufficient for exercise images.
- Weekly and month-end encrypted Storage exports accompany independent database backups.
- Storage manifests include path, size, MIME, and content hash.
- Restore drills must reconcile media metadata and actual objects.

## New specification and ADR

- `docs/product/EXERCISE_GUIDANCE_AND_MEDIA.md`
- `docs/decisions/ADR-0006-exercise-media-storage-and-youtube-embedding.md`

## Implementation-plan impact

- Phase 3 now includes exercise library, guidance, media, and reviewed routines.
- Phase 5 now includes Android guidance, image cache, and YouTube playback.
- Phase 8 now includes database plus Storage backup and restore verification.
- The feature should be split into bounded implementation packets rather than one oversized task.

## Foundation packet decision

`TASK-IMP-001` remains approved and valid because it creates scaffolding and local quality gates only. It does not implement the new product or media features.

## Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

## Verification performed

- official YouTube IFrame, WebView, Referer, player-size, controls, and playback-policy guidance reviewed;
- official Supabase Storage, RLS, private bucket, upload, MIME/size restriction, and Flutter upload guidance reviewed;
- confirmed database backups do not include Storage objects;
- defined owner, revision, historical, deletion, and clone behavior;
- defined offline text, image, and video boundaries;
- preserved all rank and scheduling economics;
- synchronized product, architecture, roadmap, implementation plan, bootstrap, ADR index, handoff, and audit history;
- no code, schema, bucket, package, project, account, credential, media, deployment, or runtime was created.

## Known risks

- User-authored technique guidance can be inaccurate and is not medical advice.
- YouTube videos can later be removed, restricted, or have embedding disabled.
- Privacy-enhanced embedding still creates a third-party YouTube connection when loaded.
- Image processing and MIME validation require careful browser and server tests.
- Storage-object backup is operationally separate from database backup.
- Media caching must remain bounded to avoid device-storage growth.

## Repository and branch

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`
- Task: documentation and decision changes only.

## Exact next action

Execute:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
branch: codex/task-imp-001-foundation
```

## Do-not-touch boundaries for the next task

- no remote Supabase, Storage, or Vercel project;
- no real credentials, signing keys, images, videos, or personal data;
- no authentication, product schema, bucket, media, YouTube player, routine, workout, SQLite feature, rank, wallet, or deployment implementation;
- no direct work on `main`;
- no silent change to accepted product configurations or ADRs.

## Verdict

`COMPLETE`

The workout-guidance and media feature is fully planned and synchronized. The implementation foundation remains the next bounded task.
