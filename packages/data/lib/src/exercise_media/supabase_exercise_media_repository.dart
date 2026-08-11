import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_domain/exercise_media.dart';

import 'exercise_media_remote_service.dart';
import 'supabase_exercise_media_error_mapper.dart';

final class SupabaseExerciseMediaRepository implements ExerciseMediaRepository {
  const SupabaseExerciseMediaRepository({
    required this.remote,
    required this.storage,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final ExerciseMediaRemoteService remote;
  final ExerciseMediaStorageService storage;
  final DateTime Function() _now;

  @override
  Future<GuidanceMediaManifest> getDraftManifest(String exerciseId, String draftId) => _guard(
    () async => _decodeManifest(
      await remote.fetchDraftManifest(exerciseId, draftId),
      expectedExerciseId: exerciseId,
      expectedDraftId: draftId,
    ),
  );

  @override
  Future<GuidanceMediaManifest> getRevisionManifest(
    String exerciseId,
    String guidanceRevisionId,
  ) => _guard(
    () async => _decodeManifest(
      await remote.fetchRevisionManifest(exerciseId, guidanceRevisionId),
      expectedExerciseId: exerciseId,
      expectedGuidanceRevisionId: guidanceRevisionId,
    ),
  );

  @override
  Future<MediaAccessUrl> createImageAccessUrl(
    GuidanceImageAsset asset, {
    Duration lifetime = const Duration(minutes: 5),
  }) => _guard(() async {
    if (asset.bucketId != GuidanceMediaManifest.bucketId ||
        lifetime <= Duration.zero ||
        lifetime > const Duration(minutes: 5)) {
      throw const ExerciseMediaFailure(ExerciseMediaErrorCode.invalidInput);
    }
    final url = await storage.createSignedUrl(asset, lifetime);
    if (url.scheme != 'https' || url.host.isEmpty || url.userInfo.isNotEmpty) {
      throw const FormatException('Signed media URL is invalid.');
    }
    return MediaAccessUrl(url: url, expiresAt: _now().toUtc().add(lifetime));
  });

  @override
  Future<MediaUploadIntent> createUploadIntent(CreateMediaUploadIntentCommand command) =>
      _guard(() async {
        final envelope = await remote.createUploadIntent(command);
        _requireOperation(envelope, 'create_guidance_media_upload_intent_v1');
        _requireMatch(envelope, 'exerciseId', command.exerciseId);
        _requireMatch(envelope, 'draftId', command.draftId);
        final intent = MediaUploadIntent(
          intentId: _requiredString(envelope, 'intentId'),
          assetId: _requiredString(envelope, 'assetId'),
          ownerId: _requiredString(envelope, 'ownerId'),
          exerciseId: command.exerciseId,
          draftId: command.draftId,
          bucketId: _requiredString(envelope, 'bucketId'),
          objectPath: _requiredString(envelope, 'objectPath'),
          mimeType: GuidanceMediaMimeType.fromWireValue(
            _requiredString(envelope, 'mimeType'),
          ),
          maximumByteSize: _requiredInt(envelope, 'maximumByteSize'),
          mediaRevision: _requiredInt(envelope, 'mediaRevision'),
          expiresAt: _requiredDate(envelope, 'expiresAt'),
          replayed: _requiredBool(envelope, 'replayed'),
          correlationId: _requiredString(envelope, 'correlationId'),
        );
        if (intent.bucketId != GuidanceMediaManifest.bucketId ||
            intent.mimeType != command.mimeType ||
            intent.maximumByteSize < 1 ||
            intent.maximumByteSize > 5 * 1024 * 1024 ||
            !_isPendingPath(intent)) {
          throw const FormatException('Upload intent is inconsistent.');
        }
        return intent;
      });

  @override
  Future<void> uploadPendingBytes(
    MediaUploadIntent intent,
    List<int> bytes, {
    MediaUploadProgressCallback? onProgress,
    MediaUploadCancellation cancellation = const NeverCancelledMediaUpload(),
  }) => _guard(() async {
    if (intent.isExpiredAt(_now())) {
      throw const ExerciseMediaFailure(ExerciseMediaErrorCode.uploadExpired);
    }
    if (bytes.isEmpty || bytes.length > intent.maximumByteSize) {
      throw const ExerciseMediaFailure(ExerciseMediaErrorCode.invalidInput);
    }
    if (cancellation.isCancelled) {
      throw const ExerciseMediaFailure(ExerciseMediaErrorCode.uploadCancelled);
    }
    onProgress?.call(
      MediaUploadProgress(
        phase: MediaUploadPhase.preparing,
        completedBytes: 0,
        totalBytes: bytes.length,
      ),
    );
    onProgress?.call(
      MediaUploadProgress(
        phase: MediaUploadPhase.uploading,
        completedBytes: 0,
        totalBytes: bytes.length,
      ),
    );
    try {
      await storage.upload(intent, bytes);
    } on Object catch (error) {
      final failure = mapSupabaseExerciseMediaFailure(error);
      if (failure.code != ExerciseMediaErrorCode.uploadConflict) {
        throw failure;
      }
      // Storage may report that the exact server-issued intent/path already
      // exists after a lost response or retry. This is not byte-integrity
      // proof: the subsequent finalize RPC remains authoritative and must
      // verify the stored object metadata against this one-time intent.
    }
    if (cancellation.isCancelled) {
      throw const ExerciseMediaFailure(ExerciseMediaErrorCode.uploadCancelled);
    }
    onProgress?.call(
      MediaUploadProgress(
        phase: MediaUploadPhase.uploaded,
        completedBytes: bytes.length,
        totalBytes: bytes.length,
      ),
    );
  });

  @override
  Future<MediaMutationResult<GuidanceMediaManifest>> finalizeUpload(
    FinalizeMediaUploadCommand command,
  ) => _guard(() async {
    final envelope = await remote.finalizeUpload(command);
    final evidence = _mutationEvidence(envelope, 'finalize_guidance_media_upload_v1');
    final exerciseId = _requiredString(envelope, 'exerciseId');
    final draftId = _requiredString(envelope, 'draftId');
    final manifest = await getDraftManifest(exerciseId, draftId);
    if (manifest.mediaRevision != _requiredInt(envelope, 'mediaRevision')) {
      throw const FormatException('Upload result revision is inconsistent.');
    }
    return MediaMutationResult<GuidanceMediaManifest>(
      value: manifest,
      replayed: evidence.replayed,
      correlationId: evidence.correlationId,
    );
  });

  @override
  Future<MediaMutationResult<GuidanceMediaManifest>> saveLayout(
    SaveMediaLayoutCommand command,
  ) => _draftMutation(
    operation: 'save_guidance_media_layout_v1',
    exerciseId: command.exerciseId,
    draftId: command.draftId,
    action: () => remote.saveLayout(command),
  );

  @override
  Future<MediaMutationResult<GuidanceMediaManifest>> removeAsset(
    RemoveMediaAssetCommand command,
  ) => _draftMutation(
    operation: 'remove_guidance_media_asset_v1',
    exerciseId: command.exerciseId,
    draftId: command.draftId,
    action: () => remote.removeAsset(command),
  );

  @override
  Future<MediaMutationResult<GuidanceMediaManifest>> saveYouTubeReference(
    SaveYouTubeReferenceCommand command,
  ) {
    final reference = command.reference;
    if (reference.validationStatus == YouTubeValidationStatus.unavailable ||
        (reference.validationStatus == YouTubeValidationStatus.previewRequired &&
            reference.validatedAt != null) ||
        (reference.validationStatus == YouTubeValidationStatus.validated &&
            reference.validatedAt == null)) {
      return Future<MediaMutationResult<GuidanceMediaManifest>>.error(
        const ExerciseMediaFailure(ExerciseMediaErrorCode.invalidInput),
      );
    }
    return _draftMutation(
      operation: 'save_guidance_youtube_reference_v1',
      exerciseId: command.exerciseId,
      draftId: command.draftId,
      action: () => remote.saveYouTubeReference(command),
    );
  }

  @override
  Future<MediaMutationResult<GuidanceMediaManifest>> removeYouTubeReference(
    RemoveYouTubeReferenceCommand command,
  ) => _draftMutation(
    operation: 'remove_guidance_youtube_reference_v1',
    exerciseId: command.exerciseId,
    draftId: command.draftId,
    action: () => remote.removeYouTubeReference(command),
  );

  Future<MediaMutationResult<GuidanceMediaManifest>> _draftMutation({
    required String operation,
    required String exerciseId,
    required String draftId,
    required Future<Map<String, Object?>> Function() action,
  }) => _guard(() async {
    final envelope = await action();
    final evidence = _mutationEvidence(envelope, operation);
    _requireMatch(envelope, 'exerciseId', exerciseId);
    _requireMatch(envelope, 'draftId', draftId);
    final manifest = await getDraftManifest(exerciseId, draftId);
    if (manifest.mediaRevision != _requiredInt(envelope, 'mediaRevision')) {
      throw const FormatException('Draft media revision is inconsistent.');
    }
    return MediaMutationResult<GuidanceMediaManifest>(
      value: manifest,
      replayed: evidence.replayed,
      correlationId: evidence.correlationId,
    );
  });

  @override
  Future<MediaPublicationReservation> beginPublication(
    BeginMediaPublicationCommand command,
  ) => _guard(() async {
    final envelope = await remote.beginPublication(command);
    _requireOperation(envelope, 'begin_guidance_media_publication_v1');
    _requireMatch(envelope, 'exerciseId', command.exerciseId);
    _requireMatch(envelope, 'draftId', command.draftId);
    final copies = _requiredList(envelope, 'copies')
        .map((value) {
          final copy = _map(value);
          return MediaPublicationCopy(
            assetId: _requiredString(copy, 'assetId'),
            sourcePath: _requiredString(copy, 'sourcePath'),
            destinationPath: _requiredString(copy, 'destinationPath'),
          );
        })
        .toList(growable: false);
    final reservation = MediaPublicationReservation(
      reservationId: _requiredString(envelope, 'reservationId'),
      exerciseId: command.exerciseId,
      draftId: command.draftId,
      guidanceRevisionId: _requiredString(envelope, 'guidanceRevisionId'),
      contentHash: _requiredHash(envelope, 'contentHash'),
      revisionHash: _requiredHash(envelope, 'revisionHash'),
      manifestHash: _requiredHash(envelope, 'manifestHash'),
      bundleHash: _requiredHash(envelope, 'bundleHash'),
      expiresAt: _requiredDate(envelope, 'expiresAt'),
      copies: copies,
      noChange: _requiredBool(envelope, 'noChange'),
      replayed: _requiredBool(envelope, 'replayed'),
      correlationId: _requiredString(envelope, 'correlationId'),
    );
    if (copies.length > 6 ||
        copies.any(
          (copy) => !_safeStoragePath(copy.sourcePath) || !_safeStoragePath(copy.destinationPath),
        )) {
      throw const FormatException('Publication copy plan is invalid.');
    }
    return reservation;
  });

  @override
  Future<void> copyReservedObjects(MediaPublicationReservation reservation) => _guard(() async {
    if (!reservation.expiresAt.isAfter(_now().toUtc())) {
      throw const ExerciseMediaFailure(ExerciseMediaErrorCode.uploadExpired);
    }
    for (final copy in reservation.copies) {
      try {
        await storage.copy(copy);
      } on Object catch (error) {
        final failure = mapSupabaseExerciseMediaFailure(error);
        if (failure.code != ExerciseMediaErrorCode.uploadConflict) {
          throw failure;
        }
        // An exact retry may find its prior copy. Finalization revalidates the
        // destination Storage row against the reservation before publication.
      }
    }
  });

  @override
  Future<MediaPublicationResult> finalizePublication(
    FinalizeMediaPublicationCommand command,
  ) => _guard(() async {
    final envelope = await remote.finalizePublication(command);
    final evidence = _mutationEvidence(envelope, 'finalize_guidance_media_publication_v1');
    _requireMatch(envelope, 'reservationId', command.reservationId);
    final result = MediaPublicationResult(
      exerciseId: _requiredString(envelope, 'exerciseId'),
      guidanceRevisionId: _requiredString(envelope, 'guidanceRevisionId'),
      versionNumber: _requiredInt(envelope, 'versionNumber'),
      contentHash: _requiredHash(envelope, 'contentHash'),
      revisionHash: _requiredHash(envelope, 'revisionHash'),
      manifestHash: _requiredHash(envelope, 'manifestHash'),
      bundleHash: _requiredHash(envelope, 'bundleHash'),
      noChange: _requiredBool(envelope, 'noChange'),
      replayed: evidence.replayed,
      correlationId: evidence.correlationId,
    );
    final expectedBundleHash =
        ExerciseMediaCanonicalizer(
          unicodeNormalizer: const AlreadyNormalizedUnicodeNormalizer(),
        ).bundleHash(
          guidanceRevisionHash: result.revisionHash,
          manifestHash: result.manifestHash,
        );
    if (result.bundleHash != expectedBundleHash) {
      throw const FormatException('Published guidance bundle hash is inconsistent.');
    }
    return result;
  });

  @override
  Future<DuplicateGuidanceMediaResult> duplicateRevisionWithMediaAsDraft(
    DuplicateGuidanceRevisionWithMediaCommand command,
  ) => _guard(() async {
    final envelope = await remote.duplicateRevisionWithMediaAsDraft(command);
    final evidence = _mutationEvidence(
      envelope,
      'duplicate_guidance_revision_with_media_as_draft_v1',
    );
    _requireMatch(envelope, 'exerciseId', command.exerciseId);
    _requireMatch(
      envelope,
      'sourceGuidanceRevisionId',
      command.guidanceRevisionId,
    );
    final draftId = _requiredString(envelope, 'draftId');
    final imageCount = _requiredInt(envelope, 'imageCount');
    final youtubeCopied = _requiredBool(envelope, 'youtubeCopied');
    if (!_requiredBool(envelope, 'reusedPublishedObjects') || imageCount < 0 || imageCount > 6) {
      throw const FormatException('Duplicated media evidence is invalid.');
    }
    final manifest = await getDraftManifest(command.exerciseId, draftId);
    if (manifest.images.length != imageCount ||
        (manifest.youtube != null) != youtubeCopied ||
        manifest.mediaRevision != _requiredInt(envelope, 'mediaRevision')) {
      throw const FormatException('Duplicated media manifest is inconsistent.');
    }
    return DuplicateGuidanceMediaResult(
      manifest: manifest,
      sourceGuidanceRevisionId: command.guidanceRevisionId,
      draftRevision: _requiredInt(envelope, 'draftRevision'),
      mediaRevision: manifest.mediaRevision,
      imageCount: imageCount,
      youtubeCopied: youtubeCopied,
      reusedPublishedObjects: true,
      replayed: evidence.replayed,
      correlationId: evidence.correlationId,
    );
  });

  @override
  Future<CreateGuidanceMediaDraftFromRevisionResult> createGuidanceMediaDraftFromRevision(
    CreateGuidanceMediaDraftFromRevisionCommand command,
  ) => _guard(() async {
    final envelope = await remote.createGuidanceMediaDraftFromRevision(command);
    final evidence = _mutationEvidence(
      envelope,
      'create_guidance_media_draft_from_revision_v1',
    );
    _requireMatch(envelope, 'exerciseId', command.exerciseId);
    _requireMatch(
      envelope,
      'sourceGuidanceRevisionId',
      command.guidanceRevisionId,
    );
    final exerciseRevision = _requiredInt(envelope, 'exerciseRevision');
    final draftRevision = _requiredInt(envelope, 'draftRevision');
    final mediaRevision = _requiredInt(envelope, 'mediaRevision');
    final imageCount = _requiredInt(envelope, 'imageCount');
    final youtubeCopied = _requiredBool(envelope, 'youtubeCopied');
    final reusedPublishedObjects = _requiredBool(
      envelope,
      'reusedPublishedObjects',
    );
    if (exerciseRevision < 0 ||
        draftRevision < 0 ||
        mediaRevision < 0 ||
        imageCount < 0 ||
        imageCount > 6 ||
        !reusedPublishedObjects) {
      throw const FormatException('Created guidance/media draft evidence is invalid.');
    }
    return CreateGuidanceMediaDraftFromRevisionResult(
      exerciseId: command.exerciseId,
      sourceGuidanceRevisionId: command.guidanceRevisionId,
      draftId: _requiredString(envelope, 'draftId'),
      exerciseRevision: exerciseRevision,
      draftRevision: draftRevision,
      mediaRevision: mediaRevision,
      imageCount: imageCount,
      youtubeCopied: youtubeCopied,
      reusedPublishedObjects: reusedPublishedObjects,
      replayed: evidence.replayed,
      correlationId: evidence.correlationId,
    );
  });
}

Future<T> _guard<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on ExerciseMediaFailure {
    rethrow;
  } on Object catch (error) {
    throw mapSupabaseExerciseMediaFailure(error);
  }
}

GuidanceMediaManifest _decodeManifest(
  Map<String, Object?> value, {
  required String expectedExerciseId,
  String? expectedDraftId,
  String? expectedGuidanceRevisionId,
}) {
  if (_requiredInt(value, 'schemaVersion') != GuidanceMediaManifest.schemaVersion) {
    throw const FormatException('Unsupported media manifest schema.');
  }
  _requireMatch(value, 'exerciseId', expectedExerciseId);
  if (expectedDraftId != null) {
    _requireMatch(value, 'draftId', expectedDraftId);
  }
  if (expectedGuidanceRevisionId != null) {
    _requireMatch(value, 'guidanceRevisionId', expectedGuidanceRevisionId);
  }
  final images = _requiredList(value, 'images').map((raw) => _decodeImage(_map(raw))).toList();
  final ownerId = _requiredString(value, 'ownerId');
  if (images.length > 6 ||
      images.map((image) => image.position).toSet().length != images.length ||
      images.any(
        (image) =>
            image.ownerId != ownerId ||
            image.exerciseId != expectedExerciseId ||
            image.draftId != value['draftId'] ||
            image.guidanceRevisionId != value['guidanceRevisionId'],
      )) {
    throw const FormatException('Media manifest image bounds are invalid.');
  }
  images.sort((left, right) => left.position.compareTo(right.position));
  final manifest = GuidanceMediaManifest(
    exerciseId: expectedExerciseId,
    ownerId: ownerId,
    draftId: value['draftId'] as String?,
    guidanceRevisionId: value['guidanceRevisionId'] as String?,
    guidanceRevisionHash: _optionalHash(value['guidanceRevisionHash']),
    mediaRevision: _requiredInt(value, 'mediaRevision'),
    images: images,
    youtube: value['youtube'] == null ? null : _decodeYouTube(_map(value['youtube'])),
    manifestHash: _optionalHash(value['manifestHash']),
    bundleHash: _optionalHash(value['bundleHash']),
  );
  if (manifest.isPublished &&
      images.isNotEmpty &&
      images.where((image) => image.isCover).length != 1) {
    throw const FormatException('Published media manifest cover evidence is invalid.');
  }
  final canonicalizer = ExerciseMediaCanonicalizer(
    unicodeNormalizer: const AlreadyNormalizedUnicodeNormalizer(),
  );
  if (manifest.manifestHash != null &&
      canonicalizer.manifestHash(manifest) != manifest.manifestHash) {
    throw const FormatException('Media manifest hash is inconsistent.');
  }
  if (manifest.bundleHash != null) {
    if (manifest.guidanceRevisionHash == null || manifest.manifestHash == null) {
      throw const FormatException('Guidance bundle evidence is incomplete.');
    }
    final expectedBundleHash = canonicalizer.bundleHash(
      guidanceRevisionHash: manifest.guidanceRevisionHash!,
      manifestHash: manifest.manifestHash!,
    );
    if (expectedBundleHash != manifest.bundleHash) {
      throw const FormatException('Guidance bundle hash is inconsistent.');
    }
  }
  return manifest;
}

GuidanceImageAsset _decodeImage(Map<String, Object?> value) {
  final asset = GuidanceImageAsset(
    id: _requiredString(value, 'assetId'),
    ownerId: _requiredString(value, 'ownerId'),
    exerciseId: _requiredString(value, 'exerciseId'),
    draftId: value['draftId'] as String?,
    guidanceRevisionId: value['guidanceRevisionId'] as String?,
    bucketId: _requiredString(value, 'bucketId'),
    objectPath: _requiredString(value, 'objectPath'),
    mimeType: GuidanceMediaMimeType.fromWireValue(_requiredString(value, 'mimeType')),
    byteSize: _requiredInt(value, 'byteSize'),
    width: _requiredInt(value, 'width'),
    height: _requiredInt(value, 'height'),
    sha256Hex: _requiredHash(value, 'sha256Hex'),
    altText: _requiredString(value, 'altText', allowEmpty: true),
    position: _requiredInt(value, 'position'),
    isCover: _requiredBool(value, 'isCover'),
    lifecycle: switch (_requiredString(value, 'state')) {
      'pending' => GuidanceMediaLifecycle.pending,
      'ready' => GuidanceMediaLifecycle.ready,
      'publish_reserved' => GuidanceMediaLifecycle.publishReserved,
      'published' => GuidanceMediaLifecycle.published,
      'quarantined' => GuidanceMediaLifecycle.quarantined,
      _ => throw const FormatException('Unsupported media lifecycle.'),
    },
    createdAt: _requiredDate(value, 'createdAt'),
    updatedAt: _requiredDate(value, 'updatedAt'),
  );
  if (asset.bucketId != GuidanceMediaManifest.bucketId ||
      asset.byteSize < 1 ||
      asset.byteSize > 5 * 1024 * 1024 ||
      asset.width < 1 ||
      asset.height < 1 ||
      asset.position < 0 ||
      !_safeStoragePath(asset.objectPath)) {
    throw const FormatException('Media asset evidence is invalid.');
  }
  return asset;
}

GuidanceYouTubeReference _decodeYouTube(Map<String, Object?> value) {
  if (_requiredString(value, 'provider') != GuidanceYouTubeReference.provider) {
    throw const FormatException('Unsupported video provider.');
  }
  final reference = GuidanceYouTubeReference(
    videoId: _requiredString(value, 'videoId'),
    canonicalWatchUrl: _requiredHttpsUri(value, 'canonicalWatchUrl'),
    startSeconds: value['startSeconds'] as int?,
    titleSnapshot: value['titleSnapshot'] as String?,
    thumbnailUrlSnapshot: value['thumbnailUrlSnapshot'] == null
        ? null
        : _requiredHttpsUri(value, 'thumbnailUrlSnapshot'),
    validationStatus: switch (_requiredString(value, 'validationStatus')) {
      'preview_required' => YouTubeValidationStatus.previewRequired,
      'preview_succeeded' || 'validated' => YouTubeValidationStatus.validated,
      'unavailable' || 'embed_disabled' || 'player_error' => YouTubeValidationStatus.unavailable,
      _ => throw const FormatException('Unsupported YouTube validation status.'),
    },
    validatedAt: _optionalDate(value['validatedAt']),
  );
  final normalized = const YouTubeReferenceNormalizer().parse(
    reference.canonicalWatchUrl.toString(),
  );
  if (normalized.videoId != reference.videoId ||
      (reference.startSeconds != null &&
          (reference.startSeconds! < 0 ||
              reference.startSeconds! > YouTubeReferenceNormalizer.maximumStartSeconds)) ||
      (reference.validationStatus == YouTubeValidationStatus.validated) !=
          (reference.validatedAt != null)) {
    throw const FormatException('YouTube reference is inconsistent.');
  }
  return reference;
}

({bool replayed, String correlationId}) _mutationEvidence(
  Map<String, Object?> envelope,
  String operation,
) {
  _requireOperation(envelope, operation);
  return (
    replayed: _requiredBool(envelope, 'replayed'),
    correlationId: _requiredString(envelope, 'correlationId'),
  );
}

void _requireOperation(Map<String, Object?> values, String operation) =>
    _requireMatch(values, 'operation', operation);

void _requireMatch(Map<String, Object?> values, String key, String expected) {
  if (_requiredString(values, key) != expected) {
    throw FormatException('Expected matching $key.');
  }
}

bool _isPendingPath(MediaUploadIntent intent) =>
    intent.objectPath.startsWith(
      '${intent.ownerId}/${intent.exerciseId}/drafts/${intent.draftId}/${intent.assetId}.',
    ) &&
    intent.objectPath.endsWith('.${intent.mimeType.fileExtension}') &&
    _safeStoragePath(intent.objectPath);

bool _safeStoragePath(String path) =>
    path.isNotEmpty &&
    !path.startsWith('/') &&
    !path.endsWith('/') &&
    !path.contains('..') &&
    !path.contains('\\') &&
    path.split('/').every((segment) => segment.isNotEmpty);

Map<String, Object?> _map(Object? value) {
  if (value is! Map<String, Object?>) {
    throw const FormatException('Expected an object value.');
  }
  return value;
}

List<Object?> _requiredList(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is! List<Object?>) {
    throw FormatException('Expected a list for $key.');
  }
  return value;
}

