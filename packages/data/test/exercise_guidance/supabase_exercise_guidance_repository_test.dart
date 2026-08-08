import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/exercise_guidance.dart';

void main() {
  test('decodes a bounded server page and preserves exact count', () async {
    final remote = _FakeRemote()
      ..exercisePage = <String, Object?>{
        'items': <Object?>[_summaryFixture()],
        'total': 42,
        'page': 2,
        'pageSize': 10,
      };
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);
    final query = ExerciseLibraryQuery(
      search: 'press',
      equipmentKeys: const <String>['bench', 'dumbbell'],
      muscleKeys: const <String>['chest'],
      page: 2,
      pageSize: 10,
    );

    final page = await repository.listExercises(query);

    expect(remote.lastQuery, same(query));
    expect(page.totalCount, 42);
    expect(page.items.single.canonicalName, 'Incline press');
    expect(page.items.single.primaryMuscleIds, <String>[_muscleId]);
  });

  test('decodes a full exercise detail with ordered nested relations', () async {
    final remote = _FakeRemote()..exercise = _exerciseFixture();
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);

    final exercise = await repository.getExercise(_exerciseId);

    expect(exercise.equipmentKeys, <String>['bench', 'dumbbell']);
    expect(exercise.primaryMuscles.single.muscle.key, 'chest');
    expect(exercise.currentDraft?.content.shortExplanation, 'Controlled press.');
  });

  test(
    'mutation requires replay and correlation evidence and fetches authoritative detail',
    () async {
      final remote = _FakeRemote()
        ..exercise = _exerciseFixture()
        ..mutationEnvelope = <String, Object?>{
          'operation': 'create_exercise_v1',
          'exerciseId': _exerciseId,
          'replayed': true,
          'correlationId': _correlationId,
        };
      final repository = SupabaseExerciseGuidanceRepository(remote: remote);

      final result = await repository.createOrUpdateExercise(_createCommand());

      expect(result.replayed, isTrue);
      expect(result.correlationId, _correlationId);
      expect(remote.fetchExerciseCalls, 1);
    },
  );

  test('malformed mutation envelope becomes a safe unknown failure', () async {
    final remote = _FakeRemote()
      ..exercise = _exerciseFixture()
      ..mutationEnvelope = <String, Object?>{
        'operation': 'create_exercise_v1',
        'exerciseId': _exerciseId,
      };
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);

    await expectLater(
      repository.createOrUpdateExercise(_createCommand()),
      throwsA(
        isA<ExerciseGuidanceFailure>().having(
          (failure) => failure.code,
          'code',
          ExerciseGuidanceErrorCode.unknown,
        ),
      ),
    );
  });

  test('update uses the update operation envelope and preserves expected revision', () async {
    final remote = _FakeRemote()
      ..exercise = _exerciseFixture()
      ..mutationEnvelope = <String, Object?>{
        ..._exerciseMutationEnvelope('update_exercise_v1'),
      };
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);
    final command = CreateOrUpdateExerciseCommand(
      exerciseId: _exerciseId,
      canonicalName: 'Incline press',
      variantKey: null,
      equipmentKeys: const <String>['bench', 'dumbbell'],
      primaryMuscleKeys: const <String>['chest'],
      secondaryMuscleKeys: const <String>[],
      expectedRevision: 2,
      idempotencyKey: _operationId,
    );

    await repository.createOrUpdateExercise(command);

    expect(remote.lastCreateOrUpdateCommand, same(command));
    expect(remote.lastCreateOrUpdateCommand?.expectedRevision, 2);
  });

  test('revision history uses the remote page and exact count', () async {
    final remote = _FakeRemote()
      ..revisionPage = ExerciseGuidanceRemotePage(
        items: <Map<String, Object?>>[_revisionFixture()],
        totalCount: 9,
      );
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);

    final page = await repository.listGuidanceRevisions(_exerciseId, page: 2, pageSize: 3);

    expect(remote.lastRevisionPage, 2);
    expect(remote.lastRevisionPageSize, 3);
    expect(page.totalCount, 9);
    expect(page.items.single.versionNumber, 3);
  });

  test('duplicate revision binds the command and refetches the authoritative draft', () async {
    final remote = _FakeRemote()
      ..draft = _draftFixture()
      ..mutationEnvelope = <String, Object?>{
        'operation': 'duplicate_guidance_revision_as_draft_v1',
        'exerciseId': _exerciseId,
        'sourceGuidanceRevisionId': _revisionId,
        'replayed': false,
        'correlationId': _correlationId,
      };
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);
    const command = DuplicateGuidanceRevisionAsDraftCommand(
      exerciseId: _exerciseId,
      revisionId: _revisionId,
      expectedDraftRevision: 4,
      idempotencyKey: _operationId,
    );

    final result = await repository.duplicateGuidanceRevisionAsDraft(command);

    expect(remote.lastDuplicateCommand, same(command));
    expect(result.draft.id, _draftId);
    expect(result.replayed, isFalse);
  });

  test('maps the fixed muscle taxonomy response without client authority', () async {
    final remote = _FakeRemote()
      ..muscles = <Map<String, Object?>>[
        <String, Object?>{
          'id': _muscleId,
          'stable_key': 'chest',
          'display_name': 'Chest',
          'display_order': 1,
        },
      ];

    final muscles = await SupabaseExerciseGuidanceRepository(
      remote: remote,
    ).listMuscles();

    expect(muscles.single.key, 'chest');
    expect(muscles.single.displayOrder, 1);
  });

  test('the Supabase adapter is usable through the pure-Dart read-only contract', () async {
    final remote = _FakeRemote()
      ..exercise = _exerciseFixture()
      ..revision = _revisionFixture();
    final ExerciseGuidanceReadRepository repository = SupabaseExerciseGuidanceRepository(
      remote: remote,
    );

    final exercise = await repository.getExercise(_exerciseId);
    final revision = await repository.getGuidanceRevision(_exerciseId, _revisionId);

    expect(exercise.id, _exerciseId);
    expect(revision.id, _revisionId);
  });

  test('archive and unarchive bind intent and require matching durable evidence', () async {
    final remote = _FakeRemote()
      ..exercise = _exerciseFixture()
      ..mutationEnvelope = _exerciseMutationEnvelope('set_exercise_archived_v1');
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);
    const command = ArchiveExerciseCommand(
      exerciseId: _exerciseId,
      expectedRevision: 2,
      idempotencyKey: _operationId,
    );

    await repository.archiveExercise(command);
    expect(remote.lastArchiveCommand, same(command));
    expect(remote.lastArchivedValue, isTrue);

    await repository.unarchiveExercise(command);
    expect(remote.lastArchivedValue, isFalse);
  });

  test('clone binds source and fetches only the returned owned exercise', () async {
    final remote = _FakeRemote()
      ..exercise = _exerciseFixture()
      ..mutationEnvelope = <String, Object?>{
        ..._exerciseMutationEnvelope('clone_exercise_v1'),
        'sourceExerciseId': _sourceExerciseId,
      };
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);
    const command = CloneExerciseCommand(
      sourceExerciseId: _sourceExerciseId,
      canonicalName: 'Incline press copy',
      duplicateConfirmed: true,
      idempotencyKey: _operationId,
    );

    await repository.cloneExercise(command);

    expect(remote.lastCloneCommand, same(command));
    expect(remote.lastFetchedExerciseId, _exerciseId);
  });

  test('save draft requires matching draft and replay evidence', () async {
    final remote = _FakeRemote()
      ..draft = _draftFixture()
      ..mutationEnvelope = <String, Object?>{
        ..._mutationEvidence('save_guidance_draft_v1'),
        'draftId': _draftId,
      };
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);
    final command = SaveGuidanceDraftCommand(
      exerciseId: _exerciseId,
      draftId: _draftId,
      content: _content(),
      expectedRevision: 4,
      idempotencyKey: _operationId,
    );

    final result = await repository.saveGuidanceDraft(command);

    expect(remote.lastSaveCommand, same(command));
    expect(result.correlationId, _correlationId);
    expect(result.draft.revision, 4);
  });

  test('validation binds revisions and maps only structured safe issue codes', () async {
    final remote = _FakeRemote()
      ..validationEnvelope = <String, Object?>{
        'issues': <Object?>[
          <String, Object?>{'code': 'exercise_archived', 'path': 'exercise'},
          <String, Object?>{'code': 'short_explanation_required', 'path': 'shortExplanation'},
        ],
      };
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);
    const command = ValidateGuidanceDraftCommand(
      exerciseId: _exerciseId,
      draftId: _draftId,
      expectedExerciseRevision: 2,
      expectedDraftRevision: 4,
    );

    final result = await repository.validateGuidanceDraft(command);

    expect(remote.lastValidateCommand, same(command));
    expect(result.issues.first.code, ExerciseGuidanceValidationCode.exerciseArchived);
    expect(result.issues.last.code, ExerciseGuidanceValidationCode.invalidStructuredContent);
    expect(result.issues.last.message, 'short_explanation_required');
  });

  test('publish binds expected revisions and decodes the authoritative revision', () async {
    final remote = _FakeRemote()
      ..revision = _revisionFixture()
      ..mutationEnvelope = <String, Object?>{
        ..._mutationEvidence('publish_guidance_revision_v1'),
        'exerciseId': _exerciseId,
        'guidanceRevisionId': _revisionId,
        'noChange': true,
      };
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);
    const command = PublishGuidanceCommand(
      exerciseId: _exerciseId,
      draftId: _draftId,
      expectedExerciseRevision: 2,
      expectedDraftRevision: 4,
      idempotencyKey: _operationId,
    );

    final result = await repository.publishGuidance(command);

    expect(remote.lastPublishCommand, same(command));
    expect(remote.lastFetchedRevisionId, _revisionId);
    expect(result.noChange, isTrue);
    expect(result.revision.versionNumber, 3);
  });

  test('revision detail rejects a revision from another exercise', () async {
    final remote = _FakeRemote()..revision = _revisionFixture();
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);

    await expectLater(
      repository.getGuidanceRevision(_sourceExerciseId, _revisionId),
      throwsA(
        isA<ExerciseGuidanceFailure>().having(
          (failure) => failure.code,
          'code',
          ExerciseGuidanceErrorCode.notFound,
        ),
      ),
    );
  });

  test('revision pagination rejects unbounded requests before remote access', () {
    final remote = _FakeRemote();
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);

    expect(
      () => repository.listGuidanceRevisions(_exerciseId, pageSize: 101),
      throwsArgumentError,
    );
    expect(remote.revisionPageCalls, 0);
  });

  test('unsupported schema and muscle role become safe unknown failures', () async {
    final invalidSchema = _exerciseFixture();
    final draft = Map<String, Object?>.of(
      (invalidSchema['current_draft']! as List<Object?>).single! as Map<String, Object?>,
    )..['structured_content_schema_version'] = 2;
    invalidSchema['current_draft'] = <Object?>[draft];
    final remote = _FakeRemote()..exercise = invalidSchema;
    final repository = SupabaseExerciseGuidanceRepository(remote: remote);

    await expectLater(
      repository.getExercise(_exerciseId),
      throwsA(
        isA<ExerciseGuidanceFailure>().having(
          (failure) => failure.code,
          'code',
          ExerciseGuidanceErrorCode.unknown,
        ),
      ),
    );

    final invalidRole = _revisionFixture();
    invalidRole['muscles'] = <Object?>[
      <String, Object?>{
        'role': 'owner',
        'position': 1,
        'muscle_id': _muscleId,
        'muscle_key_snapshot': 'chest',
      },
    ];
    remote.revision = invalidRole;
    await expectLater(
      repository.getGuidanceRevision(_exerciseId, _revisionId),
      throwsA(isA<ExerciseGuidanceFailure>()),
    );
  });
}

