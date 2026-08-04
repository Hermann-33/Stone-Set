# TASK-IMP-002B — Implement mobile design system, authenticated shell, and rank hero

Status: `PLANNED — NOT YET AUTHORIZED`
Depends on:

1. `TASK-IMP-001 — Create Flutter and Supabase project foundation` complete and merged;
2. `TASK-IMP-002A — Identity, login, sessions, profiles, and ownership` complete and merged;
3. `stone-set-ranks-v1` assets present on the execution branch;
4. `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md` still accepted and conflict-free.

## Objective

Implement the first coherent Stone Set Android UI baseline: semantic design tokens, authenticated four-destination navigation shell, fixture-driven Home screen, centered animated rank-progress hero, rank-asset mapping, loading and synchronization states, accessibility behavior, and automated visual/widget verification.

The packet builds presentation infrastructure only. It does not implement authoritative weekly-plan, workout, RR, XP, rank-finalization, wallet, or history persistence.

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

Implement one tested mapping from stable rank identity to the committed asset path.

Requirements:

- cover all 20 assets;
- fail clearly for an unknown rank identity;
- avoid filename construction from user-visible rank text;
- keep the manifest as the source evidence;
- load assets locally with no network dependency;
- preserve aspect ratio and prevent clipping.

### 3. Presentation model

Define an immutable UI-facing rank-progress model containing the data required by the accepted specification.

The presentation model must not:

- write RR or XP;
- determine authoritative rewards;
- call Supabase directly;
- finalize rank transitions;
- contain service credentials;
- infer product authority from animation state.

Provide deterministic fixture factories for representative rank, progress, loading, stale, provisional, pending, offline, error, rank-up, rank-down, and max-rank states.

### 4. Rank-progress hero

Implement the accepted hero using first-party Flutter primitives unless a later approved decision authorizes another dependency.

Required behavior:

- centered rank emblem;
- near-complete circular ring with top gap;
- inactive track and active authoritative progress arc;
- rounded active cap;
- rank-family palette;
- textual rank, RR, percentage, and next-rank summary;
- Adonis max-rank presentation;
- provisional secondary treatment;
- pending-sync indication outside the authoritative ring;
- complete semantics;
- optional tap callback for the future progression route.

The ring renderer must clamp invalid fractions and must not visually exceed its accepted sweep.

### 5. Motion controller

Implement event-driven animation for:

- first stable render;
- same-rank RR increase;
- same-rank RR decrease;
- authoritative rank up;
- authoritative rank down;
- palette transition;
- reduced-motion substitution;
- return-to-Home without unchanged replay.

No continuous idle animation is allowed.

Animation code must:

- dispose all controllers/tickers;
- stop when offstage where applicable;
- avoid rebuilding the entire Home screen per frame;
- isolate the animated region with a repaint boundary;
- finish at exact authoritative display values.

### 6. Authenticated mobile shell

Implement the initial four destinations:

1. Home;
2. Week;
3. History;
4. Profile.

Only Home requires substantive UI in this packet. The other destinations may use tested, accessible, clearly labelled placeholders that preserve navigation and state.

Requirements:

- route state survives tab changes;
- back behavior is predictable;
- protected shell is inaccessible without the accepted authenticated state;
- logout and session-loss behavior remain owned by `TASK-IMP-002A`;
- no dashboard changes unless required for a shared token compilation fix.

### 7. Fixture-driven Home screen

Implement the accepted content order:

1. header;
2. rank hero;
3. conditional pending/provisional banner;
4. today's item card;
5. week strip;
6. compact progression metrics.

The packet uses fixture-backed presentation data. It does not read real weekly plans or rank ledger state.

Today's card must support visual fixtures for:

- available workout;
- active workout;
- pending synchronization;
- completed workout;
- rest day;
- locked state;
- unavailable/error state.

The week strip must support seven fixture items and selected/locked/completed/rest visual states.

### 8. Responsive and accessibility behavior

Implement and verify:

