# Stone Set Mobile Home and Rank Progress UI

Updated: 2026-08-05
Status: `ACCEPTED PRODUCT UI BASELINE`
Task: `TASK-PD-011`

## 1. Purpose

The Android home screen is the user's daily command surface. It must answer, in order:

1. What is my current rank and how close am I to the next rank?
2. What do I need to do today?
3. What is the state of this week?
4. Is anything pending, provisional, locked, or unsynchronized?

The user's current rank is the primary identity element. It appears in the center of the first viewport, surrounded by a radial progress ring that communicates completion toward the next rank.

## 2. Visual inspiration boundary

The supplied Fortnite screenshot is inspiration only for the general interaction pattern:

- a central rank emblem;
- a circular progress treatment around the emblem;
- a short polished progress or rank-transition animation;
- clear visual emphasis on the user's current competitive standing.

Stone Set must not copy Fortnite's proprietary emblem, typography, exact ring geometry, colors, background treatment, sound, particles, layout, or animation timing. The reference screenshot is not committed to the repository.

Stone Set uses its own:

- `stone-set-ranks-v1` emblems;
- dark stone-and-metal design language;
- rank-family palettes;
- spacing and typography system;
- motion and accessibility behavior;
- product data and labels.

## 3. Mobile application shell

The authenticated Android shell contains:

- a safe-area-aware top header;
- one vertically scrollable home body;
- a persistent four-destination bottom navigation bar;
- route-preserving navigation state;
- global surfaces for synchronization, provisional state, and errors.

### Bottom navigation

The initial destinations are:

1. **Home** — rank hero, today's item, weekly summary, and next action;
2. **Week** — complete seven-day plan and swap entry points;
3. **History** — completed workouts, RR/XP transactions, and corrections;
4. **Profile** — account, units, session, cache, and logout controls.

A separate permanent Rank tab is unnecessary because rank is already the dominant home element. Tapping the rank hero opens the detailed progression surface when that route is implemented.

## 4. Home-screen hierarchy

The home body is ordered as follows:

1. compact header;
2. rank-progress hero;
3. pending or provisional status banner, only when applicable;
4. today's workout or rest card;
5. seven-day week strip;
6. compact progression statistics;
7. secondary actions and history entry points.

The rank hero is visually dominant, but the primary workout action must remain reachable without excessive scrolling on a normal phone.

## 5. Header

The header contains:

- contextual greeting or user display name;
- a compact synchronization-state indicator;
- profile/avatar action.

The header must not duplicate rank information. It remains visually quiet so the rank hero retains focus.

## 6. Rank-progress hero

### 6.1 Composition

The hero consists of five layers:

1. optional restrained rank-colored ambient halo;
2. inactive circular track;
3. active progress arc;
4. centered rank emblem;
5. textual progress summary.

The emblem uses the exact asset mapped by `assets/ranks/manifest.json`.

### 6.2 Ring geometry

- The progress treatment is a near-complete circle with a small gap centered at 12 o'clock.
- Recommended drawable sweep: `344 degrees`.
- Recommended top gap: `16 degrees`.
- Progress starts immediately clockwise after the top gap.
- Progress advances clockwise.
- The active sweep equals `344 degrees × progressFraction`.
- Rounded line caps are used for the active arc.
- The active arc must never obscure the emblem.

The gap gives the ring a visible start and finish while preserving the circular appearance shown in the reference pattern.

### 6.3 Relative sizing

For the normal phone layout:

- hero ring diameter: clamp between `224 dp` and `296 dp`;
- preferred diameter: approximately `72%` of the available content width;
- rank emblem visible bounds: approximately `54–60%` of ring diameter;
- progress track thickness: `8–12 dp`, responsive to ring size;
- minimum free space between emblem and ring: `18 dp`;
- hero section target height: no more than `360 dp` on standard phones.

The complete emblem must remain visible. Transparent padding in the source PNG must be handled through a consistent fitted-box contract rather than per-rank arbitrary scaling.

### 6.4 Color behavior

Each rank family supplies a semantic palette:

