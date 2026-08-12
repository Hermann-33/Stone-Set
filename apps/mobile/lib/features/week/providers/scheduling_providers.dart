import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/scheduling.dart';

import '../../identity/controllers/mobile_session_controller.dart';
import '../../identity/providers/identity_providers.dart';
import '../../local/providers/mobile_local_providers.dart';
import '../../sync/controllers/mobile_sync_controller.dart';

final schedulingRepositoryProvider = Provider<SchedulingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSchedulingRepository(
    remote: SupabaseSchedulingRemoteService(client),
  );
});

final currentWeekProvider = FutureProvider.autoDispose<WeekLoadResult>((
  ref,
) async {
  final ownerId = ref.watch(
    mobileSessionControllerProvider.select((value) => value.value?.userId),
  );
  if (ownerId == null) {
    throw const SchedulingFailure('session_required');
  }
  ref.watch(mobileSyncControllerProvider.select((value) => value.generationId));
  final store = ref.watch(mobileSnapshotStoreProvider);
  final cached = await store.loadCurrentWeek(ownerId);
  if (cached != null) return cached;

  await ref
      .read(mobileSyncControllerProvider.notifier)
      .initializeForOwner(ownerId);
  await ref
      .read(mobileSyncControllerProvider.notifier)
      .synchronize(trigger: MobileSyncTrigger.retry);
  final synchronized = await store.loadCurrentWeek(ownerId);
  if (synchronized == null) {
    throw const SchedulingFailure('cached_week_unavailable');
  }
  return synchronized;
});
