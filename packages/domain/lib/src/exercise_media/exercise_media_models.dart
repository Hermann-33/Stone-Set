import 'dart:collection';

enum GuidanceMediaMimeType {
  jpeg('image/jpeg', 'jpg'),
  png('image/png', 'png'),
  webp('image/webp', 'webp');

  const GuidanceMediaMimeType(this.wireValue, this.fileExtension);

  final String wireValue;
  final String fileExtension;

  static GuidanceMediaMimeType fromWireValue(String value) => switch (value) {
    'image/jpeg' => GuidanceMediaMimeType.jpeg,
    'image/png' => GuidanceMediaMimeType.png,
    'image/webp' => GuidanceMediaMimeType.webp,
    _ => throw const FormatException('Unsupported guidance media MIME type.'),
  };
}

enum GuidanceMediaLifecycle {
  pending,
  ready,
  publishReserved,
  published,
  quarantined,
}

enum YouTubeValidationStatus { previewRequired, validated, unavailable }

final class GuidanceImageAsset {
  const GuidanceImageAsset({
    required this.id,
    required this.ownerId,
    required this.exerciseId,
    required this.bucketId,
    required this.objectPath,
    required this.mimeType,
    required this.byteSize,
    required this.width,
    required this.height,
    required this.sha256Hex,
    required this.altText,
    required this.position,
    required this.isCover,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.draftId,
    this.guidanceRevisionId,
  });

  final String id;
  final String ownerId;
  final String exerciseId;
  final String? draftId;
  final String? guidanceRevisionId;
  final String bucketId;
  final String objectPath;
  final GuidanceMediaMimeType mimeType;
  final int byteSize;
  final int width;
  final int height;
  final String sha256Hex;
  final String altText;
  final int position;
  final bool isCover;
  final GuidanceMediaLifecycle lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class GuidanceYouTubeReference {
  const GuidanceYouTubeReference({
    required this.videoId,
    required this.canonicalWatchUrl,
    required this.validationStatus,
    this.startSeconds,
    this.titleSnapshot,
    this.thumbnailUrlSnapshot,
    this.validatedAt,
  });

  static const provider = 'youtube';

  final String videoId;
  final Uri canonicalWatchUrl;
  final int? startSeconds;
  final String? titleSnapshot;
  final Uri? thumbnailUrlSnapshot;
  final YouTubeValidationStatus validationStatus;
  final DateTime? validatedAt;

  bool get isPublishable =>
      validationStatus == YouTubeValidationStatus.validated && validatedAt != null;
}

final class GuidanceMediaManifest {
  GuidanceMediaManifest({
    required this.exerciseId,
    required this.ownerId,
    required this.mediaRevision,
    required Iterable<GuidanceImageAsset> images,
    required this.youtube,
    this.draftId,
    this.guidanceRevisionId,
    this.guidanceRevisionHash,
    this.manifestHash,
    this.bundleHash,
  }) : images = UnmodifiableListView<GuidanceImageAsset>(
         List<GuidanceImageAsset>.of(images),
       );

  static const schemaVersion = 1;
  static const bucketId = 'exercise-media';

  final String exerciseId;
  final String ownerId;
  final String? draftId;
  final String? guidanceRevisionId;
  final String? guidanceRevisionHash;
  final int mediaRevision;
  final List<GuidanceImageAsset> images;
  final GuidanceYouTubeReference? youtube;
  final String? manifestHash;
  final String? bundleHash;

  bool get isPublished => guidanceRevisionId != null;
}

final class MediaUploadIntent {
  const MediaUploadIntent({
    required this.intentId,
    required this.assetId,
    required this.ownerId,
    required this.exerciseId,
    required this.draftId,
    required this.bucketId,
    required this.objectPath,
    required this.mimeType,
    required this.maximumByteSize,
    required this.mediaRevision,
    required this.expiresAt,
    required this.replayed,
    required this.correlationId,
  });

