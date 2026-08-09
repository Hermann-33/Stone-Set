import 'dart:convert';

import 'package:stone_set_domain/routines.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'routine_remote_service.dart';

final class SupabaseRoutineRepository implements RoutineRepository {
  const SupabaseRoutineRepository({required RoutineRemoteService remote})
    // Public constructor label intentionally maps to a private dependency.
    // ignore: prefer_initializing_formals
    : _remote = remote;
  final RoutineRemoteService _remote;

  @override
  Future<List<RoutineSummary>> listRoutines() async => _guard(() async {
    final result = await _remote.call('list_my_routines_v1', const <String, Object?>{});
    return _list(result, 'items').map((value) => _summary(_map(value))).toList(growable: false);
  });

  @override
  Future<RoutineMutationResult<RoutineDraft>> createDraft(
    String name,
    String? description,
    String idempotencyKey,
  ) => _mutation(
    'create_routine_draft_v1',
    <String, Object?>{
      'p_name': name,
      'p_description': description,
      'p_idempotency_key': idempotencyKey,
    },
    (envelope) => getDraft(_requiredString(envelope, 'routineDraftId')),
  );

  @override
  Future<RoutineDraft> getDraft(String routineId) => _guard(() async {
    final value = await _remote.call('get_routine_draft_v1', <String, Object?>{
      'p_routine_draft_id': routineId,
    });
    final draft = _draft(_object(value));
    if (draft.id != routineId) throw const FormatException('Mismatched routine draft.');
    return draft;
  });

  @override
  Future<RoutineMutationResult<RoutineDraft>> saveDraft(SaveRoutineDraftCommand command) =>
      _mutation(
        'save_routine_draft_v1',
        <String, Object?>{
          'p_routine_draft_id': command.draft.id,
          'p_name': command.draft.name,
          'p_description': command.draft.description,
          'p_days': routineDraftPayload(command.draft)['days'],
          'p_expected_revision': command.expectedRevision,
          'p_idempotency_key': command.idempotencyKey,
        },
        (_) => getDraft(command.draft.id),
      );

  @override
  Future<RoutineMutationResult<RoutineDraft>> archiveDraft(
    String routineId,
    int expectedRevision,
    String idempotencyKey,
  ) => _mutation(
    'archive_routine_draft_v1',
    <String, Object?>{
      'p_routine_draft_id': routineId,
      'p_expected_revision': expectedRevision,
      'p_idempotency_key': idempotencyKey,
    },
    (_) => getDraft(routineId),
  );

  @override
  Future<RoutineValidationResult> validateDraft(String routineId, int expectedRevision) =>
      _guard(() async {
        final value = await _remote.call('validate_routine_draft_v1', <String, Object?>{
          'p_routine_draft_id': routineId,
          'p_expected_revision': expectedRevision,
        });
        return RoutineValidationResult(_decodeIssues(_list(value, 'issues')));
      });

  @override
  Future<RoutineMutationResult<RoutineSubmission>> submitDraft(
    String routineId,
    int expectedRevision,
    String idempotencyKey,
  ) => _mutation(
    'submit_routine_v1',
    <String, Object?>{
      'p_routine_draft_id': routineId,
      'p_expected_revision': expectedRevision,
      'p_idempotency_key': idempotencyKey,
    },
    (envelope) => getSubmission(_requiredString(envelope, 'submissionId')),
  );

  @override
  Future<List<RoutineSubmission>> listReviewQueue() async => _guard(() async {
    final value = await _remote.call('list_routine_review_queue_v1', const <String, Object?>{});
    return _list(value, 'items').map((item) => _submission(_map(item))).toList(growable: false);
  });

  @override
  Future<RoutineSubmission> getSubmission(String submissionId) => _guard(() async {
    final value = await _remote.call('get_routine_submission_v1', <String, Object?>{
      'p_submission_id': submissionId,
    });
    final result = _submission(_object(value));
    if (result.id != submissionId) throw const FormatException('Mismatched submission.');
    return result;
  });

  @override
  Future<RoutineMutationResult<RoutineSubmission>> approve(
    String submissionId,
    String? note,
    String idempotencyKey,
  ) => _review('approve_routine_submission_v1', submissionId, note, idempotencyKey);

  @override
  Future<RoutineMutationResult<RoutineSubmission>> reject(
    String submissionId,
    String note,
    String idempotencyKey,
  ) => _review('reject_routine_submission_v1', submissionId, note, idempotencyKey);

