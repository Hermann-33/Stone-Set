import 'dart:async';

import 'package:stone_set_domain/exercise_guidance.dart';

final class FakeExerciseGuidanceRepository implements ExerciseGuidanceRepository {
  FakeExerciseGuidanceRepository({List<ExerciseLibraryItem>? items})
    : items = items ?? <ExerciseLibraryItem>[];

  final List<ExerciseLibraryItem> items;
  final List<ExerciseLibraryQuery> queries = <ExerciseLibraryQuery>[];
  final List<CreateOrUpdateExerciseCommand> exerciseMutations = <CreateOrUpdateExerciseCommand>[];
  final List<SaveGuidanceDraftCommand> draftSaves = <SaveGuidanceDraftCommand>[];
  final List<PublishGuidanceCommand> publications = <PublishGuidanceCommand>[];
  ExerciseGuidanceFailure? listFailure;
  Completer<ExerciseMutationResult>? exerciseMutationBlocker;
  Completer<GuidanceDraftMutationResult>? draftSaveBlocker;
  Completer<GuidancePublishResult>? publishBlocker;

  static final muscle = Muscle(
    id: '10000000-0000-4000-8000-000000000001',
    key: 'chest',
    displayName: 'Chest',
    displayOrder: 1,
  );

  @override
  Future<List<Muscle>> listMuscles() async => <Muscle>[muscle];

