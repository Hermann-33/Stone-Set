# TASK-IMP-002C — Implement responsive dashboard shell and Overview

Status: `PLANNED — NOT YET AUTHORIZED`

Depends on:

1. `TASK-IMP-001 — Create Flutter and Supabase project foundation` complete and merged;
2. `TASK-IMP-002A — Identity, login, sessions, profiles, and ownership` complete and merged;
3. shared UI tokens from `TASK-IMP-002B` available or an explicitly approved sequencing revision that builds the shared tokens first;
4. `docs/product/COMPLETE_UI_UX_SYSTEM.md` still accepted and conflict-free;
5. `docs/context/UI_IMPLEMENTATION_PLAN.md` still current.

## Objective

Implement Stone Set's first coherent Flutter Web dashboard baseline: responsive authenticated shell, adaptive navigation, fixture-driven attention-first Overview, global search shell, contextual command palette, keyboard shortcut help, shared save-state patterns, accessible placeholder destinations, responsive list-detail/supporting-pane primitives, themes, and automated verification.

This task implements presentation infrastructure only. It does not implement routine, exercise, guidance, media, review, schedule, workout, rank, wallet, or export persistence.

## Mandatory repository reads

1. `AGENTS.md`
2. `docs/context/ACTIVE_CONTEXT.md`
3. `docs/context/ARCHITECTURE.md`
4. `docs/context/CODEBASE_MAP.md`
5. `docs/context/ROADMAP.md`
6. `docs/context/IMPLEMENTATION_PLAN.md`
7. `docs/context/UI_IMPLEMENTATION_PLAN.md`
8. `docs/context/WORKFLOW.md`
9. `docs/context/HANDOFF.md`
10. `docs/product/AUTHENTICATION_AND_SESSION_UX.md`
11. `docs/product/COMPLETE_UI_UX_SYSTEM.md`
12. `docs/product/APPLICATION_WORKFLOW.md`
13. all code and tests introduced by prerequisite tasks.

## Verified starting state required before approval

The execution agent must verify:

- dashboard builds and tests from the merged foundation;
- responsive `/login`, session restoration, and protected routing exist;
- shared UI tokens compile for web;
- the branch starts from the latest accepted prerequisite merge;
- no competing dashboard information architecture or shell exists;
- no unresolved conflict exists between the UI product documents and architecture;
- this packet has been promoted to `APPROVED` after verification.

If any prerequisite is false, stop and report the conflict.

## Exact scope

### 1. Adaptive dashboard shell

Implement width-driven layouts:

#### Compact

- top app bar;
- modal navigation drawer;
- one content pane;
- details open as routes or full-screen dialogs;
- touch and keyboard support.

#### Medium

- navigation rail;
- one main pane with optional dismissible supporting pane;
- list-detail where space permits.

#### Expanded

- persistent labeled sidebar;
- bounded content width where appropriate;
- list-detail and supporting-pane primitives;
- keyboard-first behavior.

Do not branch on hardware/device type.

### 2. Primary navigation

Destinations:

1. Overview;
2. Routines;
3. Exercises;
4. Reviews;
5. Activity;
6. Settings.

Only Overview requires substantive fixture UI. Other destinations use accessible, clearly labeled placeholders and retain navigation state.

### 3. Overview

Implement fixture-driven sections in this order:

1. Needs attention;
2. Resume work;
3. Published routine / upcoming activation;
4. Recent activity;
5. compact system status;
6. quick actions.

Fixture states include:

- no attention items;
- routine validation blockers;
- review requested;
- routine rejected;
- media failure;
- draft save conflict;
- upcoming activation;
- recent guidance publication;
- empty first-run setup;
- loading, stale, offline, and error.

Each attention item has one direct resolution action, which may route to a placeholder destination in this task.

### 4. Global search shell

Implement a keyboard-accessible grouped-result search UI with fixture results for:

- routines;
- routine versions;
- exercises;
- guidance revisions;
- reviews;
- activity events.

Requirements:

- `/` focuses search when not typing;
- arrow-key navigation;
- Enter opens result;
- Esc closes;
- grouped headings;
- no unauthorized/private result leakage;
- empty, loading, and error states;
- no real backend search in this packet.

### 5. Command palette

`Ctrl/Cmd + K` opens the palette.

Fixture commands:

- create routine;
- create exercise;
- open recent draft;
- open review queue;
- open search;
- open settings;
- switch theme;
- view shortcuts.

Requirements:

- contextual ranking/grouping;
- keyboard operation;
- clear disabled reason;
- no mutating command executes real product behavior in this packet;
- commands route to placeholders or fixture actions.

### 6. Keyboard shortcut help

Implement a searchable help surface opened by `?` when not typing.

It documents:

- global navigation;
- search;
- command palette;
- dialogs/panes;
- context actions;
- future editor shortcuts as unavailable/planned where appropriate.

Shortcuts do not override normal text-editing behavior.

### 7. Save-state component pattern

Implement shared visual/semantic components for:

- Saved;
- Saving;
- Offline — stored locally;
- Syncing;
- Conflict;
- Failed — retry.

Use fixtures only. The component must expose status to screen readers without repeatedly stealing focus.

### 8. First-run setup checklist

Implement a dismissible/resumable fixture checklist:

1. confirm units and timezone;
2. create exercise guidance;
3. create routine;
4. submit for review;
5. obtain approval/activation;
6. begin first scheduled workout.

It is informational only and awards no rank/XP.

### 9. Responsive primitives

Provide tested shared dashboard primitives for:

