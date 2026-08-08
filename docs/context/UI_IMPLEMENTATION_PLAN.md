# Stone Set Complete UI Implementation Plan

Updated: 2026-08-07
Status: `PLANNED — IMPLEMENT THROUGH APPROVED PACKETS ONLY`

Product baselines:

- `docs/product/COMPLETE_UI_UX_SYSTEM.md`
- `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md`

Architecture/data baselines:

- `docs/context/TECHNOLOGY_BASELINE.md`
- `docs/context/DATABASE_AND_SERVER_PLAN.md`

## 1. Global UI rules

Every UI milestone must:

- use shared semantic design tokens;
- use Riverpod controllers/view models and repository interfaces;
- use typed go_router routes;
- keep widgets independent of Supabase/SQLite/Storage clients;
- preserve server authority and explicit pending/provisional states;
- implement loading, empty, stale, offline, conflict, error and recovery states;
- support system/dark/light, reduced motion and 200-percent text;
- support touch/mouse/keyboard/screen reader as applicable;
- include deterministic fixture routes before integrations;
- include unit/widget/semantics/golden/browser/performance tests;
- preserve route, selected item, filters, draft and scroll state where safe.

## 2. UI milestone map

```text
UI-0 COMPLETE  Research and accepted UX system           PD-011/012/013
UI-1 COMPLETE  Shared design + Android shell/Home         IMP-002B / PR #10
UI-2 COMPLETE  Dashboard shell + Overview                 IMP-002C / PR #12
UI-3 ACTIVE    Exercises/guidance/media/routines/review   IMP-003A merge pending; B/C planned
UI-4 PLANNED   Week/schedule/swap                         IMP-004
UI-5 PLANNED   Workout logger/guidance                    IMP-005A/B
UI-6 PLANNED   Progress/rank/wallet/history               IMP-006
UI-7 PLANNED   Progression/protection/corrections         IMP-007
UI-8 PLANNED   Accessibility/performance/export/release   IMP-008
```

## 3. UI-1 — Shared design system and Android shell/Home

Packet: `TASK-IMP-002B`
Prerequisites: foundation and identity merged.

Deliver:

- semantic color/type/spacing/shape/motion/chart/state tokens;
- shared buttons, fields, cards, banners, dialogs, sheets, skeletons, statuses and metrics;
- Home, Week, Progress and Profile stateful shell;
- all 20 rank assets;
- full-circle Home rank progress;
- fixture today card/week strip/metrics;
- themes, accessibility, fixture gallery and golden baseline.

Week/Progress/Profile remain state-complete placeholders until their data phases.

## 4. UI-2 — Dashboard shell and Overview

Packet: `TASK-IMP-002C`
Prerequisites: foundation, identity and shared UI availability.

Deliver:

- compact drawer, medium rail and expanded sidebar;
- Overview, Routines, Exercises, Reviews, Activity and Settings;
- attention queue and resumable work;
- global search shell;
- command palette and shortcut help;
- save/offline/conflict statuses;
- list-detail/supporting-pane primitives;
- URL/back/forward/refresh behavior;
- theme/accessibility/browser/golden baseline.

## 5. UI-3 — Dashboard authoring and review

### `TASK-IMP-003A`

- exercise list/detail/search/filter/sort;
- structured guidance editor;
- autosave/browser draft recovery;
- version shell, usage and clone;
- conflict compare/recovery.

### `TASK-IMP-003B`

- image preprocessing/upload/progress/retry/cancel;
- cover, alt text and accessible ordering;
- YouTube validation/official preview;
- mobile preview and media history.

### `TASK-IMP-003C`

- routine library;
- expanded three-pane and compact single-pane editor;
- seven-day outline, exercise picker and prescription editor;
- live duration/set/muscle summaries;
- linked validator errors;
- submit, immutable diff, approve/reject;
- version compare and duplicate-as-new-draft.

## 6. UI-4 — Week and schedule

Packet: `TASK-IMP-004`

- real Home today/week binding;
- seven-day schedule and item detail;
- allocations, locks, protection and explanations;
- previous/future week navigation;
- two-date swap selection;
- recovery warnings;
- before/after preview;
- free-credit/RR payment choice and authoritative result.

## 7. UI-5 — Workout logger and guidance

### `TASK-IMP-005A`

- workout overview/start;
- active header/timer/progress;
- previous/best/target context;
- fast load/reps/RIR entry and set completion;
- automatic rest timer and next-incomplete-set;
- SQLite autosave/outbox/offline/pending/conflict;
- finish review/result and notification states.

### `TASK-IMP-005B`

- pinned exercise guidance;
- images/placeholders/retry/offline cache;
- official YouTube player/fallback;
- guidance navigation preserving logger state.

## 8. UI-6 — Progress, rank, wallet and history

Packet: `TASK-IMP-006`

Progress destination sections:

- workout calendar and list;
- filters and workout result;
- exercise trends/PR history;
- rank ladder/progress/explanation;
- RR/XP/wallet transactions;
- consistency/milestones/penalties/decay;
- provisional/finalized/correction evidence.

Home rank hero binds to authoritative snapshots and events.

## 9. UI-7 — Exceptions and corrections

Packet: `TASK-IMP-007`

- progression recommendation and `Why?`;
- override/substitution/pain flag;
- item/full-week protection;
- correction request/evidence/result;
- audit/history links;
- no medical diagnosis.

## 10. UI-8 — Release hardening

Packet: `TASK-IMP-008`

- full accessibility audit;
- supported browser/API 24 performance;
- deep-link/refresh/resize/lifecycle validation;
- security/error/diagnostic states;
- user export UI;
- account deactivation support information;
- production CSP/headers/cache/preview protection;
- visual regression and end-to-end release evidence.

## 11. Shared screen-state standard

Every data surface considers:

```text
initial/loading
empty
populated
refreshing
stale
cached/offline
pending local work
syncing
provisional
conflict
permission denied
validation blocked
recoverable error
terminal error
read only/maintenance
```

Only applicable states are implemented, but omission is explicit.

## 12. Accessibility release gates

- Dashboard WCAG 2.2 AA-equivalent;
- Android platform semantics;
- keyboard complete/no traps;
- visible/unobscured focus;
- linked field errors and status announcements;
- non-color communication;
- 200-percent text;
- reduced motion;
- minimum targets;
- accessible reorder alternatives;
- image alt text;
- screen-reader friendly charts with textual summaries.

## 13. Visual/performance gates

- no continuous decorative animation;
- no full-screen repaint during local animation;
- deterministic fonts/fixtures for goldens;
- local rank assets;
- virtualized/paginated long lists;
- bounded chart points;
- dashboard resizing does not discard work;
- workout logger remains responsive during autosave/timers;
- standard Flutter Web build is baseline; Wasm only after compatibility benchmark.

## 14. Exact next UI action

Generate and review the Linux 003A dashboard goldens, pass final-head CI and merge
`codex/task-imp-003a-exercise-guidance`. The branch implements real exercise/structured-guidance
authoring and browser recovery; media/YouTube, routines/review and later UI remain unapproved.
