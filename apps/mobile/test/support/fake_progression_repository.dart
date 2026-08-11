import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_domain/progression.dart';

final class FakeProgressionRepository implements ProgressionRepository {
  FakeProgressionRepository({ProgressionSnapshot? initial})
    : current = initial ?? standardProgressionSnapshot();

  ProgressionSnapshot current;
  int settingUpdates = 0;
  int correctionCalls = 0;

  @override
  Future<ProgressionSnapshot> getProgression() async => current;

  @override
  Future<ProgressionSnapshot> updateSetting({
    required String exerciseId,
    required bool progressionProtected,
    required bool painFlagged,
    required String note,
    String? preferredSubstituteExerciseId,
    double? manualNextLoad,
  }) async {
    settingUpdates += 1;
    current = ProgressionSnapshot(
      recommendations: <ProgressionRecommendation>[
        for (final recommendation in current.recommendations)
          if (recommendation.exerciseId == exerciseId)
            ProgressionRecommendation(
              exerciseId: recommendation.exerciseId,
              exerciseName: recommendation.exerciseName,
              loadUnit: recommendation.loadUnit,
              state: progressionProtected
                  ? ProgressionRecommendationState.protected
                  : painFlagged
                  ? ProgressionRecommendationState.hold
                  : manualNextLoad != null
                  ? ProgressionRecommendationState.override
                  : recommendation.state,
              latestLoad: recommendation.latestLoad,
              suggestedLoad: manualNextLoad ?? recommendation.suggestedLoad,
              reason: recommendation.reason,
              setting: ProgressionSetting(
                exerciseId: exerciseId,
                progressionProtected: progressionProtected,
                painFlagged: painFlagged,
                preferredSubstituteExerciseId: preferredSubstituteExerciseId,
                preferredSubstituteName: current.substituteOptions
                    .where((option) => option.exerciseId == preferredSubstituteExerciseId)
                    .map((option) => option.exerciseName)
                    .firstOrNull,
                manualNextLoad: manualNextLoad,
                note: note,
              ),
            )
          else
            recommendation,
      ],
      substituteOptions: current.substituteOptions,
      corrections: current.corrections,
    );
    return current;
  }

  @override
  Future<ProgressCorrectionResult> applyCorrection({
    required ProgressCorrectionKind kind,
    required int delta,
    required String reason,
  }) async {
    correctionCalls += 1;
    final correction = ProgressCorrection(
      id: 'correction-$correctionCalls',
      kind: kind,
      delta: delta,
      reason: reason,
      reversed: false,
      createdAt: DateTime.utc(2026, 8, 10, 10),
    );
    current = ProgressionSnapshot(
      recommendations: current.recommendations,
      substituteOptions: current.substituteOptions,
      corrections: <ProgressCorrection>[correction, ...current.corrections],
    );
    return ProgressCorrectionResult(account: _account(), correction: correction);
  }

  @override
  Future<ProgressCorrectionResult> reverseCorrection({
    required String correctionId,
    required String reason,
  }) async {
    correctionCalls += 1;
    final original = current.corrections.firstWhere((item) => item.id == correctionId);
    final reversal = ProgressCorrection(
      id: 'correction-$correctionCalls',
      kind: original.kind,
      delta: -original.delta,
      reason: reason,
      reversesCorrectionId: original.id,
      reversed: false,
      createdAt: DateTime.utc(2026, 8, 10, 11),
    );
    current = ProgressionSnapshot(
      recommendations: current.recommendations,
      substituteOptions: current.substituteOptions,
      corrections: <ProgressCorrection>[
        reversal,
        for (final item in current.corrections)
          if (item.id == original.id)
            ProgressCorrection(
              id: item.id,
              kind: item.kind,
              delta: item.delta,
              reason: item.reason,
              reversed: true,
              createdAt: item.createdAt,
              reversesCorrectionId: item.reversesCorrectionId,
            )
          else
            item,
      ],
    );
    return ProgressCorrectionResult(account: _account(), correction: reversal);
  }
}

ProgressionSnapshot standardProgressionSnapshot() => ProgressionSnapshot(
  recommendations: const <ProgressionRecommendation>[
    ProgressionRecommendation(
      exerciseId: 'exercise-1',
      exerciseName: 'Bench Press',
      loadUnit: 'kg',
      state: ProgressionRecommendationState.increase,
      latestLoad: 80,
      suggestedLoad: 82.5,
      reason: 'All prescribed sets reached the top of the rep range at or above target RIR.',
      setting: ProgressionSetting(
        exerciseId: 'exercise-1',
        progressionProtected: false,
        painFlagged: false,
        note: '',
      ),
    ),
  ],
  substituteOptions: const <SubstituteExerciseOption>[
    SubstituteExerciseOption(exerciseId: 'exercise-1', exerciseName: 'Bench Press'),
    SubstituteExerciseOption(exerciseId: 'exercise-2', exerciseName: 'Dumbbell Press'),
  ],
  corrections: const <ProgressCorrection>[],
);

RankAccount _account() => const RankAccount(
  userId: '00000000-0000-4000-8000-000000000001',
  rrBalance: 1910,
  lifetimeXp: 4860,
  rankId: 'platinum_ii',
  currentMinimum: 1775,
  activeConsistencyMultiplier: 1,
  nextRankId: 'platinum_iii',
  nextMinimum: 2075,
  progress: 0.45,
);

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
