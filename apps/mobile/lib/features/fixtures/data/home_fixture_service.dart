import 'package:stone_set_ui/stone_set_ui.dart';

import '../../home/models/home_view_models.dart';
import '../models/home_fixture_scenario.dart';

final class HomeFixtureService {
  const HomeFixtureService();

  HomeViewData load(HomeFixtureScenario scenario) {
    if (scenario == HomeFixtureScenario.error) {
      throw const HomeFixtureFailure('The preview could not be loaded.');
    }

    final base = _standard;
    return switch (scenario) {
      HomeFixtureScenario.standard => base,
      HomeFixtureScenario.zeroProgress => _withRank(
        base,
        const HomeRankViewData(
          rankId: StoneSetRankPresentationId.bronzeI,
          rankRating: 0,
          currentMinimum: 0,
          nextRankId: StoneSetRankPresentationId.bronzeII,
          nextMinimum: 100,
          progress: 0,
          percentageLabel: '0% to Bronze II',
        ),
      ),
      HomeFixtureScenario.onePercent => _withProgress(base, 0.01, '1% to Platinum III'),
      HomeFixtureScenario.halfProgress => _withProgress(base, 0.5, '50% to Platinum III'),
      HomeFixtureScenario.ninetyNinePercent => _withProgress(base, 0.99, '99% to Platinum III'),
      HomeFixtureScenario.threshold => _withRank(
        base,
        const HomeRankViewData(
          rankId: StoneSetRankPresentationId.platinumIII,
          rankRating: 2075,
          currentMinimum: 2075,
          nextRankId: StoneSetRankPresentationId.diamondI,
          nextMinimum: 2400,
          progress: 0,
          percentageLabel: '0% to Diamond I',
        ),
      ),
      HomeFixtureScenario.rankDown => _withRank(
        base,
        const HomeRankViewData(
          rankId: StoneSetRankPresentationId.platinumI,
          rankRating: 1760,
          currentMinimum: 1500,
          nextRankId: StoneSetRankPresentationId.platinumII,
          nextMinimum: 1775,
          progress: 0.945,
          percentageLabel: '95% to Platinum II',
        ),
        banner: const HomeBannerViewData(
          kind: HomeBannerKind.information,
          message: 'Rank adjusted. Open Progress for the recorded reason.',
        ),
      ),
      HomeFixtureScenario.provisional => _withRank(
        base,
        const HomeRankViewData(
          rankId: StoneSetRankPresentationId.platinumII,
          rankRating: 1910,
          currentMinimum: 1775,
          nextRankId: StoneSetRankPresentationId.platinumIII,
          nextMinimum: 2075,
          progress: 0.45,
          provisionalProgress: 0.55,
          percentageLabel: '45% to Platinum III',
          pendingLabel: '30 RR provisional',
        ),
        banner: const HomeBannerViewData(
          kind: HomeBannerKind.provisional,
          message: '30 RR is provisional and does not change your rank yet.',
        ),
      ),
      HomeFixtureScenario.pendingSynchronization => _withToday(
        base,
        _todayPending,
        banner: const HomeBannerViewData(
          kind: HomeBannerKind.pending,
          message: 'Workout pending synchronization. Rank updates after server validation.',
        ),
      ),
      HomeFixtureScenario.stale => _withBanner(
        base,
        const HomeBannerViewData(
          kind: HomeBannerKind.stale,
          message: 'This preview snapshot may be out of date.',
        ),
      ),
      HomeFixtureScenario.offline => _withBanner(
        base,
        const HomeBannerViewData(
          kind: HomeBannerKind.offline,
          message: 'Offline preview. Finalized values have not changed.',
        ),
      ),
      HomeFixtureScenario.maxRank => _withRank(
        base,
        const HomeRankViewData(
          rankId: StoneSetRankPresentationId.adonis,
          rankRating: 5500,
          currentMinimum: 5500,
          progress: 1,
          percentageLabel: 'Max rank',
        ),
      ),
      HomeFixtureScenario.activeWorkout => _withToday(base, _todayActive),
      HomeFixtureScenario.completedWorkout => _withToday(base, _todayCompleted),
      HomeFixtureScenario.restDay => _withToday(base, _todayRest),
      HomeFixtureScenario.lockedWorkout => _withToday(base, _todayLocked),
      HomeFixtureScenario.unavailableWorkout => _withToday(base, _todayUnavailable),
      HomeFixtureScenario.empty => HomeViewData(
        rank: base.rank,
        today: base.today,
        week: base.week,
        metrics: base.metrics,
        fixtureLabel: base.fixtureLabel,
        isEmpty: true,
      ),
      HomeFixtureScenario.error => throw StateError('Handled above.'),
    };
  }
}

final class HomeFixtureFailure implements Exception {
  const HomeFixtureFailure(this.message);

  final String message;
}

