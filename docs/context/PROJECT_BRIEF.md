# Stone Set Project Brief

Updated: 2026-08-03
Status: Discovery

## Product purpose

Stone Set is a personal muscle-growth training application for the repository owner.

Its initial purpose is to make an evidence-informed hypertrophy routine executable, trackable, and adaptable under real constraints rather than relying on memory, scattered notes, or arbitrary exercise changes.

## Primary user

- Initial user: the repository owner
- Additional user types: not yet decided

## Confirmed product problem

The owner needs a reliable way to execute and progressively adjust a hypertrophy routine when:

- gym equipment is limited;
- each session must finish within 60 minutes;
- exercise order, sets, repetitions, rest periods, and effort targets must remain consistent enough to measure progress;
- future changes must be based on logged performance and recovery rather than random variation.

## First accepted user outcome

The user can follow the accepted five-session weekly hypertrophy routine defined in `docs/product/HYPERTROPHY_ROUTINE.md`, complete each session within 60 minutes, and preserve enough training data to determine whether load, repetitions, volume, or exercise selection should change.

## Current scope

- product discovery;
- evidence-backed workout-program definition;
- exercise, set, repetition, RIR, rest, and progression rules;
- limited-equipment constraints;
- strict session-duration constraints;
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

## Product facts still to be established

1. the exact trigger that opens the app before or during training;
2. the complete workout-start-to-workout-completion user flow;
3. required workout-log fields;
4. timer and rest-management behavior;
5. progression recommendation rules and user override behavior;
6. pain, substitution, missed-session, and equipment-unavailable flows;
7. required versus optional features;
8. device and platform targets;
9. offline, sync, and persistence requirements;
10. privacy and security requirements;
11. acceptable operating cost and maintenance burden;
12. success criteria for the first usable version.

## Success criteria for discovery

Discovery is complete only when:

- the workout execution and logging workflow is specific and testable;
- the minimum viable scope is separated from later ideas;
- constraints and non-goals are explicit;
- progression and adjustment behavior is defined without pretending the app can diagnose health conditions;
- major architecture options are evaluated;
- accepted durable decisions are recorded as ADRs;
- the first implementation phase has measurable completion criteria.

## Honest capability boundary

Stone Set currently consists only of repository documentation, governance, and an accepted workout-program baseline. The application does not yet track workouts, manage timers, calculate progression, persist data, or provide recommendations.