# Stone Set Project Brief

Updated: 2026-08-04
Status: `DISCOVERY — PRE-IMPLEMENTATION`

## Product purpose

Stone Set is a private muscle-growth training system for an initial two-user group.

Its purpose is to make evidence-informed hypertrophy routines executable, trackable, adaptable, and motivating under real constraints while preserving transparent rank, schedule, wallet, and correction history.

## Users

- Initial provisioned users: `2`.
- Public registration: excluded from MVP.
- Account count must not be hardcoded into the data model.
- Each ordinary user owns and manages only their own routine, schedule, logs, rank state, wallet, and history.
- Cross-user coaching or administration is not accepted for MVP.

## Foundational product-logic status

`COMPLETE FOR THE SINGLE-ROUTINE BASELINE`

Accepted product baselines currently cover:

- the repository owner's five-session hypertrophy routine;
- `rank-v5`;
- `schedule-v2`;
- lifetime XP and Rank Rating;
- consistency multipliers and resets;
- valid PR rewards;
- direct missed-session penalties;
- failed-week decay;
- same-week swaps;
- monthly bankable free-swap credits.

The new requirement for multiple user-owned routines and equal weekly RR opportunity reopens rank and scheduling discovery. It is proposed as `rank-v6` and `schedule-v3` and is not yet authoritative.

## Confirmed product problem

Each user needs a reliable way to:

- authenticate privately;
- follow a personal hypertrophy routine;
- complete sessions within the accepted 60-minute boundary where applicable;
- preserve exercise, set, repetition, load, RIR, rest, and completion history;
- adjust future routine versions without rewriting active or historical weeks;
- receive transparent progression recommendations;
- rearrange the current week through controlled swaps;
- earn and spend free-swap credits;
- understand every RR, XP, penalty, milestone, and correction;
- compete under the same rank ladder despite different routine structures.

## Accepted product outcomes

1. The repository owner's accepted routine remains documented in `docs/product/HYPERTROPHY_ROUTINE.md`.
2. The current rank system remains `rank-v5` until explicitly superseded.
3. The current scheduling system remains `schedule-v2` until explicitly superseded.
4. Rank contains 20 levels from Bronze I to Adonis.
5. Adonis remains `5,500 RR`.
6. The defined decent-consistency target remains approximately ten months under the accepted synthetic model.
7. Five, ten, and fifteen consecutive perfect weeks unlock 1.50x, 2.00x, and 2.50x.
8. Any unprotected non-perfect week resets the accepted consistency multiplier.
9. Protected pauses freeze rather than reset consistency.
10. Missed scheduled workouts create direct RR consequences under the active configuration.
11. Maximum confirmed swaps remain two per week.
12. Two free-swap credits are granted each month.
13. Credits never expire and have no balance cap.
14. One credit waives one swap's `5 RR` charge.
15. The user chooses between spending a credit and paying RR.
16. Unscheduled extra workouts and sets earn no RR.
17. All score, wallet, schedule, and correction changes remain auditable and versioned.

## Accepted planning architecture

The target architecture is documented in accepted ADRs:

- Flutter mobile application;
- separate Flutter Web dashboard;
- shared Dart domain and data packages;
- hosted Supabase Auth and Postgres;
- RLS-protected user-owned data;
- server-authoritative reward and wallet transitions.

Canonical decisions:

- `docs/decisions/ADR-0001-flutter-client-platforms.md`
- `docs/decisions/ADR-0002-supabase-backend-auth-and-persistence.md`

No runtime or infrastructure has been created.

## Account and credential boundary

- Passwords are managed by Supabase Auth.
- Passwords are not stored in application tables.
- Public profiles may store a unique username, display name, reward timezone, and non-sensitive settings.
- Public signup remains disabled for MVP.
- Both Flutter clients use publishable credentials only.
- Service-role and secret keys never appear in public clients.
- RLS and database authorization protect data; hidden UI controls do not.

## Routine-management direction

The planned dashboard allows each user to:

