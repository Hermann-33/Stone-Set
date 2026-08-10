# TASK-IMP-009 — Android visual system and motion modernization

Updated: 2026-08-11
Status: `COMPLETE AND MERGED`
Branch: `codex/task-imp-009-mobile-ui-polish`

## Objective

Deliver a coherent Stone Set 2.0 presentation pass for the existing Flutter Android application so
it feels premium, disciplined, tactile and intentionally designed while behaving as the same
Stone Set product.

This is a presentation, accessibility and event-driven motion task. It is not permission to add
product functionality, change workflows, move authority into clients or reinterpret accepted
business rules.

## Authorization

The product owner explicitly approved this exact bounded packet on 2026-08-11. Repository authority
records it as the next executable post-release task. Implementation must begin from accepted `main`
on `codex/task-imp-009-mobile-ui-polish` after rechecking the verified starting state.

Approval does not authorize external infrastructure, backend or product-logic changes and does not
weaken any scope, non-goal, accessibility, motion, performance or verification requirement below.

## Mandatory repository reads

Before implementation, read completely and in repository order:

1. `AGENTS.md`;
2. `docs/context/ACTIVE_CONTEXT.md`;
3. `docs/context/PROJECT_BRIEF.md`;
4. `docs/context/ARCHITECTURE.md`;
5. `docs/context/CODEBASE_MAP.md`;
6. `docs/context/ROADMAP.md`;
7. `docs/context/WORKFLOW.md`;
8. `docs/context/HANDOFF.md`;
9. `docs/product/COMPLETE_UI_UX_SYSTEM.md`;
10. `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md`;
11. `docs/product/APPLICATION_WORKFLOW.md`;
12. `docs/product/RANK_SYSTEM.md`;
13. `docs/product/WEEKLY_SCHEDULING.md`;
14. `docs/product/HYPERTROPHY_ROUTINE.md`;
15. `docs/decisions/README.md` and every accepted ADR;
16. this packet.

When lower documentation conflicts with current state, accepted authority order applies. In
particular, direct owner publication is current and independent routine review is retired.

## Verified planning-time starting state

```text
main                         6b6167c — Merge pull request #29 (TASK-PD-020)
implementation              complete through TASK-IMP-008
primary mobile destinations Home, Week, Progress, Profile
mobile architecture          Flutter + Riverpod + go_router
theme modes                  System, Dark, Light
rank assets                  exact repository mapping for all 20 ranks
Home goldens                 dark/light, 360x800 and 412x915, 100%/200%
rank goldens                 all 20 ranks and reduced-motion states
routine publication         direct owner validation and publication
Profile                      honest identity placeholder; settings not connected
workout route                implemented active logger; no separate overview workflow
```

These facts must be reverified against updated `main` before implementation.

## Completion evidence

```text
branch                    codex/task-imp-009-mobile-ui-polish
accepted starting main    6754d55bbb108e157b55f1d56f388811450a16f8
initial runtime commit    ab6680b7104b8e98c410f7c52ebcb0f4ed9350b4
final implementation head f3f41bd95294e73b00c10f42f24ea43c4571411c
pull request              #31 — MERGED
merge commit              e59303d5acd4dbfe6706822b100913c531dc9297
Linux golden workflow     31431636004 — PASS
final Foundation CI       31433590244 — PASS
private release workflow  31433590270 — PASS
```

The merged implementation preserves the four destinations and all product, repository, Supabase,
SQLite and authority contracts. Local shared-UI and complete non-golden mobile suites, generation
freshness, formatting, fatal-info analysis and repository checks pass. Reviewed Linux candidates
cover both themes, 360×800 and 412×915, 100%/200% text, all 20 ranks and reduced-motion states.
Final-head CI passed the release build, bundle review, mobile and dashboard golden comparisons and
unchanged API 24 performance thresholds. The private-release workflow produced the Android release
artifacts. The bounded local Android build remained unavailable because this host has no Android SDK.

## Applicable accepted decisions

- separate Flutter Android and dashboard applications with shared Dart packages;
- Riverpod for state coordination and go_router typed routing;
- Supabase/Postgres server authority and RLS boundaries;
- SQLite-backed local workout drafts with online server finalization;
- Android-first mobile delivery;
- accepted Stone Set UI, Home and rank presentation specifications;
- repository-owned rank assets and deterministic asset mapping;
- path-sensitive CI with the API 24 performance lane for mobile/UI runtime changes.

