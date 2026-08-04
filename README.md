# Stone Set

Stone Set is a private two-user muscle-growth training system currently in product, architecture, and implementation planning.

The repository is authoritative for product rules, architecture, implementation state, verification evidence, and handoff context. Chat history is not authoritative.

## Current state

- Active phase: Phase 0 — product discovery, architecture, and implementation planning
- Implementation: not started
- Mobile client: Flutter accepted, not created
- Web dashboard: Flutter Web accepted, not created
- Backend: Supabase Auth and Postgres accepted, not created
- Authentication: two provisioned initial users; public registration excluded from MVP
- Passwords: managed by Supabase Auth, never stored in application tables
- Data isolation: Row Level Security required
- Reward authority: backend only

## Accepted product baselines

### Workout

- Initial owner routine: limited-equipment five-session hypertrophy routine
- Hard session cap: 60 minutes including warm-up
- Progression: repetitions first, then load

### Multi-user routines

- Users manage only their own routine drafts
- Published versions are immutable
- Routine edits apply only to future unlocked weeks
- Supported MVP frequency: 4-6 workout days and at least 1 rest day
- Every week contains 7 materialized plan items

### Rank — `rank-v6`

- 20 ranks from Bronze I to Adonis
- Adonis: `5,500 RR`
- Weekly daily-item RR pools: 110, 167, 220, 277
- Perfect-week bonus: 25 RR and 25 lifetime XP
- Workout/rest allocation weights: 4:1
- Weekly ordinary base-XP item pool: 110
- Weekly direct missed-workout penalty pool: 95 RR
- Maximum rewarded PRs: 2 per week
- Multiplier ladder: 1.00x, 1.50x, 2.00x, 2.50x at Weeks 0, 5, 10, 15
- Any unprotected non-perfect week resets consistency
- Failed week: unprotected workout-completion ratio below 60%
- No daily decay
- No RR or XP for unscheduled extra workouts or sets

### Scheduling — `schedule-v3`

- Maximum 2 confirmed swaps per week
- Any two distinct unlocked dates may exchange complete plan items
- 2 free-swap credits granted monthly
- Credits never expire and have no balance cap
- One credit waives one swap's `5 RR` cost
- Users may preserve credits and pay RR
- Credits never increase the weekly swap limit
- Swaps move prescription identity and stored allocations
- Retroactive and cross-week swaps are prohibited

## Accepted workflow

`docs/product/APPLICATION_WORKFLOW.md` defines the complete mobile, dashboard, and backend workflow.

## Accepted architecture decisions

- `docs/decisions/ADR-0001-flutter-client-platforms.md`
- `docs/decisions/ADR-0002-supabase-backend-auth-and-persistence.md`

## Start here

1. Use [`docs/context/NEW_CHAT_BOOTSTRAP.md`](docs/context/NEW_CHAT_BOOTSTRAP.md) for a new conversation.
2. Read [`AGENTS.md`](AGENTS.md).
3. Read the mandatory files under [`docs/context/`](docs/context/).
4. Read the accepted product baselines:
   - [`docs/product/HYPERTROPHY_ROUTINE.md`](docs/product/HYPERTROPHY_ROUTINE.md)
   - [`docs/product/RANK_SYSTEM.md`](docs/product/RANK_SYSTEM.md)
   - [`docs/product/WEEKLY_SCHEDULING.md`](docs/product/WEEKLY_SCHEDULING.md)
   - [`docs/product/APPLICATION_WORKFLOW.md`](docs/product/APPLICATION_WORKFLOW.md)
5. Read accepted decisions under [`docs/decisions/`](docs/decisions/).

## Exact next action

Run:

`TASK-PL-002 — Close implementation constraints and authorize the foundation task`

Implementation remains blocked until reward-eligible routine validation, offline/local persistence, release targets, dashboard hosting, Supabase operations, and the bounded `TASK-IMP-001` packet are accepted.