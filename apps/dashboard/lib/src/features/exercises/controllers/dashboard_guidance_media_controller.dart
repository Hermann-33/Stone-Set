import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/exercise_media.dart';

import '../data/dashboard_image_picker.dart';
import '../data/dashboard_image_processor.dart';

const _youtubePreviewRequiredMessage =
    'YouTube preview validation is required before publication. Load the preview, '
    'play the video until Stone Set marks it validated, then publish again. '
    'Preview validation expires after one hour.';

bool isGuidanceYouTubePublicationReady(
  GuidanceYouTubeReference? youtube, {
  DateTime? now,
}) {
  if (youtube == null) return true;
  if (youtube.validationStatus != YouTubeValidationStatus.validated)
    return false;
  final validatedAt = youtube.validatedAt;
  if (validatedAt == null) return false;
  final instant = (now ?? DateTime.now()).toUtc();
  return !validatedAt.toUtc().isBefore(
    instant.subtract(const Duration(hours: 1)),
  );
}

final exerciseMediaRepositoryProvider = Provider<ExerciseMediaRepository>((
  ref,
) {
  throw StateError('exerciseMediaRepositoryProvider must be overridden.');
});

final dashboardImagePickerProvider = Provider<DashboardImagePicker>(
  (ref) => const FileSelectorDashboardImagePicker(),
);

final dashboardImageProcessorProvider = Provider<DashboardImageProcessor>(
  (ref) => const DashboardImageProcessor(),
);

abstract interface class DashboardMediaOperationIdFactory {
  String create(String operation);
}

final dashboardMediaOperationIdFactoryProvider =
    Provider<DashboardMediaOperationIdFactory>((ref) {
      return _UuidDashboardMediaOperationIdFactory();
    });

final dashboardGuidanceRevisionMediaProvider = FutureProvider.autoDispose
    .family<GuidanceMediaManifest, ({String exerciseId, String revisionId})>(
      (ref, request) => ref
          .watch(exerciseMediaRepositoryProvider)
          .getRevisionManifest(request.exerciseId, request.revisionId),
    );

final dashboardGuidanceDraftMediaProvider = FutureProvider.autoDispose
    .family<GuidanceMediaManifest, ({String exerciseId, String draftId})>(
      (ref, request) => ref
          .watch(exerciseMediaRepositoryProvider)
          .getDraftManifest(request.exerciseId, request.draftId),
    );

final class DashboardGuidanceDraftMaterializationRequest {
  const DashboardGuidanceDraftMaterializationRequest({
    required this.exerciseId,
    required this.guidanceRevisionId,
    required this.expectedExerciseRevision,
  });

  final String exerciseId;
  final String guidanceRevisionId;
  final int expectedExerciseRevision;

  @override
  bool operator ==(Object other) =>
      other is DashboardGuidanceDraftMaterializationRequest &&
      other.exerciseId == exerciseId &&
      other.guidanceRevisionId == guidanceRevisionId &&
      other.expectedExerciseRevision == expectedExerciseRevision;

  @override
  int get hashCode =>
      Object.hash(exerciseId, guidanceRevisionId, expectedExerciseRevision);
}

final dashboardGuidanceDraftMaterializationProvider = AsyncNotifierProvider
    .autoDispose
    .family<
      DashboardGuidanceDraftMaterializationController,
      CreateGuidanceMediaDraftFromRevisionResult?,
      DashboardGuidanceDraftMaterializationRequest
    >(DashboardGuidanceDraftMaterializationController.new);

final class DashboardGuidanceDraftMaterializationController
    extends AsyncNotifier<CreateGuidanceMediaDraftFromRevisionResult?> {
  DashboardGuidanceDraftMaterializationController(this.request);

  final DashboardGuidanceDraftMaterializationRequest request;

  @override
  Future<CreateGuidanceMediaDraftFromRevisionResult?> build() async => null;

  Future<CreateGuidanceMediaDraftFromRevisionResult?> create() async {
    if (state.isLoading) return null;
    state = const AsyncLoading<CreateGuidanceMediaDraftFromRevisionResult?>();
    try {
      final result = await ref
          .read(exerciseMediaRepositoryProvider)
          .createGuidanceMediaDraftFromRevision(
            CreateGuidanceMediaDraftFromRevisionCommand(
              exerciseId: request.exerciseId,
              guidanceRevisionId: request.guidanceRevisionId,
              expectedExerciseRevision: request.expectedExerciseRevision,
              idempotencyKey: ref
                  .read(dashboardMediaOperationIdFactoryProvider)
                  .create('create-guidance-media-draft'),
            ),
          );
      state = AsyncData<CreateGuidanceMediaDraftFromRevisionResult?>(result);
      return result;
    } on Object catch (error, stackTrace) {
      state = AsyncError<CreateGuidanceMediaDraftFromRevisionResult?>(
        error,
        stackTrace,
      );
      return null;
    }
  }
}

