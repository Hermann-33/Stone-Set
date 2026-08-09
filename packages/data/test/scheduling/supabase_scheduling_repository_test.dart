import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/scheduling.dart';
import 'package:stone_set_domain/scheduling.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('decodes current week and wallet', () async {
    final repository = SupabaseSchedulingRepository(remote: _FakeRemote());
    final result = await repository.getOrCreateCurrentWeek();

    expect(result.status, WeekLoadStatus.ready);
    expect(result.week!.items, hasLength(7));
    expect(result.week!.items.singleWhere((item) => item.isToday).title, 'Legs');
    expect(result.wallet.balance, 2);
    expect(result.week!.swapsRemaining, 2);
  });

  test('decodes no published routine state', () async {
    final repository = SupabaseSchedulingRepository(remote: _FakeRemote(noRoutine: true));
    final result = await repository.getOrCreateCurrentWeek();

    expect(result.status, WeekLoadStatus.noPublishedRoutine);
    expect(result.week, isNull);
    expect(result.wallet.balance, 2);
  });

  test('sends swap ids and decodes updated state', () async {
    final remote = _FakeRemote();
    final repository = SupabaseSchedulingRepository(remote: remote);
    final result = await repository.confirmSwap(
      weekId: _FakeRemote.weekId,
      firstItemId: 'item-1',
      secondItemId: 'item-2',
    );

    expect(remote.lastFunction, 'confirm_weekly_swap_v1');
    expect(remote.lastParams['p_week_id'], _FakeRemote.weekId);
    expect(remote.lastParams['p_first_item_id'], 'item-1');
    expect(remote.lastParams['p_second_item_id'], 'item-2');
    expect(result.wallet.balance, 1);
    expect(result.week.confirmedSwapCount, 1);
    expect(result.swap.swapNumber, 1);
  });

  test('maps server scheduling error', () async {
    final repository = SupabaseSchedulingRepository(remote: _FakeRemote(failSwap: true));

    await expectLater(
      repository.confirmSwap(
        weekId: _FakeRemote.weekId,
        firstItemId: 'item-1',
        secondItemId: 'item-2',
      ),
      throwsA(isA<SchedulingFailure>().having((error) => error.code, 'code', 'free_swap_unavailable')),
    );
  });
}

final class _FakeRemote implements SchedulingRemoteService {
  _FakeRemote({this.noRoutine = false, this.failSwap = false});

  static const userId = '00000000-0000-4000-8000-000000000001';
  static const weekId = '00000000-0000-4000-8000-000000000002';
  static const versionId = '00000000-0000-4000-8000-000000000003';

  final bool noRoutine;
  final bool failSwap;
  String? lastFunction;
  Map<String, Object?> lastParams = const <String, Object?>{};

  @override
  Future<Map<String, Object?>> call(String function, Map<String, Object?> params) async {
    lastFunction = function;
    lastParams = params;
    if (function == 'get_or_create_current_week_v1') {
      return <String, Object?>{
        'status': noRoutine ? 'no_published_routine' : 'ready',
        if (!noRoutine) 'week': _week(),
        'wallet': _wallet(2),
      };
    }
    if (function == 'confirm_weekly_swap_v1') {
      if (failSwap) {
        throw const PostgrestException(message: 'free_swap_unavailable', code: '22023');
      }
      return <String, Object?>{
        'week': _week(confirmedSwapCount: 1),
        'wallet': _wallet(1),
        'swap': <String, Object?>{
          'id': '00000000-0000-4000-8000-000000000010',
          'weekId': weekId,
          'userId': userId,
          'swapNumber': 1,
          'firstItemId': 'item-1',
          'secondItemId': 'item-2',
          'firstDate': '2026-08-10',
          'secondDate': '2026-08-11',
          'createdAt': '2026-08-10T01:00:00Z',
        },
      };
    }
    throw UnsupportedError(function);
  }

  Map<String, Object?> _wallet(int balance) => <String, Object?>{
    'userId': userId,
    'balance': balance,
    'lifetimeGranted': 2,
    'lifetimeConsumed': 2 - balance,
  };

  Map<String, Object?> _week({int confirmedSwapCount = 0}) => <String, Object?>{
    'id': weekId,
    'userId': userId,
    'routineVersionId': versionId,
    'weekStart': '2026-08-10',
    'weekEnd': '2026-08-16',
    'rewardTimezone': 'UTC',
    'rankConfigVersion': 'rank-v6',
    'scheduleConfigVersion': 'schedule-v3',
    'confirmedSwapCount': confirmedSwapCount,
    'items': <Object?>[
      for (var index = 1; index <= 7; index += 1)
        <String, Object?>{
          'id': 'item-$index',
          'weekId': weekId,
          'routineVersionDayId': 'day-$index',
          'originalDayIndex': index,
          'originalDate': '2026-08-${(9 + index).toString().padLeft(2, '0')}',
          'currentDate': '2026-08-${(9 + index).toString().padLeft(2, '0')}',
          'itemType': index == 3 || index == 7 ? 'rest' : 'workout',
          'title': index == 4 ? 'Legs' : 'Day $index',
          'purpose': index == 3 || index == 7 ? 'Recover' : 'Train',
          'allocatedRr': index == 3 || index == 7 ? 5 : 20,
          'allocatedBaseXp': index == 3 || index == 7 ? 5 : 20,
          'allocatedMissedPenaltyRr': index == 3 || index == 7 ? 0 : 19,
          'lockState': 'open',
          'isToday': index == 4,
        },
    ],
  };
}