  Future<RoutineMutationResult<RoutineSubmission>> _review(
    String function,
    String submissionId,
    String? note,
    String idempotencyKey,
  ) => _mutation(
    function,
    <String, Object?>{
      'p_submission_id': submissionId,
      function.startsWith('reject') ? 'p_reason' : 'p_note': note,
      'p_idempotency_key': idempotencyKey,
    },
    (_) => getSubmission(submissionId),
  );

  @override
  Future<RoutineMutationResult<RoutineVersion>> publish(
    String submissionId,
    DateTime effectiveDate,
    String idempotencyKey,
  ) => _mutation(
    'publish_approved_routine_submission_v1',
    <String, Object?>{
      'p_submission_id': submissionId,
      'p_effective_date': _dateOnly(effectiveDate),
      'p_idempotency_key': idempotencyKey,
    },
    (envelope) => getVersion(
      _requiredString(envelope, 'routineDraftId'),
      _requiredString(envelope, 'routineVersionId'),
    ),
  );

  @override
  Future<List<RoutineVersion>> listVersions(String routineId) async => _guard(() async {
    final value = await _remote.call('list_routine_versions_v1', <String, Object?>{
      'p_routine_draft_id': routineId,
    });
    return _list(value, 'items').map((item) => _version(_map(item))).toList(growable: false);
  });

  @override
  Future<RoutineVersion> getVersion(String routineId, String versionId) => _guard(() async {
    final value = await _remote.call('get_routine_version_v1', <String, Object?>{
      'p_version_id': versionId,
    });
    final result = _version(_object(value));
    if (result.id != versionId || result.routineDraftId != routineId) {
      throw const FormatException('Mismatched routine version.');
    }
    return result;
  });

  @override
  Future<RoutineMutationResult<RoutineDraft>> duplicateVersion(
    String routineId,
    String versionId,
    String name,
    String idempotencyKey,
  ) => _mutation(
    'duplicate_routine_version_as_draft_v1',
    <String, Object?>{
      'p_version_id': versionId,
      'p_name': name,
      'p_idempotency_key': idempotencyKey,
    },
    (envelope) => getDraft(_requiredString(envelope, 'routineDraftId')),
  );

  Future<RoutineMutationResult<T>> _mutation<T>(
    String function,
    Map<String, Object?> params,
    Future<T> Function(Map<String, Object?>) load,
  ) => _guard(() async {
    final value = await _remote.call(function, params);
    return RoutineMutationResult<T>(
      value: await load(value),
      correlationId: _requiredString(value, 'correlationId'),
      replayed: _requiredBool(value, 'replayed'),
    );
  });
}

Future<T> _guard<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on RoutineFailure {
    rethrow;
  } on PostgrestException catch (error) {
    final detail = _detail(error.details);
    throw RoutineFailure(
      error.code == '40001' ? 'stale_revision' : error.code ?? 'server_error',
      correlationId: detail['correlationId'] as String?,
      currentRevision: detail['currentRevision'] as int? ?? detail['routineDraftRevision'] as int?,
    );
  }
}

Map<String, Object?> _detail(Object? value) {
  if (value is Map<Object?, Object?>) return _map(value);
  if (value is String && value.length <= 2048) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<Object?, Object?>) return _map(decoded);
    } on FormatException {
      return const <String, Object?>{};
    }
  }
  return const <String, Object?>{};
}

RoutineDraft _draft(Map<String, Object?> value) => RoutineDraft(
  id: _requiredString(value, 'id'),
  ownerId: _requiredString(value, 'ownerId'),
  name: _requiredString(value, 'name'),
  description: value['description'] as String?,
  status: _status(_requiredString(value, 'status')),
  revision: _requiredInt(value, 'revision'),
  days: _list(value, 'days').map((item) => _day(_map(item))),
  baseVersionId: value['baseVersionId'] as String?,
  latestSubmissionId: value['latestSubmissionId'] as String?,
  createdAt: DateTime.parse(_requiredString(value, 'createdAt')),
  updatedAt: DateTime.parse(_requiredString(value, 'updatedAt')),
);

RoutineSummary _summary(Map<String, Object?> value) => RoutineSummary(
  id: _requiredString(value, 'id'),
  name: _requiredString(value, 'name'),
  status: _status(_requiredString(value, 'status')),
  revision: _requiredInt(value, 'revision'),
  updatedAt: DateTime.parse(_requiredString(value, 'updatedAt')),
  latestVersionId: value['latestVersionId'] as String?,
  latestVersionNumber: value['latestVersionNumber'] as int?,
);