const _exerciseId = '10000000-0000-4000-8000-000000000001';
const _userId = '20000000-0000-4000-8000-000000000001';
const _muscleId = 'a3000000-0000-4000-8000-000000000001';
const _draftId = '30000000-0000-4000-8000-000000000001';
const _revisionId = '40000000-0000-4000-8000-000000000001';
const _operationId = '50000000-0000-4000-8000-000000000001';
const _correlationId = '60000000-0000-4000-8000-000000000001';
const _sourceExerciseId = '70000000-0000-4000-8000-000000000001';

Map<String, Object?> _mutationEvidence(String operation) => <String, Object?>{
  'operation': operation,
  'replayed': false,
  'correlationId': _correlationId,
};

Map<String, Object?> _exerciseMutationEnvelope(String operation) => <String, Object?>{
  ..._mutationEvidence(operation),
  'exerciseId': _exerciseId,
};

GuidanceContentV1 _content() => GuidanceContentV1(
  shortExplanation: 'Controlled press.',
  setupSteps: const <String>['Set the bench.'],
  executionSteps: const <String>['Press.'],
);

CreateOrUpdateExerciseCommand _createCommand() => CreateOrUpdateExerciseCommand(
  canonicalName: 'Incline press',
  variantKey: null,
  equipmentKeys: const <String>['bench', 'dumbbell'],
  primaryMuscleKeys: const <String>['chest'],
  secondaryMuscleKeys: const <String>[],
  idempotencyKey: _operationId,
);

