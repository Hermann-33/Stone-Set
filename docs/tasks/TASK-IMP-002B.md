# TASK-IMP-002B — Implement mobile design system, authenticated shell, and rank hero

Status: `PLANNED — NOT YET AUTHORIZED`
Depends on:

1. `TASK-IMP-001 — Create Flutter and Supabase project foundation` complete and merged;
2. `TASK-IMP-002A — Identity, login, sessions, profiles, and ownership` complete and merged;
3. `stone-set-ranks-v1` assets present on the execution branch;
4. `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md` still accepted and conflict-free.

## Objective

Implement Stone Set's first coherent Android UI baseline: semantic design tokens, authenticated four-destination navigation shell, fixture-driven Home screen, centered animated rank-progress hero, rank-asset mapping, today's workout/rest card, loading and synchronization states, accessibility behavior, and automated visual/widget verification.

The packet builds presentation infrastructure only. It does not implement authoritative weekly-plan persistence, workout execution, RR, XP, rank finalization, wallet, or history persistence.

## Mandatory repository reads

1. `AGENTS.md`
2. `docs/context/ACTIVE_CONTEXT.md`
3. `docs/context/PROJECT_BRIEF.md`
4. `docs/context/ARCHITECTURE.md`
5. `docs/context/CODEBASE_MAP.md`
6. `docs/context/ROADMAP.md`
7. `docs/context/IMPLEMENTATION_PLAN.md`
8. `docs/context/WORKFLOW.md`
9. `docs/context/HANDOFF.md`
10. `docs/product/AUTHENTICATION_AND_SESSION_UX.md`
11. `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md`
12. `docs/product/APPLICATION_WORKFLOW.md`
13. `docs/product/RANK_SYSTEM.md`
14. `assets/ranks/README.md`
15. `assets/ranks/manifest.json`
16. all code and tests introduced by `TASK-IMP-001` and `TASK-IMP-002A`.

## Verified starting state required before approval

The execution agent must verify:

- the Android application builds and tests through the merged foundation;
- protected navigation and an authenticated user/session boundary exist;
- the branch starts from the latest accepted implementation base;
- no competing mobile design system or Home implementation exists;
- all 20 rank files resolve and match the manifest;
- rank thresholds remain `rank-v6`;
- the packet has been promoted from `PLANNED` to `APPROVED` after prerequisite verification.

If any prerequisite is false, stop and report the conflict rather than implementing around it.

## Exact scope

### 1. Semantic design system

Create or extend shared UI-package tokens for:

- background, surface, raised surface, border, text, muted text, warning, success, and error colors;
- rank-family semantic colors;
- spacing scale;
- corner-radius scale;
- border widths;
- elevation/shadow levels;
- typography roles;
- standard motion durations and curves;
- reduced-motion policy;
- minimum touch targets.

Do not hardcode rank colors independently in multiple screens.

### 2. Rank asset resolver

Implement one tested mapping from stable rank identity to committed asset path.

Requirements:

- cover all 20 assets;
- fail clearly for an unknown rank identity;
- avoid filename construction from user-visible rank text;
- keep the manifest as source evidence;
- load assets locally with no network dependency;
- preserve aspect ratio and prevent clipping.

### 3. Presentation models

Define immutable UI-facing models for:

- rank progress;
- synchronization and provisional state;
- today's workout/rest item;
- seven-day compact week state;
- Home metrics.

The presentation layer must not:

- write RR or XP;
- determine authoritative rewards;
- call Supabase directly;
- start or finalize a server workout;
- finalize rank transitions;
- contain service credentials;
- infer product authority from animation state.

Provide deterministic fixture factories for representative rank, progress, loading, stale, provisional, pending, offline, error, rank-up, rank-down, max-rank, workout, and rest states.

### 4. Rank-progress hero

Implement the accepted hero using first-party Flutter primitives unless a later accepted decision authorizes another dependency.

Required behavior:

- centered rank emblem;
- full `360°` inactive circular track that is always visible;
- active authoritative progress arc beginning at 12 o'clock and advancing clockwise;
- `0%`: full inactive track visible and zero active sweep;
- intermediate progress: active arc overlays the matching portion of the track;
- `100%`: seamless full active circle with no gap, overlap bump, doubled cap, or missing segment;
- rounded active cap for intermediate fractions where visually appropriate;
- rank-family palette;
- textual rank, RR, percentage, and next-rank summary;
- Adonis max-rank presentation;
- provisional secondary treatment;
- pending-sync indication outside the authoritative ring;
- complete semantics;
- optional tap callback for the future progression route.

