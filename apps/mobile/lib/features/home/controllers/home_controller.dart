import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../fixtures/models/home_fixture_scenario.dart';
import '../../fixtures/providers/home_fixture_providers.dart';
import '../../week/providers/scheduling_providers.dart';
import '../data/live_home_schedule_mapper.dart';
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
  (ref, request) async {
    if (request.userId.isEmpty) {
      throw ArgumentError.value(request.userId, 'userId', 'Authenticated user ID is required.');
    }
    final fixture = await ref.watch(homeRepositoryProvider).load(request.scenario);
    if (request.scenario != HomeFixtureScenario.standard) return fixture;
    final liveWeek = await ref.watch(schedulingRepositoryProvider).getOrCreateCurrentWeek();
    return mergeLiveWeekIntoHome(fixture, liveWeek);
  },
  name: 'homeControllerProvider',
);