  @override
  Future<ExerciseLibraryPage> listExercises(ExerciseLibraryQuery query) async {
    queries.add(query);
    final failure = listFailure;
    if (failure != null) throw failure;
    final search = query.search?.toLowerCase();
    final filtered = items
        .where((item) {
          if (search != null && !item.canonicalName.toLowerCase().contains(search)) {
            return false;
          }
          if (query.archive == ExerciseArchiveFilter.active && item.isArchived) {
            return false;
          }
          if (query.archive == ExerciseArchiveFilter.archived && !item.isArchived) {
            return false;
          }
          if (query.publication == ExercisePublicationFilter.published && !item.published) {
            return false;
          }
          if (query.publication == ExercisePublicationFilter.draftOnly && item.published) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
    return ExerciseLibraryPage(
      items: filtered,
      page: query.page,
      pageSize: query.pageSize,
      totalCount: filtered.length,
    );
  }

  @override
  Future<ExerciseDefinition> getExercise(String exerciseId) async {
    final item = items.where((candidate) => candidate.id == exerciseId).firstOrNull;
    if (item == null) throw const ExerciseGuidanceFailure(ExerciseGuidanceErrorCode.notFound);
    return exerciseDefinition(item);
  }

  @override
  Future<ExerciseMutationResult> createOrUpdateExercise(
    CreateOrUpdateExerciseCommand command,
  ) async {
    exerciseMutations.add(command);
    final blocker = exerciseMutationBlocker;
    exerciseMutationBlocker = null;
    if (blocker != null) return blocker.future;
    final now = DateTime.utc(2026, 8, 8);
    final definition = ExerciseDefinition(
      id: command.exerciseId ?? '20000000-0000-4000-8000-000000000001',
      userId: testUserId,
      canonicalName: command.canonicalName,
      normalizedName: command.canonicalName.toLowerCase(),
      variantKey: command.variantKey,
      equipmentKeys: command.equipmentKeys,
      muscles: <ExerciseMuscleSelection>[
        for (final key in command.primaryMuscleKeys)
          ExerciseMuscleSelection(
            muscle: Muscle(id: muscle.id, key: key, displayName: key, displayOrder: 1),
            role: ExerciseMuscleRole.primary,
            position: 0,
          ),
      ],
      revision: (command.expectedRevision ?? 0) + 1,
      createdAt: now,
      updatedAt: now,
    );
    return ExerciseMutationResult(
      exercise: definition,
      replayed: false,
      correlationId: '30000000-0000-4000-8000-000000000001',
    );
  }

  @override
  Future<ExerciseMutationResult> archiveExercise(ArchiveExerciseCommand command) async =>
      _existingMutation(command.exerciseId);

  @override
  Future<ExerciseMutationResult> unarchiveExercise(ArchiveExerciseCommand command) async =>
      _existingMutation(command.exerciseId);

  @override
  Future<ExerciseMutationResult> cloneExercise(CloneExerciseCommand command) async =>
      _existingMutation(command.sourceExerciseId);

  Future<ExerciseMutationResult> _existingMutation(String exerciseId) async =>
      ExerciseMutationResult(
        exercise: await getExercise(exerciseId),
        replayed: false,
        correlationId: '30000000-0000-4000-8000-000000000002',
      );

  @override
  Future<GuidanceDraft> getGuidanceDraft(String exerciseId) async => guidanceDraft(exerciseId);

  @override
  Future<GuidanceDraftMutationResult> saveGuidanceDraft(SaveGuidanceDraftCommand command) async =>
      _saveGuidanceDraft(command);

  Future<GuidanceDraftMutationResult> _saveGuidanceDraft(SaveGuidanceDraftCommand command) async {
    draftSaves.add(command);
    final blocker = draftSaveBlocker;
    draftSaveBlocker = null;
    if (blocker != null) return blocker.future;
    return GuidanceDraftMutationResult(
      draft: GuidanceDraft(
        id: command.draftId,
        exerciseId: command.exerciseId,
        userId: testUserId,
        content: command.content,
        revision: command.expectedRevision + 1,
        createdAt: DateTime.utc(2026, 8, 8),
        updatedAt: DateTime.utc(2026, 8, 8),
      ),
      replayed: false,
      correlationId: '30000000-0000-4000-8000-000000000003',
    );
  }

  @override
  Future<ExerciseGuidanceValidationResult> validateGuidanceDraft(
    ValidateGuidanceDraftCommand command,
  ) async => ExerciseGuidanceValidationResult(const <ExerciseGuidanceValidationIssue>[]);

  @override
  Future<GuidancePublishResult> publishGuidance(PublishGuidanceCommand command) async =>
      _publishGuidance(command);

  Future<GuidancePublishResult> _publishGuidance(PublishGuidanceCommand command) async {
    publications.add(command);
    final blocker = publishBlocker;
    publishBlocker = null;
    if (blocker != null) return blocker.future;
    return GuidancePublishResult(
      revision: guidanceRevision(command.exerciseId),
      noChange: false,
      replayed: false,
      correlationId: '30000000-0000-4000-8000-000000000004',
    );
  }

  @override
  Future<GuidanceRevisionPage> listGuidanceRevisions(
    String exerciseId, {
    int page = 1,
    int pageSize = 25,
  }) async => GuidanceRevisionPage(
    items: const <GuidanceRevision>[],
    page: page,
    pageSize: pageSize,
    totalCount: 0,
  );

  @override
  Future<GuidanceRevision> getGuidanceRevision(String exerciseId, String revisionId) async =>
      guidanceRevision(exerciseId, revisionId: revisionId);

  @override
  Future<GuidanceDraftMutationResult> duplicateGuidanceRevisionAsDraft(
    DuplicateGuidanceRevisionAsDraftCommand command,
  ) async => GuidanceDraftMutationResult(
    draft: guidanceDraft(command.exerciseId),
    replayed: false,
    correlationId: '30000000-0000-4000-8000-000000000005',
  );
}

const testUserId = '00000000-0000-4000-8000-000000000001';

ExerciseLibraryItem exerciseItem({
  String id = '20000000-0000-4000-8000-000000000001',
  String name = 'Incline dumbbell press',
  bool published = false,
}) => ExerciseLibraryItem(
  id: id,
  userId: testUserId,
  canonicalName: name,
  normalizedName: name.toLowerCase(),
  variantKey: null,
  equipmentKeys: const <String>['dumbbell'],
  primaryMuscleIds: <String>[FakeExerciseGuidanceRepository.muscle.id],
  secondaryMuscleIds: const <String>[],
  published: published,
  revision: 1,
  createdAt: DateTime.utc(2026, 8, 8),
  updatedAt: DateTime.utc(2026, 8, 8),
  draftId: '40000000-0000-4000-8000-000000000001',
  draftRevision: 1,
);

ExerciseDefinition exerciseDefinition(ExerciseLibraryItem item) => ExerciseDefinition(
  id: item.id,
  userId: item.userId,
  canonicalName: item.canonicalName,
  normalizedName: item.normalizedName,
  variantKey: item.variantKey,
  equipmentKeys: item.equipmentKeys,
  muscles: <ExerciseMuscleSelection>[
    ExerciseMuscleSelection(
      muscle: FakeExerciseGuidanceRepository.muscle,
      role: ExerciseMuscleRole.primary,
      position: 0,
    ),
  ],
  revision: item.revision,
  createdAt: item.createdAt,
  updatedAt: item.updatedAt,
  currentDraft: guidanceDraft(item.id),
);

GuidanceDraft guidanceDraft(String exerciseId) => GuidanceDraft(
  id: '40000000-0000-4000-8000-000000000001',
  exerciseId: exerciseId,
  userId: testUserId,
  content: GuidanceContentV1(shortExplanation: 'Keep the torso stable.'),
  revision: 1,
  createdAt: DateTime.utc(2026, 8, 8),
  updatedAt: DateTime.utc(2026, 8, 8),
);

GuidanceRevision guidanceRevision(
  String exerciseId, {
  String revisionId = '50000000-0000-4000-8000-000000000001',
}) => GuidanceRevision(
  id: revisionId,
  exerciseId: exerciseId,
  userId: testUserId,
  versionNumber: 1,
  content: GuidanceContentV1(shortExplanation: 'Keep the torso stable.'),
  canonicalName: 'Incline dumbbell press',
  variantKey: null,
  equipmentKeys: const <String>['dumbbell'],
  muscles: const <ExerciseMuscleSelection>[],
  contentHash: ''.padLeft(64, 'a'),
  revisionHash: ''.padLeft(64, 'b'),
  publishedAt: DateTime.utc(2026, 8, 8),
);
