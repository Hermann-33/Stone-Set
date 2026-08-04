# Stone Set Latest Handoff

Updated: 2026-08-05

## Current task

`TASK-PD-011 — Define mobile home and radial rank-progress UI`

## Result

- Accepted the Android mobile Home screen as the user's daily command surface.
- Made the current rank emblem the centered first-viewport focal point.
- Defined a near-complete circular progress ring with a small top gap around the emblem.
- Defined authoritative RR, percentage, next-rank, and Adonis max-rank labels.
- Separated finalized, provisional, and pending-synchronization visuals.
- Defined first render, RR increase/decrease, rank-up, rank-down, return-from-background, and reduced-motion behavior.
- Defined Home, Week, History, and Profile as the authenticated mobile destinations.
- Defined today's item card, seven-day strip, and progression statistics below the rank hero.
- Established Stone Set's own dark stone-and-metal visual language.
- Preserved the supplied Fortnite screenshot as inspiration only; it is not copied or committed.
- Created a detailed future implementation packet for the base mobile UI.

## New canonical specification

```text
docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md
```

The specification owns:

- Home information hierarchy;
- rank-ring geometry and progress calculation;
- labels and max-rank behavior;
- authoritative/provisional/pending state separation;
- motion and reduced motion;
- responsive and accessibility requirements;
- component/data boundaries;
- staged fixture-to-real-data integration.

## Planned implementation packet

```text
TASK-IMP-002B — Mobile design system, authenticated shell, and rank hero
packet: docs/tasks/TASK-IMP-002B.md
status: PLANNED — NOT YET AUTHORIZED
```

Prerequisites:

1. `TASK-IMP-001` complete and merged;
2. `TASK-IMP-002A` complete and merged;
3. rank assets present and unchanged;
4. packet reverified and promoted to `APPROVED`.

## Implementation sequence impact

```text
TASK-IMP-001
  foundation only

TASK-IMP-002A
  identity, login, sessions, profiles, ownership

TASK-IMP-002B
  design system, mobile shell, fixture-driven Home and rank hero

TASK-IMP-004
  bind real today's item and weekly plan

TASK-IMP-005A
  bind real workout and synchronization state

TASK-IMP-006
  bind authoritative RR, provisional transactions, and rank transitions
```

## Protected behavior

- The client never awards RR or chooses authoritative rank.
- The solid ring represents finalized authoritative RR only.
- Provisional RR does not change the authoritative emblem.
- Pending local workout data does not move the ring.
- All 20 `stone-set-ranks-v1` assets use one stable mapping.
- No continuous idle animation is allowed.
- Reduced-motion mode remains fully understandable.
- No proprietary Fortnite artwork, sound, particles, exact styling, or screenshot enters the repository.

## Repository and branch

- Repository: `Hermann-33/Stone-Set`
- Planning branch: `codex/task-pd-011-mobile-home-rank-ui`
- Base: merged `main` after `TASK-ASSET-001`
- Product code added: none
- External infrastructure changed: none

## Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

## Exact next action

Merge the `TASK-PD-011` planning pull request after review, then execute:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
branch: codex/task-imp-001-foundation
packet: docs/tasks/TASK-IMP-001.md
```

Do not execute `TASK-IMP-002B` yet.

## Verdict

`COMPLETE`
