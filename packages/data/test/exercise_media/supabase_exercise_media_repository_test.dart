import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/exercise_media.dart';

void main() {
  final now = DateTime.parse('2026-08-08T00:00:00Z');

  test('decodes a bounded draft manifest and rejects mismatched identity', () async {
    final remote = _FakeRemote()..manifest = _manifest();
    final repository = _repository(remote, now);

    final manifest = await repository.getDraftManifest(_exerciseId, _draftId);

    expect(manifest.mediaRevision, 2);
    expect(manifest.youtube?.validationStatus, YouTubeValidationStatus.previewRequired);
    remote.manifest = <String, Object?>{..._manifest(), 'exerciseId': 'other'};
    await expectLater(
      repository.getDraftManifest(_exerciseId, _draftId),
      throwsA(_failure(ExerciseMediaErrorCode.unknown)),
    );
  });

  test('upload intent is strict and upload reports honest phases', () async {
    final remote = _FakeRemote()
      ..intentEnvelope = <String, Object?>{
        'operation': 'create_guidance_media_upload_intent_v1',
        'intentId': _intentId,
        'assetId': _assetId,
        'ownerId': _ownerId,
        'exerciseId': _exerciseId,
        'draftId': _draftId,
        'bucketId': GuidanceMediaManifest.bucketId,
        'objectPath': '$_ownerId/$_exerciseId/drafts/$_draftId/$_assetId.webp',
        'mimeType': 'image/webp',
        'maximumByteSize': 100,
        'mediaRevision': 2,
        'expiresAt': '2026-08-08T00:05:00Z',
        'replayed': false,
        'correlationId': _correlationId,
      };
    final storage = _FakeStorage();
    final repository = SupabaseExerciseMediaRepository(
      remote: remote,
      storage: storage,
      now: () => now,
    );
    final intent = await repository.createUploadIntent(_createIntentCommand());
    final phases = <MediaUploadPhase>[];

    await repository.uploadPendingBytes(
      intent,
      const [1, 2, 3],
      onProgress: (progress) => phases.add(progress.phase),
    );

    expect(storage.uploads, 1);
    expect(phases, MediaUploadPhase.values);
  });

  test('expired and cancelled upload never reaches Storage', () async {
    final storage = _FakeStorage();
    final repository = SupabaseExerciseMediaRepository(
      remote: _FakeRemote(),
      storage: storage,
      now: () => now,
    );
    final expired = _intent(expiresAt: now);

    await expectLater(
      repository.uploadPendingBytes(expired, const [1]),
      throwsA(_failure(ExerciseMediaErrorCode.uploadExpired)),
    );
    await expectLater(
      repository.uploadPendingBytes(
        _intent(expiresAt: now.add(const Duration(minutes: 1))),
        const [1],
        cancellation: const _Cancelled(),
      ),
      throwsA(_failure(ExerciseMediaErrorCode.uploadCancelled)),
    );
    expect(storage.uploads, 0);
  });

  test('exact intent upload conflict continues to authoritative finalize', () async {
    final storage = _FakeStorage()
      ..uploadError = const ExerciseMediaFailure(
        ExerciseMediaErrorCode.uploadConflict,
      );
    final repository = SupabaseExerciseMediaRepository(
      remote: _FakeRemote(),
      storage: storage,
      now: () => now,
    );
    final phases = <MediaUploadPhase>[];

    await repository.uploadPendingBytes(
      _intent(expiresAt: now.add(const Duration(minutes: 1))),
      const [1, 2, 3],
      onProgress: (progress) => phases.add(progress.phase),
    );

    expect(storage.uploads, 1);
    expect(phases, MediaUploadPhase.values);
  });

  test('draft YouTube reference can be saved before preview validation', () async {
    final remote = _FakeRemote()
      ..manifest = <String, Object?>{..._manifest(), 'mediaRevision': 3}
      ..mutationEnvelope = _mutation('save_guidance_youtube_reference_v1');
    final repository = _repository(remote, now);
    final reference = const YouTubeReferenceNormalizer().parse(
      'https://youtu.be/AbC_12-xYz9',
    );

    final result = await repository.saveYouTubeReference(
      SaveYouTubeReferenceCommand(
        exerciseId: _exerciseId,
        draftId: _draftId,
        reference: reference,
        expectedMediaRevision: 2,
        idempotencyKey: 'operation-1',
      ),
    );

    expect(result.correlationId, _correlationId);
    expect(remote.savedYouTube?.reference.isPublishable, isFalse);
  });

  test('mutation without replay evidence becomes a safe unknown failure', () async {
    final remote = _FakeRemote()
      ..manifest = _manifest()
      ..mutationEnvelope = <String, Object?>{
        'operation': 'save_guidance_media_layout_v1',
        'exerciseId': _exerciseId,
        'draftId': _draftId,
        'correlationId': _correlationId,
      };
    final repository = _repository(remote, now);

    await expectLater(
      repository.saveLayout(
        SaveMediaLayoutCommand(
          exerciseId: _exerciseId,
          draftId: _draftId,
          images: const [],
          expectedMediaRevision: 2,
          idempotencyKey: 'operation-1',
        ),
      ),
      throwsA(_failure(ExerciseMediaErrorCode.unknown)),
    );
  });

  test('signed access URLs are bounded to five minutes and HTTPS', () async {
    final storage = _FakeStorage();
    final repository = SupabaseExerciseMediaRepository(
      remote: _FakeRemote(),
      storage: storage,
      now: () => now,
    );

    final access = await repository.createImageAccessUrl(_image());
    expect(access.url.scheme, 'https');
    expect(access.expiresAt, now.add(const Duration(minutes: 5)));
    await expectLater(
      repository.createImageAccessUrl(_image(), lifetime: const Duration(minutes: 6)),
      throwsA(_failure(ExerciseMediaErrorCode.invalidInput)),
    );
  });

  test('duplicates published media metadata without client byte copies', () async {
    final remote = _FakeRemote()
      ..manifest = _manifest()
      ..mutationEnvelope = <String, Object?>{
        ..._mutation('duplicate_guidance_revision_with_media_as_draft_v1'),
        'sourceGuidanceRevisionId': _revisionId,
        'draftRevision': 5,
        'mediaRevision': 2,
        'imageCount': 0,
        'youtubeCopied': true,
        'reusedPublishedObjects': true,
      };
    final storage = _FakeStorage();
    final repository = SupabaseExerciseMediaRepository(
      remote: remote,
      storage: storage,
      now: () => now,
    );

    final result = await repository.duplicateRevisionWithMediaAsDraft(
      const DuplicateGuidanceRevisionWithMediaCommand(
        exerciseId: _exerciseId,
        guidanceRevisionId: _revisionId,
        expectedDraftRevision: 4,
        expectedMediaRevision: 1,
        idempotencyKey: 'operation-1',
      ),
    );

    expect(result.reusedPublishedObjects, isTrue);
    expect(result.imageCount, 0);
    expect(storage.copies, 0);
    expect(storage.uploads, 0);
  });

  test('creates a guidance/media draft with strict authoritative evidence', () async {
    final remote = _FakeRemote()
      ..mutationEnvelope = <String, Object?>{
        ..._mutation('create_guidance_media_draft_from_revision_v1'),
        'sourceGuidanceRevisionId': _revisionId,
        'exerciseRevision': 9,
        'draftRevision': 1,
        'mediaRevision': 1,
        'imageCount': 0,
        'youtubeCopied': false,
        'reusedPublishedObjects': true,
      };
    final repository = _repository(remote, now);
    const command = CreateGuidanceMediaDraftFromRevisionCommand(
      exerciseId: _exerciseId,
      guidanceRevisionId: _revisionId,
      expectedExerciseRevision: 9,
      idempotencyKey: 'operation-1',
    );

    final result = await repository.createGuidanceMediaDraftFromRevision(command);

    expect(remote.createdDraftCommand, same(command));
    expect(result.exerciseId, _exerciseId);
    expect(result.sourceGuidanceRevisionId, _revisionId);
    expect(result.draftId, _draftId);
    expect(result.exerciseRevision, 9);
    expect(result.draftRevision, 1);
    expect(result.mediaRevision, 1);
    expect(result.imageCount, 0);
    expect(result.youtubeCopied, isFalse);
    expect(result.reusedPublishedObjects, isTrue);
    expect(result.replayed, isFalse);
    expect(result.correlationId, _correlationId);
  });

  test('rejects malformed draft-materialization evidence', () async {
    final remote = _FakeRemote()
      ..mutationEnvelope = <String, Object?>{
        ..._mutation('create_guidance_media_draft_from_revision_v1'),
        'sourceGuidanceRevisionId': _revisionId,
        'exerciseRevision': 9,
        'draftRevision': 1,
        'mediaRevision': 1,
        'imageCount': 7,
        'youtubeCopied': false,
        'reusedPublishedObjects': true,
      };
    final repository = _repository(remote, now);

    await expectLater(
      repository.createGuidanceMediaDraftFromRevision(
        const CreateGuidanceMediaDraftFromRevisionCommand(
          exerciseId: _exerciseId,
          guidanceRevisionId: _revisionId,
          expectedExerciseRevision: 9,
          idempotencyKey: 'operation-1',
        ),
      ),
      throwsA(_failure(ExerciseMediaErrorCode.unknown)),
    );
  });
}

