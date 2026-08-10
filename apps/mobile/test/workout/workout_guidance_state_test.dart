import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/workouts.dart';
import 'package:stone_set_mobile/features/workout/data/workout_local_store.dart';
import 'package:stone_set_mobile/features/workout/guidance/workout_guidance_providers.dart';
import 'package:stone_set_mobile/features/workout/guidance/workout_guidance_sheet.dart';
import 'package:stone_set_mobile/features/workout/providers/workout_providers.dart';
import 'package:stone_set_mobile/features/workout/views/workout_screen.dart';

import '../support/fake_workout_guidance_loader.dart';

void main() {
  testWidgets('opening and closing Guidance preserves logger field state', (
    tester,
  ) async {
    final loader = FakeWorkoutGuidanceLoader();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workoutDraftProvider('plan-1').overrideWith((ref) async => _draft()),
          workoutGuidanceLoaderProvider.overrideWithValue(loader),
        ],
        child: const MaterialApp(home: WorkoutScreen(planItemId: 'plan-1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('80.0'), findsOneWidget);
    await tester.tap(find.byKey(const Key('workout-guidance-session-exercise-1')));
    await tester.pumpAndSettle();

    expect(find.text('Pinned guidance · revision 3'), findsOneWidget);
    expect(find.text('Keep the bar path controlled.'), findsOneWidget);

    Navigator.of(tester.element(find.byType(WorkoutGuidanceSheet))).pop();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('workout-load-session-exercise-1-1')), findsOneWidget);
    expect(find.text('80.0'), findsOneWidget);
  });
}

LocalWorkoutDraft _draft() {
  final startedAt = DateTime.utc(2026, 8, 10, 10);
  const exercise = WorkoutExercise(
    id: 'session-exercise-1',
    position: 1,
    exerciseDefinitionId: 'exercise-1',
    guidanceRevisionId: 'guidance-1',
    title: 'Bench Press',
    priority: false,
    workingSets: 1,
    repMin: 8,
    repMax: 10,
    rirTarget: 2,
    restSeconds: 120,
    loadUnit: 'kg',
    notes: '',
  );
  const set = WorkoutSetDraft(
    sessionExerciseId: 'session-exercise-1',
    setIndex: 1,
    loadUnit: 'kg',
    completed: false,
    clientRevision: 0,
    loadValue: 80,
  );
  final session = WorkoutSession(
    id: 'session-1',
    userId: 'user-1',
    planItemId: 'plan-1',
    state: WorkoutSessionState.active,
    startedAt: startedAt,
    lastClientRevision: 0,
    exercises: const <WorkoutExercise>[exercise],
    sets: const <WorkoutSetDraft>[set],
  );
  return LocalWorkoutDraft(
    userId: 'user-1',
    planItemId: 'plan-1',
    session: session,
    sets: const <WorkoutSetDraft>[set],
    clientRevision: 0,
    lastSyncedRevision: 0,
  );
}
