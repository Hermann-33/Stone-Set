# Stone Set Exercise Guidance and Media

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PD-009`

## Purpose

Stone Set must explain each planned workout and each exercise at the point of execution.

The Flutter Web dashboard is the primary management surface for:

- routines;
- workout-day summaries;
- exercise descriptions;
- muscle targeting;
- exercise images;
- YouTube demonstration links;
- previews and revision history.

The Android app consumes published guidance while the user performs the workout. Guidance is supplemental: viewing text, images, or video is never required for workout completion and never awards RR or XP.

## Product-hosted versus external media

Images are managed by Stone Set and stored in Supabase Storage. They are not committed to the Flutter Web build and are not stored in Vercel's immutable deployment output.

YouTube remains the video host. Stone Set stores a validated YouTube video reference and embeds the official YouTube player. Stone Set does not upload, proxy, download, extract, cache, or re-host YouTube video or audio.

## Guidance levels

### Workout-day overview

Every workout day may contain:

```text
workoutTitle
briefPurpose
primaryMuscleGroups[]
secondaryMuscleGroups[]
estimatedDurationMinutes
equipmentSummary[]
optionalCoachNote
```

The brief purpose explains the session's role in the routine rather than repeating every exercise instruction.

Example intent:

```text
Upper A prioritizes horizontal pressing and rowing, with secondary arm and lateral-delt work.
```

### Exercise guidance

Every prescribed exercise references a stable exercise definition and one immutable guidance revision.

A guidance revision contains:

```text
exerciseName
shortExplanation
primaryMuscles[]
secondaryMuscles[]
equipment[]
setupSteps[]
executionSteps[]
techniqueCues[]
commonMistakes[]
safetyNotes[]
orderedImages[]
youtubeVideo
createdBy
createdAt
revisionNumber
contentHash
```

Required fields for a publishable guidance revision:

- exercise name;
- short explanation;
- at least one primary muscle;
- at least one setup or execution step;
- either at least one image or a YouTube video is recommended but not mandatory;
- text guidance remains mandatory even when a video is present.

## Ownership

- Exercise definitions and guidance revisions are user-owned.
- One ordinary user cannot silently edit another user's exercise content.
- A user may explicitly clone another permitted exercise into their own library, creating a new owned definition and revision.
- MVP does not maintain one globally mutable exercise library shared by both users.
- A routine may reference only guidance the routine owner is permitted to read.

This avoids one user's media edits unexpectedly changing another user's routine.

## Versioning and activation

Exercise guidance is versioned separately from reward-bearing prescription data.

```text
guidance draft
  -> validated
  -> published revision
  -> referenced by future routine or plan items
  -> archived when replaced
