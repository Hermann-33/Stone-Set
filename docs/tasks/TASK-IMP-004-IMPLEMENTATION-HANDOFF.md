# TASK-IMP-004 — External implementation handoff

Status: `IMPLEMENTED — FINAL CI RUNNING`

Phase 4 runtime was implemented directly on this branch to minimize Codex usage. Codex is not required unless final CI reveals a defect that cannot be repaired through the repository/GitHub workflow.

## Implemented

### Domain/data

- `TrainingWeek`, `TrainingWeekItem`, `FreeSwapWallet`, `WeeklySwap`, `WeekLoadResult`, `SwapResult`;
- `SchedulingRepository`;
- Supabase scheduling RPC adapter and decoder;
- public domain/data exports.

### Database

Migration:

```text
supabase/migrations/20260809172000_weekly_plans_swaps.sql
```

Provides:

- `training_weeks`;
- `training_week_items`;
- `free_swap_wallets`;
- `monthly_free_swap_grants`;
- `weekly_swaps`;
- lazy monthly two-credit grants;
- lazy current-week materialization;
- largest-remainder RR/base-XP allocations;
- stored missed-workout penalty allocations;
- owner-scoped read policies;
- `get_or_create_current_week_v1`;
- `confirm_weekly_swap_v1`.

Internal scheduled item dates use `assigned_date`; the Dart/JSON API remains `currentDate`.

### Android

- real `/week` screen;
- real Monday-Sunday schedule;
- workout/rest rendering;
- free-swap balance;
- remaining swaps;
- select-two-date swap preview;
- free-credit confirmation;
- no-routine/no-credit/error states;
- real `/` Home binds today/week/free-swap data;
- fixture rank/RR/XP/multiplier presentation remains unchanged until Phase 6;
- fixture Home preview routes remain fixture-only to avoid golden churn.

### Tests

Focused coverage exists for:

- week materialization/idempotency;
- allocation totals;
- monthly credit grant idempotency;
- free-credit swaps;
- weekly swap limit;
- date exchange;
- cross-user isolation;
- Dart repository decoding/error mapping;
- Week screen happy path/no-routine/no-credit;
- existing mobile shell regression with a fake scheduling repository.

## Explicitly deferred

- paid `5 RR` swaps;
- RR/XP award posting;
- missed-penalty application;
- consistency/rank finalization;
- cron/background pre-generation;
- workout-start/completion locks;
- protection/corrections;
- workout execution and offline sync.

These remain owned by later phases.

## Verification history

The first verification passes exposed two implementation-local issues and both were repaired without Codex:

1. PostgreSQL keyword collision on the original `current_date` column -> renamed internally to `assigned_date`;
2. generated-source/handwritten Dart formatting divergence -> canonicalized with the repository-pinned Flutter 3.44.7 / Dart 3.12.2 toolchain.

Generated route/provider files were restored from `build_runner`; only handwritten Phase 4 Dart sources were formatted. Temporary formatter/canonicalizer workflows self-removed and are not part of the final feature diff.

## Current action

This commit intentionally triggers ordinary path-sensitive Foundation CI on the canonicalized head. If that run passes, external orchestration will perform the final PR review, completion-doc update and merge without a Codex implementation pass.
