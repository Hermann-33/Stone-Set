import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:stone_set_domain/workouts.dart';

import '../../local/data/mobile_local_database.dart';
import 'workout_local_store.dart';

final class SqfliteWorkoutLocalStore implements WorkoutLocalStore {
  SqfliteWorkoutLocalStore({Future<Database> Function()? openDatabase})
    : _openDatabase = openDatabase ?? openStoneSetMobileDatabase;

  final Future<Database> Function() _openDatabase;
  Future<Database>? _database;

  Future<Database> get _db => _database ??= _openDatabase();

  @override
  Future<LocalWorkoutDraft?> loadActive(String userId) async => _load(await _db, userId);

  @override
  Future<void> saveStarted({
    required String userId,
    required WorkoutSession session,
  }) async {
    final db = await _db;
    await db.transaction((txn) async {
      final old = await txn.query(
        'active_workouts',
        columns: const <String>['session_id'],
        where: 'user_id = ?',
        whereArgs: <Object?>[userId],
        limit: 1,
      );
      if (old.isNotEmpty) {
        await txn.delete(
          'workout_set_drafts',
          where: 'session_id = ?',
          whereArgs: <Object?>[old.single['session_id']],
        );
      }
      await txn.insert('active_workouts', <String, Object?>{
        'user_id': userId,
        'plan_item_id': session.planItemId,
        'session_id': session.id,
        'server_payload_json': jsonEncode(_sessionPayload(session)),
        'client_revision': session.lastClientRevision,
        'last_synced_revision': session.lastClientRevision,
        'rest_end_at': null,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      for (final set in session.sets) {
        await txn.insert(
          'workout_set_drafts',
          _setRow(session.id, set),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<LocalWorkoutDraft> saveSet({
    required String userId,
    required WorkoutSetDraft set,
    DateTime? restEndAt,
    bool clearRestEndAt = false,
  }) async {
    final db = await _db;
    return db.transaction((txn) async {
      final active = await txn.query(
        'active_workouts',
        where: 'user_id = ?',
        whereArgs: <Object?>[userId],
        limit: 1,
      );
      if (active.isEmpty) {
        throw StateError('No active workout for user.');
      }
      final row = active.single;
      final revision = (row['client_revision']! as int) + 1;
      final sessionId = row['session_id']! as String;
      final now = DateTime.now().toUtc().toIso8601String();
      await txn.insert(
        'workout_set_drafts',
        _setRow(
          sessionId,
          set.copyWith(clientRevision: revision),
          updatedAt: now,
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final update = <String, Object?>{
        'client_revision': revision,
        'updated_at': now,
      };
      if (clearRestEndAt) {
        update['rest_end_at'] = null;
      } else if (restEndAt != null) {
        update['rest_end_at'] = restEndAt.toUtc().toIso8601String();
      }
      await txn.update(
        'active_workouts',
        update,
        where: 'user_id = ?',
        whereArgs: <Object?>[userId],
      );
      return (await _load(txn, userId))!;
    });
  }

  @override
  Future<void> markSynced({
    required String userId,
    required WorkoutSession session,
    required int syncedRevision,
  }) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update(
        'active_workouts',
        <String, Object?>{
          'server_payload_json': jsonEncode(_sessionPayload(session)),
          'last_synced_revision': syncedRevision,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'user_id = ? and session_id = ?',
        whereArgs: <Object?>[userId, session.id],
      );
      await txn.delete(
        'workout_set_drafts',
        where: 'session_id = ?',
        whereArgs: <Object?>[session.id],
      );
      for (final set in session.sets) {
        await txn.insert(
          'workout_set_drafts',
          _setRow(session.id, set),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> clear(String userId) async {
    final db = await _db;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'active_workouts',
        columns: const <String>['session_id'],
        where: 'user_id = ?',
        whereArgs: <Object?>[userId],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        await txn.delete(
          'workout_set_drafts',
          where: 'session_id = ?',
          whereArgs: <Object?>[rows.single['session_id']],
        );
      }
      await txn.delete(
        'active_workouts',
        where: 'user_id = ?',
        whereArgs: <Object?>[userId],
      );
    });
  }
}

Future<LocalWorkoutDraft?> _load(DatabaseExecutor db, String userId) async {
  final active = await db.query(
    'active_workouts',
    where: 'user_id = ?',
    whereArgs: <Object?>[userId],
    limit: 1,
  );
  if (active.isEmpty) return null;
  final row = active.single;
  final sessionId = row['session_id']! as String;
  final serverPayload = jsonDecode(row['server_payload_json']! as String);
  if (serverPayload is! Map<String, Object?>) {
    throw const FormatException('Invalid local workout session payload.');
  }
  final sets = await db.query(
    'workout_set_drafts',
    where: 'session_id = ?',
    whereArgs: <Object?>[sessionId],
    orderBy: 'session_exercise_id, set_index',
  );
  final decodedSets = sets.map(_decodeSet).toList(growable: false);
  final session = _decodeSession(serverPayload, decodedSets);
  return LocalWorkoutDraft(
    userId: userId,
    planItemId: row['plan_item_id']! as String,
    session: session,
    sets: decodedSets,
    clientRevision: row['client_revision']! as int,
    lastSyncedRevision: row['last_synced_revision']! as int,
    restEndAt: row['rest_end_at'] == null ? null : DateTime.parse(row['rest_end_at']! as String),
  );
}

Map<String, Object?> _setRow(
  String sessionId,
  WorkoutSetDraft set, {
  String? updatedAt,
}) => <String, Object?>{
  'session_id': sessionId,
  'session_exercise_id': set.sessionExerciseId,
  'set_index': set.setIndex,
  'load_value': set.loadValue,
  'load_unit': set.loadUnit,
  'repetitions': set.repetitions,
  'rir': set.rir,
  'completed': set.completed ? 1 : 0,
  'client_revision': set.clientRevision,
  'updated_at': updatedAt ?? DateTime.now().toUtc().toIso8601String(),
};

WorkoutSetDraft _decodeSet(Map<String, Object?> row) => WorkoutSetDraft(
  sessionExerciseId: row['session_exercise_id']! as String,
  setIndex: row['set_index']! as int,
  loadValue: (row['load_value'] as num?)?.toDouble(),
  loadUnit: row['load_unit']! as String,
  repetitions: row['repetitions'] as int?,
  rir: row['rir'] as int?,
  completed: row['completed'] == 1,
  clientRevision: row['client_revision']! as int,
);

Map<String, Object?> _sessionPayload(WorkoutSession session) => <String, Object?>{
  'id': session.id,
  'userId': session.userId,
  'planItemId': session.planItemId,
  'state': session.state.name,
  'startedAt': session.startedAt.toUtc().toIso8601String(),
  'lastClientRevision': session.lastClientRevision,
  'exercises': session.exercises
      .map(
        (exercise) => <String, Object?>{
          'id': exercise.id,
          'position': exercise.position,
          'exerciseDefinitionId': exercise.exerciseDefinitionId,
          'guidanceRevisionId': exercise.guidanceRevisionId,
          'title': exercise.title,
          'priority': exercise.priority,
          'workingSets': exercise.workingSets,
          'repMin': exercise.repMin,
          'repMax': exercise.repMax,
          'rirTarget': exercise.rirTarget,
          'restSeconds': exercise.restSeconds,
          'loadUnit': exercise.loadUnit,
          'notes': exercise.notes,
        },
      )
      .toList(growable: false),
};

WorkoutSession _decodeSession(
  Map<String, Object?> value,
  List<WorkoutSetDraft> sets,
) => WorkoutSession(
  id: value['id']! as String,
  userId: value['userId']! as String,
  planItemId: value['planItemId']! as String,
  state: WorkoutSessionState.values.byName(value['state']! as String),
  startedAt: DateTime.parse(value['startedAt']! as String),
  lastClientRevision: value['lastClientRevision']! as int,
  exercises: (value['exercises']! as List<Object?>).map((item) {
    final map = Map<String, Object?>.from(item! as Map<Object?, Object?>);
    return WorkoutExercise(
      id: map['id']! as String,
      position: map['position']! as int,
      exerciseDefinitionId: map['exerciseDefinitionId']! as String,
      guidanceRevisionId: map['guidanceRevisionId']! as String,
      title: map['title']! as String,
      priority: map['priority']! as bool,
      workingSets: map['workingSets']! as int,
      repMin: map['repMin']! as int,
      repMax: map['repMax']! as int,
      rirTarget: map['rirTarget']! as int,
      restSeconds: map['restSeconds']! as int,
      loadUnit: map['loadUnit']! as String,
      notes: map['notes'] as String? ?? '',
    );
  }),
  sets: sets,
);
