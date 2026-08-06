import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/home_repository.dart';
import '../data/fixture_home_repository.dart';
import '../data/home_fixture_service.dart';

final homeFixtureServiceProvider = Provider<HomeFixtureService>(
  (ref) => const HomeFixtureService(),
  name: 'homeFixtureServiceProvider',
);

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => FixtureHomeRepository(ref.watch(homeFixtureServiceProvider)),
  name: 'homeRepositoryProvider',
);