enum DashboardGuidanceMediaStatus {
  loading,
  ready,
  processing,
  uploading,
  saving,
  cancelled,
  offline,
  permissionDenied,
  conflict,
  failed,
  readOnly,
}

final class DashboardGuidanceMediaRequest {
  const DashboardGuidanceMediaRequest({
    required this.exerciseId,
    required this.draftId,
  });

  final String exerciseId;
  final String draftId;

  @override
  bool operator ==(Object other) =>
      other is DashboardGuidanceMediaRequest &&
      other.exerciseId == exerciseId &&
      other.draftId == draftId;

  @override
  int get hashCode => Object.hash(exerciseId, draftId);
}

final class DashboardGuidanceMediaState {
  const DashboardGuidanceMediaState({
    required this.manifest,
    required this.status,
    this.progress,
    this.activeFileName,
    this.message,
  });

  final GuidanceMediaManifest manifest;
  final DashboardGuidanceMediaStatus status;
  final MediaUploadProgress? progress;
  final String? activeFileName;
  final String? message;

  DashboardGuidanceMediaState copyWith({
    GuidanceMediaManifest? manifest,
    DashboardGuidanceMediaStatus? status,
    MediaUploadProgress? progress,
    bool clearProgress = false,
    String? activeFileName,
    bool clearActiveFileName = false,
    String? message,
    bool clearMessage = false,
  }) => DashboardGuidanceMediaState(
    manifest: manifest ?? this.manifest,
    status: status ?? this.status,
    progress: clearProgress ? null : progress ?? this.progress,
    activeFileName: clearActiveFileName
        ? null
        : activeFileName ?? this.activeFileName,
    message: clearMessage ? null : message ?? this.message,
  );
}

final dashboardGuidanceMediaControllerProvider = AsyncNotifierProvider
    .autoDispose
    .family<
      DashboardGuidanceMediaController,
      DashboardGuidanceMediaState,
      DashboardGuidanceMediaRequest
    >(DashboardGuidanceMediaController.new);

