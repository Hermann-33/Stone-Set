# Stone Set Implementation Plan

Updated: 2026-08-05
Status: `IMPLEMENTATION AUTHORIZED FOR APPROVED PACKETS ONLY`
Latest planning task: `TASK-PD-012`

## Starting point

Phase 0 is complete. Product, authentication, architecture, security, media, offline, release, operations, rank assets, and the complete Android/dashboard UI/UX system are accepted.

The repository contains documentation and static rank assets only. No Flutter application, Supabase runtime, remote infrastructure, or product deployment exists.

The complete UI workstream is defined in:

```text
docs/context/UI_IMPLEMENTATION_PLAN.md
```

The complete product-interface baseline is defined in:

```text
docs/product/COMPLETE_UI_UX_SYSTEM.md
docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md
```

## Authorization rule

Implementation proceeds only through packets explicitly marked `APPROVED`.

Current approved packet:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
```

Planned UI packets:

```text
TASK-IMP-002B — Shared design system and authenticated mobile shell
TASK-IMP-002C — Responsive dashboard shell and Overview
```

Neither UI packet is authorized until its prerequisites are complete, merged, reverified, and the packet status is changed to `APPROVED`.

## Target experience architecture

```text
Android Flutter app
  -> username/password login and session guard
  -> Home / Week / Progress / Profile shell
  -> full-circle rank-progress Home hero
  -> today's scheduled workout entry
  -> active workout logger with previous values and rest timer
  -> exercise guidance and media
  -> local SQLite draft/outbox
  -> authoritative online finalization
  -> calendar/list history, progress, rank, wallet, and corrections

Flutter Web dashboard
  -> responsive /login and protected routing
  -> drawer / rail / persistent sidebar shell
  -> attention-first Overview
  -> global search, command palette, shortcut help
  -> exercise and guidance editor
  -> image upload and YouTube preview
  -> routine editor, validator, review diff, version history
  -> Activity and Settings
  -> static Vercel deployment

Shared native Pub workspace
  -> domain models and rules
  -> data/repository adapters
  -> semantic themes, components, charts, panes, forms, validation, and state patterns

Supabase Auth + Postgres + RLS
  -> identities, profiles, ownership, immutable product state, transactions, and atomic transitions

Supabase Storage + RLS
  -> private immutable exercise images
