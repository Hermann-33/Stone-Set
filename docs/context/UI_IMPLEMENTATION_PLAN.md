# Stone Set Complete UI Implementation Plan

Updated: 2026-08-05
Status: `PLANNED — IMPLEMENT THROUGH APPROVED PACKETS ONLY`
Product baseline: `docs/product/COMPLETE_UI_UX_SYSTEM.md`
Home/rank baseline: `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md`
Planning task: `TASK-PD-012`

## 1. Purpose

This document is the canonical implementation workstream for Stone Set's Android application UI, Flutter Web dashboard UI, and shared design system.

It does not authorize work by itself. Every milestone requires a bounded approved packet, prerequisite verification, implementation, tests, documentation, and Git review.

## 2. Global delivery rules

Every UI milestone must:

- consume semantic tokens rather than hardcoded per-screen styling;
- preserve server authority and ownership boundaries;
- implement loading, empty, populated, stale, offline, pending, provisional, error, and conflict states where applicable;
- support compact, medium, and expanded width behavior where applicable;
- support touch, mouse, keyboard, screen reader, and 200% text scaling;
- include reduced-motion behavior;
- use deterministic fixtures before real integrations are available;
- avoid third-party UI/animation dependencies unless an accepted decision justifies them;
- include widget/golden/semantics tests and focused performance checks;
- update implemented-state documentation accurately.

## 3. Milestone map

```text
UI-0  Research and accepted UX system                     COMPLETE
UI-1  Shared design system + authenticated mobile shell   TASK-IMP-002B
UI-2  Responsive dashboard shell + Overview               TASK-IMP-002C
UI-3  Dashboard exercise/guidance/routine authoring       TASK-IMP-003A/B/C
UI-4  Mobile Week and schedule interaction                TASK-IMP-004
UI-5  Mobile workout logger and guidance                  TASK-IMP-005A/B
UI-6  Mobile Progress, rank, wallet, and history          TASK-IMP-006
UI-7  Progression, substitutions, protection, correction  TASK-IMP-007
UI-8  Accessibility, performance, export, release audit   TASK-IMP-008
```

## 4. UI-0 — Research and accepted system

Status: `COMPLETE`
Tasks: `TASK-PD-011`, `TASK-PD-012`

Deliverables:

- full-circle mobile rank-progress hero;
- complete mobile and dashboard information architecture;
- shared visual and interaction principles;
- complete screen inventory;
- responsive/adaptive behavior;
- accessibility and state standards;
- high-value UX additions;
- phased implementation ownership.

No code is produced in UI-0.

## 5. UI-1 — Shared design system and authenticated mobile shell

Packet: `TASK-IMP-002B`
Status: `PLANNED — BLOCKED BY TASK-IMP-001 AND TASK-IMP-002A`

### Scope

- semantic color, type, spacing, radius, elevation, border, motion, chart, and state tokens;
- system/dark/light theme structure;
- shared buttons, inputs, cards, chips, banners, dialogs, sheets, skeletons, empty states, error summaries, status indicators, metric tiles, and navigation primitives;
- rank asset resolver;
- authenticated mobile shell;
- Home, Week, Progress, and Profile destinations;
- fixture-driven Home and full-circle rank hero;
- fixture-driven today's card and week strip;
- accessible placeholders for non-Home destinations;
- route/scroll state restoration;
- mobile fixture gallery and golden baseline.

### Required amendment before approval

The existing planned packet currently uses the destination label `History`. Before promotion to `APPROVED`, amend it to `Progress`, with workout history nested inside the Progress destination.

### Exit criteria

- all 20 rank assets render through one stable resolver;
- themes and semantic tokens compile on mobile and dashboard packages;
- mobile shell is protected by authenticated state;
- Home covers all accepted fixture states;
- no real weekly plan, workout, rank ledger, or wallet integration is introduced;
- accessibility and performance checks pass.

## 6. UI-2 — Responsive dashboard shell and Overview

Packet: `TASK-IMP-002C`
Status: `PLANNED — BLOCKED BY TASK-IMP-001 AND TASK-IMP-002A`

### Scope

- responsive dashboard shell;
- compact drawer, medium navigation rail, expanded persistent sidebar;
- Overview, Routines, Exercises, Reviews, Activity, and Settings destinations;
- Overview attention queue and resumable drafts using fixtures;
- global search shell;
- command palette;
- searchable keyboard shortcut help;
- save-state indicator patterns;
- responsive list-detail/supporting-pane primitives;
- theme switching;
- accessible placeholder routes for later feature domains;
- fixture gallery and golden baseline.

