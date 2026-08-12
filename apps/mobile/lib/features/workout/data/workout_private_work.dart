import 'package:stone_set_domain/identity.dart';

import '../controllers/workout_controller.dart';
import 'workout_local_store.dart';

final class WorkoutPrivateWork implements UnsynchronizedPrivateWork {
  const WorkoutPrivateWork({
    required WorkoutLocalStore local,
    required WorkoutController controller,
  }) : this._(local, controller);

  const WorkoutPrivateWork._(this._local, this._controller);

  final WorkoutLocalStore _local;
  final WorkoutController _controller;

  @override
  Future<bool> hasUnsynchronizedPrivateWork(String userId) async {
    final draft = await _local.loadActive(userId);
    return draft?.pendingSync ?? false;
  }

  @override
  Future<bool> synchronizeNow(String userId) async {
    final draft = await _local.loadActive(userId);
    if (draft == null || !draft.pendingSync) return true;
    try {
      final synchronized = await _controller.sync(userId: userId);
      return !synchronized.pendingSync;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> discard(String userId) => _local.clear(userId);
}

final class OwnerScopedWorkoutQuarantine implements PrivateWorkQuarantine {
  const OwnerScopedWorkoutQuarantine();

  @override
  Future<void> quarantineForSessionLoss(String userId) async {
    // Workout rows are already keyed by immutable owner UUID. Keeping them in
    // place while the Supabase session is absent is the quarantine boundary:
    // another account cannot load or submit them, and the original owner can
    // resume after reauthentication.
  }
}