RoutineDay _day(Map<String, Object?> value) => RoutineDay(
  id: _requiredString(value, 'id'),
  dayIndex: _requiredInt(value, 'dayIndex'),
  kind: _requiredString(value, 'kind') == 'rest' ? RoutineDayKind.rest : RoutineDayKind.workout,
  title: value['title'] as String? ?? '',
  purpose: value['purpose'] as String?,
  prescriptions: _list(value, 'prescriptions').map((item) => _prescription(_map(item))),
);

RoutinePrescription _prescription(Map<String, Object?> value) => RoutinePrescription(
  id: _requiredString(value, 'id'),
  exerciseId: _requiredString(value, 'exerciseId'),
  guidanceRevisionId: _requiredString(value, 'guidanceRevisionId'),
  position: _requiredInt(value, 'position'),
  sets: _requiredInt(value, 'sets'),
  minReps: _requiredInt(value, 'minReps'),
  maxReps: _requiredInt(value, 'maxReps'),
  rir: _requiredInt(value, 'rir'),
  restSeconds: _requiredInt(value, 'restSeconds'),
  priority: _requiredBool(value, 'priority'),
  loadUnit: value['loadUnit'] as String?,
  notes: value['notes'] as String?,
);

RoutineSubmission _submission(Map<String, Object?> value) => RoutineSubmission(
  id: _requiredString(value, 'id'),
  routineDraftId: _requiredString(value, 'routineDraftId'),
  ownerId: _requiredString(value, 'ownerId'),
  routineName: _requiredString(value, 'routineName'),
  draftRevision: _requiredInt(value, 'draftRevision'),
  status: _status(_requiredString(value, 'status')),
  submittedAt: DateTime.parse(_requiredString(value, 'submittedAt')),
  description: value['description'] as String?,
  days: _optionalList(value['days']).map((item) => _day(_map(item))),
  validationIssues: _decodeIssues(_optionalList(value['validationIssues'])),
  reviewedAt: _optionalDate(value['reviewedAt']),
  reviewNote: value['reviewNote'] as String?,
);

RoutineVersion _version(Map<String, Object?> value) => RoutineVersion(
  id: _requiredString(value, 'id'),
  routineDraftId: _requiredString(value, 'routineDraftId'),
  ownerId: _requiredString(value, 'ownerId'),
  versionNumber: _requiredInt(value, 'versionNumber'),
  name: _requiredString(value, 'name'),
  description: value['description'] as String?,
  days: _optionalList(value['days']).map((item) => _day(_map(item))),
  contentHash: _requiredString(value, 'contentHash'),
  publishedAt: DateTime.parse(_requiredString(value, 'publishedAt')),
  effectiveDate: DateTime.parse(_requiredString(value, 'effectiveDate')),
);

Iterable<RoutineValidationIssue> _decodeIssues(List<Object?> values) => values.map((item) {
  final value = _map(item);
  return RoutineValidationIssue(
    code: _requiredString(value, 'code'),
    path: _requiredString(value, 'path'),
  );
});

RoutineDraftStatus _status(String value) => RoutineDraftStatus.values.firstWhere(
  (item) => item.name == value,
  orElse: () => throw const FormatException('Unknown routine status.'),
);

String _dateOnly(DateTime value) => value.toUtc().toIso8601String().split('T').first;
DateTime? _optionalDate(Object? value) => value is String ? DateTime.parse(value) : null;
Map<String, Object?> _object(Map<String, Object?> value) =>
    value['item'] == null ? value : _map(value['item']);
List<Object?> _list(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! List<Object?>) throw FormatException('Expected $key list.');
  return item;
}

List<Object?> _optionalList(Object? value) => value is List<Object?> ? value : const <Object?>[];
Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) throw const FormatException('Expected object.');
  return <String, Object?>{
    for (final entry in value.entries)
      if (entry.key is String) entry.key! as String: entry.value,
  };
}

String _requiredString(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! String || item.isEmpty) throw FormatException('Expected $key string.');
  return item;
}

int _requiredInt(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! int) throw FormatException('Expected $key integer.');
  return item;
}

bool _requiredBool(Map<String, Object?> value, String key) {
  final item = value[key];
  if (item is! bool) throw FormatException('Expected $key boolean.');
  return item;
}
