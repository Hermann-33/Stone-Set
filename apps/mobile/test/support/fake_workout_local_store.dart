import 'package:stone_set_domain/workouts.dart';

import '../../lib/features/workout/data/workout_local_store.dart';

final class FakeWorkoutLocalStore implements WorkoutLocalStore {
  LocalWorkoutDraft? draft;

  @override
  Future<LocalWorkoutDraft?> loadActive(String userId) async {
    final value = draft;
    return value?.userId == userId ? value : null;
  }

  @override
  Future<void> saveStarted({
    required String userId,
    required WorkoutSession session,
  }) async {
    draft = LocalWorkoutDraft(
      userId: userId,
      planItemId: session.planItemId,
      session: session,
      sets: session.sets,
      clientRevision: session.lastClientRevision,
      lastSyncedRevision: session.lastClientRevision,
    );
  }

  @override
  Future<LocalWorkoutDraft> saveSet({
    required String userId,
    required WorkoutSetDraft set,
    DateTime? restEndAt,
    bool clearRestEndAt = false,
  }) async {
    final current = draft;
    if (current == null || current.userId != userId) {
      throw StateError('No active workout.');
    }
    final revision = current.clientRevision + 1;
    final sets = <WorkoutSetDraft>[
      for (final existing in current.sets)
        if (existing.sessionExerciseId == set.sessionExerciseId &&
            existing.setIndex == set.setIndex)
          set.copyWith(clientRevision: revision)
        else
          existing,
    ];
    draft = LocalWorkoutDraft(
      userId: current.userId,
      planItemId: current.planItemId,
      session: current.session,
      sets: sets,
      clientRevision: revision,
      lastSyncedRevision: current.lastSyncedRevision,
      restEndAt: clearRestEndAt ? null : restEndAt ?? current.restEndAt,
    );
    return draft!;
  }

  @override
  Future<void> markSynced({
    required String userId,
    required WorkoutSession session,
    required int syncedRevision,
  }) async {
    final current = draft;
    if (current == null || current.userId != userId) return;
    draft = LocalWorkoutDraft(
      userId: current.userId,
      planItemId: current.planItemId,
      session: session,
      sets: session.sets,
      clientRevision: current.clientRevision,
      lastSyncedRevision: syncedRevision,
      restEndAt: current.restEndAt,
    );
  }

  @override
  Future<void> clear(String userId) async {
    if (draft?.userId == userId) draft = null;
  }
}
