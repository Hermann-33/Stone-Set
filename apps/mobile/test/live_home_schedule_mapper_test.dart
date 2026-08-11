import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_mobile/features/fixtures/data/home_fixture_service.dart';
import 'package:stone_set_mobile/features/fixtures/models/home_fixture_scenario.dart';
import 'package:stone_set_mobile/features/home/data/live_home_schedule_mapper.dart';

void main() {
  test('live progress replaces the fixture multiplier with server state', () {
    const fixtureService = HomeFixtureService();
    final fixture = fixtureService.load(HomeFixtureScenario.standard);
    final live = mergeLiveProgressIntoHome(
      fixture,
      const ProgressSnapshot(
        account: RankAccount(
          userId: '00000000-0000-4000-8000-000000000001',
          rrBalance: 0,
          lifetimeXp: 0,
          rankId: 'bronze_i',
          currentMinimum: 0,
          nextRankId: 'bronze_ii',
          nextMinimum: 100,
          activeConsistencyMultiplier: 1,
          progress: 0,
        ),
        ranks: <RankDefinition>[],
        transactions: <ProgressTransaction>[],
        workouts: <WorkoutHistoryItem>[],
      ),
    );

    final multiplier = live.metrics.singleWhere((metric) => metric.label == 'Multiplier');
    expect(multiplier.value, '1.00×');
    expect(multiplier.supportingText, 'Live server state');
    expect(multiplier.value, isNot('1.5×'));
    expect(live.fixtureLabel, 'Live schedule · live rank');
  });
}