The ring renderer must clamp invalid fractions to `0...1`. It must use a special full-circle rendering path or equivalent treatment at `1.0` so the result is visually continuous.

The previous near-complete ring with a top gap is not part of the accepted design.

### 5. Motion controller

Implement event-driven animation for:

- first stable render;
- same-rank RR increase;
- same-rank RR decrease;
- authoritative rank up;
- authoritative rank down;
- palette transition;
- reduced-motion substitution;
- return to Home without unchanged replay.

No continuous idle animation is allowed.

Animation code must:

- dispose all controllers and tickers;
- stop when offstage where applicable;
- avoid rebuilding the entire Home screen per frame;
- isolate the animated region with a repaint boundary;
- finish at exact authoritative display values;
- preserve the inactive track at all times;
- resolve an exact 100% state to a seamless closed ring.

### 6. Authenticated mobile shell

Implement the initial four destinations:

1. Home;
2. Week;
3. History;
4. Profile.

Only Home requires substantive UI in this packet. Other destinations may use tested, accessible, clearly labelled placeholders that preserve navigation and state.

Requirements:

- route state survives tab changes;
- back behavior is predictable;
- protected shell is inaccessible without accepted authenticated state;
- logout and session-loss behavior remain owned by `TASK-IMP-002A`;
- no dashboard changes unless required for a shared-token compilation fix.

### 7. Fixture-driven Home screen

Implement the accepted content order:

1. header;
2. rank hero;
3. conditional pending/provisional banner;
4. today's workout/rest card;
5. week strip;
6. compact progression metrics.

This packet uses fixture-backed presentation data. It does not read real weekly plans or rank-ledger state.

#### Today's card visual states

Support fixtures for:

- available scheduled workout;
- active workout;
- pending synchronization;
- completed workout;
- rest day;
- locked state;
- unavailable/error state.

#### Today's card primary actions

Expose state-dependent callbacks and labels:

- available workout: `Start workout`;
- active workout: `Continue workout`;
- pending local completion: `Sync workout`;
- completed authoritative workout: `View result`;
- rest day: `Rest day` non-workout state;
- locked/unavailable: disabled action with reason and optional retry.

The fixture callbacks may navigate to clearly labelled placeholder surfaces or record test invocations. They must not start a real session or mutate product state.

Real behavior is connected later:

- `TASK-IMP-004` supplies the materialized today's item and week data;
- `TASK-IMP-005A` makes `Start workout`, `Continue workout`, and `Sync workout` functional and provides set logging, local drafts, timers, and submission;
- `TASK-IMP-005A` or its accepted completion route enables `View result` with real data.

A programmed rest day must not expose a rewarded unscheduled workout action or manual completion control.

The week strip supports seven fixture items and selected, locked, completed, workout, and rest visual states.

### 8. Responsive and accessibility behavior

Implement and verify:

- narrow Android phone layout;
- normal phone layout;
- larger-width behavior;
- portrait baseline;
- text scaling through 200%;
- 48 dp minimum interaction targets;
- semantic rank announcement;
- semantic today's-action labels;
- meaningful focus and traversal order;
- non-color status communication;
- reduced motion;
- no decorative semantics.

Landscape may use a safe fallback layout but is not a polished MVP target unless the accepted mobile policy changes.

### 9. Preview and test fixtures

Provide deterministic development previews or fixture routes for:

- Bronze I at 0%, showing the complete inactive track;
- one middle rank at 1%, 50%, 99%, and 100%;
- exact rank-up boundary;
- representative rank-down;
- Diamond III with provisional delta;
- pending synchronization;
- stale/offline snapshot;
- error fallback;
- Adonis max rank;
- reduced motion;
- 200% text scale;
- each today's-card action state.

No production user data is permitted in fixtures.

## Non-goals

This packet must not implement:

- Supabase rank tables, transactions, functions, or RLS;
- rank/RR/XP calculation;
- real materialized weekly plans;
- routine, exercise, or guidance management;
- real workout start, set entry, timers, SQLite drafts, outbox, or submission;
- authoritative pending submission;
- swaps or wallet behavior;
- rank history persistence;
- progression-detail business data;
- web dashboard Home redesign;
- sound effects;
- copied Fortnite assets, exact geometry, typography, particles, or sound;
- a third-party animation runtime without a separate accepted decision;
- remote infrastructure or deployment.

## Protected boundaries

