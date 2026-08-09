import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/scheduling.dart';

import '../../identity/providers/identity_providers.dart';

final schedulingRepositoryProvider = Provider<SchedulingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSchedulingRepository(
    remote: SupabaseSchedulingRemoteService(client),
  );
});

final currentWeekProvider = FutureProvider.autoDispose<WeekLoadResult>((ref) {
  return ref.watch(schedulingRepositoryProvider).getOrCreateCurrentWeek();
});
