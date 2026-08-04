# Stone Set Implementation Plan

Updated: 2026-08-05
Status: `IMPLEMENTATION AUTHORIZED FOR APPROVED PACKETS ONLY`
Latest planning task: `TASK-PD-011`

## Starting point

Phase 0 is complete. Authentication UX, product, mobile Home UI, rank-progress presentation, guidance, media, workflow, architecture, security, local persistence, release, hosting, backup, and operator-access decisions are accepted.

The repository contains accepted documentation and the curated `stone-set-ranks-v1` asset set, but still contains no Flutter application code or external infrastructure.

## Authorization rule

Implementation proceeds only through approved packets in `docs/tasks/`.

Current approved packet:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
```

Its approval does not authorize authentication, product features, mobile Home feature UI, media features, or external project creation.

Future UI packet:

```text
TASK-IMP-002B — Mobile design system, authenticated shell, and rank hero
status: PLANNED — NOT YET AUTHORIZED
```

`TASK-IMP-002B` is blocked until `TASK-IMP-001` and `TASK-IMP-002A` are complete and merged.

## Target architecture

```text
Android Flutter app
  -> username/password login and session guard
  -> authenticated four-destination shell
  -> centered radial rank-progress Home hero
  -> today's item and weekly status
  -> workout and exercise guidance
  -> YouTube IFrame player
  -> online start
  -> SQLite draft, guidance cache, and outbox
  -> online authoritative finalization

Flutter Web dashboard
  -> responsive /login and protected routes
  -> exercise library and guidance management
  -> private image upload
  -> YouTube preview
  -> reviewed routine management
  -> static Vercel deployment

Native Pub workspace
  -> domain, data, and UI packages

Supabase Auth + Postgres + RLS
  -> provisioned identities, profiles, private state, media metadata, and atomic transitions

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

Exit criteria are defined in the packet. No login, authentication, profile, product schema, Storage bucket, media, YouTube player, mobile Home feature UI, SQLite feature, routine, workout, rank, wallet, remote project, or deployment belongs in Phase 1.

## Phase 2 — Identity, sessions, and authenticated UI foundation

Planned packet sequence:

```text
TASK-IMP-002A — Identity, login, sessions, profiles, and ownership
TASK-IMP-002B — Mobile design system, authenticated shell, and rank hero
```

### Planned `TASK-IMP-002A` — Identity, login, sessions, profiles, and ownership

#### Provisioning

- administratively create confirmed Supabase Auth users;
- create immutable normalized usernames and internal sign-in aliases;
- create protected profiles with `must_change_password`;
- no public signup or invitation flow.

#### Android authentication

- native username/password login screen;
- password visibility and password-manager autofill support;
- session restoration before private rendering;
- first-login password change;
- authenticated navigation guard;
- generic invalid-credential, network, rate-limit, disabled-profile, and expiry states;
- logout with unsynchronized-draft decision flow;
- same-account draft quarantine after involuntary session loss.

#### Dashboard authentication

- responsive `/login` page;
- keyboard, focus, semantic, and responsive-layout tests;
- session restoration and protected-route guards;
- intended-route return after successful authorization;
- first-login password change;
- logout, private-cache cleanup, and back-navigation privacy;
- generic invalid-credential, network, rate-limit, disabled-profile, and expiry states.

#### Backend and security

- Supabase Auth password sign-in and refresh lifecycle;
- profile trigger/linkage and active-profile enforcement;
- RLS ownership policies and allow/deny tests;
- no password storage or logging;
- operator-managed temporary-password reset and session revocation;
- Auth rate-limit verification;
- public configuration for internal auth alias domain;
- no service-role key in either client.

### Planned `TASK-IMP-002B` — Mobile design system, authenticated shell, and rank hero

Packet: `docs/tasks/TASK-IMP-002B.md`
Status: `PLANNED — BLOCKED BY TASK-IMP-001 AND TASK-IMP-002A`

#### Design system

- dark-first Stone Set color, typography, spacing, radius, border, elevation, and motion tokens;
- semantic rank-family colors rather than per-screen hardcoding;
- accessible contrast, text scaling, touch targets, and reduced-motion rules;
- common cards, chips, skeletons, metrics, and navigation primitives.

#### Mobile shell

- authenticated destinations: Home, Week, History, and Profile;
- route and scroll-state preservation;
- predictable back behavior;
- protected-shell compatibility with `TASK-IMP-002A`;
- accessible placeholders for non-Home destinations.