- The server remains authoritative for identity, RR, XP, rank, weekly state, workout start, submission, and finalization.
- Solid active ring progress represents authoritative finalized RR only.
- The full inactive track remains visible at every progress value.
- Provisional state never changes the authoritative rank emblem.
- Local pending data never changes the authoritative active arc.
- `rank-v6` thresholds and names remain unchanged.
- `stone-set-ranks-v1` files are not renamed or silently replaced.
- Login/session behavior remains compatible with `TASK-IMP-002A`.
- The visual result must be recognizably Stone Set, not a Fortnite reproduction.
- No secrets, credentials, private media, or personal data enter the repository.

## Acceptance criteria

1. Android authenticated users land in a four-destination shell.
2. Home renders the accepted information hierarchy.
3. The rank emblem is centered inside a complete circular track.
4. At 0%, the complete inactive track is visible and the active sweep is zero.
5. At intermediate values, active progress is accurate and clockwise.
6. At 100%, the active ring is visually complete and seamless around the full circumference.
7. Progress is accurate for 0, intermediate, threshold, and max-rank fixtures.
8. All 20 rank identities resolve to exactly one local asset.
9. Rank, RR, percentage, next-rank, provisional, and pending states are readable without color.
10. First render, increase, decrease, rank-up, and rank-down motion end at exact final values.
11. Reduced-motion mode avoids sweep, scale, and spatial transitions.
12. Reopening unchanged Home does not replay entrance animation.
13. Today's card exposes correct fixture states and `Start workout`, `Continue workout`, `Sync workout`, `View result`, and rest behavior.
14. Today's card and week strip are reusable, state-complete presentation widgets.
15. Narrow layouts and 200% text scaling do not clip essential content.
16. Semantics expose one coherent rank-progress action and correct status/action text.
17. The UI has no continuous idle animation or active ticker after disposal.
18. Widget, golden, semantics, and focused performance checks pass.
19. No authoritative product behavior or external infrastructure is introduced.

## Required tests and checks

### Formatting and analysis

- repository formatting command;
- Dart/Flutter static analysis;
- dependency-boundary checks introduced by foundation.

### Unit tests

- progress clamping and display rounding;
- 0% and exact 100% renderer-state selection;
- max-rank model;
- asset mapping for all 20 ranks;
- animation-state transition reducer/controller;
- provisional versus authoritative presentation;
- stale and pending state mapping;
- today's-card action mapping.

### Widget tests

- shell navigation and route preservation;
- hero at 0%, intermediate values, and 100%;
- rank-up and rank-down final frames;
- pending and provisional banners;
- all today-card states and callbacks;
- week-strip states;
- reduced motion;
- text scaling and narrow width;
- semantic labels and traversal.

### Golden tests

Use stable deterministic fonts and fixtures for:

- Bronze I 0% with visible complete track;
- representative middle rank 50%;
- representative rank at exact 100%;
- Diamond III provisional state;
- Adonis max-rank state;
- available workout card;
- active workout card;
- rest-day card;
- narrow width;
- 200% text scale;
- reduced-motion static frame.

Golden coverage need not snapshot every animation frame.

### Performance and lifecycle checks

- profile ring animation on accepted Android baseline;
- verify no continuous frame scheduling at idle;
- verify `RepaintBoundary` containment;
- verify controllers dispose and offstage destinations do not animate;
- verify local asset loading without network access.

### Build checks

- Android debug build;
- all foundation-required test/build commands;
- dashboard build only if shared UI changes affect it.

## Required documentation updates on completion

- `docs/context/ACTIVE_CONTEXT.md`;
- `docs/context/CODEBASE_MAP.md`;
- `docs/context/ROADMAP.md`;
- `docs/context/IMPLEMENTATION_PLAN.md`;
- `docs/context/HANDOFF.md`;
- append-only audit continuation;
- application README/setup documentation;
- package and component documentation where required.

Do not rewrite accepted product or audit history.

## Git requirements

- Work on a dedicated branch created from the latest accepted prerequisite merge.
- Suggested branch: `codex/task-imp-002b-mobile-home-rank-ui`.
- Do not work directly on `main`.
- Commit messages must contain `TASK-IMP-002B`.
- Open a pull request to `main`.
- Report exact tests, builds, CI, visual evidence, and remaining integrations.

## Completion-report schema

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-IMP-002B
Branch:
Commit:
Pull request:
Files changed:
Design system implemented:
Navigation shell implemented:
Home and rank hero implemented:
Today's workout action states implemented:
Fixture states implemented:
Explicitly not implemented:
Tests and checks run:
Results:
CI result:
Accessibility result:
Performance result:
Documentation updated:
Risks or blockers:
Exact next action:
```