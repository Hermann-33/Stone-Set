import 'dart:async';

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
import 'package:stone_set_domain/exercise_media.dart';

import '../../../support/fake_exercise_guidance_repository.dart';
import '../../../support/fake_exercise_media_repository.dart';
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

  testWidgets('guidance editor exposes responsive accessible media authoring at 200 percent text', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpDashboard(
      tester,
      exercises: FakeExerciseGuidanceRepository(items: <ExerciseLibraryItem>[exerciseItem()]),
      location:
          '/exercises/20000000-0000-4000-8000-000000000001/guidance/drafts/'
          '40000000-0000-4000-8000-000000000001',
      size: const Size(700, 1000),
    );

    expect(find.text('Images'), findsOneWidget);
    expect(find.text('Optional YouTube Video'), findsOneWidget);
    expect(find.text('Mobile-Shaped Preview'), findsOneWidget);
    expect(find.byKey(const Key('media-select-images')), findsOneWidget);
    expect(find.byKey(const Key('youtube-url-field')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exercise detail renders truthful text-only published media actions', (tester) async {
    final exercises = FakeExerciseGuidanceRepository(
      items: <ExerciseLibraryItem>[exerciseItem(published: true, hasDraft: false)],
    );
    await _pumpDashboard(
      tester,
      exercises: exercises,
      media: FakeExerciseMediaRepository(),
      location: '/exercises/20000000-0000-4000-8000-000000000001',
    );
    await _scrollExerciseDetailTo(tester, find.byKey(const Key('published-media-summary')));

    expect(find.byKey(const Key('published-media-summary')), findsOneWidget);
    expect(find.text('0 images'), findsOneWidget);
    expect(find.text('No YouTube video attached'), findsOneWidget);
    expect(find.byKey(const Key('add-exercise-media')), findsOneWidget);
    expect(find.byKey(const Key('view-published-media')), findsOneWidget);
    await _scrollExerciseDetailTo(
      tester,
      find.text('Routine references arrive in TASK-IMP-003C. No usage count is inferred.'),
    );
    expect(
      find.text('Routine references arrive in TASK-IMP-003C. No usage count is inferred.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const Key('view-published-media')));
    await tester.tap(find.byKey(const Key('view-published-media')));
    await tester.pumpAndSettle();
    expect(find.text('Immutable Media'), findsOneWidget);
  });

  testWidgets('current draft media opens the existing media editor', (tester) async {
    final exercises = FakeExerciseGuidanceRepository(
      items: <ExerciseLibraryItem>[exerciseItem(published: true)],
    );
    await _pumpDashboard(
      tester,
      exercises: exercises,
      location: '/exercises/20000000-0000-4000-8000-000000000001',
    );
    await _scrollExerciseDetailTo(tester, find.byKey(const Key('manage-exercise-media')));

    expect(find.byKey(const Key('draft-media-summary')), findsOneWidget);
    expect(find.byKey(const Key('manage-exercise-media')), findsOneWidget);
    expect(find.byKey(const Key('add-exercise-media')), findsNothing);

    await tester.tap(find.byKey(const Key('manage-exercise-media')));
    await tester.pumpAndSettle();

    expect(find.text('Images'), findsOneWidget);
    expect(find.byKey(const Key('media-select-images')), findsOneWidget);
  });

  testWidgets('published media shows its private cover, image count, and YouTube state', (
    tester,
  ) async {
    final exercises = FakeExerciseGuidanceRepository(
      items: <ExerciseLibraryItem>[exerciseItem(published: true, hasDraft: false)],
    );
    await _pumpDashboard(
      tester,
      exercises: exercises,
      media: FakeExerciseMediaRepository(manifest: _publishedMediaManifest()),
      location: '/exercises/20000000-0000-4000-8000-000000000001',
    );
    await _scrollExerciseDetailTo(tester, find.byKey(const Key('media-cover-thumbnail')));

    expect(find.byKey(const Key('media-cover-thumbnail')), findsOneWidget);
    expect(find.text('1 image'), findsOneWidget);
    expect(find.text('YouTube attached'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Published media. 1 image. YouTube attached.'),
      findsOneWidget,
    );
  });

  testWidgets('Add media waits for server confirmation then opens the existing editor', (
    tester,
  ) async {
    final exercises = FakeExerciseGuidanceRepository(
      items: <ExerciseLibraryItem>[exerciseItem(published: true, hasDraft: false)],
    );
    final media = FakeExerciseMediaRepository();
    await _pumpDashboard(
      tester,
      exercises: exercises,
      media: media,
      location: '/exercises/20000000-0000-4000-8000-000000000001',
    );
    await _scrollExerciseDetailTo(tester, find.byKey(const Key('add-exercise-media')));

    await tester.tap(find.byKey(const Key('add-exercise-media')));
    await tester.pumpAndSettle();

    expect(media.draftMaterializations, hasLength(1));
    expect(media.draftMaterializations.single.expectedExerciseRevision, 1);
    expect(
      media.draftMaterializations.single.guidanceRevisionId,
      '50000000-0000-4000-8000-000000000001',
    );
    expect(find.byKey(const Key('media-select-images')), findsOneWidget);
  });

  testWidgets('concurrent existing draft is reloaded and managed without false success', (
    tester,
  ) async {
    final first = exerciseItem(published: true, hasDraft: false);
    final exercises = FakeExerciseGuidanceRepository(items: <ExerciseLibraryItem>[first]);
    final blocker = Completer<CreateGuidanceMediaDraftFromRevisionResult>();
    final media = FakeExerciseMediaRepository()..draftMaterializationBlocker = blocker;
    await _pumpDashboard(
      tester,
      exercises: exercises,
      media: media,
      location: '/exercises/20000000-0000-4000-8000-000000000001',
    );
    await _scrollExerciseDetailTo(tester, find.byKey(const Key('add-exercise-media')));

    await tester.tap(find.byKey(const Key('add-exercise-media')));
    await tester.pump();
    expect(find.text('Creating media draft…'), findsOneWidget);
    exercises.items[0] = exerciseItem(published: true);
    blocker.completeError(const ExerciseMediaFailure(ExerciseMediaErrorCode.staleRevision));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('media-select-images')), findsOneWidget);
    expect(find.textContaining('could not be created'), findsNothing);
  });

  testWidgets('media loading and safe error states remain retryable at 200 percent text', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final exercises = FakeExerciseGuidanceRepository(
      items: <ExerciseLibraryItem>[exerciseItem(published: true, hasDraft: false)],
    );
    final blocker = Completer<GuidanceMediaManifest>();
    final media = FakeExerciseMediaRepository()..revisionManifestBlocker = blocker;
    await _pumpDashboard(
      tester,
      exercises: exercises,
      media: media,
      location: '/exercises/20000000-0000-4000-8000-000000000001',
      size: const Size(700, 1100),
      settle: false,
    );
    await tester.pump();
    await _pumpUntilFound(tester, find.byKey(const Key('exercise-detail')));
    await _scrollExerciseDetailTo(tester, find.byKey(const Key('exercise-media-section')));

    final loading = find.byKey(const Key('published-media-loading'));
    expect(loading, findsOneWidget);
    expect(tester.getSemantics(loading).label, contains('Loading published media'));
    blocker.completeError(const ExerciseMediaFailure(ExerciseMediaErrorCode.networkUnavailable));
    await tester.pumpAndSettle();

    expect(find.text('Published media is unavailable.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('read-only media keeps immutable viewing available and blocks authoring', (
    tester,
  ) async {
    final exercises = FakeExerciseGuidanceRepository(
      items: <ExerciseLibraryItem>[exerciseItem(published: true, hasDraft: false)],
    );
    final media = FakeExerciseMediaRepository();
    await _pumpDashboard(
      tester,
      exercises: exercises,
      media: media,
      readOnly: true,
      location: '/exercises/20000000-0000-4000-8000-000000000001',
    );
    await _scrollExerciseDetailTo(tester, find.byKey(const Key('add-exercise-media')));

    await tester.tap(find.byKey(const Key('add-exercise-media')), warnIfMissed: false);
    await tester.pump();
    expect(media.draftMaterializations, isEmpty);
    expect(find.byKey(const Key('view-published-media')), findsOneWidget);
  });
}

Future<void> _scrollExerciseDetailTo(WidgetTester tester, Finder target) async {
  final scrollable = find.descendant(
    of: find.byKey(const Key('exercise-detail')),
    matching: find.byType(Scrollable),
  );
  await tester.scrollUntilVisible(target, 300, scrollable: scrollable);
  await tester.pump();
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder target) async {
  for (var attempt = 0; attempt < 20 && target.evaluate().isEmpty; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(target, findsOneWidget);
}

GuidanceMediaManifest _publishedMediaManifest() {
  final now = DateTime.utc(2026, 8, 11);
  return GuidanceMediaManifest(
    exerciseId: '20000000-0000-4000-8000-000000000001',
    ownerId: testUserId,
    guidanceRevisionId: '50000000-0000-4000-8000-000000000001',
    guidanceRevisionHash: ''.padLeft(64, 'b'),
    mediaRevision: 1,
    images: <GuidanceImageAsset>[
      GuidanceImageAsset(
        id: '82000000-0000-4000-8000-000000000001',
        ownerId: testUserId,
        exerciseId: '20000000-0000-4000-8000-000000000001',
        guidanceRevisionId: '50000000-0000-4000-8000-000000000001',
        bucketId: GuidanceMediaManifest.bucketId,
        objectPath: '$testUserId/20000000-0000-4000-8000-000000000001/revisions/cover.webp',
        mimeType: GuidanceMediaMimeType.webp,
        byteSize: 1200,
        width: 800,
        height: 600,
        sha256Hex: ''.padLeft(64, 'a'),
        altText: 'Incline press setup position',
        position: 0,
        isCover: true,
        lifecycle: GuidanceMediaLifecycle.published,
        createdAt: now,
        updatedAt: now,
      ),
    ],
    youtube: GuidanceYouTubeReference(
      videoId: 'dQw4w9WgXcQ',
      canonicalWatchUrl: Uri.https('www.youtube.com', '/watch', <String, String>{
        'v': 'dQw4w9WgXcQ',
      }),
      validationStatus: YouTubeValidationStatus.validated,
      validatedAt: now,
    ),
    manifestHash: ''.padLeft(64, 'c'),
    bundleHash: ''.padLeft(64, 'd'),
  );
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required FakeExerciseGuidanceRepository exercises,
  required String location,
  FakeExerciseMediaRepository? media,
  bool readOnly = false,
  Size size = const Size(1200, 900),
  bool settle = true,
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
        exerciseMediaRepositoryProvider.overrideWithValue(media ?? FakeExerciseMediaRepository()),
        dashboardGuidanceDraftCacheProvider.overrideWithValue(cache),
      ],
      child: StoneSetDashboardApp(initialLocation: location),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}
