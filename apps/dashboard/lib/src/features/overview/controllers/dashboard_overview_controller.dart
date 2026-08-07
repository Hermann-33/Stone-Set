import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../fixtures/dashboard_overview_fixture_repository.dart';
import '../../fixtures/dashboard_overview_fixture_service.dart';
import '../../fixtures/dashboard_overview_fixtures.dart';

final dashboardOverviewFixtureServiceProvider = Provider<DashboardOverviewFixtureService>(
  (ref) => const DashboardOverviewFixtureService(),
  name: 'dashboardOverviewFixtureServiceProvider',
);

final dashboardOverviewRepositoryProvider = Provider<DashboardOverviewFixtureRepository>(
  (ref) => FixtureDashboardOverviewRepository(
    service: ref.watch(dashboardOverviewFixtureServiceProvider),
  ),
  name: 'dashboardOverviewRepositoryProvider',
);

/// Riverpod presentation controller for immutable Overview view models.
final dashboardOverviewControllerProvider = FutureProvider.autoDispose
    .family<DashboardOverviewFixture, DashboardOverviewFixtureScenario>(
      (ref, scenario) => ref.watch(dashboardOverviewRepositoryProvider).load(scenario),
      name: 'dashboardOverviewControllerProvider',
    );
