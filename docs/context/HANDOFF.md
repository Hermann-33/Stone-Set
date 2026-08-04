# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-PL-001 — Define two-user architecture, application workflow, and implementation plan`

## Starting state

- Phase 0 was active.
- Phase 1 had not started.
- The repository contained documentation only.
- `rank-v5` and `schedule-v2` assumed one fixed five-session routine.
- No application architecture or ADR was accepted.
- No application workflow or implementation plan existed.
- Technology stack, authentication, persistence, and dashboard decisions were unset.
- The new request introduced two users, separate routines, Flutter, Supabase, a web dashboard, and equal weekly RR opportunity across different routines.

## Conflict found

The request stated that Phase 1 was complete. Repository authority showed that Phase 1 had not started and remained blocked by Phase 0.

The requested daily reward change also conflicts with accepted baselines:

- `rank-v5` awards by main or specialization session;
- `rank-v5` caps PR rewards per session;
- `rank-v5` gives programmed rest days zero RR;
- `schedule-v2` assumes five workout sessions and two rest days;
- missed penalties are tied to main and specialization session types.

The change is therefore a new rank and scheduling configuration, not a minor patch.

## Completed work

### Accepted architecture

- accepted Flutter for the mobile application;
- accepted a separate Flutter Web dashboard;
- accepted shared Dart domain and data packages;
- accepted hosted Supabase Auth and Postgres;
- accepted Row Level Security as the user-data isolation boundary;
- rejected application-table password storage;
- required passwords to remain inside Supabase Auth;
- required public clients to use publishable credentials only;
- required reward and wallet transitions to remain server-authoritative;
- recorded decisions in `ADR-0001` and `ADR-0002`.

### Planned product workflow

Created `docs/product/APPLICATION_WORKFLOW.md` covering:

- account provisioning and sign-in;
- first-use setup;
- routine drafting, validation, publication, and history;
- weekly plan materialization;
- mobile home and schedule presentation;
- swap preview, payment, locking, and correction behavior;
- workout execution, timers, set entry, synchronization, and completion;
- rest-day behavior;
- daily awards;
- weekly finalization;
- progression recommendations;
- protected interruptions and corrections;
- history and MVP boundaries.

The workflow remains proposed until the variable-routine reward model is accepted.

### Proposed `rank-v6` and `schedule-v3`

Created `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md` with:

- four-to-six workout days per week for MVP;
- immutable user-owned routine versions;
- future-week routine activation;
- fixed weekly daily-item RR pools of 110, 167, 220, and 277;
- workout-day weight 4 and rest-day weight 1;
- lower programmed-rest RR;
- exact perfect-week totals of 135, 192, 245, and 302 RR;
- largest-remainder integer allocation;
- a fixed 95 RR weekly missed-workout penalty pool;
- weekly two-PR cap;
- normalized failed-week threshold below 60% workout completion;
- anti-gaming and historical-version rules.

A 50,000-user preliminary synthetic check for each supported routine frequency produced:

| Workout days | Mean weeks to Adonis | Median |
|---:|---:|---:|
| 4 | 42.87 | 43 |
| 5 | 42.00 | 42 |
| 6 | 41.41 | 42 |

Maximum weekly opportunity is exactly equal. The remaining mean spread is approximately 1.46 weeks due to discrete completion counts. A dedicated balance task must decide whether that variance is acceptable.

### Implementation plan

Created `docs/context/IMPLEMENTATION_PLAN.md` with the planned sequence:

1. decision closure;
2. Flutter and Supabase foundation;
3. authentication, profiles, and RLS;
4. routine drafting and publication;
5. weekly plan and reward allocation;
6. mobile workout execution;
7. swaps, wallet, rank, and weekly finalization;
8. progression, protection, and corrections;
9. release hardening.

No implementation was performed.

### Context synchronization

Updated:

- `README.md`;
- `docs/context/ACTIVE_CONTEXT.md`;
- `docs/context/PROJECT_BRIEF.md`;
- `docs/context/ARCHITECTURE.md`;
- `docs/context/CODEBASE_MAP.md`;
- `docs/context/ROADMAP.md`;
- `docs/context/HANDOFF.md`;
- `docs/decisions/README.md`.

