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
  testWidgets(
    'saved guidance is explicitly identified as a draft, not a live app version',
    (tester) async {
      await _pumpGuidanceEditor(tester, media: FakeExerciseMediaRepository());

      expect(find.text('Draft saved'), findsOneWidget);
      expect(
        find.byKey(const Key('guidance-publication-boundary')),
        findsOneWidget,
      );
      expect(find.text('Draft is not live'), findsOneWidget);
      expect(
        find.textContaining(
          'Saving does not update the Android app. Publish must succeed first.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('next newly started workout'), findsWidgets);
    },
  );

  testWidgets('YouTube preview requirement blocks Publish above the fold', (
    tester,
  ) async {
    final media = FakeExerciseMediaRepository(
      manifest: _previewRequiredManifest(),
    );
    await _pumpGuidanceEditor(tester, media: media);

    expect(find.text('Publication blocked'), findsOneWidget);
    expect(
      find.textContaining('YouTube preview validation is required.'),
      findsOneWidget,
    );

    final publish = find.byKey(const Key('dashboard-toolbar-publish-guidance'));
    expect(publish, findsOneWidget);
    await tester.tap(publish, warnIfMissed: false);
    await tester.pump();

    expect(find.text('Publish immutable guidance?'), findsNothing);
    expect(media.copiedReservations, isEmpty);
  });

  testWidgets(
    'Publish confirmation explains activation and active-session pinning',
    (tester) async {
      await _pumpGuidanceEditor(tester, media: FakeExerciseMediaRepository());

      final publish = find.byKey(
        const Key('dashboard-toolbar-publish-guidance'),
      );
      expect(publish, findsOneWidget);
      await tester.tap(publish);
      await tester.pumpAndSettle();

      expect(find.text('Publish immutable guidance?'), findsOneWidget);
      expect(
        find.textContaining('Save only updates the editable draft.'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'next newly started workout uses that published version',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('workouts already in progress remain pinned'),
        findsOneWidget,
      );
    },
  );
}

GuidanceMediaManifest _previewRequiredManifest() => GuidanceMediaManifest(
  exerciseId: '20000000-0000-4000-8000-000000000001',
  ownerId: testUserId,
  draftId: '40000000-0000-4000-8000-000000000001',
  mediaRevision: 1,
  images: const <GuidanceImageAsset>[],
  youtube: GuidanceYouTubeReference(
    videoId: 'dQw4w9WgXcQ',
    canonicalWatchUrl: Uri.https('www.youtube.com', '/watch', <String, String>{
      'v': 'dQw4w9WgXcQ',
    }),
    validationStatus: YouTubeValidationStatus.previewRequired,
  ),
);

Future<void> _pumpGuidanceEditor(
  WidgetTester tester, {
  required FakeExerciseMediaRepository media,
}) async {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final exercises = FakeExerciseGuidanceRepository(
    items: <ExerciseLibraryItem>[exerciseItem()],
  );
  final identity = FakeIdentityRepository(
    recoveredSession: testSession,
    bootstrapResult: testBootstrap(),
  );
  final cache = InMemoryDashboardGuidanceDraftCache();
  addTearDown(identity.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardIdentityRepositoryProvider.overrideWithValue(identity),
        dashboardPrivateCacheProvider.overrideWithValue(cache),
        exerciseGuidanceRepositoryProvider.overrideWithValue(exercises),
        exerciseMediaRepositoryProvider.overrideWithValue(media),
        dashboardGuidanceDraftCacheProvider.overrideWithValue(cache),
      ],
      child: const StoneSetDashboardApp(
        initialLocation:
            '/exercises/20000000-0000-4000-8000-000000000001/guidance/drafts/'
            '40000000-0000-4000-8000-000000000001',
      ),
    ),
  );
  await tester.pumpAndSettle();
}
