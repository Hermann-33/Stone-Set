# Stone Set Roadmap

Updated: 2026-08-05

## Completion rule

A phase is complete only when every applicable product, authentication, architecture, media, security, operations, testing, documentation, and Git gate is implemented or conclusively closed for that phase.

## Phase 0 — Product discovery, architecture, and implementation planning

Status: `COMPLETE`
Latest planning extension: `TASK-PD-011`
Completed supporting asset task: `TASK-ASSET-001`

Closed outcomes:

- evidence-informed initial hypertrophy routine and 60-minute cap;
- `rank-v6`, `schedule-v3`, and normalized multi-user fairness;
- curated `stone-set-ranks-v1` emblem masters for all 20 ranks, with CC0 provenance and reproducible verification;
- accepted Android Home hierarchy and authenticated four-destination mobile shell;
- centered rank emblem with a complete circular inactive track visible at 0%;
- clockwise authoritative progress arc that becomes a seamless full circle at 100%;
- Home entry states for today's workout: start, continue, synchronize, and view result;
- authoritative, provisional, pending-sync, stale, max-rank, rank-up, rank-down, and reduced-motion display rules;
- fixture-first UI implementation sequence through planned `TASK-IMP-002B`;
- swaps, free-credit wallet, penalties, PRs, consistency, and finalization;
- reviewed reward-eligible routine rules through `routine-validator-v1`;
- accepted end-to-end workflow;
- dedicated login pages for Android and Flutter Web;
- shared provisioned username/password accounts across both clients;
- first-login password change, session restoration, route guards, logout, and operator-managed recovery;
- dashboard-managed workout explanations and exercise guidance;
- user-owned immutable guidance revisions;
- private product-hosted exercise images through Supabase Storage;
- policy-compliant YouTube demonstration embedding;
- active-session offline guidance text and prefetched images;
- Flutter Android mobile and Flutter Web dashboard architecture;
- Supabase Auth/Postgres/Storage/RLS and server authority;
- SQLite local drafts, online start, offline continuation, and online finalization;
- Android-first release and Vercel dashboard target;
- local, staging, and production environment model;
- database and Storage backup, restore, access, and operational controls;
- approved bounded foundation packet.

No application code or external infrastructure was created during Phase 0. Supporting asset and UI-planning tasks do not start Phase 1.

## Phase 1 — Repository and quality foundation

Status: `READY — NOT STARTED`

Approved packet:

```text
docs/tasks/TASK-IMP-001.md
```

Goal:

- Android Flutter shell;
- Flutter Web dashboard shell;
- shared native Pub workspace packages;
- local Supabase configuration;
- non-secret configuration templates;
- formatting, analysis, tests, Android/Web builds, database checks, and CI;
- accurate implemented-state documentation.

Phase 1 excludes login, authentication, profiles, product schema, Storage bucket or policy, exercise media, YouTube player, routines, workouts, rank behavior, mobile Home feature UI, SQLite feature implementation, remote projects, credentials, and deployment.

## Phase 2 — Identity, sessions, and authenticated UI foundation

Status: `PLANNED`

Planned packet sequence:

```text
TASK-IMP-002A — Identity, login, sessions, profiles, and ownership
TASK-IMP-002B — Mobile design system, authenticated shell, and rank hero
```

### Planned `TASK-IMP-002A` — Identity and sessions

- Android native username/password login screen;
- responsive Flutter Web `/login` page;
- provisioned Supabase Auth identities and internal sign-in aliases;
- first-login password change;
- protected profiles, usernames, units, and reward timezone;
- mobile and dashboard session restoration and route guards;
- generic failure, rate-limit, network, disabled-profile, expiry, and revocation states;
- dashboard logout and browser-cache cleanup;
- mobile logout with unsynchronized-draft resolution;
- same-account draft quarantine and recovery after session expiry;
- operator-managed password reset and session revocation;
- RLS ownership and cross-user denial tests.

### Planned `TASK-IMP-002B` — Mobile base UI and rank hero

Prerequisites: `TASK-IMP-001` and `TASK-IMP-002A` complete and merged.

