import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_domain/scheduling.dart';

import 'mobile_local_database.dart';
import 'mobile_snapshot_codec.dart';
import 'mobile_snapshot_store.dart';

final class SqfliteMobileSnapshotStore implements MobileSnapshotStore {
  SqfliteMobileSnapshotStore({Future<Database> Function()? openDatabase})
    : _openDatabase = openDatabase ?? openStoneSetMobileDatabase;

  final Future<Database> Function() _openDatabase;
  Future<Database>? _database;

  Future<Database> get _db => _database ??= _openDatabase();

  @override
  Future<IdentityBootstrap?> loadIdentityBootstrap(String ownerId) async {
    final payload = await _loadPayload(ownerId, identityBootstrapSnapshotKey);
    if (payload == null) return null;
    final bootstrap = decodeIdentityBootstrap(payload);
    validateIdentityOwner(ownerId, bootstrap);
    return bootstrap;
  }

  @override
  Future<void> saveIdentityBootstrap({
    required String ownerId,
    required IdentityBootstrap bootstrap,
    required DateTime cachedAt,
  }) async {
    validateIdentityOwner(ownerId, bootstrap);
    final now = cachedAt.toUtc();
    await (await _db).insert(
      'mobile_snapshots',
      _snapshotRow(
        ownerId: ownerId,
        key: identityBootstrapSnapshotKey,
        payload: encodeIdentityBootstrap(bootstrap),
        generationId: 'identity-${now.microsecondsSinceEpoch}',
        cachedAt: now,
        serverUpdatedAt: bootstrap.serverTime,
      ),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<WeekLoadResult?> loadCurrentWeek(String ownerId) async {
    final payload = await _loadPayload(ownerId, currentWeekSnapshotKey);
    if (payload == null) return null;
    final week = decodeWeekLoadResult(payload);
    validateWeekOwner(ownerId, week);
    return week;
  }

  @override
  Future<ProgressSnapshot?> loadProgress(String ownerId) async {
    final payload = await _loadPayload(ownerId, progressSnapshotKey);
    if (payload == null) return null;
    final progress = decodeProgressSnapshot(payload);
    validateProgressOwner(ownerId, progress);
    return progress;
  }

  @override
  Future<MobileSyncMetadata?> loadSyncMetadata(String ownerId) async {
    final rows = await (await _db).query(
      'mobile_sync_state',
      where: 'owner_id = ?',
      whereArgs: <Object?>[ownerId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    return MobileSyncMetadata(
      ownerId: ownerId,
      generationId: row['generation_id'] as String?,
      lastSuccessfulSyncAt: _dateTime(row['last_successful_sync_at']),
      lastAttemptAt: _dateTime(row['last_attempt_at']),
      lastErrorCode: row['last_error_code'] as String?,
    );
  }

  @override
  Future<String> commitSynchronizedSnapshots({
    required String ownerId,
    required WeekLoadResult week,
    required ProgressSnapshot progress,
    required DateTime synchronizedAt,
  }) async {
    validateWeekOwner(ownerId, week);
    validateProgressOwner(ownerId, progress);
    final when = synchronizedAt.toUtc();
    final generationId = 'sync-${when.microsecondsSinceEpoch}';
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert(
        'mobile_snapshots',
        _snapshotRow(
          ownerId: ownerId,
          key: currentWeekSnapshotKey,
          payload: encodeWeekLoadResult(week),
          generationId: generationId,
          cachedAt: when,
          serverUpdatedAt: when,
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'mobile_snapshots',
        _snapshotRow(
          ownerId: ownerId,
          key: progressSnapshotKey,
          payload: encodeProgressSnapshot(progress),
          generationId: generationId,
          cachedAt: when,
          serverUpdatedAt: when,
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert('mobile_sync_state', <String, Object?>{
        'owner_id': ownerId,
        'generation_id': generationId,
        'last_successful_sync_at': when.toIso8601String(),
        'last_attempt_at': when.toIso8601String(),
        'last_error_code': null,
        'updated_at': when.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
    return generationId;
  }

  @override
  Future<void> recordSyncFailure({
    required String ownerId,
    required DateTime attemptedAt,
    required String errorCode,
  }) async {
    final when = attemptedAt.toUtc();
    final db = await _db;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'mobile_sync_state',
        where: 'owner_id = ?',
        whereArgs: <Object?>[ownerId],
        limit: 1,
      );
      final previous = rows.isEmpty ? null : rows.single;
      await txn.insert('mobile_sync_state', <String, Object?>{
        'owner_id': ownerId,
        'generation_id': previous?['generation_id'],
        'last_successful_sync_at': previous?['last_successful_sync_at'],
        'last_attempt_at': when.toIso8601String(),
        'last_error_code': errorCode,
        'updated_at': when.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  @override
  Future<void> clearReadSnapshots(String ownerId) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'mobile_snapshots',
        where: 'owner_id = ?',
        whereArgs: <Object?>[ownerId],
      );
      await txn.delete(
        'mobile_sync_state',
        where: 'owner_id = ?',
        whereArgs: <Object?>[ownerId],
      );
    });
  }

  Future<Map<String, Object?>?> _loadPayload(String ownerId, String key) async {
    final rows = await (await _db).query(
      'mobile_snapshots',
      columns: const <String>['schema_version', 'payload_json'],
      where: 'owner_id = ? and snapshot_key = ?',
      whereArgs: <Object?>[ownerId, key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    if (row['schema_version'] != mobileSnapshotSchemaVersion) {
      return null;
    }
    final decoded = jsonDecode(row['payload_json']! as String);
    if (decoded is! Map<Object?, Object?>) {
      throw const FormatException('Invalid mobile snapshot payload.');
    }
    return <String, Object?>{
      for (final entry in decoded.entries)
        if (entry.key is String) entry.key! as String: entry.value,
    };
  }
}

Map<String, Object?> _snapshotRow({
  required String ownerId,
  required String key,
  required Map<String, Object?> payload,
  required String generationId,
  required DateTime cachedAt,
  DateTime? serverUpdatedAt,
}) => <String, Object?>{
  'owner_id': ownerId,
  'snapshot_key': key,
  'schema_version': mobileSnapshotSchemaVersion,
  'payload_json': jsonEncode(payload),
  'server_updated_at': serverUpdatedAt?.toUtc().toIso8601String(),
  'cached_at': cachedAt.toUtc().toIso8601String(),
  'generation_id': generationId,
};

DateTime? _dateTime(Object? value) => value is String ? DateTime.parse(value) : null;
