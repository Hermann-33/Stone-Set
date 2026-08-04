# Stone Set Active Context

Updated: 2026-08-04

## Current state

Stone Set is a private personal muscle-growth training application in product discovery. The repository contains no application code, runtime, database, external integration, deployment, or accepted technical stack.

Accepted product-domain baselines now cover:

1. a limited-equipment five-session hypertrophy routine with a hard 60-minute session cap;
2. workout execution rewards, valid PRs, lifetime XP, Rank Rating, missed-session penalties, and failed-week decay;
3. controlled same-week day swaps with two swaps per week and a direct RR cost;
4. a resettable consecutive-perfect-week multiplier reaching 2.50x after 15 perfect weeks.

## Active phase

`Phase 0 — Product discovery and governance`

Repository Phase 1 remains blocked by incomplete discovery.

## Latest completed work

`TASK-PD-005` renamed the highest rank from Titan to Adonis, replaced the rolling six-week multiplier with a resettable 5/10/15-week consistency ladder, and calibrated the path to the highest rank.

## Verified product facts

- Repository: `Hermann-33/Stone-Set`
- Initial user: repository owner
- Weekly structure: five resistance-training sessions and two non-lifting days
- Maximum session duration: 60 minutes including warm-up
- Rank tracks: permanent lifetime XP and current Rank Rating
- Rank count: 20
- Highest rank: `Adonis`
- Adonis threshold: `27,300 RR`
- Consistency basis: consecutive perfect weeks
- Multiplier tiers: 1.00x before Week 5, 1.50x at Week 5, 2.00x at Week 10, and 2.50x at Week 15+
- Maximum consistency multiplier: `2.50x`
- Any unprotected non-perfect week resets the streak and multiplier to zero weeks / 1.00x
- Protected pause: freezes rather than resets consistency
- A fully completed swapped week remains perfect
- Valid PR reward: 5 raw RR each, maximum two rewarded PRs per session
- Perfect-week reward: 25 RR and 25 lifetime XP
- Missed main session: -20 RR
- Missed specialization session: -15 RR
- Confirmed swap: -5 RR, maximum two per week
- Penalties are never multiplied by consistency
- Daily decay: prohibited
- Failed week: direct missed-session penalties plus rank-local weekly decay
- Extra unscheduled workouts and sets: no RR
- Clean no-PR Adonis projection: 87 perfect weeks, approximately 20 months
- Technology stack: not selected
- Implementation: not started

## Active task

No implementation task is active.

The next work remains product discovery, not code generation.

## Current blockers

Implementation cannot be scoped responsibly until the workout execution and logging workflow is defined, including timers, set entry, PR detection, provisional and finalized RR, consistency milestone top-ups, missed-session finalization, swaps, protected interruptions, progression recommendations, equipment conflicts, correction history, and user overrides.

## Exact next action

Define the complete application workflow from opening a scheduled workout through entering sets, completing or missing the session, resolving swaps and protected states, finalizing consistency and penalties, displaying the auditable RR breakdown, and generating the next-session prescription.

## Do-not-touch boundaries

- Do not scaffold application code.
- Do not select a stack.
- Do not add authentication, persistence, external services, analytics, telemetry, or deployment.
- Do not expand into nutrition or sleep planning.
- Do not create daily workout streaks or daily rank decay.
- Do not reward random extra workouts or extra sets.
- Do not remove missed-session or swap penalties without an explicit balance task.
- Do not penalize programmed rest, prescribed deloads, or protected pauses.
- Do not silently change the Adonis threshold or multiplier ladder.
- Do not treat research-derived guidance as medical diagnosis.

## Relevant decisions

No architecture ADR has been accepted yet.

Accepted product-domain baselines:

- `docs/product/HYPERTROPHY_ROUTINE.md`
- `docs/product/RANK_SYSTEM.md`
- `docs/product/WEEKLY_SCHEDULING.md`