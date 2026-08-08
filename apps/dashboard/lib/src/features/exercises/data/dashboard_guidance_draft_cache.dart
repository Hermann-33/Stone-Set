import 'dart:async';

import 'package:idb_shim/idb.dart';

import '../../../session/dashboard_private_cache.dart';

const dashboardGuidanceCacheSchemaVersion = 1;
const dashboardGuidanceCacheRetention = Duration(days: 30);

/// Stable browser-local identity for one non-authoritative recovery record.
final class DashboardGuidanceRecoveryKey {
  const DashboardGuidanceRecoveryKey({
    required this.userId,
    required this.exerciseId,
    required this.draftId,
    this.cacheSchemaVersion = dashboardGuidanceCacheSchemaVersion,
  });

  final String userId;
  final String exerciseId;
  final String draftId;
  final int cacheSchemaVersion;

  String get storageKey => <String>[
    cacheSchemaVersion.toString(),
    Uri.encodeComponent(userId),
    Uri.encodeComponent(exerciseId),
    Uri.encodeComponent(draftId),
  ].join('|');

  @override
  bool operator ==(Object other) =>
      other is DashboardGuidanceRecoveryKey &&
      other.userId == userId &&
      other.exerciseId == exerciseId &&
      other.draftId == draftId &&
      other.cacheSchemaVersion == cacheSchemaVersion;

  @override
  int get hashCode => Object.hash(userId, exerciseId, draftId, cacheSchemaVersion);
}

/// A private recovery snapshot. It never represents publication or authority.
final class DashboardGuidanceRecoveryRecord {
  DashboardGuidanceRecoveryRecord({
    required this.key,
    required this.localRevision,
    required this.expectedServerRevision,
    required Map<String, Object?> structuredPayload,
    required this.updatedAt,
    this.synchronizedAt,
    this.serverConfirmed = false,
  }) : structuredPayload = Map<String, Object?>.unmodifiable(structuredPayload);

  final DashboardGuidanceRecoveryKey key;
  final int localRevision;
  final int expectedServerRevision;
  final Map<String, Object?> structuredPayload;
  final DateTime updatedAt;
  final DateTime? synchronizedAt;
  final bool serverConfirmed;

  DashboardGuidanceRecoveryRecord copyWith({
    int? localRevision,
    int? expectedServerRevision,
    Map<String, Object?>? structuredPayload,
    DateTime? updatedAt,
    DateTime? synchronizedAt,
    bool clearSynchronizedAt = false,
    bool? serverConfirmed,
  }) => DashboardGuidanceRecoveryRecord(
    key: key,
    localRevision: localRevision ?? this.localRevision,
    expectedServerRevision: expectedServerRevision ?? this.expectedServerRevision,
    structuredPayload: structuredPayload ?? this.structuredPayload,
    updatedAt: updatedAt ?? this.updatedAt,
    synchronizedAt: clearSynchronizedAt ? null : synchronizedAt ?? this.synchronizedAt,
    serverConfirmed: serverConfirmed ?? this.serverConfirmed,
  );

  Map<String, Object?> toStorageMap() => <String, Object?>{
    'storageKey': key.storageKey,
    'cacheSchemaVersion': key.cacheSchemaVersion,
    'userId': key.userId,
    'exerciseId': key.exerciseId,
    'draftId': key.draftId,
    'localRevision': localRevision,
    'expectedServerRevision': expectedServerRevision,
    'structuredPayload': structuredPayload,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'synchronizedAt': synchronizedAt?.toUtc().toIso8601String(),
    'serverConfirmed': serverConfirmed,
  };

