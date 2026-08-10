import 'workout_models.dart';

abstract interface class WorkoutRepository {
  Future<WorkoutLoadResult> startWorkout({required String planItemId});

  Future<WorkoutLoadResult> syncWorkout({
    required String sessionId,
    required int clientRevision,
    required List<WorkoutSetDraft> sets,
  });

  Future<WorkoutLoadResult> submitWorkout({
    required String sessionId,
    required int clientRevision,
    required List<WorkoutSetDraft> sets,
  });
}
