import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/workouts.dart';

import '../../identity/controllers/mobile_session_controller.dart';
import '../../identity/providers/identity_providers.dart';
import '../../sync/controllers/mobile_sync_controller.dart';
import '../controllers/workout_controller.dart';
import '../data/sqflite_workout_local_store.dart';
import '../data/workout_local_store.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseWorkoutRepository(remote: SupabaseWorkoutRemoteService(client));
});

final workoutLocalStoreProvider = Provider<WorkoutLocalStore>((ref) {
  return SqfliteWorkoutLocalStore();
});

final workoutControllerProvider = Provider<WorkoutController>((ref) {
  return WorkoutController(
    remote: ref.watch(workoutRepositoryProvider),
    local: ref.watch(workoutLocalStoreProvider),
    afterSubmit: (userId) async {
      await ref
          .read(mobileSyncControllerProvider.notifier)
          .synchronize(trigger: MobileSyncTrigger.workoutCompletion);
    },
  );
});

final workoutDraftProvider = FutureProvider.autoDispose.family<LocalWorkoutDraft, String>((
  ref,
  planItemId,
) async {
  final userId = ref.watch(mobileSessionControllerProvider).value?.userId;
  if (userId == null) throw const WorkoutFailure('session_required');
  return ref.watch(workoutControllerProvider).loadOrStart(userId: userId, planItemId: planItemId);
});
