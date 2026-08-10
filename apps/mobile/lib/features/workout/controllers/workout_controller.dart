import 'package:stone_set_domain/workouts.dart';

import '../data/workout_local_store.dart';

final class WorkoutController {
  const WorkoutController({
    required WorkoutRepository remote,
    required WorkoutLocalStore local,
  }) : _remote = remote,
       _local = local;

  final WorkoutRepository _remote;
  final WorkoutLocalStore _local;

  Future<LocalWorkoutDraft> loadOrStart({
    required String userId,
    required String planItemId,
  }) async {
    final existing = await _local.loadActive(userId);
    if (existing != null) {
      if (existing.planItemId != planItemId) {
        throw const WorkoutFailure('another_workout_is_active');
      }
      if (existing.pendingSync) {
        try {
          await sync(userId: userId);
        } on Object {
          // Local work remains usable. Explicit Sync can retry later.
        }
      }
      return (await _local.loadActive(userId))!;
    }

    final started = await _remote.startWorkout(planItemId: planItemId);
    await _local.saveStarted(userId: userId, session: started.session);
    return (await _local.loadActive(userId))!;
  }

  Future<LocalWorkoutDraft> saveSet({
    required String userId,
    required WorkoutSetDraft set,
    DateTime? restEndAt,
    bool clearRestEndAt = false,
  }) => _local.saveSet(
    userId: userId,
    set: set,
    restEndAt: restEndAt,
    clearRestEndAt: clearRestEndAt,
  );

  Future<LocalWorkoutDraft> sync({required String userId}) async {
    final draft = await _local.loadActive(userId);
    if (draft == null) throw const WorkoutFailure('no_active_workout');
    if (!draft.pendingSync) return draft;

    final result = await _remote.syncWorkout(
      sessionId: draft.session.id,
      clientRevision: draft.clientRevision,
      sets: draft.sets,
    );

    final current = await _local.loadActive(userId);
    if (current == null) throw const WorkoutFailure('no_active_workout');
    if (current.session.id != draft.session.id || current.clientRevision != draft.clientRevision) {
      return current;
    }

    await _local.markSynced(
      userId: userId,
      session: result.session,
      syncedRevision: draft.clientRevision,
    );
    return (await _local.loadActive(userId))!;
  }

  Future<WorkoutLoadResult> submit({required String userId}) async {
    final draft = await _local.loadActive(userId);
    if (draft == null) throw const WorkoutFailure('no_active_workout');
    final result = await _remote.submitWorkout(
      sessionId: draft.session.id,
      clientRevision: draft.clientRevision,
      sets: draft.sets,
    );
    await _local.clear(userId);
    return result;
  }
}