## Current accepted baselines

| Area | Current authoritative state |
|---|---|
| Workout routine | Accepted five-session baseline |
| Rank | `rank-v5` |
| Scheduling | `schedule-v2` |
| Highest rank | Adonis at `5,500 RR` |
| Multiplier | 1.00x, 1.50x, 2.00x, 2.50x at accepted thresholds |
| Weekly swaps | Maximum 2 |
| Monthly free swaps | 2 credits, non-expiring, uncapped |
| Mobile client | Flutter planning architecture accepted |
| Web dashboard | Flutter Web planning architecture accepted |
| Backend | Supabase planning architecture accepted |
| Authentication | Supabase Auth planning architecture accepted |
| Password storage | No application-table password storage |
| Implementation | Not started |

## Proposed but not accepted

- `rank-v6`;
- `schedule-v3`;
- rest-day RR;
- variable routine frequency;
- normalized daily reward pools;
- normalized missed-penalty pool;
- weekly PR cap;
- normalized failed-week threshold;
- the application workflow's activation status.

## Verification performed

- re-read repository authority and mandatory context;
- rechecked `main` and recent commits;
- confirmed no accepted ADR existed before the task;
- checked current official Flutter architecture guidance;
- checked current Supabase password-authentication, user-data, RLS, and breaking-change guidance;
- verified that no plaintext-password design was introduced;
- verified that clients cannot authoritatively submit score totals;
- verified exact weekly pool sums for four-, five-, and six-day routines;
- ran deterministic 50,000-user preliminary simulations for each supported routine frequency;
- preserved `rank-v5`, `schedule-v2`, Adonis at `5,500 RR`, the multiplier ladder, swap limit, and free-credit rules;
- introduced no code, project, schema, credentials, deployment, or runtime claim.

## Repository and branch

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`
- Task commits: multiple documentation commits prefixed with `TASK-PL-001`

## Known risks

- Equal weekly RR ceiling does not prove equal physical effort across different routines.
- User-controlled routine editing creates reward-gaming pressure and requires strict publication validation.
- The proposed four-to-six-day boundary may not match both actual user routines.
- Cross-routine calibration still has approximately 1.46 weeks of synthetic mean variance.
- Flutter Web accessibility, keyboard behavior, and performance require explicit testing.
- RLS errors can create cross-user exposure if policies are weak.
- Complex database functions can bypass RLS if privileged carelessly.
- Offline in-progress workout persistence remains undecided.
- Dashboard hosting, mobile release scope, production backup, and operational access remain undecided.
- No real user data exists for balance validation.

## Exact next action

Create and execute a dedicated product task:

`TASK-PD-008 — Audit and finalize multi-user routine normalization`

It must:

1. validate the actual workout-day counts for both initial users;
2. accept or revise the four-to-six-day boundary;
3. accept or revise the workout-to-rest weight;
4. accept or revise the weekly RR and missed-penalty pools;
5. define acceptable cross-routine variance;
6. confirm rest-day award semantics;
7. confirm the weekly PR cap;
8. accept and activate `rank-v6` and `schedule-v3`, or reject the proposal;
9. synchronize `RANK_SYSTEM.md`, `WEEKLY_SCHEDULING.md`, workflow, context, and audit history;
10. produce the first implementation task only after the product gate passes.

## Do-not-touch boundaries

- no Flutter scaffolding yet;
- no Supabase project or schema yet;
- no credentials or accounts yet;
- no application-table password storage;
- no service-role or secret key in public clients;
- no client-authored RR or wallet totals;
- no silent activation of `rank-v6` or `schedule-v3`;
- no silent change to Adonis at `5,500 RR` or the 5/10/15 multiplier ladder;
- no increase to the two-swap weekly limit through free credits;
- no expiry or cap on free-swap credits;
- no reward for unscheduled extra workouts or extra sets;
- no nutrition, sleep, public social, payment, wearable, analytics, or medical-diagnosis expansion.

## Verdict

`PARTIAL`

The architecture and implementation plan are documented and the technology decisions are accepted. Implementation remains correctly blocked because the requested variable-routine daily-RR system changes accepted product economics and has not yet passed its dedicated activation audit.
