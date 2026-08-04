# Stone Set Implementation Plan

Updated: 2026-08-04
Status: `IMPLEMENTATION AUTHORIZED FOR APPROVED PACKETS ONLY`
Latest planning task: `TASK-PD-009`

## Starting point

Phase 0 is complete. Product, guidance, media, workflow, architecture, security, local persistence, release, hosting, backup, and operator-access decisions are accepted.

The repository still contains no application code or external infrastructure.

## Authorization rule

Implementation proceeds only through approved packets in `docs/tasks/`.

Current approved packet:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
```

Its approval does not authorize product features, media features, or external project creation.

## Target architecture

```text
Android Flutter app
  -> workout and exercise guidance
  -> YouTube IFrame player
  -> online start
  -> SQLite draft, guidance cache, and outbox
  -> online authoritative finalization

Flutter Web dashboard
  -> exercise library and guidance management
  -> private image upload
  -> YouTube preview
  -> reviewed routine management
  -> static Vercel deployment

Native Pub workspace
  -> domain, data, and UI packages

Supabase Auth + Postgres + RLS
  -> private state, media metadata, and atomic transitions

Supabase Storage + Storage RLS
  -> private immutable exercise images
```

## Phase 1 — Repository and quality foundation

Status: `READY — NOT STARTED`
Packet: `docs/tasks/TASK-IMP-001.md`

Scope:

- pin Flutter and tooling;
- create Android-only mobile shell;
- create web-only dashboard shell;
- create shared native Pub workspace packages;
- initialize local Supabase configuration only;
- add non-secret configuration templates;
- add formatting, analysis, tests, Android/Web builds, database tests, lint, and CI;
- document local setup and actual repository structure.

Exit criteria are defined in the packet. No authentication, product schema, Storage bucket, media, YouTube player, SQLite feature, routine, workout, rank, wallet, remote project, or deployment belongs in Phase 1.

## Phase 2 — Identity and ownership

Planned packet: `TASK-IMP-002`

- administratively provisioned Supabase Auth accounts;
- profiles, usernames, units, and reward timezone;
- mobile and dashboard sessions;
- RLS ownership policies and allow/deny tests;
- logout and private-cache cleanup.

## Phase 3 — Exercise library, guidance, media, and routine management

Planned packet sequence may be split if one reviewable task becomes too large.

### Planned `TASK-IMP-003A` — Exercise library and guidance persistence

- stable user-owned exercise definitions;
- immutable guidance revisions;
- muscle taxonomy and structured text fields;
- content-only publication and history;
- cross-user denial and explicit clone behavior.

### Planned `TASK-IMP-003B` — Private exercise images and YouTube references

- private `exercise-media` bucket;
- owner-scoped Storage RLS;
- image validation, EXIF stripping, optimization, upload, ordering, alt text, and immutable object identity;
- YouTube URL normalization, embed preview, error states, and fallback metadata;
- media metadata/history and orphan-draft cleanup;
- Storage backup/manifest tooling deferred to release operations but schema designed now.

### Planned `TASK-IMP-003C` — Reviewed routine management

- workout-day summaries;
- exercise-guidance selection;
- routine schema and drafts;
- hard server validator `routine-validator-v1`;
- submission content hashes;
- independent review and self-approval prevention;
- immutable publication, future activation, rejection, and audit history.

## Phase 4 — Weekly plans and normalized allocations

Planned packet: `TASK-IMP-004`

- routine-version selection;
- seven dated plan items;
- pinned workout-day and exercise-guidance revisions;
- `rank-v6` RR and base-XP allocation;
- 95 RR penalty allocation;
- monthly grants;
- immutable schedule snapshots, locks, timezones, and idempotency.

## Phase 5 — Android workout execution and guidance

Planned packet sequence:

### Planned `TASK-IMP-005A` — Workout execution and local drafts

- home and weekly schedule;
- online session start and lock;
- timers and set entry;
- SQLite active draft and outbox;
- offline continuation;
- pending submission and 24-hour grace;
- server validation and authoritative provisional result.

### Planned `TASK-IMP-005B` — Workout guidance and media playback

- workout overview and exercise instruction views;
- stable navigation that preserves active set entry and timers;
- guidance text snapshot and offline availability;
- signed/authenticated image loading, prefetch, active-session caching, placeholder, and retry;
- official YouTube IFrame playback in Android WebView;
- Referer/base URL, privacy-enhanced mode where compatible, no autoplay/background play, and fallback handling;
- no reward coupling.

## Phase 6 — Swaps, wallet, rank, and finalization

Planned packet: `TASK-IMP-006`

- swap preview and payment choice;
- wallet ledger;
- daily awards, missed penalties, and weekly PR cap;
- consistency, top-ups, bonuses, milestones, and decay;
- idempotent weekly finalization and transaction history.

## Phase 7 — Progression, protection, and corrections

Planned packet: `TASK-IMP-007`

- double-progression recommendations;
- user overrides;
- substitution and pain flags without diagnosis;
- protected periods;
- exact-value backdated corrections and audit presentation.

## Phase 8 — Release hardening

Planned packet: `TASK-IMP-008`

- full end-to-end tests;
- database and Storage RLS, privilege, advisor, and migration audit;
- staging and production setup;
- Supabase Pro database backups;
- encrypted logical database and Storage object export automation;
- object hash manifest and metadata reconciliation;
- demonstrated database plus Storage restore drill;
- Vercel preview and production deployment;
- signed Android APK/private release;
- operational runbook and final context sync.

## Cross-cutting testing strategy

### Dart and Flutter

- pure domain tests;
- repository and adapter tests;
- widget and integration tests;
- Android device behavior;
- web keyboard, focus, semantics, image editor, and SPA routing;
- local database and media-cache migration and recovery tests.

### Supabase and Postgres

- clean migration rebuild;
- database RLS allow and deny fixtures;
- Storage RLS allow and deny fixtures;
- immutable object and content-hash tests;
- function privilege tests;
- transaction and concurrency tests;
- idempotency and immutable-ledger tests;
- database lint and advisors.

### Media

- MIME and decoded-type validation;
- size, dimension, animation, metadata stripping, and image-count limits;
- immutable historical asset references;
- YouTube URL normalization and player failure states;
- no autoplay, background playback, download, or reward coupling;
- offline guidance text and prefetched image behavior;
- database/Storage backup-manifest reconciliation.

### Product integrity

- 4-, 5-, and 6-day allocation fixtures;
- routine eligibility and self-approval rejection;
- guidance-versus-prescription change classification;
- content-hash and publication tests;
- PR, swap, consistency, penalty, and correction tests;
- long-run rank calibration checks.

### Operations

- staging data and media isolation;
- no secrets in artifacts;
- database and Storage backup encryption and retention;
- restore drill evidence;
- release artifact traceability and rollback.

## Exact next action

Execute `docs/tasks/TASK-IMP-001.md` on branch `codex/task-imp-001-foundation`.
