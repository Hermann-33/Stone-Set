# TASK-IMP-002B — Implement shared design system, mobile shell, Home and rank hero

Status: `PLANNED — NOT YET AUTHORIZED`
Target phase: `Phase 2 — Identity, sessions and authenticated UI foundation`

Depends on:

1. `TASK-IMP-001` complete and merged;
2. `TASK-IMP-002A` complete and merged;
3. `stone-set-ranks-v1` present and verified;
4. `TECHNOLOGY_BASELINE.md`, `COMPLETE_UI_UX_SYSTEM.md` and `MOBILE_HOME_AND_RANK_PROGRESS_UI.md` still accepted;
5. task-start dependency/tool compatibility verification.

## Objective

Implement Stone Set's shared visual foundation and first substantive Android interface:

- semantic design system;
- Riverpod-backed presentation architecture;
- go_router stateful authenticated shell;
- permanent Home, Week, Progress and Profile destinations;
- fixture-driven Home;
- centered rank emblem with true 360-degree progress track;
- today's workout/rest action card;
- state, accessibility, motion, visual-regression and performance foundations.

This packet is presentation infrastructure. It does not implement authoritative schedules, workouts, SQLite drafts, RR/XP/wallet logic, rank finalization or dashboard feature persistence.

## Mandatory reads

- repository governance/context/roadmap/implementation/UI plan;
- `TECHNOLOGY_BASELINE.md`;
- `DATABASE_AND_SERVER_PLAN.md`;
- `AUTHENTICATION_AND_SESSION_UX.md`;
- `COMPLETE_UI_UX_SYSTEM.md`;
- `MOBILE_HOME_AND_RANK_PROGRESS_UI.md`;
- `APPLICATION_WORKFLOW.md` and `RANK_SYSTEM.md`;
- rank asset manifest/readme;
- merged foundation and identity code/tests.

## Architecture

Use:

```text
View
  -> Riverpod presentation controller/view model
  -> fixture repository interface in this task
  -> deterministic fixture service
```

Rules:

- widgets do not call Supabase;
- immutable view models;
- provider overrides for tests/fixture gallery;
- go_router typed routes;
- `StatefulShellRoute` or current supported equivalent preserves one stack per permanent destination;
- design tokens live in shared UI package;
- feature composition remains mobile-owned;
- no competing state/routing framework.

## Exact scope

## 1. Semantic design system

Implement shared tokens for:

- system/dark/light color roles;
- rank-family semantic palettes;
- typography;
- spacing;
- radii;
- borders;
- elevation/shadow;
- motion duration/curves;
- chart/status colors;
- focus/touch targets;
- reduced motion;
- loading, stale, offline, pending, provisional, success, warning, conflict and error states.

Implement tested primitives required by this packet:

- buttons;
- fields;
- cards;
- chips;
- banners;
- dialogs/sheets;
- skeletons;
- empty/error states;
- status indicators;
- metric tiles;
- navigation primitives.

Avoid screen-specific duplicated colors/styles.

## 2. Rank asset resolver

One stable mapping from rank ID to committed asset path.

Requirements:

- all 20 ranks;
- no filename construction from localized/display text;
- local assets only;
- aspect ratio preserved;
- consistent visible bounds/padding;
- clear unknown-rank failure;
- mapping and manifest tests.

## 3. Authenticated stateful shell

Permanent destinations:

1. **Home**;
2. **Week**;
3. **Progress**;
4. **Profile**.

`Progress` includes future workout history, exercise trends, rank, wallet, milestones and corrections. The obsolete permanent label `History` must not appear.

Requirements:

- separate preserved branch navigation stacks;
- selected tab and scroll restoration;
- predictable Android back behavior;
- protected by `TASK-IMP-002A` auth/first-password-change/compatibility guards;
- accessible labels and touch targets;
- Week, Progress and Profile may use state-complete accessible placeholders in this task;
- contextual routes prepared for rank detail and fixture workout/result placeholders.

## 4. Immutable presentation models

Define UI-facing models for:

- rank progress;
- authoritative/provisional/pending/stale/offline state;
- today's workout/rest item;
- compact seven-day week;
- progression metrics;
- Home loading/empty/error state;
- navigation placeholders.

Models cannot award, calculate or persist authoritative product state.

## 5. Rank-progress hero

Implement exactly the accepted full-circle behavior:

- current emblem centered;
- complete 360-degree inactive track always visible;
- 0 percent = track visible, active sweep zero;
- active arc starts at 12 o'clock and advances clockwise;
- active sweep = 360 degrees multiplied by clamped fraction;
- intermediate arc may use rounded leading cap;
- exact 100 percent uses a seamless closed-ring path with no gap, doubled cap, bump or missing segment;
- authoritative finalized RR only drives the solid arc;
- provisional RR uses a distinct secondary treatment;
- pending local data does not move authoritative progress;
- Adonis shows full ring and max-rank state;
- text and semantics expose rank, RR, percentage and next threshold;
- optional tap opens fixture rank detail.