### Exit criteria

- dashboard routes are protected;
- width changes preserve selection and route state;
- keyboard operation covers navigation, search, command palette, dialogs, and placeholders;
- Overview shows attention, resume, publication, recent activity, and quick-action fixtures;
- no exercise/routine/review persistence is introduced;
- WCAG-oriented automated and manual checks pass.

## 7. UI-3 — Dashboard authoring and review

Packets: `TASK-IMP-003A`, `TASK-IMP-003B`, `TASK-IMP-003C`
Status: `PLANNED`

UI is implemented alongside the corresponding backend/domain work rather than as a disconnected mock-only phase.

## 7.1 Exercise library and guidance persistence — `TASK-IMP-003A`

UI deliverables:

- adaptive exercise list-detail view;
- search, filters, sort, selected-item pane;
- exercise create/edit flow;
- guidance structured-section editor without media upload yet;
- autosave and save-state feedback;
- usage and publication state;
- version-history shell;
- explicit clone behavior;
- empty/loading/error/conflict states.

## 7.2 Images and YouTube — `TASK-IMP-003B`

UI deliverables:

- media uploader with progress, validation, retry, cancellation, and failure states;
- cover selection;
- image reorder with keyboard alternative;
- required alt-text editing;
- YouTube URL normalization, preview, and fallback state;
- side-by-side mobile preview;
- media history and immutable-object explanation;
- no silent overwrite/upsert behavior.

## 7.3 Routine editor and review — `TASK-IMP-003C`

UI deliverables:

- routine library;
- three-pane expanded editor and single-pane compact editor;
- seven-day outline;
- exercise search/picker;
- prescription editor;
- reorder and duplicate actions;
- live duration/set/volume summaries;
- validator summary linked to exact fields;
- publication state bar;
- submit flow;
- review queue;
- immutable diff/review screen;
- approve/reject workflow;
- version timeline and duplicate-as-new-draft restoration;
- mobile workout preview.

### Exit criteria for UI-3

- a user can create guidance, media, and a routine without hidden required steps;
- every blocking validation error is reachable from the summary;
- reload/network loss does not lose draft work;
- keyboard and screen-reader paths exist for core authoring and review;
- self-approval is unavailable and explained;
- published history remains immutable.

## 8. UI-4 — Mobile Week and schedule

Packet: `TASK-IMP-004`
Status: `PLANNED`

### Scope

- replace Home and Week fixtures with materialized plan data;
- week header, current day, seven item cards, lock states, allocations, and penalties;
- compact and large-width selected-item detail;
- future/past week navigation under product rules;
- swap selection mode;
- before/after swap preview;
- allowance and payment selection;
- success/failure/atomic rollback states;
- pinned routine/guidance version detail;
- protection-state presentation.

### Exit criteria

- all 4-, 5-, and 6-day routine patterns render correctly;
- locks and payment effects are explicit;
- canceling preview mutates nothing;
- Home today's card and Week show consistent state;
- schedule data remains server authoritative.

## 9. UI-5 — Mobile workout execution and guidance

Packets: `TASK-IMP-005A`, `TASK-IMP-005B`
Status: `PLANNED`

## 9.1 Workout logger — `TASK-IMP-005A`

### Scope

- workout overview;
- start connectivity validation;
- active workout session header;
- exercise cards and set rows;
- previous comparable performance inline;
- progression recommendation and `Why?`;
- fast numeric entry;
- one-tap valid set completion;
- automatic rest timer;
- next incomplete set navigation;
- autosave and sync state;
- SQLite draft recovery;
- offline continuation;
- finish review and pending submission;
- result-state shell.

### Exit criteria

- logging a normal set requires minimal interaction;
- previous and target values are visible without leaving the logger;
- guidance navigation preserves fields, timers, focus, and scroll state;
- process interruption and network loss do not silently lose work;
- offline finish never displays authoritative rewards;
- all accepted logger states and lifecycle tests pass.

## 9.2 Guidance and media — `TASK-IMP-005B`

### Scope

- full-screen/sheet guidance;
- structured text and table of contents;
- ordered image gallery with placeholder/retry;
- YouTube IFrame playback and fallback;
- active-session text/image cache behavior;
- return to exact logger position;
- no reward coupling.

### Exit criteria

- text guidance is always available for a valid started session;
- media failure never blocks logging;
- backgrounding pauses video and preserves workout state;
- accessibility and offline states pass.

## 10. UI-6 — Progress, rank, wallet, history, and finalization

