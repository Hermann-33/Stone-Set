# ADR-0006: Exercise guidance media storage and YouTube embedding

## Status

Accepted

- Date: 2026-08-04
- Type: Product content, object storage, external media integration, and mobile playback
- Supersedes: ADR-0002's explicit exclusion of Supabase Storage for this newly accepted scope
- Preserves: User ownership, RLS, immutable version history, server authority, Android-first release, Vercel static hosting, and YouTube policy compliance

## Context

Stone Set users need to manage workout explanations, targeted muscles, exercise instructions, images, and demonstration videos through the Flutter Web dashboard. The Android app must present that guidance during workout execution.

User-uploaded images cannot be persisted inside a Vercel static deployment. Embedding arbitrary external image URLs would weaken reliability, privacy, and ownership controls. Directly hosting video would add storage, bandwidth, transcoding, moderation, and playback complexity that is unnecessary because the requested videos already exist on YouTube.

ADR-0002 deliberately excluded Supabase Storage until a concrete requirement existed. `TASK-PD-009` introduces that requirement.

## Decision criteria

- user-owned dashboard management;
- stable and auditable guidance revisions;
- reliable image serving to Flutter mobile and web;
- private access by default;
- no client secrets;
- offline availability of essential instructions;
- compliance with YouTube player policies;
- low operational burden for two users;
- backup and restore completeness;
- no coupling between media viewing and rank rewards.

## Options considered

### Image Option A — Commit images into the dashboard repository

Advantages:

- simple static serving;
- no runtime object-storage API.

Disadvantages:

- ordinary users cannot upload at runtime;
- every image change requires a Git deployment;
- user-owned access and version history become awkward;
- images are bundled into a public static artifact.

Rejected.

### Image Option B — Store arbitrary external image URLs

Advantages:

- no object-storage implementation.

Disadvantages:

- broken links, tracking, hotlinking, ownership, and content-replacement risk;
- no reliable offline prefetch or backup;
- external hosts can change content without Stone Set history.

Rejected.

### Image Option C — Supabase Storage private bucket

Advantages:

- integrates with accepted Supabase identity and RLS;
- authenticated Flutter upload and download support;
- immutable object paths and ownership policies;
- CDN delivery and optional transformations;
- one operational platform for database and media metadata.

Disadvantages:

- Storage objects require separate backup and restore;
- RLS and object lifecycle require dedicated tests;
- image processing and cleanup must be implemented deliberately.

Accepted.

### Video Option A — Direct video uploads

Advantages:

- Stone Set controls file availability and player behavior.

Disadvantages:

- high storage and bandwidth cost;
- transcoding, codecs, streaming, moderation, and backup burden;
- unnecessary for the requested YouTube workflow.

Rejected.

### Video Option B — Open YouTube externally only

Advantages:

- simplest integration.

Disadvantages:

- leaves the workout experience;
- weaker instructional flow.

Accepted only as a fallback.

### Video Option C — Official YouTube embedded player

Advantages:

- keeps playback in the exercise guidance view;
- YouTube owns streaming, codecs, controls, and availability;
- no Stone Set video storage.

Disadvantages:

- requires connectivity;
- embedding can be disabled or restricted;
- WebView, Referer, sizing, branding, and policy requirements must be preserved.

Accepted.

## Decision

### Guidance model

- Workout-day summaries and exercise guidance are editable in the dashboard.
- Exercise guidance is user-owned and versioned independently from reward-bearing prescriptions.
- Published guidance revisions are immutable.
- Weekly materialization pins a guidance revision.
- Content-only guidance updates may be self-published by the owner after validation.
- Changes affecting canonical variant identity, equipment, prescription, progression, or PR comparability remain routine changes and require the accepted review workflow.

### Supabase Storage

Stone Set will use one private Supabase Storage bucket:

```text
exercise-media
```

MVP object path:

```text
<owner-user-id>/<exercise-definition-id>/<guidance-revision-id>/<asset-id>.<extension>
```

Policies:

- the bucket remains private;
- authenticated reads require permission to the referenced guidance revision;
- uploads must target the authenticated user's own root path;
- published objects cannot be overwritten or deleted through ordinary client actions;
- uploads use new immutable object names and `upsert: false`;
- Storage operations use the API, not direct mutation of the `storage` schema;
- service-role credentials never enter either Flutter client.

