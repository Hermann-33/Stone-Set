import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_domain/scheduling.dart';

const int mobileSnapshotSchemaVersion = 1;
const String identityBootstrapSnapshotKey = 'identity.bootstrap';
const String currentWeekSnapshotKey = 'week.current';
const String progressSnapshotKey = 'progress.current';

Map<String, Object?> encodeIdentityBootstrap(IdentityBootstrap value) =>
    <String, Object?>{
      'profile': <String, Object?>{
        'userId': value.profile.userId,
        'normalizedUsername': value.profile.normalizedUsername,
        'displayName': value.profile.displayName,
        'active': value.profile.active,
        'mustChangePassword': value.profile.mustChangePassword,
        'rewardTimezone': value.profile.rewardTimezone,
        'revision': value.profile.revision,
      },
      'preferences': <String, Object?>{
        'loadUnit': value.preferences.loadUnit,
        'appearanceMode': value.preferences.appearanceMode,
        'reducedMotion': value.preferences.reducedMotion,
        'hapticsEnabled': value.preferences.hapticsEnabled,
        'locale': value.preferences.locale,
        'restTimerSoundEnabled': value.preferences.restTimerSoundEnabled,
        'workoutRemindersEnabled': value.preferences.workoutRemindersEnabled,
        'reminderLocalTime': value.preferences.reminderLocalTime,
        'revision': value.preferences.revision,
      },
      'compatibility': <String, Object?>{
        'maintenanceMode': value.compatibility.maintenanceMode,
        'readOnlyMode': value.compatibility.readOnlyMode,
        'clientCompatible': value.compatibility.clientCompatible,
        'configVersion': value.compatibility.configVersion,
        'minimumBuild': value.compatibility.minimumBuild,
        'recommendedMobileBuild': value.compatibility.recommendedMobileBuild,
        'messageCode': value.compatibility.messageCode,
        'messageText': value.compatibility.messageText,
        'features': value.compatibility.features,
      },
      'serverTime': value.serverTime.toUtc().toIso8601String(),
      'correlationId': value.correlationId,
      'capabilities': value.capabilities.toList(growable: false),
      'schemaContract': value.schemaContract,
    };

IdentityBootstrap decodeIdentityBootstrap(Map<String, Object?> value) {
  final profile = _map(value['profile']);
  final preferences = _map(value['preferences']);
  final compatibility = _map(value['compatibility']);
  return IdentityBootstrap(
    profile: IdentityProfile(
      userId: _string(profile, 'userId'),
      normalizedUsername: _string(profile, 'normalizedUsername'),
      displayName: _string(profile, 'displayName'),
      active: _bool(profile, 'active'),
      mustChangePassword: _bool(profile, 'mustChangePassword'),
      rewardTimezone: _string(profile, 'rewardTimezone'),
      revision: _int(profile, 'revision'),
    ),
    preferences: IdentityPreferences(
      loadUnit: _string(preferences, 'loadUnit'),
      appearanceMode: _string(preferences, 'appearanceMode'),
      reducedMotion: _bool(preferences, 'reducedMotion'),
      hapticsEnabled: _bool(preferences, 'hapticsEnabled'),
      locale: _string(preferences, 'locale'),
      restTimerSoundEnabled: _bool(preferences, 'restTimerSoundEnabled'),
      workoutRemindersEnabled: _bool(preferences, 'workoutRemindersEnabled'),
      reminderLocalTime: preferences['reminderLocalTime'] as String?,
      revision: _int(preferences, 'revision'),
    ),
    compatibility: IdentityCompatibility(
      maintenanceMode: _bool(compatibility, 'maintenanceMode'),
      readOnlyMode: _bool(compatibility, 'readOnlyMode'),
      clientCompatible: _bool(compatibility, 'clientCompatible'),
      configVersion: _int(compatibility, 'configVersion'),
      minimumBuild: _int(compatibility, 'minimumBuild'),
      recommendedMobileBuild: _int(compatibility, 'recommendedMobileBuild'),
      messageCode: compatibility['messageCode'] as String?,
      messageText: compatibility['messageText'] as String?,
      features: _mapOrEmpty(compatibility['features']),
    ),
    serverTime: DateTime.parse(_string(value, 'serverTime')),
    correlationId: _string(value, 'correlationId'),
    capabilities: _list(value['capabilities']).map(_listString).toSet(),
    schemaContract: _int(value, 'schemaContract'),
  );
}

Map<String, Object?> encodeWeekLoadResult(WeekLoadResult value) => <String, Object?>{
  'status': value.status.name,
  'wallet': <String, Object?>{
    'userId': value.wallet.userId,
    'balance': value.wallet.balance,
    'lifetimeGranted': value.wallet.lifetimeGranted,
    'lifetimeConsumed': value.wallet.lifetimeConsumed,
  },
  'week': value.week == null ? null : _encodeWeek(value.week!),
};