- semantic Stone Set dark-theme tokens, typography, spacing, shape, and motion rules;
- authenticated four-destination mobile shell: Home, Week, History, and Profile;
- fixture-driven Home layout;
- current rank emblem centered inside a complete `360°` inactive circular track;
- full track visible at 0%;
- clockwise authoritative active arc with a seamless full-circle 100% state;
- exact RR, percentage, next-rank, max-rank, provisional, pending-sync, stale, offline, loading, and error presentation;
- event-driven entrance, RR increase/decrease, rank-up, rank-down, and reduced-motion behavior;
- local mapping for all 20 `stone-set-ranks-v1` assets;
- fixture-driven today's workout/rest card with `Start workout`, `Continue workout`, `Sync workout`, and `View result` states;
- week strip and compact metrics as fixture widgets;
- responsive, semantic, golden, lifecycle, and performance tests.

This packet is presentation-only. It does not implement authoritative RR, weekly-plan persistence, real workout execution, finalization, wallet behavior, or remote infrastructure.

## Phase 3 — Exercise library, guidance, and reviewed routines

Status: `PLANNED`

- user-owned stable exercise definitions;
- guidance drafts and immutable published revisions;
- primary/secondary muscles and structured instruction fields;
- private `exercise-media` bucket and Storage RLS;
- dashboard image processing, upload, alt text, ordering, and history;
- YouTube URL normalization, preview, and fallback data;
- workout-day summaries;
- routine editor and `routine-validator-v1`;
- submission, independent review, rejection, approval hash, and audit;
- future activation and history.

## Phase 4 — Weekly planning and allocations

Status: `PLANNED`

- seven materialized plan items;
- pinned workout and exercise-guidance revisions;
- deterministic RR, XP, and penalty allocations;
- monthly grants;
- schedule snapshots, locks, swaps, timezone, and idempotency;
- bind server-authoritative today's item and seven-day plan data into the existing Home card and week strip.

## Phase 5 — Android workout execution and guidance

Status: `PLANNED`

### Planned `TASK-IMP-005A` — Workout execution and local drafts

- make Home `Start workout`, `Continue workout`, and `Sync workout` actions functional;
- online workout start and lock;
- timers and set entry;
- SQLite active draft and outbox;
- offline continuation;
- pending submission and 24-hour grace;
- server validation and authoritative provisional result;
- bind active, pending, completed, and result state into the existing Home card.

### Planned `TASK-IMP-005B` — Workout guidance and media playback

- workout overview and exercise instruction UI;
- image prefetch and active-session cache;
- official YouTube IFrame playback through Android WebView;
- stable navigation that preserves active set entry and timers;
- guidance text snapshot and offline availability;
- signed/authenticated image loading, placeholder, and retry;
- no reward coupling.

## Phase 6 — Rank, wallet, and finalization

Status: `PLANNED`

- daily awards and penalties;
- weekly PR cap;
- consistency, top-ups, milestones, and decay;
- swaps and wallet ledger;
- idempotent weekly finalization and transparent history;
- bind the existing rank hero to authoritative snapshots, provisional transactions, RR deltas, and rank-up/rank-down events.

## Phase 7 — Progression and exceptions

Status: `PLANNED`

- double-progression recommendations and overrides;
- substitutions and pain flags;
- protected periods;
- exact-value corrections and audit history.

## Phase 8 — Release hardening

Status: `PLANNED`

- end-to-end authentication, media, UI, and security verification;
- production Auth rate-limit and optional CAPTCHA review;
- database and Storage RLS audit;
- database advisors and migration review;
- database plus Storage restore drill;
- staging and production setup;
- Vercel preview/production deployment;
- signed Android release;
- operational runbook.

## Current position

```text
Phase 0 complete
Phase 1 ready, not started
```

## Exact next action

Execute `TASK-IMP-001` on branch `codex/task-imp-001-foundation`.

`TASK-IMP-002B` remains planned and blocked until foundation and authentication are complete.

## Reopening rule

A completed decision or phase reopens only when later evidence invalidates its requirements, security assumptions, operations, or completion evidence. Newly requested features must be planned and synchronized before their implementation packet is approved.