  factory DashboardGuidanceRecoveryRecord.fromStorageMap(Map<Object?, Object?> value) {
    String requiredString(String key) {
      final field = value[key];
      if (field is! String || field.isEmpty) {
        throw FormatException('Invalid guidance recovery field: $key');
      }
      return field;
    }

    int requiredInt(String key) {
      final field = value[key];
      if (field is! int || field < 0) {
        throw FormatException('Invalid guidance recovery field: $key');
      }
      return field;
    }

    final payloadValue = value['structuredPayload'];
    if (payloadValue is! Map) {
      throw const FormatException('Invalid guidance recovery structured payload');
    }
    final payload = <String, Object?>{};
    for (final entry in payloadValue.entries) {
      if (entry.key is! String) {
        throw const FormatException('Invalid guidance recovery payload key');
      }
      payload[entry.key! as String] = entry.value;
    }

    DateTime? optionalDate(String key) {
      final field = value[key];
      if (field == null) return null;
      if (field is! String) {
        throw FormatException('Invalid guidance recovery field: $key');
      }
      return DateTime.tryParse(field)?.toUtc() ??
          (throw FormatException('Invalid guidance recovery date: $key'));
    }

    final cacheSchemaVersion = requiredInt('cacheSchemaVersion');
    final record = DashboardGuidanceRecoveryRecord(
      key: DashboardGuidanceRecoveryKey(
        userId: requiredString('userId'),
        exerciseId: requiredString('exerciseId'),
        draftId: requiredString('draftId'),
        cacheSchemaVersion: cacheSchemaVersion,
      ),
      localRevision: requiredInt('localRevision'),
      expectedServerRevision: requiredInt('expectedServerRevision'),
      structuredPayload: payload,
      updatedAt:
          optionalDate('updatedAt') ??
          (throw const FormatException('Missing guidance recovery updatedAt')),
      synchronizedAt: optionalDate('synchronizedAt'),
      serverConfirmed: value['serverConfirmed'] == true,
    );
    if (value['storageKey'] != record.key.storageKey) {
      throw const FormatException('Guidance recovery identity mismatch');
    }
    return record;
  }
}

enum DashboardGuidanceCacheWriteStatus { saved, conflict }

final class DashboardGuidanceCacheWriteResult {
  const DashboardGuidanceCacheWriteResult._(this.status, this.current);

  const DashboardGuidanceCacheWriteResult.saved()
    : this._(DashboardGuidanceCacheWriteStatus.saved, null);

  const DashboardGuidanceCacheWriteResult.conflict([
    DashboardGuidanceRecoveryRecord? current,
  ]) : this._(DashboardGuidanceCacheWriteStatus.conflict, current);

  final DashboardGuidanceCacheWriteStatus status;
  final DashboardGuidanceRecoveryRecord? current;
}

abstract interface class DashboardGuidanceDraftCache implements DashboardPrivateCache {
  Future<DashboardGuidanceRecoveryRecord?> read(DashboardGuidanceRecoveryKey key);

  /// Atomically saves only when [expectedLocalRevision] still matches.
  Future<DashboardGuidanceCacheWriteResult> compareAndSwap({
    required DashboardGuidanceRecoveryRecord record,
    required int? expectedLocalRevision,
  });

  Future<void> remove(DashboardGuidanceRecoveryKey key);

  /// Removes only server-confirmed records older than the recovery window.
  Future<int> cleanConfirmedForUser(String userId, DateTime now);
}

/// Deterministic non-persistent cache used by controller and widget tests.
final class InMemoryDashboardGuidanceDraftCache implements DashboardGuidanceDraftCache {
  final Map<DashboardGuidanceRecoveryKey, DashboardGuidanceRecoveryRecord> _records =
      <DashboardGuidanceRecoveryKey, DashboardGuidanceRecoveryRecord>{};

  @override
  Future<DashboardGuidanceRecoveryRecord?> read(DashboardGuidanceRecoveryKey key) async =>
      _records[key];

  @override
  Future<DashboardGuidanceCacheWriteResult> compareAndSwap({
    required DashboardGuidanceRecoveryRecord record,
    required int? expectedLocalRevision,
  }) async {
    final current = _records[record.key];
    if (current?.localRevision != expectedLocalRevision) {
      return DashboardGuidanceCacheWriteResult.conflict(current);
    }
    _records[record.key] = record;
    return const DashboardGuidanceCacheWriteResult.saved();
  }

  @override
  Future<void> remove(DashboardGuidanceRecoveryKey key) async {
    _records.remove(key);
  }

  @override
  Future<int> cleanConfirmedForUser(String userId, DateTime now) async {
    final expired = _records.entries
        .where(
          (entry) =>
              entry.key.userId == userId &&
              entry.value.serverConfirmed &&
              entry.value.synchronizedAt != null &&
              !entry.value.synchronizedAt!.add(dashboardGuidanceCacheRetention).isAfter(now),
        )
        .map((entry) => entry.key)
        .toList(growable: false);
    for (final key in expired) {
      _records.remove(key);
    }
    return expired.length;
  }

