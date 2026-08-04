# Stone Set Active Context

Updated: 2026-08-04

## Current state

Stone Set is a private personal muscle-growth training application in product discovery. The repository contains no application code, runtime, database, external integration, deployment, or accepted technical stack.

Two product-domain baselines are accepted:

1. a limited-equipment hypertrophy routine with a hard 60-minute session cap;
2. a workout rank system that rewards scheduled-session consistency, complete logging, and valid PRs.

## Active phase

`Phase 0 — Product discovery and governance`

Repository Phase 1 remains the later technical foundation phase and is still blocked by incomplete discovery.

## Latest completed work

`TASK-PD-002` adapted the supplied Quest Tracker rank model into a gym-specific system and documented it in `docs/product/RANK_SYSTEM.md`.

## Verified product facts

- Repository: `Hermann-33/Stone-Set`
- Initial user: repository owner
- Product direction: personal muscle-growth training application
- Weekly structure: five resistance-training sessions and two non-lifting days
- Maximum session duration: 60 minutes including warm-up
- Progression: repetitions first, then load
- Rank tracks: permanent lifetime XP and current Rank Rating
- Rank count: 20, from Bronze I to Titan
- Consistency calculation: rolling six-week scheduled-program adherence
- Maximum consistency multiplier: 1.50x
- Valid PR reward: 5 raw RR each, maximum two rewarded PRs per session
- Perfect-week reward: 25 RR and 25 lifetime XP
- Rest days: no reward, no penalty, no streak break
- Daily decay: prohibited
- Rank decay: weekly and only after an unprotected failed week with fewer than three completed scheduled sessions
- Extra unscheduled workouts and sets: no RR
- Technology stack: not selected
- Implementation: not started

## Active task

No implementation task is active.

The next work remains product discovery, not code generation.

## Current blockers

Implementation cannot be scoped responsibly until the workout execution and logging workflow is defined, including timers, set entry, PR detection, award previews, progression recommendations, substitutions, missed sessions, equipment conflicts, protected pauses, correction history, and user overrides.

## Exact next action

Define the first complete app workflow from opening a scheduled workout through entering sets, validating PRs, completing the session, showing the stored RR award breakdown, and generating the next-session prescription.

## Do-not-touch boundaries

- Do not scaffold application code.
- Do not select a stack.
- Do not add authentication, persistence, external services, analytics, telemetry, or deployment.
- Do not expand into nutrition or sleep planning.
- Do not create speculative ADRs.
- Do not create daily workout streaks or daily rank decay.
- Do not reward random extra workouts or extra sets.
- Do not treat research-derived guidance as medical diagnosis.
- Do not change accepted workout or rank baselines silently.

## Relevant decisions

No architecture ADR has been accepted yet.

Accepted product-domain baselines:

- `docs/product/HYPERTROPHY_ROUTINE.md`
- `docs/product/RANK_SYSTEM.md`