Do not create a new ADR unless implementation would change architecture, public contracts,
persistence ownership, authentication/authorization, material security/privacy, an external
service, deployment or repository governance.

## Scope

### Primary production files

- `packages/ui/lib/src/theme/`;
- `packages/ui/lib/src/foundation/`;
- `packages/ui/lib/src/primitives/`;
- `packages/ui/lib/src/rank/`;
- `packages/ui/lib/src/auth/` where visual consistency requires it;
- `packages/ui/lib/stone_set_ui.dart` exports;
- `apps/mobile/lib/app/` for theme and presentation transition wiring only;
- `apps/mobile/lib/features/shell/`;
- `apps/mobile/lib/features/home/`;
- `apps/mobile/lib/features/week/`;
- `apps/mobile/lib/features/workout/`;
- `apps/mobile/lib/features/progress/`;
- existing Profile placeholder and identity/session presentation surfaces.

### Tests and visual evidence

- affected `packages/ui/test/` unit, widget, semantic and golden tests;
- affected `apps/mobile/test/` unit, widget, navigation, semantic and golden tests;
- affected mobile integration tests, including API 24 performance evidence;
- exact existing rank assets only; new decorative assets require explicit review and justification.

### Dependency boundary

No dependency or custom font is expected. Do not modify `pubspec.yaml`, `pubspec.lock`, npm files or
introduce a UI/state/animation framework. If a dependency becomes genuinely necessary, stop and
return the evidence, exact pin, compatibility proof and scope impact for separate approval.

## Design-system-first passes

### Pass 1 — measured visual audit

Capture and classify every implemented production mobile surface at narrow and normal phone widths,
dark/light modes, normal/200% text and reduced motion. Record only actionable gaps involving
hierarchy, stock Material appearance, spacing, typography, surface depth, state distinction,
interaction priority, motion, semantics, layout resilience or repaint risk.

Do not redesign a screen merely to imitate another product.

### Pass 2 — semantic design system

Centralize and test:

- canvas, base/raised/interactive surfaces and tonal layering;
- strong/muted/disabled foregrounds;
- outline, focus, success, warning, destructive and information roles;
- authoritative, provisional, pending and stale roles;
- restrained rank-family accents that never replace operational state colors;
- 4 dp grid spacing with primary increments 8, 12, 16, 20, 24, 32 and 48;
- structural, content, control, pill and circular shape roles;
- minimal elevation/border treatment without heavy shadows or pervasive blur;
- motion durations/easing for micro, standard, emphasized and rank choreography;
- semantic typography roles: rank display, page title, section title, card title, body, compact
  body, data value, tabular numeric/table value, label, caption, button and identifier/code.

Arbitrary feature-local colors, radii, shadows and font sizes must be removed where a semantic
token applies. Dark is the primary presentation; Light and System remain complete modes.

### Pass 3 — shared components and shell

Upgrade reusable cards, buttons, fields, chips, banners, metrics, loading/empty/error surfaces,
status messages and focus treatment before feature-specific styling. Upgrade the four-destination
bottom navigation selected state, touch feedback, safe-area treatment and destination transition
without changing destinations, routes, branch state or scroll preservation.

Every interactive mobile target remains at least 48 dp. Icon-only controls retain explicit labels.

### Pass 4 — Home and rank

Preserve this exact Home ordering:

```text
compact header
rank hero
conditional status banner
today card
seven-day strip
progression statistics
secondary actions
```

The rank hero must preserve the central repository emblem, complete 360-degree inactive track,
clockwise authoritative arc from 12 o'clock, correct 0% and seamless 100% frames, rank/RR/integer
percentage/next-rank labels and a non-authoritative provisional treatment. Pending local state must
never alter the authoritative ring.

Polish the ring with restrained tonal depth and rank-family accents. Do not replace it with another
progress metaphor. Keep today's primary action easy to reach.

### Pass 5 — Week

Polish the implemented seven-day schedule, today/workout/rest/lock/status distinctions, selection,
swap preview and explicit free-credit/RR payment presentation. Use coordinated selected-day and
preview transitions without changing swap eligibility, limits, costs, lock reasons or server
operations.

### Pass 6 — active workout and guidance

