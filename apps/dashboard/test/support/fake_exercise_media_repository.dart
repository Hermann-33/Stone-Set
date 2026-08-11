import 'dart:async';

import 'package:stone_set_domain/exercise_media.dart';

final class FakeExerciseMediaRepository implements ExerciseMediaRepository {
  FakeExerciseMediaRepository({GuidanceMediaManifest? manifest})
    : manifest = manifest ?? emptyMediaManifest();

  GuidanceMediaManifest manifest;
  final List<CreateMediaUploadIntentCommand> uploadIntents = <CreateMediaUploadIntentCommand>[];
  final List<String> uploadedIntentIds = <String>[];
  final List<RemoveMediaAssetCommand> assetRemovals = <RemoveMediaAssetCommand>[];
  final List<SaveMediaLayoutCommand> layouts = <SaveMediaLayoutCommand>[];
  final List<SaveYouTubeReferenceCommand> youtubeSaves = <SaveYouTubeReferenceCommand>[];
  final List<MediaPublicationReservation> copiedReservations = <MediaPublicationReservation>[];
  final List<CreateGuidanceMediaDraftFromRevisionCommand> draftMaterializations =
      <CreateGuidanceMediaDraftFromRevisionCommand>[];
  ExerciseMediaFailure? failure;
  CreateGuidanceMediaDraftFromRevisionResult? draftMaterializationResult;
  Completer<GuidanceMediaManifest>? revisionManifestBlocker;
  Completer<GuidanceMediaManifest>? draftManifestBlocker;
  Completer<CreateGuidanceMediaDraftFromRevisionResult>? draftMaterializationBlocker;
  int uploadFailuresRemaining = 0;
  int finalizeUploadCalls = 0;
  Completer<void>? uploadGate;
  MediaUploadIntent? _lastIntent;

  String? get lastCreatedAssetId => _lastIntent?.assetId;

  @override
  Future<GuidanceMediaManifest> getDraftManifest(String exerciseId, String draftId) async {
    _throwFailure();
    final blocker = draftManifestBlocker;
    if (blocker != null) return blocker.future;
    return manifest;
  }

  @override
  Future<GuidanceMediaManifest> getRevisionManifest(
    String exerciseId,
    String guidanceRevisionId,
  ) async {
    _throwFailure();
    final blocker = revisionManifestBlocker;
    if (blocker != null) return blocker.future;
    return manifest;
  }

  @override
  Future<MediaAccessUrl> createImageAccessUrl(
    GuidanceImageAsset asset, {
    Duration lifetime = const Duration(minutes: 5),
  }) async => MediaAccessUrl(
    url: Uri.https('local.invalid', '/private-image'),
    expiresAt: DateTime.utc(2026, 8, 8).add(lifetime),
  );

  @override
  Future<MediaUploadIntent> createUploadIntent(CreateMediaUploadIntentCommand command) async {
    _throwFailure();
    uploadIntents.add(command);
    return _lastIntent = MediaUploadIntent(
      intentId: '81000000-0000-4000-8000-000000000001',
      assetId: '82000000-0000-4000-8000-000000000001',
      ownerId: manifest.ownerId,
      exerciseId: command.exerciseId,
      draftId: command.draftId,
      bucketId: GuidanceMediaManifest.bucketId,
      objectPath:
          '${manifest.ownerId}/${command.exerciseId}/drafts/${command.draftId}/'
          '82000000-0000-4000-8000-000000000001.${command.mimeType.fileExtension}',
      mimeType: command.mimeType,
      maximumByteSize: 5 * 1024 * 1024,
      mediaRevision: manifest.mediaRevision,
      expiresAt: DateTime.utc(2026, 8, 8, 1),
      replayed: false,
      correlationId: '83000000-0000-4000-8000-000000000001',
    );
  }

