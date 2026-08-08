import 'package:stone_set_domain/exercise_guidance.dart';

import 'exercise_guidance_remote_service.dart';
import 'supabase_exercise_guidance_error_mapper.dart';

final class SupabaseExerciseGuidanceRepository implements ExerciseGuidanceRepository {
  const SupabaseExerciseGuidanceRepository({required ExerciseGuidanceRemoteService remote})
    // This public constructor label intentionally maps to a private dependency.
    // ignore: prefer_initializing_formals
    : _remote = remote;

  final ExerciseGuidanceRemoteService _remote;

  @override
  Future<List<Muscle>> listMuscles() async => _guard(
    () async => (await _remote.fetchMuscles()).map(_decodeMuscle).toList(growable: false),
  );

  @override
  Future<ExerciseLibraryPage> listExercises(ExerciseLibraryQuery query) async => _guard(() async {
    final envelope = await _remote.fetchExercisePage(query);
    final page = _requiredInt(envelope, 'page');
    final pageSize = _requiredInt(envelope, 'pageSize');
    final totalCount = _requiredInt(envelope, 'total');
    final rawItems = _list(envelope, 'items');
    if (page != query.page ||
        pageSize != query.pageSize ||
        totalCount < 0 ||
        rawItems.length > query.pageSize) {
      throw const FormatException('Exercise page envelope is inconsistent.');
    }
    return ExerciseLibraryPage(
      items: rawItems.map((value) => _decodeExerciseLibraryItem(_mapValue(value))),
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
    );
  });

  @override
  Future<ExerciseDefinition> getExercise(String exerciseId) => _guard(() async {
    final exercise = _decodeExercise(await _remote.fetchExercise(exerciseId));
    if (exercise.id != exerciseId) {
      throw const FormatException('Exercise detail response is inconsistent.');
    }
    return exercise;
  });

  @override
  Future<ExerciseMutationResult> createOrUpdateExercise(
    CreateOrUpdateExerciseCommand command,
  ) => _guard(() async {
    final envelope = await _remote.createOrUpdateExercise(command);
    final evidence = _decodeMutationEvidence(
      envelope,
      command.exerciseId == null ? 'create_exercise_v1' : 'update_exercise_v1',
    );
    final exerciseId = _requiredString(envelope, 'exerciseId');
    if (command.exerciseId != null && exerciseId != command.exerciseId) {
      throw const FormatException('Exercise mutation returned a mismatched exercise.');
    }
    final exercise = await getExercise(exerciseId);
    return ExerciseMutationResult(
      exercise: exercise,
      replayed: evidence.replayed,
      correlationId: evidence.correlationId,
    );
  });

  @override
  Future<ExerciseMutationResult> archiveExercise(ArchiveExerciseCommand command) =>
      _setArchived(command, true);

  @override
  Future<ExerciseMutationResult> unarchiveExercise(ArchiveExerciseCommand command) =>
      _setArchived(command, false);

  Future<ExerciseMutationResult> _setArchived(
    ArchiveExerciseCommand command,
    bool archived,
  ) => _guard(() async {
    final envelope = await _remote.setExerciseArchived(command, archived);
    final evidence = _decodeMutationEvidence(envelope, 'set_exercise_archived_v1');
    _requireMatchingString(envelope, 'exerciseId', command.exerciseId);
    return ExerciseMutationResult(
      exercise: await getExercise(command.exerciseId),
      replayed: evidence.replayed,
      correlationId: evidence.correlationId,
    );
  });

  @override
  Future<ExerciseMutationResult> cloneExercise(CloneExerciseCommand command) => _guard(() async {
    final envelope = await _remote.cloneExercise(command);
    final evidence = _decodeMutationEvidence(envelope, 'clone_exercise_v1');
    _requireMatchingString(envelope, 'sourceExerciseId', command.sourceExerciseId);
    final exerciseId = _requiredString(envelope, 'exerciseId');
    return ExerciseMutationResult(
      exercise: await getExercise(exerciseId),
      replayed: evidence.replayed,
      correlationId: evidence.correlationId,
    );
  });

  @override
  Future<GuidanceDraft> getGuidanceDraft(String exerciseId) => _guard(() async {
    final draft = _decodeDraft(await _remote.fetchGuidanceDraft(exerciseId));
    if (draft.exerciseId != exerciseId) {
      throw const FormatException('Guidance draft response is inconsistent.');
    }
    return draft;
  });