- create a routine draft;
- edit future workout and rest days;
- edit exercises, variants, order, sets, repetitions, RIR, rest, and priority;
- validate the draft;
- preview the next weekly schedule and reward allocation;
- publish an immutable routine version for a future week;
- inspect historical routine versions.

Published and historical routines are not edited in place.

## Proposed equal-opportunity rank direction

`docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md` proposes:

- a fixed weekly daily-item RR pool;
- workout days weighted more heavily than rest days;
- lower RR for programmed rest items;
- exact equal perfect-week base opportunity across four-, five-, and six-day routines;
- a fixed weekly missed-workout penalty pool;
- a weekly PR cap independent of routine frequency;
- a normalized failed-week threshold;
- routine publication and anti-gaming controls.

This proposal is not accepted yet. `rank-v5` still awards by session type and gives programmed rest days zero RR.

## Current scope

- product and workflow discovery;
- two provisioned user accounts;
- user-owned versioned routines;
- Flutter mobile execution experience;
- Flutter Web routine management;
- Supabase Auth and Postgres planning;
- weekly plan materialization;
- workout and set logging;
- timers and local in-progress draft recovery;
- rank, RR, XP, PR, consistency, penalty, decay, milestone, and correction behavior;
- schedule swaps and free-swap wallet;
- progression recommendations and user overrides;
- protected interruptions;
- architecture, security, data, testing, roadmap, and task planning.

## Current explicit non-goals

- application implementation in the current task;
- public signup;
- social authentication;
- cross-user routine editing;
- coach, organization, or public leaderboard systems;
- nutrition or sleep planning;
- payments, subscriptions, or monetization;
- wearables;
- social feeds or chat;
- medical diagnosis or injury clearance;
- RR for random extra volume;
- free credits increasing the weekly swap limit;
- retroactive swaps rewriting past misses;
- unversioned historical recalculation;
- analytics or telemetry without a later decision;
- microservices or unnecessary external integrations.

## Current maturity

`PRE-IMPLEMENTATION`

Documentation now contains:

- accepted single-routine product baselines;
- accepted Flutter and Supabase planning architecture;
- a proposed end-to-end workflow;
- a proposed multi-user normalized-reward model;
- a documentation-only implementation plan.

The repository still contains no application code, Flutter project, Supabase schema, credentials, database, deployment, CI, or tests.

## Current accepted configurations

- Workout baseline: `docs/product/HYPERTROPHY_ROUTINE.md`
- Rank configuration: `rank-v5`
- Scheduling configuration: `schedule-v2`
- Highest rank: Adonis at `5,500 RR`
- Maximum multiplier: `2.50x`
- Multiplier unlocks: Weeks 5, 10, and 15
- Perfect-week bonus: `25 RR` and `25 lifetime XP`
- Valid PR: `5 raw RR` and `5 lifetime XP`, maximum two per session under `rank-v5`
- Missed main session: `-20 RR`
- Missed specialization session: `-15 RR`
- Maximum confirmed swaps: `2` per week
- Paid swap: up to `5 RR`
- Monthly free-swap grant: `2`
- Free-swap expiry: none
- Free-swap balance cap: none

## Product and operational facts still to be accepted

1. activation or rejection of `rank-v6` and `schedule-v3`;
2. acceptable cross-routine calibration variance;
3. exact local in-progress-workout persistence technology;
4. offline final-submission behavior;
5. Android and iOS release scope;
6. dashboard hosting provider;
7. production Supabase environment and backup policy;
8. operational access and recovery procedures;
9. first bounded implementation task.

## Discovery completion criteria

Phase 0 is complete only when:

- the end-to-end workflow is accepted and testable;
- the variable-routine rank and scheduling model is accepted or replaced;
- MVP and non-goals are explicit;
- platform, connectivity, persistence, security, privacy, cost, maintenance, release, and hosting constraints are accepted;
- architecture ADRs cover every durable implementation choice;
- the first implementation task has measurable acceptance criteria.

## Honest capability boundary

Stone Set does not currently authenticate users, store routines, run a dashboard, log workouts, calculate daily RR, manage a database, grant credits, process swaps, validate PRs, finalize weeks, or generate recommendations. Every such behavior remains documented or proposed, not implemented.
