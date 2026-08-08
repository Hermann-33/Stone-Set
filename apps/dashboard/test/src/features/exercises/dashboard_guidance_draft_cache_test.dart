import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_shim.dart';
import 'package:stone_set_dashboard/src/features/exercises/data/dashboard_guidance_draft_cache.dart';

void main() {
  group('IdbDashboardGuidanceDraftCache', () {
    late String databaseName;
    late IdbDashboardGuidanceDraftCache cache;

    setUp(() {
      databaseName = 'guidance-cache-${DateTime.now().microsecondsSinceEpoch}';
      cache = IdbDashboardGuidanceDraftCache(
        factory: idbFactoryMemory,
        databaseName: databaseName,
      );
    });

    tearDown(() async {
      cache.close();
      await idbFactoryMemory.deleteDatabase(databaseName);
    });

    test('creates only with a null expected revision and increments by CAS', () async {
      final first = _record(localRevision: 1);

      expect(
        (await cache.compareAndSwap(record: first, expectedLocalRevision: 3)).status,
        DashboardGuidanceCacheWriteStatus.conflict,
      );
      expect(await cache.read(first.key), isNull);

      expect(
        (await cache.compareAndSwap(record: first, expectedLocalRevision: null)).status,
        DashboardGuidanceCacheWriteStatus.saved,
      );

      final second = _record(localRevision: 2);
      expect(
        (await cache.compareAndSwap(record: second, expectedLocalRevision: 0)).status,
        DashboardGuidanceCacheWriteStatus.conflict,
      );
      final saved = await cache.compareAndSwap(record: second, expectedLocalRevision: 1);
      expect(saved.status, DashboardGuidanceCacheWriteStatus.saved);
      expect((await cache.read(first.key))?.localRevision, 2);
    });

    test('clearForUser isolates private records by authenticated user', () async {
      final first = _record(userId: 'user-a', localRevision: 1);
      final second = _record(userId: 'user-b', localRevision: 1);
      await cache.compareAndSwap(record: first, expectedLocalRevision: null);
      await cache.compareAndSwap(record: second, expectedLocalRevision: null);

      await cache.clearForUser('user-a');

      expect(await cache.read(first.key), isNull);
      expect(await cache.read(second.key), isNotNull);
    });

    test('cleanup removes only expired server-confirmed recovery', () async {
      final now = DateTime.utc(2026, 8, 8);
      final expired = _record(
        userId: 'user-a',
        draftId: 'expired',
        localRevision: 1,
        serverConfirmed: true,
        synchronizedAt: now.subtract(const Duration(days: 31)),
      );
      final recent = _record(
        userId: 'user-a',
        draftId: 'recent',
        localRevision: 1,
        serverConfirmed: true,
        synchronizedAt: now.subtract(const Duration(days: 1)),
      );
      final unconfirmed = _record(
        userId: 'user-a',
        draftId: 'unconfirmed',
        localRevision: 1,
      );
      for (final record in <DashboardGuidanceRecoveryRecord>[expired, recent, unconfirmed]) {
        await cache.compareAndSwap(record: record, expectedLocalRevision: null);
      }

      expect(await cache.cleanConfirmedForUser('user-a', now), 1);
      expect(await cache.read(expired.key), isNull);
      expect(await cache.read(recent.key), isNotNull);
      expect(await cache.read(unconfirmed.key), isNotNull);
    });

    test('rejects corrupt records instead of treating them as recovery', () async {
      // Open once so the cache creates its schema, then insert a malformed value
      // through the same IndexedDB factory to exercise the production decoder.
      await cache.read(_key());
      final database = await idbFactoryMemory.open(databaseName);
      final transaction = database.transaction(
        'guidance_draft_recovery_v1',
        idbModeReadWrite,
      );
      await transaction.objectStore('guidance_draft_recovery_v1').put(<String, Object?>{
        'storageKey': _key().storageKey,
        'userId': 'user-a',
      });
      await transaction.completed;

      await expectLater(cache.read(_key()), throwsA(isA<FormatException>()));
      database.close();
    });
  });

  group('guidance recovery record', () {
    test('round trips structured content without becoming authoritative state', () {
      final record = _record(localRevision: 4);

      final decoded = DashboardGuidanceRecoveryRecord.fromStorageMap(record.toStorageMap());

      expect(decoded.key, record.key);
      expect(decoded.localRevision, 4);
      expect(decoded.structuredPayload, record.structuredPayload);
      expect(decoded.serverConfirmed, isFalse);
    });

    test('rejects a storage identity mismatch', () {
      final stored = _record(localRevision: 1).toStorageMap()..['storageKey'] = 'wrong-record';

      expect(
        () => DashboardGuidanceRecoveryRecord.fromStorageMap(stored),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

DashboardGuidanceRecoveryKey _key({
  String userId = 'user-a',
  String draftId = 'draft-a',
}) => DashboardGuidanceRecoveryKey(
  userId: userId,
  exerciseId: 'exercise-a',
  draftId: draftId,
);

DashboardGuidanceRecoveryRecord _record({
  String userId = 'user-a',
  String draftId = 'draft-a',
  required int localRevision,
  bool serverConfirmed = false,
  DateTime? synchronizedAt,
}) => DashboardGuidanceRecoveryRecord(
  key: _key(userId: userId, draftId: draftId),
  localRevision: localRevision,
  expectedServerRevision: 7,
  structuredPayload: const <String, Object?>{
    'schemaVersion': 1,
    'shortExplanation': 'Keep the torso stable.',
    'setupSteps': <String>['Brace'],
  },
  updatedAt: DateTime.utc(2026, 8, 8),
  synchronizedAt: synchronizedAt,
  serverConfirmed: serverConfirmed,
);
