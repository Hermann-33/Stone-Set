import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_domain/scheduling.dart';
import 'package:stone_set_domain/workouts.dart';

import '../../identity/providers/identity_providers.dart';
import '../../workout/controllers/workout_controller.dart';
import '../../workout/data/sqflite_workout_local_store.dart';
import '../../workout/data/workout_local_store.dart';

final mobileSyncSchedulingRepositoryProvider = Provider<SchedulingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSchedulingRepository(remote: SupabaseSchedulingRemoteService(client));
});

final mobileSyncProgressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProgressRepository(SupabaseProgressRemoteService(client));
});

final mobileSyncWorkoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseWorkoutRepository(remote: SupabaseWorkoutRemoteService(client));
});

final mobileSyncWorkoutLocalStoreProvider = Provider<WorkoutLocalStore>((ref) {
  return SqfliteWorkoutLocalStore();
});

final mobileSyncWorkoutControllerProvider = Provider<WorkoutController>((ref) {
  return WorkoutController(
    remote: ref.watch(mobileSyncWorkoutRepositoryProvider),
    local: ref.watch(mobileSyncWorkoutLocalStoreProvider),
  );
});