SupabaseExerciseMediaRepository _repository(_FakeRemote remote, DateTime now) =>
    SupabaseExerciseMediaRepository(remote: remote, storage: _FakeStorage(), now: () => now);

Matcher _failure(ExerciseMediaErrorCode code) => isA<ExerciseMediaFailure>().having(
  (failure) => failure.code,
  'code',
  code,
);

CreateMediaUploadIntentCommand _createIntentCommand() => const CreateMediaUploadIntentCommand(
  exerciseId: _exerciseId,
  draftId: _draftId,
  mimeType: GuidanceMediaMimeType.webp,
  expectedDraftRevision: 1,
  expectedMediaRevision: 2,
  idempotencyKey: 'operation-1',
);

MediaUploadIntent _intent({required DateTime expiresAt}) => MediaUploadIntent(
  intentId: _intentId,
  assetId: _assetId,
  ownerId: _ownerId,
  exerciseId: _exerciseId,
  draftId: _draftId,
  bucketId: GuidanceMediaManifest.bucketId,
  objectPath: '$_ownerId/$_exerciseId/drafts/$_draftId/$_assetId.webp',
  mimeType: GuidanceMediaMimeType.webp,
  maximumByteSize: 100,
  mediaRevision: 2,
  expiresAt: expiresAt,
  replayed: false,
  correlationId: _correlationId,
);

