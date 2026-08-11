import 'dart:typed_data';

import 'package:stone_set_domain/exercise_media.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ExerciseMediaRemoteService {
  Future<Map<String, Object?>> fetchDraftManifest(String exerciseId, String draftId);

  Future<Map<String, Object?>> fetchRevisionManifest(
    String exerciseId,
    String guidanceRevisionId,
  );

  Future<Map<String, Object?>> createUploadIntent(CreateMediaUploadIntentCommand command);

  Future<Map<String, Object?>> finalizeUpload(FinalizeMediaUploadCommand command);

  Future<Map<String, Object?>> saveLayout(SaveMediaLayoutCommand command);

  Future<Map<String, Object?>> removeAsset(RemoveMediaAssetCommand command);

  Future<Map<String, Object?>> saveYouTubeReference(SaveYouTubeReferenceCommand command);

  Future<Map<String, Object?>> removeYouTubeReference(RemoveYouTubeReferenceCommand command);

  Future<Map<String, Object?>> beginPublication(BeginMediaPublicationCommand command);

  Future<Map<String, Object?>> finalizePublication(FinalizeMediaPublicationCommand command);

  Future<Map<String, Object?>> duplicateRevisionWithMediaAsDraft(
    DuplicateGuidanceRevisionWithMediaCommand command,
  );

  Future<Map<String, Object?>> createGuidanceMediaDraftFromRevision(
    CreateGuidanceMediaDraftFromRevisionCommand command,
  );
}

abstract interface class ExerciseMediaStorageService {
  Future<void> upload(MediaUploadIntent intent, List<int> bytes);

  Future<void> copy(MediaPublicationCopy copy);

  Future<Uri> createSignedUrl(GuidanceImageAsset asset, Duration lifetime);
}

