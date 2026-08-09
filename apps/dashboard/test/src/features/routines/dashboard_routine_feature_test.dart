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
    test('preserves seven days and completes save, validation and submission', () async {
      final repository = FakeRoutineRepository();
      final container = ProviderContainer(
        overrides: [
          routineRepositoryProvider.overrideWithValue(repository),
        ],
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
      final submission = await controller.submit();

      expect(submission, isNotNull);
      expect(repository.calls, orderedEquals(<String>['save', 'validate', 'submit']));
      expect(
        container.read(dashboardRoutineEditorControllerProvider(request)).requireValue.action,
        DashboardRoutineActionState.submitted,
      );
    });

    test('blocks submission and exposes structured server validation issues', () async {
      final repository = FakeRoutineRepository(
        validation: const <RoutineValidationIssue>[
          RoutineValidationIssue(code: 'workout_day_count', path: 'days'),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          routineRepositoryProvider.overrideWithValue(repository),
        ],
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
          .submit();

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
  });

  group('DashboardRoutineReviewController', () {
    test('requires a rejection reason and stores the final decision', () async {
      final repository = FakeRoutineRepository();
      final container = ProviderContainer(
        overrides: [
          routineRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        dashboardRoutineReviewControllerProvider(submissionId),
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await container.read(dashboardRoutineReviewControllerProvider(submissionId).future);
      final controller = container.read(
        dashboardRoutineReviewControllerProvider(submissionId).notifier,
      );

      await controller.reject('');
      expect(repository.calls, isNot(contains('reject')));
      expect(
        container.read(dashboardRoutineReviewControllerProvider(submissionId)).requireValue.message,
        contains('required'),
      );

      await controller.reject('Needs another priority exercise.');
      expect(repository.calls, contains('reject'));
      expect(
        container
            .read(dashboardRoutineReviewControllerProvider(submissionId))
            .requireValue
            .submission
            .status,
        RoutineDraftStatus.rejected,
      );
    });

    test('reviewer approves and owner editor publishes an immutable version', () async {
      final repository = FakeRoutineRepository();
      await repository.submitDraft(draftId, repository.draft.revision, 'seed-submission');
      final container = ProviderContainer(
        overrides: [
          routineRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        dashboardRoutineReviewControllerProvider(submissionId),
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await container.read(dashboardRoutineReviewControllerProvider(submissionId).future);
      final reviewController = container.read(
        dashboardRoutineReviewControllerProvider(submissionId).notifier,
      );

      await reviewController.approve(note: 'Ready');
      final editorRequest = DashboardRoutineEditorRequest(routineId: draftId);
      final editorSubscription = container.listen(
        dashboardRoutineEditorControllerProvider(editorRequest),
        (previous, next) {},
      );
      addTearDown(editorSubscription.close);
      await container.read(dashboardRoutineEditorControllerProvider(editorRequest).future);
      final version = await container
          .read(dashboardRoutineEditorControllerProvider(editorRequest).notifier)
          .publish(DateTime.utc(2026, 8, 17));

      expect(repository.calls, containsAllInOrder(<String>['approve', 'publish']));
      expect(version?.contentHash, 'abc123');
      expect(
        container.read(dashboardRoutineEditorControllerProvider(editorRequest)).requireValue.action,
        DashboardRoutineActionState.published,
      );
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

  testWidgets('review screen requires a note then rejects the immutable snapshot', (tester) async {
    final repository = FakeRoutineRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routineRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: StoneSetTheme.light(),
          home: const Scaffold(body: DashboardRoutineReviewView(submissionId: submissionId)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('routine-review-detail')), findsOneWidget);
    expect(find.text('Immutable submitted revision 1'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('reject-routine')),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('reject-routine')));
    await tester.pump();
    expect(find.text('A rejection reason is required.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('routine-review-note')),
      'Add a clearer lower-body priority.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('reject-routine')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('reject-routine')));
    await tester.pumpAndSettle();

    expect(find.text('Routine rejected.'), findsOneWidget);
    expect(repository.calls, contains('reject'));
  });
}