  @override
  Future<void> uploadPendingBytes(
    MediaUploadIntent intent,
    List<int> bytes, {
    MediaUploadProgressCallback? onProgress,
    MediaUploadCancellation cancellation = const NeverCancelledMediaUpload(),
  }) async {
    _throwFailure();
    uploadedIntentIds.add(intent.intentId);
    if (uploadFailuresRemaining > 0) {
      uploadFailuresRemaining -= 1;
      throw const ExerciseMediaFailure(ExerciseMediaErrorCode.networkUnavailable);
    }
    await uploadGate?.future;
    if (cancellation.isCancelled) {
      throw const ExerciseMediaFailure(ExerciseMediaErrorCode.uploadCancelled);
    }
    onProgress?.call(
      MediaUploadProgress(
        phase: MediaUploadPhase.uploading,
        completedBytes: 0,
        totalBytes: bytes.length,
      ),
    );
    onProgress?.call(
      MediaUploadProgress(
        phase: MediaUploadPhase.uploaded,
        completedBytes: bytes.length,
        totalBytes: bytes.length,
      ),
    );
  }

  @override
  Future<MediaMutationResult<GuidanceMediaManifest>> finalizeUpload(
    FinalizeMediaUploadCommand command,
  ) async {
    _throwFailure();
    finalizeUploadCalls += 1;
    final intent = _lastIntent!;
    manifest = _copyManifest(
      images: <GuidanceImageAsset>[
        ...manifest.images,
        GuidanceImageAsset(
          id: intent.assetId,
          ownerId: manifest.ownerId,
          exerciseId: manifest.exerciseId,
          draftId: manifest.draftId,
          bucketId: GuidanceMediaManifest.bucketId,
          objectPath: intent.objectPath,
          mimeType: intent.mimeType,
          byteSize: command.byteSize,
          width: command.width,
          height: command.height,
          sha256Hex: command.sha256Hex,
          altText: '',
          position: manifest.images.length,
          isCover: manifest.images.isEmpty,
          lifecycle: GuidanceMediaLifecycle.ready,
          createdAt: DateTime.utc(2026, 8, 8),
          updatedAt: DateTime.utc(2026, 8, 8),
        ),
      ],
    );
    return _result();
  }

  @override
  Future<MediaMutationResult<GuidanceMediaManifest>> saveLayout(
    SaveMediaLayoutCommand command,
  ) async {
    _throwFailure();
    layouts.add(command);
    manifest = _copyManifest(
      images: <GuidanceImageAsset>[
        for (final layout in command.images)
          _copyImage(
            manifest.images.singleWhere((image) => image.id == layout.assetId),
            altText: layout.altText,
            position: layout.position,
            isCover: layout.isCover,
          ),
      ]..sort((left, right) => left.position.compareTo(right.position)),
    );
    return _result();
  }

  @override
  Future<MediaMutationResult<GuidanceMediaManifest>> removeAsset(
    RemoveMediaAssetCommand command,
  ) async {
    assetRemovals.add(command);
    manifest = _copyManifest(
      images: manifest.images.where((image) => image.id != command.assetId).toList(),
    );
    return _result();
  }

  @override
  Future<MediaMutationResult<GuidanceMediaManifest>> saveYouTubeReference(
    SaveYouTubeReferenceCommand command,
  ) async {
    _throwFailure();
    youtubeSaves.add(command);
    manifest = _copyManifest(youtube: command.reference);
    return _result();
  }

  @override
  Future<MediaMutationResult<GuidanceMediaManifest>> removeYouTubeReference(
    RemoveYouTubeReferenceCommand command,
  ) async {
    manifest = _copyManifest(clearYouTube: true);
    return _result();
  }

  @override
  Future<MediaPublicationReservation> beginPublication(
    BeginMediaPublicationCommand command,
  ) async {
    _throwFailure();
    return MediaPublicationReservation(
      reservationId: '84000000-0000-4000-8000-000000000001',
      exerciseId: command.exerciseId,
      draftId: command.draftId,
      guidanceRevisionId: '85000000-0000-4000-8000-000000000001',
      contentHash: '1' * 64,
      revisionHash: '2' * 64,
      manifestHash: '3' * 64,
      bundleHash: '4' * 64,
      expiresAt: DateTime.utc(2026, 8, 8, 1),
      copies: const <MediaPublicationCopy>[],
      noChange: false,
      replayed: false,
      correlationId: '86000000-0000-4000-8000-000000000001',
    );
  }

  @override
  Future<void> copyReservedObjects(MediaPublicationReservation reservation) async {
    copiedReservations.add(reservation);
  }