## 6. Event-driven motion

Implement:

- first stable render;
- same-rank increase/decrease;
- rank-up/rank-down fixture transitions;
- palette transition;
- return without unchanged replay;
- reduced-motion substitution.

Rules:

- no idle animation;
- exact final values;
- disposed/offstage controllers stop;
- repaint boundary around animated hero;
- no full-page rebuild per frame;
- no copied Fortnite particles, timing, sound or choreography.

## 7. Fixture-driven Home

Content order:

1. quiet header/profile/sync state;
2. rank hero;
3. conditional state banner;
4. today's workout/rest card;
5. compact seven-day strip;
6. lifetime XP, multiplier and free-swap metrics;
7. contextual secondary actions.

Today's card fixtures:

- available scheduled workout — `Start workout`;
- active session — `Continue workout`;
- pending local completion — `Sync workout`;
- authoritative completion — `View result`;
- rest day;
- locked;
- unavailable/error.

Callbacks may navigate to labelled fixture placeholders or record test invocations. They cannot start or mutate a real workout.

Real bindings remain:

- `TASK-IMP-004`: schedule and Week data;
- `TASK-IMP-005A`: start/continue/log/sync/result;
- `TASK-IMP-006`: authoritative rank/wallet transactions.

## 8. Fixture gallery

Provide deterministic development routes/previews for:

- all 20 rank assets;
- Bronze I at 0 percent;
- representative rank at 1, 50, 99 and 100 percent;
- exact threshold/rank up;
- rank down;
- provisional delta;
- pending sync;
- stale/offline/error;
- Adonis max rank;
- every today's-card state;
- narrow/normal/large width;
- 100/150/200 percent text scale;
- system/dark/light themes;
- reduced motion.

No production data.

## 9. Accessibility and responsiveness

- Android platform semantics;
- 48 dp minimum targets;
- meaningful traversal order;
- complete hero/action announcements;
- non-color status communication;
- decorative effects excluded from semantics;
- text scale through 200 percent;
- reduced motion;
- safe narrow/normal/large portrait layouts;
- safe landscape fallback;
- no essential clipping.

## 10. Lifecycle and performance

- no ticker/frame scheduling at idle;
- rank assets cached locally;
- bounded rebuilds;
- route/tab state retained;
- no duplicate network/data calls from rebuilds;
- API 24 baseline profiling;
- memory/lifecycle tests for repeated tab/route transitions.

## Non-goals

- real schedule/week persistence;
- real workout start/logger/timers/SQLite/outbox;
- Supabase rank/wallet tables or functions;
- authoritative calculations/finalization;
- dashboard shell beyond shared-token compilation compatibility;
- sound effects;
- third-party animation runtime;
- remote infrastructure;
- copied game UI/assets.

## Protected boundaries

- server authority remains unchanged;
- full inactive track remains visible at every percentage;
- pending/provisional state cannot impersonate final rank;
- `rank-v6` and asset filenames remain unchanged;
- identity/session behavior remains owned by `TASK-IMP-002A`;
- no secrets/private data in fixtures;
- no claims that real workouts or rewards work.

## Acceptance criteria

1. Authenticated Android user reaches a stateful Home/Week/Progress/Profile shell.
2. Each branch preserves route/scroll state.
3. Home follows accepted hierarchy.
4. Rank track is complete at 0 percent and active ring is seamless at 100 percent.
5. Intermediate/threshold/max/provisional/pending states are accurate and understandable without color.
6. All rank assets map exactly once.
7. Today's card maps every accepted state/action correctly.
8. Themes, narrow layouts, 200-percent text and reduced motion work.
9. No continuous idle animation/ticker leak.
10. Fixture, unit, widget, semantics, golden and focused performance checks pass.
11. No authoritative product behavior or infrastructure is introduced.

## Required verification

- format/analyze/build;
- provider/controller unit tests;
- router state/guard/branch tests;
- rank math display/clamping/full-circle state tests;
- asset resolver tests;
- today action mapping tests;
- widget/semantics tests;
- deterministic golden set;
- animation final-frame/lifecycle tests;
- API 24 profile check;
- dashboard build if shared package changes affect it;
- Git diff/secret/fixture review.

## Completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-IMP-002B
Branch/commit/PR:
Design system:
Routing/shell:
Home/rank hero:
Today/week fixtures:
Accessibility/themes:
Tests/builds/CI:
Performance/lifecycle:
Explicitly not implemented:
Documentation:
Risks/blockers:
Exact next action:
```
