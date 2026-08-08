import 'exercise_guidance_models.dart';
import 'exercise_guidance_validation.dart';

enum ExerciseGuidanceErrorCode {
  invalidInput,
  duplicateConfirmationRequired,
  staleRevision,
  notFound,
  forbidden,
  inactiveProfile,
  passwordChangeRequired,
  sessionExpired,
  networkUnavailable,
  serverUnavailable,
  unknown,
}

final class ExerciseGuidanceConflictEvidence {
  const ExerciseGuidanceConflictEvidence({
    this.exerciseRevision,
    this.draftRevision,
    this.duplicateExerciseId,
  });

  final int? exerciseRevision;
  final int? draftRevision;
  final String? duplicateExerciseId;
}

final class ExerciseGuidanceFailure implements Exception {
  const ExerciseGuidanceFailure(this.code, {this.correlationId, this.conflict});

  final ExerciseGuidanceErrorCode code;
  final String? correlationId;
  final ExerciseGuidanceConflictEvidence? conflict;

  @override
  String toString() => 'ExerciseGuidanceFailure(${code.name})';
}

final class CreateOrUpdateExerciseCommand {
  CreateOrUpdateExerciseCommand({
    required this.canonicalName,
    required this.variantKey,
    required Iterable<String> equipmentKeys,
    required Iterable<String> primaryMuscleKeys,
    required Iterable<String> secondaryMuscleKeys,
    required this.idempotencyKey,
    this.exerciseId,
    this.expectedRevision,
    this.duplicateConfirmed = false,
  }) : equipmentKeys = List<String>.unmodifiable(equipmentKeys),
       primaryMuscleKeys = List<String>.unmodifiable(primaryMuscleKeys),
       secondaryMuscleKeys = List<String>.unmodifiable(secondaryMuscleKeys);

  final String? exerciseId;
  final String canonicalName;
  final String? variantKey;
  final List<String> equipmentKeys;
  final List<String> primaryMuscleKeys;
  final List<String> secondaryMuscleKeys;
  final int? expectedRevision;
  final String idempotencyKey;
  final bool duplicateConfirmed;
}

final class ArchiveExerciseCommand {
  const ArchiveExerciseCommand({
    required this.exerciseId,
    required this.expectedRevision,
    required this.idempotencyKey,
  });

  final String exerciseId;
  final int expectedRevision;
  final String idempotencyKey;
}

final class CloneExerciseCommand {
  const CloneExerciseCommand({
    required this.sourceExerciseId,
    required this.canonicalName,
    required this.idempotencyKey,
    this.duplicateConfirmed = false,
  });

  final String sourceExerciseId;
  final String canonicalName;
  final String idempotencyKey;
  final bool duplicateConfirmed;
}

final class SaveGuidanceDraftCommand {
  const SaveGuidanceDraftCommand({
    required this.exerciseId,
    required this.draftId,
    required this.content,
    required this.expectedRevision,
    required this.idempotencyKey,
  });

  final String exerciseId;
  final String draftId;
  final GuidanceContentV1 content;
  final int expectedRevision;
  final String idempotencyKey;
}

final class PublishGuidanceCommand {
  const PublishGuidanceCommand({
    required this.exerciseId,
    required this.draftId,
    required this.expectedExerciseRevision,
    required this.expectedDraftRevision,
    required this.idempotencyKey,
  });

  final String exerciseId;
  final String draftId;
  final int expectedExerciseRevision;
  final int expectedDraftRevision;
  final String idempotencyKey;
}

final class ValidateGuidanceDraftCommand {
  const ValidateGuidanceDraftCommand({
    required this.exerciseId,
    required this.draftId,
    required this.expectedExerciseRevision,
    required this.expectedDraftRevision,
  });

  final String exerciseId;
  final String draftId;
  final int expectedExerciseRevision;
  final int expectedDraftRevision;
}

final class DuplicateGuidanceRevisionAsDraftCommand {
  const DuplicateGuidanceRevisionAsDraftCommand({
    required this.exerciseId,
    required this.revisionId,
    required this.expectedDraftRevision,
    required this.idempotencyKey,
  });

  final String exerciseId;
  final String revisionId;
  final int expectedDraftRevision;
  final String idempotencyKey;
}

final class ExerciseMutationResult {
  const ExerciseMutationResult({
    required this.exercise,
    required this.replayed,
    required this.correlationId,
  });

  final ExerciseDefinition exercise;
  final bool replayed;
  final String correlationId;
}

final class GuidanceDraftMutationResult {
  const GuidanceDraftMutationResult({
    required this.draft,
    required this.replayed,
    required this.correlationId,
  });

  final GuidanceDraft draft;
  final bool replayed;
  final String correlationId;
}

final class GuidancePublishResult {
  const GuidancePublishResult({
    required this.revision,
    required this.noChange,
    required this.replayed,
    required this.correlationId,
  });

  final GuidanceRevision revision;
  final bool noChange;
  final bool replayed;
  final String correlationId;
}

/// Pure-Dart read boundary suitable for clients that must not author guidance.
abstract interface class ExerciseGuidanceReadRepository {
  Future<List<Muscle>> listMuscles();

  Future<ExerciseDefinition> getExercise(String exerciseId);

  Future<GuidanceRevision> getGuidanceRevision(String exerciseId, String revisionId);
}

/// Dashboard authoring boundary. Mobile code should depend on
/// [ExerciseGuidanceReadRepository] only.
abstract interface class ExerciseGuidanceRepository implements ExerciseGuidanceReadRepository {
  Future<ExerciseLibraryPage> listExercises(ExerciseLibraryQuery query);

  Future<ExerciseMutationResult> createOrUpdateExercise(CreateOrUpdateExerciseCommand command);

  Future<ExerciseMutationResult> archiveExercise(ArchiveExerciseCommand command);

  Future<ExerciseMutationResult> unarchiveExercise(ArchiveExerciseCommand command);

  Future<ExerciseMutationResult> cloneExercise(CloneExerciseCommand command);

  Future<GuidanceDraft> getGuidanceDraft(String exerciseId);

  Future<GuidanceDraftMutationResult> saveGuidanceDraft(SaveGuidanceDraftCommand command);

  Future<ExerciseGuidanceValidationResult> validateGuidanceDraft(
    ValidateGuidanceDraftCommand command,
  );

  Future<GuidancePublishResult> publishGuidance(PublishGuidanceCommand command);

  Future<GuidanceRevisionPage> listGuidanceRevisions(
    String exerciseId, {
    int page = 1,
    int pageSize = 25,
  });

  Future<GuidanceDraftMutationResult> duplicateGuidanceRevisionAsDraft(
    DuplicateGuidanceRevisionAsDraftCommand command,
  );
}
