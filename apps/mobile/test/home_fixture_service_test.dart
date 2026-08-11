import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_mobile/features/fixtures/data/home_fixture_service.dart';
import 'package:stone_set_mobile/features/fixtures/models/home_fixture_scenario.dart';
import 'package:stone_set_mobile/features/home/models/home_view_models.dart';

void main() {
  const service = HomeFixtureService();

  test('every fixture scenario is deterministic and presentation-only', () {
    for (final scenario in HomeFixtureScenario.values.where(
      (scenario) => scenario != HomeFixtureScenario.error,
    )) {
      final first = service.load(scenario);
      final second = service.load(scenario);

      expect(second.fixtureLabel, first.fixtureLabel, reason: scenario.name);
      expect(second.rank.rankId, first.rank.rankId, reason: scenario.name);
      expect(second.rank.rankRating, first.rank.rankRating, reason: scenario.name);
      expect(second.rank.progress, first.rank.progress, reason: scenario.name);
      expect(second.today.action, first.today.action, reason: scenario.name);
      expect(first.week, hasLength(7), reason: scenario.name);
      expect(first.metrics, hasLength(3), reason: scenario.name);
    }
  });

  test('today states expose the accepted action labels and availability', () {
    const expectations =
        <HomeFixtureScenario, (TodayPlanItemStatus, TodayPlanItemAction, String, bool)>{
          HomeFixtureScenario.standard: (
            TodayPlanItemStatus.available,
            TodayPlanItemAction.start,
            'Start workout',
            true,
          ),
          HomeFixtureScenario.activeWorkout: (
            TodayPlanItemStatus.active,
            TodayPlanItemAction.continueWorkout,
            'Continue workout',
            true,
          ),
          HomeFixtureScenario.pendingSynchronization: (
            TodayPlanItemStatus.pendingSynchronization,
            TodayPlanItemAction.synchronize,
            'Sync workout',
            true,
          ),
          HomeFixtureScenario.completedWorkout: (
            TodayPlanItemStatus.completed,
            TodayPlanItemAction.viewResult,
            'View result',
            true,
          ),
          HomeFixtureScenario.restDay: (
            TodayPlanItemStatus.rest,
            TodayPlanItemAction.openWeek,
            'View week',
            true,
          ),
          HomeFixtureScenario.lockedWorkout: (
            TodayPlanItemStatus.locked,
            TodayPlanItemAction.none,
            'Locked',
            false,
          ),
          HomeFixtureScenario.unavailableWorkout: (
            TodayPlanItemStatus.unavailable,
            TodayPlanItemAction.retry,
            'Retry',
            true,
          ),
        };

    for (final entry in expectations.entries) {
      final today = service.load(entry.key).today;
      final expected = entry.value;
      expect(
        (today.status, today.action, today.actionLabel, today.actionEnabled),
        expected,
        reason: entry.key.name,
      );
    }
  });

  test('pending and provisional fixtures never move the authoritative snapshot', () {
    final standard = service.load(HomeFixtureScenario.standard);
    final pending = service.load(HomeFixtureScenario.pendingSynchronization);
    final provisional = service.load(HomeFixtureScenario.provisional);

    expect(pending.rank.rankRating, standard.rank.rankRating);
    expect(pending.rank.progress, standard.rank.progress);
    expect(provisional.rank.rankRating, standard.rank.rankRating);
    expect(provisional.rank.progress, standard.rank.progress);
    expect(provisional.rank.provisionalProgress, greaterThan(provisional.rank.progress));
    expect(provisional.banner?.kind, HomeBannerKind.provisional);
  });

  test('standard preview intentionally retains its fixture multiplier', () {
    final standard = service.load(HomeFixtureScenario.standard);
    final multiplier = standard.metrics.singleWhere((metric) => metric.label == 'Multiplier');

    expect(multiplier.value, '1.5×');
    expect(multiplier.supportingText, 'Fixture state');
    expect(standard.fixtureLabel, 'Preview data');
  });

  test('error fixture fails without fabricating Home data', () {
    expect(
      () => service.load(HomeFixtureScenario.error),
      throwsA(
        isA<HomeFixtureFailure>().having(
          (failure) => failure.message,
          'message',
          'The preview could not be loaded.',
        ),
      ),
    );
  });
}
