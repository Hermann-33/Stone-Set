# TASK-PD-011 — Define mobile home and radial rank-progress UI

Status: `COMPLETE`
Approved by: user request on 2026-08-05
Type: product and implementation planning only

## Objective

Define Stone Set's base Android Home-screen UI, using the supplied Fortnite screenshot only as inspiration for a centered rank emblem surrounded by an animated circular progress bar, then place the implementation sequence into the canonical roadmap without starting Flutter implementation.

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
10. `docs/product/APPLICATION_WORKFLOW.md`
11. `docs/product/RANK_SYSTEM.md`
12. `assets/ranks/manifest.json`

## Verified starting state

- `TASK-ASSET-001` is merged into `main`.
- `stone-set-ranks-v1` contains 20 transparent rank PNGs.
- Phase 0 is complete.
- Phase 1 is ready but not started.
- `TASK-IMP-001` remains the exact next implementation action.
- The application workflow already requires authenticated Home, Week, History, Profile, rank, RR, lifetime XP, multiplier, pending synchronization, today's item, and the next valid action.
- No mobile design system, navigation shell, rank-progress component, animation contract, or UI implementation packet existed.

## Accepted decisions

- The rank emblem is the visual focal point of the Android Home screen.
- A complete `360°` inactive circular track surrounds the emblem and remains visible even at `0%`.
- The active progress arc begins at 12 o'clock, advances clockwise, and forms a seamless full circle at `100%`.
- The earlier top-gap concept is superseded.
- The active ring represents finalized authoritative RR only.
- Provisional RR uses a distinct secondary treatment and never changes the authoritative emblem.
- Pending local synchronization does not move the authoritative active arc.
- The Home screen explicitly exposes the action for today's scheduled workout.
- Workout-day actions are `Start workout`, `Continue workout`, `Sync workout`, and `View result`, depending on state.
- A programmed rest day does not expose a rewarded unscheduled workout or manual completion action.
- The authenticated mobile shell uses Home, Week, History, and Profile destinations.
- Home also exposes the week summary, key progression statistics, and conditional pending/provisional state.
- Motion is event-driven, restrained, reduced-motion aware, and never continuously animated while idle.
- Fortnite is inspiration only; no screenshot, proprietary artwork, exact styling, sound, particle pattern, or animation choreography is copied.
- The UI is implemented after foundation and authentication through a dedicated `TASK-IMP-002B` packet.
- Fixture-backed UI is implemented before server rank or workout integration.
- Weekly-plan data is connected in `TASK-IMP-004`, workout logging and synchronization in `TASK-IMP-005A`, and authoritative rank events in `TASK-IMP-006`.

## Files created

- `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md`
- `docs/tasks/TASK-PD-011.md`
- `docs/tasks/TASK-IMP-002B.md`
- `docs/context/AUDIT_LOG_CONTINUED_2.md`

## Files synchronized

- `docs/context/ACTIVE_CONTEXT.md`
- `docs/context/CODEBASE_MAP.md`
- `docs/context/ROADMAP.md`
- `docs/context/IMPLEMENTATION_PLAN.md`
- `docs/context/HANDOFF.md`

`docs/product/APPLICATION_WORKFLOW.md` already contains today's item and next-action requirements. The dedicated mobile UI specification owns the exact ring behavior, Home layout, and state-dependent workout action contract.

## Protected boundaries

- Preserve `rank-v6`, all thresholds, and Adonis at 5,500 RR.
- Preserve server-authoritative RR, workout start, submission, and rank finalization.
- Preserve `TASK-IMP-001` as foundation-only.
- Do not claim Phase 1 has started.
- Do not implement Flutter, Supabase, routing, animation, or product behavior in this task.
- Do not commit the supplied Fortnite screenshot.
- Do not add a third-party animation dependency as a planning assumption.

## Verification

- The UI hierarchy covers rank, today's workout/rest action, week state, synchronization, and progression statistics.
- The ring is defined at 0%, intermediate values, exact 100%, threshold transition, and max rank.
- Authoritative, provisional, pending, stale, max-rank, rank-up, rank-down, loading, error, and reduced-motion states are defined.
- The progress formula is compatible with all `rank-v6` thresholds.
- The component contract does not grant client authority over RR, rank, workout start, or submission.
- The future packet is explicitly blocked by `TASK-IMP-001` and `TASK-IMP-002A`.
- Roadmap sequencing avoids duplicating Home implementation in later weekly-plan, workout, and rank phases.
- No product code or external infrastructure is introduced.

## Verdict

`COMPLETE`

The mobile base-UI, full-circle rank progress bar, and today's workout entry action are accepted and implementation-planned. The exact next implementation action remains `TASK-IMP-001`.