Map<String, Object?> _manifest() => <String, Object?>{
  'schemaVersion': 1,
  'exerciseId': _exerciseId,
  'ownerId': _ownerId,
  'draftId': _draftId,
  'guidanceRevisionId': null,
  'guidanceRevisionHash': null,
  'mediaRevision': 2,
  'images': <Object?>[],
  'youtube': <String, Object?>{
    'provider': 'youtube',
    'videoId': 'AbC_12-xYz9',
    'canonicalWatchUrl': 'https://www.youtube.com/watch?v=AbC_12-xYz9',
    'startSeconds': null,
    'titleSnapshot': null,
    'thumbnailUrlSnapshot': null,
    'validationStatus': 'preview_required',
    'validatedAt': null,
  },
  'manifestHash': null,
  'bundleHash': null,
};

Map<String, Object?> _mutation(String operation) => <String, Object?>{
  'operation': operation,
  'exerciseId': _exerciseId,
  'draftId': _draftId,
  'mediaRevision': 3,
  'replayed': false,
  'correlationId': _correlationId,
};

GuidanceImageAsset _image() => GuidanceImageAsset(
  id: _assetId,
  ownerId: _ownerId,
  exerciseId: _exerciseId,
  draftId: _draftId,
  bucketId: GuidanceMediaManifest.bucketId,
  objectPath: '$_ownerId/$_exerciseId/drafts/$_draftId/$_assetId.webp',
  mimeType: GuidanceMediaMimeType.webp,
  byteSize: 3,
  width: 640,
  height: 480,
  sha256Hex: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  altText: 'Safe alt text',
  position: 0,
  isCover: true,
  lifecycle: GuidanceMediaLifecycle.ready,
  createdAt: DateTime.parse('2026-08-08T00:00:00Z'),
  updatedAt: DateTime.parse('2026-08-08T00:00:00Z'),
);

