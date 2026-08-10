import 'package:stone_set_domain/workouts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'workout_remote_service.dart';

final class SupabaseWorkoutRepository implements WorkoutRepository {
  const SupabaseWorkoutRepository({required WorkoutRemoteService remote}) : _remote = remote;

  final WorkoutRemoteService _remote;

  @override
  Future<WorkoutLoadResult> startWorkout({required String planItemId}) => _guard(() async {
    final value = await _remote.call('start_workout_v1', <String, Object?>{
      'p_plan_item_id': planItemId,
    });
    return _load(value);
  });

  @override
  Future<WorkoutLoadResult> syncWorkout({
    required String sessionId,
    required int clientRevision,
    required List<WorkoutSetDraft> sets,
  }) => _guard(() async {
    final value = await _remote.call('sync_workout_v1', <String, Object?>{
      'p_session_id': sessionId,
      'p_client_revision': clientRevision,
      'p_sets': sets.map(_setPayload).toList(growable: false),
    });
    return _load(value);
  });

  @override
  Future<WorkoutLoadResult> submitWorkout({
    required String sessionId,
    required int clientRevision,
    required List<WorkoutSetDraft> sets,
  }) => _guard(() async {
    final value = await _remote.call('submit_workout_v1', <String, Object?>{
      'p_session_id': sessionId,
      'p_client_revision': clientRevision,
      'p_sets': sets.map(_setPayload).toList(growable: false),
    });
    return _load(value);
  });
}

Map<String, Object?> _setPayload(WorkoutSetDraft value) => <String, Object?>{
  'sessionExerciseId': value.sessionExerciseId,
  'setIndex': value.setIndex,
  'loadValue': value.loadValue,
  'loadUnit': value.loadUnit,
  'repetitions': value.repetitions,
  'rir': value.rir,
  'completed': value.completed,
};

Future<T> _guard<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on WorkoutFailure {
    rethrow;
  } on PostgrestException catch (error) {
    final code = error.message.isNotEmpty ? error.message : (error.code ?? 'server_error');
    throw WorkoutFailure(code);
  }
}

WorkoutLoadResult _load(Map<String, Object?> value) => WorkoutLoadResult(
  session: _session(_requiredMap(value, 'session')),
  result: value['result'] == null ? null : _result(_requiredMap(value, 'result')),
);

WorkoutSession _session(Map<String, Object?> value) => WorkoutSession(
  id: _requiredString(value, 'id'),
  userId: _requiredString(value, 'userId'),
  planItemId: _requiredString(value, 'planItemId'),
  state: switch (_requiredString(value, 'state')) {
    'active' => WorkoutSessionState.active,
    'submitted' => WorkoutSessionState.submitted,
    _ => throw const FormatException('Unknown workout session state.'),
  },
  startedAt: DateTime.parse(_requiredString(value, 'startedAt')),
  lastClientRevision: _requiredInt(value, 'lastClientRevision'),
  exercises: _requiredList(
    value,
    'exercises',
  ).map((item) => _exercise(_map(item))),
  sets: _requiredList(value, 'sets').map((item) => _set(_map(item))),
);

WorkoutExercise _exercise(Map<String, Object?> value) => WorkoutExercise(
  id: _requiredString(value, 'id'),
  position: _requiredInt(value, 'position'),
  exerciseDefinitionId: _requiredString(value, 'exerciseDefinitionId'),
  guidanceRevisionId: _requiredString(value, 'guidanceRevisionId'),
  title: _requiredString(value, 'title'),
  priority: _requiredBool(value, 'priority'),
  workingSets: _requiredInt(value, 'workingSets'),
  repMin: _requiredInt(value, 'repMin'),
  repMax: _requiredInt(value, 'repMax'),
  rirTarget: _requiredInt(value, 'rirTarget'),
  restSeconds: _requiredInt(value, 'restSeconds'),
  loadUnit: _requiredString(value, 'loadUnit'),
  notes: value['notes'] as String? ?? '',
);

WorkoutSetDraft _set(Map<String, Object?> value) => WorkoutSetDraft(
  sessionExerciseId: _requiredString(value, 'sessionExerciseId'),
  setIndex: _requiredInt(value, 'setIndex'),
  loadValue: _optionalDouble(value['loadValue']),
  loadUnit: _requiredString(value, 'loadUnit'),
  repetitions: _optionalInt(value['repetitions']),
  rir: _optionalInt(value['rir']),
  completed: _requiredBool(value, 'completed'),
  clientRevision: _requiredInt(value, 'clientRevision'),
);

WorkoutResult _result(Map<String, Object?> value) => WorkoutResult(
  id: _requiredString(value, 'id'),
  sessionId: _requiredString(value, 'sessionId'),
  status: switch (_requiredString(value, 'status')) {
    'completed' => WorkoutResultStatus.completed,
    'partial' => WorkoutResultStatus.partial,
    _ => throw const FormatException('Unknown workout result status.'),
  },
  plannedSets: _requiredInt(value, 'plannedSets'),
  completedSets: _requiredInt(value, 'completedSets'),
  submittedAt: DateTime.parse(_requiredString(value, 'submittedAt')),
);

Map<String, Object?> _requiredMap(Map<String, Object?> value, String key) => _map(value[key]);

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) {
    throw const FormatException('Expected object.');
  }
  return <String, Object?>{
    for (final entry in value.entries)
      if (entry.key is String) entry.key! as String: entry.value,
  };
}

List<Object?> _requiredList(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! List<Object?>) throw FormatException('Expected $key list.');
  return item;
}

String _requiredString(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! String || item.isEmpty) {
    throw FormatException('Expected $key string.');
  }
  return item;
}

int _requiredInt(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! int) throw FormatException('Expected $key integer.');
  return item;
}

bool _requiredBool(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! bool) throw FormatException('Expected $key boolean.');
  return item;
}

int? _optionalInt(Object? value) => value == null
    ? null
    : value is int
    ? value
    : throw const FormatException('Expected nullable integer.');

double? _optionalDouble(Object? value) => value == null
    ? null
    : value is num
    ? value.toDouble()
    : throw const FormatException('Expected nullable number.');
