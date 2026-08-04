# Stone Set Project Brief

Updated: 2026-08-04
Status: Discovery

## Product purpose

Stone Set is a personal muscle-growth training application for the repository owner.

Its initial purpose is to make an evidence-informed hypertrophy routine executable, trackable, adaptable, and motivating under real constraints rather than relying on memory, scattered notes, arbitrary exercise changes, or shallow attendance streaks.

## Primary user

- Initial user: repository owner
- Additional user types: not yet decided

## Confirmed product problem

The owner needs a reliable way to execute and progressively adjust a hypertrophy routine when:

- gym equipment is limited;
- each session must finish within 60 minutes;
- exercise order, sets, repetitions, rest periods, and effort targets must remain consistent enough to measure progress;
- future changes must be based on logged performance and recovery rather than random variation;
- uninterrupted perfect-week consistency should materially accelerate rank progression;
- any unprotected non-perfect week should reset the consistency multiplier;
- legitimate PRs should produce additional rank progress without rewarding fake volume;
- missing an unprotected scheduled workout should create a real current-rank consequence;
- unavoidable schedule conflicts should permit controlled same-week rearrangement with a smaller RR consequence;
- programmed rest, deloads, and protected pauses must remain non-punitive;
- the complete rank ladder should be attainable in approximately ten months under a defined decent-consistency profile.

## Accepted user outcomes

1. The user can follow the five-session hypertrophy routine in `docs/product/HYPERTROPHY_ROUTINE.md`, complete each session within 60 minutes, and preserve enough data to evaluate progression.
2. The user can earn lifetime XP and Rank Rating under `docs/product/RANK_SYSTEM.md`.
3. The user progresses through 20 ranks from Bronze I to Adonis.
4. Adonis is reached at `5,500 RR`.
5. The rank ladder is calibrated to an average of approximately 43 weeks under the accepted synthetic decent-consistency profile.
6. Five consecutive perfect weeks unlock 1.50x session RR, ten unlock 2.00x, and fifteen unlock the 2.50x cap while the streak continues.
7. Any unprotected non-perfect week resets the perfect-week streak and multiplier to 1.00x.
8. The user directly loses RR for every unprotected missed scheduled workout.
9. The user may exchange any two unlocked days inside the active Monday-Sunday week under `docs/product/WEEKLY_SCHEDULING.md`.
10. Each confirmed swap costs 5 RR, and no more than two swaps may be confirmed in one week.

## Current scope

- product discovery;
- evidence-backed workout-program definition;
- exercise, set, repetition, RIR, rest, and progression rules;
- limited-equipment and 60-minute constraints;
- lifetime XP, Rank Rating, rank thresholds, resettable consistency multipliers, PR rewards, streak milestones, missed-session penalties, swap penalties, and failed-week decay;
- synthetic balance calibration and rank-configuration versioning;
- same-week scheduling, day locking, swap limits, warnings, and corrections;
- protected recovery states;
- future workout logging and controlled program-adjustment workflow;
- architecture evaluation, roadmap definition, and bounded Codex task planning.

## Explicit non-goals at this stage

- selecting a technology stack;
- generating application scaffolding;
- implementing features;
- creating a database or external-service account;
- authentication, deployment, monetization, analytics, or integrations;
- nutrition or sleep planning;
- daily workout streaks or daily rank decay;
- RR for random extra workouts or sets;
- penalties for programmed rest days or approved protected pauses;
- retroactive swaps that rewrite a past missed day;
- medical diagnosis or injury-clearance decisions;
- presenting synthetic balance simulations as real population evidence;
- claiming production capability.

## Current maturity

`PRE-IMPLEMENTATION`

There is no application runtime, UI, service, data model, deployment, or test suite yet.

## Confirmed domain constraints

- The initial routine uses only equipment listed in `docs/product/HYPERTROPHY_ROUTINE.md`.
- Every workout has a hard 60-minute cap including warm-up.
- The program contains five resistance-training sessions and two rest days per week.
- Progression uses repetitions first, then load.
- Rank uses separate lifetime XP and current RR tracks.
- Current rank configuration: `rank-v4`.
- Highest rank: Adonis at `5,500 RR`.
- Defined decent consistency: 72% perfect weeks, 23% compliant weeks, and 5% weak weeks, approximately 93% scheduled-session completion.
- The 50,000-run calibration produced a 42.7-week mean and 43-week median to Adonis.
- Consecutive perfect-week multiplier tiers: 1.00x for weeks 0-4, 1.50x for weeks 5-9, 2.00x for weeks 10-14, and 2.50x for week 15 onward.
- The fifth, tenth, and fifteenth perfect weeks receive exact milestone top-ups.
- Any unprotected non-perfect week resets the consistency streak and multiplier.
- Protected pauses freeze rather than reset consistency.
- Valid PR rewards are capped at two per session.
- An unprotected missed main session costs 20 RR.
- An unprotected missed specialization session costs 15 RR.
- Any two distinct unlocked days in the active week may be exchanged.
- Maximum confirmed swaps per week: 2.
- Each confirmed swap costs 5 RR and never reduces lifetime XP.
- Swap and missed-session penalties are never multiplied by consistency.
- A week containing swaps can still be perfect when all five sessions are completed.
- A confirmed swap cannot be freely undone; restoring the schedule requires another valid swap.
- Rest days do not break consistency or cause penalties by themselves.
- Failed weeks receive missed-session penalties plus rank-local weekly decay.
- Unscheduled extra training earns no RR.

## Product facts still to be established

1. the exact trigger that opens the app before or during training;
2. the complete workout-start-to-workout-completion user flow;
3. required workout-log fields and editing behavior;
4. timer and rest-management behavior;
5. progression recommendation rules and user override behavior;
6. pain, substitution, equipment-unavailable, and protected-interruption flows;
7. exact screen behavior for swap preview, confirmation, warnings, locks, and correction history;
8. provisional RR, weekly finalization, consistency top-up, reset, and transaction-feedback behavior;
9. historical rank-configuration migration behavior once persistent data exists;
10. required versus optional MVP features;
11. platform, offline, sync, persistence, privacy, security, cost, and maintenance constraints;
12. measurable success criteria for the first usable version.

## Success criteria for discovery

Discovery is complete only when:

- the workout execution and logging workflow is specific and testable;
- the minimum viable scope is separated from later ideas;
- progression and adjustment behavior is defined without medical diagnosis;
- rank awards, multiplier unlocks, resets, swaps, penalties, corrections, weekly evaluation, and protection behavior are testable;
- major architecture options are evaluated;
- accepted durable architecture decisions are recorded;
- the first implementation phase has measurable completion criteria.

## Honest capability boundary

Stone Set currently consists only of repository documentation, governance, and accepted workout, rank, and weekly-scheduling baselines. The application does not yet track workouts, manage timers, swap days, validate PRs, calculate RR, apply multiplier top-ups or resets, persist data, or provide recommendations.