### Image constraints

- 0–6 images per exercise guidance revision;
- at most one cover image;
- JPEG, PNG, and static WebP only;
- maximum 5 MB per processed image;
- maximum longest edge 2400 pixels;
- EXIF and GPS metadata removed;
- declared MIME, decoded MIME, and file extension must agree;
- image alt text required for publication;
- published image references are immutable.

The dashboard processes small uploads using the standard Supabase upload path. Images larger than the accepted 5 MB limit are rejected rather than using resumable upload in MVP.

### YouTube integration

- one optional YouTube video per guidance revision;
- store normalized video ID, canonical URL, optional start time, title/thumbnail snapshot, and validation timestamp;
- accept supported single-video YouTube URL forms;
- reject arbitrary hosts and playlist-only links;
- require an embedded preview before publication;
- use the YouTube IFrame Player API;
- use an OS-provided Android WebView;
- provide the required Referer or base URL;
- use privacy-enhanced embed mode where compatible;
- do not autoplay, download, cache, background-play, modify, obscure, or reward playback;
- preserve YouTube controls, branding, advertisements, and player behavior;
- handle runtime errors and offer `Open in YouTube` fallback.

The implementation may select a Flutter wrapper only after verifying that it exposes the required WebView, Referer, player-event, and policy behavior. The wrapper is replaceable; the official IFrame contract is authoritative.

### Mobile offline behavior

- workout overview and exercise guidance text are included in the active-session snapshot;
- referenced images are prefetched and cached for the active session when available;
- missing images do not block execution;
- YouTube playback remains online-only;
- guidance navigation cannot reset workout timers or local drafts;
- viewing guidance never changes reward eligibility or totals.

### Backup and recovery

Supabase database backups and `db dump` do not include Storage object bytes.

Therefore:

- encrypted weekly and month-end backups include the `exercise-media` object set and a hash manifest;
- Storage backups follow the accepted 12-week and 12-month-end retention policy;
- restore drills restore both database metadata and image objects;
- a restore is unsuccessful when a published revision references a missing object;
- Storage object export credentials remain operator secrets.

## Consequences

### Positive

- the dashboard becomes the complete routine and exercise-content management surface;
- images remain inside the Stone Set backend rather than arbitrary external hosts;
- mobile instructions can survive temporary connectivity loss;
- video playback remains embedded without Stone Set storing video files;
- guidance history is reproducible;
- one user's edits do not silently change another user's library.

### Negative

- Supabase Storage becomes an additional production subsystem;
- object backup and restore are separate from database recovery;
- image processing, RLS, cleanup, and cache invalidation add implementation work;
- YouTube playback depends on network, video availability, and YouTube policy;
- user-entered instructions may be inaccurate and are not medical advice.

## Security, privacy, data, and operational impact

- private images are protected by authenticated Storage RLS;
- object paths are owner-scoped and immutable;
- EXIF and GPS removal reduces accidental personal-data leakage;
- user text is structured and rendered without executable HTML;
- signed/authenticated URLs are temporary;
- production previews cannot access production media;
- YouTube receives network requests only when the player or thumbnail is loaded under the accepted UX;
- privacy-enhanced mode is preferred but does not remove all third-party processing;
- operators must back up and restore object bytes separately from Postgres.

## Scope boundaries

This ADR does not authorize:

- creation of a Supabase bucket or project;
- schema or RLS implementation;
- installation of an image or YouTube package;
- direct video upload;
- YouTube Data API search;
- non-YouTube providers;
- public media buckets;
- image sharing between users without explicit permissions;
- AI-generated instructions;
- medical advice;
- analytics or watch tracking;
- reward changes;
- implementation inside `TASK-IMP-001`.

## Rollback or supersession rule

A later ADR may replace Supabase Storage only with a migration covering object bytes, metadata, ownership, URLs, history, backups, and rollback.

A later ADR may add another video provider only after defining provider validation, playback policy, privacy, availability, and migration behavior.

A later ADR may permit shared exercise content only after defining ownership, moderation, conflict, and update propagation.

## Activation evidence

`TASK-PD-009` accepts this architecture and synchronizes the implementation plan. Runtime activation requires later bounded implementation packets.