- track: low-contrast neutral charcoal;
- active arc start: rank mid-tone;
- active arc end and leading cap: rank highlight;
- ambient halo: rank highlight at low opacity;
- labels: neutral high-contrast foreground;
- provisional overlay: translucent rank highlight with a distinct dashed or separated treatment.

Progress cannot be communicated by color alone. The percentage and RR values remain visible in text.

### 6.5 Labels

The hero shows:

- current rank name;
- current authoritative RR;
- next-rank threshold, when one exists;
- integer completion percentage;
- next rank name, when one exists.

Recommended text pattern:

```text
PLATINUM II
1,910 / 2,075 RR
45% to Platinum III
```

For Adonis:

```text
ADONIS
5,500+ RR
MAX RANK
```

The user-visible percentage is rounded to the nearest whole number after clamping.

## 7. Progress calculation and authority

The authoritative rank snapshot comes from the server-controlled rank system. The client does not award RR, select rank, or finalize rank transitions.

For a non-final rank:

```text
progressFraction = clamp(
  (rankRR - currentRankMinimumRR)
  / (nextRankMinimumRR - currentRankMinimumRR),
  0,
  1
)
```

For Adonis:

```text
progressFraction = 1
nextRank = none
state = maxRank
```

The UI may recompute the fraction from a trusted snapshot for rendering and consistency checks, but the server-provided rank identity and RR remain authoritative.

## 8. Authoritative, provisional, and pending values

Stone Set distinguishes three display classes:

### Authoritative

- The solid active ring represents finalized `rankRR` only.
- The central rank emblem always represents the authoritative current rank.

### Provisional

- A known provisional positive RR delta may appear as a secondary translucent arc extending beyond the solid authoritative arc.
- Provisional RR never changes the central emblem or rank name.
- The text explicitly labels the value as provisional.
- A provisional negative delta uses a warning treatment and must not imply a finalized rank loss.

### Pending synchronization

- Unsynchronized local workout state does not move the rank ring.
- A compact pending-sync banner appears below the hero.
- The banner explains that RR and rank will update only after server validation.

This prevents optimistic client visuals from misrepresenting authoritative progression.

## 9. Hero interaction

The entire hero may be one semantic button when the detailed rank route exists.

Tap behavior:

- open the progression detail screen;
- preserve the current home scroll position;
- use a restrained shared-element transition for the emblem when supported;
- never trigger a reward or mutation.

Long press has no special behavior in MVP.

## 10. Motion specification

Motion is event-driven. There is no continuous idle animation.

### 10.1 First stable render

When no previous display snapshot exists:

- track fades in over approximately `180 ms`;
- emblem fades and scales from `0.94` to `1.0` over approximately `360 ms`;
- active arc sweeps to the authoritative fraction over approximately `760 ms` using a decelerating curve;
- labels fade in during the latter half of the arc animation.

This entrance runs at most once per authenticated application session, not every time the user returns to the Home tab.

### 10.2 Normal RR increase

When the same rank receives finalized positive RR:

- animate from the previously displayed fraction to the new fraction;
- duration scales with the angular delta, constrained to approximately `320–800 ms`;
- RR text counts from the old value to the new value;
- the arc leading cap receives one restrained glow pulse;
- optional light haptic feedback occurs only after an authoritative successful update.

### 10.3 RR decrease

When finalized RR decreases without changing rank:

- animate the arc backward smoothly;
- count the RR value downward;
- use no celebratory glow, burst, or particle effect;
- show the associated transaction or reason through the detail/history surface.

### 10.4 Rank-up transition

The rank-up sequence is:

1. complete the old rank ring to 100%;
2. hold for approximately `100 ms`;
3. fade and scale the old emblem down slightly;
4. morph the ring palette to the new rank palette;
5. cross-fade and scale the new emblem from `0.86` to `1.0`;
6. reset the ring to the new rank's carried progress fraction;
7. show a short `Rank Up` label and optional medium haptic feedback.

Total target duration: approximately `1,100–1,450 ms`.

Effects must remain restrained: no copied Fortnite particles, sound, flare pattern, or animation choreography.

### 10.5 Rank-down transition

- fade the previous emblem;
- cross-fade to the lower rank emblem;
- animate the ring to the new authoritative fraction;
- use a neutral `Rank adjusted` message;
- do not use celebratory effects.

