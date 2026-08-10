import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/progression.dart';

import '../../identity/providers/identity_providers.dart';

final progressionRepositoryProvider = Provider<ProgressionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProgressionRepository(SupabaseProgressionRemoteService(client));
});

final progressionSnapshotProvider = FutureProvider.autoDispose<ProgressionSnapshot>((ref) {
  return ref.watch(progressionRepositoryProvider).getProgression();
});
