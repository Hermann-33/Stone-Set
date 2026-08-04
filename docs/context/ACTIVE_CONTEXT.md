# Stone Set Active Context

Updated: 2026-08-04

## Current state

Stone Set is a private personal muscle-growth training application in product discovery. The repository contains no application code, runtime, database, external integration, deployment, or accepted technical stack.

Three product-domain baselines are accepted:

1. a limited-equipment hypertrophy routine with a hard 60-minute session cap;
2. a workout rank system that rewards consistency, logging, and valid PRs while penalizing misses;
3. a weekly scheduling system that permits controlled day swaps with an RR cost.

## Active phase

`Phase 0 — Product discovery and governance`

Repository Phase 1 remains blocked by incomplete discovery.

## Latest completed work

`TASK-PD-004` defined same-week session swaps and their Rank Rating consequences.

## Verified product facts

- Repository: `Hermann-33/Stone-Set`
- Weekly structure: five resistance-training sessions and two rest days
- Maximum workout duration: 60 minutes including warm-up
- Rank tracks: lifetime XP and current Rank Rating
- Rank count: 20, Bronze I through Titan
- Maximum consistency multiplier: 1.50x
- Valid PR reward: 5 raw RR each, maximum two rewarded PRs per session
- Perfect-week reward: 25 RR and 25 lifetime XP
- Missed main session: -20 RR
- Missed specialization session: -15 RR
- Maximum confirmed swaps per week: 2
- Confirmed swap penalty: -5 RR
- Maximum weekly swap penalty: -10 RR
- Swaps may exchange any two distinct unlocked days inside the active Monday–Sunday week
- Workout-to-rest and workout-to-workout swaps are allowed
- A swapped week can remain perfect when all five sessions are completed
- Confirmed swaps cannot be freely undone; restoring the schedule requires another swap
- Retroactive swaps are prohibited after a day locks
- Penalties never reduce lifetime XP and are never amplified by consistency
- Rest days: no reward, no penalty, no streak break
- Failed week: missed-session penalties plus rank-local weekly decay
- Extra unscheduled workouts and sets: no RR
- Technology stack: not selected
- Implementation: not started

## Active task

No implementation task is active.

The next work remains product discovery, not code generation.

## Current blockers

Implementation cannot be scoped responsibly until the end-to-end workout workflow is defined, including timers, set entry, PR detection, award previews, day-swap UI, locking, missed-session finalization, protected interruptions, progression recommendations, correction history, and user overrides.

## Exact next action

Define the first complete app workflow from viewing the current weekly schedule through optionally swapping days, opening a scheduled workout, entering sets, validating PRs, completing or missing the session, finalizing RR transactions, and producing the next-session prescription.

## Do-not-touch boundaries

- Do not scaffold application code.
- Do not select a stack.
- Do not add authentication, persistence, external services, analytics, telemetry, or deployment.
- Do not expand into nutrition or sleep planning.
- Do not create daily workout streaks or daily rank decay.
- Do not reward random extra workouts or extra sets.
- Do not remove direct missed-session or swap penalties without an explicit balance task.
- Do not allow more than two confirmed swaps per week.
- Do not allow cross-week or retroactive swaps.
- Do not penalize programmed rest or approved protected pauses.
- Do not treat training guidance as medical diagnosis.
- Do not change accepted product baselines silently.

## Relevant decisions

No architecture ADR has been accepted yet.

Accepted product-domain baselines:

- `docs/product/HYPERTROPHY_ROUTINE.md`
- `docs/product/RANK_SYSTEM.md`
- `docs/product/WEEKLY_SCHEDULING.md`