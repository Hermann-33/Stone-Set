import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../fixtures/models/home_fixture_scenario.dart';
import '../../fixtures/providers/home_fixture_providers.dart';
import '../../progress/providers/progress_providers.dart';
import '../../week/providers/scheduling_providers.dart';
import '../data/live_home_schedule_mapper.dart';
import '../models/home_view_models.dart';

@immutable
final class HomeRequest {
  const HomeRequest({
    required this.userId,
    this.scenario = HomeFixtureScenario.standard,
    this.useLiveSchedule = true,
  });

  final String userId;
  final HomeFixtureScenario scenario;
  final bool useLiveSchedule;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeRequest &&
          other.userId == userId &&
          other.scenario == scenario &&
          other.useLiveSchedule == useLiveSchedule;

  @override
  int get hashCode => Object.hash(userId, scenario, useLiveSchedule);
}

final homeControllerProvider = FutureProvider.autoDispose.family<HomeViewData, HomeRequest>((
  ref,
  request,
) async {
  if (request.userId.isEmpty) {
    throw ArgumentError.value(
      request.userId,
      'userId',
      'Authenticated user ID is required.',
    );
  }
  final fixture = await ref.watch(homeRepositoryProvider).load(request.scenario);
  if (!request.useLiveSchedule || request.scenario != HomeFixtureScenario.standard) return fixture;
  final liveWeek = await ref.watch(currentWeekProvider.future);
  final withWeek = mergeLiveWeekIntoHome(fixture, liveWeek);
  final progress = await ref.watch(progressSnapshotProvider.future);
  return mergeLiveProgressIntoHome(withWeek, progress);
}, name: 'homeControllerProvider');
