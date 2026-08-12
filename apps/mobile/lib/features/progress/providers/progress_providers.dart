import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/progress.dart';

import '../../identity/controllers/mobile_session_controller.dart';
import '../../identity/providers/identity_providers.dart';
import '../../local/providers/mobile_local_providers.dart';
import '../../sync/controllers/mobile_sync_controller.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProgressRepository(SupabaseProgressRemoteService(client));
});

final progressSnapshotProvider = FutureProvider.autoDispose<ProgressSnapshot>((ref) async {
  final ownerId = ref.watch(
    mobileSessionControllerProvider.select((value) => value.value?.userId),
  );
  if (ownerId == null) {
    throw const ProgressFailure('session_required');
  }
  ref.watch(mobileSyncControllerProvider.select((value) => value.generationId));
  final store = ref.watch(mobileSnapshotStoreProvider);
  final cached = await store.loadProgress(ownerId);
  if (cached != null) return cached;

  await ref.read(mobileSyncControllerProvider.notifier).initializeForOwner(ownerId);
  await ref
      .read(mobileSyncControllerProvider.notifier)
      .synchronize(trigger: MobileSyncTrigger.retry);
  final synchronized = await store.loadProgress(ownerId);
  if (synchronized == null) {
    throw const ProgressFailure('cached_progress_unavailable');
  }
  return synchronized;
});
