import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../fixtures/models/home_fixture_scenario.dart';
import '../../fixtures/providers/home_fixture_providers.dart';
import '../models/home_view_models.dart';

@immutable
final class HomeRequest {
  const HomeRequest({
    required this.userId,
    this.scenario = HomeFixtureScenario.standard,
  });

  final String userId;
  final HomeFixtureScenario scenario;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeRequest && other.userId == userId && other.scenario == scenario;

  @override
  int get hashCode => Object.hash(userId, scenario);
}

final homeControllerProvider = FutureProvider.autoDispose.family<HomeViewData, HomeRequest>(
  (ref, request) {
    if (request.userId.isEmpty) {
      throw ArgumentError.value(request.userId, 'userId', 'Authenticated user ID is required.');
    }
    return ref.watch(homeRepositoryProvider).load(request.scenario);
  },
  name: 'homeControllerProvider',
);
