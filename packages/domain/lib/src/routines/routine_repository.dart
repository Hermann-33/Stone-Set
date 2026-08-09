import 'routine_models.dart';

final class SaveRoutineDraftCommand {
  const SaveRoutineDraftCommand({
    required this.draft,
    required this.expectedRevision,
    required this.idempotencyKey,
  });
  final RoutineDraft draft;
  final int expectedRevision;
  final String idempotencyKey;
}

abstract interface class RoutineRepository {
  Future<List<RoutineSummary>> listRoutines();
  Future<RoutineMutationResult<RoutineDraft>> createDraft(
    String name,
    String? description,
    String idempotencyKey,
  );
  Future<RoutineDraft> getDraft(String routineId);
  Future<RoutineMutationResult<RoutineDraft>> saveDraft(SaveRoutineDraftCommand command);
  Future<RoutineMutationResult<RoutineDraft>> archiveDraft(
    String routineId,
    int expectedRevision,
    String idempotencyKey,
  );
  Future<RoutineValidationResult> validateDraft(String routineId, int expectedRevision);
  Future<RoutineMutationResult<RoutineSubmission>> submitDraft(
    String routineId,
    int expectedRevision,
    String idempotencyKey,
  );
  Future<List<RoutineSubmission>> listReviewQueue();
  Future<RoutineSubmission> getSubmission(String submissionId);
  Future<RoutineMutationResult<RoutineSubmission>> approve(
    String submissionId,
    String? note,
    String idempotencyKey,
  );
  Future<RoutineMutationResult<RoutineSubmission>> reject(
    String submissionId,
    String note,
    String idempotencyKey,
  );
  Future<RoutineMutationResult<RoutineVersion>> publish(
    String submissionId,
    DateTime effectiveDate,
    String idempotencyKey,
  );
  Future<List<RoutineVersion>> listVersions(String routineId);
  Future<RoutineVersion> getVersion(String routineId, String versionId);
  Future<RoutineMutationResult<RoutineDraft>> duplicateVersion(
    String routineId,
    String versionId,
    String name,
    String idempotencyKey,
  );
}