  @override
  Future<GuidanceDraftMutationResult> saveGuidanceDraft(SaveGuidanceDraftCommand command) =>
      _guard(() async {
        final envelope = await _remote.saveGuidanceDraft(command);
        final evidence = _decodeMutationEvidence(envelope, 'save_guidance_draft_v1');
        _requireMatchingString(envelope, 'draftId', command.draftId);
        final draft = _decodeDraft(await _remote.fetchGuidanceDraft(command.exerciseId));
        if (draft.id != command.draftId || draft.exerciseId != command.exerciseId) {
          throw const FormatException('Saved guidance draft response is inconsistent.');
        }
        return GuidanceDraftMutationResult(
          draft: draft,
          replayed: evidence.replayed,
          correlationId: evidence.correlationId,
        );
      });

  @override
  Future<ExerciseGuidanceValidationResult> validateGuidanceDraft(
    ValidateGuidanceDraftCommand command,
  ) => _guard(() async {
    final envelope = await _remote.validateGuidanceDraft(command);
    final issueValues = _list(envelope, 'issues');
    return ExerciseGuidanceValidationResult(
      issueValues.map((value) {
        final issue = _mapValue(value);
        final rawCode = _requiredString(issue, 'code');
        return ExerciseGuidanceValidationIssue(
          code: switch (rawCode) {
            'exercise_archived' => ExerciseGuidanceValidationCode.exerciseArchived,
            _ => ExerciseGuidanceValidationCode.invalidStructuredContent,
          },
          field: issue['path'] as String? ?? 'structuredContent',
          message: rawCode,
        );
      }),
    );
  });

  @override
  Future<GuidancePublishResult> publishGuidance(PublishGuidanceCommand command) => _guard(() async {
    final envelope = await _remote.publishGuidance(command);
    final evidence = _decodeMutationEvidence(envelope, 'publish_guidance_revision_v1');
    _requireMatchingString(envelope, 'exerciseId', command.exerciseId);
    final revisionId = _requiredString(envelope, 'guidanceRevisionId');
    return GuidancePublishResult(
      revision: _decodeRevision(await _remote.fetchGuidanceRevision(revisionId)),
      noChange: _requiredBool(envelope, 'noChange'),
      replayed: evidence.replayed,
      correlationId: evidence.correlationId,
    );
  });

  @override
  Future<GuidanceRevisionPage> listGuidanceRevisions(
    String exerciseId, {
    int page = 1,
    int pageSize = 25,
  }) {
    if (page < 1 || pageSize < 1 || pageSize > 100) {
      throw ArgumentError('Guidance revision page bounds are invalid.');
    }
    return _guard(() async {
      final remotePage = await _remote.fetchGuidanceRevisionPage(
        exerciseId,
        page: page,
        pageSize: pageSize,
      );
      if (remotePage.totalCount < 0 || remotePage.items.length > pageSize) {
        throw const FormatException('Guidance revision page is inconsistent.');
      }
      final items = remotePage.items.map(_decodeRevision).toList(growable: false);
      if (items.any((revision) => revision.exerciseId != exerciseId)) {
        throw const FormatException('Guidance revision page contains another exercise.');
      }
      return GuidanceRevisionPage(
        items: items,
        page: page,
        pageSize: pageSize,
        totalCount: remotePage.totalCount,
      );
    });
  }

  @override
  Future<GuidanceRevision> getGuidanceRevision(String exerciseId, String revisionId) => _guard(
    () async {
      final revision = _decodeRevision(await _remote.fetchGuidanceRevision(revisionId));
      if (revision.exerciseId != exerciseId) {
        throw const ExerciseGuidanceFailure(ExerciseGuidanceErrorCode.notFound);
      }
      return revision;
    },
  );

  @override
  Future<GuidanceDraftMutationResult> duplicateGuidanceRevisionAsDraft(
    DuplicateGuidanceRevisionAsDraftCommand command,
  ) => _guard(() async {
    final envelope = await _remote.duplicateGuidanceRevisionAsDraft(command);
    final evidence = _decodeMutationEvidence(
      envelope,
      'duplicate_guidance_revision_as_draft_v1',
    );
    _requireMatchingString(envelope, 'exerciseId', command.exerciseId);
    _requireMatchingString(envelope, 'sourceGuidanceRevisionId', command.revisionId);
    final draft = _decodeDraft(await _remote.fetchGuidanceDraft(command.exerciseId));
    if (draft.exerciseId != command.exerciseId) {
      throw const FormatException('Duplicated guidance draft response is inconsistent.');
    }
    return GuidanceDraftMutationResult(
      draft: draft,
      replayed: evidence.replayed,
      correlationId: evidence.correlationId,
    );
  });
}

