import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:test/test.dart';

void main() {
  const validator = ExerciseGuidanceValidator();

  test('accepts valid structured guidance', () {
    final result = validator.validateContent(
      GuidanceContentV1(
        shortExplanation: 'A stable pressing movement.',
        setupSteps: const <String>['Set the bench.'],
        executionSteps: const <String>['Press under control.'],
      ),
    );

    expect(result.isValid, isTrue);
  });

  test('rejects blank and oversized items and requires setup or execution', () {
    final result = validator.validateContent(
      GuidanceContentV1(
        shortExplanation: '',
        techniqueCues: <String>['', List<String>.filled(501, 'x').join()],
      ),
    );

    expect(
      result.issues.map((issue) => issue.code),
      containsAll(<ExerciseGuidanceValidationCode>[
        ExerciseGuidanceValidationCode.required,
        ExerciseGuidanceValidationCode.tooLong,
        ExerciseGuidanceValidationCode.setupOrExecutionRequired,
      ]),
    );
  });

  test('validates exercise identity, equipment and disjoint muscle roles', () {
    final result = validator.validateExercise(
      canonicalName: 'Press',
      variantKey: 'Not Stable',
      equipmentKeys: const <String>['dumbbell', 'Bad Key'],
      primaryMuscleKeys: const <String>['chest'],
      secondaryMuscleKeys: const <String>['chest'],
    );

    expect(
      result.issues.map((issue) => issue.code),
      containsAll(<ExerciseGuidanceValidationCode>[
        ExerciseGuidanceValidationCode.invalidVariantKey,
        ExerciseGuidanceValidationCode.invalidEquipmentKey,
        ExerciseGuidanceValidationCode.duplicateMuscle,
      ]),
    );
  });

  test('rejects control characters, duplicate equipment and malformed muscle keys', () {
    final result = validator.validateExercise(
      canonicalName: 'Press\u0000',
      variantKey: null,
      equipmentKeys: const <String>['bench', 'bench'],
      primaryMuscleKeys: const <String>['Bad Muscle'],
      secondaryMuscleKeys: const <String>[],
    );

    expect(
      result.issues.map((issue) => issue.code),
      containsAll(<ExerciseGuidanceValidationCode>[
        ExerciseGuidanceValidationCode.invalidControlCharacter,
        ExerciseGuidanceValidationCode.invalidEquipmentKey,
        ExerciseGuidanceValidationCode.invalidMuscleKey,
      ]),
    );
  });

  test('models defensively copy list inputs', () {
    final steps = <String>['Brace'];
    final content = GuidanceContentV1(shortExplanation: 'Explain', setupSteps: steps);
    steps.add('Mutated later');

    expect(content.setupSteps, <String>['Brace']);
    expect(() => content.setupSteps.add('No'), throwsUnsupportedError);
  });
}
