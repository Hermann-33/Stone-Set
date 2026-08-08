import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ExerciseGuidanceRemoteService {
  Future<List<Map<String, Object?>>> fetchMuscles();

  Future<Map<String, Object?>> fetchExercisePage(ExerciseLibraryQuery query);

  Future<Map<String, Object?>> fetchExercise(String exerciseId);

  Future<Map<String, Object?>> fetchGuidanceDraft(String exerciseId);

  Future<ExerciseGuidanceRemotePage> fetchGuidanceRevisionPage(
    String exerciseId, {
    required int page,
    required int pageSize,
  });

  Future<Map<String, Object?>> fetchGuidanceRevision(String revisionId);

  Future<Map<String, Object?>> createOrUpdateExercise(CreateOrUpdateExerciseCommand command);

  Future<Map<String, Object?>> setExerciseArchived(ArchiveExerciseCommand command, bool archived);

  Future<Map<String, Object?>> cloneExercise(CloneExerciseCommand command);

  Future<Map<String, Object?>> saveGuidanceDraft(SaveGuidanceDraftCommand command);

  Future<Map<String, Object?>> validateGuidanceDraft(ValidateGuidanceDraftCommand command);

  Future<Map<String, Object?>> publishGuidance(PublishGuidanceCommand command);

  Future<Map<String, Object?>> duplicateGuidanceRevisionAsDraft(
    DuplicateGuidanceRevisionAsDraftCommand command,
  );
}

final class ExerciseGuidanceRemotePage {
  const ExerciseGuidanceRemotePage({required this.items, required this.totalCount});

  final List<Map<String, Object?>> items;
  final int totalCount;
}

final class SupabaseExerciseGuidanceRemoteService implements ExerciseGuidanceRemoteService {
  const SupabaseExerciseGuidanceRemoteService(this._client);

  static const _exerciseSelect = '''
    id,user_id,canonical_name,normalized_name,variant_key,archived_at,
    cloned_from_exercise_id,revision,created_at,updated_at,
    equipment:exercise_definition_equipment(equipment_key,position),
    muscles:exercise_definition_muscles(role,position,muscle:muscles(id,stable_key,display_name,display_order)),
    current_draft:guidance_drafts(id,exercise_id,user_id,base_guidance_revision_id,
      structured_content_schema_version,structured_content,revision,created_at,updated_at),
    guidance_revisions(id,version_number)
  ''';

  static const _revisionSelect = '''
    id,exercise_id,user_id,version_number,structured_content_schema_version,structured_content,
    canonical_name_snapshot,variant_key_snapshot,equipment_keys_snapshot,content_hash,revision_hash,
    supersedes_revision_id,published_at,
    muscles:guidance_revision_muscles(role,position,muscle_id,muscle_key_snapshot,
      muscle:muscles(id,stable_key,display_name,display_order))
  ''';

  static const _draftSelect = '''
    id,exercise_id,user_id,base_guidance_revision_id,structured_content_schema_version,
    structured_content,revision,created_at,updated_at
  ''';

  final SupabaseClient _client;

  @override
  Future<List<Map<String, Object?>>> fetchMuscles() async => _mapList(
    await _client
        .from('muscles')
        .select('id,stable_key,display_name,display_order')
        .order('display_order'),
  );

  @override
  Future<Map<String, Object?>> fetchExercisePage(ExerciseLibraryQuery query) async => _map(
    await _client.rpc<Object?>(
      'list_exercises_v1',
      params: <String, Object?>{
        'p_search': query.search,
        'p_archive_filter': switch (query.archive) {
          ExerciseArchiveFilter.active => 'active',
          ExerciseArchiveFilter.archived => 'archived',
          ExerciseArchiveFilter.all => 'all',
        },
        'p_publication_filter': switch (query.publication) {
          ExercisePublicationFilter.all => 'all',
          ExercisePublicationFilter.draftOnly => 'unpublished',
          ExercisePublicationFilter.published => 'published',
        },
        'p_equipment_keys': query.equipmentKeys,
        'p_muscle_keys': query.muscleKeys,
        'p_sort': switch (query.sort) {
          ExerciseLibrarySort.updatedDescending => 'updated_desc',
          ExerciseLibrarySort.nameAscending => 'name_asc',
          ExerciseLibrarySort.nameDescending => 'name_desc',
          ExerciseLibrarySort.publicationState => 'publication_desc',
        },
        'p_page': query.page,
        'p_page_size': query.pageSize,
      },
    ),
  );

  @override
  Future<Map<String, Object?>> fetchExercise(String exerciseId) async => _map(
    await _client
        .from('exercise_definitions')
        .select(_exerciseSelect)
        .eq('id', exerciseId)
        .single(),
  );

  @override
  Future<Map<String, Object?>> fetchGuidanceDraft(String exerciseId) async => _map(
    await _client
        .from('guidance_drafts')
        .select(_draftSelect)
        .eq('exercise_id', exerciseId)
        .single(),
  );

  @override
  Future<ExerciseGuidanceRemotePage> fetchGuidanceRevisionPage(
    String exerciseId, {
    required int page,
    required int pageSize,
  }) async {
    final start = (page - 1) * pageSize;
    final response = await _client
        .from('guidance_revisions')
        .select(_revisionSelect)
        .eq('exercise_id', exerciseId)
        .order('version_number', ascending: false)
        .range(start, start + pageSize - 1)
        .count(CountOption.exact);
    return ExerciseGuidanceRemotePage(items: _mapList(response.data), totalCount: response.count);
  }

