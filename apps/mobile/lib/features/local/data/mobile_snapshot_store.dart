import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_domain/scheduling.dart';

final class MobileSyncMetadata {
  const MobileSyncMetadata({
    required this.ownerId,
    this.generationId,
    this.lastSuccessfulSyncAt,
    this.lastAttemptAt,
    this.lastErrorCode,
  });

  final String ownerId;
  final String? generationId;
  final DateTime? lastSuccessfulSyncAt;
  final DateTime? lastAttemptAt;
  final String? lastErrorCode;
}

abstract interface class MobileSnapshotStore {
  Future<IdentityBootstrap?> loadIdentityBootstrap(String ownerId);

  Future<void> saveIdentityBootstrap({
    required String ownerId,
    required IdentityBootstrap bootstrap,
    required DateTime cachedAt,
  });

  Future<WeekLoadResult?> loadCurrentWeek(String ownerId);

  Future<ProgressSnapshot?> loadProgress(String ownerId);

  Future<MobileSyncMetadata?> loadSyncMetadata(String ownerId);

  Future<String> commitSynchronizedSnapshots({
    required String ownerId,
    required WeekLoadResult week,
    required ProgressSnapshot progress,
    required DateTime synchronizedAt,
  });

  Future<void> recordSyncFailure({
    required String ownerId,
    required DateTime attemptedAt,
    required String errorCode,
  });

  Future<void> clearReadSnapshots(String ownerId);
}
