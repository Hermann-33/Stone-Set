import 'exercise_media_models.dart';

enum ExerciseMediaErrorCode {
  invalidInput,
  staleRevision,
  uploadExpired,
  uploadCancelled,
  uploadConflict,
  previewRequired,
  notFound,
  forbidden,
  inactiveProfile,
  passwordChangeRequired,
  sessionExpired,
  networkUnavailable,
  serverUnavailable,
  unknown,
}

final class ExerciseMediaConflictEvidence {
  const ExerciseMediaConflictEvidence({
    this.exerciseRevision,
    this.draftRevision,
    this.mediaRevision,
  });

  final int? exerciseRevision;
  final int? draftRevision;
  final int? mediaRevision;
}

final class ExerciseMediaFailure implements Exception {
  const ExerciseMediaFailure(this.code, {this.correlationId, this.conflict});

  final ExerciseMediaErrorCode code;
  final String? correlationId;
  final ExerciseMediaConflictEvidence? conflict;

  @override
  String toString() => 'ExerciseMediaFailure(${code.name})';
}

enum MediaUploadPhase { preparing, uploading, uploaded }

final class MediaUploadProgress {
  const MediaUploadProgress({
    required this.phase,
    required this.completedBytes,
    required this.totalBytes,
  });

  final MediaUploadPhase phase;
  final int completedBytes;
  final int totalBytes;
}

typedef MediaUploadProgressCallback = void Function(MediaUploadProgress progress);

abstract interface class MediaUploadCancellation {
  bool get isCancelled;
}

final class NeverCancelledMediaUpload implements MediaUploadCancellation {
  const NeverCancelledMediaUpload();

  @override
  bool get isCancelled => false;
}

final class CreateMediaUploadIntentCommand {
  const CreateMediaUploadIntentCommand({
    required this.exerciseId,
    required this.draftId,
    required this.mimeType,
    required this.expectedDraftRevision,
    required this.expectedMediaRevision,
    required this.idempotencyKey,
  });

  final String exerciseId;
  final String draftId;
  final GuidanceMediaMimeType mimeType;
  final int expectedDraftRevision;
  final int expectedMediaRevision;
  final String idempotencyKey;
}

final class FinalizeMediaUploadCommand {
  const FinalizeMediaUploadCommand({
    required this.intentId,
    required this.byteSize,
    required this.width,
    required this.height,
    required this.sha256Hex,
    required this.expectedMediaRevision,
    required this.idempotencyKey,
  });

  final String intentId;
  final int byteSize;
  final int width;
  final int height;
  final String sha256Hex;
  final int expectedMediaRevision;
  final String idempotencyKey;
}

final class DraftMediaLayoutItem {
  const DraftMediaLayoutItem({
    required this.assetId,
    required this.altText,
    required this.position,
    required this.isCover,
  });

  final String assetId;
  final String altText;
  final int position;
  final bool isCover;
}

final class SaveMediaLayoutCommand {
  SaveMediaLayoutCommand({
    required this.exerciseId,
    required this.draftId,
    required Iterable<DraftMediaLayoutItem> images,
    required this.expectedMediaRevision,
    required this.idempotencyKey,
  }) : images = List<DraftMediaLayoutItem>.unmodifiable(images);

  final String exerciseId;
  final String draftId;
  final List<DraftMediaLayoutItem> images;
  final int expectedMediaRevision;
  final String idempotencyKey;
}

final class RemoveMediaAssetCommand {
  const RemoveMediaAssetCommand({
    required this.exerciseId,
    required this.draftId,
    required this.assetId,
    required this.expectedMediaRevision,
    required this.idempotencyKey,
  });

  final String exerciseId;
  final String draftId;
  final String assetId;
  final int expectedMediaRevision;
  final String idempotencyKey;
}

final class SaveYouTubeReferenceCommand {
  const SaveYouTubeReferenceCommand({
    required this.exerciseId,
    required this.draftId,
    required this.reference,
    required this.expectedMediaRevision,
    required this.idempotencyKey,
  });

  final String exerciseId;
  final String draftId;
  final GuidanceYouTubeReference reference;
  final int expectedMediaRevision;
  final String idempotencyKey;
}