final class DashboardGuidanceMediaController
    extends AsyncNotifier<DashboardGuidanceMediaState> {
  DashboardGuidanceMediaController(this.request);

  final DashboardGuidanceMediaRequest request;
  _DashboardMediaCancellation? _cancellation;
  DashboardProcessedImage? _retryProcessed;
  String? _retryFileName;
  CreateMediaUploadIntentCommand? _retryCreateCommand;
  MediaUploadIntent? _retryIntent;
  String? _retryFinalizeOperationId;
  String? _retryCancellationOperationId;
  int? _retryCancellationExpectedMediaRevision;

  ExerciseMediaRepository get _repository =>
      ref.read(exerciseMediaRepositoryProvider);
  DashboardMediaOperationIdFactory get _operationIds =>
      ref.read(dashboardMediaOperationIdFactoryProvider);

  @override
  Future<DashboardGuidanceMediaState> build() async =>
      DashboardGuidanceMediaState(
        manifest: await _repository.getDraftManifest(
          request.exerciseId,
          request.draftId,
        ),
        status: DashboardGuidanceMediaStatus.ready,
      );

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;
    state = const AsyncLoading<DashboardGuidanceMediaState>();
    state = await AsyncValue.guard(
      () async => DashboardGuidanceMediaState(
        manifest: await _repository.getDraftManifest(
          request.exerciseId,
          request.draftId,
        ),
        status: DashboardGuidanceMediaStatus.ready,
      ),
    );
  }

  Future<void> selectAndUpload({required int draftRevision}) async {
    final current = state.value;
    if (current == null) return;
    final available = 6 - current.manifest.images.length;
    if (available <= 0) {
      state = AsyncData(
        current.copyWith(
          status: DashboardGuidanceMediaStatus.failed,
          message: 'A guidance revision can contain at most 6 images.',
        ),
      );
      return;
    }
    try {
      final selections = await ref
          .read(dashboardImagePickerProvider)
          .pick(maximumCount: available);
      for (final selection in selections) {
        if (state.value?.manifest.images.length == 6) break;
        final cancellation = _DashboardMediaCancellation();
        _cancellation = cancellation;
        final beforeProcessing = state.value!;
        state = AsyncData(
          beforeProcessing.copyWith(
            status: DashboardGuidanceMediaStatus.processing,
            activeFileName: selection.fileName,
            clearMessage: true,
            clearProgress: true,
          ),
        );
        final processed = await ref
            .read(dashboardImageProcessorProvider)
            .process(
              DashboardImageProcessingInput(
                bytes: selection.bytes,
                fileName: selection.fileName,
                declaredMimeType: selection.declaredMimeType,
              ),
              cancellation: cancellation,
            );
        _retryProcessed = processed;
        _retryFileName = selection.fileName;
        final mime = GuidanceMediaMimeType.fromWireValue(processed.mimeType);
        _retryCreateCommand = CreateMediaUploadIntentCommand(
          exerciseId: request.exerciseId,
          draftId: request.draftId,
          mimeType: mime,
          expectedDraftRevision: draftRevision,
          expectedMediaRevision: beforeProcessing.manifest.mediaRevision,
          idempotencyKey: _operationIds.create('create-media-upload-intent'),
        );
        _retryFinalizeOperationId = _operationIds.create(
          'finalize-media-upload',
        );
        _retryCancellationOperationId = _operationIds.create(
          'cancel-media-upload',
        );
        final intent = await _createOrReuseRetryIntent();
        await _uploadProcessed(
          processed,
          selection.fileName,
          intent,
          cancellation,
        );
      }
    } on Object catch (error) {
      final cleanupConfirmed =
          !_isCancellation(error) || await _cleanupCancelledIntent();
      _setFailure(error);
      if (!cleanupConfirmed) _setCancellationCleanupFailure();
    } finally {
      _cancellation = null;
    }
  }

  Future<void> retryUpload() async {
    final processed = _retryProcessed;
    final fileName = _retryFileName;
    if (processed == null || fileName == null || _retryCreateCommand == null)
      return;
    final cancellation = _DashboardMediaCancellation();
    _cancellation = cancellation;
    try {
      final intent = await _createOrReuseRetryIntent();
      await _uploadProcessed(processed, fileName, intent, cancellation);
    } on Object catch (error) {
      final cleanupConfirmed =
          !_isCancellation(error) || await _cleanupCancelledIntent();
      _setFailure(error);
      if (!cleanupConfirmed) _setCancellationCleanupFailure();
    } finally {
      _cancellation = null;
    }
  }

  Future<MediaUploadIntent> _createOrReuseRetryIntent() async {
    final existing = _retryIntent;
    if (existing != null) return existing;
    final command = _retryCreateCommand;
    if (command == null) {
      throw StateError('Upload retry has no stable intent command.');
    }
    final created = await _repository.createUploadIntent(command);
    _retryCancellationExpectedMediaRevision = created.mediaRevision;
    return _retryIntent = created;
  }

  void cancel() {
    _cancellation?.cancel();
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          status: DashboardGuidanceMediaStatus.cancelled,
          message:
              'Media processing or upload was cancelled. No success was recorded.',
          clearProgress: true,
        ),
      );
    }
  }

  bool _isCancellation(Object error) =>
      error is DashboardImageProcessingFailure &&
          error.code == DashboardImageProcessingFailureCode.cancelled ||
      error is ExerciseMediaFailure &&
          error.code == ExerciseMediaErrorCode.uploadCancelled;

  Future<bool> _cleanupCancelledIntent() async {
    final intent = _retryIntent;
    if (intent == null) {
      _discardRetryBytes();
      return true;
    }
    try {
      final result = await _repository.removeAsset(
        RemoveMediaAssetCommand(
          exerciseId: request.exerciseId,
          draftId: request.draftId,
          assetId: intent.assetId,
          expectedMediaRevision:
              _retryCancellationExpectedMediaRevision ?? intent.mediaRevision,
          idempotencyKey: _retryCancellationOperationId ??= _operationIds
              .create('cancel-media-upload'),
        ),
      );
      final current = state.value;
      if (current != null) {
        state = AsyncData(current.copyWith(manifest: result.value));
      }
      return true;
    } on Object {
      return false;
    } finally {
      _discardRetryBytes();
    }
  }

  void _setCancellationCleanupFailure() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        status: DashboardGuidanceMediaStatus.failed,
        message:
            'Upload cancellation was requested, but pending media cleanup was not confirmed. '
            'Reload before adding another image.',
        clearProgress: true,
      ),
    );
  }

  Future<void> _uploadProcessed(
    DashboardProcessedImage processed,
    String fileName,
    MediaUploadIntent intent,
    _DashboardMediaCancellation cancellation,
  ) async {
    var current = state.value!;
    state = AsyncData(
      current.copyWith(
        status: DashboardGuidanceMediaStatus.uploading,
        activeFileName: fileName,
        progress: MediaUploadProgress(
          phase: MediaUploadPhase.preparing,
          completedBytes: 0,
          totalBytes: processed.bytes.length,
        ),
        clearMessage: true,
      ),
    );
    await _repository.uploadPendingBytes(
      intent,
      processed.bytes,
      cancellation: cancellation,
      onProgress: (progress) {
        final latest = state.value;
        if (latest != null && !cancellation.isCancelled) {
          state = AsyncData(latest.copyWith(progress: progress));
        }
      },
    );
    if (cancellation.isCancelled) {
      throw const ExerciseMediaFailure(ExerciseMediaErrorCode.uploadCancelled);
    }
    final result = await _repository.finalizeUpload(
      FinalizeMediaUploadCommand(
        intentId: intent.intentId,
        byteSize: processed.bytes.length,
        width: processed.width,
        height: processed.height,
        sha256Hex: processed.sha256,
        expectedMediaRevision: intent.mediaRevision,
        idempotencyKey: _retryFinalizeOperationId ??= _operationIds.create(
          'finalize-media-upload',
        ),
      ),
    );
    current = state.value!;
    _retryCancellationExpectedMediaRevision = result.value.mediaRevision;
    if (cancellation.isCancelled) {
      state = AsyncData(current.copyWith(manifest: result.value));
      throw const ExerciseMediaFailure(ExerciseMediaErrorCode.uploadCancelled);
    }
    state = AsyncData(
      current.copyWith(
        manifest: result.value,
        status: DashboardGuidanceMediaStatus.ready,
        message: result.replayed
            ? 'Image finalized from a safe retry.'
            : 'Image uploaded. Add alternative text before publication.',
        clearProgress: true,
        clearActiveFileName: true,
      ),
    );
    _discardRetryBytes();
  }

  Future<void> updateLayout(List<DraftMediaLayoutItem> images) =>
      _mutateManifest(
        'save-media-layout',
        (current) => _repository.saveLayout(
          SaveMediaLayoutCommand(
            exerciseId: request.exerciseId,
            draftId: request.draftId,
            images: images,
            expectedMediaRevision: current.manifest.mediaRevision,
            idempotencyKey: _operationIds.create('save-media-layout'),
          ),
        ),
      );

  Future<void> removeImage(String assetId) => _mutateManifest(
    'remove-media-asset',
    (current) => _repository.removeAsset(
      RemoveMediaAssetCommand(
        exerciseId: request.exerciseId,
        draftId: request.draftId,
        assetId: assetId,
        expectedMediaRevision: current.manifest.mediaRevision,
        idempotencyKey: _operationIds.create('remove-media-asset'),
      ),
    ),
  );

  Future<void> saveYouTubeInput(String rawInput) async {
    final current = state.value;
    if (current == null) return;
    try {
      final reference = const YouTubeReferenceNormalizer().parse(rawInput);
      await _saveYouTube(reference);
    } on FormatException {
      state = AsyncData(
        current.copyWith(
          status: DashboardGuidanceMediaStatus.failed,
          message:
              'Enter one supported HTTPS YouTube video URL, then try again.',
        ),
      );
    }
  }

  Future<void> markYouTubePreviewValidated() async {
    final current = state.value;
    final reference = current?.manifest.youtube;
    if (current == null || reference == null) return;
    await _saveYouTube(
      GuidanceYouTubeReference(
        videoId: reference.videoId,
        canonicalWatchUrl: reference.canonicalWatchUrl,
        startSeconds: reference.startSeconds,
        titleSnapshot: reference.titleSnapshot,
        thumbnailUrlSnapshot: reference.thumbnailUrlSnapshot,
        validationStatus: YouTubeValidationStatus.validated,
        validatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> markYouTubePreviewInvalidated() async {
    final current = state.value;
    final reference = current?.manifest.youtube;
    if (current == null || reference == null) return;
    await _saveYouTube(
      GuidanceYouTubeReference(
        videoId: reference.videoId,
        canonicalWatchUrl: reference.canonicalWatchUrl,
        startSeconds: reference.startSeconds,
        titleSnapshot: reference.titleSnapshot,
        thumbnailUrlSnapshot: reference.thumbnailUrlSnapshot,
        validationStatus: YouTubeValidationStatus.previewRequired,
      ),
    );
  }

  Future<void> _saveYouTube(GuidanceYouTubeReference reference) =>
      _mutateManifest(
        'save-youtube-reference',
        (current) => _repository.saveYouTubeReference(
          SaveYouTubeReferenceCommand(
            exerciseId: request.exerciseId,
            draftId: request.draftId,
            reference: reference,
            expectedMediaRevision: current.manifest.mediaRevision,
            idempotencyKey: _operationIds.create('save-youtube-reference'),
          ),
        ),
      );

  Future<void> removeYouTube() => _mutateManifest(
    'remove-youtube-reference',
    (current) => _repository.removeYouTubeReference(
      RemoveYouTubeReferenceCommand(
        exerciseId: request.exerciseId,
        draftId: request.draftId,
        expectedMediaRevision: current.manifest.mediaRevision,
        idempotencyKey: _operationIds.create('remove-youtube-reference'),
      ),
    ),
  );

  Future<MediaPublicationResult?> publish({
    required int exerciseRevision,
    required int draftRevision,
  }) async {
    final current = state.value;
    if (current == null) return null;
    if (!isGuidanceYouTubePublicationReady(current.manifest.youtube)) {
      state = AsyncData(
        current.copyWith(
          status: DashboardGuidanceMediaStatus.failed,
          message: _youtubePreviewRequiredMessage,
        ),
      );
      return null;
    }
    state = AsyncData(
      current.copyWith(
        status: DashboardGuidanceMediaStatus.saving,
        message: 'Reserving immutable media publication…',
      ),
    );
    try {
      final reservation = await _repository.beginPublication(
        BeginMediaPublicationCommand(
          exerciseId: request.exerciseId,
          draftId: request.draftId,
          expectedExerciseRevision: exerciseRevision,
          expectedDraftRevision: draftRevision,
          expectedMediaRevision: current.manifest.mediaRevision,
          idempotencyKey: _operationIds.create('begin-media-publication'),
        ),
      );
      if (!reservation.noChange) {
        final latest = state.value;
        if (latest != null) {
          state = AsyncData(
            latest.copyWith(
              message: 'Copying verified images to immutable revision paths…',
            ),
          );
        }
        await _repository.copyReservedObjects(reservation);
      }
      final result = await _repository.finalizePublication(
        FinalizeMediaPublicationCommand(
          reservationId: reservation.reservationId,
          idempotencyKey: _operationIds.create('finalize-media-publication'),
        ),
      );
      final latest = state.value!;
      state = AsyncData(
        latest.copyWith(
          status: DashboardGuidanceMediaStatus.ready,
          message: result.noChange
              ? 'No new immutable revision was needed.'
              : 'Guidance and media published as immutable version ${result.versionNumber}.',
        ),
      );
      return result;
    } on Object catch (error) {
      _setFailure(error);
      return null;
    }
  }

  Future<DuplicateGuidanceMediaResult?> duplicateRevisionAsDraft({
    required String guidanceRevisionId,
    required int draftRevision,
  }) async {
    final current = state.value;
    if (current == null) return null;
    state = AsyncData(
      current.copyWith(
        status: DashboardGuidanceMediaStatus.saving,
        message: 'Duplicating immutable guidance and media as a new draft…',
      ),
    );
    try {
      final result = await _repository.duplicateRevisionWithMediaAsDraft(
        DuplicateGuidanceRevisionWithMediaCommand(
          exerciseId: request.exerciseId,
          guidanceRevisionId: guidanceRevisionId,
          expectedDraftRevision: draftRevision,
          expectedMediaRevision: current.manifest.mediaRevision,
          idempotencyKey: _operationIds.create(
            'duplicate-guidance-media-revision',
          ),
        ),
      );
      state = AsyncData(
        current.copyWith(
          manifest: result.manifest,
          status: DashboardGuidanceMediaStatus.ready,
          message: result.replayed
              ? 'Draft restored from a safe retry.'
              : 'Guidance and media duplicated as an editable draft.',
        ),
      );
      return result;
    } on Object catch (error) {
      _setFailure(error);
      return null;
    }
  }

  Future<void> _mutateManifest(
    String operation,
    Future<MediaMutationResult<GuidanceMediaManifest>> Function(
      DashboardGuidanceMediaState current,
    )
    mutation,
  ) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        status: DashboardGuidanceMediaStatus.saving,
        message: 'Saving ${operation.replaceAll('-', ' ')}…',
      ),
    );
    try {
      final result = await mutation(current);
      state = AsyncData(
        current.copyWith(
          manifest: result.value,
          status: DashboardGuidanceMediaStatus.ready,
          message: result.replayed
              ? 'Saved from a safe retry.'
              : 'Media draft saved.',
        ),
      );
    } on Object catch (error) {
      _setFailure(error);
    }
  }

  void _setFailure(Object error) {
    final current = state.value;
    if (current == null) return;
    final mapped = switch (error) {
      DashboardImageProcessingFailure(:final code, :final message) => (
        status: code == DashboardImageProcessingFailureCode.cancelled
            ? DashboardGuidanceMediaStatus.cancelled
            : DashboardGuidanceMediaStatus.failed,
        message: message,
      ),
      ExerciseMediaFailure(:final code) => switch (code) {
        ExerciseMediaErrorCode.uploadCancelled => (
          status: DashboardGuidanceMediaStatus.cancelled,
          message: 'Upload was cancelled. The image was not finalized.',
        ),
        ExerciseMediaErrorCode.previewRequired => (
          status: DashboardGuidanceMediaStatus.failed,
          message: _youtubePreviewRequiredMessage,
        ),
        ExerciseMediaErrorCode.staleRevision ||
        ExerciseMediaErrorCode.uploadConflict => (
          status: DashboardGuidanceMediaStatus.conflict,
          message:
              'Media changed elsewhere. Reload the authoritative draft before retrying.',
        ),
        ExerciseMediaErrorCode.networkUnavailable => (
          status: DashboardGuidanceMediaStatus.offline,
          message: 'Media changes require a connection. Reconnect and retry.',
        ),
        ExerciseMediaErrorCode.forbidden ||
        ExerciseMediaErrorCode.inactiveProfile ||
        ExerciseMediaErrorCode.passwordChangeRequired ||
        ExerciseMediaErrorCode.sessionExpired => (
          status: DashboardGuidanceMediaStatus.permissionDenied,
          message:
              'This account cannot change media. Revalidate the session and permissions.',
        ),
        _ => (
          status: DashboardGuidanceMediaStatus.failed,
          message:
              'Media could not be saved. Retry without changing the draft.',
        ),
      },
      _ => (
        status: DashboardGuidanceMediaStatus.failed,
        message:
            'Media could not be processed. Choose the file again or retry.',
      ),
    };
    state = AsyncData(
      current.copyWith(
        status: mapped.status,
        message: mapped.message,
        clearProgress: true,
      ),
    );
  }

  void _discardRetryBytes() {
    _retryProcessed = null;
    _retryFileName = null;
    _retryCreateCommand = null;
    _retryIntent = null;
    _retryFinalizeOperationId = null;
    _retryCancellationOperationId = null;
    _retryCancellationExpectedMediaRevision = null;
  }
}

final class _DashboardMediaCancellation
    implements MediaUploadCancellation, DashboardImageProcessingCancellation {
  bool _cancelled = false;

  @override
  bool get isCancelled => _cancelled;

  @override
  void cancel() => _cancelled = true;
}

final class _UuidDashboardMediaOperationIdFactory
    implements DashboardMediaOperationIdFactory {
  final Random _random = Random.secure();

  @override
  String create(String operation) {
    final bytes = List<int>.generate(
      16,
      (_) => _random.nextInt(256),
      growable: false,
    );
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
