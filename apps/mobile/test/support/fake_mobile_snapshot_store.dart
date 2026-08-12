import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_domain/scheduling.dart';
import 'package:stone_set_mobile/features/local/data/mobile_snapshot_store.dart';

final class FakeMobileSnapshotStore implements MobileSnapshotStore {
  final identityByOwner = <String, IdentityBootstrap>{};
  final weekByOwner = <String, WeekLoadResult>{};
  final progressByOwner = <String, ProgressSnapshot>{};
  final metadataByOwner = <String, MobileSyncMetadata>{};

  @override
  Future<IdentityBootstrap?> loadIdentityBootstrap(String ownerId) async => identityByOwner[ownerId];

  @override
  Future<void> saveIdentityBootstrap({
    required String ownerId,
    required IdentityBootstrap bootstrap,
    required DateTime cachedAt,
  }) async {
    identityByOwner[ownerId] = bootstrap;
  }

  @override
  Future<WeekLoadResult?> loadCurrentWeek(String ownerId) async => weekByOwner[ownerId];

  @override
  Future<ProgressSnapshot?> loadProgress(String ownerId) async => progressByOwner[ownerId];

  @override
  Future<MobileSyncMetadata?> loadSyncMetadata(String ownerId) async => metadataByOwner[ownerId];

  @override
  Future<String> commitSynchronizedSnapshots({
    required String ownerId,
    required WeekLoadResult week,
    required ProgressSnapshot progress,
    required DateTime synchronizedAt,
  }) async {
    final generation = 'test-${synchronizedAt.microsecondsSinceEpoch}';
    weekByOwner[ownerId] = week;
    progressByOwner[ownerId] = progress;
    metadataByOwner[ownerId] = MobileSyncMetadata(
      ownerId: ownerId,
      generationId: generation,
      lastSuccessfulSyncAt: synchronizedAt,
      lastAttemptAt: synchronizedAt,
    );
    return generation;
  }

  @override
  Future<void> recordSyncFailure({
    required String ownerId,
    required DateTime attemptedAt,
    required String errorCode,
  }) async {
    final previous = metadataByOwner[ownerId];
    metadataByOwner[ownerId] = MobileSyncMetadata(
      ownerId: ownerId,
      generationId: previous?.generationId,
      lastSuccessfulSyncAt: previous?.lastSuccessfulSyncAt,
      lastAttemptAt: attemptedAt,
      lastErrorCode: errorCode,
    );
  }

  @override
  Future<void> clearReadSnapshots(String ownerId) async {
    identityByOwner.remove(ownerId);
    weekByOwner.remove(ownerId);
    progressByOwner.remove(ownerId);
    metadataByOwner.remove(ownerId);
  }
}
