# Stone Set Roadmap

Updated: 2026-08-05

## Completion rule

A phase is complete only when every applicable product, authentication, architecture, UI/UX, accessibility, media, security, operations, testing, documentation, and Git gate is implemented or conclusively closed.

Detailed UI sequencing is defined in `docs/context/UI_IMPLEMENTATION_PLAN.md`.

## Phase 0 — Product discovery, architecture, assets, and implementation planning

Status: `COMPLETE`
Latest planning extension: `TASK-PD-012`
Completed asset task: `TASK-ASSET-001`

Closed outcomes include:

- `rank-v6`, `schedule-v3`, and the accepted hypertrophy routine;
- all 20 `stone-set-ranks-v1` emblems;
- complete Android Home and full-circle rank-progress behavior;
- Android navigation: Home, Week, Progress, Profile;
- dashboard navigation: Overview, Routines, Exercises, Reviews, Activity, Settings;
- shared System/Dark/Light semantic design baseline;
- workout logger behavior with previous comparable performance, fast set entry, autosave, rest timer, draft recovery, and next-incomplete-set navigation;
- dashboard attention-first Overview, autosave state, search, command palette, keyboard shortcuts, adaptive panes, mobile preview, validation summaries, version history, and review diffs;
- calendar/list history, exercise progress, rank/wallet ledgers, and user-owned export planning;
- responsive, keyboard, screen-reader, text-scaling, reduced-motion, error, conflict, and recovery requirements;
- explicit exclusion of social, nutrition, sleep, wearable, AI-coach, camera-form-analysis, CRM, and public-marketplace scope;
- authentication, media, routines, reviews, offline drafts, server authority, release, backup, and recovery decisions;
- approved `TASK-IMP-001` foundation packet.

No application code or external infrastructure was created during Phase 0.

## Phase 1 — Repository and quality foundation

Status: `READY — NOT STARTED`
Packet: `docs/tasks/TASK-IMP-001.md`

Scope:

- Android and Flutter Web shells;
- native Pub workspace;
- local Supabase configuration;
- non-secret templates;
- formatting, analysis, tests, builds, database checks, and CI.

No login, feature UI, product schema, remote infrastructure, credentials, or deployment.

## Phase 2 — Identity, sessions, and authenticated UI foundations

Status: `PLANNED`

Sequence:

```text
TASK-IMP-002A — Identity, login, sessions, profiles, ownership
TASK-IMP-002B — Shared design system and authenticated mobile shell
TASK-IMP-002C — Responsive dashboard shell and Overview
```

### TASK-IMP-002A

- provisioned identities and username aliases;
- mobile/dashboard login and first-password change;
- protected routes, profiles, sessions, logout, expiry, recovery, and RLS tests.

### TASK-IMP-002B

- semantic themes and shared primitives;
- Home, Week, Progress, Profile mobile shell;
- amend the planned packet's old `History` label to `Progress` before approval;
- fixture-driven Home, full-circle rank hero, today's card, week strip, and metrics;
- all accepted loading, offline, pending, provisional, error, accessibility, motion, and performance states.

No real schedule, workout, rank, wallet, or finalization behavior.

### TASK-IMP-002C

- adaptive drawer/rail/sidebar dashboard shell;
- Overview, Routines, Exercises, Reviews, Activity, Settings;
- attention-first fixture Overview and resumable drafts;
- search shell, command palette, shortcut help, save/conflict indicators, adaptive pane primitives, themes, and first-run checklist.

No real authoring, review, search backend, export, or feature persistence.

## Phase 3 — Exercise library, guidance, media, routines, and review

Status: `PLANNED`

### TASK-IMP-003A

- adaptive exercise library;
- structured guidance editor;
- autosave, save state, versions, ownership, and RLS.

### TASK-IMP-003B

- private media storage;
- upload progress, validation, retry, cover, reorder, alt text;
- YouTube normalization/preview and mobile preview.

### TASK-IMP-003C

- routine library and adaptive editor;
- exercise picker and prescriptions;
- duration/set/volume summaries;
- validator summary linked to fields;
- submit/reject/approve/publish;
- immutable review diff, version history, and duplicate-as-new-draft restore.

## Phase 4 — Weekly plans, allocations, locks, and swaps

Status: `PLANNED`
Packet: `TASK-IMP-004`

- materialized week and deterministic allocations;
- real Home and Week binding;
- locks, grants, snapshots, item detail;
- swap selection, before/after preview, payment choice, and atomic result states.

## Phase 5 — Android workout execution and guidance

Status: `PLANNED`

### TASK-IMP-005A

- real Start/Continue/Sync/View result actions;
- workout overview and server start;
- active logger, set rows, previous/best comparable values, progression explanation;
- fast load/reps/RIR entry, automatic rest timer, next incomplete set;
- SQLite autosave/outbox, offline continuation, pending submission, finish/result states.

### TASK-IMP-005B

- structured guidance;
- ordered images and cache;
- YouTube IFrame playback and fallback;
- preserved logger state and non-blocking media failure.

## Phase 6 — Progress, rank, wallet, history, and finalization

Status: `PLANNED`
Packet: `TASK-IMP-006`

- calendar/list history, filters, and workout detail;
- exercise progress charts and comparable-context explanations;
- rank ladder and full-circle progress detail;
- RR/XP/PR/penalty/decay/bonus/milestone/correction evidence;
- wallet ledger, rank motion, and idempotent finalization.

## Phase 7 — Progression, substitutions, protection, and corrections

Status: `PLANNED`
Packet: `TASK-IMP-007`

- recommendations and explanations;
- substitutions, overrides, and pain flags without diagnosis;
- protected periods and exact-value correction history;
- consistent Home/Week/Progress integration.

## Phase 8 — Release hardening, accessibility, export, and operations

Status: `PLANNED`
Packet: `TASK-IMP-008`

- end-to-end product/security/UI verification;
- WCAG 2.2 AA dashboard and keyboard audit;
- TalkBack mobile audit;
- contrast, focus, text scaling, reduced motion, touch targets, and Android API 24 performance;
- autosave/conflict and workout recovery drills;
- user-owned CSV/JSON export with strict ownership and secret exclusion;
- staging/production, backups, restore, Vercel, signed Android, and runbook.

## UI milestone summary

```text
UI-0 COMPLETE — research and accepted system
UI-1 PLANNED  — shared design/mobile foundation
UI-2 PLANNED  — dashboard shell/Overview
UI-3 PLANNED  — dashboard authoring/review
UI-4 PLANNED  — Week/schedule
UI-5 PLANNED  — workout logger/guidance
UI-6 PLANNED  — Progress/rank/wallet/history
UI-7 PLANNED  — exceptions/corrections
UI-8 PLANNED  — release/accessibility/export
```

## Current position

```text
Phase 0 complete
Phase 1 ready, not started
```

## Exact next action

Execute `TASK-IMP-001` on branch `codex/task-imp-001-foundation`.

Do not execute `TASK-IMP-002B` or `TASK-IMP-002C` until prerequisites are merged and their packets are explicitly approved.