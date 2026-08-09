enum TrainingWeekItemType { workout, rest }

enum TrainingWeekLockState { open, locked }

enum WeekLoadStatus { ready, noPublishedRoutine }

final class TrainingWeekItem {
  const TrainingWeekItem({
    required this.id,
    required this.weekId,
    required this.routineVersionDayId,
    required this.originalDayIndex,
    required this.originalDate,
    required this.currentDate,
    required this.itemType,
    required this.title,
    required this.purpose,
    required this.allocatedRr,
    required this.allocatedBaseXp,
    required this.allocatedMissedPenaltyRr,
    required this.lockState,
    required this.isToday,
  });

  final String id;
  final String weekId;
  final String routineVersionDayId;
  final int originalDayIndex;
  final DateTime originalDate;
  final DateTime currentDate;
  final TrainingWeekItemType itemType;
  final String title;
  final String? purpose;
  final int allocatedRr;
  final int allocatedBaseXp;
  final int allocatedMissedPenaltyRr;
  final TrainingWeekLockState lockState;
  final bool isToday;

  bool get isWorkout => itemType == TrainingWeekItemType.workout;
  bool get isRest => itemType == TrainingWeekItemType.rest;
}

final class TrainingWeek {
  TrainingWeek({
    required this.id,
    required this.userId,
    required this.routineVersionId,
    required this.weekStart,
    required this.weekEnd,
    required this.rewardTimezone,
    required this.rankConfigVersion,
    required this.scheduleConfigVersion,
    required this.confirmedSwapCount,
    required Iterable<TrainingWeekItem> items,
  }) : items = List<TrainingWeekItem>.unmodifiable(items);

  final String id;
  final String userId;
  final String routineVersionId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final String rewardTimezone;
  final String rankConfigVersion;
  final String scheduleConfigVersion;
  final int confirmedSwapCount;
  final List<TrainingWeekItem> items;

  int get swapsRemaining {
    final remaining = 2 - confirmedSwapCount;
    return remaining < 0 ? 0 : remaining;
  }
}

final class FreeSwapWallet {
  const FreeSwapWallet({
    required this.userId,
    required this.balance,
    required this.lifetimeGranted,
    required this.lifetimeConsumed,
  });

  final String userId;
  final int balance;
  final int lifetimeGranted;
  final int lifetimeConsumed;
}

final class WeeklySwap {
  const WeeklySwap({
    required this.id,
    required this.weekId,
    required this.userId,
    required this.swapNumber,
    required this.firstItemId,
    required this.secondItemId,
    required this.firstDate,
    required this.secondDate,
    required this.createdAt,
  });

  final String id;
  final String weekId;
  final String userId;
  final int swapNumber;
  final String firstItemId;
  final String secondItemId;
  final DateTime firstDate;
  final DateTime secondDate;
  final DateTime createdAt;
}

final class WeekLoadResult {
  const WeekLoadResult({
    required this.status,
    required this.wallet,
    this.week,
  });

  final WeekLoadStatus status;
  final TrainingWeek? week;
  final FreeSwapWallet wallet;

  bool get hasWeek => status == WeekLoadStatus.ready && week != null;
}

final class SwapResult {
  const SwapResult({
    required this.week,
    required this.wallet,
    required this.swap,
  });

  final TrainingWeek week;
  final FreeSwapWallet wallet;
  final WeeklySwap swap;
}

final class SchedulingFailure implements Exception {
  const SchedulingFailure(this.code);

  final String code;

  @override
  String toString() => 'SchedulingFailure($code)';
}