### 10.6 Returning from background

- do not replay entrance animation when nothing changed;
- animate only the delta between the cached displayed snapshot and the newly authoritative snapshot;
- if the delta is too old or ambiguous, use a direct cross-fade rather than replaying every intermediate transaction.

## 11. Reduced-motion behavior

When the platform requests reduced motion:

- no ring sweep from zero;
- no emblem scale animation;
- no palette morph or shared-element travel;
- values update through a short cross-fade of at most `150 ms`, or immediately;
- haptic feedback remains separately controllable;
- no flashing or rapid repeated pulses.

The product remains fully understandable with all animation disabled.

## 12. Home content below the hero

### 12.1 Pending/provisional banner

Shown only when required. States include:

- workout pending synchronization;
- server validation in progress;
- provisional transaction available;
- retry required;
- stale cached rank snapshot.

### 12.2 Today's card

The card displays:

- workout or rest status;
- title and brief purpose;
- estimated duration for workouts;
- locked, available, active, pending, completed, or rest state;
- one clear primary action.

Primary labels include:

- `Start workout`;
- `Continue workout`;
- `Sync workout`;
- `View result`;
- `Rest day`.

### 12.3 Week strip

A compact seven-day strip shows:

- weekday and date;
- workout/rest identity;
- current status;
- lock state;
- selected date.

The strip opens the Week destination or the selected item.

### 12.4 Compact progression statistics

The initial statistics are:

- active consistency multiplier;
- lifetime XP;
- free-swap balance.

They are secondary to rank and today's action.

## 13. Visual design system

### 13.1 Base theme

Stone Set uses a dark-first interface:

- charcoal and near-black surfaces;
- stone-textured appearance created through subtle tonal layering, not image-heavy backgrounds;
- restrained elevation and border contrast;
- rank colors reserved for progression, selection, and meaningful emphasis;
- no uncontrolled neon or permanent glow.

### 13.2 Typography

The base UI requires semantic text roles rather than hardcoded per-screen styles:

- display rank;
- section title;
- body;
- compact metric;
- label;
- caption;
- button.

Rank names may use increased weight and letter spacing but must remain legible and localizable.

### 13.3 Shape language

- rounded cards with controlled radii;
- circular rank-progress hero;
- compact pill-shaped state chips;
- consistent border thickness;
- no direct reproduction of Fortnite panel shapes or decorative geometry.

## 14. Responsive behavior

### Narrow phones

- ring diameter reduces to the lower clamp;
- labels remain below rather than overlaying the emblem;
- statistics may wrap to two rows;
- today's primary action remains visible without horizontal scrolling.

### Normal phones

- full centered hero;
- today's card begins within or immediately below the first viewport;
- three statistics fit in one row when text scaling permits.

### Large phones and tablets

- ring grows only to the defined maximum;
- extra width is used for content spacing, not an excessively large emblem;
- home may place today's card beside the hero only when the resulting reading order and touch targets remain clear.

The Flutter Web management dashboard does not reuse the full mobile home layout. It may later reuse a compact non-dominant rank summary component.

## 15. Accessibility

The rank hero semantic label must communicate:

```text
Current rank Platinum II. 1,910 rank rating. 45 percent toward Platinum III at 2,075 rank rating. Button, view progression.
```

Requirements:

- support platform text scaling up to at least 200%;
- preserve a logical screen-reader order;
- use minimum 48 dp interactive targets;
- provide high-contrast text and track separation;
- do not rely on hue alone;
- expose authoritative, provisional, and pending states explicitly;
- keep decorative halo and glow out of the semantic tree;
- provide reduced-motion behavior;
- avoid flashing and rapid repeated effects.

## 16. Component and data boundaries

The planned implementation uses a presentation-first contract.

### Shared UI package

Planned reusable components:

- `StoneSetTheme` and semantic tokens;
- `RankProgressHero`;
- `RankProgressRingPainter`;
- `RankEmblem`;
- `MetricTile`;
- shared cards, chips, skeletons, and navigation primitives.

### Mobile application

Planned mobile-owned components:

- authenticated app shell;
- Home destination;
- today's card;
- week strip;
- home-state composition and routing;
- state-change animation coordination.