String _requiredString(
  Map<String, Object?> values,
  String key, {
  bool allowEmpty = false,
}) {
  final value = values[key];
  if (value is! String || (!allowEmpty && value.isEmpty)) {
    throw FormatException('Expected a string for $key.');
  }
  return value;
}

int _requiredInt(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is! int) {
    throw FormatException('Expected an integer for $key.');
  }
  return value;
}

bool _requiredBool(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is! bool) {
    throw FormatException('Expected a boolean for $key.');
  }
  return value;
}

String _requiredHash(Map<String, Object?> values, String key) {
  final value = _requiredString(values, key);
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(value)) {
    throw FormatException('Expected a SHA-256 hash for $key.');
  }
  return value;
}

String? _optionalHash(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is! String || !RegExp(r'^[0-9a-f]{64}$').hasMatch(value)) {
    throw const FormatException('Expected an optional SHA-256 hash.');
  }
  return value;
}

DateTime _requiredDate(Map<String, Object?> values, String key) {
  final value = _optionalDate(values[key]);
  if (value == null) {
    throw FormatException('Expected a timestamp for $key.');
  }
  return value;
}

DateTime? _optionalDate(Object? value) => value is String ? DateTime.parse(value).toUtc() : null;

Uri _requiredHttpsUri(Map<String, Object?> values, String key) {
  final uri = Uri.tryParse(_requiredString(values, key));
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty || uri.userInfo.isNotEmpty) {
    throw FormatException('Expected a safe HTTPS URI for $key.');
  }
  return uri;
}
