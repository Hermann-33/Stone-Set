# TASK-IMP-004 — Prebuilt implementation handoff

This file exists only to minimize Codex work on the remaining Phase 4 implementation.

## Already written on the implementation branch

### Domain

- `packages/domain/lib/src/scheduling/scheduling_models.dart`
- `packages/domain/lib/src/scheduling/scheduling_repository.dart`
- scheduling exports

Models/contracts already defined:

```text
TrainingWeek
TrainingWeekItem
FreeSwapWallet
WeeklySwap
WeekLoadResult
SwapResult
SchedulingFailure
SchedulingRepository
```

Do not redesign them unless CI proves a concrete defect.

### Data/Supabase adapter

- `packages/data/lib/src/scheduling/scheduling_remote_service.dart`
- `packages/data/lib/src/scheduling/supabase_scheduling_repository.dart`
- scheduling exports

RPC names are already fixed:

```text
get_or_create_current_week_v1
confirm_weekly_swap_v1
```

The Dart decoder defines the exact JSON field names the SQL should return.

### Mobile

Already written:

- scheduling repository/current-week providers;
- `WeekScreen` with loading/no-routine/error states;
- seven-item rendering;
- free-swap balance and remaining-swap chips;
- two-item selection;
- swap preview;
- free-credit confirmation;
- `/week` route wiring;
- live Week -> Home mapping;
- Home controller live scheduling merge while preserving rank/XP fixture data;
- test fake scheduling repository.

Do not redesign Home or Week. Fix only concrete compile/runtime defects.

### Database

Already drafted:

- `supabase/migrations/20260809172000_weekly_plans_swaps.sql`

It contains:

```text
training_weeks
training_week_items
free_swap_wallets
monthly_free_swap_grants
weekly_swaps
lazy monthly grant helper
largest-remainder materialization helper
week/wallet JSON payload helpers
get_or_create_current_week_v1
confirm_weekly_swap_v1
minimum owner-select RLS/grants
```

The SQL is a senior-engineer draft and may need syntax or harness corrections after actual reset/pgTAP execution. Do not replace it wholesale unless necessary.

### Tests

Already written:

- `supabase/tests/database/weekly_plans_swaps.test.sql`
- `packages/data/test/scheduling/supabase_scheduling_repository_test.dart`
- `apps/mobile/test/week_screen_test.dart`
- existing `mobile_shell_home_test.dart` updated with scheduling fake

## Exact JSON contract expected from `get_or_create_current_week_v1`

Ready:

```json
{
  "status": "ready",
  "week": {
    "id": "uuid",
    "userId": "uuid",
    "routineVersionId": "uuid",
    "weekStart": "YYYY-MM-DD",
    "weekEnd": "YYYY-MM-DD",
    "rewardTimezone": "IANA timezone",
    "rankConfigVersion": "rank-v6",
    "scheduleConfigVersion": "schedule-v3",
    "confirmedSwapCount": 0,
    "items": [
      {
        "id": "uuid",
        "weekId": "uuid",
        "routineVersionDayId": "uuid",
        "originalDayIndex": 1,
        "originalDate": "YYYY-MM-DD",
        "currentDate": "YYYY-MM-DD",
        "itemType": "workout|rest",
        "title": "string",
        "purpose": "string|null",
        "allocatedRr": 20,
        "allocatedBaseXp": 20,
        "allocatedMissedPenaltyRr": 19,
        "lockState": "open|locked",
        "isToday": false
      }
    ]
  },
  "wallet": {
    "userId": "uuid",
    "balance": 2,
    "lifetimeGranted": 2,
    "lifetimeConsumed": 0
  }
}
```

No published routine:

```json
{
  "status": "no_published_routine",
  "wallet": {
    "userId": "uuid",
    "balance": 2,
    "lifetimeGranted": 2,
    "lifetimeConsumed": 0
  }
}
```

## Exact JSON contract expected from `confirm_weekly_swap_v1`

```json
{
  "week": { "...": "same week shape above" },
  "wallet": { "...": "same wallet shape above" },
  "swap": {
    "id": "uuid",
    "weekId": "uuid",
    "userId": "uuid",
    "swapNumber": 1,
    "firstItemId": "uuid",
    "secondItemId": "uuid",
    "firstDate": "YYYY-MM-DD",
    "secondDate": "YYYY-MM-DD",
    "createdAt": "timestamp"
  }
}
```

## Remaining Codex work

Codex should do only the following:

1. pull this branch;
2. run formatting/analyzer/focused tests;
3. run Supabase reset/pgTAP if Docker is available;
4. fix compile, SQL, generated-route, or test failures found by those runs;
5. add only missing focused test coverage if a concrete gap blocks confidence;
6. commit fixes under `TASK-IMP-004`;
7. push the branch;
8. stop.

Do not:

- redesign the schema;
- redesign Home/Week;
- add paid RR swaps;
- add cron;
- add rank finalization;
- add broad docs;
- create another PR;
- merge PR #20;
- start 005A.

External orchestration owns final CI review, documentation completion and merge.