final class SupabaseExerciseMediaRemoteService implements ExerciseMediaRemoteService {
  const SupabaseExerciseMediaRemoteService(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, Object?>> fetchDraftManifest(String exerciseId, String draftId) => _rpc(
    'get_guidance_draft_media_manifest_v1',
    <String, Object?>{'p_exercise_id': exerciseId, 'p_draft_id': draftId},
  );

  @override
  Future<Map<String, Object?>> fetchRevisionManifest(
    String exerciseId,
    String guidanceRevisionId,
  ) => _rpc(
    'get_guidance_revision_media_manifest_v1',
    <String, Object?>{
      'p_exercise_id': exerciseId,
      'p_guidance_revision_id': guidanceRevisionId,
    },
  );

  @override
  Future<Map<String, Object?>> createUploadIntent(CreateMediaUploadIntentCommand command) => _rpc(
    'create_guidance_media_upload_intent_v1',
    <String, Object?>{
      'p_exercise_id': command.exerciseId,
      'p_draft_id': command.draftId,
      'p_mime_type': command.mimeType.wireValue,
      'p_file_extension': command.mimeType.fileExtension,
      'p_expected_draft_revision': command.expectedDraftRevision,
      'p_expected_media_revision': command.expectedMediaRevision,
      'p_idempotency_key': command.idempotencyKey,
    },
  );

  @override
  Future<Map<String, Object?>> finalizeUpload(FinalizeMediaUploadCommand command) => _rpc(
    'finalize_guidance_media_upload_v1',
    <String, Object?>{
      'p_intent_id': command.intentId,
      'p_byte_size': command.byteSize,
      'p_width': command.width,
      'p_height': command.height,
      'p_sha256_hex': command.sha256Hex,
      'p_expected_media_revision': command.expectedMediaRevision,
      'p_idempotency_key': command.idempotencyKey,
    },
  );

  @override
  Future<Map<String, Object?>> saveLayout(SaveMediaLayoutCommand command) => _rpc(
    'save_guidance_media_layout_v1',
    <String, Object?>{
      'p_draft_id': command.draftId,
      'p_images': command.images
          .map(
            (image) => <String, Object?>{
              'assetId': image.assetId,
              'altText': image.altText,
              'position': image.position,
              'isCover': image.isCover,
            },
          )
          .toList(growable: false),
      'p_expected_media_revision': command.expectedMediaRevision,
      'p_idempotency_key': command.idempotencyKey,
    },
  );

  @override
  Future<Map<String, Object?>> removeAsset(RemoveMediaAssetCommand command) => _rpc(
    'remove_guidance_media_asset_v1',
    <String, Object?>{
      'p_draft_id': command.draftId,
      'p_asset_id': command.assetId,
      'p_expected_media_revision': command.expectedMediaRevision,
      'p_idempotency_key': command.idempotencyKey,
    },
  );

  @override
  Future<Map<String, Object?>> saveYouTubeReference(SaveYouTubeReferenceCommand command) => _rpc(
    'save_guidance_youtube_reference_v1',
    <String, Object?>{
      'p_draft_id': command.draftId,
      'p_video_id': command.reference.videoId,
      'p_canonical_watch_url': command.reference.canonicalWatchUrl.toString(),
      'p_start_seconds': command.reference.startSeconds,
      'p_title_snapshot': command.reference.titleSnapshot,
      'p_thumbnail_url_snapshot': command.reference.thumbnailUrlSnapshot?.toString(),
      'p_preview_succeeded_at': command.reference.validatedAt?.toIso8601String(),
      'p_expected_media_revision': command.expectedMediaRevision,
      'p_idempotency_key': command.idempotencyKey,
    },
  );

  @override
  Future<Map<String, Object?>> removeYouTubeReference(
    RemoveYouTubeReferenceCommand command,
  ) => _rpc(
    'remove_guidance_youtube_reference_v1',
    <String, Object?>{
      'p_draft_id': command.draftId,
      'p_expected_media_revision': command.expectedMediaRevision,
      'p_idempotency_key': command.idempotencyKey,
    },
  );

  @override
  Future<Map<String, Object?>> beginPublication(BeginMediaPublicationCommand command) => _rpc(
    'begin_guidance_media_publication_v1',
    <String, Object?>{
      'p_exercise_id': command.exerciseId,
      'p_draft_id': command.draftId,
      'p_expected_exercise_revision': command.expectedExerciseRevision,
      'p_expected_draft_revision': command.expectedDraftRevision,
      'p_expected_media_revision': command.expectedMediaRevision,
      'p_idempotency_key': command.idempotencyKey,
    },
  );

  @override
  Future<Map<String, Object?>> finalizePublication(
    FinalizeMediaPublicationCommand command,
  ) => _rpc(
    'finalize_guidance_media_publication_v1',
    <String, Object?>{
      'p_reservation_id': command.reservationId,
      'p_idempotency_key': command.idempotencyKey,
    },
  );

  @override
  Future<Map<String, Object?>> duplicateRevisionWithMediaAsDraft(
    DuplicateGuidanceRevisionWithMediaCommand command,
  ) => _rpc(
    'duplicate_guidance_revision_with_media_as_draft_v1',
    <String, Object?>{
      'p_exercise_id': command.exerciseId,
      'p_guidance_revision_id': command.guidanceRevisionId,
      'p_expected_draft_revision': command.expectedDraftRevision,
      'p_expected_media_revision': command.expectedMediaRevision,
      'p_idempotency_key': command.idempotencyKey,
    },
  );

  @override
  Future<Map<String, Object?>> createGuidanceMediaDraftFromRevision(
    CreateGuidanceMediaDraftFromRevisionCommand command,
  ) => _rpc(
    'create_guidance_media_draft_from_revision_v1',
    <String, Object?>{
      'p_exercise_id': command.exerciseId,
      'p_guidance_revision_id': command.guidanceRevisionId,
      'p_expected_exercise_revision': command.expectedExerciseRevision,
      'p_idempotency_key': command.idempotencyKey,
    },
  );

  Future<Map<String, Object?>> _rpc(String functionName, Map<String, Object?> parameters) async =>
      _map(await _client.rpc<Object?>(functionName, params: parameters));
}

final class SupabaseExerciseMediaStorageService implements ExerciseMediaStorageService {
  const SupabaseExerciseMediaStorageService(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upload(MediaUploadIntent intent, List<int> bytes) async {
    await _client.storage
        .from(intent.bucketId)
        .uploadBinary(
          intent.objectPath,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: intent.mimeType.wireValue, upsert: false),
          retryAttempts: 0,
        );
  }

  @override
  Future<void> copy(MediaPublicationCopy copy) async {
    await _client.storage
        .from(GuidanceMediaManifest.bucketId)
        .copy(copy.sourcePath, copy.destinationPath);
  }

  @override
  Future<Uri> createSignedUrl(GuidanceImageAsset asset, Duration lifetime) async => Uri.parse(
    await _client.storage
        .from(asset.bucketId)
        .createSignedUrl(asset.objectPath, lifetime.inSeconds),
  );
}

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) {
    throw const FormatException('Expected an object response.');
  }
  return <String, Object?>{
    for (final entry in value.entries)
      if (entry.key is String) entry.key! as String: _jsonValue(entry.value),
  };
}

Object? _jsonValue(Object? value) => switch (value) {
  final Map<Object?, Object?> map => _map(map),
  final List<Object?> list => list.map(_jsonValue).toList(growable: false),
  _ => value,
};
