# Stone Set Implementation Plan

Updated: 2026-08-05
Status: `IMPLEMENTATION AUTHORIZED FOR APPROVED PACKETS ONLY`
Latest planning task: `TASK-PD-011`

## Starting point

Phase 0 is complete. Authentication UX, product, guidance, media, workflow, architecture, security, local persistence, release, hosting, backup, operator-access, rank-asset, and mobile Home UI decisions are accepted.

The repository contains no Flutter application code or external infrastructure.

## Authorization rule

Implementation proceeds only through approved packets in `docs/tasks/`.

Current approved packet:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
```

Its approval does not authorize authentication, product features, media features, Home feature UI, workout logging, rank behavior, or external project creation.

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
  -> authenticated Home, Week, History, Profile shell
  -> centered rank emblem with full circular progress bar
  -> today's workout/rest action card
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

Exit criteria are defined in the packet. No login, authentication, profile, product schema, Storage bucket, media, YouTube player, SQLite feature, routine, workout, rank, wallet, mobile Home feature UI, remote project, or deployment belongs in Phase 1.

## Phase 2 — Identity, sessions, and authenticated UI foundation

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

Status: `PLANNED — NOT YET AUTHORIZED`
Prerequisites: `TASK-IMP-001` and `TASK-IMP-002A` complete and merged.
Packet: `docs/tasks/TASK-IMP-002B.md`

#### Design system and shell

- semantic Stone Set dark-theme tokens;
- typography, spacing, radius, border, elevation, rank-family color, and motion roles;
- authenticated Home, Week, History, and Profile destinations;
- route and tab-state preservation;
- responsive, semantic, and reduced-motion behavior.

#### Rank hero

- current rank emblem centered inside a complete `360°` inactive track;
- inactive track visible at every value, including `0%`;
- authoritative active arc starts at 12 o'clock and advances clockwise;
- exact `100%` resolves to a seamless complete active circle;
- local stable mapping for all 20 rank assets;
- current RR, percentage, next rank, and Adonis max-rank text;
- authoritative, provisional, pending, stale, offline, loading, error, rank-up, and rank-down states;
- event-driven animation with no continuous idle ticker.

#### Fixture-driven Home

- compact header;
- rank hero;
- conditional pending/provisional banner;
- today's workout/rest card;
- seven-day strip;
- consistency multiplier, lifetime XP, and free-swap metrics;
- fixture action states: `Start workout`, `Continue workout`, `Sync workout`, `View result`, rest, locked, and error.

This packet creates presentation infrastructure only. It does not read real weekly plans, start real workouts, log sets, write RR, or finalize rank.

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
- bind authoritative today's item and seven-day state into existing Home and Week presentation widgets.

## Phase 5 — Android workout execution and guidance

### Planned `TASK-IMP-005A` — Workout execution and local drafts

- make Home `Start workout`, `Continue workout`, and `Sync workout` actions functional;
- online session start and lock;
- timers and set entry;
- SQLite active draft and outbox;
- offline continuation;
- pending submission and 24-hour grace;
- server validation and authoritative provisional result;
- bind active, pending, completed, and result states into the existing Home card.

`Start workout` is the Home entry point for logging the day's sets, load, repetitions, RIR, rest, and completion.

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
- bind authoritative rank snapshots, provisional transactions, RR changes, and rank-up/rank-down events into the existing rank hero.

## Phase 7 — Progression, protection, and corrections

Planned packet: `TASK-IMP-007`

- double-progression recommendations;
- user overrides;
- substitution and pain flags without diagnosis;
- protected periods;
- exact-value backdated corrections and audit presentation.

## Phase 8 — Release hardening

Planned packet: `TASK-IMP-008`

- full end-to-end tests including mobile and dashboard authentication;
- Home ring, workout action, accessibility, and motion verification;
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

### Mobile UI

- complete inactive rank track at 0%;
- accurate intermediate progress;
- seamless complete active ring at 100%;
- all 20 rank assets;
- authoritative, provisional, pending, stale, offline, max-rank, rank-up, and rank-down states;
- today's available, active, pending, completed, rest, locked, and error states;
- `Start workout`, `Continue workout`, `Sync workout`, and `View result` semantics;
- 200% text scale, narrow layout, reduced motion, and idle lifecycle.

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