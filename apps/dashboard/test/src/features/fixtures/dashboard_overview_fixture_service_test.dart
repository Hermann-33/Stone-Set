import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/src/features/fixtures/dashboard_overview_fixture_service.dart';
import 'package:stone_set_dashboard/src/features/fixtures/dashboard_overview_fixtures.dart';

void main() {
  const service = DashboardOverviewFixtureService();

  group('DashboardOverviewFixtureService', () {
    test('populated fixture follows the accepted attention-first hierarchy', () async {
      final fixture = await service.load(DashboardOverviewFixtureScenario.populated);

      expect(fixture.heading, 'Focus on what needs a decision');
      expect(fixture.attentionItems, hasLength(2));
      expect(
        fixture.attentionItems.map((item) => item.action.label),
        containsAll(<String>['Resolve blockers', 'Open review queue']),
      );
      expect(fixture.resumeDrafts, isNotEmpty);
      expect(fixture.publishedRoutine, isNotNull);
      expect(fixture.activity, isNotEmpty);
      expect(fixture.quickActions, isNotEmpty);
      expect(fixture.previewNotice, contains('not saved product records'));
    });

    test('every non-transient scenario loads deterministic immutable data', () async {
      final scenarios = DashboardOverviewFixtureScenario.values.where(
        (scenario) =>
            scenario != DashboardOverviewFixtureScenario.loading &&
            scenario != DashboardOverviewFixtureScenario.error,
      );

      for (final scenario in scenarios) {
        final first = await service.load(scenario);
        final second = await service.load(scenario);

        expect(second.heading, first.heading, reason: scenario.name);
        expect(second.attentionItems.length, first.attentionItems.length, reason: scenario.name);
        expect(
          first.attentionItems.clear,
          throwsUnsupportedError,
          reason: scenario.name,
        );
      }
    });

    test('first-run state has setup guidance without pretending records exist', () async {
      final fixture = await service.load(DashboardOverviewFixtureScenario.firstRun);

      expect(fixture.isFirstRun, isTrue);
      expect(fixture.publishedRoutine, isNull);
      expect(fixture.resumeDrafts, isEmpty);
      expect(fixture.activity, isEmpty);
      expect(fixture.attentionItems.single.action.location, '/settings');
    });

    test('no-attention state removes blockers and optional activation', () async {
      final fixture = await service.load(DashboardOverviewFixtureScenario.noAttention);

      expect(fixture.attentionItems, isEmpty);
      expect(fixture.publishedRoutine?.upcomingName, isNull);
      expect(fixture.publishedRoutine?.upcomingActivationLabel, isNull);
    });

    test('offline state communicates non-authoritative limitations without color alone', () async {
      final fixture = await service.load(DashboardOverviewFixtureScenario.staleOffline);

      expect(fixture.systemStatus.condition, DashboardSystemCondition.offline);
      expect(fixture.systemStatus.label, contains('Offline'));
      expect(fixture.resumeDrafts.first.saveState, DashboardDraftSaveState.offline);
      final retry = fixture.attentionItems.single.action;
      expect(retry.enabled, isFalse);
      expect(retry.disabledReason, isNotEmpty);
    });

    test('error state returns a bounded presentation error', () async {
      expect(
        service.load(DashboardOverviewFixtureScenario.error),
        throwsA(
          isA<DashboardFixtureException>().having(
            (error) => error.message,
            'message',
            contains('No saved work was changed'),
          ),
        ),
      );
    });
  });
}