```

Rules:

1. A published guidance revision is immutable.
2. Editing guidance creates a new draft revision.
3. Content-only changes do not require the routine's independent reward-eligibility review.
4. Content-only guidance changes may be published by the owning user after validation.
5. A change to canonical exercise identity, equipment variant, set prescription, repetition range, RIR, rest, priority, progression, or PR-comparability is not content-only and must follow routine review.
6. Active and historical plan items retain the exact guidance revision selected when their week materialized.
7. New guidance becomes available only to future unlocked plan items after explicit publication.
8. A started workout retains its cached guidance snapshot even if a newer revision is published.
9. History displays the revision used during that workout.

## Image model

### Limits

MVP supports:

```text
images per exercise revision = 0 through 6
cover image = at most 1
additional ordered step images = at most 5
maximum file size = 5 MB per image
allowed MIME types = image/jpeg, image/png, image/webp
maximum longest edge after processing = 2400 pixels
minimum useful dimension = 320 pixels on the shortest edge
```

The application rejects:

- SVG;
- animated GIF or animated WebP;
- HEIC as a stored final format;
- HTML or script-capable content;
- files whose decoded type does not match the declared MIME type;
- images exceeding limits;
- empty or corrupted files.

### Processing

Before upload, the dashboard:

1. decodes the image;
2. corrects orientation;
3. removes EXIF and location metadata;
4. resizes oversized images;
5. encodes an optimized JPEG, PNG, or WebP;
6. calculates a content hash;
7. uploads to a new immutable object path.

The original local image is not retained by Stone Set unless it already satisfies the accepted processed format and metadata policy.

### Accessibility

Every published image requires concise alternative text describing what the image demonstrates. A caption is optional.

### Storage identity

Objects use immutable paths such as:

```text
<user-id>/<exercise-definition-id>/<guidance-revision-id>/<asset-id>.<extension>
```

Assets are never overwritten in place. New content receives a new object path.

An image referenced by a published or historical revision cannot be physically deleted through ordinary dashboard actions. Removing it from a new draft does not remove it from older revisions. Unreferenced draft objects may be cleaned up through a controlled garbage-collection process.

## YouTube video model

MVP supports at most one optional YouTube video per exercise guidance revision.

Stored values:

```text
provider = "youtube"
videoId
canonicalWatchUrl
optionalStartSeconds
titleSnapshot
thumbnailUrlSnapshot
validatedAt
```

The original pasted URL is normalized. Supported inputs include ordinary YouTube watch URLs, `youtu.be` URLs, Shorts URLs, and valid embed URLs that resolve to one video.

The dashboard must:

1. parse and normalize the URL;
2. reject non-YouTube hosts and playlist-only URLs;
3. render an official embedded-player preview;
4. show a clear failure when embedding is disabled, unavailable, age-restricted, or invalid;
5. let the user replace or remove the reference;
6. store the canonical video ID rather than relying only on the pasted URL.

A successful preview is required before publishing a new video reference. Availability can still change later, so the mobile app must handle player errors and offer `Open in YouTube` as a fallback.

## YouTube player behavior

The Android app uses the official YouTube IFrame Player API inside an OS-provided Android WebView integration.

Rules:

- use a valid HTTP Referer or WebView base URL as required by YouTube;
- use privacy-enhanced embed mode where compatible;
- use a responsive 16:9 player that never falls below YouTube's minimum viewport;
- show standard YouTube controls and branding;
- do not place overlays over player controls;
- do not autoplay;
- do not play in the background;
- do not download or cache the video;
- do not extract audio;
- do not suppress advertisements or YouTube UI;
- do not reward, require, or incentivize video watching;
- pause the player when the guidance view closes or the app backgrounds;
- provide an external YouTube fallback when embedded playback fails.

A specific Flutter wrapper package is not selected by this product document. Implementation must select a maintained adapter that preserves the official IFrame behavior, WebView type, Referer, and policy requirements.

## Dashboard workflow

The dashboard contains an `Exercise Library` for the signed-in user.

### Exercise editor sections

1. **Basics** — name, equipment, stable exercise identity.
2. **Muscles** — primary and secondary muscles.
3. **Instructions** — short explanation, setup, execution, cues, mistakes, and safety notes.
4. **Images** — upload, crop/preview, alt text, caption, cover selection, and ordering.
5. **Video** — paste YouTube URL, normalize, preview, optional start time, replace, or remove.
6. **Usage** — routines and future weeks referencing the exercise.
7. **Version history** — draft, published, archived revisions and diffs.
8. **Mobile preview** — approximate Android instruction layout before publication.

### Publication

- Draft changes autosave.
- Validation errors block publication.
- Publication creates an immutable guidance revision.
- The user explicitly chooses whether eligible future routine versions should use the new guidance revision.
- Existing materialized weeks are not rewritten.

## Android workout experience

### Workout opening screen

Before or alongside set logging, the workout screen presents:

- workout title;
- brief session purpose;
- primary and secondary muscle groups;
- estimated duration;
- equipment summary;
- the ordered exercise list.

This overview must not delay workout start or require dismissal of a modal on every launch.

### Exercise card

Each exercise card shows:

- exercise name;
- cover image or neutral placeholder;
- primary muscles;
- prescribed sets, repetitions, RIR, and rest;
- a clear `How to perform` action.

### Guidance view

The guidance view shows:

1. short explanation;
2. primary and secondary muscle chips;
3. setup and execution steps;
4. ordered images with alt text;
5. technique cues and common mistakes;
6. safety notes;
7. YouTube player when online and configured;
8. external YouTube fallback.

Opening or closing guidance must not reset entered sets, timers, scroll position, or the active SQLite draft.

## Offline behavior

At online workout start, the backend returns the pinned workout and guidance revision identifiers.

The mobile app caches:

- workout overview text;
- exercise guidance text;
- muscle data;
- image metadata;
- available instruction images for the active session, subject to storage and connectivity success;
- the YouTube video ID and fallback URL.

Rules:

- guidance text is available offline after a valid session start;
- successfully prefetched images are available offline for the active session;
- image failures show placeholders and retry controls;
- YouTube playback always requires connectivity;
- the app clearly marks video as unavailable offline;
- offline media failure never blocks set logging or workout completion;
- cached active-session media is removed under the accepted account logout and cache-cleanup rules.

## Supabase records

Planned logical records include:

```text
exerciseDefinition
exerciseGuidanceRevision
exerciseGuidanceImage
exerciseGuidanceVideo
workoutDayGuidance
```

Postgres stores metadata, ownership, ordering, hashes, versioning, and references. Supabase Storage stores image object bytes.

No database row stores a YouTube video file.

## Security and privacy

- The exercise-media bucket is private.
- Authenticated reads, uploads, and draft deletion use Storage RLS.
- Object paths begin with the immutable owner user ID.
- Storage ownership alone is not treated as authorization; explicit policies are required.
- Users cannot upload into another user's path.
- Users cannot overwrite published assets.
- Public bucket URLs are prohibited for MVP.
- Signed or authenticated URLs are short-lived and regenerated as needed.
- Service-role keys never enter the dashboard or mobile app.
- File extensions are not trusted as MIME validation.
- EXIF, GPS, and unnecessary metadata are stripped.
- User-entered guidance is rendered as plain structured text, not executable HTML.
- YouTube embeds use only normalized video IDs and approved player parameters.

## Backup and recovery

Supabase database backups do not include Storage object bytes. Therefore exercise-media recovery requires a separate object backup.

Before production release:

- export the private `exercise-media` bucket through the Supabase Storage or S3-compatible API;
- encrypt the export;
- store it alongside the accepted independent database backup locations;
- retain the same 12 weekly and 12 month-end schedule;
- record an object manifest containing path, size, MIME type, and content hash;
- include Storage objects and metadata reconciliation in restore drills.

A restore is incomplete if database metadata exists but referenced image objects are missing.

## Required validation and test scenarios

- publish text-only guidance;
- publish image-only and image-plus-video guidance;
- reject unsupported image MIME types and corrupted images;
- reject oversized and animated images;
- strip EXIF and GPS metadata;
- enforce image count and ordering;
- prevent cross-user upload, read, update, and deletion;
- prevent overwrite of published assets;
- preserve historical images after a new revision;
- reject non-YouTube and playlist-only URLs;
- normalize watch, short, Shorts, and embed URLs;
- handle embedding disabled, removed, private, age-restricted, and region-blocked video states;
- provide external YouTube fallback;
- verify no autoplay and no background play;
- verify guidance viewing does not alter rewards;
- verify active-workout state survives guidance navigation;
- verify offline text and prefetched images;
- verify video is unavailable offline without blocking the workout;
- verify database restore plus Storage-object restore produces no broken references.

## Non-goals

- direct video uploads;
- non-YouTube video providers;
- YouTube search inside Stone Set;
- automatic transcription or AI-generated coaching;
- public exercise galleries;
- comments, likes, ratings, or social sharing;
- rewards for watching guidance;
- medical diagnosis or injury treatment;
- offline YouTube playback;
- editing another user's guidance without an explicit clone or future role decision.
