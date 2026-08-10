# TASK-IMP-007 — Implementation Code Map

Use this map to avoid broad repository exploration.

## Server / database

### Existing routine prescription authority

- `supabase/migrations/20260809120509_routine_review_publication.sql`
  - `routine_version_prescriptions`
  - working sets / rep range / RIR / load unit
  - original exercise + pinned guidance identity

### Existing workout execution authority

- `supabase/migrations/20260810100000_workout_execution.sql`
  - `workout_sessions`
  - `workout_session_exercises`
  - `workout_set_entries`
  - `workout_results`
  - `start_workout_v1`
  - `sync_workout_v1`
  - `submit_workout_v1`

`start_workout_v1` is the only existing workout RPC expected to need replacement in 007 so preferred substitutions can be resolved at session creation.

### Existing RR / XP authority

- `supabase/migrations/20260810120000_rank_progress.sql`
- `supabase/migrations/20260810120500_rank_progress_paid_swap_fix.sql`
  - `rank_accounts`
  - `rr_ledger`
  - `xp_ledger`
  - `private.refresh_progress_for_user`
  - `get_progress_v1`

007 should extend these ledgers for `manual_correction`; do not create a second balance system.

### New 007 migration

Create one migration after the current 006 migrations. It should own:

- `exercise_progression_settings`
- `progress_corrections`
- recommendation payload/helper functions
- setting/correction/reversal RPCs
- ledger constraint extension for `manual_correction`
- replacement `start_workout_v1` for preferred substitution

Do not modify historical migrations.

## Domain package

Create:

```text
packages/domain/lib/progression.dart
packages/domain/lib/src/progression/progression.dart
packages/domain/lib/src/progression/progression_models.dart
packages/domain/lib/src/progression/progression_repository.dart
```

Update:

```text
packages/domain/lib/stone_set_domain.dart
```

Keep models small:

- `ProgressionRecommendation`
- `ProgressionSetting`
- `SubstituteExerciseOption`
- `ProgressCorrection`
- `ProgressionSnapshot`
- repository mutation contracts

## Data package

Create:

```text
packages/data/lib/progression.dart
packages/data/lib/src/progression/progression.dart
packages/data/lib/src/progression/progression_remote_service.dart
packages/data/lib/src/progression/supabase_progression_repository.dart
```

Update:

```text
packages/data/lib/stone_set_data.dart
```

Use RPCs only. Do not add direct client table mutations.

Focused decoder test:

```text
packages/data/test/progression/supabase_progression_repository_test.dart
```

## Mobile

Reuse the existing Progress branch instead of adding navigation.

Primary files:

```text
apps/mobile/lib/features/progress/providers/progress_providers.dart
apps/mobile/lib/features/progress/views/progress_screen.dart
```

Add only if separation materially improves readability:

```text
apps/mobile/lib/features/progress/providers/progression_providers.dart
apps/mobile/lib/features/progress/views/progression_section.dart
apps/mobile/lib/features/progress/views/correction_dialog.dart
```

Tests:

```text
apps/mobile/test/progress_screen_test.dart
apps/mobile/test/support/fake_progression_repository.dart
```

Do not add a new top-level route.

## Workout runtime regression points

Because `start_workout_v1` may substitute the effective exercise, review but do not redesign:

```text
packages/domain/lib/src/workouts/workout_models.dart
packages/data/lib/src/workouts/supabase_workout_repository.dart
apps/mobile/lib/features/workout/controllers/workout_controller.dart
apps/mobile/lib/features/workout/views/workout_screen.dart
```

A substitution should be transparent to the logger because the session snapshot already supplies exercise title/guidance/load-unit fields.

Only change Dart workout models if the real RPC response shape must change. Prefer keeping the existing shape unchanged.

## Database tests

Create:

```text
supabase/tests/database/progression_corrections.test.sql
```

Focus on recommendation states, substitution at workout start, correction/reversal exactness, idempotency and owner isolation.

## Avoid touching

Unless CI proves it necessary:

- dashboard files;
- router/generated route files;
- media/storage code;
- SQLite schema;
- scheduling/week tables;
- rank presentation assets;
- CI workflows;
- broad security/performance/golden suites.

## Preferred implementation order

```text
1. migration + pgTAP
2. domain contracts
3. Supabase data adapter
4. mobile providers
5. Progress UI
6. focused Dart/mobile tests
7. Foundation CI
8. patch only demonstrated failures
9. completion evidence + merge
```
