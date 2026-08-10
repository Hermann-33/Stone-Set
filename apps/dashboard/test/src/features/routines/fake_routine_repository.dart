import 'package:stone_set_domain/routines.dart';

final class FakeRoutineRepository implements RoutineRepository {
  FakeRoutineRepository({
    RoutineDraft? draft,
    this.validation = const <RoutineValidationIssue>[],
  }) : draft = draft ?? routineDraft();

  RoutineDraft draft;
  List<RoutineValidationIssue> validation;
  final List<String> calls = <String>[];
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
  Future<RoutineMutationResult<RoutineVersion>> publishDraft(
    String routineId,
    int expectedRevision,
    String idempotencyKey,
  ) async {
    calls.add('publish');
    if (validation.isNotEmpty) {
      throw const RoutineFailure('routine_draft_invalid');
    }
    if (expectedRevision != draft.revision) {
      throw RoutineFailure('stale_revision', currentRevision: draft.revision);
    }
    version = RoutineVersion(
      id: versionId,
      routineDraftId: draft.id,
      ownerId: draft.ownerId,
      versionNumber: (version?.versionNumber ?? 0) + 1,
      name: draft.name,
      description: draft.description,
      days: draft.days,
      contentHash: 'abc123',
      publishedAt: testNow,
      effectiveDate: DateTime.utc(testNow.year, testNow.month, testNow.day - (testNow.weekday - 1)),
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
    draft = _copyDraft(
      draft,
      name: name,
      revision: 1,
      status: RoutineDraftStatus.draft,
      latestSubmissionId: null,
      replaceLatestSubmissionId: true,
    );
    return _result(draft);
  }
}

const ownerId = '10000000-0000-4000-8000-000000000001';
const draftId = '20000000-0000-4000-8000-000000000001';
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

RoutineMutationResult<T> _result<T>(T value) => RoutineMutationResult<T>(
  value: value,
  correlationId: '90000000-0000-4000-8000-000000000001',
  replayed: false,
);
