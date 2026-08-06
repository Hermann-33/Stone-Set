import '../../fixtures/models/home_fixture_scenario.dart';
import '../models/home_view_models.dart';

abstract interface class HomeRepository {
  Future<HomeViewData> load(HomeFixtureScenario scenario);
}
