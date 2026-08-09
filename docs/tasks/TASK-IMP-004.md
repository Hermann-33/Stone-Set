# TASK-IMP-004 — Implement real weekly plans, swaps and free-swap credits

Status: `APPROVED — EXECUTABLE`

Mode: `FAST PRIVATE TWO-USER MVP`

## Objective

Replace the Android fixture Week/Home scheduling data with a real server-backed Monday-Sunday plan built from the published routine version.

The minimum working flow is:

```text
published routine version
  -> current week is created lazily
  -> exactly 7 dated items appear on Android
  -> Home shows today's real item
  -> Week shows the real week
  -> user can swap two unlocked dates
  -> one free-swap credit pays for the swap
  -> monthly free-swap credits are granted lazily
```

This is a private app for two known users. Optimize for working functionality and speed. Preserve existing Auth/RLS/private-data boundaries, but do not add production-grade scheduling infrastructure, cron hardening, exhaustive reward security, broad audit systems, or large test matrices.

## Required branch

```text
codex/task-imp-004-weekly-plans-swaps
```

Do not work on `main`. Do not create another planning task or ADR.

## Verified baseline

```text
TASK-IMP-003A — COMPLETE AND MERGED
TASK-IMP-003B — COMPLETE AND MERGED (PR #16)
TASK-IMP-003C — COMPLETE AND MERGED (PR #18)
003C merge commit — d1997c8e9ef306301806001f6540a1d9ba3314dc
003C final-head CI — 31314739913 PASS
```

The repository already has published routine versions with exactly seven days and ordered prescriptions.

## Important simplifications for Phase 4

The accepted product documents remain useful background, but this fast packet intentionally implements only what is needed before workouts and rank authority exist.

### Implement now

- one real Monday-Sunday week per user/week;
- exactly seven plan items copied from the effective published routine version;
- item type and prescription/version identity pinned at materialization;
- stored RR/base-XP/missed-penalty allocations using the already accepted `rank-v6` largest-remainder formulas;
- monthly free-swap wallet and lazy two-credit grant;
- maximum two confirmed swaps per week;
- swap two distinct unlocked dates;
- payment with one free-swap credit;
- Android Home/Week binding to real plan data;
- basic swap preview/confirm UI;
- obvious date locking and same-week restrictions.

### Explicitly defer

- paid `5 RR` swap payment until `TASK-IMP-006` creates authoritative rank RR;
- weekly reward finalization;
- RR/XP ledger posting;
- missed-workout penalty application;
- consistency/streak evaluation;
- PR rewards;
- protection/corrections;
- workout start/completion locks beyond simple date/state fields;
- cron/pg_cron scheduling;
- background week pre-generation;
- complex recovery warnings;
- production operational hardening.

The UI may show `RR payment coming with rank system` when no free credit is available. Do not invent a temporary rank balance.

## Database scope

Create one new migration after the merged 003C migration.

### `training_weeks`

Minimum fields:

```text
id
user_id
routine_version_id
week_start
week_end
reward_timezone
rank_config_version = 'rank-v6'
schedule_config_version = 'schedule-v3'
confirmed_swap_count default 0
created_at
```

Unique `(user_id, week_start)`.

### `training_week_items`

Minimum fields:

```text
id
week_id
user_id
original_day_index
original_date
current_date
item_type
routine_version_day_id
allocated_rr
allocated_base_xp
allocated_missed_penalty_rr
lock_state
created_at
```

Exactly seven distinct items per materialized week.

Allocations stay attached to item identity when dates are swapped.

### `free_swap_wallets`

Minimum fields:

```text
user_id
balance
lifetime_granted
lifetime_consumed
updated_at
```

### `monthly_free_swap_grants`

Minimum fields:

```text
id
user_id
grant_month
quantity = 2
created_at
```

Unique `(user_id, grant_month)`.

### `weekly_swaps`

Minimum fields:

```text
id
week_id
user_id
swap_number
first_item_id
second_item_id
first_date
second_date
payment_method = 'free_credit'
created_at
```

No correction/void system in 004.

## Lazy week materialization

Do not build cron.

Use a single authenticated RPC/repository operation such as:

```text
get_or_create_current_week()
```

On Home/Week load it should:

1. resolve the user's reward timezone;
2. determine the current Monday-Sunday week;
3. lazily grant this calendar month's two free-swap credits if not already granted;
4. return the existing week if present;
5. otherwise choose the published routine version effective for this week;
6. create the week and seven items atomically;
7. calculate and store RR/base-XP/missed-penalty allocations;
8. return the week, ordered current schedule and free-swap balance.

A retry must not create duplicate weeks or duplicate monthly grants.

If there is no effective published routine version, return a simple `no_published_routine` state for the UI.

## Allocation formulas

Use the accepted simple formulas already in `RANK_SYSTEM.md`.

Weights:

```text
workout = 4
rest = 1
```

For both daily RR pool and base XP pool, allocate integers using largest remainder and earlier calendar date as tie-break.

For 004 use the 1.00x weekly daily-item pool:

```text
RR pool = 110
base XP pool = 110
```

Do not implement consistency multipliers yet. `TASK-IMP-006` will own authoritative multiplier/rank finalization.

Missed-workout penalty pool:

```text
95 RR across workout items only
```

