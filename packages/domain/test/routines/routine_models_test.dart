import 'package:stone_set_domain/routines.dart';
import 'package:test/test.dart';

void main() {
  test('validation is valid only without issues', () {
    expect(RoutineValidationResult(const <RoutineValidationIssue>[]).isValid, isTrue);
    expect(
      RoutineValidationResult(const <RoutineValidationIssue>[
        RoutineValidationIssue(code: 'day_count', path: 'days'),
      ]).isValid,
      isFalse,
    );
  });

  test('routine collections are immutable', () {
    final day = RoutineDay(
      id: 'day',
      dayIndex: 1,
      kind: RoutineDayKind.rest,
      title: 'Rest',
      purpose: null,
    );
    final draft = RoutineDraft(
      id: 'draft',
      ownerId: 'owner',
      name: 'Plan',
      description: null,
      status: RoutineDraftStatus.draft,
      revision: 1,
      days: <RoutineDay>[day],
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    expect(() => draft.days.add(day), throwsUnsupportedError);
  });
}
