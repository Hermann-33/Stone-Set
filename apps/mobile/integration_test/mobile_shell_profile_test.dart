import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_mobile/app/stone_set_mobile_app.dart';
import 'package:stone_set_mobile/features/identity/providers/identity_providers.dart';
import 'package:stone_set_mobile/features/progress/providers/progress_providers.dart';
import 'package:stone_set_mobile/features/week/providers/scheduling_providers.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../test/support/fake_identity_repository.dart';
import '../test/support/fake_progress_repository.dart';
import '../test/support/fake_scheduling_repository.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('API 24 shell and Home profile scenario meets bounded frame budgets', (tester) async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(initialSession: session);
    final schedulingRepository = FakeSchedulingRepository();
    final progressRepository = FakeProgressRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          identityRepositoryProvider.overrideWithValue(repository),
          schedulingRepositoryProvider.overrideWithValue(schedulingRepository),
          progressRepositoryProvider.overrideWithValue(progressRepository),
        ],
        child: const StoneSetMobileApp(),
      ),
    );
    await tester.pumpAndSettle();

    final bundledRanks = await Future.wait(
      StoneSetRankAssets.all.map((asset) => rootBundle.load(asset.assetKey)),
    );
    expect(bundledRanks, hasLength(20));
    expect(bundledRanks.every((asset) => asset.lengthInBytes > 0), isTrue);

    // Warm image decoding, route construction and the first rank entrance before measuring.
    await _exerciseBoundedScenario(tester);

    await binding.watchPerformance(
      () async {
        await _exerciseBoundedScenario(tester);
        await _exerciseBoundedScenario(tester);
      },
      reportKey: 'api24_profile',
    );

    final summary = binding.reportData!['api24_profile']! as Map<String, dynamic>;
    final buildTimes = _frameTimes(summary, 'frame_build_times');
    final rasterTimes = _frameTimes(summary, 'frame_rasterizer_times');
    _expectFrameBudget(buildTimes, label: 'build');
    _expectFrameBudget(rasterTimes, label: 'raster');

    summary['stone_set_thresholds'] = <String, Object>{
      'minimum_sample_count': 20,
      'required_fraction_below_32ms': 0.95,
      'maximum_frame_time_micros': 100000,
      'build_fraction_below_32ms': _fractionBelow(buildTimes, 32000),
      'raster_fraction_below_32ms': _fractionBelow(rasterTimes, 32000),
    };
  });
}

Future<void> _exerciseBoundedScenario(WidgetTester tester) async {
  await _selectDestination(tester, 'week');
  await _selectDestination(tester, 'progress');
  await _selectDestination(tester, 'profile');
  await _selectDestination(tester, 'home');

  await tester.tap(find.byKey(const Key('home-rank-hero')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('progress-rank-card')), findsOneWidget);
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();

  final homeScroll = find.byType(CustomScrollView);
  expect(homeScroll, findsOneWidget);
  await tester.drag(homeScroll, const Offset(0, -320));
  await tester.pumpAndSettle();
  await tester.drag(homeScroll, const Offset(0, 320));
  await tester.pumpAndSettle();
}

Future<void> _selectDestination(WidgetTester tester, String destination) async {
  await tester.tap(find.byKey(Key('mobile-destination-$destination')));
  await tester.pumpAndSettle();
}

List<int> _frameTimes(Map<String, dynamic> summary, String key) {
  final values = summary[key]! as List<dynamic>;
  return values.cast<num>().map((value) => value.toInt()).toList(growable: false);
}

void _expectFrameBudget(List<int> times, {required String label}) {
  expect(times.length, greaterThanOrEqualTo(20), reason: '$label frame sample count');
  expect(
    _fractionBelow(times, 32000),
    greaterThanOrEqualTo(0.95),
    reason: '$label frames below 32 ms',
  );
  expect(
    times.reduce((left, right) => left > right ? left : right),
    lessThanOrEqualTo(100000),
    reason: '$label frame maximum',
  );
}

double _fractionBelow(List<int> times, int threshold) =>
    times.where((value) => value < threshold).length / times.length;