- narrow Android phone layout;
- normal phone layout;
- larger width behavior;
- portrait baseline;
- text scaling through 200%;
- 48 dp minimum interaction targets;
- semantic rank announcement;
- meaningful focus/traversal order;
- non-color status communication;
- reduced motion;
- no decorative semantics.

Landscape may use a safe fallback layout but is not a polished MVP target unless the accepted mobile policy changes.

### 9. Preview and test fixtures

Provide deterministic development previews or fixture routes for:

- Bronze I 0%;
- one middle rank at 1%, 50%, and 99%;
- exact rank-up boundary;
- representative rank-down;
- Diamond III with provisional delta;
- pending synchronization;
- stale/offline snapshot;
- error fallback;
- Adonis max rank;
- reduced motion;
- 200% text scale.

No production user data is permitted in fixtures.

## Non-goals

This packet must not implement:

- Supabase rank tables, transactions, functions, or RLS;
- rank/RR/XP calculation;
- real materialized weekly plans;
- routine, exercise, or guidance management;
- workout start, set entry, timers, SQLite drafts, or outbox;
- authoritative pending submission;
- swaps or wallet behavior;
- rank history persistence;
- progression detail business data;
- web dashboard Home redesign;
- sound effects;
- copied Fortnite assets, geometry, typography, particles, or sound;
- a third-party animation runtime without a separate accepted decision;
- remote infrastructure or deployment.

## Protected boundaries

- The server remains authoritative for identity, RR, XP, rank, weekly state, and finalization.
- Solid ring progress represents authoritative finalized RR only.
- Provisional state never changes the authoritative rank emblem.
- Local pending data never changes the authoritative ring.
- `rank-v6` thresholds and names remain unchanged.
- `stone-set-ranks-v1` files are not renamed or silently replaced.
- Login/session behavior remains compatible with `TASK-IMP-002A`.
- The visual result must be recognizably Stone Set, not a Fortnite reproduction.
- No secrets, credentials, private media, or personal data enter the repository.

## Acceptance criteria

1. Android authenticated users land in a four-destination shell.
2. The Home destination renders the accepted information hierarchy.
3. The rank emblem is centered and surrounded by an accurate radial progress ring.
4. Progress is accurate for 0, intermediate, threshold, and max-rank fixtures.
5. All 20 rank identities resolve to exactly one local asset.
6. Rank, RR, percentage, next-rank, provisional, and pending states are readable without color.
7. First render, increase, decrease, rank-up, and rank-down motion end at exact final values.
8. Reduced-motion mode avoids sweep, scale, and spatial transitions.
9. Reopening an unchanged Home tab does not replay the entrance animation.
10. Today's card and week strip are reusable, state-complete fixture widgets.
11. Narrow layouts and 200% text scaling do not clip essential content.
12. Semantics expose one coherent rank-progress action and correct status text.
13. The UI has no continuous idle animation or active ticker after disposal.
14. Widget, golden, semantics, and focused performance checks pass.
15. No authoritative product behavior or external infrastructure is introduced.

## Required tests and checks

### Formatting and analysis

- repository formatting command;
- Dart/Flutter static analysis;
- dependency-boundary checks introduced by foundation.

### Unit tests

- progress clamping and display rounding;
- max-rank model;
- asset mapping for all 20 ranks;
- animation-state transition reducer/controller;
- provisional versus authoritative presentation;
- stale and pending state mapping.

### Widget tests

- shell navigation and route preservation;
- hero at required percentages;
- rank-up and rank-down final frames;
- pending and provisional banners;
- today-card states;
- week-strip states;
- reduced motion;
- text scaling and narrow width;
- semantic labels and traversal.

### Golden tests

Use stable deterministic fonts and fixtures for:

- Bronze I 0%;
- representative middle rank 50%;
- Diamond III provisional state;
- Adonis max-rank state;
- narrow width;
- 200% text scale;
- reduced-motion static frame.

Golden coverage need not snapshot every animation frame.

### Performance and lifecycle checks

- profile the ring animation on the accepted Android baseline;
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
- append-only `docs/context/AUDIT_LOG_CONTINUED.md` or its successor;
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
