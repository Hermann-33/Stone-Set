import 'dart:collection';

enum RoutineDraftStatus { draft, submitted, approved, rejected, published, archived }

enum RoutineDayKind { workout, rest }

final class RoutinePrescription {
  const RoutinePrescription({
    required this.id,
    required this.exerciseId,
    required this.guidanceRevisionId,
    required this.position,
    required this.sets,
    required this.minReps,
    required this.maxReps,
    required this.rir,
    required this.restSeconds,
    required this.priority,
    required this.loadUnit,
    required this.notes,
  });

  final String id;
  final String exerciseId;
  final String guidanceRevisionId;
  final int position;
  final int sets;
  final int minReps;
  final int maxReps;
  final int rir;
  final int restSeconds;
  final bool priority;
  final String? loadUnit;
  final String? notes;
}

final class RoutineDay {
  RoutineDay({
    required this.id,
    required this.dayIndex,
    required this.kind,
    required this.title,
    required this.purpose,
    Iterable<RoutinePrescription> prescriptions = const <RoutinePrescription>[],
  }) : prescriptions = UnmodifiableListView<RoutinePrescription>(
         List<RoutinePrescription>.of(prescriptions),
       );

  final String id;
  final int dayIndex;
  final RoutineDayKind kind;
  final String title;
  final String? purpose;
  final List<RoutinePrescription> prescriptions;
}

final class RoutineDraft {
  RoutineDraft({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.status,
    required this.revision,
    required Iterable<RoutineDay> days,
    required this.createdAt,
    required this.updatedAt,
    this.baseVersionId,
    this.latestSubmissionId,
  }) : days = UnmodifiableListView<RoutineDay>(List<RoutineDay>.of(days));

  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final RoutineDraftStatus status;
  final int revision;
  final List<RoutineDay> days;
  final String? baseVersionId;
  final String? latestSubmissionId;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class RoutineSummary {
  const RoutineSummary({
    required this.id,
    required this.name,
    required this.status,
    required this.revision,
    required this.updatedAt,
    this.latestVersionId,
    this.latestVersionNumber,
  });

  final String id;
  final String name;
  final RoutineDraftStatus status;
  final int revision;
  final DateTime updatedAt;
  final String? latestVersionId;
  final int? latestVersionNumber;
}

final class RoutineValidationIssue {
  const RoutineValidationIssue({required this.code, required this.path});

  final String code;
  final String path;
}

final class RoutineValidationResult {
  RoutineValidationResult(Iterable<RoutineValidationIssue> issues)
    : issues = UnmodifiableListView<RoutineValidationIssue>(
        List<RoutineValidationIssue>.of(issues),
      );

  final List<RoutineValidationIssue> issues;
  bool get isValid => issues.isEmpty;
}

final class RoutineSubmission {
  RoutineSubmission({
    required this.id,
    required this.routineDraftId,
    required this.ownerId,
    required this.routineName,
    required this.draftRevision,
    required this.status,
    required this.submittedAt,
    this.description,
    Iterable<RoutineDay> days = const <RoutineDay>[],
    Iterable<RoutineValidationIssue> validationIssues = const <RoutineValidationIssue>[],
    this.reviewedAt,
    this.reviewNote,
  }) : days = UnmodifiableListView<RoutineDay>(List<RoutineDay>.of(days)),
       validationIssues = UnmodifiableListView<RoutineValidationIssue>(
         List<RoutineValidationIssue>.of(validationIssues),
       );

  final String id;
  final String routineDraftId;
  final String ownerId;
  final String routineName;
  final int draftRevision;
  final RoutineDraftStatus status;
  final DateTime submittedAt;
  final String? description;
  final List<RoutineDay> days;
  final List<RoutineValidationIssue> validationIssues;
  final DateTime? reviewedAt;
  final String? reviewNote;
}

final class RoutineVersion {
  RoutineVersion({
    required this.id,
    required this.routineDraftId,
    required this.ownerId,
    required this.versionNumber,
    required this.name,
    required this.description,
    required Iterable<RoutineDay> days,
    required this.contentHash,
    required this.publishedAt,
    required this.effectiveDate,
  }) : days = UnmodifiableListView<RoutineDay>(List<RoutineDay>.of(days));

  final String id;
  final String routineDraftId;
  final String ownerId;
  final int versionNumber;
  final String name;
  final String? description;
  final List<RoutineDay> days;
  final String contentHash;
  final DateTime publishedAt;
  final DateTime effectiveDate;
}

final class RoutineMutationResult<T> {
  const RoutineMutationResult({
    required this.value,
    required this.correlationId,
    required this.replayed,
  });

  final T value;
  final String correlationId;
  final bool replayed;
}

final class RoutineFailure implements Exception {
  const RoutineFailure(this.code, {this.correlationId, this.currentRevision});

  final String code;
  final String? correlationId;
  final int? currentRevision;
}
