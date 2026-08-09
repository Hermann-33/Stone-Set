# TASK-IMP-004 — exact code map

Purpose: remove repository-discovery work from the implementation run. This is an implementation aid, not a new scope document. `TASK-IMP-004.md` remains authoritative.

## Existing code already verified

### Published routine source

The merged 003C schema already provides:

- `public.routine_versions`
  - `id`
  - `user_id`
  - `effective_date`
  - `version_number`
  - `name`
  - immutable publication identity
- `public.routine_version_days`
  - `id`
  - `routine_version_id`
  - `user_id`
  - `day_index` 1..7
  - `day_type` = workout/rest
  - `title`
  - `purpose`
  - `position`
- `public.routine_version_prescriptions`
  - immutable prescription rows tied to `routine_version_day_id`

Do not duplicate routine version/day/prescription content into new scheduling-domain master tables. Phase 4 week items should pin the version/day identity and use the existing routine version rows as the source.

Relevant migration:

`supabase/migrations/20260809120509_routine_review_publication.sql`

### Existing Dart routine patterns

Use these as the direct repository/service pattern:

- `packages/domain/lib/src/routines/routine_models.dart`
- `packages/domain/lib/src/routines/routine_repository.dart`
- `packages/domain/lib/routines.dart`
- `packages/domain/lib/stone_set_domain.dart`
- `packages/data/lib/src/routines/routine_remote_service.dart`
- `packages/data/lib/src/routines/supabase_routine_repository.dart`
- `packages/data/lib/routines.dart`
- `packages/data/lib/stone_set_data.dart`

Do not invent a new networking/repository convention.

### Existing mobile Supabase provider pattern

Reuse `supabaseClientProvider` from:

`apps/mobile/lib/features/identity/providers/identity_providers.dart`

That provider already exposes `Supabase.instance.client` and is the correct client source. Do not initialize another Supabase client.

### Existing Home structure

Current fixture-oriented files:

- `apps/mobile/lib/features/home/controllers/home_controller.dart`
- `apps/mobile/lib/features/home/data/home_repository.dart`
- `apps/mobile/lib/features/home/models/home_view_models.dart`
- `apps/mobile/lib/features/home/views/home_screen.dart`
- `apps/mobile/lib/features/home/views/compact_week_strip.dart`
- `apps/mobile/lib/features/home/views/today_plan_card.dart`

Important: do **not** rewrite the fixture rank system. Keep the existing fixture-produced `HomeRankViewData` and rank/XP/multiplier metrics until TASK-IMP-006.

The fastest integration is to let `homeControllerProvider` combine:

1. the existing fixture `HomeRepository.load(...)` result for rank/remaining fixture metrics; and
2. the new scheduling repository current-week result for `today`, `week`, and free-swap display.

Construct a final `HomeViewData` from those two sources. Do not delete the fixture gallery/scenario support; fixture preview routes can keep fixture-only behavior if needed.

### Current Week route

`apps/mobile/lib/app/router/mobile_routes.dart`

`MobileWeekRoute` currently returns `MobileDestinationPlaceholder`. Replace only that route body with the new real `WeekScreen` and import it. Regenerate typed routes only if the source change requires generation; the route path itself does not need to change.

## Preferred new file layout

Use these paths unless an existing adjacent convention makes one obviously unnecessary.

### Domain

- `packages/domain/lib/scheduling.dart`
- `packages/domain/lib/src/scheduling/scheduling.dart`
- `packages/domain/lib/src/scheduling/scheduling_models.dart`
- `packages/domain/lib/src/scheduling/scheduling_repository.dart`
- export from `packages/domain/lib/stone_set_domain.dart`

Minimum public types:

- `TrainingWeek`
- `TrainingWeekItem`
- `FreeSwapWallet`
- `WeeklySwap`
- `WeekLoadResult`
- `SwapResult`
- `SchedulingFailure`
- `SchedulingRepository`

`SchedulingRepository` only needs:

```dart
Future<WeekLoadResult> getOrCreateCurrentWeek();
Future<SwapResult> confirmSwap({
  required String weekId,
  required String firstItemId,
  required String secondItemId,
});
```

No extra domain service layer.

### Data

- `packages/data/lib/scheduling.dart`
- `packages/data/lib/src/scheduling/scheduling.dart`
- `packages/data/lib/src/scheduling/scheduling_remote_service.dart`
- `packages/data/lib/src/scheduling/supabase_scheduling_repository.dart`
- export from `packages/data/lib/stone_set_data.dart`

Follow the same small RPC wrapper / error mapping style as the routine repository. Do not create general HTTP abstractions.

RPC names should be stable and versioned:

- `get_or_create_current_week_v1`
- `confirm_weekly_swap_v1`

Client-side preview can be pure Dart from the loaded `TrainingWeek`; no preview RPC is required.

### Mobile scheduling providers

Add:

- `apps/mobile/lib/features/week/providers/week_providers.dart`
- generated provider file only if Riverpod annotation is used

`SchedulingRepository` provider should instantiate `SupabaseSchedulingRepository` using the existing `supabaseClientProvider`.

Add a family/autoDispose current-week provider only if helpful; keep provider count small.

### Mobile Week UI

Add only the minimal feature files:

- `apps/mobile/lib/features/week/controllers/week_controller.dart` (optional if provider can own the two small mutations)
- `apps/mobile/lib/features/week/views/week_screen.dart`

Avoid a deep Week model/presentation hierarchy unless needed to compile cleanly.

Week screen can render the domain/data values directly through a small local mapper because this is a private two-user MVP.

Required screen states only:

- loading
- error/retry
- no published routine
- loaded week
- swap selection/confirmation
- no free credit

### Home integration

Prefer modifying only:

- `apps/mobile/lib/features/home/controllers/home_controller.dart`
- `apps/mobile/lib/features/home/models/home_view_models.dart` only if a small additional field/copy helper is needed
- `apps/mobile/lib/features/home/views/home_screen.dart` only for wording/actions needed by real schedule data

Do not replace Home's rank hero or existing visual primitives.

## Database implementation shortcut

Use one migration after `20260809120509_routine_review_publication.sql`.

The fastest server design is two narrow authenticated RPCs plus owner-readable tables. Keep direct mutation revoked.

`get_or_create_current_week_v1` can perform all of the following in one transaction/function:

- identify `auth.uid()` via the existing product-actor helper pattern;
- resolve `profiles.reward_timezone`;
- calculate current local date and Monday week start;
- insert monthly grant with `on conflict do nothing`;
- upsert/create wallet row and increment only when a new grant row was actually inserted;
- find existing `training_weeks` row and return it if present;
- select latest owned `routine_versions` where `effective_date <= week_start`, ordered by effective date/version descending;
- if missing, return `{state: 'no_published_routine', ...}`;
- insert `training_weeks` with unique `(user_id, week_start)`;
- insert seven `training_week_items` from `routine_version_days` ordered by `day_index`;
- store allocation integers;
- return week/items/wallet as one JSON object.

For the two-user MVP, concurrency can rely primarily on unique constraints + row locking inside the RPC; no separate operation ledger/idempotency table is required for this phase.

`confirm_weekly_swap_v1` should lock:

- the week row;
- wallet row;
- both item rows;

Then validate and atomically swap `current_date` values, decrement one credit, increment swap count and insert one `weekly_swaps` row.

## Allocation helper shortcut

Implement largest-remainder allocation once in SQL as a small private helper or inline CTE. It only needs weights 4/1 and date order.

Store:

- RR pool 110 across all seven items;
- base XP pool 110 across all seven items;
- missed penalty pool 95 across workout items only; rest items receive 0 missed penalty.

Do not create multiplier or finalization infrastructure.

## Exact mobile fixture behavior to preserve

`HomeRepository` currently has:

```dart
Future<HomeViewData> load(HomeFixtureScenario scenario);
```

Do not remove the fixture scenario parameter because fixture preview screens/tests use it. Instead, merge real scheduling only for the normal authenticated Home path. If the scenario is not `HomeFixtureScenario.standard`, retaining the old fixture-only output is acceptable and is the lowest-risk approach.

`HomeScreen` currently obtains the authenticated `userId` from `mobileSessionControllerProvider`; continue using that existing identity state.

## Suggested minimum test file map

Database:

- `supabase/tests/database/weekly_plans_swaps.test.sql`

Domain/data:

- `packages/domain/test/scheduling/scheduling_models_test.dart`
- `packages/data/test/scheduling/supabase_scheduling_repository_test.dart`

Mobile:

- `apps/mobile/test/week_screen_test.dart`
- extend `apps/mobile/test/mobile_shell_home_test.dart` only for real Home scheduling binding, or add one small scheduling-specific Home test if that is cleaner.

Do not touch existing golden files.

## Files that should normally remain untouched

- dashboard feature implementation
- 003A/003B/003C migrations
- rank UI implementation
- rank assets/goldens
- workout fixture routes other than Home's current-day mapping
- README and broad architecture/security documents
- GitHub workflow unless compilation genuinely requires a trivial path-classifier adjustment

## End state before handoff

The branch only needs to contain working Phase 4 code and focused tests. External orchestration will create the PR, inspect full diff, run/inspect CI, update canonical completion docs and merge.