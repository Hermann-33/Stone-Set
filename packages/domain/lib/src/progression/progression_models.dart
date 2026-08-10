import '../progress/progress_models.dart';

enum ProgressionRecommendationState { increase, hold, protected, override, noData }

enum ProgressCorrectionKind { rr, xp }

final class ProgressionSetting {
  const ProgressionSetting({
    required this.exerciseId,
    required this.progressionProtected,
    required this.painFlagged,
    required this.note,
    this.preferredSubstituteExerciseId,
    this.preferredSubstituteName,
    this.manualNextLoad,
  });

  final String exerciseId;
  final bool progressionProtected;
  final bool painFlagged;
  final String? preferredSubstituteExerciseId;
  final String? preferredSubstituteName;
  final double? manualNextLoad;
  final String note;
}

final class ProgressionRecommendation {
  const ProgressionRecommendation({
    required this.exerciseId,
    required this.exerciseName,
    required this.loadUnit,
    required this.state,
    required this.reason,
    required this.setting,
    this.latestLoad,
    this.suggestedLoad,
  });

  final String exerciseId;
  final String exerciseName;
  final String loadUnit;
  final ProgressionRecommendationState state;
  final double? latestLoad;
  final double? suggestedLoad;
  final String reason;
  final ProgressionSetting setting;
}

final class SubstituteExerciseOption {
  const SubstituteExerciseOption({
    required this.exerciseId,
    required this.exerciseName,
  });

  final String exerciseId;
  final String exerciseName;
}

final class ProgressCorrection {
  const ProgressCorrection({
    required this.id,
    required this.kind,
    required this.delta,
    required this.reason,
    required this.reversed,
    required this.createdAt,
    this.reversesCorrectionId,
  });

  final String id;
  final ProgressCorrectionKind kind;
  final int delta;
  final String reason;
  final String? reversesCorrectionId;
  final bool reversed;
  final DateTime createdAt;

  bool get canReverse => reversesCorrectionId == null && !reversed;
}

final class ProgressionSnapshot {
  const ProgressionSnapshot({
    required this.recommendations,
    required this.substituteOptions,
    required this.corrections,
  });

  final List<ProgressionRecommendation> recommendations;
  final List<SubstituteExerciseOption> substituteOptions;
  final List<ProgressCorrection> corrections;
}

final class ProgressCorrectionResult {
  const ProgressCorrectionResult({
    required this.account,
    required this.correction,
  });

  final RankAccount account;
  final ProgressCorrection correction;
}

final class ProgressionFailure implements Exception {
  const ProgressionFailure(this.code);

  final String code;

  @override
  String toString() => 'ProgressionFailure($code)';
}