Store these values only. Do not apply awards or penalties in 004.

Reference sanity checks:

```text
4 workout days: RR/base XP workout 23/23/23/23, rests 6/6/6
5 workout days: workouts 20 each, rests 5/5
6 workout days: workouts 18/18/18/18/17/17, rest 4
```

Use date-order tie-break for the remainder.

## Locking — simple MVP

An item is swappable only when:

```text
current_date is today or future in reward timezone
lock_state == 'open'
week is current week
```

Past dates are treated as locked when the week is loaded or swap is attempted.

Future workout start/completion locks belong to 005A. Weekly finalization locks belong to 006.

## Swap behavior

Implement a narrow server mutation:

```text
preview_swap(weekId, firstItemId, secondItemId)
confirm_swap(weekId, firstItemId, secondItemId)
```

For speed, preview may also be computed client-side from current authoritative week data, but confirmation must re-check server state.

Confirmation rules:

- same user;
- same current week;
- two distinct items;
- both unlocked;
- not a no-op same-content exchange when practical to detect;
- confirmed swap count < 2;
- free-swap balance >= 1;
- atomically exchange `current_date` values;
- decrement one free credit;
- increment confirmed swap count;
- write one `weekly_swaps` row;
- return updated week and wallet balance.

If balance is zero, return `free_swap_unavailable`. Do not implement RR payment in this task.

## RLS / grants — minimum

Keep the existing private-owner style:

- authenticated user can read own week/items/wallet/grants/swaps;
- no direct client mutation of counters, dates, allocations or balances;
- mutations go through narrow RPCs;
- other user cannot read or mutate the first user's weekly data.

No large permission matrix or new threat model is required.

## Shared Dart/data scope

Add the minimum immutable models/repository methods for:

```text
TrainingWeek
TrainingWeekItem
FreeSwapWallet
WeeklySwap
WeekLoadResult
SwapResult
```

Repository operations:

```text
getOrCreateCurrentWeek()
confirmSwap(...)
```

No Flutter/Supabase imports in domain.

## Android scope

Replace fixture Week data with real repository-backed data.

### Home

Use real current week for:

- today's workout/rest item;
- seven-day strip;
- basic loading/error/no-routine state;
- free-swap balance where already displayed.

Keep the existing fixture rank/XP/multiplier presentation until 006.

### Week

Show:

- Monday-Sunday items;
- workout/rest;
- routine day title if available;
- current date assignment;
- locked/unlocked state;
- stored RR/base-XP allocation as informational values if already designed;
- remaining swaps;
- free-swap balance.

### Swap UI

Keep it basic:

```text
select first day
select second day
show before/after order
show `Use 1 free swap credit`
confirm
refresh week
```

No drag-and-drop required.

When no credit is available, disable confirmation and state that RR payment is deferred to the rank phase.

Do not implement workout execution.

## Dashboard

No new dashboard scheduling UI is required for 004.

Only add shared compile-safe contracts if necessary.

## Testing — minimal

During development run targeted tests only.

### Database

Required cases:

1. current week materializes exactly once;
2. exactly seven items are created;
3. 4/5/6-day allocation sums equal 110 RR, 110 XP and 95 missed-penalty pool;
4. monthly grant is idempotent and grants two credits;
5. valid swap exchanges dates and consumes one credit;
6. third swap fails;
7. zero-credit swap fails;
8. past/locked item swap fails;
9. other user cannot access/mutate the week.

### Dart/data

Only test model decoding, week load, successful swap and common error mapping.

### Android

Only test:

- real Week rendering;
- Home today/week binding;
- successful swap UI;
- no-routine state;
- no-credit state.

Do not create new goldens unless an existing repository check absolutely requires one.

## Verification policy

Codex should perform only basic development sanity checks:

```text
generation if generated files changed
format changed Dart files
analyze affected packages/app
run focused 004 tests
```

Do not run broad final verification, API 24 profiling, full CI, security review, documentation review or merge. Those are handled outside the coding run.

## Documentation

The planning/status documentation has already been prepared outside Codex. Codex should not rewrite broad docs.

Do not edit unless compilation/repository checks require it:

```text
README.md
AGENTS.md
docs/context/ACTIVE_CONTEXT.md
docs/context/ROADMAP.md
docs/context/HANDOFF.md
docs/context/ARCHITECTURE.md
docs/context/IMPLEMENTATION_PLAN.md
docs/context/UI_IMPLEMENTATION_PLAN.md
security docs
```

Codex may update only `docs/tasks/TASK-IMP-004.md` with a short implementation result if necessary.

## Git handoff

Codex's responsibility ends after coding and pushing.

```text
branch: codex/task-imp-004-weekly-plans-swaps
commit messages contain TASK-IMP-004
push branch to origin
```

Do not create or merge the PR unless specifically needed to expose the pushed branch. Final PR creation, CI inspection, docs/result updates and merge are handled outside Codex.

## Completion handoff from Codex

Return only:

```text
Coding verdict: READY FOR EXTERNAL VERIFICATION | BLOCKED
Branch:
Head commit:
Files changed:
Migration:
Week materialization:
Allocations:
Monthly credits:
Swap RPC:
Android Home:
Android Week:
Focused tests run:
Known limitations:
```

Do not start TASK-IMP-005A.
