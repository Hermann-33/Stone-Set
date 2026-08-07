import 'dashboard_overview_fixture_service.dart';
import 'dashboard_overview_fixtures.dart';

abstract interface class DashboardOverviewFixtureRepository {
  Future<DashboardOverviewFixture> load(DashboardOverviewFixtureScenario scenario);
}

final class FixtureDashboardOverviewRepository implements DashboardOverviewFixtureRepository {
  const FixtureDashboardOverviewRepository({
    this.service = const DashboardOverviewFixtureService(),
  });

  final DashboardOverviewFixtureService service;

  @override
  Future<DashboardOverviewFixture> load(DashboardOverviewFixtureScenario scenario) =>
      service.load(scenario);
}
