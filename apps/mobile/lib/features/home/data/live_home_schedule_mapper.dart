import 'package:stone_set_domain/scheduling.dart';

import '../models/home_view_models.dart';

HomeViewData mergeLiveWeekIntoHome(HomeViewData base, WeekLoadResult result) {
  final metrics = _metrics(base.metrics, result.wallet.balance);
  final week = result.week;
  if (week == null) {
    return HomeViewData(
      rank: base.rank,
      today: base.today,
      week: base.week,
      metrics: metrics,
      fixtureLabel: 'Live schedule · rank preview',
      banner: base.banner,
      isEmpty: true,
    );
  }

  final items = [...week.items]..sort((a, b) => a.currentDate.compareTo(b.currentDate));
  TrainingWeekItem? today;
  for (final item in items) {
    if (item.isToday) {
      today = item;
      break;
    }
  }

  return HomeViewData(
    rank: base.rank,
    today: _today(today),
    week: items.map(_weekDay).toList(growable: false),
    metrics: metrics,
    fixtureLabel: 'Live schedule · rank preview',
    banner: base.banner,
  );
}

TodayPlanItemViewData _today(TrainingWeekItem? item) {
  if (item == null) {
    return const TodayPlanItemViewData(
      title: 'No item today',
      purpose: 'Open Week to review the current schedule.',
      status: TodayPlanItemStatus.unavailable,
      action: TodayPlanItemAction.openWeek,
      actionLabel: 'View week',
      actionEnabled: true,
    );
  }
  if (item.itemType == TrainingWeekItemType.rest) {
    return TodayPlanItemViewData(
      title: item.title.isEmpty ? 'Programmed recovery' : item.title,
      purpose: item.purpose ?? 'Rest supports the next scheduled training day.',
      status: TodayPlanItemStatus.rest,
      action: TodayPlanItemAction.openWeek,
      actionLabel: 'View week',
      actionEnabled: true,
    );
  }
  if (item.lockState == TrainingWeekLockState.locked) {
    return TodayPlanItemViewData(
      title: item.title.isEmpty ? 'Workout' : item.title,
      purpose: item.purpose ?? 'Scheduled workout.',
      status: TodayPlanItemStatus.locked,
      action: TodayPlanItemAction.none,
      actionLabel: 'Locked',
      actionEnabled: false,
    );
  }
  return TodayPlanItemViewData(
    title: item.title.isEmpty ? 'Workout' : item.title,
    purpose: item.purpose ?? 'Scheduled workout.',
    status: TodayPlanItemStatus.available,
    action: TodayPlanItemAction.start,
    actionLabel: 'Start workout',
    actionEnabled: true,
  );
}

WeekDayViewData _weekDay(TrainingWeekItem item) => WeekDayViewData(
  dayLabel: const <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'][item.currentDate.weekday - 1],
  dateLabel: '${item.currentDate.day}',
  itemLabel: item.itemType == TrainingWeekItemType.rest
      ? 'Rest'
      : (item.title.isEmpty ? 'Workout' : item.title),
  status: item.itemType == TrainingWeekItemType.rest
      ? WeekDayStatus.rest
      : item.isToday
      ? WeekDayStatus.today
      : item.lockState == TrainingWeekLockState.locked
      ? WeekDayStatus.locked
      : WeekDayStatus.upcoming,
  selected: item.isToday,
);

List<HomeMetricViewData> _metrics(List<HomeMetricViewData> existing, int freeSwapBalance) {
  var replaced = false;
  final values = <HomeMetricViewData>[
    for (final metric in existing)
      if (metric.label == 'Free swaps')
        HomeMetricViewData(
          label: metric.label,
          value: '$freeSwapBalance',
          supportingText: 'Live balance',
        )
      else
        metric,
  ];
  for (final metric in existing) {
    if (metric.label == 'Free swaps') {
      replaced = true;
      break;
    }
  }
  if (!replaced) {
    values.add(
      HomeMetricViewData(
        label: 'Free swaps',
        value: '$freeSwapBalance',
        supportingText: 'Live balance',
      ),
    );
  }
  return List<HomeMetricViewData>.unmodifiable(values);
}