The logger is the priority usability surface. Polish the existing session header, sync state, rest
timer, exercise cards, prescriptions, notes, guidance entry, ordered load/reps/RIR fields,
completion controls, autosave and finish action without changing their data flow.

Set completion may use a short state-fill/border transition, check response and platform haptic only
where already supported. It must not delay rapid entry or require a long press. Rest-timer
appearance remains compact and non-blocking. Guidance transitions preserve the exact workout
position and never imply a reset.

Do not invent a separate workout-overview route or unimplemented timer controls. Missing product
behavior belongs to a separately approved product packet, not this visual task.

### Pass 7 — Progress, Profile and identity

Improve rank/ledger/workout-history/progression hierarchy and accurate state presentation without
changing values, ordering or server authority. Polish the existing Profile identity placeholder and
authentication/session-resolution states honestly. Do not invent a settings page, theme persistence,
offline controls or account operations that the current product does not implement.

### Pass 8 — accessibility, motion and performance

Audit all modified surfaces for semantics, contrast, target sizes, dynamic type, focus, announcements,
safe areas, gesture navigation, repaint scope and controller lifecycle. Resolve failures before final
golden acceptance.

## Motion contract

Motion is event-driven only:

```text
micro feedback              100–180 ms
standard transition         180–300 ms
emphasized state transition 300–500 ms
```

No idle pulse, shimmer after load, floating card, particle loop, breathing action, rotating
gradient, ambient parallax or permanent emblem animation is allowed.

The rank coordinator must preserve the accepted event semantics:

- first stable authenticated render: track fade about 180 ms, emblem 0.94→1 about 360 ms, arc
  sweep about 760 ms and delayed labels, at most once per authenticated application session;
- RR change: animate previous authoritative fraction to the new fraction in about 320–800 ms,
  interpolate the displayed RR, permit one restrained leading-cap response and animate decreases
  calmly;
- rank up: complete old ring, short hold, restrained old/new emblem and palette transition, show the
  new full inactive track, animate carried progress and a short Rank Up treatment in about
  1100–1450 ms total;
- rank down: neutral adjustment without failure or celebratory theatrics.

Haptics are optional, preference/platform-gated and must not imply server finalization before it is
authoritative.

## Reduced motion

Platform reduced-motion behavior is mandatory. Remove large translation, scale travel, ring sweeps,
palette morphing, shared-element travel, decorative pulses and rank choreography. Replace optional
motion with immediate changes or fades no longer than 150 ms. All hierarchy, authority and state
meaning must remain complete without animation.

## Product and security boundaries

The implementation must not change:

- Home, Week, Progress and Profile as the four permanent destinations;
- route meaning, typed-route ownership, contextual-route status or navigation state preservation;
- direct owner routine validation/publication;
- workout start, completion, autosave, offline, synchronization or finalization behavior;
- Supabase, Auth, RLS, Storage, RPC, Data API or SQLite contracts;
- rank, RR, XP, penalty, PR, wallet, schedule, swap, progression, protection or correction rules;
- prescriptions, routine behavior, data ownership or historical records;
- Riverpod, go_router, Flutter or the layered architecture.

Do not move product logic into widgets. Do not represent pending/provisional/local data as
authoritative. Do not add credentials, secrets, personal data or remote infrastructure.

## Visual constraints

Target dark stone, charcoal, near-black, metal-like tonal depth, high contrast, controlled geometry,
subtle layered surfaces and reserved rank-family accents. Avoid generic untouched Material,
childish/casino/cyberpunk styling, excessive neon/glass/gradients/shadows, permanent glow and visual
noise. Data-entry surfaces stay calmer than progression/achievement surfaces.

## Accessibility acceptance criteria

- 200% text has no clipped essential content, inaccessible actions or horizontal viewport overflow;
- layouts respond to available width through `LayoutBuilder`, flexible composition and bounded
  breakpoints rather than device-name assumptions;
- touch targets are at least 48×48 dp;
- semantic reading/focus order follows visible hierarchy;
- icon controls have labels and dynamic updates use live announcements only where useful;
- state is never color-only and all themes retain required contrast;
- reduced motion is deterministic and testable;
- no flashing or auto-looping decorative effect exists;
- fields preserve logical keyboard traversal and validation association.

## User-facing acceptance criteria

- all implemented production mobile surfaces use one coherent token/component language;
- dark, light and System modes render intentionally and consistently;
- Home still answers rank, next-rank progress, today's plan/action, week and authority-state questions
  in accepted order;