  final String intentId;
  final String assetId;
  final String ownerId;
  final String exerciseId;
  final String draftId;
  final String bucketId;
  final String objectPath;
  final GuidanceMediaMimeType mimeType;
  final int maximumByteSize;
  final int mediaRevision;
  final DateTime expiresAt;
  final bool replayed;
  final String correlationId;

  bool isExpiredAt(DateTime instant) => !instant.toUtc().isBefore(expiresAt.toUtc());
}

final class MediaPublicationCopy {
  const MediaPublicationCopy({
    required this.assetId,
    required this.sourcePath,
    required this.destinationPath,
  });

  final String assetId;
  final String sourcePath;
  final String destinationPath;
}

final class MediaPublicationReservation {
  MediaPublicationReservation({
    required this.reservationId,
    required this.exerciseId,
    required this.draftId,
    required this.guidanceRevisionId,
    required this.contentHash,
    required this.revisionHash,
    required this.manifestHash,
    required this.bundleHash,
    required this.expiresAt,
    required Iterable<MediaPublicationCopy> copies,
    required this.noChange,
    required this.replayed,
    required this.correlationId,
  }) : copies = UnmodifiableListView<MediaPublicationCopy>(
         List<MediaPublicationCopy>.of(copies),
       );

  final String reservationId;
  final String exerciseId;
  final String draftId;
  final String guidanceRevisionId;
  final String contentHash;
  final String revisionHash;
  final String manifestHash;
  final String bundleHash;
  final DateTime expiresAt;
  final List<MediaPublicationCopy> copies;
  final bool noChange;
  final bool replayed;
  final String correlationId;
}

final class MediaPublicationResult {
  const MediaPublicationResult({
    required this.exerciseId,
    required this.guidanceRevisionId,
    required this.versionNumber,
    required this.contentHash,
    required this.revisionHash,
    required this.manifestHash,
    required this.bundleHash,
    required this.noChange,
    required this.replayed,
    required this.correlationId,
  });

  final String exerciseId;
  final String guidanceRevisionId;
  final int versionNumber;
  final String contentHash;
  final String revisionHash;
  final String manifestHash;
  final String bundleHash;
  final bool noChange;
  final bool replayed;
  final String correlationId;
}

final class DuplicateGuidanceMediaResult {
  const DuplicateGuidanceMediaResult({
    required this.manifest,
    required this.sourceGuidanceRevisionId,
    required this.draftRevision,
    required this.mediaRevision,
    required this.imageCount,
    required this.youtubeCopied,
    required this.reusedPublishedObjects,
    required this.replayed,
    required this.correlationId,
  });

  final GuidanceMediaManifest manifest;
  final String sourceGuidanceRevisionId;
  final int draftRevision;
  final int mediaRevision;
  final int imageCount;
  final bool youtubeCopied;
  final bool reusedPublishedObjects;
  final bool replayed;
  final String correlationId;
}

final class CreateGuidanceMediaDraftFromRevisionResult {
  const CreateGuidanceMediaDraftFromRevisionResult({
    required this.exerciseId,
    required this.sourceGuidanceRevisionId,
    required this.draftId,
    required this.exerciseRevision,
    required this.draftRevision,
    required this.mediaRevision,
    required this.imageCount,
    required this.youtubeCopied,
    required this.reusedPublishedObjects,
    required this.replayed,
    required this.correlationId,
  });

  final String exerciseId;
  final String sourceGuidanceRevisionId;
  final String draftId;
  final int exerciseRevision;
  final int draftRevision;
  final int mediaRevision;
  final int imageCount;
  final bool youtubeCopied;
  final bool reusedPublishedObjects;
  final bool replayed;
  final String correlationId;
}

final class MediaMutationResult<T> {
  const MediaMutationResult({
    required this.value,
    required this.replayed,
    required this.correlationId,
  });

  final T value;
  final bool replayed;
  final String correlationId;
}

final class MediaAccessUrl {
  const MediaAccessUrl({required this.url, required this.expiresAt});

  final Uri url;
  final DateTime expiresAt;
}
