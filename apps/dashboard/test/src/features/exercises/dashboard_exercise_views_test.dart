import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/main.dart';
import 'package:stone_set_dashboard/src/features/exercises/controllers/dashboard_exercise_controllers.dart';
import 'package:stone_set_dashboard/src/features/exercises/data/dashboard_guidance_draft_cache.dart';
import 'package:stone_set_dashboard/src/session/dashboard_private_cache.dart';
import 'package:stone_set_dashboard/src/session/dashboard_session_controller.dart';
import 'package:stone_set_domain/exercise_guidance.dart';

import '../../../support/fake_exercise_guidance_repository.dart';
import '../../../support/fake_identity_repository.dart';

void main() {
  testWidgets('library renders owner summaries and sends debounced search to repository', (
    tester,
  ) async {
    final exercises = FakeExerciseGuidanceRepository(
      items: <ExerciseLibraryItem>[
        exerciseItem(),
        exerciseItem(
          id: '20000000-0000-4000-8000-000000000002',
          name: 'Front squat',
        ),
      ],
    );
    await _pumpDashboard(tester, exercises: exercises, location: '/exercises');

    expect(find.text('Incline dumbbell press'), findsOneWidget);
    expect(find.text('Front squat'), findsOneWidget);
    expect(find.bySemanticsLabel('2 exercises'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, ' incline ');
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();

    expect(exercises.queries.any((query) => query.search == 'incline'), isTrue);
    expect(find.text('Incline dumbbell press'), findsOneWidget);
    expect(find.text('Front squat'), findsNothing);
  });

  testWidgets('direct malformed exercise route resolves to safe not-found UI', (tester) async {
    await _pumpDashboard(
      tester,
      exercises: FakeExerciseGuidanceRepository(items: <ExerciseLibraryItem>[exerciseItem()]),
      location: '/exercises/not-an-id',
    );

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.textContaining('not-an-id'), findsNothing);
  });

  testWidgets('dirty create editor guards route exit and read-only mode disables commands', (
    tester,
  ) async {
    final exercises = FakeExerciseGuidanceRepository();
    await _pumpDashboard(
      tester,
      exercises: exercises,
      location: '/exercises/new',
    );

    await tester.enterText(
      find.byKey(const Key('exercise-name-field')),
      'Incline dumbbell press',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('dashboard-toolbar-cancel-exercise')));
    await tester.pumpAndSettle();

    expect(find.text('Discard unsaved exercise changes?'), findsOneWidget);
    expect(find.byKey(const Key('discard-exercise-editor')), findsOneWidget);

    await _pumpDashboard(
      tester,
      exercises: exercises,
      location: '/exercises/new',
      readOnly: true,
    );

    expect(find.textContaining('Read only.'), findsWidgets);
    final nameField = tester.widget<TextFormField>(
      find.byKey(const Key('exercise-name-field')),
    );
    expect(nameField.enabled, isFalse);
  });

  testWidgets('compact library remains operable at 200 percent text scale', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpDashboard(
      tester,
      exercises: FakeExerciseGuidanceRepository(items: <ExerciseLibraryItem>[exerciseItem()]),
      location: '/exercises',
      size: const Size(375, 900),
    );

    expect(find.byKey(const Key('dashboard-shell-compact')), findsOneWidget);
    expect(find.text('Incline dumbbell press'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exercise fields are semantically paused while save is in flight', (
    tester,
  ) async {
    final exercises = FakeExerciseGuidanceRepository();
    final blocker = Completer<ExerciseMutationResult>();
    exercises.exerciseMutationBlocker = blocker;
    await _pumpDashboard(
      tester,
      exercises: exercises,
      location: '/exercises/new',
      size: const Size(1440, 900),
    );

    await tester.enterText(
      find.byKey(const Key('exercise-name-field')),
      'Incline dumbbell press',
    );
    await tester.enterText(
      find.byKey(const Key('exercise-equipment-field')),
      'dumbbell',
    );
    await tester.tap(find.byKey(const Key('exercise-muscle-chest')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Primary').last);
    await tester.pump();
    await tester.tap(find.byKey(const Key('dashboard-toolbar-save-exercise')));
    await tester.pump();

    expect(exercises.exerciseMutations, hasLength(1));
    expect(find.text('Saving exercise. Editing is temporarily paused.'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byKey(const Key('exercise-name-field'))).enabled,
      isFalse,
    );

    blocker.complete(
      ExerciseMutationResult(
        exercise: exerciseDefinition(exerciseItem()),
        replayed: false,
        correlationId: '70000000-0000-4000-8000-000000000001',
      ),
    );
    await tester.pumpAndSettle();
  });
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required FakeExerciseGuidanceRepository exercises,
  required String location,
  bool readOnly = false,
  Size size = const Size(1200, 900),
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final identity = FakeIdentityRepository(
    recoveredSession: testSession,
    bootstrapResult: testBootstrap(readOnly: readOnly),
  );
  final cache = InMemoryDashboardGuidanceDraftCache();
  addTearDown(identity.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardIdentityRepositoryProvider.overrideWithValue(identity),
        dashboardPrivateCacheProvider.overrideWithValue(cache),
        exerciseGuidanceRepositoryProvider.overrideWithValue(exercises),
        dashboardGuidanceDraftCacheProvider.overrideWithValue(cache),
      ],
      child: StoneSetDashboardApp(initialLocation: location),
    ),
  );
  await tester.pumpAndSettle();
}
