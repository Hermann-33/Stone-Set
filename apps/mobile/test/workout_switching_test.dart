import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/workouts.dart';
import 'package:stone_set_mobile/features/workout/controllers/workout_controller.dart';
import 'package:stone_set_mobile/features/workout/data/workout_local_store.dart';

void main() {
  const userId = '00000000-0000-4000-8000-000000000001';

  test('synchronized stale local workout is cleared before requested start', () async {
    final local = _MemoryWorkoutLocalStore(
      active: _draft(userId: userId, planItemId: 'old', revision: 0, synced: 0),
    );
    final remote = _FakeWorkoutRepository();
    final controller = WorkoutController(remote: remote, local: local);

    final result = await controller.loadOrStart(userId: userId, planItemId: 'today');

    expect(remote.startedPlanItemIds, <String>['today']);
    expect(local.clearCalls, 1);
    expect(result.planItemId, 'today');
  });

  test('pending local workout synchronizes before switching', () async {
    final local = _MemoryWorkoutLocalStore(
      active: _draft(userId: userId, planItemId: 'old', revision: 3, synced: 2),
    );
    final remote = _FakeWorkoutRepository();
    final controller = WorkoutController(remote: remote, local: local);

    final result = await controller.loadOrStart(userId: userId, planItemId: 'today');

    expect(remote.syncCalls, 1);
    expect(remote.startedPlanItemIds, <String>['today']);
    expect(local.clearCalls, 1);
    expect(result.planItemId, 'today');
  });

  test('failed pending sync preserves old local workout and blocks switching', () async {
    final old = _draft(userId: userId, planItemId: 'old', revision: 3, synced: 2);
    final local = _MemoryWorkoutLocalStore(active: old);
    final remote = _FakeWorkoutRepository(failSync: true);
    final controller = WorkoutController(remote: remote, local: local);

    await expectLater(
      controller.loadOrStart(userId: userId, planItemId: 'today'),
      throwsA(
        isA<WorkoutFailure>().having(
          (error) => error.code,
          'code',
          'another_workout_is_active',
        ),
      ),
    );

    expect(remote.startedPlanItemIds, isEmpty);
    expect(local.clearCalls, 0);
    expect((await local.loadActive(userId))?.planItemId, 'old');
  });
}

LocalWorkoutDraft _draft({
  required String userId,
  required String planItemId,
  required int revision,
  required int synced,
}) => LocalWorkoutDraft(
  userId: userId,
  planItemId: planItemId,
  session: _session(userId: userId, planItemId: planItemId),
  sets: const <WorkoutSetDraft>[],
  clientRevision: revision,
  lastSyncedRevision: synced,
);

WorkoutSession _session({required String userId, required String planItemId}) => WorkoutSession(
  id: 'session-$planItemId',
  userId: userId,
  planItemId: planItemId,
  state: WorkoutSessionState.active,
  startedAt: DateTime.utc(2026, 8, 13),
  lastClientRevision: 0,
  exercises: const <WorkoutExercise>[],
  sets: const <WorkoutSetDraft>[],
);

final class _FakeWorkoutRepository implements WorkoutRepository {
  _FakeWorkoutRepository({this.failSync = false});

  final bool failSync;
  final List<String> startedPlanItemIds = <String>[];
  int syncCalls = 0;

  @override
  Future<WorkoutLoadResult> startWorkout({required String planItemId}) async {
    startedPlanItemIds.add(planItemId);
    return WorkoutLoadResult(
      session: _session(
        userId: '00000000-0000-4000-8000-000000000001',
        planItemId: planItemId,
      ),
    );
  }

  @override
  Future<WorkoutLoadResult> syncWorkout({
    required String sessionId,
    required int clientRevision,
    required List<WorkoutSetDraft> sets,
  }) async {
    syncCalls += 1;
    if (failSync) throw const WorkoutFailure('network');
    return WorkoutLoadResult(
      session: _session(
        userId: '00000000-0000-4000-8000-000000000001',
        planItemId: 'old',
      ),
    );
  }

  @override
  Future<WorkoutLoadResult> submitWorkout({
    required String sessionId,
    required int clientRevision,
    required List<WorkoutSetDraft> sets,
  }) => throw UnimplementedError();
}

final class _MemoryWorkoutLocalStore implements WorkoutLocalStore {
  _MemoryWorkoutLocalStore({LocalWorkoutDraft? active}) : _active = active;

  LocalWorkoutDraft? _active;
  int clearCalls = 0;

  @override
  Future<LocalWorkoutDraft?> loadActive(String userId) async => _active;

  @override
  Future<void> saveStarted({
    required String userId,
    required WorkoutSession session,
  }) async {
    _active = LocalWorkoutDraft(
      userId: userId,
      planItemId: session.planItemId,
      session: session,
      sets: const <WorkoutSetDraft>[],
      clientRevision: 0,
      lastSyncedRevision: 0,
    );
  }

  @override
  Future<LocalWorkoutDraft> saveSet({
    required String userId,
    required WorkoutSetDraft set,
    DateTime? restEndAt,
    bool clearRestEndAt = false,
  }) => throw UnimplementedError();

  @override
  Future<void> markSynced({
    required String userId,
    required WorkoutSession session,
    required int syncedRevision,
  }) async {
    final current = _active!;
    _active = LocalWorkoutDraft(
      userId: current.userId,
      planItemId: current.planItemId,
      session: current.session,
      sets: current.sets,
      clientRevision: current.clientRevision,
      lastSyncedRevision: syncedRevision,
      restEndAt: current.restEndAt,
    );
  }

  @override
  Future<void> clear(String userId) async {
    clearCalls += 1;
    _active = null;
  }
}
