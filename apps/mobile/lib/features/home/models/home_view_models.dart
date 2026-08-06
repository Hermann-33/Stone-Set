import 'package:flutter/foundation.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

enum HomeBannerKind { information, provisional, pending, stale, offline, error }

@immutable
final class HomeBannerViewData {
  const HomeBannerViewData({required this.kind, required this.message});

  final HomeBannerKind kind;
  final String message;
}

@immutable
final class HomeRankViewData {
  const HomeRankViewData({
    required this.rankId,
    required this.rankRating,
    required this.currentMinimum,
    required this.progress,
    required this.percentageLabel,
    this.nextRankId,
    this.nextMinimum,
    this.provisionalProgress,
    this.pendingLabel,
  }) : assert(progress >= 0 && progress <= 1),
       assert(provisionalProgress == null || provisionalProgress >= 0),
       assert(provisionalProgress == null || provisionalProgress <= 1);

  final StoneSetRankPresentationId rankId;
  final int rankRating;
  final int currentMinimum;
  final double progress;
  final String percentageLabel;
  final StoneSetRankPresentationId? nextRankId;
  final int? nextMinimum;
  final double? provisionalProgress;
  final String? pendingLabel;
}

enum TodayPlanItemStatus {
  available,
  active,
  pendingSynchronization,
  completed,
  rest,
  locked,
  unavailable,
}

enum TodayPlanItemAction { start, continueWorkout, synchronize, viewResult, openWeek, retry, none }

@immutable
final class TodayPlanItemViewData {
  const TodayPlanItemViewData({
    required this.title,
    required this.purpose,
    required this.status,
    required this.action,
    required this.actionLabel,
    required this.actionEnabled,
    this.estimatedDuration,
    this.unavailableReason,
  });

  final String title;
  final String purpose;
  final TodayPlanItemStatus status;
  final TodayPlanItemAction action;
  final String actionLabel;
  final bool actionEnabled;
  final String? estimatedDuration;
  final String? unavailableReason;
}

enum WeekDayStatus { upcoming, today, completed, rest, locked, pending }

@immutable
final class WeekDayViewData {
  const WeekDayViewData({
    required this.dayLabel,
    required this.dateLabel,
    required this.itemLabel,
    required this.status,
    this.selected = false,
  });

  final String dayLabel;
  final String dateLabel;
  final String itemLabel;
  final WeekDayStatus status;
  final bool selected;
}

@immutable
final class HomeMetricViewData {
  const HomeMetricViewData({
    required this.label,
    required this.value,
    required this.supportingText,
  });

  final String label;
  final String value;
  final String supportingText;
}

@immutable
final class HomeViewData {
  const HomeViewData({
    required this.rank,
    required this.today,
    required this.week,
    required this.metrics,
    required this.fixtureLabel,
    this.banner,
    this.isEmpty = false,
  });

  final HomeRankViewData rank;
  final TodayPlanItemViewData today;
  final List<WeekDayViewData> week;
  final List<HomeMetricViewData> metrics;
  final String fixtureLabel;
  final HomeBannerViewData? banner;
  final bool isEmpty;
}
