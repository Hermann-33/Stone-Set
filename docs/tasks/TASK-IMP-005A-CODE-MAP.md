# TASK-IMP-005A — Exact code map

This file exists to minimize any future Codex investigation. Follow these paths unless CI proves a concrete reason to differ.

## Server

Create:

```text
supabase/migrations/20260810100000_workout_execution.sql
supabase/tests/database/workout_execution.test.sql
```

Consume existing:

```text
public.training_weeks
public.training_week_items
public.routine_version_days
public.routine_version_prescriptions
public.profiles.reward_timezone
```

RPCs are fixed:

```text
start_workout_v1
sync_workout_v1
submit_workout_v1
```

Return camelCase JSON matching the Dart decoder.

## Domain

Create:

```text
packages/domain/lib/src/workouts/workout_models.dart
packages/domain/lib/src/workouts/workout_repository.dart
packages/domain/lib/src/workouts/workouts.dart
packages/domain/lib/workouts.dart
```

Update only exports:

```text
packages/domain/lib/stone_set_domain.dart
```

Do not put Flutter/Supabase/SQLite in domain.

## Remote data

Create:

```text
packages/data/lib/src/workouts/workout_remote_service.dart
packages/data/lib/src/workouts/supabase_workout_repository.dart
packages/data/lib/src/workouts/workouts.dart
packages/data/lib/workouts.dart
packages/data/test/workouts/supabase_workout_repository_test.dart
```

Update only exports:

```text
packages/data/lib/stone_set_data.dart
```

Copy the simple RPC/decode structure from:

```text
packages/data/lib/src/scheduling/
packages/data/lib/src/routines/
```

## Mobile dependency

Update:

```text
apps/mobile/pubspec.yaml
pubspec.lock
```

Add exact dependency:

```yaml
sqflite: 2.4.3
```

No connectivity or WorkManager dependency is needed.

## Mobile local store

Create:

```text
apps/mobile/lib/features/workout/data/workout_local_store.dart
apps/mobile/lib/features/workout/data/sqflite_workout_local_store.dart
```

The rest of the app should depend on `WorkoutLocalStore`, not raw sqflite APIs.

The local store owns only:

```text
active_workouts
workout_set_drafts
```

Use JSON for the immutable server session payload to avoid duplicating the entire server snapshot schema locally.

## Mobile controller/providers

Create:

```text
apps/mobile/lib/features/workout/providers/workout_providers.dart
apps/mobile/lib/features/workout/controllers/workout_controller.dart
```

The controller coordinates:

```text
remote WorkoutRepository
+ local WorkoutLocalStore
+ current authenticated user
```

Required operations:

```text
loadOrStart(planItemId)
editSet(...)
toggleSetComplete(...)
sync()
submit()
```

Do not add another global framework.

## Mobile UI

Create:

```text
apps/mobile/lib/features/workout/views/workout_screen.dart
```

Modify:

```text
apps/mobile/lib/app/router/mobile_routes.dart
apps/mobile/lib/features/home/models/home_view_models.dart
apps/mobile/lib/features/home/data/live_home_schedule_mapper.dart
apps/mobile/lib/features/home/views/home_screen.dart
apps/mobile/lib/features/week/views/week_screen.dart
```

### Home integration

Add an optional source plan item ID to today's real mapped item. Fixture data may leave it null.

For real Home only:

```text
TodayPlanItemAction.start|continueWorkout
+ sourcePlanItemId
-> real /workout/:planItemId route
```

Fixture Home keeps `MobileFixtureWorkoutRoute`.

### Week integration

Do not reuse the card tap because card tap is already swap selection.

For today's open/locked workout item, add a compact explicit button/action:

```text
Start workout
```

Once the server session exists, the same route safely resumes from local/duplicate server start.

## Mobile tests

Create:

```text
apps/mobile/test/workout/workout_controller_test.dart
apps/mobile/test/workout/workout_screen_test.dart
apps/mobile/test/support/fake_workout_repository.dart
apps/mobile/test/support/fake_workout_local_store.dart
```

Update only existing Home/Week tests if the new route/action requires it.

## Minimal server payload shape

`start_workout_v1` / `sync_workout_v1` return:

```json
{
  "session": {
    "id": "uuid",
    "userId": "uuid",
    "planItemId": "uuid",
    "state": "active",
    "startedAt": "timestamp",
    "lastClientRevision": 0,
    "exercises": [
      {
        "id": "uuid",
        "position": 1,
        "exerciseDefinitionId": "uuid",
        "guidanceRevisionId": "uuid",
        "title": "Exercise name",
        "priority": true,
        "workingSets": 3,
        "repMin": 8,
        "repMax": 12,
        "rirTarget": 2,
        "restSeconds": 90,
        "loadUnit": "kg",
        "notes": ""
      }
    ],
    "sets": [
      {
        "sessionExerciseId": "uuid",
        "setIndex": 1,
        "loadValue": null,
        "loadUnit": "kg",
        "repetitions": null,
        "rir": null,
        "completed": false,
        "clientRevision": 0
      }
    ]
  }
}
```

`submit_workout_v1` returns:

```json
{
  "session": { "...": "same session payload with state submitted" },
  "result": {
    "id": "uuid",
    "sessionId": "uuid",
    "status": "completed|partial",
    "plannedSets": 12,
    "completedSets": 12,
    "submittedAt": "timestamp"
  }
}
```

## Local state simplification

There is no event stream. Each local edit increments `clientRevision` and the entire current set snapshot is sent on sync.

Pending state is:

```text
clientRevision > lastSyncedRevision
```

This is intentional for the two-user/single-device MVP.

## Files to avoid

Do not touch unless a compile failure requires it:

```text
apps/dashboard/**
packages/ui/**
rank assets
security docs
CI path classifier
003A/003B/003C migrations
004 migration
```
