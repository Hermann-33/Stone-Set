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

  /// Publishes the owner's current saved routine directly after server-side
  /// validation. No submission, reviewer, or approval step is required.
  Future<RoutineMutationResult<RoutineVersion>> publishDraft(
    String routineId,
    int expectedRevision,
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
