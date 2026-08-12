import 'package:sqflite/sqflite.dart';

const int stoneSetMobileDatabaseVersion = 2;
const String stoneSetMobileDatabaseName = 'stone_set_workout.db';

Future<Database> openStoneSetMobileDatabase() async {
  final base = await getDatabasesPath();
  return openDatabase(
    '$base/$stoneSetMobileDatabaseName',
    version: stoneSetMobileDatabaseVersion,
    onCreate: (db, version) async {
      await createWorkoutTables(db);
      await createSnapshotTables(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await createSnapshotTables(db);
      }
    },
  );
}

Future<void> createWorkoutTables(DatabaseExecutor db) async {
  await db.execute('''
    create table if not exists active_workouts (
      user_id text primary key,
      plan_item_id text not null,
      session_id text not null,
      server_payload_json text not null,
      client_revision integer not null,
      last_synced_revision integer not null,
      rest_end_at text,
      updated_at text not null
    )
  ''');
  await db.execute('''
    create table if not exists workout_set_drafts (
      session_id text not null,
      session_exercise_id text not null,
      set_index integer not null,
      load_value real,
      load_unit text not null,
      repetitions integer,
      rir integer,
      completed integer not null,
      client_revision integer not null,
      updated_at text not null,
      primary key (session_exercise_id, set_index)
    )
  ''');
  await db.execute(
    'create index if not exists workout_set_drafts_session_idx '
    'on workout_set_drafts(session_id)',
  );
}

Future<void> createSnapshotTables(DatabaseExecutor db) async {
  await db.execute('''
    create table if not exists mobile_snapshots (
      owner_id text not null,
      snapshot_key text not null,
      schema_version integer not null,
      payload_json text not null,
      server_updated_at text,
      cached_at text not null,
      generation_id text not null,
      primary key (owner_id, snapshot_key)
    )
  ''');
  await db.execute(
    'create index if not exists mobile_snapshots_owner_generation_idx '
    'on mobile_snapshots(owner_id, generation_id)',
  );
  await db.execute('''
    create table if not exists mobile_sync_state (
      owner_id text primary key,
      generation_id text,
      last_successful_sync_at text,
      last_attempt_at text,
      last_error_code text,
      updated_at text not null
    )
  ''');
}
