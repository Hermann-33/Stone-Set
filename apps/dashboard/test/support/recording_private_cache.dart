import 'dart:async';

import 'package:stone_set_dashboard/src/session/dashboard_private_cache.dart';

final class RecordingPrivateCache implements DashboardPrivateCache {
  final List<String> clearedUsers = [];
  Completer<void>? clearBlocker;

  @override
  Future<void> clearForUser(String userId) async {
    clearedUsers.add(userId);
    await clearBlocker?.future;
  }
}
