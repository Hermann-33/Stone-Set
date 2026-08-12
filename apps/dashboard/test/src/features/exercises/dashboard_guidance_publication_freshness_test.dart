import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/src/features/exercises/controllers/dashboard_guidance_media_controller.dart';
import 'package:stone_set_domain/exercise_media.dart';

import '../../../support/fake_exercise_media_repository.dart';

void main() {
  const request = DashboardGuidanceMediaRequest(
    exerciseId: '20000000-0000-4000-8000-000000000001',
    draftId: '40000000-0000-4000-8000-000000000001',
  );

  test('loaded preview-required draft fails before reservation', () async {
    final repository = FakeExerciseMediaRepository(
      manifest: GuidanceMediaManifest(
        exerciseId: request.exerciseId,
        ownerId: '00000000-0000-4000-8000-000000000001',
        draftId: request.draftId,
        mediaRevision: 2,
        images: const <GuidanceImageAsset>[],
        youtube: GuidanceYouTubeReference(
          videoId: 'dQw4w9WgXcQ',
          canonicalWatchUrl: Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
          validationStatus: YouTubeValidationStatus.previewRequired,
        ),
      ),
    );
    final container = ProviderContainer(
      overrides: [exerciseMediaRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final provider = dashboardGuidanceMediaControllerProvider(request);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(provider.future);

    repository.failure = const ExerciseMediaFailure(
      ExerciseMediaErrorCode.networkUnavailable,
    );
    final result = await container
        .read(provider.notifier)
        .publish(
          exerciseRevision: 1,
          draftRevision: 3,
        );

    expect(result, isNull);
    final state = container.read(provider).requireValue;
    expect(state.status, DashboardGuidanceMediaStatus.failed);
    expect(state.message, contains('YouTube preview validation is required'));
    expect(state.message, contains('play the video'));
    expect(state.message, contains('expires after one hour'));
  });

  test('server preview-required failure gives same remediation', () async {
    final repository = FakeExerciseMediaRepository();
    final container = ProviderContainer(
      overrides: [exerciseMediaRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final provider = dashboardGuidanceMediaControllerProvider(request);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(provider.future);

    repository.failure = const ExerciseMediaFailure(
      ExerciseMediaErrorCode.previewRequired,
    );
    final result = await container
        .read(provider.notifier)
        .publish(
          exerciseRevision: 1,
          draftRevision: 3,
        );

    expect(result, isNull);
    final state = container.read(provider).requireValue;
    expect(state.status, DashboardGuidanceMediaStatus.failed);
    expect(state.message, contains('YouTube preview validation is required'));
    expect(state.message, contains('play the video'));
    expect(state.message, contains('expires after one hour'));
    expect(repository.copiedReservations, isEmpty);
  });
}
