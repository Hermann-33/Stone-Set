import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_private_cache.g.dart';

abstract interface class DashboardPrivateCache {
  Future<void> clearForUser(String userId);
}

final class EmptyDashboardPrivateCache implements DashboardPrivateCache {
  const EmptyDashboardPrivateCache();

  @override
  Future<void> clearForUser(String userId) async {}
}

@Riverpod(keepAlive: true)
DashboardPrivateCache dashboardPrivateCache(Ref ref) => const EmptyDashboardPrivateCache();
