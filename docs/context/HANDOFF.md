# Stone Set Latest Handoff

Updated: 2026-08-05

## Current task

`TASK-PD-012 — Research and define the complete app and dashboard UI system`

## Result

Stone Set now has a complete accepted UI/UX system for the Android application, Flutter Web dashboard, and shared design components.

### Research completed

Reviewed current official guidance and product behavior from Flutter, Material, W3C, Hevy, Hevy Coach, Fitbod, Strava, Figma, Linear, TrueCoach, and relevant Reddit discussions.

Material findings:

- workout history and targets must be visible in the logging context;
- set entry must minimize interaction cost;
- draft recovery and autosave are trust requirements;
- dashboard Overview should prioritize unresolved work and resumable drafts;
- responsive list-detail/supporting-pane layouts fit the dashboard domains;
- keyboard access, search, command palette, version history, diff, and explicit validation materially improve desktop workflows;
- history needs calendar, list, and exercise-specific views;
- recommendations, locks, penalties, and rank changes need explanations.

### Accepted Android structure

```text
Home | Week | Progress | Profile
```

`Progress` supersedes the narrower `History` label.

Accepted mobile behavior includes:

- Home full-circle rank hero and today's action;
- Week schedule, locks, swaps, allocations, and item detail;
- workout overview and active logger;
- previous and best comparable performance inside the logger;
- fast load/reps/RIR entry;
- one-tap set completion and automatic rest timer;
- next-incomplete-set navigation;
- transactional autosave, offline continuation, and pending submission;
- structured guidance preserving workout state;
- calendar/list history, exercise charts, rank/wallet ledgers, and corrections;
- complete settings, theme, accessibility, cache, session, export, and logout surfaces.

### Accepted dashboard structure

```text
Overview | Routines | Exercises | Reviews | Activity | Settings
```

Accepted dashboard behavior includes:

- drawer, rail, and persistent sidebar based on width;
- attention-first Overview and resumable drafts;
- global search;
- command palette and searchable keyboard shortcuts;
- Saved/Saving/Offline/Syncing/Conflict/Failed states;
- adaptive list-detail and supporting panes;
- exercise library and structured guidance editor;
- image upload, alt text, reorder, YouTube preview, and mobile preview;
- adaptive routine editor with linked validation summary;
- immutable review diff, version timeline, and duplicate-as-new-draft restore;
- human-readable Activity and user-owned CSV/JSON export planning.

### Shared design and quality baseline

- System, Dark, and Light modes through semantic tokens;
- standardized loading, empty, stale, offline, pending, provisional, conflict, permission, error, and recovery states;
- WCAG 2.2 AA-equivalent dashboard target;
- TalkBack/platform-equivalent mobile accessibility;
- 200% text scaling, keyboard access, visible focus, reduced motion, and non-color communication;
- no continuous idle animation;
- no social, nutrition, sleep, wearable, AI coach, camera form analysis, CRM, or public marketplace scope.

## New canonical documents

```text
docs/product/COMPLETE_UI_UX_SYSTEM.md
docs/context/UI_IMPLEMENTATION_PLAN.md
docs/tasks/TASK-PD-012.md
docs/tasks/TASK-IMP-002C.md
```

Existing Home/rank specification remains canonical:

```text
docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md
```

## UI implementation sequence

```text
UI-0 COMPLETE — research and accepted UX system

TASK-IMP-001
  repository and quality foundation

TASK-IMP-002A
  identity, login, sessions, profiles, ownership

TASK-IMP-002B / UI-1
  shared design system and authenticated mobile shell
  fixture Home and full-circle rank hero

TASK-IMP-002C / UI-2
  responsive dashboard shell and attention-first Overview

TASK-IMP-003A/B/C / UI-3
  dashboard exercise, guidance, media, routine, review, versions

TASK-IMP-004 / UI-4
  Week, schedule, locks, and swaps

TASK-IMP-005A/B / UI-5
  workout logger, drafts, timers, guidance, media

TASK-IMP-006 / UI-6
  Progress, rank, wallet, history, and finalization

TASK-IMP-007 / UI-7
  progression, substitutions, protection, corrections

TASK-IMP-008 / UI-8
  release accessibility, performance, recovery, export, operations
```

## Required packet correction

Before `TASK-IMP-002B` is promoted to `APPROVED`, change its old mobile destination label from `History` to `Progress`.

## Protected behavior

- Clients never award RR or choose authoritative rank.
- Server authority, RLS, immutable versions, independent review, and finalization remain unchanged.
- Previous/best values must use accepted comparable-context rules.
- Draft work is never silently discarded.
- Published history is immutable; restore creates a new draft.
- Search, Activity, fixtures, and export cannot expose another user's private data.
- No third-party UI/animation dependency is assumed without a separate decision.
- No proprietary competitor screenshot or exact UI is copied.

## Repository and branch

- Repository: `Hermann-33/Stone-Set`
- Planning branch: `codex/task-pd-011-mobile-home-rank-ui`
- Pull request: `#2`
- Product code added: none
- External infrastructure changed: none

## Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
UI-0 — COMPLETE
```

## Exact next action

Review and merge Pull Request `#2`, then execute:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
branch: codex/task-imp-001-foundation
packet: docs/tasks/TASK-IMP-001.md
```

Do not execute `TASK-IMP-002B` or `TASK-IMP-002C` yet.

## Verdict

`COMPLETE`
