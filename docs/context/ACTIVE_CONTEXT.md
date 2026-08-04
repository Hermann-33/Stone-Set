# Stone Set Active Context

Updated: 2026-08-04

## Current state

Stone Set is a private two-user muscle-growth training system in product, architecture, and implementation planning.

The repository contains documentation only. There is no Flutter project, Supabase project, database schema, authentication runtime, account, dashboard, deployment, CI, or test suite.

Accepted planning architecture:

- Flutter mobile application;
- separate Flutter Web dashboard;
- shared Dart domain and data packages;
- Supabase Auth and Postgres;
- Row Level Security;
- server-authoritative reward, wallet, and finalization transitions.

Accepted product workflow and multi-user normalization now exist.

## Active phase

`Phase 0 — Product discovery, architecture, and implementation planning`

Phase 1 has not started and is not complete.

## Latest completed work

`TASK-PD-008` accepted and activated:

- user-specific versioned routines;
- `rank-v6` normalized daily-item rewards;
- `schedule-v3` variable-routine weekly scheduling;
- the complete application workflow;
- four-to-six-workout-day MVP support;
- equal maximum weekly RR opportunity;
- normalized missed-workout penalties and weekly PR opportunity.

## Accepted architecture decisions

- `ADR-0001`: Flutter mobile and Flutter Web clients with shared Dart packages.
- `ADR-0002`: Supabase Auth and Postgres with RLS, no application-table password storage, and no client-authored score totals.

## Accepted product facts

### Users and routines

- Initial provisioned accounts: 2.
- Public registration: excluded from MVP.
- Data model account count: not hardcoded to two.
- Users manage only their own routine drafts.
- Published routine versions are immutable.
- Routine edits apply only to future unlocked weeks.
- Supported MVP frequency: 4-6 workout days and at least 1 programmed rest day.
- Every materialized week contains 7 plan items.
- Initial owner routine remains the five-session routine in `HYPERTROPHY_ROUTINE.md`.

### Rank and fairness

- Active rank configuration: `rank-v6`.
- Active scheduling configuration: `schedule-v3`.
- Rank count: 20.
- Highest rank: Adonis.
- Adonis threshold: `5,500 RR`.
- Daily-item RR pools: 110, 167, 220, and 277 at 1.00x, 1.50x, 2.00x, and 2.50x.
- Perfect-week bonus: 25 RR and 25 lifetime XP.
- Maximum no-PR weekly RR: 135, 192, 245, and 302.
- Weekly ordinary base-XP item pool: 110.
- Workout-item weight: 4.
- Rest-item weight: 1.
- Rest items finalize automatically and earn lower allocations.
- Weekly direct missed-workout penalty pool: 95 RR.
- Maximum rewarded PRs: 2 per week.
- Valid PR: 5 raw RR and 5 lifetime XP.
- PR RR is consistency-multiplied; PR XP is not.
- Failed week: unprotected workout-completion ratio below 60%.
- Multiplier tiers remain 1.00x, 1.50x, 2.00x, and 2.50x at Weeks 0, 5, 10, and 15.
- Any unprotected non-perfect week resets consistency.
- Protected full weeks freeze consistency.
- Daily rank decay is prohibited.
- Unscheduled extra workouts and sets earn no RR or XP.

### Swaps and wallet

- Maximum confirmed swaps per week: 2.
- Monthly free-swap grant: 2 credits.
- Credits never expire and have no balance cap.
- One credit waives one swap's `5 RR` cost.
- Users may preserve credits and pay RR.
- Free credits never increase the weekly swap limit.
- Paid and missed penalties are never multiplied.
- Swaps move complete plan-item identity and stored allocations.
- Retroactive and cross-week swaps are prohibited.

### Calibration

- Perfect-week maximum opportunity is exactly equal for 4-, 5-, and 6-workout-day routines.
- Preliminary 50,000-user synthetic means: 42.87, 42.00, and 41.41 weeks to Adonis.
- The maximum synthetic mean spread of approximately 1.46 weeks is accepted.
- Synthetic projections are not observed user data.

## Accepted workflow

`docs/product/APPLICATION_WORKFLOW.md` is the accepted end-to-end product workflow for:

- provisioning and sign-in;
- routine drafting and publication;
- weekly plan materialization;
- mobile home and schedule;
- swaps and wallet payment;
- workout execution and logging;
- rest-item finalization;
- daily and weekly awards;
- progression recommendations;
- protected interruptions and corrections;
- transparent history.

## Current blockers

Implementation remains blocked by:

1. concrete reward-eligibility and anti-triviality rules for user-created routines;
2. local in-progress-workout persistence behavior;
3. offline submission and server-finalization behavior;
4. initial mobile release targets;
5. dashboard hosting target;
6. production Supabase backup and operator-access expectations;
7. approval of the bounded `TASK-IMP-001` packet.

## Exact next action

Run:

`TASK-PL-002 — Close implementation constraints and authorize the foundation task`

This task must resolve all current blockers and produce the first implementation packet. No scaffolding is authorized before it passes.

## Do-not-touch boundaries

- Do not represent Phase 1 as started or complete.
- Do not scaffold application code yet.
- Do not create a Supabase project, schema, account, credential, or secret yet.
- Do not store passwords in application tables.
- Do not expose service-role or secret keys to public clients.
- Do not allow clients to set RR, XP, rank, penalties, wallet balances, milestones, or finalization totals.
- Do not silently change `rank-v6`, `schedule-v3`, Adonis at `5,500 RR`, or the 5/10/15 multiplier ladder.
- Do not increase the two-swap weekly limit through credits.
- Do not expire or cap free-swap credits.
- Do not reward unscheduled extra workouts or sets.
- Do not introduce nutrition, sleep, social, payment, wearable, analytics, or medical-diagnosis features.
- Do not treat synthetic simulations as observed user data.

## Relevant sources

Accepted product baselines:

- `docs/product/HYPERTROPHY_ROUTINE.md`
- `docs/product/RANK_SYSTEM.md`
- `docs/product/WEEKLY_SCHEDULING.md`
- `docs/product/APPLICATION_WORKFLOW.md`

Supporting activation analysis:

- `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md`

Implementation plan:

- `docs/context/IMPLEMENTATION_PLAN.md`

Accepted ADRs:

- `docs/decisions/ADR-0001-flutter-client-platforms.md`
- `docs/decisions/ADR-0002-supabase-backend-auth-and-persistence.md`