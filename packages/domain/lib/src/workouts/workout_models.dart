enum WorkoutSessionState { active, submitted }

enum WorkoutResultStatus { completed, partial }

final class WorkoutSetDraft {
  const WorkoutSetDraft({
    required this.sessionExerciseId,
    required this.setIndex,
    required this.loadUnit,
    required this.completed,
    required this.clientRevision,
    this.loadValue,
    this.repetitions,
    this.rir,
  });

  final String sessionExerciseId;
  final int setIndex;
  final double? loadValue;
  final String loadUnit;
  final int? repetitions;
  final int? rir;
  final bool completed;
  final int clientRevision;

  WorkoutSetDraft copyWith({
    double? loadValue,
    bool clearLoadValue = false,
    String? loadUnit,
    int? repetitions,
    bool clearRepetitions = false,
    int? rir,
    bool clearRir = false,
    bool? completed,
    int? clientRevision,
  }) => WorkoutSetDraft(
    sessionExerciseId: sessionExerciseId,
    setIndex: setIndex,
    loadValue: clearLoadValue ? null : loadValue ?? this.loadValue,
    loadUnit: loadUnit ?? this.loadUnit,
    repetitions: clearRepetitions ? null : repetitions ?? this.repetitions,
    rir: clearRir ? null : rir ?? this.rir,
    completed: completed ?? this.completed,
    clientRevision: clientRevision ?? this.clientRevision,
  );
}

final class WorkoutExercise {
  const WorkoutExercise({
    required this.id,
    required this.position,
    required this.exerciseDefinitionId,
    required this.guidanceRevisionId,
    required this.title,
    required this.priority,
    required this.workingSets,
    required this.repMin,
    required this.repMax,
    required this.rirTarget,
    required this.restSeconds,
    required this.loadUnit,
    required this.notes,
  });

  final String id;
  final int position;
  final String exerciseDefinitionId;
  final String guidanceRevisionId;
  final String title;
  final bool priority;
  final int workingSets;
  final int repMin;
  final int repMax;
  final int rirTarget;
  final int restSeconds;
  final String loadUnit;
  final String notes;
}

final class WorkoutSession {
  WorkoutSession({
    required this.id,
    required this.userId,
    required this.planItemId,
    required this.state,
    required this.startedAt,
    required this.lastClientRevision,
    required Iterable<WorkoutExercise> exercises,
    required Iterable<WorkoutSetDraft> sets,
  }) : exercises = List<WorkoutExercise>.unmodifiable(exercises),
       sets = List<WorkoutSetDraft>.unmodifiable(sets);

  final String id;
  final String userId;
  final String planItemId;
  final WorkoutSessionState state;
  final DateTime startedAt;
  final int lastClientRevision;
  final List<WorkoutExercise> exercises;
  final List<WorkoutSetDraft> sets;

  int get plannedSetCount => exercises.fold<int>(
    0,
    (total, exercise) => total + exercise.workingSets,
  );

  int get completedSetCount => sets.where((set) => set.completed).length;
}

final class WorkoutResult {
  const WorkoutResult({
    required this.id,
    required this.sessionId,
    required this.status,
    required this.plannedSets,
    required this.completedSets,
    required this.submittedAt,
  });

  final String id;
  final String sessionId;
  final WorkoutResultStatus status;
  final int plannedSets;
  final int completedSets;
  final DateTime submittedAt;
}

final class WorkoutLoadResult {
  const WorkoutLoadResult({required this.session, this.result});

  final WorkoutSession session;
  final WorkoutResult? result;
}

final class WorkoutFailure implements Exception {
  const WorkoutFailure(this.code);

  final String code;

  @override
  String toString() => 'WorkoutFailure($code)';
}
