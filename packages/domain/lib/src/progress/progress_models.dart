final class RankDefinition {
  const RankDefinition({
    required this.id,
    required this.displayName,
    required this.minimumRr,
  });

  final String id;
  final String displayName;
  final int minimumRr;
}

final class RankAccount {
  const RankAccount({
    required this.userId,
    required this.rrBalance,
    required this.lifetimeXp,
    required this.rankId,
    required this.currentMinimum,
    required this.progress,
    this.nextRankId,
    this.nextMinimum,
  });

  final String userId;
  final int rrBalance;
  final int lifetimeXp;
  final String rankId;
  final int currentMinimum;
  final String? nextRankId;
  final int? nextMinimum;
  final double progress;
}

enum ProgressTransactionKind { rr, xp }

final class ProgressTransaction {
  const ProgressTransaction({
    required this.id,
    required this.kind,
    required this.sourceType,
    required this.sourceId,
    required this.delta,
    required this.createdAt,
  });

  final String id;
  final ProgressTransactionKind kind;
  final String sourceType;
  final String sourceId;
  final int delta;
  final DateTime createdAt;
}

enum WorkoutHistoryStatus { completed, partial }

final class WorkoutHistoryItem {
  const WorkoutHistoryItem({
    required this.resultId,
    required this.planItemId,
    required this.date,
    required this.status,
    required this.plannedSets,
    required this.completedSets,
    required this.submittedAt,
  });

  final String resultId;
  final String planItemId;
  final DateTime date;
  final WorkoutHistoryStatus status;
  final int plannedSets;
  final int completedSets;
  final DateTime submittedAt;
}

final class ProgressSnapshot {
  const ProgressSnapshot({
    required this.account,
    required this.ranks,
    required this.transactions,
    required this.workouts,
  });

  final RankAccount account;
  final List<RankDefinition> ranks;
  final List<ProgressTransaction> transactions;
  final List<WorkoutHistoryItem> workouts;
}

final class ProgressFailure implements Exception {
  const ProgressFailure(this.code);

  final String code;

  @override
  String toString() => 'ProgressFailure($code)';
}
