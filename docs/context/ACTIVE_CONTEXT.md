# Stone Set Active Context

Updated: 2026-08-04

## Current state

Stone Set is a private two-user muscle-growth training system in product and implementation planning.

The repository contains documentation only. There is no Flutter project, Supabase project, database schema, authentication runtime, dashboard, deployment, CI, or test suite.

Accepted planning architecture now exists:

- Flutter mobile application;
- separate Flutter Web dashboard;
- shared Dart domain and data packages;
- Supabase Auth and Postgres;
- Row Level Security;
- server-authoritative rank and wallet transitions.

The single-routine foundational product baseline remains accepted as `rank-v5` and `schedule-v2`.

The new requirement for user-specific routines and equal weekly RR opportunity reopens rank and scheduling discovery. It is documented as a proposed `rank-v6` and `schedule-v3`, not as active behavior.

## Active phase

`Phase 0 — Product discovery, architecture, and implementation planning`

Phase 1 has not started and is not complete.

## Latest work

`TASK-PL-001` documents:

- the proposed end-to-end application workflow;
- the proposed multi-user routine and normalized daily-RR model;
- the documentation-only implementation plan;
- accepted Flutter client architecture;
- accepted Supabase authentication and persistence architecture.

## Accepted architecture decisions

- `ADR-0001`: Flutter mobile and Flutter Web clients with shared Dart packages.
- `ADR-0002`: Supabase Auth and Postgres with RLS, no application-table password storage, and no client-authored score totals.

## Verified accepted product facts

- Accepted workout baseline: limited-equipment five-session routine
- Maximum session duration: 60 minutes including warm-up
- Rank tracks: permanent lifetime XP and current Rank Rating
- Active rank configuration: `rank-v5`
- Active scheduling configuration: `schedule-v2`
- Rank count: 20
- Highest rank: Adonis
- Adonis threshold: `5,500 RR`
- Calibration target: approximately ten months under the defined synthetic decent-consistency profile
- Multiplier tiers: 1.00x, 1.50x, 2.00x, and 2.50x at the accepted thresholds
- Any unprotected non-perfect week resets the accepted streak and multiplier
- Protected pauses freeze rather than reset consistency
- Valid PR: 5 raw RR, maximum two rewarded PRs per session under `rank-v5`
- Perfect-week reward: 25 RR and 25 lifetime XP
- Missed main session: -20 RR
- Missed specialization session: -15 RR
- Maximum confirmed swaps per week: 2
- Monthly free-swap grant: 2 credits
- Free-swap credits never expire and have no balance cap
- One free credit waives one swap's `5 RR` cost
- Free credits do not increase the weekly swap limit
- Penalties are never multiplied
- Daily rank decay is prohibited
- Unscheduled extra workouts and sets earn no RR

## Verified planned product facts

- Initial provisioned accounts: 2
- Public registration: excluded from MVP
- Users manage only their own routine drafts
- Published routine versions are immutable
- Routine edits apply to future weeks
- Mobile execution surface: Flutter
- Web routine-management surface: Flutter Web
- Backend and authentication: Supabase
- Passwords: managed by Supabase Auth, not stored in application tables
- Database isolation: RLS-protected user ownership
- Application workflow: proposed in `docs/product/APPLICATION_WORKFLOW.md`
- Implementation sequence: documented in `docs/context/IMPLEMENTATION_PLAN.md`

## Proposed product changes

`docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md` proposes:

- four-to-six workout days per week for MVP;
- user-specific immutable routine versions;
- fixed weekly daily-item RR pools of 110, 167, 220, and 277 across multiplier tiers;
- workout-day weight 4 and rest-day weight 1;
- lower RR for programmed rest items;
- equal perfect-week totals of 135, 192, 245, and 302 RR;
- a fixed 95 RR weekly missed-workout penalty pool;
- maximum two rewarded PRs per week;
- normalized failed-week threshold below 60% workout completion;
- proposed configurations `rank-v6` and `schedule-v3`.

These values are not accepted yet.

## Current blockers

Implementation remains blocked by:

1. product audit and acceptance or rejection of `rank-v6` and `schedule-v3`;
2. promotion of the proposed application workflow to accepted status;
3. local in-progress-workout persistence and offline-finalization decisions;
4. mobile release-target decision;
5. dashboard hosting decision;
6. production Supabase backup and operational-access decisions;
7. approval of the first bounded implementation task.

## Exact next action

Run a dedicated product-balance audit of `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md`.

The audit must either:

- accept and activate `rank-v6` and `schedule-v3`, then synchronize `RANK_SYSTEM.md` and `WEEKLY_SCHEDULING.md`; or
- reject the proposal and replace it with another mathematically verified equal-opportunity model.

No scaffolding or Supabase project creation is authorized before this gate passes.

## Do-not-touch boundaries

- Do not represent Phase 1 as started or complete.
- Do not scaffold application code yet.
- Do not create a Supabase project, schema, account, credential, or secret yet.
- Do not store passwords in application tables.
- Do not expose service-role or secret keys to public clients.
- Do not allow clients to set RR, XP, rank, penalties, wallet balances, milestones, or finalization totals.
- Do not silently activate proposed `rank-v6` or `schedule-v3` behavior.
- Do not silently change Adonis at `5,500 RR` or the 5/10/15 multiplier ladder.
- Do not increase the weekly two-swap limit through free credits.
- Do not expire or cap banked free-swap credits.
- Do not reward random extra workouts or extra sets.
- Do not introduce nutrition, sleep, social, payment, analytics, wearable, or medical-diagnosis features.
- Do not treat synthetic simulation as observed user data.

## Relevant sources

Accepted product baselines:

- `docs/product/HYPERTROPHY_ROUTINE.md`
- `docs/product/RANK_SYSTEM.md`
- `docs/product/WEEKLY_SCHEDULING.md`

Proposed planning documents:

- `docs/product/APPLICATION_WORKFLOW.md`
- `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md`
- `docs/context/IMPLEMENTATION_PLAN.md`

Accepted ADRs:

- `docs/decisions/ADR-0001-flutter-client-platforms.md`
- `docs/decisions/ADR-0002-supabase-backend-auth-and-persistence.md`
