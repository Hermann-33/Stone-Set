# TASK-PD-011 — Define mobile home and radial rank-progress UI

Status: `COMPLETE`
Approved by: user request on 2026-08-05
Type: product and implementation planning only

## Objective

Define Stone Set's base Android home-screen UI, using the supplied Fortnite screenshot only as inspiration for a centered rank emblem surrounded by an animated circular progress ring, then place the resulting implementation sequence into the canonical roadmap without starting Flutter implementation.

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
- The application workflow already requires authenticated Home, Week, History, Profile, rank, RR, lifetime XP, multiplier, pending synchronization, and today's action.
- No mobile design system, navigation shell, rank-progress component, animation contract, or UI implementation packet existed.

## Accepted decisions

- The rank emblem is the visual focal point of the Android Home screen.
- A near-complete circular ring with a small top gap shows progress to the next rank.
- The ring represents finalized authoritative RR only.
- Provisional RR uses a distinct secondary treatment and never changes the authoritative emblem.
- Pending local synchronization does not move the rank ring.
- The Home screen also exposes today's item, week summary, key progression statistics, and pending state.
- The authenticated mobile shell uses Home, Week, History, and Profile destinations.
- Motion is event-driven, restrained, reduced-motion aware, and never continuously animated while idle.
- Fortnite is inspiration only; no screenshot, proprietary artwork, exact styling, sound, particle pattern, or animation choreography is copied.
- The UI is implemented after foundation and authentication through a dedicated `TASK-IMP-002B` packet.
- Fixture-backed UI is implemented before server rank integration.
- Weekly-plan data is connected in `TASK-IMP-004`, workout state in `TASK-IMP-005A`, and authoritative rank events in `TASK-IMP-006`.

## Files created

- `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md`
- `docs/tasks/TASK-PD-011.md`
- `docs/tasks/TASK-IMP-002B.md`

## Files synchronized

- `docs/product/APPLICATION_WORKFLOW.md`
- `docs/context/ACTIVE_CONTEXT.md`
- `docs/context/CODEBASE_MAP.md`
- `docs/context/ROADMAP.md`
- `docs/context/IMPLEMENTATION_PLAN.md`
- `docs/context/HANDOFF.md`
- `docs/context/AUDIT_LOG_CONTINUED.md`

## Protected boundaries

- Preserve `rank-v6`, all thresholds, and Adonis at 5,500 RR.
- Preserve server-authoritative RR and rank finalization.
- Preserve `TASK-IMP-001` as foundation-only.
- Do not claim Phase 1 has started.
- Do not implement Flutter, Supabase, routing, animation, or product behavior in this task.
- Do not commit the supplied Fortnite screenshot.
- Do not add a third-party animation dependency as a planning assumption.

## Verification

- The UI hierarchy covers rank, today's action, week state, synchronization, and progression statistics.
- Authoritative, provisional, pending, stale, max-rank, rank-up, rank-down, loading, error, and reduced-motion states are defined.
- The progress formula is compatible with all `rank-v6` thresholds.
- The component contract does not grant client authority over RR or rank.
- The future packet is explicitly blocked by `TASK-IMP-001` and `TASK-IMP-002A`.
- Roadmap sequencing avoids duplicating Home implementation in later workout and rank phases.
- No product code or external infrastructure is introduced.

## Verdict

`COMPLETE`

The mobile base-UI and radial rank-progress design are accepted and implementation-planned. The exact next implementation action remains `TASK-IMP-001`.