Map<String, Object?> _encodeWeek(TrainingWeek value) => <String, Object?>{
  'id': value.id,
  'userId': value.userId,
  'routineVersionId': value.routineVersionId,
  'weekStart': value.weekStart.toIso8601String(),
  'weekEnd': value.weekEnd.toIso8601String(),
  'rewardTimezone': value.rewardTimezone,
  'rankConfigVersion': value.rankConfigVersion,
  'scheduleConfigVersion': value.scheduleConfigVersion,
  'confirmedSwapCount': value.confirmedSwapCount,
  'items': value.items
      .map(
        (item) => <String, Object?>{
          'id': item.id,
          'weekId': item.weekId,
          'routineVersionDayId': item.routineVersionDayId,
          'originalDayIndex': item.originalDayIndex,
          'originalDate': item.originalDate.toIso8601String(),
          'currentDate': item.currentDate.toIso8601String(),
          'itemType': item.itemType.name,
          'title': item.title,
          'purpose': item.purpose,
          'allocatedRr': item.allocatedRr,
          'allocatedBaseXp': item.allocatedBaseXp,
          'allocatedMissedPenaltyRr': item.allocatedMissedPenaltyRr,
          'lockState': item.lockState.name,
          'isToday': item.isToday,
        },
      )
      .toList(growable: false),
};

WeekLoadResult decodeWeekLoadResult(Map<String, Object?> value) {
  final walletMap = _map(value['wallet']);
  final wallet = FreeSwapWallet(
    userId: _string(walletMap, 'userId'),
    balance: _int(walletMap, 'balance'),
    lifetimeGranted: _int(walletMap, 'lifetimeGranted'),
    lifetimeConsumed: _int(walletMap, 'lifetimeConsumed'),
  );
  final status = WeekLoadStatus.values.byName(_string(value, 'status'));
  final rawWeek = value['week'];
  if (status == WeekLoadStatus.noPublishedRoutine || rawWeek == null) {
    return WeekLoadResult(status: status, wallet: wallet);
  }
  final week = _map(rawWeek);
  return WeekLoadResult(
    status: status,
    wallet: wallet,
    week: TrainingWeek(
      id: _string(week, 'id'),
      userId: _string(week, 'userId'),
      routineVersionId: _string(week, 'routineVersionId'),
      weekStart: DateTime.parse(_string(week, 'weekStart')),
      weekEnd: DateTime.parse(_string(week, 'weekEnd')),
      rewardTimezone: _string(week, 'rewardTimezone'),
      rankConfigVersion: _string(week, 'rankConfigVersion'),
      scheduleConfigVersion: _string(week, 'scheduleConfigVersion'),
      confirmedSwapCount: _int(week, 'confirmedSwapCount'),
      items: _list(week['items']).map((raw) {
        final item = _map(raw);
        return TrainingWeekItem(
          id: _string(item, 'id'),
          weekId: _string(item, 'weekId'),
          routineVersionDayId: _string(item, 'routineVersionDayId'),
          originalDayIndex: _int(item, 'originalDayIndex'),
          originalDate: DateTime.parse(_string(item, 'originalDate')),
          currentDate: DateTime.parse(_string(item, 'currentDate')),
          itemType: TrainingWeekItemType.values.byName(_string(item, 'itemType')),
          title: item['title'] as String? ?? '',
          purpose: item['purpose'] as String?,
          allocatedRr: _int(item, 'allocatedRr'),
          allocatedBaseXp: _int(item, 'allocatedBaseXp'),
          allocatedMissedPenaltyRr: _int(item, 'allocatedMissedPenaltyRr'),
          lockState: TrainingWeekLockState.values.byName(_string(item, 'lockState')),
          isToday: _bool(item, 'isToday'),
        );
      }),
    ),
  );
}