```

## Phase 1 — Repository and quality foundation

Status: `READY — NOT STARTED`
Packet: `TASK-IMP-001`

Scope:

- pin Flutter and tooling;
- create Android-only mobile shell and web-only dashboard shell;
- create native Pub workspace packages;
- initialize local Supabase configuration only;
- add non-secret configuration templates;
- add format, analysis, tests, Android/Web builds, database checks, lint, and CI;
- document local setup and actual structure.

Excluded:

- authentication;
- feature UI;
- product schemas;
- remote projects;
- credentials;
- deployment.

## Phase 2 — Identity, sessions, and authenticated UI foundations

### TASK-IMP-002A — Identity, login, sessions, profiles, and ownership

- provisioned Supabase Auth users and internal aliases;
- mobile and dashboard login;
- first-password change;
- profile ownership and RLS;
- session restoration, route guards, expiry, revocation, operator recovery, and logout;
- mobile draft quarantine and same-account recovery;
- generic errors and rate-limit states.

### TASK-IMP-002B — Shared design system and mobile foundation

Status: `PLANNED — NOT AUTHORIZED`
Packet: `docs/tasks/TASK-IMP-002B.md`
Prerequisites: `TASK-IMP-001` and `TASK-IMP-002A` complete and merged.

Before approval, amend the packet's old `History` label to `Progress`.

Scope:

- System/Dark/Light semantic tokens;
- shared buttons, inputs, cards, status, error, dialog, sheet, skeleton, navigation, rank, and chart primitives;
- authenticated Home, Week, Progress, Profile shell;
- route and scroll restoration;
- fixture-driven Home;
- complete 360-degree rank track, active progress, 0% and seamless 100% behavior;
- all 20 rank assets;
- fixture today's card, week strip, metrics, and all state variants;
- accessibility, reduced motion, golden, lifecycle, and performance checks.

No real schedule, workout, rank, wallet, or finalization integration.

### TASK-IMP-002C — Dashboard shell and Overview

Status: `PLANNED — NOT AUTHORIZED`
Packet: `docs/tasks/TASK-IMP-002C.md`
Prerequisites: Phase 1, `TASK-IMP-002A`, and shared UI tokens available.

Scope:

- adaptive drawer/rail/sidebar protected shell;
- Overview, Routines, Exercises, Reviews, Activity, Settings routes;
- fixture-driven attention-first Overview and resumable drafts;
- global search shell;
- command palette;
- searchable shortcut help;
- save/offline/conflict status patterns;
- responsive list-detail and supporting-pane primitives;
- first-run setup checklist;
- System/Dark/Light theme switching;
- keyboard, focus, WCAG-oriented, responsive, golden, and browser-navigation tests.

No real feature persistence, authoring, review, search backend, export, or deployment.

## Phase 3 — Exercise library, guidance, media, routines, and review

### TASK-IMP-003A — Exercise library and guidance persistence

Backend/domain:

- stable user-owned exercise definitions;
- structured immutable guidance revisions;
- muscle taxonomy;
- content publication and ownership/RLS.

UI:

- adaptive list-detail exercise library;
- search, filters, sort, usage, and clone flow;
- structured guidance editor;
- autosave and save/conflict state;
- version-history shell;
- loading, empty, error, and recovery states.

### TASK-IMP-003B — Images and YouTube

Backend/domain:

- private Storage bucket and owner-scoped policies;
- validation, immutable paths, metadata, and history;
- YouTube normalization.

UI:

- upload progress/retry/cancel;
- cover selection and keyboard-accessible reorder;
- required alt text;
- YouTube preview and fallback;
- side-by-side mobile preview;
- immutable-media explanations.

### TASK-IMP-003C — Routine editor, validator, review, and publication

Backend/domain:

- routine drafts, validator, content hashes, independent review, publication, activation, and audit.

UI:

- routine library;
- expanded three-pane and compact adaptive editor;
- day outline, exercise picker, prescriptions, duplicate/reorder;
- duration/set/volume summaries;
- validator summary linked to exact fields;
- state bar and submit flow;
- review queue and immutable diff/evidence;
- approve/reject;
- version timeline and duplicate-as-new-draft restoration;
- mobile preview.

## Phase 4 — Weekly plans, allocations, locks, and swaps

Packet: `TASK-IMP-004`

Backend/domain:

- materialized seven-day plan;
- pinned versions;
- deterministic RR/XP/penalty allocations;
- grants, locks, timezones, snapshots, and atomic swaps.

UI:

- bind Home today's card and Week to real plan data;
- week navigation and item detail;
- lock, allocation, penalty, protection, and version evidence;
- swap selection, before/after preview, payment choice, cancel, success, failure, and rollback states.

## Phase 5 — Android workout execution and guidance

### TASK-IMP-005A — Workout logger and local drafts

Backend/domain:

- online authoritative session start and lock;
- idempotent mutations and completion;
- SQLite draft and outbox;
- pending submission and grace.

UI:

- real Start/Continue/Sync/View result actions;
- workout overview;
- active session header;
- exercise cards and set rows;
- previous and best comparable performance;
- progression recommendation with `Why?`;
- fast load/reps/RIR input;
- one-tap completion;
- automatic rest timer;
- next incomplete set;
- autosave/sync/offline indicators;
- finish review and pending/provisional/final result states.

### TASK-IMP-005B — Guidance and media playback

- structured guidance route/sheet;
- text snapshot and active-session image cache;
- YouTube IFrame playback and fallback;
- preserved logger fields, timers, focus, route, and scroll state;
- no reward coupling and no blocking media failure.

## Phase 6 — Progress, rank, wallet, history, and finalization

Packet: `TASK-IMP-006`

Backend/domain:

- rewards, penalties, PR cap, consistency, top-ups, bonuses, milestones, decay, wallet, and idempotent finalization.

UI:

- Progress overview;
- calendar and list history;
- filters/search and workout detail;
- exercise progress charts and comparable-context explanations;
- rank ladder and detailed full-circle progress;
- authoritative/provisional/pending states;
- RR/XP/PR/penalty/decay/bonus/milestone/correction/configuration evidence;
- wallet/free-swap ledger;
- rank-up/down/adjustment motion.

## Phase 7 — Progression, substitutions, protection, and corrections

Packet: `TASK-IMP-007`

- recommendation explanation and explicit override;
- substitution and comparable impact;
- pain flags without diagnosis;
- protected periods;
- exact-value correction detail and immutable history;
- consistent Home/Week/Progress integration.

## Phase 8 — Release hardening, accessibility, export, and operations

Packet: `TASK-IMP-008`

UI/reliability:

- complete end-to-end flows on staging;
- WCAG 2.2 AA dashboard audit;
- keyboard-only dashboard audit;
- TalkBack mobile audit;
- 200% text scaling, contrast, focus, reduced motion, and touch-target audit;
- Android API 24 performance profile;
- long-list/editor virtualization and performance;
- dashboard autosave/reload/conflict drill;
- active workout process-death/offline recovery drill;
- consistent loading/empty/error/recovery audit;
- user-owned CSV/JSON export.

Security/operations:

- Auth, RLS, Storage, privilege, advisor, and migration audit;
- staging/production setup;
- database and Storage backups plus restore drill;
- Vercel preview/production deployment;
- signed Android release;
- operational runbook.

## Cross-cutting test strategy

### UI and accessibility

- compact, medium, expanded widths;
- touch, mouse, keyboard, screen reader;
- System/Dark/Light themes;
- 100%, 150%, 200% text scaling;
- normal and reduced motion;
- loading, empty, stale, offline, pending, provisional, conflict, error, and permission states;
- focus, status announcements, labels, error summaries, and non-color communication.

### Mobile workout reliability

- online start;
- set-entry speed and keyboard behavior;
- autosave under rapid edits;
- rest timer lifecycle;
- navigation to guidance and back;
- app background/process recreation;
- offline continuation;
- pending submission;
- no false final reward display.

### Dashboard reliability

- protected deep links and refresh;
- adaptive navigation and resize preservation;
- autosave/reload/offline/conflict;
- keyboard search/command/editor/review;
- validation summary to field;
- immutable version/diff behavior;
- media upload failure/retry;
- no cross-user leakage.

### Product integrity and security

- allocation fixtures;
- validator and self-approval denial;
- immutable hashes and versions;
- PR, swap, penalty, consistency, correction, and finalization tests;
- database and Storage RLS allow/deny;
- no secrets or tokens in logs/artifacts;
- export ownership and secret exclusion.

## Exact next action

Execute:

```text
TASK-IMP-001
branch: codex/task-imp-001-foundation
packet: docs/tasks/TASK-IMP-001.md
```

Do not execute a UI packet until prerequisites are merged and the packet is explicitly approved.