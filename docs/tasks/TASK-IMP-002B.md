# TASK-IMP-002B — Implement shared design system, mobile shell, Home and rank hero

Status: `APPROVED — NOT EXECUTED`
Target phase: `Phase 2 — Identity, sessions and authenticated UI foundation`

Depends on:

1. `TASK-IMP-001` complete and merged;
2. `TASK-IMP-002A` complete and merged;
3. `stone-set-ranks-v1` present and verified;
4. `TECHNOLOGY_BASELINE.md`, `COMPLETE_UI_UX_SYSTEM.md` and `MOBILE_HOME_AND_RANK_PROGRESS_UI.md` still accepted;
5. task-start dependency/tool compatibility verification.

## Verified starting state

Verified on 2026-08-06 before approval:

```text
TASK-IMP-001             COMPLETE AND MERGED
TASK-IMP-002A            COMPLETE AND MERGED
Identity pull request    #7 — MERGED
Identity merge commit    2281be745b75116e70d2fed9ccf85c60e79bc4aa
Identity final CI        31093560109 — PASS
Flutter                  3.44.7
Dart                     3.12.2
Node.js                  24.11.1
Supabase CLI             2.111.0
Workspace lockfile       one root pubspec.lock; no nested lockfile or overrides
Client foundations       Android-only mobile and Web-only dashboard identity shells
Supabase foundation      local-only identity/Auth/RLS/RPC implementation
Rank assets              stone-set-ranks-v1; 20 verified 256x256 RGBA PNGs
Later product runtime    NOT IMPLEMENTED
Remote infrastructure    NONE
```

The working application/build graph is:

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

`analysis_options.yaml` separately selects the current analysis-server plugin
`riverpod_lint 3.1.8`. This is not a root application-lockfile dependency. Exact restore, two-pass
generation and strict analysis passed in final identity CI. The implementation agent must recheck
current official package evidence and the real solver at task start, preserve this proven baseline
unless a bounded correction is required, and must not add overrides, nested lockfiles or obsolete
`custom_lint` configuration. New state, routing, animation, icon or golden-test dependencies are not
currently justified.

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
- merged foundation and identity code/tests;
- pull request #7 metadata, diff and final CI run `31093560109`;
- Dart analyzer-plugin and Flutter asset-bundling guidance current at task start.

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
- reusable UI/rank presentation contracts stay in `packages/ui` while Home models, fixture
  repositories/services, controllers and composition stay in `apps/mobile`;
- no competing state/routing framework.

The existing `MobileSessionController`, foreground revalidation, `IdentityRouteGuard`, mandatory
password-change flow, active-profile/compatibility checks, quarantine contract and logout decision
flow remain the identity boundary. Do not replace or bypass them.

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

One stable mapping from a closed presentation-only rank ID to committed asset path.

The presentation IDs are exactly:

```text
bronze_i, bronze_ii, bronze_iii
silver_i, silver_ii, silver_iii
gold_i, gold_ii, gold_iii
platinum_i, platinum_ii, platinum_iii
diamond_i, diamond_ii, diamond_iii
elite, champion, apex, prodigy, adonis
```

These IDs are a UI asset contract only. They must not be represented as the future authoritative
database `current_rank_id` contract. Map each ID explicitly to one manifest entry; do not infer an
asset path from display or localized text.

Requirements:

- all 20 ranks;
- no filename construction from localized/display text;
- local assets only;
- aspect ratio preserved;
- consistent visible bounds/padding;
- clear unknown-rank failure;
- mapping and manifest tests;
- automated manifest schema, count, order, filename uniqueness, RR threshold, dimensions and SHA-256
  checks;
- `assets/ranks/` remains the single canonical source; do not copy or regenerate a competing asset
  tree;
- the lead owns the required `apps/mobile/pubspec.yaml` registration of the root assets and must
  document/test the exact runtime asset keys accepted by Flutter 3.44.7;
- Android release output must prove every asset is bundled exactly once.

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
- shell branch, selection, scroll and provider state preserved only within the same authenticated
  user, and destroyed on logout or authenticated user-ID change;
- predictable Android back behavior;
- protected by `TASK-IMP-002A` auth/first-password-change/compatibility guards;
- identity routes remain outside and above the protected shell; every shell/context route remains
  classified as protected, and intended-route recovery resolves to canonical Home when necessary;
- accessible labels and touch targets;
- Week, Progress and Profile may use state-complete accessible placeholders in this task;
- contextual routes prepared for rank detail and fixture workout/result placeholders;
- Profile retains the working `TASK-IMP-002A` logout-resolution flow.

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
Fixture pending-workout state must not implement `UnsynchronizedPrivateWork`, trigger real
quarantine, call Supabase or imply persisted drafts.

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

## 9. Deterministic golden policy

- checked-in baselines live under `apps/mobile/test/goldens/`;
- use Flutter test's deterministic font environment and a device-pixel ratio of 1.0;
- cover canonical 360x800 and 412x915 surfaces, light and dark themes, 100 and 200 percent text,
  reduced-motion final frames, Bronze I at 0 percent, representative 1/50/99/100 percent states,
  threshold, provisional, pending, Adonis and the all-20 gallery;
- exact 100 percent has a painter-level geometry test and a golden that catches a seam, doubled cap
  or top gap;