Map<String, Object?> _summaryFixture() => <String, Object?>{
  'id': _exerciseId,
  'userId': _userId,
  'canonicalName': 'Incline press',
  'normalizedName': 'incline press',
  'variantKey': null,
  'archivedAt': null,
  'clonedFromExerciseId': null,
  'revision': 2,
  'createdAt': '2026-08-07T00:00:00Z',
  'updatedAt': '2026-08-07T01:00:00Z',
  'equipmentKeys': <Object?>['bench', 'dumbbell'],
  'primaryMuscleIds': <Object?>[_muscleId],
  'secondaryMuscleIds': <Object?>[],
  'published': true,
  'draftId': _draftId,
  'draftRevision': 4,
  'latestGuidanceRevisionId': _revisionId,
  'latestGuidanceVersion': 3,
};

Map<String, Object?> _exerciseFixture() => <String, Object?>{
  'id': _exerciseId,
  'user_id': _userId,
  'canonical_name': 'Incline press',
  'normalized_name': 'incline press',
  'variant_key': null,
  'archived_at': null,
  'cloned_from_exercise_id': null,
  'revision': 2,
  'created_at': '2026-08-07T00:00:00Z',
  'updated_at': '2026-08-07T01:00:00Z',
  'equipment': <Object?>[
    <String, Object?>{'equipment_key': 'dumbbell', 'position': 2},
    <String, Object?>{'equipment_key': 'bench', 'position': 1},
  ],
  'muscles': <Object?>[
    <String, Object?>{
      'role': 'primary',
      'position': 1,
      'muscle': <String, Object?>{
        'id': _muscleId,
        'stable_key': 'chest',
        'display_name': 'Chest',
        'display_order': 1,
      },
    },
  ],
  'current_draft': <Object?>[_draftFixture()],
  'guidance_revisions': <Object?>[
    <String, Object?>{'id': _revisionId, 'version_number': 3},
  ],
};

