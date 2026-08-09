import 'package:stone_set_domain/routines.dart';

final class FakeRoutineRepository implements RoutineRepository {
  FakeRoutineRepository({
    RoutineDraft? draft,
    this.validation = const <RoutineValidationIssue>[],
  }) : draft = draft ?? routineDraft();

  RoutineDraft draft;
  List<RoutineValidationIssue> validation;
  final List<String> calls = <String>[];
  RoutineSubmission? submission;
  RoutineVersion? version;

  @override
  Future<List<RoutineSummary>> listRoutines() async => draft.status == RoutineDraftStatus.archived
      ? const <RoutineSummary>[]
      : <RoutineSummary>[
          RoutineSummary(
            id: draft.id,
            name: draft.name,
            status: draft.status,
            revision: draft.revision,
            updatedAt: draft.updatedAt,
            latestVersionId: version?.id,
            latestVersionNumber: version?.versionNumber,
          ),
        ];

  @override
  Future<RoutineMutationResult<RoutineDraft>> createDraft(
    String name,
    String? description,
    String idempotencyKey,
  ) async {
    calls.add('create');
    draft = _copyDraft(draft, name: name, description: description);
    return _result(draft);
  }

  @override
  Future<RoutineDraft> getDraft(String routineId) async => draft;

  @override
  Future<RoutineMutationResult<RoutineDraft>> saveDraft(SaveRoutineDraftCommand command) async {
    calls.add('save');
    if (command.expectedRevision != draft.revision) {
      throw RoutineFailure('stale_revision', currentRevision: draft.revision);
    }
    draft = _copyDraft(command.draft, revision: command.expectedRevision + 1);
    return _result(draft);
  }

  @override
  Future<RoutineMutationResult<RoutineDraft>> archiveDraft(
    String routineId,
    int expectedRevision,
    String idempotencyKey,
  ) async {
    calls.add('archive');
    draft = _copyDraft(
      draft,
      revision: expectedRevision + 1,
      status: RoutineDraftStatus.archived,
    );
    return _result(draft);
  }

  @override
  Future<RoutineValidationResult> validateDraft(String routineId, int expectedRevision) async {
    calls.add('validate');
    return RoutineValidationResult(validation);
  }

  @override
  Future<RoutineMutationResult<RoutineSubmission>> submitDraft(
    String routineId,
    int expectedRevision,
    String idempotencyKey,
  ) async {
    calls.add('submit');
    submission = RoutineSubmission(
      id: submissionId,
      routineDraftId: draft.id,
      ownerId: draft.ownerId,
      routineName: draft.name,
      draftRevision: expectedRevision,
      status: RoutineDraftStatus.submitted,
      submittedAt: testNow,
      description: draft.description,
      days: draft.days,
      validationIssues: validation,
    );
    draft = _copyDraft(
      draft,
      status: RoutineDraftStatus.submitted,
      latestSubmissionId: submissionId,
      replaceLatestSubmissionId: true,
    );
    return _result(submission!);
  }

  @override
  Future<List<RoutineSubmission>> listReviewQueue() async => <RoutineSubmission>[?submission];

  @override
  Future<RoutineSubmission> getSubmission(String submissionId) async =>
      submission ??
      RoutineSubmission(
        id: submissionId,
        routineDraftId: draft.id,
        ownerId: draft.ownerId,
        routineName: draft.name,
        draftRevision: draft.revision,
        status: RoutineDraftStatus.submitted,
        submittedAt: testNow,
        description: draft.description,
        days: draft.days,
        validationIssues: validation,
      );

  @override
  Future<RoutineMutationResult<RoutineSubmission>> approve(
    String submissionId,
    String? note,
    String idempotencyKey,
  ) async {
    calls.add('approve');
    submission = _reviewed(await getSubmission(submissionId), RoutineDraftStatus.approved, note);
    draft = _copyDraft(draft, status: RoutineDraftStatus.approved);
    return _result(submission!);
  }

  @override
  Future<RoutineMutationResult<RoutineSubmission>> reject(
    String submissionId,
    String note,
    String idempotencyKey,
  ) async {
    calls.add('reject');
    submission = _reviewed(await getSubmission(submissionId), RoutineDraftStatus.rejected, note);
    draft = _copyDraft(draft, status: RoutineDraftStatus.draft);
    return _result(submission!);
  }