  @override
  Future<void> clearForUser(String userId) async {
    _records.removeWhere((key, _) => key.userId == userId);
  }
}

/// IndexedDB implementation. Every operation waits for transaction completion.
final class IdbDashboardGuidanceDraftCache implements DashboardGuidanceDraftCache {
  IdbDashboardGuidanceDraftCache({
    required this.factory,
    this.databaseName = 'stone_set_dashboard_private_v1',
  });

  static const _databaseVersion = 1;
  static const _storeName = 'guidance_draft_recovery_v1';

  final IdbFactory factory;
  final String databaseName;
  Future<Database>? _database;

  Future<Database> _open() => _database ??= factory.open(
    databaseName,
    version: _databaseVersion,
    onUpgradeNeeded: (event) {
      final database = event.database;
      if (!database.objectStoreNames.contains(_storeName)) {
        database.createObjectStore(_storeName, keyPath: 'storageKey');
      }
    },
  );

  @override
  Future<DashboardGuidanceRecoveryRecord?> read(DashboardGuidanceRecoveryKey key) async {
    final database = await _open();
    final transaction = database.transaction(_storeName, idbModeReadOnly);
    final value = await transaction.objectStore(_storeName).getObject(key.storageKey);
    await transaction.completed;
    if (value == null) return null;
    if (value is! Map) {
      throw const FormatException('Invalid IndexedDB guidance recovery record');
    }
    return DashboardGuidanceRecoveryRecord.fromStorageMap(value.cast<Object?, Object?>());
  }

  @override
  Future<DashboardGuidanceCacheWriteResult> compareAndSwap({
    required DashboardGuidanceRecoveryRecord record,
    required int? expectedLocalRevision,
  }) async {
    final database = await _open();
    final transaction = database.transaction(_storeName, idbModeReadWrite);
    final store = transaction.objectStore(_storeName);
    final existing = await store.getObject(record.key.storageKey);
    DashboardGuidanceRecoveryRecord? current;
    if (existing != null) {
      if (existing is! Map) {
        transaction.abort();
        throw const FormatException('Invalid IndexedDB guidance recovery record');
      }
      current = DashboardGuidanceRecoveryRecord.fromStorageMap(
        existing.cast<Object?, Object?>(),
      );
    }
    if (current?.localRevision != expectedLocalRevision) {
      await transaction.completed;
      return DashboardGuidanceCacheWriteResult.conflict(current);
    }
    await store.put(record.toStorageMap());
    await transaction.completed;
    return const DashboardGuidanceCacheWriteResult.saved();
  }

  @override
  Future<void> remove(DashboardGuidanceRecoveryKey key) async {
    final database = await _open();
    final transaction = database.transaction(_storeName, idbModeReadWrite);
    await transaction.objectStore(_storeName).delete(key.storageKey);
    await transaction.completed;
  }

  @override
  Future<int> cleanConfirmedForUser(String userId, DateTime now) async {
    final database = await _open();
    final transaction = database.transaction(_storeName, idbModeReadWrite);
    final store = transaction.objectStore(_storeName);
    var removed = 0;
    await for (final cursor in store.openCursor(autoAdvance: true)) {
      final value = cursor.value;
      if (value is! Map) continue;
      final record = DashboardGuidanceRecoveryRecord.fromStorageMap(
        value.cast<Object?, Object?>(),
      );
      if (record.key.userId == userId &&
          record.serverConfirmed &&
          record.synchronizedAt != null &&
          !record.synchronizedAt!.add(dashboardGuidanceCacheRetention).isAfter(now)) {
        await cursor.delete();
        removed += 1;
      }
    }
    await transaction.completed;
    return removed;
  }

  @override
  Future<void> clearForUser(String userId) async {
    final database = await _open();
    final transaction = database.transaction(_storeName, idbModeReadWrite);
    final store = transaction.objectStore(_storeName);
    await for (final cursor in store.openCursor(autoAdvance: true)) {
      final value = cursor.value;
      if (value is Map && value['userId'] == userId) {
        await cursor.delete();
      }
    }
    await transaction.completed;
  }

  void close() {
    final database = _database;
    _database = null;
    if (database != null) {
      unawaited(database.then((value) => value.close(), onError: (_) {}));
    }
  }
}
