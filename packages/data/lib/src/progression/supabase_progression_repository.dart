import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_domain/progression.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'progression_remote_service.dart';

final class SupabaseProgressionRepository implements ProgressionRepository {
  const SupabaseProgressionRepository(this._remote);

  final ProgressionRemoteService _remote;

  @override
  Future<ProgressionSnapshot> getProgression() async =>
      _guard(() async => _snapshot(await _remote.getProgression()));

  @override
  Future<ProgressionSnapshot> updateSetting({
    required String exerciseId,
    required bool progressionProtected,
    required bool painFlagged,
    required String note,
    String? preferredSubstituteExerciseId,
    double? manualNextLoad,
  }) async => _guard(
    () async => _snapshot(
      await _remote.updateSetting(<String, Object?>{
        'p_exercise_definition_id': exerciseId,
        'p_progression_protected': progressionProtected,
        'p_pain_flagged': painFlagged,
        'p_preferred_substitute_exercise_id': preferredSubstituteExerciseId,
        'p_manual_next_load': manualNextLoad,
        'p_note': note,
      }),
    ),
  );

  @override
  Future<ProgressCorrectionResult> applyCorrection({
    required ProgressCorrectionKind kind,
    required int delta,
    required String reason,
  }) async => _guard(
    () async => _correctionResult(
      await _remote.applyCorrection(<String, Object?>{
        'p_kind': kind.name,
        'p_delta': delta,
        'p_reason': reason,
      }),
    ),
  );

  @override
  Future<ProgressCorrectionResult> reverseCorrection({
    required String correctionId,
    required String reason,
  }) async => _guard(
    () async => _correctionResult(
      await _remote.reverseCorrection(<String, Object?>{
        'p_correction_id': correctionId,
        'p_reason': reason,
      }),
    ),
  );
}

Future<T> _guard<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on ProgressionFailure {
    rethrow;
  } on PostgrestException catch (error) {
    throw ProgressionFailure(
      error.message.isNotEmpty ? error.message : (error.code ?? 'server_error'),
    );
  }
}

ProgressionSnapshot _snapshot(Map<String, Object?> value) =>
    ProgressionSnapshot(
      recommendations: _list(
        value['recommendations'],
      ).map((item) => _recommendation(_map(item))).toList(growable: false),
      substituteOptions: _list(
        value['substituteOptions'],
      ).map((item) => _substitute(_map(item))).toList(growable: false),
      corrections: _list(
        value['corrections'],
      ).map((item) => _correction(_map(item))).toList(growable: false),
    );

ProgressionRecommendation _recommendation(Map<String, Object?> value) =>
    ProgressionRecommendation(
      exerciseId: _string(value, 'exerciseId'),
      exerciseName: _string(value, 'exerciseName'),
      loadUnit: _string(value, 'loadUnit'),
      state: switch (_string(value, 'state')) {
        'increase' => ProgressionRecommendationState.increase,
        'hold' => ProgressionRecommendationState.hold,
        'protected' => ProgressionRecommendationState.protected,
        'override' => ProgressionRecommendationState.override,
        'no_data' => ProgressionRecommendationState.noData,
        _ => throw const FormatException('Unknown progression state.'),
      },
      latestLoad: _optionalDouble(value['latestLoad']),
      suggestedLoad: _optionalDouble(value['suggestedLoad']),
      reason: _string(value, 'reason'),
      setting: _setting(_map(value['setting'])),
    );

ProgressionSetting _setting(Map<String, Object?> value) => ProgressionSetting(
  exerciseId: _string(value, 'exerciseId'),
  progressionProtected: _bool(value, 'progressionProtected'),
  painFlagged: _bool(value, 'painFlagged'),
  preferredSubstituteExerciseId:
      value['preferredSubstituteExerciseId'] as String?,
  preferredSubstituteName: value['preferredSubstituteName'] as String?,
  manualNextLoad: _optionalDouble(value['manualNextLoad']),
  note: _stringAllowEmpty(value, 'note'),
);

SubstituteExerciseOption _substitute(Map<String, Object?> value) =>
    SubstituteExerciseOption(
      exerciseId: _string(value, 'exerciseId'),
      exerciseName: _string(value, 'exerciseName'),
    );

ProgressCorrection _correction(Map<String, Object?> value) =>
    ProgressCorrection(
      id: _string(value, 'id'),
      kind: switch (_string(value, 'kind')) {
        'rr' => ProgressCorrectionKind.rr,
        'xp' => ProgressCorrectionKind.xp,
        _ => throw const FormatException('Unknown correction kind.'),
      },
      delta: _int(value, 'delta'),
      reason: _string(value, 'reason'),
      reversesCorrectionId: value['reversesCorrectionId'] as String?,
      reversed: _bool(value, 'reversed'),
      createdAt: DateTime.parse(_string(value, 'createdAt')),
    );

ProgressCorrectionResult _correctionResult(Map<String, Object?> value) =>
    ProgressCorrectionResult(
      account: _account(_map(value['account'])),
      correction: _correction(_map(value['correction'])),
    );

RankAccount _account(Map<String, Object?> value) => RankAccount(
  userId: _string(value, 'userId'),
  rrBalance: _int(value, 'rrBalance'),
  lifetimeXp: _int(value, 'lifetimeXp'),
  rankId: _string(value, 'rankId'),
  currentMinimum: _int(value, 'currentMinimum'),
  nextRankId: value['nextRankId'] as String?,
  nextMinimum: _optionalInt(value['nextMinimum']),
  progress: _number(value, 'progress').toDouble(),
);

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>)
    throw const FormatException('Expected object.');
  return <String, Object?>{
    for (final entry in value.entries)
      if (entry.key is String) entry.key! as String: entry.value,
  };
}

List<Object?> _list(Object? value) {
  if (value is! List<Object?>) throw const FormatException('Expected list.');
  return value;
}

String _string(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! String || item.isEmpty)
    throw FormatException('Expected $key string.');
  return item;
}

String _stringAllowEmpty(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! String) throw FormatException('Expected $key string.');
  return item;
}

bool _bool(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! bool) throw FormatException('Expected $key boolean.');
  return item;
}

int _int(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! int) throw FormatException('Expected $key integer.');
  return item;
}

num _number(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! num) throw FormatException('Expected $key number.');
  return item;
}

double? _optionalDouble(Object? value) => switch (value) {
  null => null,
  num value => value.toDouble(),
  _ => throw const FormatException('Expected nullable number.'),
};

int? _optionalInt(Object? value) => switch (value) {
  null => null,
  int value => value,
  _ => throw const FormatException('Expected nullable integer.'),
};
