# TASK-IMP-005B — Workout guidance and media playback

Status: `APPROVED — EXECUTABLE`
Mode: `FAST TWO-USER MVP`
Branch: `codex/task-imp-005b-workout-guidance-media`

## Objective

Show the immutable guidance and media already pinned by an active workout session without disrupting the existing logger, local autosave, sync state, rest timer, or submission flow.

TASK-IMP-005B is required before TASK-IMP-008.

## Existing data to reuse

Do not add another media or workout schema.

- each `WorkoutExercise` already carries `exerciseDefinitionId` and pinned `guidanceRevisionId`;
- `ExerciseGuidanceReadRepository.getGuidanceRevision(exerciseId, revisionId)` already returns immutable structured guidance;
- `ExerciseMediaReadRepository.getRevisionManifest(exerciseId, guidanceRevisionId)` already returns immutable published images and YouTube metadata;
- `ExerciseMediaReadRepository.createImageAccessUrl(...)` already creates short-lived signed URLs for private images;
- the current workout logger already keeps its draft, rest timer and scroll state in the same route.

## Aggressive simplification

Implement only:

1. a `Guidance` action on each workout exercise card;
2. an in-route modal/bottom sheet so logger state is never replaced;
3. pinned structured guidance text;
4. published private images for that exact guidance revision using signed URLs;
5. YouTube playback in an embedded Android WebView when a validated YouTube reference exists;
6. compact loading/error/empty/retry states;
7. focused provider/widget tests;
8. Foundation CI.

## No database migration

TASK-IMP-005B must not add database tables, RPCs, Storage policies, media mutation APIs or background jobs unless CI reveals a genuine missing read capability.

## Mobile data boundary

Add one workout-guidance loader that combines existing read repositories:

```text
WorkoutExercise.exerciseDefinitionId
WorkoutExercise.guidanceRevisionId
        ↓
getGuidanceRevision(...)
getRevisionManifest(...)
        ↓
WorkoutGuidanceBundle
```

The bundle should contain:

- immutable `GuidanceRevision`;
- immutable `GuidanceMediaManifest`;
- signed image URLs created only when the panel needs them.

Signed URLs are short-lived presentation data and are never written into SQLite or the workout session snapshot.

## UI

Inside each existing workout exercise card add a compact `Guidance` button.

Open a modal bottom sheet or equivalent in-route overlay containing:

### Text

- short explanation;
- setup steps;
- execution steps;
- technique cues;
- common mistakes;
- safety notes.

Omit empty sections.

### Images

- show revision images ordered by existing manifest position;
- cover image first when already represented that way by the manifest;
- show alt text semantics;
- loading/error placeholder per image;
- retry reloads a fresh signed URL.

No persistent disk cache layer is required. Flutter/network image cache is sufficient for this two-user build.

### YouTube

If the manifest contains a validated YouTube reference:

- use `webview_flutter` pinned to a compatible exact version;
- Android only;
- load YouTube's standard embed URL derived from the already-normalized video ID;
- include the existing start offset when non-zero;
- JavaScript enabled only for the YouTube player;
- do not autoplay;
- do not download video;
- do not couple playback to RR/XP/rewards.

If WebView cannot load, show a retry/error state; do not break the logger.

## State preservation

Opening/closing guidance must not:

- recreate the workout session;
- clear text fields;
- change set completion;
- change client revision;
- clear pending sync;
- reset the rest timer;
- reset the logger's PageStorage scroll position.

The simplest acceptable mechanism is to keep guidance in a modal on the same `WorkoutScreen` state instance.

## Dependencies

Allowed new mobile dependency:

```text
webview_flutter 4.14.1
```

Verified against pub.dev on 2026-08-10:
- Flutter publisher `flutter.dev`;
- minimum Dart 3.10;
- Android SDK 24+;
- compatible with Stone Set Flutter 3.44.7 / Dart 3.12.2 / API 24 baseline.

No other dependency should be added unless a concrete compile/runtime defect requires it.

## Tests

Focused only.

### Provider/data

- loader requests the exercise's exact pinned guidance revision;
- loader requests the matching media manifest;
- signed image URL is created from the manifest asset;
- read failures map to one user-safe failure.

### Mobile

- Guidance action exists for an exercise;
- guidance text renders;
- empty sections are omitted;
- manifest image placeholder/path renders through a fake loader;
- YouTube section exists when reference exists;
- opening and closing guidance preserves current workout draft values;
- existing workout controller/logger tests remain green.

Do not add broad media cache or browser matrices.

## Explicitly deferred/excluded

- offline video;
- direct video upload;
- background prefetch;
- WorkManager media jobs;
- custom disk cache schema;
- cache cleanup daemon;
- full-screen media gallery;
- YouTube account/auth features;
- analytics;
- dashboard media work;
- new server/media schema;
- TASK-IMP-008.

## Acceptance

TASK-IMP-005B is complete when:

- an active workout can open its exact pinned guidance without leaving the logger;
- structured guidance text is readable;
- private published images load through short-lived signed URLs;
- a validated YouTube reference plays in the Android WebView;
- logger state survives opening/closing guidance;
- focused tests and Foundation CI pass.

## Execution policy

Assistant owns implementation, dependency/lockfile handling, CI diagnosis/fixes, completion docs and merge where feasible.

Codex is fallback only for a concrete local-only Flutter/WebView defect that cannot reasonably be solved through GitHub CI.