  @override
  Future<RoutineMutationResult<RoutineVersion>> publish(
    String submissionId,
    DateTime effectiveDate,
    String idempotencyKey,
  ) async {
    calls.add('publish');
    final approved = await getSubmission(submissionId);
    version = RoutineVersion(
      id: versionId,
      routineDraftId: approved.routineDraftId,
      ownerId: approved.ownerId,
      versionNumber: 1,
      name: approved.routineName,
      description: approved.description,
      days: approved.days,
      contentHash: 'abc123',
      publishedAt: effectiveDate,
      effectiveDate: effectiveDate,
    );
    draft = _copyDraft(draft, status: RoutineDraftStatus.published);
    return _result(version!);
  }

  @override
  Future<List<RoutineVersion>> listVersions(String routineId) async => <RoutineVersion>[?version];

  @override
  Future<RoutineVersion> getVersion(String routineId, String versionId) async =>
      version ??
      RoutineVersion(
        id: versionId,
        routineDraftId: draft.id,
        ownerId: draft.ownerId,
        versionNumber: 1,
        name: draft.name,
        description: draft.description,
        days: draft.days,
        contentHash: 'abc123',
        publishedAt: testNow,
        effectiveDate: testNow,
      );

  @override
  Future<RoutineMutationResult<RoutineDraft>> duplicateVersion(
    String routineId,
    String versionId,
    String name,
    String idempotencyKey,
  ) async {
    calls.add('duplicate');
    draft = _copyDraft(draft, name: name, revision: 1);
    return _result(draft);
  }
}

const ownerId = '10000000-0000-4000-8000-000000000001';
const draftId = '20000000-0000-4000-8000-000000000001';
const submissionId = '30000000-0000-4000-8000-000000000001';
const versionId = '40000000-0000-4000-8000-000000000001';
final testNow = DateTime.utc(2026, 8, 9);

RoutineDraft routineDraft() => RoutineDraft(
  id: draftId,
  ownerId: ownerId,
  name: 'Strength and size',
  description: 'Four focused sessions.',
  status: RoutineDraftStatus.draft,
  revision: 1,
  days: <RoutineDay>[
    for (var day = 1; day <= 7; day++)
      RoutineDay(
        id: '50000000-0000-4000-8000-${day.toString().padLeft(12, '0')}',
        dayIndex: day,
        kind: day <= 4 ? RoutineDayKind.workout : RoutineDayKind.rest,
        title: day <= 4 ? 'Workout $day' : 'Rest $day',
        purpose: day <= 4 ? 'Build muscle' : 'Recover',
        prescriptions: day <= 4
            ? <RoutinePrescription>[
                for (var exercise = 1; exercise <= 3; exercise++)
                  RoutinePrescription(
                    id: '60000000-0000-4000-8000-${(day * 10 + exercise).toString().padLeft(12, '0')}',
                    exerciseId: '70000000-0000-4000-8000-${exercise.toString().padLeft(12, '0')}',
                    guidanceRevisionId:
                        '80000000-0000-4000-8000-${exercise.toString().padLeft(12, '0')}',
                    position: exercise,
                    sets: 3,
                    minReps: 8,
                    maxReps: 12,
                    rir: 2,
                    restSeconds: 90,
                    priority: exercise == 1,
                    loadUnit: 'kg',
                    notes: null,
                  ),
              ]
            : const <RoutinePrescription>[],
      ),
  ],
  createdAt: testNow,
  updatedAt: testNow,
);

RoutineDraft _copyDraft(
  RoutineDraft source, {
  String? name,
  String? description,
  int? revision,
  RoutineDraftStatus? status,
  String? latestSubmissionId,
  bool replaceLatestSubmissionId = false,
}) => RoutineDraft(
  id: source.id,
  ownerId: source.ownerId,
  name: name ?? source.name,
  description: description ?? source.description,
  status: status ?? source.status,
  revision: revision ?? source.revision,
  days: source.days,
  baseVersionId: source.baseVersionId,
  latestSubmissionId: replaceLatestSubmissionId
      ? latestSubmissionId
      : latestSubmissionId ?? source.latestSubmissionId,
  createdAt: source.createdAt,
  updatedAt: testNow,
);

RoutineSubmission _reviewed(
  RoutineSubmission source,
  RoutineDraftStatus status,
  String? note,
) => RoutineSubmission(
  id: source.id,
  routineDraftId: source.routineDraftId,
  ownerId: source.ownerId,
  routineName: source.routineName,
  draftRevision: source.draftRevision,
  status: status,
  submittedAt: source.submittedAt,
  description: source.description,
  days: source.days,
  validationIssues: source.validationIssues,
  reviewedAt: testNow,
  reviewNote: note,
);

RoutineMutationResult<T> _result<T>(T value) => RoutineMutationResult<T>(
  value: value,
  correlationId: '90000000-0000-4000-8000-000000000001',
  replayed: false,
);
