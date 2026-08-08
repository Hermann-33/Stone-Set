import 'dart:collection';

import 'exercise_guidance_canonicalizer.dart';
import 'exercise_guidance_models.dart';

enum ExerciseGuidanceValidationCode {
  required,
  tooLong,
  tooManyItems,
  invalidControlCharacter,
  invalidVariantKey,
  invalidEquipmentKey,
  invalidMuscleKey,
  missingPrimaryMuscle,
  duplicateMuscle,
  setupOrExecutionRequired,
  exerciseArchived,
  invalidStructuredContent,
}

final class ExerciseGuidanceValidationIssue {
  const ExerciseGuidanceValidationIssue({
    required this.code,
    required this.field,
    required this.message,
  });

  final ExerciseGuidanceValidationCode code;
  final String field;
  final String message;
}

final class ExerciseGuidanceValidationResult {
  ExerciseGuidanceValidationResult(Iterable<ExerciseGuidanceValidationIssue> issues)
    : issues = UnmodifiableListView<ExerciseGuidanceValidationIssue>(
        List<ExerciseGuidanceValidationIssue>.of(issues),
      );

  final List<ExerciseGuidanceValidationIssue> issues;

  bool get isValid => issues.isEmpty;
}

final class ExerciseGuidanceValidator {
  const ExerciseGuidanceValidator();

  static final RegExp _stableKey = RegExp(r'^[a-z0-9]+(?:_[a-z0-9]+)*$');

  ExerciseGuidanceValidationResult validateExercise({
    required String canonicalName,
    required String? variantKey,
    required List<String> equipmentKeys,
    required List<String> primaryMuscleKeys,
    required List<String> secondaryMuscleKeys,
  }) {
    final issues = <ExerciseGuidanceValidationIssue>[];
    final nameLength = canonicalName.trim().runes.length;
    if (nameLength == 0) {
      issues.add(
        _issue(ExerciseGuidanceValidationCode.required, 'canonicalName', 'Name is required.'),
      );
    } else if (nameLength > 120) {
      issues.add(
        _issue(ExerciseGuidanceValidationCode.tooLong, 'canonicalName', 'Name is too long.'),
      );
    }
    if (ExerciseGuidanceCanonicalizer.containsDisallowedControl(canonicalName)) {
      issues.add(
        _issue(
          ExerciseGuidanceValidationCode.invalidControlCharacter,
          'canonicalName',
          'Name contains a disallowed control character.',
        ),
      );
    }
    if (variantKey != null && (variantKey.length > 64 || !_stableKey.hasMatch(variantKey))) {
      issues.add(
        _issue(
          ExerciseGuidanceValidationCode.invalidVariantKey,
          'variantKey',
          'Variant key is invalid.',
        ),
      );
    }
    if (equipmentKeys.isEmpty || equipmentKeys.length > 10) {
      issues.add(
        _issue(
          ExerciseGuidanceValidationCode.invalidEquipmentKey,
          'equipmentKeys',
          'One to ten equipment keys are required.',
        ),
      );
    }
    final uniqueEquipment = <String>{};
    for (var index = 0; index < equipmentKeys.length; index += 1) {
      final key = equipmentKeys[index];
      if (key.length > 64 || !_stableKey.hasMatch(key) || !uniqueEquipment.add(key)) {
        issues.add(
          _issue(
            ExerciseGuidanceValidationCode.invalidEquipmentKey,
            'equipmentKeys[$index]',
            'Equipment key is invalid.',
          ),
        );
      }
    }
    if (primaryMuscleKeys.isEmpty) {
      issues.add(
        _issue(
          ExerciseGuidanceValidationCode.missingPrimaryMuscle,
          'primaryMuscleKeys',
          'At least one primary muscle is required.',
        ),
      );
    }
    final allMuscles = <String>{};
    for (final key in <String>[...primaryMuscleKeys, ...secondaryMuscleKeys]) {
      if (!_stableKey.hasMatch(key)) {
        issues.add(
          _issue(
            ExerciseGuidanceValidationCode.invalidMuscleKey,
            'muscleKeys',
            'Muscle key is invalid.',
          ),
        );
      } else if (!allMuscles.add(key)) {
        issues.add(
          _issue(
            ExerciseGuidanceValidationCode.duplicateMuscle,
            'muscleKeys',
            'A muscle cannot appear more than once.',
          ),
        );
      }
    }
    return ExerciseGuidanceValidationResult(issues);
  }

  ExerciseGuidanceValidationResult validateContent(GuidanceContentV1 content) {
    final issues = <ExerciseGuidanceValidationIssue>[];
    _validateString(
      content.shortExplanation,
      field: 'shortExplanation',
      maximumLength: 2000,
      issues: issues,
    );
    _validateList(content.setupSteps, field: 'setupSteps', issues: issues);
    _validateList(content.executionSteps, field: 'executionSteps', issues: issues);
    _validateList(content.techniqueCues, field: 'techniqueCues', issues: issues);
    _validateList(content.commonMistakes, field: 'commonMistakes', issues: issues);
    _validateList(content.safetyNotes, field: 'safetyNotes', issues: issues);
    if (content.setupSteps.isEmpty && content.executionSteps.isEmpty) {
      issues.add(
        _issue(
          ExerciseGuidanceValidationCode.setupOrExecutionRequired,
          'content',
          'At least one setup or execution step is required.',
        ),
      );
    }
    return ExerciseGuidanceValidationResult(issues);
  }

  void _validateList(
    List<String> values, {
    required String field,
    required List<ExerciseGuidanceValidationIssue> issues,
  }) {
    if (values.length > 50) {
      issues.add(
        _issue(
          ExerciseGuidanceValidationCode.tooManyItems,
          field,
          'The list contains too many items.',
        ),
      );
    }
    for (var index = 0; index < values.length; index += 1) {
      _validateString(values[index], field: '$field[$index]', maximumLength: 500, issues: issues);
    }
  }

  void _validateString(
    String value, {
    required String field,
    required int maximumLength,
    required List<ExerciseGuidanceValidationIssue> issues,
  }) {
    if (value.trim().isEmpty) {
      issues.add(_issue(ExerciseGuidanceValidationCode.required, field, 'Value is required.'));
    } else if (value.runes.length > maximumLength) {
      issues.add(_issue(ExerciseGuidanceValidationCode.tooLong, field, 'Value is too long.'));
    }
    if (ExerciseGuidanceCanonicalizer.containsDisallowedControl(value)) {
      issues.add(
        _issue(
          ExerciseGuidanceValidationCode.invalidControlCharacter,
          field,
          'Value contains a disallowed control character.',
        ),
      );
    }
  }

  ExerciseGuidanceValidationIssue _issue(
    ExerciseGuidanceValidationCode code,
    String field,
    String message,
  ) => ExerciseGuidanceValidationIssue(code: code, field: field, message: message);
}