Packet: `TASK-IMP-006`
Status: `PLANNED`

### Scope

- Progress destination overview;
- calendar and chronological history views;
- filters and search;
- workout detail and result detail;
- exercise progress charts and comparable-context explanations;
- rank ladder and detailed full-circle progress;
- authoritative/provisional/pending RR behavior;
- transaction ledger;
- penalty, decay, bonus, milestone, PR, correction, and configuration details;
- wallet/free-swap balance and ledger;
- rank-up/down/adjustment motion;
- finalization state and transparent calculation details.

### Exit criteria

- every displayed RR/XP/wallet change links to an immutable transaction/evidence record;
- historical corrections remain visible;
- charts have text alternatives and exact values;
- current rank and Home hero agree;
- provisional and pending values never appear final;
- calendar/list filters are stable and testable.

## 11. UI-7 — Progression, substitutions, protection, and corrections

Packet: `TASK-IMP-007`
Status: `PLANNED`

### Scope

- progression recommendation card and explanation;
- accept/override flow;
- substitution selector with comparable-impact explanation;
- pain flag with non-diagnostic safety copy;
- protected-period request/status/history;
- correction request/detail;
- exact before/after values;
- audit timeline;
- Home/Week/Progress state integration.

### Exit criteria

- no recommendation silently mutates a published routine;
- all overrides are explicit;
- medical diagnosis is not implied;
- correction history is never hidden by the corrected total;
- rank and plan surfaces remain consistent.

## 12. UI-8 — Release hardening and trust features

Packet: `TASK-IMP-008`
Status: `PLANNED`

### Scope

- end-to-end UI flows on staging;
- WCAG 2.2 AA dashboard audit;
- TalkBack mobile audit;
- keyboard-only dashboard audit;
- contrast, focus, text-scaling, reduced-motion, and touch-target audit;
- Android API 24 performance profiling;
- dashboard large-data virtualization checks;
- editor autosave/reload/conflict recovery drill;
- active workout process-death/offline recovery drill;
- data export implementation and privacy verification;
- final theme polish;
- loading/empty/error consistency audit;
- localization readiness review;
- release screenshots and operational documentation.

### Exit criteria

- no critical accessibility defects;
- no data-loss path in tested workout/editor recovery scenarios;
- no continuous idle animations/tickers;
- no production secret/private data in client artifacts;
- exports contain only the requesting user's permitted data;
- all UI routes have meaningful loading, empty, error, and recovery states;
- signed Android and production dashboard artifacts pass the same verified UI checks.

## 13. Component delivery order

Implement shared primitives before feature copies:

1. semantic tokens and themes;
2. text, icon, focus, spacing, and motion primitives;
3. buttons and inputs;
4. status banners, chips, save state, errors, empty states, and skeletons;
5. cards, tables/lists, dialogs, sheets, and panes;
6. navigation shells;
7. rank hero and chart primitives;
8. editor primitives;
9. workout logger primitives;
10. feature composition.

No feature may fork a private visual system unless the shared component cannot meet a documented requirement.

## 14. Test strategy by layer

### Token and component tests

- theme snapshots;
- contrast checks;
- component state matrices;
- text scaling;
- keyboard/focus behavior;
- reduced motion;
- semantics.

### Screen tests

- representative fixture goldens;
- width breakpoints;
- loading/empty/error/conflict states;
- route and scroll restoration;
- state-authority distinctions;
- destructive-action recovery.

### Integration tests

- login to protected shell;
- dashboard draft autosave/reload;
- routine create/validate/submit/review;
- materialized week and swap;
- workout start/log/offline/submit;
- finalization and rank update;
- correction/protection history;
- export.

### Manual evidence

- screen-reader recordings/checklists;
- keyboard-only dashboard run;
- low-end Android performance trace;
- network interruption and process-death recovery;
- visual review of all 20 ranks and key charts.

## 15. Completion reporting

Each implementation packet reports:

```text
Verdict
Task and UI milestone
Branch and commit
Pull request
Screens and states implemented
Shared components added/changed
Real integrations versus fixtures
Accessibility checks
Responsive checks
Performance checks
Tests/builds/CI
Screenshots or golden evidence
Explicit exclusions
Risks/blockers
Exact next UI milestone
```

## 16. Current position

```text
UI-0 complete
UI-1 and UI-2 planned, blocked
Exact next implementation action remains TASK-IMP-001
```

Do not execute a UI packet until its prerequisites are merged and its status is explicitly changed to `APPROVED`.