- page header;
- toolbar;
- filter/search row;
- list-detail scaffold;
- supporting pane;
- responsive table-to-card adaptation;
- empty state;
- attention card;
- recent draft card;
- activity row;
- status chip;
- error summary;
- dialog and confirmation shell;
- skip link and landmark structure.

### 10. Theme and appearance

Implement System, Dark, and Light using semantic shared tokens.

Requirements:

- theme changes persist through the accepted preference boundary or use a temporary local preference until profile persistence exists;
- focus, success, warning, error, authoritative, provisional, and pending semantics remain distinct;
- no rank palette is used as a generic error/focus color.

### 11. Route and UI-state preservation

Preserve where applicable:

- selected destination;
- selected fixture item;
- drawer/rail/sidebar behavior;
- scroll position;
- search query during safe resize;
- supporting-pane state;
- theme.

Back/forward browser navigation must be predictable.

### 12. Accessibility

Implement and verify:

- semantic landmarks and headings;
- skip-to-content;
- visible focus;
- logical tab order;
- keyboard operation for navigation/search/palette/dialogs;
- 200% browser zoom/text scaling;
- non-color state communication;
- status announcements without focus theft;
- minimum practical target sizes;
- no hover-only required information;
- reduced motion.

Target WCAG 2.2 AA behavior for the implemented scope.

### 13. Fixture gallery

Provide deterministic development routes or stories for:

- compact, medium, expanded shells;
- dark/light/system themes;
- empty/new user Overview;
- attention-heavy Overview;
- recent-draft Overview;
- offline/stale/error Overview;
- search states;
- command palette states;
- save-state variants;
- 200% text scaling;
- keyboard focus snapshots;
- reduced motion.

No production user data is permitted.

## Non-goals

This task must not implement:

- exercise/routine/guidance persistence;
- media upload or YouTube preview;
- validator logic;
- submission/review mutations;
- actual activity/audit queries;
- actual global search backend;
- data export generation;
- client management, chat, CRM, or social features;
- remote deployment;
- new secrets or privileged credentials;
- dashboard rank/reward mutation;
- mobile feature changes except compilation fixes in shared tokens.

## Protected boundaries

- Supabase/RLS remains authoritative for identity and future product data.
- Widgets do not call Supabase directly.
- Search fixtures cannot imply cross-user visibility.
- Placeholder commands cannot mutate authoritative state.
- Shared UI tokens remain compatible with Android.
- `TASK-IMP-003A/B/C` own real authoring and review behavior.
- No hidden service-role key enters the dashboard.

## Acceptance criteria

1. Authenticated dashboard users enter a responsive protected shell.
2. Navigation adapts between drawer, rail, and labeled sidebar based on available width.
3. Overview renders the accepted attention-first hierarchy.
4. Search, command palette, and shortcut help are fully keyboard operable using fixtures.
5. Overview and shell support loading, empty, stale, offline, error, and attention states.
6. System/dark/light themes use semantic tokens.
7. Route, selection, and scroll state survive safe navigation and resizing.
8. Core content works at 200% scaling without essential clipping.
9. Focus, status, and error behavior meet the accepted accessibility contract.
10. No real product persistence, backend feature, or infrastructure is introduced.
11. Widget, golden, semantics, browser navigation, and build checks pass.

## Required tests and checks

### Formatting and analysis

- repository formatting command;
- Dart/Flutter analysis;
- dependency-boundary checks.

### Unit tests

- breakpoint/layout selection;
- command visibility/enabling;
- search grouping/filtering fixtures;
- theme preference mapping;
- save-state semantics mapping;
- navigation state reducer.

### Widget tests

- protected shell;
- destination navigation;
- drawer/rail/sidebar behavior;
- Overview sections and states;
- search keyboard flow;
- command palette keyboard flow;
- shortcut help;
- dialogs/supporting panes;
- theme switching;
- 200% scaling;
- reduced motion;
- focus order and semantics.

### Golden tests

- compact Overview;
- medium Overview;
- expanded Overview;
- dark and light themes;
- attention-heavy state;
- empty setup state;
- offline/error state;
- 200% scaling;
- visible keyboard focus.

### Browser and build checks

- Flutter Web build;
- protected-route deep link and refresh;
- browser back/forward;
- resize state preservation;
- keyboard-only smoke test;
- no horizontal overflow at accepted widths.

### Performance checks

- no continuous frame scheduling at idle;
- bounded rebuilds when navigation or search state changes;
- placeholder long lists remain responsive;
- no expensive work on every resize frame.

## Required documentation updates on completion

- `docs/context/ACTIVE_CONTEXT.md`;
- `docs/context/CODEBASE_MAP.md`;
- `docs/context/ROADMAP.md`;
- `docs/context/IMPLEMENTATION_PLAN.md`;
- `docs/context/UI_IMPLEMENTATION_PLAN.md`;
- `docs/context/HANDOFF.md`;
- append-only audit successor;
- dashboard setup/component documentation.

## Git requirements

- dedicated branch from the latest accepted prerequisite merge;
- suggested branch: `codex/task-imp-002c-dashboard-ui-foundation`;
- do not work directly on `main`;
- commit messages contain `TASK-IMP-002C`;
- open a pull request to `main`;
- report exact automated/manual accessibility evidence.

## Completion-report schema

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-IMP-002C
Branch:
Commit:
Pull request:
Files changed:
Dashboard shell implemented:
Overview implemented:
Search and command palette implemented:
Responsive modes implemented:
Theme modes implemented:
Fixture states implemented:
Explicitly not implemented:
Tests/checks/builds:
CI result:
Accessibility result:
Keyboard result:
Performance result:
Documentation updated:
Risks/blockers:
Exact next action:
```