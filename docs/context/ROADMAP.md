# Stone Set Roadmap

Updated: 2026-08-04

## Completion rule

A phase is complete only when every applicable product, architecture, media, security, operations, testing, documentation, and Git gate is implemented or conclusively closed for that phase.

## Phase 0 — Product discovery, architecture, and implementation planning

Status: `COMPLETE`
Latest extension: `TASK-PD-009`

Closed outcomes:

- evidence-informed initial hypertrophy routine and 60-minute cap;
- `rank-v6`, `schedule-v3`, and normalized multi-user fairness;
- swaps, free-credit wallet, penalties, PRs, consistency, and finalization;
- reviewed reward-eligible routine rules through `routine-validator-v1`;
- accepted end-to-end workflow;
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

No application code or external infrastructure was created during Phase 0.

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

Phase 1 excludes authentication, product schema, Storage bucket or policy, exercise media, YouTube player, routines, workouts, rank behavior, SQLite feature implementation, remote projects, credentials, and deployment.

## Phase 2 — Identity and ownership

Status: `PLANNED`

- provisioned Supabase Auth sign-in;
- profiles, units, and reward timezone;
- RLS ownership and cross-user denial tests;
- session, logout, and cache cleanup behavior.

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
- schedule snapshots, locks, swaps, timezone, and idempotency.

## Phase 5 — Android workout execution and guidance

Status: `PLANNED`

- workout overview and exercise instruction UI;
- image prefetch and active-session cache;
- official YouTube IFrame playback through Android WebView;
- online session start;
- timers and set logging;
- SQLite active draft and outbox;
- offline continuation and pending submission;
- server completion validation and provisional result presentation.

## Phase 6 — Rank, wallet, and finalization

Status: `PLANNED`

- daily awards and penalties;
- weekly PR cap;
- consistency, top-ups, milestones, and decay;
- swaps and wallet ledger;
- idempotent weekly finalization and transparent history.

## Phase 7 — Progression and exceptions

Status: `PLANNED`

- double-progression recommendations and overrides;
- substitutions and pain flags;
- protected periods;
- exact-value corrections and audit history.

## Phase 8 — Release hardening

Status: `PLANNED`

- end-to-end, media, and security verification;
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

## Reopening rule

A completed decision or phase reopens only when later evidence invalidates its requirements, security assumptions, operations, or completion evidence. Newly requested features must be planned and synchronized before their implementation packet is approved.
