import 'package:sqflite/sqflite.dart';

const int stoneSetMobileDatabaseVersion = 2;
const String stoneSetMobileDatabaseName = 'stone_set_workout.db';

const List<String> stoneSetWorkoutSchemaStatements = <String>[
  '''
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
  ''',
  '''
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
  ''',
  'create index if not exists workout_set_drafts_session_idx '
      'on workout_set_drafts(session_id)',
];

const List<String> stoneSetSnapshotSchemaStatements = <String>[
  '''
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
  ''',
  'create index if not exists mobile_snapshots_owner_generation_idx '
      'on mobile_snapshots(owner_id, generation_id)',
  '''
    create table if not exists mobile_sync_state (
      owner_id text primary key,
      generation_id text,
      last_successful_sync_at text,
      last_attempt_at text,
      last_error_code text,
      updated_at text not null
    )
  ''',
];

Future<Database> openStoneSetMobileDatabase() async {
  final base = await getDatabasesPath();
  return openDatabase(
    '$base/$stoneSetMobileDatabaseName',
    version: stoneSetMobileDatabaseVersion,
    onCreate: (db, version) async {
      await _executeStatements(db, stoneSetWorkoutSchemaStatements);
      await _executeStatements(db, stoneSetSnapshotSchemaStatements);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      await _executeStatements(
        db,
        stoneSetMobileMigrationStatements(
          oldVersion: oldVersion,
          newVersion: newVersion,
        ),
      );
    },
  );
}

List<String> stoneSetMobileMigrationStatements({
  required int oldVersion,
  required int newVersion,
}) {
  if (newVersion <= oldVersion) return const <String>[];
  final statements = <String>[];
  if (oldVersion < 2 && newVersion >= 2) {
    statements.addAll(stoneSetSnapshotSchemaStatements);
  }
  return List<String>.unmodifiable(statements);
}

Future<void> createWorkoutTables(DatabaseExecutor db) =>
    _executeStatements(db, stoneSetWorkoutSchemaStatements);

Future<void> createSnapshotTables(DatabaseExecutor db) =>
    _executeStatements(db, stoneSetSnapshotSchemaStatements);

Future<void> _executeStatements(
  DatabaseExecutor db,
  Iterable<String> statements,
) async {
  for (final statement in statements) {
    await db.execute(statement);
  }
}