  @override
  Future<Map<String, Object?>> fetchGuidanceRevision(String revisionId) async => _map(
    await _client.from('guidance_revisions').select(_revisionSelect).eq('id', revisionId).single(),
  );

  @override
  Future<Map<String, Object?>> createOrUpdateExercise(CreateOrUpdateExerciseCommand command) async {
    final common = <String, Object?>{
      'p_canonical_name': command.canonicalName,
      'p_variant_key': command.variantKey,
      'p_equipment': command.equipmentKeys,
      'p_muscles': _musclePayload(command.primaryMuscleKeys, command.secondaryMuscleKeys),
      'p_duplicate_confirmed': command.duplicateConfirmed,
      'p_idempotency_key': command.idempotencyKey,
    };
    if (command.exerciseId == null) {
      return _map(await _client.rpc<Object?>('create_exercise_v1', params: common));
    }
    return _map(
      await _client.rpc<Object?>(
        'update_exercise_v1',
        params: <String, Object?>{
          'p_exercise_id': command.exerciseId,
          ...common,
          'p_expected_revision': command.expectedRevision,
        },
      ),
    );
  }

  @override
  Future<Map<String, Object?>> setExerciseArchived(
    ArchiveExerciseCommand command,
    bool archived,
  ) async => _map(
    await _client.rpc<Object?>(
      'set_exercise_archived_v1',
      params: <String, Object?>{
        'p_exercise_id': command.exerciseId,
        'p_archived': archived,
        'p_expected_revision': command.expectedRevision,
        'p_idempotency_key': command.idempotencyKey,
      },
    ),
  );

  @override
  Future<Map<String, Object?>> cloneExercise(CloneExerciseCommand command) async => _map(
    await _client.rpc<Object?>(
      'clone_exercise_v1',
      params: <String, Object?>{
        'p_source_exercise_id': command.sourceExerciseId,
        'p_canonical_name': command.canonicalName,
        'p_duplicate_confirmed': command.duplicateConfirmed,
        'p_idempotency_key': command.idempotencyKey,
      },
    ),
  );

  @override
  Future<Map<String, Object?>> saveGuidanceDraft(SaveGuidanceDraftCommand command) async => _map(
    await _client.rpc<Object?>(
      'save_guidance_draft_v1',
      params: <String, Object?>{
        'p_draft_id': command.draftId,
        'p_structured_content': _contentPayload(command.content),
        'p_expected_revision': command.expectedRevision,
        'p_idempotency_key': command.idempotencyKey,
      },
    ),
  );

  @override
  Future<Map<String, Object?>> validateGuidanceDraft(ValidateGuidanceDraftCommand command) async =>
      _map(
        await _client.rpc<Object?>(
          'validate_guidance_draft_v1',
          params: <String, Object?>{
            'p_exercise_id': command.exerciseId,
            'p_draft_id': command.draftId,
            'p_expected_exercise_revision': command.expectedExerciseRevision,
            'p_expected_draft_revision': command.expectedDraftRevision,
          },
        ),
      );

  @override
  Future<Map<String, Object?>> publishGuidance(PublishGuidanceCommand command) async => _map(
    await _client.rpc<Object?>(
      'publish_guidance_revision_v1',
      params: <String, Object?>{
        'p_exercise_id': command.exerciseId,
        'p_draft_id': command.draftId,
        'p_expected_exercise_revision': command.expectedExerciseRevision,
        'p_expected_draft_revision': command.expectedDraftRevision,
        'p_idempotency_key': command.idempotencyKey,
      },
    ),
  );

  @override
  Future<Map<String, Object?>> duplicateGuidanceRevisionAsDraft(
    DuplicateGuidanceRevisionAsDraftCommand command,
  ) async => _map(
    await _client.rpc<Object?>(
      'duplicate_guidance_revision_as_draft_v1',
      params: <String, Object?>{
        'p_exercise_id': command.exerciseId,
        'p_guidance_revision_id': command.revisionId,
        'p_expected_draft_revision': command.expectedDraftRevision,
        'p_idempotency_key': command.idempotencyKey,
      },
    ),
  );
}

List<Map<String, Object?>> _mapList(Object? value) {
  if (value is! List<Object?>) {
    throw const FormatException('Expected a list response.');
  }
  return value.map(_map).toList(growable: false);
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

List<Map<String, Object?>> _musclePayload(List<String> primary, List<String> secondary) =>
    <Map<String, Object?>>[
      for (var index = 0; index < primary.length; index += 1)
        <String, Object?>{
          'muscleKey': primary[index],
          'role': 'primary',
          'position': index + 1,
        },
      for (var index = 0; index < secondary.length; index += 1)
        <String, Object?>{
          'muscleKey': secondary[index],
          'role': 'secondary',
          'position': index + 1,
        },
    ];

Map<String, Object?> _contentPayload(GuidanceContentV1 content) => <String, Object?>{
  'shortExplanation': content.shortExplanation,
  'setupSteps': content.setupSteps,
  'executionSteps': content.executionSteps,
  'techniqueCues': content.techniqueCues,
  'commonMistakes': content.commonMistakes,
  'safetyNotes': content.safetyNotes,
};