Future<T> _guard<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on ExerciseGuidanceFailure {
    rethrow;
  } on Object catch (error) {
    throw mapSupabaseExerciseGuidanceFailure(error);
  }
}

Muscle _decodeMuscle(Map<String, Object?> value) => Muscle(
  id: _requiredString(value, 'id'),
  key: _requiredString(
    value,
    value.containsKey('stable_key') ? 'stable_key' : 'muscle_key_snapshot',
  ),
  displayName:
      value['display_name'] as String? ??
      value['muscle_key_snapshot'] as String? ??
      _requiredString(value, 'stable_key'),
  displayOrder: value['display_order'] as int? ?? 0,
);

ExerciseLibraryItem _decodeExerciseLibraryItem(Map<String, Object?> value) => ExerciseLibraryItem(
  id: _requiredString(value, 'id'),
  userId: _requiredString(value, 'userId'),
  canonicalName: _requiredString(value, 'canonicalName'),
  normalizedName: _requiredString(value, 'normalizedName'),
  variantKey: value['variantKey'] as String?,
  equipmentKeys: _stringList(value['equipmentKeys']),
  primaryMuscleIds: _stringList(value['primaryMuscleIds']),
  secondaryMuscleIds: _stringList(value['secondaryMuscleIds']),
  published: _requiredBool(value, 'published'),
  revision: _requiredInt(value, 'revision'),
  createdAt: _requiredDate(value, 'createdAt'),
  updatedAt: _requiredDate(value, 'updatedAt'),
  archivedAt: _optionalDate(value['archivedAt']),
  clonedFromExerciseId: value['clonedFromExerciseId'] as String?,
  draftId: value['draftId'] as String?,
  draftRevision: value['draftRevision'] as int?,
  latestGuidanceRevisionId: value['latestGuidanceRevisionId'] as String?,
  latestGuidanceVersionNumber: value['latestGuidanceVersion'] as int?,
);

ExerciseDefinition _decodeExercise(Map<String, Object?> value) {
  final revisionValues = _list(value, 'guidance_revisions').map(_mapValue).toList()
    ..sort(
      (left, right) =>
          _requiredInt(right, 'version_number').compareTo(_requiredInt(left, 'version_number')),
    );
  final latestRevision = revisionValues.isEmpty ? null : revisionValues.first;
  final draftValue = _relatedObject(value['current_draft']);
  return ExerciseDefinition(
    id: _requiredString(value, 'id'),
    userId: _requiredString(value, 'user_id'),
    canonicalName: _requiredString(value, 'canonical_name'),
    normalizedName: _requiredString(value, 'normalized_name'),
    variantKey: value['variant_key'] as String?,
    equipmentKeys: _decodeEquipmentKeys(_list(value, 'equipment')),
    muscles: _decodeMuscleSelections(_list(value, 'muscles')),
    revision: _requiredInt(value, 'revision'),
    createdAt: _requiredDate(value, 'created_at'),
    updatedAt: _requiredDate(value, 'updated_at'),
    archivedAt: _optionalDate(value['archived_at']),
    clonedFromExerciseId: value['cloned_from_exercise_id'] as String?,
    latestGuidanceRevisionId: latestRevision == null ? null : _requiredString(latestRevision, 'id'),
    latestGuidanceVersionNumber: latestRevision == null
        ? null
        : _requiredInt(latestRevision, 'version_number'),
    currentDraft: draftValue == null ? null : _decodeDraft(draftValue),
  );
}

GuidanceDraft _decodeDraft(Map<String, Object?> value) {
  _requireSchemaVersionOne(value);
  return GuidanceDraft(
    id: _requiredString(value, 'id'),
    exerciseId: _requiredString(value, 'exercise_id'),
    userId: _requiredString(value, 'user_id'),
    baseGuidanceRevisionId: value['base_guidance_revision_id'] as String?,
    content: _decodeContent(_requiredMap(value, 'structured_content')),
    revision: _requiredInt(value, 'revision'),
    createdAt: _requiredDate(value, 'created_at'),
    updatedAt: _requiredDate(value, 'updated_at'),
  );
}