final class _FakeRemote implements ExerciseMediaRemoteService {
  Map<String, Object?> manifest = _manifest();
  Map<String, Object?> intentEnvelope = const <String, Object?>{};
  Map<String, Object?> mutationEnvelope = const <String, Object?>{};
  SaveYouTubeReferenceCommand? savedYouTube;
  CreateGuidanceMediaDraftFromRevisionCommand? createdDraftCommand;

  @override
  Future<Map<String, Object?>> fetchDraftManifest(String exerciseId, String draftId) async =>
      manifest;

  @override
  Future<Map<String, Object?>> fetchRevisionManifest(
    String exerciseId,
    String guidanceRevisionId,
  ) async => manifest;

  @override
  Future<Map<String, Object?>> createUploadIntent(CreateMediaUploadIntentCommand command) async =>
      intentEnvelope;

  @override
  Future<Map<String, Object?>> finalizeUpload(FinalizeMediaUploadCommand command) async =>
      mutationEnvelope;

  @override
  Future<Map<String, Object?>> saveLayout(SaveMediaLayoutCommand command) async => mutationEnvelope;

  @override
  Future<Map<String, Object?>> removeAsset(RemoveMediaAssetCommand command) async =>
      mutationEnvelope;

  @override
  Future<Map<String, Object?>> saveYouTubeReference(SaveYouTubeReferenceCommand command) async {
    savedYouTube = command;
    return mutationEnvelope;
  }

  @override
  Future<Map<String, Object?>> removeYouTubeReference(
    RemoveYouTubeReferenceCommand command,
  ) async => mutationEnvelope;

  @override
  Future<Map<String, Object?>> beginPublication(BeginMediaPublicationCommand command) async =>
      mutationEnvelope;

  @override
  Future<Map<String, Object?>> finalizePublication(
    FinalizeMediaPublicationCommand command,
  ) async => mutationEnvelope;

  @override
  Future<Map<String, Object?>> duplicateRevisionWithMediaAsDraft(
    DuplicateGuidanceRevisionWithMediaCommand command,
  ) async => mutationEnvelope;

  @override
  Future<Map<String, Object?>> createGuidanceMediaDraftFromRevision(
    CreateGuidanceMediaDraftFromRevisionCommand command,
  ) async {
    createdDraftCommand = command;
    return mutationEnvelope;
  }
}

final class _FakeStorage implements ExerciseMediaStorageService {
  int uploads = 0;
  int copies = 0;
  Object? uploadError;

  @override
  Future<void> upload(MediaUploadIntent intent, List<int> bytes) async {
    uploads += 1;
    final error = uploadError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> copy(MediaPublicationCopy copy) async {
    copies += 1;
  }

  @override
  Future<Uri> createSignedUrl(GuidanceImageAsset asset, Duration lifetime) async =>
      Uri.parse('https://storage.example.test/signed-object');
}

final class _Cancelled implements MediaUploadCancellation {
  const _Cancelled();

  @override
  bool get isCancelled => true;
}

const _exerciseId = '11111111-1111-4111-8111-111111111111';
const _draftId = '22222222-2222-4222-8222-222222222222';
const _ownerId = '33333333-3333-4333-8333-333333333333';
const _assetId = '44444444-4444-4444-8444-444444444444';
const _intentId = '55555555-5555-4555-8555-555555555555';
const _correlationId = '66666666-6666-4666-8666-666666666666';
const _revisionId = '77777777-7777-4777-8777-777777777777';
