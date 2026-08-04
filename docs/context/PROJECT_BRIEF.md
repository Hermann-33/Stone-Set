# Stone Set Project Brief

Updated: 2026-08-04
Status: Planning

## Product purpose

Stone Set is a private muscle-growth training system for two initial users with independently managed routines and a shared, normalized rank economy.

It exists to make evidence-informed hypertrophy routines executable, trackable, adaptable, and motivating without rewarding random extra volume or allowing routine-frequency differences to create unequal rank opportunity.

## Initial users

- Initial provisioned accounts: 2.
- Public registration: excluded from MVP.
- Additional accounts may be supported later without redesign.
- Each user owns their routine, schedule, logs, rank state, wallet, and history.

## Current maturity

`PRE-IMPLEMENTATION`

Accepted product workflow, architecture, and implementation plan exist. There is still no application runtime, Flutter project, Supabase project, schema, account, deployment, CI, or test suite.

Phase 0 remains active until the remaining implementation constraints are closed.

## Accepted product outcomes

1. Each user can manage a private versioned routine through a Flutter Web dashboard.
2. Published routine versions are immutable and apply only to future unlocked weeks.
3. Supported MVP routines contain four through six workout days and at least one programmed rest day.
4. Every week contains seven dated plan items.
5. The Flutter mobile app executes workouts, logs sets, manages swaps, and shows rank and history.
6. Supabase Auth manages credentials; passwords are not stored in application tables.
7. Supabase Postgres and RLS isolate user-owned data.
8. All reward, penalty, wallet, and finalization transitions are server-authoritative.
9. All supported routine frequencies have the same maximum weekly RR opportunity.
10. Programmed rest receives less RR and XP than a workout item and requires no manual check-in.
11. Extra workouts and sets earn no RR or XP.
12. Rank history, routine history, swaps, corrections, and configuration versions remain auditable.

## Accepted rank baseline — `rank-v6`

- 20 ranks from Bronze I to Adonis.
- Adonis threshold: `5,500 RR`.
- Lifetime XP and current Rank Rating remain separate.
- Weekly daily-item RR pools: 110, 167, 220, and 277.
- Perfect-week bonus: 25 RR and 25 lifetime XP.
- Maximum no-PR weekly RR: 135, 192, 245, and 302.
- Weekly ordinary base-XP item pool: 110.
- Workout-item weight: 4.
- Rest-item weight: 1.
- Allocation uses largest remainder with earlier date as the deterministic tie-break.
- Weekly direct missed-workout penalty pool: 95 RR.
- Maximum rewarded PRs: 2 per week.
- Valid PR: 5 raw RR and 5 lifetime XP.
- Failed-week threshold: unprotected workout-completion ratio below 60%.
- Multiplier tiers: 1.00x, 1.50x, 2.00x, and 2.50x at Weeks 0, 5, 10, and 15.
- Any unprotected non-perfect week resets consistency.
- Protected full weeks freeze consistency.
- No daily rank decay.

## Accepted scheduling baseline — `schedule-v3`

- Monday-Sunday reward weeks in the configured timezone.
- User-owned routine drafts and immutable published versions.
- Future-week activation only.
- Seven materialized plan items with stored allocations.
- Any two distinct unlocked dates may exchange complete plan items.
- Maximum two confirmed swaps per week.
- Two free-swap credits granted monthly.
- Credits never expire and have no balance cap.
- One credit waives one swap's `5 RR` cost.
- Users may preserve credits and pay RR.
- Free credits never increase the weekly limit.
- Swaps move item identity, prescription, rewards, and penalties.
- Retroactive, started-item, resolved-item, and cross-week swaps are prohibited.

## Accepted workout baseline

The limited-equipment five-session hypertrophy routine in `docs/product/HYPERTROPHY_ROUTINE.md` remains the initial routine for the repository owner.

Its constraints remain:

- hard 60-minute session cap including warm-up;
- double progression;
- RIR-based effort control;
- controlled substitutions and adjustments;
- no medical diagnosis.

Other users may have different reward-eligible routines within the accepted four-to-six-day boundary.

## Accepted application workflow

`docs/product/APPLICATION_WORKFLOW.md` defines:

- account provisioning and sign-in;
- first-use setup;
- routine drafting and publication;
- weekly plan materialization;
- mobile schedule and rank presentation;
- swaps, payment choice, locks, and warnings;
- workout execution, timers, set logging, and recovery;
- rest-item finalization;
- daily and weekly rewards;
- progression recommendations;
- protected interruptions, corrections, and history.

## Accepted architecture

- Flutter mobile application.
- Separate Flutter Web dashboard.
- Shared Dart domain and data packages.
- Supabase Auth and Postgres.
- Row Level Security.
- Server-authoritative reward and wallet transitions.

Durable architecture decisions are recorded in ADR-0001 and ADR-0002.

## Current scope

- product and implementation planning;
- routine eligibility and anti-gaming definition;
- offline/local-draft behavior;
- mobile and dashboard release constraints;
- Supabase operational and backup constraints;
- bounded implementation task preparation.

## Explicit MVP non-goals

- public registration;
- social login;
- one ordinary user editing another user's routine;
- coach or organization accounts;
- nutrition or sleep tracking;
- social feeds, chat, leaderboards, or public profiles;
- payments or subscriptions;
- wearable integrations;
- automatic medical or injury decisions;
- rewards for unscheduled extra volume;
- microservices or unnecessary realtime infrastructure;
- historical recalculation using current formulas.

## Remaining product and operational facts to establish

1. Concrete minimum reward-eligibility rules for user-created routines.
2. Local in-progress workout storage and recovery behavior.
3. Offline submission and authoritative finalization behavior.
4. Initial mobile release targets.
5. Dashboard hosting target.
6. Production backup, recovery, and operator-access expectations.
7. First bounded implementation task packet.

## Discovery and planning completion criteria

Phase 0 completes only when:

- routine publication cannot reward empty or trivial prescriptions;
- offline and synchronization behavior is testable;
- release and hosting targets are explicit;
- Supabase operational boundaries are explicit;
- `TASK-IMP-001` has measurable acceptance criteria;
- no material ambiguity blocks the foundation implementation.

## Honest capability boundary

Stone Set currently consists only of repository documentation and decisions. It does not authenticate users, store routines, log workouts, calculate rewards, manage swaps, persist history, or deploy any client or backend.