import 'package:stone_set_domain/scheduling.dart';

final class FakeSchedulingRepository implements SchedulingRepository {
  FakeSchedulingRepository({WeekLoadResult? initial}) : current = initial ?? standardWeek();

  WeekLoadResult current;
  int confirmCalls = 0;

  @override
  Future<WeekLoadResult> getOrCreateCurrentWeek() async => current;

  @override
  Future<SwapResult> confirmSwap({
    required String weekId,
    required String firstItemId,
    required String secondItemId,
  }) async {
    confirmCalls += 1;
    final week = current.week;
    if (week == null) throw const SchedulingFailure('no_published_routine');
    if (current.wallet.balance < 1) throw const SchedulingFailure('free_swap_unavailable');
    final items = <TrainingWeekItem>[];
    final first = week.items.firstWhere((item) => item.id == firstItemId);
    final second = week.items.firstWhere((item) => item.id == secondItemId);
    for (final item in week.items) {
      if (item.id == firstItemId) {
        items.add(_copy(item, currentDate: second.currentDate));
      } else if (item.id == secondItemId) {
        items.add(_copy(item, currentDate: first.currentDate));
      } else {
        items.add(item);
      }
    }
    final updatedWeek = TrainingWeek(
      id: week.id,
      userId: week.userId,
      routineVersionId: week.routineVersionId,
      weekStart: week.weekStart,
      weekEnd: week.weekEnd,
      rewardTimezone: week.rewardTimezone,
      rankConfigVersion: week.rankConfigVersion,
      scheduleConfigVersion: week.scheduleConfigVersion,
      confirmedSwapCount: week.confirmedSwapCount + 1,
      items: items,
    );
    final updatedWallet = FreeSwapWallet(
      userId: current.wallet.userId,
      balance: current.wallet.balance - 1,
      lifetimeGranted: current.wallet.lifetimeGranted,
      lifetimeConsumed: current.wallet.lifetimeConsumed + 1,
    );
    current = WeekLoadResult(
      status: WeekLoadStatus.ready,
      week: updatedWeek,
      wallet: updatedWallet,
    );
    return SwapResult(
      week: updatedWeek,
      wallet: updatedWallet,
      swap: WeeklySwap(
        id: 'swap-$confirmCalls',
        weekId: week.id,
        userId: week.userId,
        swapNumber: updatedWeek.confirmedSwapCount,
        firstItemId: firstItemId,
        secondItemId: secondItemId,
        firstDate: first.currentDate,
        secondDate: second.currentDate,
        createdAt: DateTime.utc(2026, 8, 10, 1),
      ),
    );
  }
}

WeekLoadResult standardWeek({int freeSwapBalance = 2}) {
  const userId = '00000000-0000-4000-8000-000000000001';
  const weekId = '00000000-0000-4000-8000-000000000002';
  final start = DateTime(2026, 8, 10);
  final items = <TrainingWeekItem>[
    for (var index = 0; index < 7; index += 1)
      TrainingWeekItem(
        id: 'item-${index + 1}',
        weekId: weekId,
        routineVersionDayId: 'day-${index + 1}',
        originalDayIndex: index + 1,
        originalDate: start.add(Duration(days: index)),
        currentDate: start.add(Duration(days: index)),
        itemType: index == 2 || index == 6
            ? TrainingWeekItemType.rest
            : TrainingWeekItemType.workout,
        title: index == 3 ? 'Legs' : 'Day ${index + 1}',
        purpose: index == 2 || index == 6 ? 'Recover' : 'Train',
        allocatedRr: index == 2 || index == 6 ? 5 : 20,
        allocatedBaseXp: index == 2 || index == 6 ? 5 : 20,
        allocatedMissedPenaltyRr: index == 2 || index == 6 ? 0 : 19,
        lockState: TrainingWeekLockState.open,
        isToday: index == 3,
      ),
  ];
  return WeekLoadResult(
    status: WeekLoadStatus.ready,
    week: TrainingWeek(
      id: weekId,
      userId: userId,
      routineVersionId: '00000000-0000-4000-8000-000000000003',
      weekStart: start,
      weekEnd: start.add(const Duration(days: 6)),
      rewardTimezone: 'UTC',
      rankConfigVersion: 'rank-v6',
      scheduleConfigVersion: 'schedule-v3',
      confirmedSwapCount: 0,
      items: items,
    ),
    wallet: FreeSwapWallet(
      userId: userId,
      balance: freeSwapBalance,
      lifetimeGranted: 2,
      lifetimeConsumed: 2 - freeSwapBalance,
    ),
  );
}

WeekLoadResult noPublishedRoutine() => const WeekLoadResult(
  status: WeekLoadStatus.noPublishedRoutine,
  wallet: FreeSwapWallet(
    userId: '00000000-0000-4000-8000-000000000001',
    balance: 2,
    lifetimeGranted: 2,
    lifetimeConsumed: 0,
  ),
);

TrainingWeekItem _copy(
  TrainingWeekItem item, {
  required DateTime currentDate,
}) => TrainingWeekItem(
  id: item.id,
  weekId: item.weekId,
  routineVersionDayId: item.routineVersionDayId,
  originalDayIndex: item.originalDayIndex,
  originalDate: item.originalDate,
  currentDate: currentDate,
  itemType: item.itemType,
  title: item.title,
  purpose: item.purpose,
  allocatedRr: item.allocatedRr,
  allocatedBaseXp: item.allocatedBaseXp,
  allocatedMissedPenaltyRr: item.allocatedMissedPenaltyRr,
  lockState: item.lockState,
  isToday: item.isToday,
);
