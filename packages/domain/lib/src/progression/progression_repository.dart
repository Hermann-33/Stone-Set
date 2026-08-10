import 'progression_models.dart';

abstract interface class ProgressionRepository {
  Future<ProgressionSnapshot> getProgression();

  Future<ProgressionSnapshot> updateSetting({
    required String exerciseId,
    required bool progressionProtected,
    required bool painFlagged,
    required String note,
    String? preferredSubstituteExerciseId,
    double? manualNextLoad,
  });

  Future<ProgressCorrectionResult> applyCorrection({
    required ProgressCorrectionKind kind,
    required int delta,
    required String reason,
  });

  Future<ProgressCorrectionResult> reverseCorrection({
    required String correctionId,
    required String reason,
  });
}
