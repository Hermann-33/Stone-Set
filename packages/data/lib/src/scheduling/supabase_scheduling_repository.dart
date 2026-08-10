import 'package:stone_set_domain/scheduling.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'scheduling_remote_service.dart';

final class SupabaseSchedulingRepository implements SchedulingRepository {
  const SupabaseSchedulingRepository({
    required this._remote,
  });

  final SchedulingRemoteService _remote;

  @override
  Future<WeekLoadResult> getOrCreateCurrentWeek() => _guard(() async {
    final value = await _remote.call(
      'get_or_create_current_week_v1',
      const <String, Object?>{},
    );
    return _weekLoad(value);
  });

  @override
  Future<SwapResult> confirmSwap({
    required String weekId,
    required String firstItemId,
    required String secondItemId,
  }) => _guard(() async {
    final value = await _remote.call('confirm_weekly_swap_v2', <String, Object?>{
      'p_week_id': weekId,
      'p_first_item_id': firstItemId,
      'p_second_item_id': secondItemId,
    });
    return SwapResult(
      week: _week(_requiredMap(value, 'week')),
      wallet: _wallet(_requiredMap(value, 'wallet')),
      swap: _swap(_requiredMap(value, 'swap')),
    );
  });
}

Future<T> _guard<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on SchedulingFailure {
    rethrow;
  } on PostgrestException catch (error) {
    final code = error.message.isNotEmpty ? error.message : (error.code ?? 'server_error');
    throw SchedulingFailure(code);
  }
}

WeekLoadResult _weekLoad(Map<String, Object?> value) {
  final status = switch (_requiredString(value, 'status')) {
    'ready' => WeekLoadStatus.ready,
    'no_published_routine' => WeekLoadStatus.noPublishedRoutine,
    _ => throw const FormatException('Unknown week load status.'),
  };
  final wallet = _wallet(_requiredMap(value, 'wallet'));
  if (status == WeekLoadStatus.noPublishedRoutine) {
    return WeekLoadResult(status: status, wallet: wallet);
  }
  return WeekLoadResult(
    status: status,
    wallet: wallet,
    week: _week(_requiredMap(value, 'week')),
  );
}

TrainingWeek _week(Map<String, Object?> value) => TrainingWeek(
  id: _requiredString(value, 'id'),
  userId: _requiredString(value, 'userId'),
  routineVersionId: _requiredString(value, 'routineVersionId'),
  weekStart: DateTime.parse(_requiredString(value, 'weekStart')),
  weekEnd: DateTime.parse(_requiredString(value, 'weekEnd')),
  rewardTimezone: _requiredString(value, 'rewardTimezone'),
  rankConfigVersion: _requiredString(value, 'rankConfigVersion'),
  scheduleConfigVersion: _requiredString(value, 'scheduleConfigVersion'),
  confirmedSwapCount: _requiredInt(value, 'confirmedSwapCount'),
  items: _requiredList(value, 'items').map((item) => _item(_map(item))),
);

TrainingWeekItem _item(Map<String, Object?> value) => TrainingWeekItem(
  id: _requiredString(value, 'id'),
  weekId: _requiredString(value, 'weekId'),
  routineVersionDayId: _requiredString(value, 'routineVersionDayId'),
  originalDayIndex: _requiredInt(value, 'originalDayIndex'),
  originalDate: DateTime.parse(_requiredString(value, 'originalDate')),
  currentDate: DateTime.parse(_requiredString(value, 'currentDate')),
  itemType: switch (_requiredString(value, 'itemType')) {
    'workout' => TrainingWeekItemType.workout,
    'rest' => TrainingWeekItemType.rest,
    _ => throw const FormatException('Unknown training week item type.'),
  },
  title: value['title'] as String? ?? '',
  purpose: value['purpose'] as String?,
  allocatedRr: _requiredInt(value, 'allocatedRr'),
  allocatedBaseXp: _requiredInt(value, 'allocatedBaseXp'),
  allocatedMissedPenaltyRr: _requiredInt(value, 'allocatedMissedPenaltyRr'),
  lockState: switch (_requiredString(value, 'lockState')) {
    'open' => TrainingWeekLockState.open,
    'locked' => TrainingWeekLockState.locked,
    _ => throw const FormatException('Unknown training week lock state.'),
  },
  isToday: _requiredBool(value, 'isToday'),
);

FreeSwapWallet _wallet(Map<String, Object?> value) => FreeSwapWallet(
  userId: _requiredString(value, 'userId'),
  balance: _requiredInt(value, 'balance'),
  lifetimeGranted: _requiredInt(value, 'lifetimeGranted'),
  lifetimeConsumed: _requiredInt(value, 'lifetimeConsumed'),
);

WeeklySwap _swap(Map<String, Object?> value) => WeeklySwap(
  id: _requiredString(value, 'id'),
  weekId: _requiredString(value, 'weekId'),
  userId: _requiredString(value, 'userId'),
  swapNumber: _requiredInt(value, 'swapNumber'),
  firstItemId: _requiredString(value, 'firstItemId'),
  secondItemId: _requiredString(value, 'secondItemId'),
  firstDate: DateTime.parse(_requiredString(value, 'firstDate')),
  secondDate: DateTime.parse(_requiredString(value, 'secondDate')),
  createdAt: DateTime.parse(_requiredString(value, 'createdAt')),
);

Map<String, Object?> _requiredMap(Map<String, Object?> value, String key) => _map(value[key]);

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) throw const FormatException('Expected object.');
  return <String, Object?>{
    for (final entry in value.entries)
      if (entry.key is String) entry.key! as String: entry.value,
  };
}

List<Object?> _requiredList(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! List<Object?>) throw FormatException('Expected $key list.');
  return item;
}

String _requiredString(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! String || item.isEmpty) throw FormatException('Expected $key string.');
  return item;
}

int _requiredInt(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! int) throw FormatException('Expected $key integer.');
  return item;
}

bool _requiredBool(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! bool) throw FormatException('Expected $key boolean.');
  return item;
}
