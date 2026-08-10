# TASK-IMP-005A — Workout logger, SQLite autosave and simple offline sync

Status: `APPROVED — EXECUTABLE AFTER TASK-IMP-004 MERGES`
Mode: `FAST PRIVATE TWO-USER MVP`

## Objective

Implement the smallest real Android workout flow that is useful for the two Stone Set users:

```text
current workout day
  -> start while online
  -> immutable server session/prescription snapshot
  -> log load/reps/RIR sets
  -> in-app rest timer
  -> transactional SQLite autosave
  -> continue after network loss/app restart
  -> reconnect and sync latest local snapshot
  -> submit
  -> simple completed/partial result
```

This is not a production/public synchronization system. Optimize for a reliable single-device happy path, not distributed-system completeness.

## Dependency

`TASK-IMP-004` must merge first. The implementation branch is intentionally based on the current Phase 4 candidate so work may proceed while PR #20 CI finishes.

## Existing Phase 4 inputs

Use:

- `public.training_weeks`;
- `public.training_week_items`;
- `public.routine_version_days`;
- `public.routine_version_prescriptions`;
- current Android Home/Week scheduling providers.

A workout can start only from an assigned workout item for today. Starting locks that plan item.

## Deliberate simplifications

Do **not** implement these in 005A:

- WorkManager/background retry;
- multi-device conflict resolution;
- event-by-event server outbox history;
- continuous connectivity monitoring;
- offline workout start;
- background rest notifications/sounds;
- workout guidance/media playback (005B);
- RR/XP/rank/wallet mutation (006);
- PR/progression calculation (006/007);
- corrections/protection;
- sophisticated session expiry/quarantine UX;
- production security/threat-model work;
- API 24 performance profiling;
- golden matrices.

Keep existing auth/private-data boundaries but add no new enterprise hardening.

## Server schema

Add one migration after Phase 4 with only:

### `workout_sessions`

Minimum fields:

```text
id uuid PK
user_id
weekly_plan_item_id unique
state active|submitted
started_at
submitted_at nullable
prescription_snapshot jsonb
last_client_revision bigint default 0
created_at
updated_at
```

### `workout_session_exercises`

Immutable snapshot rows:

```text
id
session_id
user_id
position
exercise_definition_id
guidance_revision_id
priority
working_sets
rep_min
rep_max
rir_target
rest_seconds
load_unit
notes
```

Unique `(session_id, position)`.

### `workout_set_entries`

Server copy of the latest client set state:

```text
id
session_id
session_exercise_id
user_id
set_index
load_value nullable
load_unit
repetitions nullable
rir nullable
completed boolean
client_revision
updated_at
```

Unique `(session_exercise_id, set_index)`.

### `workout_results`

Simple immutable submission result:

```text
id
session_id unique
user_id
status completed|partial
planned_sets
completed_sets
submitted_at
```

No reward transactions in this task.

## RPCs

Implement only:

```text
start_workout_v1(plan_item_id uuid)
sync_workout_v1(session_id uuid, client_revision bigint, sets jsonb)
submit_workout_v1(session_id uuid, client_revision bigint, sets jsonb)
```

### `start_workout_v1`

Rules:

- authenticated owner only;
- item must be `workout`;
- item assigned date must be the user's current local date;
- existing session for the same item is returned instead of duplicated;
- create the session and immutable exercise snapshot from the pinned routine version day/prescriptions;
- set Phase 4 item `lock_state='locked'`;
- return complete logger payload.

No offline start.

### `sync_workout_v1`

This is intentionally a **whole-current-snapshot** sync, not an event stream.

Input contains every currently known set row for the session.

Rules:

- owner/session must match;
- submitted session rejects mutation;
- `client_revision <= last_client_revision` returns current session state without duplicating work;
- validate exercise/set identity against session snapshot;
- upsert the latest set values;
- update `last_client_revision`;
- return current logger payload.

This is sufficient for one active device per user.

### `submit_workout_v1`

- perform the same final set synchronization transactionally;
- require at least one completed set;
- `completed` when all planned working sets are completed;
- otherwise `partial`;
- set session state to submitted;
- create one immutable result;
- duplicate submit returns existing result;
- return result payload.