- default comparison is pixel exact; any bounded tolerance requires a documented reason and focused
  comparator, never a repository-wide threshold;
- update only with `flutter test --update-goldens` in the documented Linux CI-equivalent
  environment, inspect every image diff, and commit reviewed baselines;
- CI runs goldens and uploads focused actual/expected/diff artifacts on failure using only a
  commit-pinned action with read-only repository permissions.

## 10. Accessibility and responsiveness

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
- no essential clipping;
- hero is one coherent action/announcement; decorative layers are excluded;
- test traversal, target geometry, state-dependent action labels and narrow/landscape layouts at
  100, 150 and 200 percent text scale.

## 11. Lifecycle and performance

- no ticker/frame scheduling at idle;
- rank assets cached locally;
- bounded rebuilds;
- route/tab state retained;
- no duplicate network/data calls from rebuilds;
- an `integration_test` API 24 profile scenario that warms the app, switches all four branches,
  opens/closes rank detail, scrolls Home and repeats the transition sequence;
- record emulator/device model, Android API, profile command and timeline summary in the PR;
- after warm-up, require at least 95 percent of measured build and raster frames below 32 ms and no
  frame above 100 ms; a noisy-host rerun must be reported, never silently discarded;
- memory/lifecycle tests for repeated tab/route transitions.

Deterministic widget tests must also prove zero idle scheduled frames, no ticker after disposal,
exact final animation values, bounded hero rebuilds and `RepaintBoundary` isolation. If an API 24
profile environment is unavailable, the task verdict is `PARTIAL`; an Android release build alone
does not satisfy this gate.

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
- public signup, password-proof, RLS/grants, live-session and JWT-expiry boundaries remain unchanged;
- no secrets/private data in fixtures;
- no claims that real workouts or rewards work.

## Acceptance criteria

1. Authenticated Android user reaches a stateful Home/Week/Progress/Profile shell.
2. Each branch preserves route/scroll state.
   Logout and user changes reset all prior-user shell/navigation/provider state.
3. Home follows accepted hierarchy.
4. Rank track is complete at 0 percent and active ring is seamless at 100 percent.
5. Intermediate/threshold/max/provisional/pending states are accurate and understandable without color.
6. All rank assets map exactly once.
7. Today's card maps every accepted state/action correctly.
8. Themes, narrow layouts, 200-percent text and reduced motion work.
9. No continuous idle animation/ticker leak.
10. Fixture, unit, widget, semantics, golden and focused performance checks pass.
11. No authoritative product behavior or infrastructure is introduced.
12. Existing mobile/dashboard authentication, password, logout, maintenance and incompatibility
    regressions pass.
13. API 24 profile evidence meets the defined thresholds.

## Required verification

- show exact Flutter/Dart/Node/Supabase versions;
- `dart pub get --enforce-lockfile` and `npm ci`, followed by a zero tracked-file diff;
- verify one root Dart lockfile, no nested lockfiles and no dependency overrides;
- run code generation twice; the second pass writes zero outputs;
- formatting and strict fatal-info analysis;
- all root/member unit and widget tests, mobile integration tests and dashboard Chrome tests;
- provider/controller unit tests;
- router state/guard/branch tests;
- logout/user-change shell reset and all existing identity regression tests;
- rank math display/clamping/full-circle state tests;
- asset resolver, manifest metadata/hash and release-bundle tests;
- today action mapping tests;
- widget/semantics/target/traversal/200-percent-text tests;
- deterministic golden set and reviewed image diffs;
- animation final-frame/lifecycle tests;
- required API 24 profile check and evidence;
- Android release APK and dashboard release Web build;
- local Supabase clean reset, Auth/signup/operator tests, pgTAP and database lint when supported;
- client-bundle and complete repository scan for privileged credentials, secrets and personal data;
- no remote Supabase/Vercel change, production signing or product persistence;
- complete `main...HEAD` diff, `git diff --check`, clean-tree and generated-file review;
- all required GitHub Actions checks passing on the final head.

## Required documentation updates

Update only implemented facts in:

- `README.md`;
- `docs/context/ARCHITECTURE.md`;
- `docs/context/CODEBASE_MAP.md`;
- `docs/context/ROADMAP.md`;
- `docs/context/IMPLEMENTATION_PLAN.md`;
- `docs/context/UI_IMPLEMENTATION_PLAN.md`;
- `docs/context/ACTIVE_CONTEXT.md`;
- `docs/context/HANDOFF.md`;
- active append-only audit volume `docs/context/AUDIT_LOG_CONTINUED_3.md`;
- this packet's implementation-result section/status.

Do not approve `TASK-IMP-002C`.

## Git requirements

```text
branch: codex/task-imp-002b-mobile-shell-home
no work directly on main
no history rewriting
all implementation commits contain TASK-IMP-002B
push the branch
open a draft pull request
inspect the complete diff
report branch, commit and pull request
```

## Completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-IMP-002B
Branch:
Commit:
Pull request:
Design system:
Routing/shell:
Home/rank hero:
Today/week fixtures:
Accessibility/themes:
Tests/builds/CI:
Performance/lifecycle:
Explicitly not implemented:
Documentation:
Runtime files changed:
Dependency/lockfile result:
Remote infrastructure changed:
Secrets review:
Diff/clean-tree review:
Risks/blockers:
Exact next action:
```
