import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mobile_snapshot_store.dart';
import '../data/sqflite_mobile_snapshot_store.dart';

final mobileSnapshotStoreProvider = Provider<MobileSnapshotStore>((ref) {
  return SqfliteMobileSnapshotStore();
});