GuidanceRevision _decodeRevision(Map<String, Object?> value) {
  _requireSchemaVersionOne(value);
  return GuidanceRevision(
    id: _requiredString(value, 'id'),
    exerciseId: _requiredString(value, 'exercise_id'),
    userId: _requiredString(value, 'user_id'),
    versionNumber: _requiredInt(value, 'version_number'),
    content: _decodeContent(_requiredMap(value, 'structured_content')),
    canonicalName: _requiredString(value, 'canonical_name_snapshot'),
    variantKey: value['variant_key_snapshot'] as String?,
    equipmentKeys: _stringList(value['equipment_keys_snapshot']),
    muscles: _decodeMuscleSelections(_list(value, 'muscles')),
    contentHash: _requiredString(value, 'content_hash'),
    revisionHash: _requiredString(value, 'revision_hash'),
    supersedesRevisionId: value['supersedes_revision_id'] as String?,
    publishedAt: _requiredDate(value, 'published_at'),
  );
}

GuidanceContentV1 _decodeContent(Map<String, Object?> value) => GuidanceContentV1(
  shortExplanation: _requiredString(value, 'shortExplanation', allowEmpty: true),
  setupSteps: _stringList(value['setupSteps']),
  executionSteps: _stringList(value['executionSteps']),
  techniqueCues: _stringList(value['techniqueCues']),
  commonMistakes: _stringList(value['commonMistakes']),
  safetyNotes: _stringList(value['safetyNotes']),
);

List<ExerciseMuscleSelection> _decodeMuscleSelections(List<Object?> values) {
  final selections = values.map((raw) {
    final value = _mapValue(raw);
    final nestedMuscle = _relatedObject(value['muscle']);
    final muscle = nestedMuscle == null
        ? Muscle(
            id: _requiredString(value, 'muscle_id'),
            key: _requiredString(value, 'muscle_key_snapshot'),
            displayName: _requiredString(value, 'muscle_key_snapshot'),
            displayOrder: 0,
          )
        : _decodeMuscle(nestedMuscle);
    final role = switch (_requiredString(value, 'role')) {
      'primary' => ExerciseMuscleRole.primary,
      'secondary' => ExerciseMuscleRole.secondary,
      _ => throw const FormatException('Expected a supported muscle role.'),
    };
    return ExerciseMuscleSelection(
      muscle: muscle,
      role: role,
      position: _requiredInt(value, 'position'),
    );
  }).toList();
  selections.sort((left, right) {
    final roleOrder = left.role.index.compareTo(right.role.index);
    return roleOrder == 0 ? left.position.compareTo(right.position) : roleOrder;
  });
  return selections;
}

List<String> _decodeEquipmentKeys(List<Object?> values) {
  final equipment = values.map(_mapValue).toList()
    ..sort(
      (left, right) => _requiredInt(left, 'position').compareTo(_requiredInt(right, 'position')),
    );
  return equipment.map((value) => _requiredString(value, 'equipment_key')).toList(growable: false);
}

({bool replayed, String correlationId}) _decodeMutationEvidence(
  Map<String, Object?> envelope,
  String expectedOperation,
) {
  _requireMatchingString(envelope, 'operation', expectedOperation);
  return (
    replayed: _requiredBool(envelope, 'replayed'),
    correlationId: _requiredString(envelope, 'correlationId'),
  );
}

void _requireMatchingString(
  Map<String, Object?> values,
  String key,
  String expected,
) {
  if (_requiredString(values, key) != expected) {
    throw FormatException('Expected matching $key.');
  }
}

void _requireSchemaVersionOne(Map<String, Object?> value) {
  if (_requiredInt(value, 'structured_content_schema_version') != GuidanceContentV1.schemaVersion) {
    throw const FormatException('Unsupported guidance content schema version.');
  }
}

Map<String, Object?>? _relatedObject(Object? value) => switch (value) {
  null => null,
  final Map<String, Object?> map => map,
  final List<Object?> list when list.isNotEmpty => _mapValue(list.first),
  _ => null,
};

Map<String, Object?> _mapValue(Object? value) {
  if (value is! Map<String, Object?>) {
    throw const FormatException('Expected an object value.');
  }
  return value;
}

Map<String, Object?> _requiredMap(Map<String, Object?> values, String key) =>
    _mapValue(values[key]);

List<Object?> _list(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is! List<Object?>) {
    throw FormatException('Expected a list for $key.');
  }
  return value;
}

List<String> _stringList(Object? value) {
  if (value is! List<Object?> || value.any((item) => item is! String)) {
    throw const FormatException('Expected a string list.');
  }
  return List<String>.unmodifiable(value.cast<String>());
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

DateTime _requiredDate(Map<String, Object?> values, String key) {
  final value = _optionalDate(values[key]);
  if (value == null) {
    throw FormatException('Expected a timestamp for $key.');
  }
  return value;
}

DateTime? _optionalDate(Object? value) => value is String ? DateTime.parse(value).toUtc() : null;