  @override
  Future<MediaPublicationResult> finalizePublication(
    FinalizeMediaPublicationCommand command,
  ) async => MediaPublicationResult(
    exerciseId: manifest.exerciseId,
    guidanceRevisionId: '85000000-0000-4000-8000-000000000001',
    versionNumber: 2,
    contentHash: '1' * 64,
    revisionHash: '2' * 64,
    manifestHash: '3' * 64,
    bundleHash: '4' * 64,
    noChange: false,
    replayed: false,
    correlationId: '86000000-0000-4000-8000-000000000002',
  );

  @override
  Future<DuplicateGuidanceMediaResult> duplicateRevisionWithMediaAsDraft(
    DuplicateGuidanceRevisionWithMediaCommand command,
  ) async => DuplicateGuidanceMediaResult(
    manifest: manifest,
    sourceGuidanceRevisionId: command.guidanceRevisionId,
    draftRevision: command.expectedDraftRevision + 1,
    mediaRevision: manifest.mediaRevision,
    imageCount: manifest.images.length,
    youtubeCopied: manifest.youtube != null,
    reusedPublishedObjects: true,
    replayed: false,
    correlationId: '88000000-0000-4000-8000-000000000001',
  );

  @override
  Future<CreateGuidanceMediaDraftFromRevisionResult> createGuidanceMediaDraftFromRevision(
    CreateGuidanceMediaDraftFromRevisionCommand command,
  ) async {
    _throwFailure();
    draftMaterializations.add(command);
    final blocker = draftMaterializationBlocker;
    if (blocker != null) return blocker.future;
    return draftMaterializationResult ??
        CreateGuidanceMediaDraftFromRevisionResult(
          exerciseId: command.exerciseId,
          sourceGuidanceRevisionId: command.guidanceRevisionId,
          draftId: '40000000-0000-4000-8000-000000000001',
          exerciseRevision: command.expectedExerciseRevision,
          draftRevision: 1,
          mediaRevision: manifest.mediaRevision,
          imageCount: manifest.images.length,
          youtubeCopied: manifest.youtube != null,
          reusedPublishedObjects: true,
          replayed: false,
          correlationId: '89000000-0000-4000-8000-000000000001',
        );
  }

  void _throwFailure() {
    final current = failure;
    if (current != null) throw current;
  }

  MediaMutationResult<GuidanceMediaManifest> _result() =>
      MediaMutationResult<GuidanceMediaManifest>(
        value: manifest,
        replayed: false,
        correlationId: '87000000-0000-4000-8000-000000000001',
      );

  GuidanceMediaManifest _copyManifest({
    List<GuidanceImageAsset>? images,
    GuidanceYouTubeReference? youtube,
    bool clearYouTube = false,
  }) => GuidanceMediaManifest(
    exerciseId: manifest.exerciseId,
    ownerId: manifest.ownerId,
    draftId: manifest.draftId,
    guidanceRevisionId: manifest.guidanceRevisionId,
    guidanceRevisionHash: manifest.guidanceRevisionHash,
    mediaRevision: manifest.mediaRevision + 1,
    images: images ?? manifest.images,
    youtube: clearYouTube ? null : youtube ?? manifest.youtube,
    manifestHash: manifest.manifestHash,
    bundleHash: manifest.bundleHash,
  );
}

GuidanceMediaManifest emptyMediaManifest({
  String exerciseId = '20000000-0000-4000-8000-000000000001',
  String draftId = '40000000-0000-4000-8000-000000000001',
}) => GuidanceMediaManifest(
  exerciseId: exerciseId,
  ownerId: '00000000-0000-4000-8000-000000000001',
  draftId: draftId,
  mediaRevision: 0,
  images: const <GuidanceImageAsset>[],
  youtube: null,
);

GuidanceImageAsset _copyImage(
  GuidanceImageAsset image, {
  required String altText,
  required int position,
  required bool isCover,
}) => GuidanceImageAsset(
  id: image.id,
  ownerId: image.ownerId,
  exerciseId: image.exerciseId,
  draftId: image.draftId,
  guidanceRevisionId: image.guidanceRevisionId,
  bucketId: image.bucketId,
  objectPath: image.objectPath,
  mimeType: image.mimeType,
  byteSize: image.byteSize,
  width: image.width,
  height: image.height,
  sha256Hex: image.sha256Hex,
  altText: altText,
  position: position,
  isCover: isCover,
  lifecycle: image.lifecycle,
  createdAt: image.createdAt,
  updatedAt: image.updatedAt,
);
