import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/main.dart';
import 'package:stone_set_dashboard/src/features/exercises/controllers/dashboard_exercise_controllers.dart';
import 'package:stone_set_dashboard/src/features/exercises/controllers/dashboard_guidance_media_controller.dart';
import 'package:stone_set_dashboard/src/features/exercises/data/dashboard_guidance_draft_cache.dart';
import 'package:stone_set_dashboard/src/session/dashboard_private_cache.dart';
import 'package:stone_set_dashboard/src/session/dashboard_session_controller.dart';
import 'package:stone_set_domain/exercise_guidance.dart';

import '../support/fake_exercise_guidance_repository.dart';
import '../support/fake_exercise_media_repository.dart';
import '../support/fake_identity_repository.dart';

void main() {
  const surfaces = <({String name, Size size})>[
    (name: 'compact', size: Size(600, 900)),
    (name: 'medium', size: Size(900, 900)),
    (name: 'expanded', size: Size(1360, 900)),
  ];

  for (final brightness in Brightness.values) {
    for (final surface in surfaces) {
      testWidgets(
        '${surface.name} ${brightness.name} Overview',
        (tester) async {
          tester.platformDispatcher.platformBrightnessTestValue = brightness;
          tester.view.physicalSize = surface.size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final repository = FakeIdentityRepository(
            recoveredSession: testSession,
            bootstrapResult: testBootstrap(),
          );
          addTearDown(repository.dispose);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                dashboardIdentityRepositoryProvider.overrideWithValue(repository),
              ],
              child: const RepaintBoundary(
                key: Key('dashboard-golden-surface'),
                child: StoneSetDashboardApp(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          await expectLater(
            find.byKey(const Key('dashboard-golden-surface')),
            matchesGoldenFile(
              'dashboard_overview_${surface.name}_${brightness.name}.png',
            ),
          );
        },
        skip: kIsWeb,
      );
    }
  }

  final exerciseGoldenSkip = kIsWeb || Uri.base.toFilePath().contains(r'\');
  testWidgets(
    'expanded exercise library',
    (tester) async {
      await _pumpExerciseGolden(
        tester,
        repository: FakeExerciseGuidanceRepository(
          items: <ExerciseLibraryItem>[exerciseItem()],
        ),
        location: '/exercises',
      );
      await expectLater(
        find.byKey(const Key('dashboard-golden-surface')),
        matchesGoldenFile('dashboard_exercise_library_expanded_light.png'),
      );
    },
    skip: exerciseGoldenSkip,
  );

  testWidgets(
    'expanded exercise editor',
    (tester) async {
      await _pumpExerciseGolden(
        tester,
        repository: FakeExerciseGuidanceRepository(),
        location: '/exercises/new',
      );
      await expectLater(
        find.byKey(const Key('dashboard-golden-surface')),
        matchesGoldenFile('dashboard_exercise_editor_expanded_light.png'),
      );
    },
    skip: exerciseGoldenSkip,
  );

  testWidgets(
    'expanded exercise safe error',
    (tester) async {
      final repository = FakeExerciseGuidanceRepository()
        ..listFailure = const ExerciseGuidanceFailure(
          ExerciseGuidanceErrorCode.networkUnavailable,
        );
      await _pumpExerciseGolden(
        tester,
        repository: repository,
        location: '/exercises',
      );
      await expectLater(
        find.byKey(const Key('dashboard-golden-surface')),
        matchesGoldenFile('dashboard_exercise_error_expanded_light.png'),
      );
    },
    skip: exerciseGoldenSkip,
  );

  testWidgets(
    'expanded guidance conflict',
    (tester) async {
      final cache = InMemoryDashboardGuidanceDraftCache();
      const key = DashboardGuidanceRecoveryKey(
        userId: testUserId,
        exerciseId: '20000000-0000-4000-8000-000000000001',
        draftId: '40000000-0000-4000-8000-000000000001',
      );
      await cache.compareAndSwap(
        record: DashboardGuidanceRecoveryRecord(
          key: key,
          localRevision: 2,
          expectedServerRevision: 0,
          structuredPayload: const <String, Object?>{
            'schemaVersion': 1,
            'shortExplanation': 'Recovered local explanation.',
            'setupSteps': <String>[],
            'executionSteps': <String>[],
            'techniqueCues': <String>[],
            'commonMistakes': <String>[],
            'safetyNotes': <String>[],
          },
          updatedAt: DateTime.utc(2026, 8, 8),
        ),
        expectedLocalRevision: null,
      );
      await _pumpExerciseGolden(
        tester,
        repository: FakeExerciseGuidanceRepository(
          items: <ExerciseLibraryItem>[exerciseItem()],
        ),
        cache: cache,
        location:
            '/exercises/20000000-0000-4000-8000-000000000001/guidance/drafts/'
            '40000000-0000-4000-8000-000000000001',
      );
      await expectLater(
        find.byKey(const Key('dashboard-golden-surface')),
        matchesGoldenFile('dashboard_guidance_conflict_expanded_light.png'),
      );
    },
    skip: exerciseGoldenSkip,
  );
}

Future<void> _pumpExerciseGolden(
  WidgetTester tester, {
  required FakeExerciseGuidanceRepository repository,
  required String location,
  InMemoryDashboardGuidanceDraftCache? cache,
}) async {
  tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
  tester.view.physicalSize = const Size(1360, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final identity = FakeIdentityRepository(
    recoveredSession: testSession,
    bootstrapResult: testBootstrap(),
  );
  final privateCache = cache ?? InMemoryDashboardGuidanceDraftCache();
  addTearDown(identity.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardIdentityRepositoryProvider.overrideWithValue(identity),
        dashboardPrivateCacheProvider.overrideWithValue(privateCache),
        exerciseGuidanceRepositoryProvider.overrideWithValue(repository),
        exerciseMediaRepositoryProvider.overrideWithValue(FakeExerciseMediaRepository()),
        dashboardGuidanceDraftCacheProvider.overrideWithValue(privateCache),
      ],
      child: RepaintBoundary(
        key: const Key('dashboard-golden-surface'),
        child: StoneSetDashboardApp(initialLocation: location),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
