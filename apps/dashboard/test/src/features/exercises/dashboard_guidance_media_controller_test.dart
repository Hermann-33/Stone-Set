import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:stone_set_dashboard/src/features/exercises/controllers/dashboard_guidance_media_controller.dart';
import 'package:stone_set_dashboard/src/features/exercises/data/dashboard_image_picker.dart';
import 'package:stone_set_domain/exercise_media.dart';

import '../../../support/fake_exercise_media_repository.dart';

void main() {
  const request = DashboardGuidanceMediaRequest(
    exerciseId: '20000000-0000-4000-8000-000000000001',
    draftId: '40000000-0000-4000-8000-000000000001',
  );

  test('processes, uploads, and finalizes selected bytes before reporting ready', () async {
    final repository = FakeExerciseMediaRepository();
    final container = ProviderContainer(
      overrides: [
        exerciseMediaRepositoryProvider.overrideWithValue(repository),
        dashboardImagePickerProvider.overrideWithValue(
          _FakeImagePicker(
            DashboardSelectedImage(
              fileName: 'setup.png',
              declaredMimeType: 'image/png',
              bytes: image.encodePng(image.Image(width: 480, height: 320)),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = dashboardGuidanceMediaControllerProvider(request);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(provider.future);

    await container.read(provider.notifier).selectAndUpload(draftRevision: 1);

    final state = container.read(provider).requireValue;
    expect(state.status, DashboardGuidanceMediaStatus.ready);
    expect(state.manifest.images, hasLength(1));
    expect(state.manifest.images.single.altText, isEmpty);
    expect(repository.uploadIntents, hasLength(1));
  });

  test('retries transient upload against one stable pending intent', () async {
    final repository = FakeExerciseMediaRepository()..uploadFailuresRemaining = 1;
    final container = _mediaContainer(repository);
    addTearDown(container.dispose);
    final provider = dashboardGuidanceMediaControllerProvider(request);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(provider.future);
    final controller = container.read(provider.notifier);

    await controller.selectAndUpload(draftRevision: 1);
    expect(container.read(provider).requireValue.status, DashboardGuidanceMediaStatus.offline);
    expect(repository.uploadIntents, hasLength(1));
    expect(repository.finalizeUploadCalls, 0);

    await controller.retryUpload();

    expect(repository.uploadIntents, hasLength(1));
    expect(repository.uploadedIntentIds, hasLength(2));
    expect(repository.uploadedIntentIds.toSet(), hasLength(1));
    expect(repository.finalizeUploadCalls, 1);
    expect(container.read(provider).requireValue.status, DashboardGuidanceMediaStatus.ready);
  });

  test('cancellation quarantines the pending slot and never reports success', () async {
    final gate = Completer<void>();
    final repository = FakeExerciseMediaRepository()..uploadGate = gate;
    final container = _mediaContainer(repository);
    addTearDown(container.dispose);
    final provider = dashboardGuidanceMediaControllerProvider(request);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(provider.future);
    final controller = container.read(provider.notifier);

    final upload = controller.selectAndUpload(draftRevision: 1);
    while (repository.uploadedIntentIds.isEmpty) {
      await Future<void>.delayed(Duration.zero);
    }
    controller.cancel();
    gate.complete();
    await upload;

    final state = container.read(provider).requireValue;
    expect(state.status, DashboardGuidanceMediaStatus.cancelled);
    expect(state.message, contains('not finalized'));
    expect(state.manifest.images, isEmpty);
    expect(repository.finalizeUploadCalls, 0);
    expect(repository.assetRemovals, hasLength(1));
    expect(repository.assetRemovals.single.assetId, repository.lastCreatedAssetId);
  });

  test('persists preview-required YouTube then validates only after playable evidence', () async {
    final repository = FakeExerciseMediaRepository();
    final container = ProviderContainer(
      overrides: [
        exerciseMediaRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = dashboardGuidanceMediaControllerProvider(request);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(provider.future);
    final controller = container.read(provider.notifier);

    await controller.saveYouTubeInput('https://youtu.be/dQw4w9WgXcQ?t=1m2s');
    expect(
      repository.youtubeSaves.single.reference.validationStatus,
      YouTubeValidationStatus.previewRequired,
    );
    expect(repository.youtubeSaves.single.reference.validatedAt, isNull);

    await controller.markYouTubePreviewValidated();
    expect(repository.youtubeSaves, hasLength(2));
    expect(
      repository.youtubeSaves.last.reference.validationStatus,
      YouTubeValidationStatus.validated,
    );
    expect(repository.youtubeSaves.last.reference.validatedAt, isNotNull);

    await controller.markYouTubePreviewInvalidated();
    expect(repository.youtubeSaves, hasLength(3));
    expect(
      repository.youtubeSaves.last.reference.validationStatus,
      YouTubeValidationStatus.previewRequired,
    );
    expect(repository.youtubeSaves.last.reference.validatedAt, isNull);
    expect(
      container.read(provider).requireValue.manifest.youtube?.validationStatus,
      YouTubeValidationStatus.previewRequired,
    );
  });

  test('maps stale media writes to an explicit conflict state', () async {
    final repository = FakeExerciseMediaRepository();
    final container = ProviderContainer(
      overrides: [
        exerciseMediaRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = dashboardGuidanceMediaControllerProvider(request);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(provider.future);
    repository.failure = const ExerciseMediaFailure(ExerciseMediaErrorCode.staleRevision);

    await container
        .read(provider.notifier)
        .saveYouTubeInput('https://www.youtube.com/watch?v=dQw4w9WgXcQ');

    final state = container.read(provider).requireValue;
    expect(state.status, DashboardGuidanceMediaStatus.conflict);
    expect(state.message, contains('Reload'));
  });
}

ProviderContainer _mediaContainer(FakeExerciseMediaRepository repository) => ProviderContainer(
  overrides: [
    exerciseMediaRepositoryProvider.overrideWithValue(repository),
    dashboardImagePickerProvider.overrideWithValue(
      _FakeImagePicker(
        DashboardSelectedImage(
          fileName: 'setup.png',
          declaredMimeType: 'image/png',
          bytes: image.encodePng(image.Image(width: 480, height: 320)),
        ),
      ),
    ),
  ],
);

final class _FakeImagePicker implements DashboardImagePicker {
  const _FakeImagePicker(this.selection);

  final DashboardSelectedImage selection;

  @override
  Future<List<DashboardSelectedImage>> pick({required int maximumCount}) async =>
      maximumCount == 0 ? const <DashboardSelectedImage>[] : <DashboardSelectedImage>[selection];
}
