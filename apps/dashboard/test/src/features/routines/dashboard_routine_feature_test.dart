import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/src/features/exercises/controllers/dashboard_exercise_controllers.dart';
import 'package:stone_set_dashboard/src/features/routines/controllers/dashboard_routine_controllers.dart';
import 'package:stone_set_dashboard/src/features/routines/views/dashboard_routine_views.dart';
import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_domain/routines.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import 'fake_routine_repository.dart';

void main() {
  testWidgets('routine library confirms archive and refreshes the active list', (tester) async {
    final repository = FakeRoutineRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [routineRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: StoneSetTheme.light(),
          home: const Scaffold(body: DashboardRoutineLibraryView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('archive-routine-$draftId')));
    await tester.pumpAndSettle();
    expect(find.text('Archive routine draft?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-archive-routine')));
    await tester.pumpAndSettle();

    expect(repository.calls, contains('archive'));
    expect(find.text('No routines yet'), findsOneWidget);
  });

  group('DashboardRoutineEditorController', () {
    test('saves, validates and publishes directly', () async {
      final repository = FakeRoutineRepository();
      final container = ProviderContainer(
        overrides: [routineRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      const request = DashboardRoutineEditorRequest(routineId: draftId);
      final subscription = container.listen(
        dashboardRoutineEditorControllerProvider(request),
        (previous, next) {},
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        dashboardRoutineEditorControllerProvider(request).future,
      );

      expect(initial.draft.days, hasLength(7));
      expect(initial.draft.days.where((day) => day.kind == RoutineDayKind.workout), hasLength(4));

      final controller = container.read(
        dashboardRoutineEditorControllerProvider(request).notifier,
      );
      controller.updateName('Updated routine');
      final version = await controller.publish();

      expect(version, isNotNull);
      expect(repository.calls, orderedEquals(<String>['save', 'validate', 'publish']));
      expect(
        container.read(dashboardRoutineEditorControllerProvider(request)).requireValue.action,
        DashboardRoutineActionState.published,
      );
      expect(
        container.read(dashboardRoutineEditorControllerProvider(request)).requireValue.draft.status,
        RoutineDraftStatus.published,
      );
    });

    test('blocks direct publication when validation fails', () async {
      final repository = FakeRoutineRepository(
        validation: const <RoutineValidationIssue>[
          RoutineValidationIssue(code: 'workout_day_count', path: 'days'),
        ],
      );
      final container = ProviderContainer(
        overrides: [routineRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      const request = DashboardRoutineEditorRequest(routineId: draftId);
      final subscription = container.listen(
        dashboardRoutineEditorControllerProvider(request),
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await container.read(dashboardRoutineEditorControllerProvider(request).future);

      final result = await container
          .read(dashboardRoutineEditorControllerProvider(request).notifier)
          .publish();

      expect(result, isNull);
      expect(repository.calls, orderedEquals(<String>['save', 'validate']));
      expect(
        container
            .read(dashboardRoutineEditorControllerProvider(request))
            .requireValue
            .validation
            ?.issues
            .single
            .code,
        'workout_day_count',
      );
    });

    test('legacy submit entrypoint now publishes directly', () async {
      final repository = FakeRoutineRepository();
      final container = ProviderContainer(
        overrides: [routineRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      const request = DashboardRoutineEditorRequest(routineId: draftId);
      final subscription = container.listen(
        dashboardRoutineEditorControllerProvider(request),
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await container.read(dashboardRoutineEditorControllerProvider(request).future);

      final version = await container
          .read(dashboardRoutineEditorControllerProvider(request).notifier)
          .submit();

      expect(version, isNotNull);
      expect(repository.calls, orderedEquals(<String>['save', 'validate', 'publish']));
    });
  });

  testWidgets('editor renders exactly seven days and displays validation errors', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = FakeRoutineRepository(
      validation: const <RoutineValidationIssue>[
        RoutineValidationIssue(code: 'workout_set_count', path: 'days.1'),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routineRepositoryProvider.overrideWithValue(repository),
          dashboardGlobalExerciseSearchProvider.overrideWith(
            (ref) async => const <ExerciseLibraryItem>[],
          ),
        ],
        child: MaterialApp(
          theme: StoneSetTheme.light(),
          home: const Scaffold(body: DashboardRoutineEditorView(routineId: draftId)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('routine-editor')), findsOneWidget);
    for (var day = 1; day <= 7; day++) {
      expect(find.byKey(Key('routine-day-$day')), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('dashboard-toolbar-validate-routine')));
    await tester.pumpAndSettle();

    expect(find.textContaining('workout set count'), findsOneWidget);
    expect(find.textContaining('Resolve 1 validation issue'), findsOneWidget);
  });
}