const _standard = HomeViewData(
  rank: HomeRankViewData(
    rankId: StoneSetRankPresentationId.platinumII,
    rankRating: 1910,
    currentMinimum: 1775,
    nextRankId: StoneSetRankPresentationId.platinumIII,
    nextMinimum: 2075,
    progress: 0.45,
    percentageLabel: '45% to Platinum III',
  ),
  today: _todayAvailable,
  week: <WeekDayViewData>[
    WeekDayViewData(
      dayLabel: 'M',
      dateLabel: '3',
      itemLabel: 'Push',
      status: WeekDayStatus.completed,
    ),
    WeekDayViewData(
      dayLabel: 'T',
      dateLabel: '4',
      itemLabel: 'Pull',
      status: WeekDayStatus.completed,
    ),
    WeekDayViewData(dayLabel: 'W', dateLabel: '5', itemLabel: 'Rest', status: WeekDayStatus.rest),
    WeekDayViewData(
      dayLabel: 'T',
      dateLabel: '6',
      itemLabel: 'Legs',
      status: WeekDayStatus.today,
      selected: true,
    ),
    WeekDayViewData(
      dayLabel: 'F',
      dateLabel: '7',
      itemLabel: 'Upper',
      status: WeekDayStatus.upcoming,
    ),
    WeekDayViewData(
      dayLabel: 'S',
      dateLabel: '8',
      itemLabel: 'Lower',
      status: WeekDayStatus.upcoming,
    ),
    WeekDayViewData(dayLabel: 'S', dateLabel: '9', itemLabel: 'Rest', status: WeekDayStatus.rest),
  ],
  metrics: <HomeMetricViewData>[
    HomeMetricViewData(label: 'Lifetime XP', value: '4,860', supportingText: 'Fixture total'),
    HomeMetricViewData(label: 'Multiplier', value: '1.5×', supportingText: 'Fixture state'),
    HomeMetricViewData(label: 'Free swaps', value: '2', supportingText: 'Fixture balance'),
  ],
  fixtureLabel: 'Preview data',
);

const _todayAvailable = TodayPlanItemViewData(
  title: 'Lower strength',
  purpose: 'Controlled compound work with posterior-chain accessories.',
  estimatedDuration: '48 min',
  status: TodayPlanItemStatus.available,
  action: TodayPlanItemAction.start,
  actionLabel: 'Start workout',
  actionEnabled: true,
);

const _todayActive = TodayPlanItemViewData(
  title: 'Lower strength',
  purpose: 'A fixture session is shown in progress.',
  estimatedDuration: '48 min',
  status: TodayPlanItemStatus.active,
  action: TodayPlanItemAction.continueWorkout,
  actionLabel: 'Continue workout',
  actionEnabled: true,
);

const _todayPending = TodayPlanItemViewData(
  title: 'Lower strength',
  purpose: 'Fixture completion is pending synchronization.',
  estimatedDuration: '48 min',
  status: TodayPlanItemStatus.pendingSynchronization,
  action: TodayPlanItemAction.synchronize,
  actionLabel: 'Sync workout',
  actionEnabled: true,
);

const _todayCompleted = TodayPlanItemViewData(
  title: 'Lower strength',
  purpose: 'Fixture result available for review.',
  estimatedDuration: '48 min',
  status: TodayPlanItemStatus.completed,
  action: TodayPlanItemAction.viewResult,
  actionLabel: 'View result',
  actionEnabled: true,
);

const _todayRest = TodayPlanItemViewData(
  title: 'Programmed recovery',
  purpose: 'Rest supports the next scheduled training day.',
  status: TodayPlanItemStatus.rest,
  action: TodayPlanItemAction.openWeek,
  actionLabel: 'View week',
  actionEnabled: true,
);

const _todayLocked = TodayPlanItemViewData(
  title: 'Lower strength',
  purpose: 'This fixture item is locked.',
  status: TodayPlanItemStatus.locked,
  action: TodayPlanItemAction.none,
  actionLabel: 'Locked',
  actionEnabled: false,
  unavailableReason: 'Available after the scheduled lock clears.',
);

const _todayUnavailable = TodayPlanItemViewData(
  title: 'Lower strength',
  purpose: 'This fixture item is temporarily unavailable.',
  status: TodayPlanItemStatus.unavailable,
  action: TodayPlanItemAction.retry,
  actionLabel: 'Retry',
  actionEnabled: true,
  unavailableReason: 'Preview data could not be refreshed.',
);

HomeViewData _withProgress(HomeViewData base, double progress, String label) => _withRank(
  base,
  HomeRankViewData(
    rankId: base.rank.rankId,
    rankRating: base.rank.rankRating,
    currentMinimum: base.rank.currentMinimum,
    nextRankId: base.rank.nextRankId,
    nextMinimum: base.rank.nextMinimum,
    progress: progress,
    percentageLabel: label,
  ),
);

HomeViewData _withRank(
  HomeViewData base,
  HomeRankViewData rank, {
  HomeBannerViewData? banner,
}) => HomeViewData(
  rank: rank,
  today: base.today,
  week: base.week,
  metrics: base.metrics,
  fixtureLabel: base.fixtureLabel,
  banner: banner,
);

HomeViewData _withToday(
  HomeViewData base,
  TodayPlanItemViewData today, {
  HomeBannerViewData? banner,
}) => HomeViewData(
  rank: base.rank,
  today: today,
  week: base.week,
  metrics: base.metrics,
  fixtureLabel: base.fixtureLabel,
  banner: banner,
);

HomeViewData _withBanner(HomeViewData base, HomeBannerViewData banner) => HomeViewData(
  rank: base.rank,
  today: base.today,
  week: base.week,
  metrics: base.metrics,
  fixtureLabel: base.fixtureLabel,
  banner: banner,
);