final class RemoveYouTubeReferenceCommand {
  const RemoveYouTubeReferenceCommand({
    required this.exerciseId,
    required this.draftId,
    required this.expectedMediaRevision,
    required this.idempotencyKey,
  });

  final String exerciseId;
  final String draftId;
  final int expectedMediaRevision;
  final String idempotencyKey;
}

final class BeginMediaPublicationCommand {
  const BeginMediaPublicationCommand({
    required this.exerciseId,
    required this.draftId,
    required this.expectedExerciseRevision,
    required this.expectedDraftRevision,
    required this.expectedMediaRevision,
    required this.idempotencyKey,
  });

  final String exerciseId;
  final String draftId;
  final int expectedExerciseRevision;
  final int expectedDraftRevision;
  final int expectedMediaRevision;
  final String idempotencyKey;
}

final class FinalizeMediaPublicationCommand {
  const FinalizeMediaPublicationCommand({
    required this.reservationId,
    required this.idempotencyKey,
  });

  final String reservationId;
  final String idempotencyKey;
}

final class DuplicateGuidanceRevisionWithMediaCommand {
  const DuplicateGuidanceRevisionWithMediaCommand({
    required this.exerciseId,
    required this.guidanceRevisionId,
    required this.expectedDraftRevision,
    required this.expectedMediaRevision,
    required this.idempotencyKey,
  });

  final String exerciseId;
  final String guidanceRevisionId;
  final int expectedDraftRevision;
  final int expectedMediaRevision;
  final String idempotencyKey;
}

abstract interface class ExerciseMediaReadRepository {
  Future<GuidanceMediaManifest> getRevisionManifest(
    String exerciseId,
    String guidanceRevisionId,
  );

  Future<MediaAccessUrl> createImageAccessUrl(
    GuidanceImageAsset asset, {
    Duration lifetime = const Duration(minutes: 5),
  });
}

abstract interface class ExerciseMediaRepository implements ExerciseMediaReadRepository {
  Future<GuidanceMediaManifest> getDraftManifest(String exerciseId, String draftId);

  Future<MediaUploadIntent> createUploadIntent(CreateMediaUploadIntentCommand command);

  /// The standard Supabase upload request is not a cancellable byte stream.
  /// Cancellation is honored before the request and immediately after it
  /// returns; progress represents honest request phases, not streamed bytes.
  /// An already-existing response for this exact server-issued intent/path may
  /// represent a lost-response retry and can proceed to [finalizeUpload]; only
  /// that server operation verifies object metadata and proves completion.
  Future<void> uploadPendingBytes(
    MediaUploadIntent intent,
    List<int> bytes, {
    MediaUploadProgressCallback? onProgress,
    MediaUploadCancellation cancellation = const NeverCancelledMediaUpload(),
  });

  Future<MediaMutationResult<GuidanceMediaManifest>> finalizeUpload(
    FinalizeMediaUploadCommand command,
  );

  Future<MediaMutationResult<GuidanceMediaManifest>> saveLayout(
    SaveMediaLayoutCommand command,
  );

  Future<MediaMutationResult<GuidanceMediaManifest>> removeAsset(
    RemoveMediaAssetCommand command,
  );

  Future<MediaMutationResult<GuidanceMediaManifest>> saveYouTubeReference(
    SaveYouTubeReferenceCommand command,
  );

  Future<MediaMutationResult<GuidanceMediaManifest>> removeYouTubeReference(
    RemoveYouTubeReferenceCommand command,
  );

  Future<MediaPublicationReservation> beginPublication(
    BeginMediaPublicationCommand command,
  );

  Future<void> copyReservedObjects(MediaPublicationReservation reservation);

  Future<MediaPublicationResult> finalizePublication(
    FinalizeMediaPublicationCommand command,
  );

  /// Atomically duplicates guidance text and published media metadata into the
  /// owned draft. Published object bytes remain immutable and are not copied by
  /// the client; a later publication reservation performs any required copy.
  Future<DuplicateGuidanceMediaResult> duplicateRevisionWithMediaAsDraft(
    DuplicateGuidanceRevisionWithMediaCommand command,
  );
}
