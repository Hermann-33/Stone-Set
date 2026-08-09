import 'package:stone_set_domain/workouts.dart';

final class LocalWorkoutDraft {
  LocalWorkoutDraft({
    required this.userId,
    required this.planItemId,
    required this.session,
    required Iterable<WorkoutSetDraft> sets,
    required this.clientRevision,
    required this.lastSyncedRevision,
    this.restEndAt,
  }) : sets = List<WorkoutSetDraft>.unmodifiable(sets);

  final String userId;
  final String planItemId;
  final WorkoutSession session;
  final List<WorkoutSetDraft> sets;
  final int clientRevision;
  final int lastSyncedRevision;
  final DateTime? restEndAt;

  bool get pendingSync => clientRevision > lastSyncedRevision;
}

abstract interface class WorkoutLocalStore {
  Future<LocalWorkoutDraft?> loadActive(String userId);

  Future<void> saveStarted({
    required String userId,
    required WorkoutSession session,
  });

  Future<LocalWorkoutDraft> saveSet({
    required String userId,
    required WorkoutSetDraft set,
    DateTime? restEndAt,
    bool clearRestEndAt = false,
  });

  Future<void> markSynced({
    required String userId,
    required WorkoutSession session,
    required int syncedRevision,
  });

  Future<void> clear(String userId);
}