## Domain/data

Add a small workout vertical:

```text
WorkoutSession
WorkoutExercise
WorkoutSetDraft
WorkoutResult
WorkoutLoadResult
WorkoutFailure
WorkoutRepository
```

Repository methods:

```text
startWorkout(planItemId)
syncWorkout(sessionId, clientRevision, sets)
submitWorkout(sessionId, clientRevision, sets)
```

Use the existing Supabase service/repository style. No extra use-case layer unless actually necessary.

## Local SQLite

Use `sqflite 2.4.3` (Flutter/Dart 3.12 compatible).

Create one private mobile DB, version 1.

Keep it deliberately small:

### `active_workouts`

```text
user_id
plan_item_id
session_id
server_payload_json
client_revision
last_synced_revision
rest_end_at nullable
updated_at
```

One active workout per user is sufficient for this private MVP.

### `workout_set_drafts`

```text
session_id
session_exercise_id
set_index
load_value nullable
load_unit
repetitions nullable
rir nullable
completed integer
updated_at
```

Unique `(session_exercise_id, set_index)`.

Every set edit must save the set row and increment `active_workouts.client_revision` in one SQLite transaction.

No separate event/outbox table is required. `client_revision > last_synced_revision` is the pending-sync marker.

## Offline behavior

- starting requires successful server RPC;
- after start, all editing reads/writes local SQLite first;
- network failure does not block logging;
- app restart restores the active local workout for the same user;
- explicit Sync and Submit try the server;
- opening/foregrounding the logger may make one best-effort sync attempt;
- failed sync leaves local data untouched and shows `Pending sync`;
- successful sync updates `last_synced_revision`;
- no polling or background worker.

## Android routes/UI

Add a real workout route such as:

```text
/workout/:planItemId
```

The screen/coordinator first checks local SQLite for that user's active session/plan item. If absent, it starts online.

### Home

For the real Home route only, today's workout action must open the real workout route. Fixture routes remain fixture-only.

Add the Phase 4 plan-item ID to real `TodayPlanItemViewData` mapping; do not redesign Home.

### Week

For today's workout item, expose a small `Start workout` / `Continue workout` action while keeping existing swap selection behavior.

Do not allow rest items to start workouts.

### Logger

One practical screen is enough:

- workout title/status;
- ordered exercises;
- target sets/reps/RIR/rest;
- one row per planned working set;
- editable load;
- editable reps;
- editable RIR;
- complete/uncomplete set;
- previous/best may show `—` in 005A;
- automatic in-app rest countdown after completing a set;
- `Pending sync` / `Synced` indicator;
- `Sync` button;
- `Finish workout` button;
- simple completed/partial result state.

Do not build guidance/media in the logger yet.

## Rest timer

Use a normal Dart timer plus stored `rest_end_at` timestamp.

- completing a set starts/restarts timer using that exercise's `rest_seconds`;
- app foreground/rebuild calculates remaining duration from timestamp;
- no Android notification/background service in this task.

## Minimum tests

### Database

Focused tests only:

- today's workout starts;
- rest/future/cross-user item start fails;
- duplicate start returns same session;
- exercise/set snapshot count matches routine prescription;
- sync upserts set values and is revision-idempotent;
- submit completed path;
- submit partial path;
- duplicate submit returns existing result.

### Dart/data

Only decoder/repository happy path + common error mapping.

### Mobile

Only:

- local autosave/restore abstraction;
- logger renders exercises/sets;
- editing a set persists and marks pending;
- offline edit remains usable after sync failure;
- successful sync clears pending state;
- submit shows result;
- Home/Week workout action opens real logger.

No golden/performance/security matrix.

## Completion standard

`TASK-IMP-005A` is complete when this manual journey works:

```text
login
-> today's workout
-> start online
-> enter first sets
-> simulate network failure
-> continue editing
-> recreate/reopen logger
-> local data restores
-> network returns
-> Sync succeeds
-> Finish workout
-> completed/partial result appears
```

## Explicit next task

`TASK-IMP-005B` — pinned guidance/private image/YouTube playback inside the logger without losing workout state.