#### Fixture-driven Home

- quiet header with profile and synchronization state;
- centered current-rank emblem;
- near-complete circular progress ring with small top gap;
- exact RR, percentage, next-rank, provisional, pending-sync, stale, offline, error, and max-rank presentation;
- fixture-driven today's card;
- fixture-driven seven-day week strip;
- lifetime XP, multiplier, and free-swap metric tiles.

#### Motion

- first stable render;
- same-rank RR increase and decrease;
- rank-up and rank-down transitions;
- palette transition and restrained haptic hooks;
- no continuous idle animation;
- reduced-motion substitution;
- no replay on unchanged Home-tab return.

#### Architecture and verification

- immutable presentation model;
- stable mapping for all 20 committed rank assets;
- first-party Flutter drawing/animation primitives unless a later decision authorizes another dependency;
- widget, unit, golden, semantics, responsive, lifecycle, and focused performance tests;
- no authoritative RR, weekly-plan, workout, wallet, or finalization implementation.

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
- immutable schedule snapshots, locks, timezones, and idempotency;
- bind authoritative current-day and seven-day plan state into the existing Home card and week strip;
- replace Phase 2B schedule fixtures without redesigning the Home component contract.

## Phase 5 — Android workout execution and guidance

Planned packet sequence:

### Planned `TASK-IMP-005A` — Workout execution and local drafts

- bind the existing Home primary action to authoritative workout state;
- online session start and lock;
- timers and set entry;
- SQLite active draft and outbox;
- offline continuation;
- pending submission and 24-hour grace;
- server validation and authoritative provisional result;
- drive existing pending-sync and workout-state UI through real data.

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
- idempotent weekly finalization and transaction history;
- authoritative rank snapshot query and presentation mapping;
- bind the existing radial hero to finalized RR, provisional transactions, rank-up, rank-down, and adjustment events;
- preserve solid-ring authority and pending/provisional distinctions defined in the UI baseline.

## Phase 7 — Progression, protection, and corrections

Planned packet: `TASK-IMP-007`

- double-progression recommendations;
- user overrides;
- substitution and pain flags without diagnosis;
- protected periods;
- exact-value backdated corrections and audit presentation;
- route corrections and rank adjustments through the existing Home and History presentation states.

## Phase 8 — Release hardening

Planned packet: `TASK-IMP-008`

- full end-to-end tests including mobile and dashboard authentication;
- mobile Home accessibility, animation lifecycle, and baseline-device performance audit;
- Auth rate-limit, session, revocation, recovery, RLS, Storage, privilege, advisor, and migration audit;
- staging and production setup;
- Supabase Pro database backups;
- encrypted logical database and Storage object export automation;
- object hash manifest and metadata reconciliation;
- demonstrated database plus Storage restore drill;
- Vercel preview and production deployment;
- signed Android APK/private release;
- operational runbook and final context sync.

## Cross-cutting testing strategy

### Authentication

- login success on both clients;
- username normalization and internal alias derivation;
- invalid credentials and account-enumeration resistance;
- first-login password change;
- persistent session restoration;
- token refresh, expiry, revocation, and disabled-profile handling;
- dashboard route guards, logout, and back-navigation privacy;
- mobile unsynchronized-draft logout and quarantine;
- cross-user RLS denial;
- no password or token leakage in logs.

### Mobile UI and rank presentation

- all 20 rank assets resolve through one stable mapping;
- progress at 0%, intermediate values, threshold boundaries, and Adonis max rank;
- authoritative versus provisional versus pending state separation;
- loading, stale, offline, error, increase, decrease, rank-up, and rank-down presentation;
- reduced-motion behavior;
- 200% text scaling, semantics, focus order, and non-color status communication;
- no unchanged entrance-animation replay;
- no continuous frame scheduling while idle;
- smooth bounded repaint on the Android API 24 baseline profile.

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

- staging identity, data, and media isolation;
- no secrets in artifacts;
- database and Storage backup encryption and retention;
- restore drill evidence;
- release artifact traceability and rollback.

## Exact next action

Execute `docs/tasks/TASK-IMP-001.md` on branch `codex/task-imp-001-foundation`.

Do not execute `TASK-IMP-002B` until its prerequisites are merged and its packet is explicitly promoted to `APPROVED`.