- 0%, partial and 100% rank-ring frames are correct and rank transitions do not alter authority;
- Week selection/swap presentation is clearer without behavior change;
- active workout entry remains fast, autosaving and non-blocking;
- guidance returns to the exact logger position;
- Progress remains numerically accurate and Profile remains honest about implemented capability;
- loading, empty, error, offline, stale, pending and synchronization states are visibly distinct and
  accessible;
- no permanent destination, workflow, calculation or persistence behavior changes.

## Required implementation tests

During development, run focused affected tests. Before the final candidate, run at minimum:

1. formatting and generated-code freshness;
2. fatal-info Dart/Flutter analysis for the workspace;
3. shared UI unit, widget and semantic tests;
4. complete mobile unit and widget tests;
5. authentication/session and four-branch navigation/state-preservation regressions;
6. Home hierarchy, today-state and week-strip tests;
7. rank painter/semantic tests for all 20 assets and 0%, partial and 100%;
8. deterministic initial, RR increase/decrease, rank-up/rank-down and reduced-motion coordinator
   tests using fake time rather than wall-clock delays;
9. Week selection, lock, swap preview/payment and failure-state regressions;
10. workout field/autosave/completion/sync/timer/guidance/finish regressions;
11. Progress authoritative/provisional/pending and ledger/history regressions;
12. Profile-placeholder and identity-state honesty tests;
13. semantics, focus, 48 dp target and non-color state tests;
14. dark/light/System, 100%/150%/200% text and reduced-motion coverage at representative 360×800
    and 412×915 viewports;
15. reviewed golden baselines for the shared system and visually significant production screens;
16. Android release build and bundle/static secret scan;
17. repository validation and complete diff/clean-tree checks;
18. path-sensitive final-head CI, including the unchanged Android API 24 performance thresholds.

System mode must be tested under both a light and dark platform brightness. Golden changes require
human-readable candidate inspection; tests must not update and accept baselines blindly.

## Performance gate

The final mobile/UI diff activates the API 24 performance lane. Preserve existing thresholds.
Profile Home rank animation, bottom-navigation transitions and the active logger where practical.
Use repaint boundaries selectively, localized animation rebuilds, bounded images and controller
lifecycle cleanup. Avoid pervasive blur, scrolling-list clipping layers, full-screen rebuilds for
microfeedback, per-frame allocation and long-lived tickers.

No performance threshold may be weakened to accept the redesign.

## Required documentation updates

Only after successful implementation and final-head evidence:

- mark this packet complete with exact branch/commit/PR evidence;
- update `ACTIVE_CONTEXT.md`, `CODEBASE_MAP.md`, `ROADMAP.md` and `HANDOFF.md` only for material
  current-state/file-ownership facts that changed;
- update UI implementation documentation only when it owns a changed implementation fact;
- append the material result to the active audit volume;
- do not rewrite accepted product requirements, ADRs or historical audit entries.

## Git requirements

```text
branch: codex/task-imp-009-mobile-ui-polish
no work directly on main
no history rewriting or force push
commits contain TASK-IMP-009
inspect the complete diff and generated changes
push the branch
open a draft pull request
run one final path-appropriate CI candidate
report branch, commit, pull request and final-head checks
```

Do not commit screenshot candidates, caches, SDK output or build artifacts unless they are reviewed
golden baselines required by the packet.

## Required completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-IMP-009
Branch:
Commit:
Pull request:
Files changed:
Visual system changes:
Animation changes:
Screens upgraded:
Behavior intentionally unchanged:
Tests/checks:
CI result:
Accessibility evidence:
Performance evidence and risks:
Secrets and personal-data review:
Remaining issues:
Exact next action:
```

`COMPLETE` requires every applicable presentation, behavior-preservation, accessibility, motion,
performance, test, documentation, Git, pull-request and final-head CI gate to pass.

## Non-goals

- new destinations, routes, settings, product workflows or business capabilities;
- routine review or any second-user publication dependency;
- dashboard redesign;
- backend, migration, Auth, RLS, Storage, RPC, SQLite or remote changes;
- dependency, custom-font or global framework changes;
- new rank, reward, schedule, swap, workout or progression semantics;
- iOS, Play Store, release signing or deployment work;
- imitation of another game's visuals, particles, sound or choreography.
