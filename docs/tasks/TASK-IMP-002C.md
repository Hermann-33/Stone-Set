# TASK-IMP-002C — Implement responsive dashboard shell and Overview

Status: `PLANNED — NOT YET AUTHORIZED`
Target phase: `Phase 2 — Identity, sessions and authenticated UI foundation`

Depends on:

1. `TASK-IMP-001` complete and merged;
2. `TASK-IMP-002A` complete and merged;
3. shared tokens/primitives from `TASK-IMP-002B`, or an approved sequencing split that extracts shared UI first;
4. `TECHNOLOGY_BASELINE.md`, `COMPLETE_UI_UX_SYSTEM.md` and `UI_IMPLEMENTATION_PLAN.md` still accepted;
5. task-start Flutter Web/browser/dependency compatibility verification.

## Objective

Implement Stone Set's first coherent Flutter Web dashboard baseline:

- protected responsive shell;
- Overview, Routines, Exercises, Reviews, Activity and Settings destinations;
- fixture-driven attention-first Overview;
- global search shell;
- command palette and shortcut guide;
- visible save/offline/conflict states;
- adaptive list-detail/supporting-pane primitives;
- system/dark/light themes;
- browser navigation, accessibility, visual-regression and performance foundations.

This packet is presentation infrastructure. It does not implement exercise, guidance, media, routine, review, schedule, rank, export or audit persistence.

## Mandatory reads

Read governance/context/architecture, `TECHNOLOGY_BASELINE.md`, `DATABASE_AND_SERVER_PLAN.md`, `COMPLETE_UI_UX_SYSTEM.md`, `UI_IMPLEMENTATION_PLAN.md`, authentication UX, application workflow and merged prerequisite code/tests.

## Architecture

Use:

```text
View
  -> Riverpod presentation controller/view model
  -> fixture repository interface
  -> deterministic fixture service
```

Use go_router typed routes for stable URLs, auth redirects, browser back/forward, deep links and error routes.

Rules:

- no direct Supabase calls from widgets;
- no second state/routing framework;
- shared tokens/primitives from `packages/ui`;
- dashboard composition remains dashboard-owned;
- route selection is the source of truth for selected resources where a URL exists;
- local fixture draft/cache state is partitioned by authenticated user.

## Exact scope

## 1. Adaptive shell

### Compact

- top app bar;
- modal navigation drawer;
- one content pane;
- details as routes/full-screen dialogs;
- keyboard and touch support.

### Medium

- navigation rail;
- one main pane;
- optional dismissible supporting pane;
- list-detail where width permits.

### Expanded

- persistent labelled sidebar;
- bounded readable content widths;
- list-detail and three/supporting-pane primitives;
- keyboard-first density.

Branch on available width, not device name. Safe resizing preserves route, selected item, filters, scroll, editor draft and focus where practical.

## 2. Primary routes

1. **Overview**;
2. **Routines**;
3. **Exercises**;
4. **Reviews**;
5. **Activity**;
6. **Settings**.

Only Overview is substantive in this packet. Other routes are accessible, state-complete placeholders linked to future ownership.

Required URL states include login/protected redirect, destination root, selected fixture detail, not found, unauthorized and safe error.

## 3. Overview

Order:

1. Needs attention;
2. Resume work;
3. Published routine/upcoming activation;
4. Recent activity;
5. compact system status;
6. quick actions.

Fixture states:

- first-run setup;
- no attention;
- validation blockers;
- review requested;
- rejected routine;
- media failure;
- save conflict;
- upcoming activation;
- recent publication/activity;
- loading;
- stale/offline;
- error.

Each attention item has one direct resolution action, routed to a labelled placeholder if the destination feature is not implemented.

## 4. Global search shell

Grouped fixture search for:

- routines;
- routine versions;
- exercises;
- guidance revisions;
- reviews;
- activity events.

Requirements:

- `/` focuses search when not editing text;
- arrow navigation;
- Enter opens;
- Esc closes;
- grouped headings and semantic result counts;
- loading/empty/error states;
- no unauthorized result fixtures;
- no backend search in this packet.

## 5. Command palette

`Ctrl/Cmd + K` opens contextual commands:

- create routine;
- create exercise;
- open recent draft;
- open review queue;
- search;
- settings;
- theme;
- shortcut help.

Requirements:

- keyboard-only complete operation;
- visible focus;
- no focus trap;
- disabled commands explain why;
- commands dispatch through typed route/action interfaces, not direct persistence.

## 6. Shortcut help

Searchable, categorized and contextual. Include only implemented shortcuts. Never override standard browser shortcuts without strong justification.

## 7. Save/sync/conflict status primitives

Shared dashboard state indicators:

```text
Saved
Saving
Offline
Syncing
Conflict
Failed to save
Read only
```

Requirements:

- text/semantics, not color alone;
- screen-reader status announcements without stealing focus;
- retry/compare/restore hooks;
- fixture conflict resolution surface;
- no false claim of persistence.

Actual IndexedDB/server draft persistence arrives with authoring tasks.

## 8. Responsive application primitives

Implement reusable tested patterns:

- list-detail scaffold;
- optional supporting pane;
- filter/search header;
- responsive toolbar/overflow actions;
- selected-row/item state;
- validation/error summary;
- status/empty/error/loading panels;
- confirmation/undo surface;
- mobile-preview container;
- keyboard-accessible reorder placeholder pattern.

Do not build complete routine/exercise editors here.

## 9. Themes and interaction states

Use shared semantic tokens for system/dark/light themes.

Implement mouse hover, pressed, selected, disabled, focused and loading states. Focus remains visible and unobscured. Rank colors remain reserved for progression meaning rather than general decoration.

## 10. Accessibility

Dashboard target: WCAG 2.2 AA-equivalent.

Verify:

- keyboard access/no traps;
- logical focus order;
- visible and unobscured focus;
- status announcements;
- labels/instructions;
- error summary patterns;
- 200 percent text scaling/browser zoom;
- contrast/non-color communication;
- reduced motion;
- accessible drawer, rail, sidebar, dialogs, search and palette;
- pointer targets and hover content dismissibility.

## 11. Browser and hosting readiness

- path URL strategy and Vercel SPA rewrite compatibility;
- refresh/direct deep-link tests;
- no secrets/user data in build;
- standard Flutter Web release build baseline;
- no Wasm requirement in this packet;
- proposed CSP/header origins documented for later deployment;
- supported current browsers tested according to Flutter support policy;
- static asset and bootstrap cache assumptions documented.

No Vercel project/deployment is created unless separately authorized.

## 12. Fixture gallery

Provide deterministic routes/previews for:

- compact/medium/expanded shell;
- every Overview state;
- all destinations;
- search states;
- command palette states;
- shortcut help;
- save/offline/conflict states;
- system/dark/light;
- reduced motion;
- 100/150/200 percent text;
- keyboard focus sequence;
- not-found/unauthorized/error.

## Non-goals

- real search;
- IndexedDB/editor autosave implementation;
- exercises/guidance/media;
- routines/validation/reviews;
- activity persistence;
- export;
- production Vercel deployment;
- Supabase product mutations;
- analytics/telemetry SDK;
- copied Figma/Linear/other proprietary UI.

## Acceptance criteria

1. Protected dashboard shell works at compact, medium and expanded widths.
2. Stable URLs, browser back/forward, refresh and direct links behave correctly.
3. Route/selection/scroll state survives safe resizing.
4. Overview follows accepted hierarchy and covers fixtures.
5. Search, palette and shortcut help are fully keyboard accessible.
6. Save/offline/conflict states are explicit and semantically announced.
7. Themes, reduced motion, 200-percent text and focus requirements pass.
8. Shared responsive primitives are reusable and tested.
9. No product persistence or external deployment is introduced.
10. Format/analyze/unit/widget/browser/golden/build/CI checks pass.

## Required verification

- provider/controller unit tests;
- typed router/auth/deep-link/not-found tests;
- resize/state preservation tests;
- keyboard/focus/semantics tests;
- fixture Overview/search/palette/status tests;
- golden tests at compact/medium/expanded and themes;
- browser refresh/back/forward/direct URL checks;
- Flutter Web release build;
- dashboard performance and idle-frame check;
- shared package mobile build regression if affected;
- secret/static-artifact review.

## Completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-IMP-002C
Branch/commit/PR:
Adaptive shell/routes:
Overview:
Search/palette/shortcuts:
Shared primitives/status:
Accessibility/themes:
Browser/build/CI:
Explicitly not implemented:
Documentation:
Risks/blockers:
Exact next action:
```
