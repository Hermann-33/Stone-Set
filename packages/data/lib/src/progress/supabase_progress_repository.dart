import 'package:stone_set_domain/progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'progress_remote_service.dart';

final class SupabaseProgressRepository implements ProgressRepository {
  const SupabaseProgressRepository(this._remote);

  final ProgressRemoteService _remote;

  @override
  Future<ProgressSnapshot> getProgress() async {
    try {
      return _decode(await _remote.getProgress());
    } on ProgressFailure {
      rethrow;
    } on PostgrestException catch (error) {
      throw ProgressFailure(
        error.message.isNotEmpty ? error.message : (error.code ?? 'server_error'),
      );
    }
  }
}

ProgressSnapshot _decode(Map<String, Object?> value) => ProgressSnapshot(
  account: _account(_map(value['account'])),
  ranks: _list(value['ranks']).map((item) => _rank(_map(item))).toList(growable: false),
  transactions: _list(
    value['transactions'],
  ).map((item) => _transaction(_map(item))).toList(growable: false),
  workouts: _list(
    value['workouts'],
  ).map((item) => _workout(_map(item))).toList(growable: false),
);

RankAccount _account(Map<String, Object?> value) => RankAccount(
  userId: _string(value, 'userId'),
  rrBalance: _int(value, 'rrBalance'),
  lifetimeXp: _int(value, 'lifetimeXp'),
  rankId: _string(value, 'rankId'),
  currentMinimum: _int(value, 'currentMinimum'),
  nextRankId: value['nextRankId'] as String?,
  nextMinimum: _optionalInt(value['nextMinimum']),
  progress: _number(value, 'progress').toDouble(),
);

RankDefinition _rank(Map<String, Object?> value) => RankDefinition(
  id: _string(value, 'id'),
  displayName: _string(value, 'displayName'),
  minimumRr: _int(value, 'minimumRr'),
);

ProgressTransaction _transaction(Map<String, Object?> value) => ProgressTransaction(
  id: _string(value, 'id'),
  kind: switch (_string(value, 'kind')) {
    'rr' => ProgressTransactionKind.rr,
    'xp' => ProgressTransactionKind.xp,
    _ => throw const FormatException('Unknown progress transaction kind.'),
  },
  sourceType: _string(value, 'sourceType'),
  sourceId: _string(value, 'sourceId'),
  delta: _int(value, 'delta'),
  createdAt: DateTime.parse(_string(value, 'createdAt')),
);

WorkoutHistoryItem _workout(Map<String, Object?> value) => WorkoutHistoryItem(
  resultId: _string(value, 'resultId'),
  planItemId: _string(value, 'planItemId'),
  date: DateTime.parse(_string(value, 'date')),
  status: switch (_string(value, 'status')) {
    'completed' => WorkoutHistoryStatus.completed,
    'partial' => WorkoutHistoryStatus.partial,
    _ => throw const FormatException('Unknown workout history status.'),
  },
  plannedSets: _int(value, 'plannedSets'),
  completedSets: _int(value, 'completedSets'),
  submittedAt: DateTime.parse(_string(value, 'submittedAt')),
);

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) throw const FormatException('Expected object.');
  return <String, Object?>{
    for (final entry in value.entries)
      if (entry.key is String) entry.key! as String: entry.value,
  };
}

List<Object?> _list(Object? value) {
  if (value is! List<Object?>) throw const FormatException('Expected list.');
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

num _number(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! num) throw FormatException('Expected $key number.');
  return item;
}

int? _optionalInt(Object? value) => switch (value) {
  null => null,
  int value => value,
  _ => throw const FormatException('Expected nullable integer.'),
};