Map<String, Object?> _draftFixture() => <String, Object?>{
  'id': _draftId,
  'exercise_id': _exerciseId,
  'user_id': _userId,
  'base_guidance_revision_id': _revisionId,
  'structured_content_schema_version': 1,
  'structured_content': _contentFixture(),
  'revision': 4,
  'created_at': '2026-08-07T00:00:00Z',
  'updated_at': '2026-08-07T01:00:00Z',
};

Map<String, Object?> _revisionFixture() => <String, Object?>{
  'id': _revisionId,
  'exercise_id': _exerciseId,
  'user_id': _userId,
  'version_number': 3,
  'structured_content_schema_version': 1,
  'structured_content': _contentFixture(),
  'canonical_name_snapshot': 'Incline press',
  'variant_key_snapshot': null,
  'equipment_keys_snapshot': <Object?>['bench', 'dumbbell'],
  'content_hash': List<String>.filled(64, 'a').join(),
  'revision_hash': List<String>.filled(64, 'b').join(),
  'supersedes_revision_id': null,
  'published_at': '2026-08-07T01:00:00Z',
  'muscles': <Object?>[],
};

Map<String, Object?> _contentFixture() => <String, Object?>{
  'shortExplanation': 'Controlled press.',
  'setupSteps': <Object?>['Set the bench.'],
  'executionSteps': <Object?>['Press.'],
  'techniqueCues': <Object?>[],
  'commonMistakes': <Object?>[],
  'safetyNotes': <Object?>[],
};

