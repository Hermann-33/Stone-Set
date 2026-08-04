# Stone Set Project Brief

Updated: 2026-08-04
Status: Discovery

## Product purpose

Stone Set is a personal muscle-growth training application for the repository owner.

Its initial purpose is to make an evidence-informed hypertrophy routine executable, trackable, adaptable, and motivating under real constraints rather than relying on memory, scattered notes, arbitrary exercise changes, or shallow attendance streaks.

## Primary user

- Initial user: the repository owner
- Additional user types: not yet decided

## Confirmed product problem

The owner needs a reliable way to execute and progressively adjust a hypertrophy routine when:

- gym equipment is limited;
- each session must finish within 60 minutes;
- exercise order, sets, repetitions, rest periods, and effort targets must remain consistent enough to measure progress;
- future changes must be based on logged performance and recovery rather than random variation;
- long-term consistency and legitimate PRs should produce visible rank progression without rewarding overtraining or fake volume.

## Accepted user outcomes

1. The user can follow the accepted five-session weekly hypertrophy routine defined in `docs/product/HYPERTROPHY_ROUTINE.md`, complete each session within 60 minutes, and preserve enough training data to determine whether load, repetitions, volume, or exercise selection should change.
2. The user can earn permanent lifetime XP and current Rank Rating from valid scheduled sessions, complete logging, legitimate PRs, and sustained adherence under the accepted rules in `docs/product/RANK_SYSTEM.md`.

## Current scope

- product discovery;
- evidence-backed workout-program definition;
- exercise, set, repetition, RIR, rest, and progression rules;
- limited-equipment constraints;
- strict session-duration constraints;
- workout consistency, PR, lifetime XP, rank RR, streak milestone, and demotion rules;
- future workout logging and controlled program-adjustment workflow;
- requirement capture;
- decision recording;
- architecture evaluation;
- roadmap definition;
- bounded Codex implementation prompts;
- verification and handoff discipline.

## Explicit non-goals at this stage

- selecting a technology stack without documented requirements;
- generating application scaffolding;
- implementing features;
- creating a database or external-service account;
- defining authentication, deployment, monetization, analytics, or integrations;
- nutrition planning;
- sleep or university-schedule planning;
- daily workout streaks;
- RR rewards for random extra workouts or extra sets;
- medical diagnosis or injury-clearance decisions;
- claiming that one static routine is universally optimal;
- claiming production capability.

## Current maturity

`PRE-IMPLEMENTATION`

There is no application runtime, UI, service, data model, deployment, or test suite yet.

## Confirmed domain constraints

- The initial routine uses only the equipment listed in `docs/product/HYPERTROPHY_ROUTINE.md`.
- Every workout has a hard 60-minute cap including warm-up.
- The program contains five weekly resistance-training sessions and two days without resistance training.
- Progression uses logged repetitions first, then load.
- Compound movements normally stop with 1-2 repetitions in reserve.
- Isolation movements normally stop with 0-2 repetitions in reserve.
- Program changes must alter one variable at a time.
- Rank uses separate lifetime XP and current RR tracks.
- Consistency is evaluated against scheduled weeks, not daily gym attendance.
- A rolling six-week consistency multiplier increases RR up to 1.50x.
- Valid PR rewards are capped at two per session.
- Rest days do not break consistency or cause decay.
- Rank decay occurs only after materially failed, unprotected weeks.
- Unscheduled extra training earns no RR.

## Product facts still to be established

1. the exact trigger that opens the app before or during training;
2. the complete workout-start-to-workout-completion user flow;
3. required workout-log fields and editing behavior;
4. timer and rest-management behavior;
5. progression recommendation rules and user override behavior;
6. pain, substitution, missed-session, rescheduling, and equipment-unavailable flows;
7. detailed rank UI and reward-feedback behavior;
8. configuration-versioning and historical-score migration behavior;
9. required versus optional features;
10. device and platform targets;
11. offline, sync, and persistence requirements;
12. privacy and security requirements;
13. acceptable operating cost and maintenance burden;
14. success criteria for the first usable version.

## Success criteria for discovery

Discovery is complete only when:

- the workout execution and logging workflow is specific and testable;
- the minimum viable scope is separated from later ideas;
- constraints and non-goals are explicit;
- progression and adjustment behavior is defined without pretending the app can diagnose health conditions;
- rank awards, corrections, weekly evaluation, and protected-pause behavior are testable;
- major architecture options are evaluated;
- accepted durable decisions are recorded as ADRs;
- the first implementation phase has measurable completion criteria.

## Honest capability boundary

Stone Set currently consists only of repository documentation, governance, an accepted workout-program baseline, and an accepted rank-system baseline. The application does not yet track workouts, manage timers, validate PRs, calculate RR, persist data, or provide recommendations.