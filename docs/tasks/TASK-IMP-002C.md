# TASK-IMP-002C — Implement responsive dashboard shell and Overview

Status: `APPROVED — NOT EXECUTED`
Approved by: `TASK-PD-017`
Target phase: `Phase 2 — Identity, sessions and authenticated UI foundation`

Depends on:

1. `TASK-IMP-001` complete and merged;
2. `TASK-IMP-002A` complete and merged;
3. merged shared tokens/primitives from `TASK-IMP-002B` remain available;
4. `TECHNOLOGY_BASELINE.md`, `COMPLETE_UI_UX_SYSTEM.md` and `UI_IMPLEMENTATION_PLAN.md` still accepted;
5. task-start Flutter Web/browser/dependency compatibility verification.

## Verified starting state

Verified on 2026-08-07 before approval:

```text
TASK-IMP-001             COMPLETE AND MERGED
TASK-IMP-002A            COMPLETE AND MERGED
TASK-IMP-002B            COMPLETE AND MERGED
Mobile presentation PR  #10 — MERGED
Mobile presentation SHA 1ab0fc56543dbd64500a9319dd6a3f014c4ccc90
Final 002B CI           31109946478 — PASS
Flutter                 3.44.7
Dart                    3.12.2
Node.js                 24.11.1
Supabase CLI            2.111.0
Workspace lockfile      one root pubspec.lock; no nested lockfiles or overrides
Dashboard platform      Web only
Dashboard runtime       identity/session routes and protected placeholder only
Shared UI               semantic themes/primitives and rank presentation merged
Later product runtime   NOT IMPLEMENTED
Remote infrastructure   NONE
```

The proven application/build graph remains:

```text
flutter_riverpod       3.3.2
riverpod_annotation    4.0.3
riverpod_generator     4.0.4
go_router              17.4.0
go_router_builder      4.4.0
supabase_flutter       2.17.1
build_runner           2.15.1
analyzer               12.1.0
test                   1.31.0
test_api               0.7.11
```

`analysis_options.yaml` selects analysis-server plugin `riverpod_lint 3.1.8` separately from the
application workspace lock graph. Preserve this coordinated baseline. Do not introduce dependency
overrides, nested lockfiles, obsolete `custom_lint` configuration, a second state framework or a
second router. No new third-party dependency is approved by this packet. The Flutter SDK
`flutter_web_plugins` dependency may be declared if required for the official path URL strategy;
that is an SDK integration, not authorization for an unrelated package.

Current official Flutter guidance confirms that Flutter Web remains appropriate for an app-centric
single-page application, that path URLs require an `index.html` rewrite, and that the default
non-Wasm release build uses CanvasKit across modern supported browsers. This packet retains the
standard release build and requires implementation-start re-verification against Flutter 3.44.7.

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

The existing `DashboardSessionController`, session restoration, refresh/foreground revalidation,
`IdentityRouteGuard`, mandatory password-change route, active-profile/compatibility checks,
private-cache clearing and logout/back-navigation protections remain the identity boundary. The
dashboard shell must be mounted only after a verified active bootstrap. Logout, session loss,
operator revocation or authenticated user-ID change must destroy all fixture/search/palette/
selection/scroll/provider state owned by the prior user.

## Required branch and Git behavior

```text
branch: codex/task-imp-002c-dashboard-shell-overview
no work directly on main
no history rewriting or force-push
all implementation commits contain TASK-IMP-002C
push the branch
open a draft pull request targeting main
inspect the complete main...HEAD diff
report branch, commit, pull request and final-head CI
```

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

Use the official Flutter path URL strategy and retain the committed Vercel SPA fallback to
`index.html`. Do not use hash URLs. A direct request or refresh at every protected fixture route
must resolve through the same auth/bootstrap guard as in-app navigation.

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

The implementation may document proposed headers and cache behavior, but it must not add deployment
credentials, link a Vercel project, connect a remote Supabase environment or claim that a local
browser build proves production hosting.

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
- copied Figma/Linear/other proprietary UI;
- any migration, Storage object, Supabase configuration change or remote infrastructure;
- replacing or weakening existing identity/session/password-proof/signup/RLS/operator boundaries;
- persisting fixtures in browser storage or presenting fixture data as a real saved product record.

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

- exact `dart pub get --enforce-lockfile` and `npm ci`, followed by tracked-file cleanliness;
- one root lockfile, no nested lockfiles and no dependency overrides;
- two-pass Riverpod/typed-route generation with zero outputs on the freshness pass;
- formatting and strict fatal-info analysis including Riverpod lint;
- provider/controller unit tests;
- typed router/auth/deep-link/not-found tests;
- existing login/password/session/expiry/revocation/logout/cache-clearing regression tests;
- resize/state preservation tests;
- keyboard/focus/semantics tests;
- fixture Overview/search/palette/status tests;
- reviewed deterministic Linux goldens at compact/medium/expanded widths and light/dark themes;
- 100/150/200-percent text, reduced-motion and high-contrast/non-color state tests;
- browser refresh/back/forward/direct URL checks;
- Flutter Web release build;
- dashboard performance and idle-frame check;
- shared package mobile build regression if affected;
- secret/static-artifact review;
- Android release build and existing mobile test/golden/API 24 CI regression gates;
- local Supabase clean reset, Auth/signup/operator/pgTAP/lint regression gates through required CI;
- complete `main...HEAD` diff, `git diff --check`, generated-file review and clean tree;
- all required GitHub Actions checks passing on the final PR head with no unexpected skip.

## Required documentation updates

Update only implemented facts in `README.md`, canonical context, this packet, `HANDOFF.md` and the
active append-only audit volume `docs/context/AUDIT_LOG_CONTINUED_3.md`. Do not approve
`TASK-IMP-003A` during implementation. Do not claim product persistence, remote deployment or later
dashboard authoring behavior exists.

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
