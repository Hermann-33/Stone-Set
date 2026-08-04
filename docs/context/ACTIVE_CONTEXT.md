# Stone Set Active Context

Updated: 2026-08-04

## Current state

Stone Set is a private personal muscle-growth training application in product discovery. The repository contains no application code, runtime, database, external integration, deployment, or accepted technical stack.

The foundational product-logic workstream is complete. Accepted product-domain baselines cover:

1. a limited-equipment five-session hypertrophy routine with a hard 60-minute session cap;
2. workout execution rewards, valid PRs, lifetime XP, Rank Rating, missed-session penalties, and failed-week decay;
3. controlled same-week day swaps with a two-swap weekly limit;
4. monthly bankable free-swap credits and optional paid swaps;
5. a resettable consecutive-perfect-week multiplier reaching 2.50x after 15 perfect weeks;
6. a compressed 20-rank ladder calibrated so defined decent consistency reaches Adonis in approximately ten months.

Foundational product logic being complete does not mean the application is ready to implement. End-to-end workflow, MVP scope, platform constraints, architecture, persistence, and the first implementation task remain undefined.

## Active phase

`Phase 0 — Product discovery and governance`

Repository Phase 1 remains blocked by incomplete workflow and architecture discovery.

## Latest completed work

`TASK-WF-002` verified and closed the foundational product-logic workstream, synchronized repository handoff state, and added `docs/context/NEW_CHAT_BOOTSTRAP.md` for future conversations.

## Verified product facts

- Repository: `Hermann-33/Stone-Set`
- Initial user: repository owner
- Weekly structure: five resistance-training sessions and two non-lifting days
- Maximum session duration: 60 minutes including warm-up
- Rank tracks: permanent lifetime XP and current Rank Rating
- Rank configuration: `rank-v5`
- Scheduling configuration: `schedule-v2`
- Rank count: 20
- Highest rank: `Adonis`
- Adonis threshold: `5,500 RR`
- Calibration target: approximately 43 weeks under the defined decent-consistency profile
- Defined decent consistency: approximately 93% scheduled-session completion, with 72% perfect weeks, 23% compliant weeks, and 5% weak weeks
- Previous paid-swap calibration result: mean 42.7 weeks and median 43 weeks across 50,000 synthetic simulations
- Free-credit expected-value effect: slightly faster by roughly 0.4 week under the same swap-frequency profile, still approximately ten months
- Consistency basis: consecutive perfect weeks
- Multiplier tiers: 1.00x before Week 5, 1.50x at Week 5, 2.00x at Week 10, and 2.50x at Week 15+
- Any unprotected non-perfect week resets the streak and multiplier to zero weeks / 1.00x
- Protected pause freezes rather than resets consistency
- A fully completed swapped week remains perfect
- Valid PR reward: 5 raw RR each, maximum two rewarded PRs per session
- Perfect-week reward: 25 RR and 25 lifetime XP
- Missed main session: -20 RR
- Missed specialization session: -15 RR
- Maximum confirmed swaps per week: 2
- Monthly free-swap grant: 2 credits
- Free-swap credits never expire and have no balance cap
- One free credit waives one swap's `5 RR` cost
- The user may preserve credits and pay `5 RR` instead
- Free credits do not increase the weekly swap limit
- Penalties are never multiplied by consistency
- Daily decay is prohibited
- Failed week: direct missed-session penalties plus rank-local weekly decay
- Extra unscheduled workouts and sets: no RR
- New-chat bootstrap: `docs/context/NEW_CHAT_BOOTSTRAP.md`
- Technology stack: not selected
- Implementation: not started

## Active task

No task is active. This conversation closes the foundational product-logic workstream.

## Current blockers

Implementation cannot be scoped responsibly until the workout execution and logging workflow is defined, including timers, set entry, PR detection, provisional and finalized RR, consistency milestone top-ups, free-swap wallet presentation, monthly grant materialization, swap payment choice, missed-session finalization, protected interruptions, progression recommendations, equipment conflicts, correction history, and user overrides.

## Exact next action

In the next Stone Set conversation, use `docs/context/NEW_CHAT_BOOTSTRAP.md`, load the repository, and define the complete end-to-end application workflow from viewing the weekly schedule and free-swap balance through swapping days, executing and logging workouts, resolving rewards and penalties, finalizing consistency, and generating the next-session prescription.

## Do-not-touch boundaries

- Do not scaffold application code.
- Do not select a stack.
- Do not add authentication, persistence, external services, analytics, telemetry, or deployment.
- Do not expand into nutrition or sleep planning.
- Do not create daily workout streaks or daily rank decay.
- Do not reward random extra workouts or extra sets.
- Do not remove missed-session or paid-swap penalties without an explicit balance task.
- Do not increase the two-swap weekly limit through free credits.
- Do not expire or cap banked free-swap credits.
- Do not penalize programmed rest, prescribed deloads, or protected pauses.
- Do not silently change the accepted workout baseline, `rank-v5`, `schedule-v2`, the `5,500 RR` Adonis threshold, rank ladder, or multiplier ladder.
- Do not treat synthetic balance projections as observed user data.
- Do not treat research-derived guidance as medical diagnosis.

## Relevant decisions

No architecture ADR has been accepted yet.

Accepted product-domain baselines:

- `docs/product/HYPERTROPHY_ROUTINE.md`
- `docs/product/RANK_SYSTEM.md`
- `docs/product/WEEKLY_SCHEDULING.md`

Reusable conversation bootstrap:

- `docs/context/NEW_CHAT_BOOTSTRAP.md`
