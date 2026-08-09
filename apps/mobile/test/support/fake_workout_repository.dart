import 'package:stone_set_domain/workouts.dart';

final class FakeWorkoutRepository implements WorkoutRepository {
  FakeWorkoutRepository({this.failSync = false});

  bool failSync;
  int syncCalls = 0;
  int submitCalls = 0;

  static const userId = '00000000-0000-4000-8000-000000000001';
  static const planItemId = '00000000-0000-4000-8000-000000000002';
  static const sessionId = '00000000-0000-4000-8000-000000000003';
  static const sessionExerciseId = '00000000-0000-4000-8000-000000000004';

  @override
  Future<WorkoutLoadResult> startWorkout({required String planItemId}) async {
    return WorkoutLoadResult(session: session());
  }

  @override
  Future<WorkoutLoadResult> syncWorkout({
    required String sessionId,
    required int clientRevision,
    required List<WorkoutSetDraft> sets,
  }) async {
    syncCalls += 1;
    if (failSync) throw const WorkoutFailure('network_error');
    return WorkoutLoadResult(
      session: session(lastClientRevision: clientRevision, sets: sets),
    );
  }

  @override
  Future<WorkoutLoadResult> submitWorkout({
    required String sessionId,
    required int clientRevision,
    required List<WorkoutSetDraft> sets,
  }) async {
    submitCalls += 1;
    final completed = sets.where((set) => set.completed).length;
    return WorkoutLoadResult(
      session: session(
        state: WorkoutSessionState.submitted,
        lastClientRevision: clientRevision,
        sets: sets,
      ),
      result: WorkoutResult(
        id: '00000000-0000-4000-8000-000000000020',
        sessionId: FakeWorkoutRepository.sessionId,
        status: completed == 3
            ? WorkoutResultStatus.completed
            : WorkoutResultStatus.partial,
        plannedSets: 3,
        completedSets: completed,
        submittedAt: DateTime.utc(2026, 8, 10, 2),
      ),
    );
  }

  WorkoutSession session({
    WorkoutSessionState state = WorkoutSessionState.active,
    int lastClientRevision = 0,
    List<WorkoutSetDraft>? sets,
  }) => WorkoutSession(
    id: sessionId,
    userId: userId,
    planItemId: planItemId,
    state: state,
    startedAt: DateTime.utc(2026, 8, 10, 1),
    lastClientRevision: lastClientRevision,
    exercises: <WorkoutExercise>[
      const WorkoutExercise(
        id: sessionExerciseId,
        position: 1,
        exerciseDefinitionId: '00000000-0000-4000-8000-000000000005',
        guidanceRevisionId: '00000000-0000-4000-8000-000000000006',
        title: 'Squat',
        priority: true,
        workingSets: 3,
        repMin: 8,
        repMax: 12,
        rirTarget: 2,
        restSeconds: 90,
        loadUnit: 'kg',
        notes: '',
      ),
    ],
    sets: sets ??
        <WorkoutSetDraft>[
          for (var index = 1; index <= 3; index += 1)
            WorkoutSetDraft(
              sessionExerciseId: sessionExerciseId,
              setIndex: index,
              loadUnit: 'kg',
              completed: false,
              clientRevision: lastClientRevision,
            ),
        ],
  );
}
