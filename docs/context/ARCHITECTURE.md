# Stone Set Current Architecture

Updated: 2026-08-04
Status: `ACCEPTED TARGET ARCHITECTURE — NOT IMPLEMENTED`

## Implemented system

```text
GitHub repository
  -> governance
  -> accepted product specifications
  -> accepted ADRs
  -> implementation plan and task packets
```

No application runtime, database, Storage bucket, account, deployment, or CI exists.

## Target system

```text
Android Flutter app
  -> workout and exercise guidance
  -> official YouTube embedded player
  -> online workout start
  -> SQLite active draft, guidance cache, and outbox
  -> authenticated synchronization

Flutter Web dashboard
  -> user-owned exercise library
  -> guidance text, muscles, images, and YouTube preview
  -> reviewed routine drafting and publication
  -> static Vercel deployment

Shared Dart workspace packages
  -> pure domain rules
  -> repository contracts and adapters
  -> limited shared UI assets

Supabase Auth
  -> credentials, sessions, identity

Supabase Postgres
  -> RLS-protected user state and media metadata
  -> immutable versions and ledgers
  -> atomic server-authoritative operations

Supabase Storage
  -> private immutable exercise images
  -> owner-scoped Storage RLS
```

## Client responsibilities

### Android mobile

- week and rank presentation;
- workout overview and exercise guidance;
- online session start and schedule locking;
- instruction image prefetch and active-session caching;
- official YouTube IFrame playback through Android WebView;
- workout timers and set entry;
- SQLite draft recovery and outbox synchronization;
- pending, provisional, and finalized state presentation;
- swaps, wallet selection, progression, protection, and history.

The client does not calculate authoritative RR, XP, penalties, wallet balances, PR awards, consistency, or finalization. It never downloads or caches YouTube video.

### Flutter Web dashboard

The dashboard owns the user-facing management workflows for:

- user-owned exercise definitions;
- guidance drafts and immutable revisions;
- muscle targeting;
- structured instructions;
- image processing, upload, ordering, alt text, and history;
- YouTube URL normalization, preview, replacement, and removal;
- workout-day summaries;
- routine drafts, validation, review, publication, future activation, and history.

The dashboard is a public static client. Supabase Auth, database RLS, and Storage RLS—not hidden URLs—protect data and media.

### Shared Dart packages

Planned dependency direction:

```text
mobile -> domain, data, ui
dashboard -> domain, data, ui
data -> domain
ui -> Flutter
domain -> Dart SDK
```

Native Pub workspaces provide one root dependency resolution and lockfile.

## Guidance and routine integrity

- Exercise definitions are stable, user-owned identities.
- Guidance revisions are immutable after publication.
- Materialized weeks pin workout-day and exercise-guidance revisions.
- Content-only guidance updates may be self-published after validation.
- Changes affecting exercise variant identity, equipment, prescription, progression, or PR comparability remain reviewed routine changes.
- `routine-validator-v1` owns hard reward-eligibility checks.
- Authors cannot self-approve reward-bearing routine changes.
- Historical weeks retain exact routine, guidance, validator, rank, and schedule versions.

## Image storage

- One private bucket: `exercise-media`.
- Paths are owner-, exercise-, revision-, and asset-scoped.
- JPEG, PNG, and static WebP only.
- Maximum six images and 5 MB per processed image.
- Dashboard strips EXIF/GPS, corrects orientation, resizes, re-encodes, and calculates a hash.
- Published objects use immutable names and are not overwritten.
- Alt text is required.
- Authenticated or signed access is short-lived.
- Storage API operations are used; the `storage` schema is treated as read-only.

## YouTube integration

- At most one optional YouTube video per guidance revision.
- The dashboard stores normalized video ID, canonical URL, optional start time, title/thumbnail snapshot, and validation time.
- Publication requires a successful embedded preview.
- Android uses the official YouTube IFrame Player API in an OS-provided WebView.
- A valid Referer or base URL is required.
- Privacy-enhanced mode is preferred where compatible.
- No autoplay, background play, download, caching, extraction, hidden controls, ad suppression, or watch rewards.
- Player failure provides an external YouTube fallback.
- A specific wrapper package remains an implementation choice subject to official-policy verification.

## Local persistence and synchronization

- SQLite through `sqflite` stores active workout drafts, guidance text snapshots, prefetched active-session image data or cache references, and outbox records.
- A workout must start online.
- The server returns session, prescription, guidance revision, image, YouTube, and start timestamp data and locks the item.
- A valid started workout may continue and finish locally while offline.
- Guidance text and prefetched images remain available offline for that active session.
- YouTube remains online-only.
- Offline completion remains `pending_submission` until server validation.
- Sync occurs on foreground, connectivity regain, and explicit retry; no continuous polling.
- Idempotency keys prevent duplicate sessions, sets, or rewards.
- Started sessions receive a 24-hour week-close synchronization grace.
- Logout with unsynchronized data requires sync or explicit discard and removes private media caches.

## Backend and authorization

- Supabase Auth owns passwords and sessions.
- Every exposed user-owned table uses RLS with ownership predicates.
- Storage objects use explicit owner- and reference-aware policies.
- User-editable metadata is not trusted for authorization.
- Routine publication, plan materialization, swaps, grants, completion, rewards, penalties, weekly finalization, and corrections are atomic server operations.
- Public clients use only the project URL and publishable key.
- Service-role, Storage backup, database, and deployment credentials never enter either Flutter client.

## Environment and deployment model

```text
local -> Supabase CLI + local runtime
staging -> hosted non-production Supabase database and Storage
production -> hosted Supabase Pro database and Storage
```

- Preview dashboard deployments connect only to staging data and media.
- Production Flutter Web output is static and hosted on Vercel.
- GitHub Actions builds and tests the exact artifact before preview and production promotion.
- Initial mobile release is Android API 24+ through a private signed APK; Play internal testing may follow.
- iOS is deferred.

## Backup and operations

- Supabase Pro managed daily database backups with seven-day retention.
- Supabase database backups do not include Storage object bytes.
- Weekly encrypted logical database dumps and `exercise-media` object exports are stored independently in private Google Drive and operator-controlled local/removable storage.
- Storage exports include a path, size, MIME, and content-hash manifest.
- Retention: 12 weekly and 12 month-end copies.
- RPO target: 24 hours.
- RTO target: 4 hours for the expected small dataset.
- Restore drill before release and quarterly thereafter.
- Restore passes only when database media metadata reconciles with all required Storage objects.
- Two distinct Owner accounts with MFA and backup factors.
- Production migrations originate from committed history; untracked dashboard edits are prohibited.

## Security boundaries

- No secrets, personal media, or personal data in Git.
- No service-role key, database password, Storage backup key, Vercel token, or operator token in clients.
- No production data or media in preview or staging by default.
- No public media bucket in MVP.
- No client-authoritative rank or wallet values.
- Local drafts and media caches are private but non-authoritative.
- User guidance text is structured plain text, not executable HTML.
- Finalized records are append-only or voided by exact-value audited corrections.
- Historical values are never recalculated from new configurations.

## Accepted ADRs

- ADR-0001 — Flutter clients.
- ADR-0002 — Supabase Auth/Postgres/RLS.
- ADR-0003 — local drafts and online finalization.
- ADR-0004 — Android-first and Vercel hosting.
- ADR-0005 — production operations and recovery.
- ADR-0006 — exercise-media Storage and YouTube embedding.

## Implementation boundary

`TASK-IMP-001` may create scaffolding, local Supabase configuration, tests, builds, and CI only.

It may not create a Storage bucket, media schema, YouTube player, remote infrastructure, or product features.