Map<String, Object?> encodeProgressSnapshot(ProgressSnapshot value) => <String, Object?>{
  'account': <String, Object?>{
    'userId': value.account.userId,
    'rrBalance': value.account.rrBalance,
    'lifetimeXp': value.account.lifetimeXp,
    'rankId': value.account.rankId,
    'currentMinimum': value.account.currentMinimum,
    'activeConsistencyMultiplier': value.account.activeConsistencyMultiplier,
    'nextRankId': value.account.nextRankId,
    'nextMinimum': value.account.nextMinimum,
    'progress': value.account.progress,
  },
  'ranks': value.ranks
      .map(
        (rank) => <String, Object?>{
          'id': rank.id,
          'displayName': rank.displayName,
          'minimumRr': rank.minimumRr,
        },
      )
      .toList(growable: false),
  'transactions': value.transactions
      .map(
        (transaction) => <String, Object?>{
          'id': transaction.id,
          'kind': transaction.kind.name,
          'sourceType': transaction.sourceType,
          'sourceId': transaction.sourceId,
          'delta': transaction.delta,
          'createdAt': transaction.createdAt.toUtc().toIso8601String(),
        },
      )
      .toList(growable: false),
  'workouts': value.workouts
      .map(
        (workout) => <String, Object?>{
          'resultId': workout.resultId,
          'planItemId': workout.planItemId,
          'date': workout.date.toIso8601String(),
          'status': workout.status.name,
          'plannedSets': workout.plannedSets,
          'completedSets': workout.completedSets,
          'submittedAt': workout.submittedAt.toUtc().toIso8601String(),
        },
      )
      .toList(growable: false),
};

ProgressSnapshot decodeProgressSnapshot(Map<String, Object?> value) {
  final account = _map(value['account']);
  return ProgressSnapshot(
    account: RankAccount(
      userId: _string(account, 'userId'),
      rrBalance: _int(account, 'rrBalance'),
      lifetimeXp: _int(account, 'lifetimeXp'),
      rankId: _string(account, 'rankId'),
      currentMinimum: _int(account, 'currentMinimum'),
      activeConsistencyMultiplier: _number(
        account,
        'activeConsistencyMultiplier',
      ).toDouble(),
      nextRankId: account['nextRankId'] as String?,
      nextMinimum: _nullableInt(account['nextMinimum']),
      progress: _number(account, 'progress').toDouble(),
    ),
    ranks: _list(value['ranks']).map((raw) {
      final rank = _map(raw);
      return RankDefinition(
        id: _string(rank, 'id'),
        displayName: _string(rank, 'displayName'),
        minimumRr: _int(rank, 'minimumRr'),
      );
    }).toList(growable: false),
    transactions: _list(value['transactions']).map((raw) {
      final transaction = _map(raw);
      return ProgressTransaction(
        id: _string(transaction, 'id'),
        kind: ProgressTransactionKind.values.byName(_string(transaction, 'kind')),
        sourceType: _string(transaction, 'sourceType'),
        sourceId: _string(transaction, 'sourceId'),
        delta: _int(transaction, 'delta'),
        createdAt: DateTime.parse(_string(transaction, 'createdAt')),
      );
    }).toList(growable: false),
    workouts: _list(value['workouts']).map((raw) {
      final workout = _map(raw);
      return WorkoutHistoryItem(
        resultId: _string(workout, 'resultId'),
        planItemId: _string(workout, 'planItemId'),
        date: DateTime.parse(_string(workout, 'date')),
        status: WorkoutHistoryStatus.values.byName(_string(workout, 'status')),
        plannedSets: _int(workout, 'plannedSets'),
        completedSets: _int(workout, 'completedSets'),
        submittedAt: DateTime.parse(_string(workout, 'submittedAt')),
      );
    }).toList(growable: false),
  );
}

void validateIdentityOwner(String ownerId, IdentityBootstrap value) {
  if (value.profile.userId != ownerId) {
    throw const FormatException('Cached identity owner mismatch.');
  }
}

void validateWeekOwner(String ownerId, WeekLoadResult value) {
  if (value.wallet.userId != ownerId ||
      (value.week != null && value.week!.userId != ownerId)) {
    throw const FormatException('Cached week owner mismatch.');
  }
}

void validateProgressOwner(String ownerId, ProgressSnapshot value) {
  if (value.account.userId != ownerId) {
    throw const FormatException('Cached progress owner mismatch.');
  }
}

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) {
    throw const FormatException('Expected object.');
  }
  return <String, Object?>{
    for (final entry in value.entries)
      if (entry.key is String) entry.key! as String: entry.value,
  };
}

Map<String, Object?> _mapOrEmpty(Object? value) =>
    value == null ? const <String, Object?>{} : _map(value);

List<Object?> _list(Object? value) {
  if (value is! List<Object?>) throw const FormatException('Expected list.');
  return value;
}

String _listString(Object? value) {
  if (value is! String) throw const FormatException('Expected string list item.');
  return value;
}

String _string(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! String || item.isEmpty) throw FormatException('Expected $key string.');
  return item;
}

int _int(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! int) throw FormatException('Expected $key integer.');
  return item;
}

int? _nullableInt(Object? value) => switch (value) {
  null => null,
  int item => item,
  _ => throw const FormatException('Expected nullable integer.'),
};

num _number(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! num) throw FormatException('Expected $key number.');
  return item;
}

bool _bool(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! bool) throw FormatException('Expected $key boolean.');
  return item;
}
