import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/workouts.dart';
import 'package:stone_set_domain/workouts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('decodes started workout snapshot', () async {
    final repository = SupabaseWorkoutRepository(remote: _FakeRemote());
    final result = await repository.startWorkout(planItemId: _FakeRemote.planItemId);

    expect(result.session.id, _FakeRemote.sessionId);
    expect(result.session.exercises, hasLength(1));
    expect(result.session.sets, hasLength(3));
    expect(result.session.plannedSetCount, 3);
    expect(result.result, isNull);
  });

  test('sends whole snapshot and decodes synced revision', () async {
    final remote = _FakeRemote();
    final repository = SupabaseWorkoutRepository(remote: remote);
    final result = await repository.syncWorkout(
      sessionId: _FakeRemote.sessionId,
      clientRevision: 2,
      sets: <WorkoutSetDraft>[
        const WorkoutSetDraft(
          sessionExerciseId: _FakeRemote.exerciseId,
          setIndex: 1,
          loadValue: 80,
          loadUnit: 'kg',
          repetitions: 10,
          rir: 2,
          completed: true,
          clientRevision: 2,
        ),
      ],
    );

    expect(remote.lastFunction, 'sync_workout_v1');
    expect(remote.lastParams['p_client_revision'], 2);
    expect(result.session.lastClientRevision, 2);
    expect(result.session.sets.first.completed, isTrue);
  });

  test('decodes submit result', () async {
    final repository = SupabaseWorkoutRepository(remote: _FakeRemote());
    final result = await repository.submitWorkout(
      sessionId: _FakeRemote.sessionId,
      clientRevision: 3,
      sets: const <WorkoutSetDraft>[],
    );

    expect(result.session.state, WorkoutSessionState.submitted);
    expect(result.result!.status, WorkoutResultStatus.completed);
    expect(result.result!.completedSets, 3);
  });

  test('maps server workout error', () async {
    final repository = SupabaseWorkoutRepository(
      remote: _FakeRemote(failStart: true),
    );

    await expectLater(
      repository.startWorkout(planItemId: _FakeRemote.planItemId),
      throwsA(
        isA<WorkoutFailure>().having(
          (error) => error.code,
          'code',
          'workout_not_today',
        ),
      ),
    );
  });
}

final class _FakeRemote implements WorkoutRemoteService {
  _FakeRemote({this.failStart = false});

  static const userId = '00000000-0000-4000-8000-000000000001';
  static const planItemId = '00000000-0000-4000-8000-000000000002';
  static const sessionId = '00000000-0000-4000-8000-000000000003';
  static const exerciseId = '00000000-0000-4000-8000-000000000004';
  static const definitionId = '00000000-0000-4000-8000-000000000005';
  static const guidanceId = '00000000-0000-4000-8000-000000000006';

  final bool failStart;
  String? lastFunction;
  Map<String, Object?> lastParams = const <String, Object?>{};

  @override
  Future<Map<String, Object?>> call(
    String function,
    Map<String, Object?> params,
  ) async {
    lastFunction = function;
    lastParams = params;
    if (function == 'start_workout_v1' && failStart) {
      throw const PostgrestException(
        message: 'workout_not_today',
        code: '22023',
      );
    }
    if (function == 'submit_workout_v1') {
      return <String, Object?>{
        'session': _session(state: 'submitted', revision: 3, completed: true),
        'result': <String, Object?>{
          'id': '00000000-0000-4000-8000-000000000010',
          'sessionId': sessionId,
          'status': 'completed',
          'plannedSets': 3,
          'completedSets': 3,
          'submittedAt': '2026-08-10T02:00:00Z',
        },
      };
    }
    if (function == 'sync_workout_v1') {
      final revision = params['p_client_revision']! as int;
      return <String, Object?>{
        'session': _session(
          revision: revision,
          completed: revision > 0,
        ),
      };
    }
    if (function == 'start_workout_v1') {
      return <String, Object?>{'session': _session()};
    }
    throw UnsupportedError(function);
  }

  Map<String, Object?> _session({
    String state = 'active',
    int revision = 0,
    bool completed = false,
  }) => <String, Object?>{
    'id': sessionId,
    'userId': userId,
    'planItemId': planItemId,
    'state': state,
    'startedAt': '2026-08-10T01:00:00Z',
    'lastClientRevision': revision,
    'exercises': <Object?>[
      <String, Object?>{
        'id': exerciseId,
        'position': 1,
        'exerciseDefinitionId': definitionId,
        'guidanceRevisionId': guidanceId,
        'title': 'Squat',
        'priority': true,
        'workingSets': 3,
        'repMin': 8,
        'repMax': 12,
        'rirTarget': 2,
        'restSeconds': 90,
        'loadUnit': 'kg',
        'notes': '',
      },
    ],
    'sets': <Object?>[
      for (var index = 1; index <= 3; index += 1)
        <String, Object?>{
          'sessionExerciseId': exerciseId,
          'setIndex': index,
          'loadValue': completed && index == 1 ? 80 : null,
          'loadUnit': 'kg',
          'repetitions': completed && index == 1 ? 10 : null,
          'rir': completed && index == 1 ? 2 : null,
          'completed': completed,
          'clientRevision': revision,
        },
    ],
  };
}
