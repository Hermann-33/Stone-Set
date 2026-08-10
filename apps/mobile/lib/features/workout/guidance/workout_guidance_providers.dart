import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_data/stone_set_data.dart';

import '../../identity/providers/identity_providers.dart';
import 'workout_guidance_loader.dart';

final workoutGuidanceLoaderProvider = Provider<WorkoutGuidanceLoader>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return RepositoryWorkoutGuidanceLoader(
    guidanceRepository: SupabaseExerciseGuidanceRepository(
      remote: SupabaseExerciseGuidanceRemoteService(client),
    ),
    mediaRepository: SupabaseExerciseMediaRepository(
      remote: SupabaseExerciseMediaRemoteService(client),
      storage: SupabaseExerciseMediaStorageService(client),
    ),
  );
});
