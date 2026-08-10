import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/workouts.dart';
import 'package:stone_set_mobile/features/workout/guidance/workout_guidance_providers.dart';
import 'package:stone_set_mobile/features/workout/guidance/workout_guidance_sheet.dart';

import '../support/fake_workout_guidance_loader.dart';

void main() {
  testWidgets('renders pinned guidance, image and Android-only YouTube fallback', (
    tester,
  ) async {
    final loader = FakeWorkoutGuidanceLoader();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [workoutGuidanceLoaderProvider.overrideWithValue(loader)],
        child: const MaterialApp(
          home: Scaffold(body: WorkoutGuidanceSheet(exercise: _exercise)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(loader.calls, 1);
    expect(loader.lastExercise?.guidanceRevisionId, 'guidance-1');
    expect(find.text('Pinned guidance · revision 3'), findsOneWidget);
    expect(find.text('Keep the bar path controlled.'), findsOneWidget);
    expect(find.text('Setup'), findsOneWidget);
    expect(find.text('Plant your feet.'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('workout-guidance-image-image-1')),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const Key('workout-guidance-image-image-1')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('YouTube playback is available on Android.'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('YouTube playback is available on Android.'),
      findsOneWidget,
    );
  });
}

const _exercise = WorkoutExercise(
  id: 'session-exercise-1',
  position: 1,
  exerciseDefinitionId: 'exercise-1',
  guidanceRevisionId: 'guidance-1',
  title: 'Bench Press',
  priority: false,
  workingSets: 3,
  repMin: 8,
  repMax: 10,
  rirTarget: 2,
  restSeconds: 120,
  loadUnit: 'kg',
  notes: '',
);
