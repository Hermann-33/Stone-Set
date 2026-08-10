import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/progression.dart';
import 'package:stone_set_domain/progression.dart';

void main() {
  test('decodes progression snapshot', () async {
    final repository = SupabaseProgressionRepository(_FakeRemote());

    final value = await repository.getProgression();

    expect(value.recommendations.single.state, ProgressionRecommendationState.increase);
    expect(value.recommendations.single.suggestedLoad, 82.5);
    expect(value.substituteOptions.single.exerciseName, 'Dumbbell Press');
    expect(value.corrections.single.canReverse, isTrue);
  });

  test('maps setting and correction parameters', () async {
    final remote = _FakeRemote();
    final repository = SupabaseProgressionRepository(remote);

    await repository.updateSetting(
      exerciseId: 'exercise-1',
      progressionProtected: true,
      painFlagged: false,
      preferredSubstituteExerciseId: 'exercise-2',
      manualNextLoad: 85,
      note: 'Keep it simple',
    );
    expect(remote.lastParams['p_exercise_definition_id'], 'exercise-1');
    expect(remote.lastParams['p_progression_protected'], true);
    expect(remote.lastParams['p_preferred_substitute_exercise_id'], 'exercise-2');
    expect(remote.lastParams['p_manual_next_load'], 85);

    await repository.applyCorrection(
      kind: ProgressCorrectionKind.rr,
      delta: -5,
      reason: 'Fix duplicate reward',
    );
    expect(remote.lastParams['p_kind'], 'rr');
    expect(remote.lastParams['p_delta'], -5);
  });

  test('invalid progression shape fails decoding', () async {
    final repository = SupabaseProgressionRepository(
      _FakeRemote(snapshot: <String, Object?>{'recommendations': 'invalid'}),
    );

    await expectLater(repository.getProgression(), throwsA(isA<FormatException>()));
  });
}

final class _FakeRemote implements ProgressionRemoteService {
  _FakeRemote({Map<String, Object?>? snapshot}) : snapshot = snapshot ?? _snapshot;

  final Map<String, Object?> snapshot;
  Map<String, Object?> lastParams = const <String, Object?>{};

  @override
  Future<Map<String, Object?>> getProgression() async => snapshot;

  @override
  Future<Map<String, Object?>> updateSetting(Map<String, Object?> params) async {
    lastParams = params;
    return snapshot;
  }

  @override
  Future<Map<String, Object?>> applyCorrection(Map<String, Object?> params) async {
    lastParams = params;
    return _correctionResult;
  }

  @override
  Future<Map<String, Object?>> reverseCorrection(Map<String, Object?> params) async {
    lastParams = params;
    return _correctionResult;
  }
}

final _snapshot = <String, Object?>{
  'recommendations': <Object?>[
    <String, Object?>{
      'exerciseId': 'exercise-1',
      'exerciseName': 'Bench Press',
      'loadUnit': 'kg',
      'state': 'increase',
      'latestLoad': 80,
      'suggestedLoad': 82.5,
      'reason': 'All conditions met.',
      'setting': <String, Object?>{
        'exerciseId': 'exercise-1',
        'progressionProtected': false,
        'painFlagged': false,
        'preferredSubstituteExerciseId': null,
        'preferredSubstituteName': null,
        'manualNextLoad': null,
        'note': '',
      },
    },
  ],
  'substituteOptions': <Object?>[
    <String, Object?>{
      'exerciseId': 'exercise-2',
      'exerciseName': 'Dumbbell Press',
    },
  ],
  'corrections': <Object?>[
    <String, Object?>{
      'id': 'correction-1',
      'kind': 'rr',
      'delta': 5,
      'reason': 'Adjustment',
      'reversesCorrectionId': null,
      'reversed': false,
      'createdAt': '2026-08-10T10:00:00Z',
    },
  ],
};

final _correctionResult = <String, Object?>{
  'account': <String, Object?>{
    'userId': '00000000-0000-4000-8000-000000000001',
    'rrBalance': 100,
    'lifetimeXp': 200,
    'rankId': 'bronze_ii',
    'currentMinimum': 100,
    'nextRankId': 'bronze_iii',
    'nextMinimum': 200,
    'progress': 0.0,
  },
  'correction': <String, Object?>{
    'id': 'correction-2',
    'kind': 'rr',
    'delta': -5,
    'reason': 'Fix duplicate reward',
    'reversesCorrectionId': null,
    'reversed': false,
    'createdAt': '2026-08-10T10:10:00Z',
  },
};
