import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/src/features/fixtures/dashboard_overview_fixture_repository.dart';
import 'package:stone_set_dashboard/src/features/fixtures/dashboard_overview_fixture_service.dart';
import 'package:stone_set_dashboard/src/features/fixtures/dashboard_overview_fixtures.dart';
import 'package:stone_set_dashboard/src/features/overview/controllers/dashboard_overview_controller.dart';

void main() {
  test('controller loads the requested scenario through its repository contract', () async {
    final repository = _RecordingOverviewRepository();
    final container = ProviderContainer(
      overrides: [dashboardOverviewRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final provider = dashboardOverviewControllerProvider(
      DashboardOverviewFixtureScenario.saveConflict,
    );
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final fixture = await container.read(provider.future);

    expect(repository.requested, [DashboardOverviewFixtureScenario.saveConflict]);
    expect(
      fixture.attentionItems.single.action.label,
      'Compare versions',
    );
  });

  test('controller preserves bounded repository failures for the view', () async {
    final container = ProviderContainer(
      overrides: [
        dashboardOverviewRepositoryProvider.overrideWithValue(
          const _FailingOverviewRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final provider = dashboardOverviewControllerProvider(
      DashboardOverviewFixtureScenario.populated,
    );
    final error = Completer<Object?>();
    final subscription = container.listen(
      provider,
      (_, next) {
        if (next.hasError && !error.isCompleted) {
          error.complete(next.error);
        }
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    expect(await error.future, isA<DashboardFixtureException>());
  });
}

final class _RecordingOverviewRepository implements DashboardOverviewFixtureRepository {
  final List<DashboardOverviewFixtureScenario> requested = [];

  @override
  Future<DashboardOverviewFixture> load(
    DashboardOverviewFixtureScenario scenario,
  ) async {
    requested.add(scenario);
    return const DashboardOverviewFixtureService().load(scenario);
  }
}

final class _FailingOverviewRepository implements DashboardOverviewFixtureRepository {
  const _FailingOverviewRepository();

  @override
  Future<DashboardOverviewFixture> load(
    DashboardOverviewFixtureScenario scenario,
  ) => Future<DashboardOverviewFixture>.error(
    const DashboardFixtureException('bounded fixture failure'),
  );
}
