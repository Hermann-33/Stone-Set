import '../../home/data/home_repository.dart';
import '../../home/models/home_view_models.dart';
import '../models/home_fixture_scenario.dart';
import 'home_fixture_service.dart';

final class FixtureHomeRepository implements HomeRepository {
  const FixtureHomeRepository(this._service);

  final HomeFixtureService _service;

  @override
  Future<HomeViewData> load(HomeFixtureScenario scenario) async => _service.load(scenario);
}