### View data

The rank hero consumes immutable view data equivalent to:

```text
rankId
rankName
emblemAssetPath
rankRR
currentRankMinimumRR
nextRankId?
nextRankName?
nextRankMinimumRR?
progressFraction
lifetimeXP
consistencyMultiplier
provisionalRRDelta?
synchronizationState
snapshotVersion
updatedAt
```

The widget does not call Supabase, calculate rewards, mutate RR, or select an authoritative rank.

## 17. Implementation sequence

### `TASK-IMP-001` — Foundation

Unchanged. Creates application and package shells only. It does not implement this UI.

### `TASK-IMP-002A` — Identity, login, sessions, profiles, and ownership

Implements authentication and establishes the protected mobile route boundary.

### `TASK-IMP-002B` — Mobile design system, authenticated shell, and rank hero

Implements:

- Stone Set design tokens and dark theme;
- four-destination mobile navigation shell;
- fixture-driven Home screen;
- central rank-progress hero;
- rank asset resolution;
- animation and reduced-motion behavior;
- loading, stale, offline, provisional, and error states;
- widget, golden, semantics, and performance tests.

It does not implement authoritative RR, reward calculation, weekly plan persistence, workout execution, or rank finalization.

### `TASK-IMP-004` — Weekly plans

Wires today's card and week strip to server-authoritative materialized schedule data.

### `TASK-IMP-005A` — Workout execution

Wires today's primary action, active workout, local draft, and synchronization state into the existing Home shell.

### `TASK-IMP-006` — Rank and finalization

Wires the hero to authoritative rank snapshots, provisional transactions, RR changes, and rank-up/rank-down events.

## 18. Testing requirements

### Visual and widget tests

- Bronze I at 0%;
- representative middle rank at 1%, 50%, and 99%;
- exact threshold transition;
- Adonis max-rank state;
- all 20 emblem mappings;
- narrow phone, normal phone, and large-width layout;
- 100%, 150%, and 200% text scaling;
- dark-theme contrast and clipping;
- loading, stale, offline, provisional, pending-sync, and error states.

### Motion tests

- first render ends at the correct fraction;
- normal RR increase and decrease end at authoritative values;
- rank-up sequence ends with the correct new emblem, palette, and fraction;
- rank-down has no celebratory state;
- reduced motion skips spatial and sweep animation;
- returning to Home does not replay entrance animation without changed data;
- no animation controller or ticker remains active while idle or disposed.

### Semantic tests

- complete rank, RR, percentage, next rank, and state announcement;
- one logical hero action;
- non-semantic decorative layers;
- correct traversal order;
- button labels and state chips remain understandable without color.

### Performance checks

- smooth rendering on the Android API 24 baseline device profile;
- no continuous animation when idle;
- isolated repaint boundary around the animated hero;
- no unnecessary full-page rebuild during ring animation;
- cached rank assets and no network dependency for emblem display.

## 19. Acceptance criteria

The UI baseline is accepted when:

1. the rank emblem is the centered focal point of the mobile Home screen;
2. a near-complete circular ring visibly represents authoritative progress to the next rank;
3. the exact percentage and RR values are available in text and semantics;
4. all 20 committed rank assets can be resolved through one stable mapping;
5. rank-up, rank-down, increase, decrease, loading, max-rank, provisional, pending, stale, and reduced-motion states are defined;
6. the design is recognizably Stone Set and does not copy Fortnite artwork or exact styling;
7. today's action remains easy to reach;
8. the UI can be implemented before the rank backend using immutable fixture-backed view data;
9. later schedule, workout, and rank phases can bind real data without redesigning the component contract;
10. accessibility and performance requirements are testable.

## 20. Non-goals

This baseline does not authorize:

- Flutter implementation before its approved packet and prerequisites;
- server rank calculation or reward mutation;
- weekly-plan persistence;
- workout execution;
- finalization;
- sound design;
- a public social profile;
- a copied Fortnite interface;
- committing the supplied Fortnite screenshot;
- continuous decorative animation;
- a web-dashboard recreation of the mobile home.

## 21. Decision status

No ADR is required. This is an accepted, reversible product-interface specification within the existing Flutter and rank architecture.
