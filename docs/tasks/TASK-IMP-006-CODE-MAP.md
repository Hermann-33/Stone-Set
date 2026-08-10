# TASK-IMP-006 — Exact implementation map

Mode: `FAST PRIVATE TWO-USER MVP`

This file exists so a fallback coding agent does not rediscover the repository.

## Already implemented on the branch

### Domain

```text
packages/domain/lib/src/progress/progress_models.dart
packages/domain/lib/src/progress/progress_repository.dart
packages/domain/lib/src/progress/progress.dart
packages/domain/lib/progress.dart
packages/domain/lib/stone_set_domain.dart
```

### Data

```text
packages/data/lib/src/progress/progress_remote_service.dart
packages/data/lib/src/progress/supabase_progress_repository.dart
packages/data/lib/src/progress/progress.dart
packages/data/lib/progress.dart
packages/data/lib/stone_set_data.dart
```

### Server

```text
supabase/migrations/20260810120000_rank_progress.sql
supabase/migrations/20260810120500_rank_progress_paid_swap_fix.sql
supabase/tests/database/rank_progress.test.sql
```

### Mobile

```text
apps/mobile/lib/features/progress/providers/progress_providers.dart
apps/mobile/lib/features/progress/views/progress_screen.dart
apps/mobile/lib/features/home/controllers/home_controller.dart
apps/mobile/lib/features/home/data/live_home_schedule_mapper.dart
apps/mobile/lib/features/week/views/week_screen.dart
apps/mobile/lib/app/router/mobile_routes.dart
```

### Tests/fakes

```text
packages/data/test/progress/supabase_progress_repository_test.dart
packages/data/test/scheduling/supabase_scheduling_repository_test.dart
apps/mobile/test/support/fake_progress_repository.dart
apps/mobile/test/progress_screen_test.dart
apps/mobile/test/mobile_shell_home_test.dart
```

## Server JSON contract

`get_progress_v1()` returns:

```text
account
  userId
  rrBalance
  lifetimeXp
  rankId
  currentMinimum
  nextRankId
  nextMinimum
  progress

ranks[]
  id
  displayName
  minimumRr

transactions[]
  id
  kind
  sourceType
  sourceId
  delta
  createdAt

workouts[]
  resultId
  planItemId
  date
  status
  plannedSets
  completedSets
  submittedAt
```

Do not change this contract unless CI proves it is necessary.

## Existing systems reused

```text
Phase 4 allocations:
training_week_items.allocated_rr
training_week_items.allocated_base_xp
training_week_items.allocated_missed_penalty_rr

Phase 5A completion:
workout_sessions
workout_results

Free wallet:
free_swap_wallets
monthly_free_swap_grants

Rank assets/thresholds:
packages/ui/lib/src/rank/stone_set_rank_asset.dart
```

## Paid-swap strategy

Do not rewrite the Phase 4 swap validator.

`confirm_weekly_swap_v2`:

```text
free credit available
  -> call confirm_weekly_swap_v1 directly

no free credit
  -> refresh RR account
  -> require 5 RR
  -> temporarily make one internal free credit available
  -> call proven confirm_weekly_swap_v1
  -> restore free-wallet counters
  -> mark the inserted weekly_swaps row payment_method=rr
  -> append -5 RR ledger entry
  -> refresh rank account
  -> return the original swap/week shape with corrected wallet
```

This keeps all existing week/date/lock/two-swap validation in one place.

## If CI fails

Fix only the reported defect.

Likely areas:

```text
SQL parser/pgTAP shape
Dart strict lints/format
existing mobile tests needing progress provider override
Progress widget asset staging
```

Do not redesign scoring.
Do not add cron.
Do not add streaks, multipliers, decay, milestones, charts or 005B.
