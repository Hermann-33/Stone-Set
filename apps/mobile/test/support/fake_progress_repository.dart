import 'package:stone_set_domain/progress.dart';

final class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository({ProgressSnapshot? snapshot})
    : snapshot = snapshot ?? defaultProgressSnapshot;

  ProgressSnapshot snapshot;

  @override
  Future<ProgressSnapshot> getProgress() async => snapshot;
}

final defaultProgressSnapshot = ProgressSnapshot(
  account: const RankAccount(
    userId: '00000000-0000-4000-8000-000000000001',
    rrBalance: 1910,
    lifetimeXp: 4860,
    rankId: 'platinum_ii',
    currentMinimum: 1775,
    activeConsistencyMultiplier: 1,
    nextRankId: 'platinum_iii',
    nextMinimum: 2075,
    progress: 0.45,
  ),
  ranks: const <RankDefinition>[
    RankDefinition(id: 'bronze_i', displayName: 'Bronze I', minimumRr: 0),
    RankDefinition(
      id: 'platinum_ii',
      displayName: 'Platinum II',
      minimumRr: 1775,
    ),
    RankDefinition(
      id: 'platinum_iii',
      displayName: 'Platinum III',
      minimumRr: 2075,
    ),
    RankDefinition(id: 'adonis', displayName: 'Adonis', minimumRr: 5500),
  ],
  transactions: <ProgressTransaction>[
    ProgressTransaction(
      id: '10000000-0000-4000-8000-000000000001',
      kind: ProgressTransactionKind.rr,
      sourceType: 'workout_reward',
      sourceId: '20000000-0000-4000-8000-000000000001',
      delta: 20,
      createdAt: DateTime.utc(2026, 8, 10, 2),
    ),
  ],
  workouts: <WorkoutHistoryItem>[
    WorkoutHistoryItem(
      resultId: '30000000-0000-4000-8000-000000000001',
      planItemId: 'item-1',
      date: DateTime.utc(2026, 8, 10),
      status: WorkoutHistoryStatus.completed,
      plannedSets: 12,
      completedSets: 12,
      submittedAt: DateTime.utc(2026, 8, 10, 2),
    ),
  ],
);