final class _FakeRemote implements ExerciseGuidanceRemoteService {
  List<Map<String, Object?>> muscles = <Map<String, Object?>>[];
  Map<String, Object?> exercisePage = <String, Object?>{};
  Map<String, Object?> exercise = <String, Object?>{};
  Map<String, Object?> draft = <String, Object?>{};
  Map<String, Object?> revision = <String, Object?>{};
  Map<String, Object?> validationEnvelope = <String, Object?>{'issues': <Object?>[]};
  Map<String, Object?> mutationEnvelope = <String, Object?>{};
  ExerciseGuidanceRemotePage revisionPage = const ExerciseGuidanceRemotePage(
    items: <Map<String, Object?>>[],
    totalCount: 0,
  );
  ExerciseLibraryQuery? lastQuery;
  CreateOrUpdateExerciseCommand? lastCreateOrUpdateCommand;
  DuplicateGuidanceRevisionAsDraftCommand? lastDuplicateCommand;
  ArchiveExerciseCommand? lastArchiveCommand;
  bool? lastArchivedValue;
  CloneExerciseCommand? lastCloneCommand;
  SaveGuidanceDraftCommand? lastSaveCommand;
  ValidateGuidanceDraftCommand? lastValidateCommand;
  PublishGuidanceCommand? lastPublishCommand;
  String? lastFetchedExerciseId;
  String? lastFetchedRevisionId;
  int? lastRevisionPage;
  int? lastRevisionPageSize;
  int revisionPageCalls = 0;
  int fetchExerciseCalls = 0;

  @override
  Future<List<Map<String, Object?>>> fetchMuscles() async => muscles;

  @override
  Future<Map<String, Object?>> fetchExercisePage(ExerciseLibraryQuery query) async {
    lastQuery = query;
    return exercisePage;
  }

  @override
  Future<Map<String, Object?>> fetchExercise(String exerciseId) async {
    fetchExerciseCalls += 1;
    lastFetchedExerciseId = exerciseId;
    return exercise;
  }

  @override
  Future<ExerciseGuidanceRemotePage> fetchGuidanceRevisionPage(
    String exerciseId, {
    required int page,
    required int pageSize,
  }) async {
    revisionPageCalls += 1;
    lastRevisionPage = page;
    lastRevisionPageSize = pageSize;
    return revisionPage;
  }

  @override
  Future<Map<String, Object?>> createOrUpdateExercise(
    CreateOrUpdateExerciseCommand command,
  ) async {
    lastCreateOrUpdateCommand = command;
    return mutationEnvelope;
  }

  @override
  Future<Map<String, Object?>> setExerciseArchived(
    ArchiveExerciseCommand command,
    bool archived,
  ) async {
    lastArchiveCommand = command;
    lastArchivedValue = archived;
    return mutationEnvelope;
  }

  @override
  Future<Map<String, Object?>> cloneExercise(CloneExerciseCommand command) async {
    lastCloneCommand = command;
    return mutationEnvelope;
  }

  @override
  Future<Map<String, Object?>> saveGuidanceDraft(SaveGuidanceDraftCommand command) async {
    lastSaveCommand = command;
    return mutationEnvelope;
  }

  @override
  Future<Map<String, Object?>> validateGuidanceDraft(
    ValidateGuidanceDraftCommand command,
  ) async {
    lastValidateCommand = command;
    return validationEnvelope;
  }

  @override
  Future<Map<String, Object?>> publishGuidance(PublishGuidanceCommand command) async {
    lastPublishCommand = command;
    return mutationEnvelope;
  }

  @override
  Future<Map<String, Object?>> fetchGuidanceRevision(String revisionId) async {
    lastFetchedRevisionId = revisionId;
    return revision;
  }

  @override
  Future<Map<String, Object?>> duplicateGuidanceRevisionAsDraft(
    DuplicateGuidanceRevisionAsDraftCommand command,
  ) async {
    lastDuplicateCommand = command;
    return mutationEnvelope;
  }

  @override
  Future<Map<String, Object?>> fetchGuidanceDraft(String exerciseId) async => draft;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
