import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/progress.dart';

import '../../identity/providers/identity_providers.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProgressRepository(SupabaseProgressRemoteService(client));
});

final progressSnapshotProvider = FutureProvider.autoDispose<ProgressSnapshot>((ref) {
  return ref.watch(progressRepositoryProvider).getProgress();
});
