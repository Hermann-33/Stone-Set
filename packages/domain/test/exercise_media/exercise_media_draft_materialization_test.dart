import 'package:stone_set_domain/exercise_media.dart';
import 'package:test/test.dart';

void main() {
  test('draft materialization command and result retain immutable evidence', () {
    const command = CreateGuidanceMediaDraftFromRevisionCommand(
      exerciseId: 'exercise-1',
      guidanceRevisionId: 'revision-1',
      expectedExerciseRevision: 4,
      idempotencyKey: 'operation-1',
    );
    const result = CreateGuidanceMediaDraftFromRevisionResult(
      exerciseId: 'exercise-1',
      sourceGuidanceRevisionId: 'revision-1',
      draftId: 'draft-1',
      exerciseRevision: 4,
      draftRevision: 1,
      mediaRevision: 1,
      imageCount: 0,
      youtubeCopied: false,
      reusedPublishedObjects: true,
      replayed: false,
      correlationId: 'correlation-1',
    );

    expect(command.expectedExerciseRevision, 4);
    expect(result.sourceGuidanceRevisionId, command.guidanceRevisionId);
    expect(result.draftId, 'draft-1');
    expect(result.reusedPublishedObjects, isTrue);
  });

  test('existing draft conflict carries only bounded concurrency evidence', () {
    const conflict = ExerciseMediaConflictEvidence(
      draftId: 'draft-1',
      draftRevision: 3,
      mediaRevision: 5,
    );
    const failure = ExerciseMediaFailure(
      ExerciseMediaErrorCode.draftAlreadyExists,
      correlationId: 'correlation-1',
      conflict: conflict,
    );

    expect(failure.conflict?.draftId, 'draft-1');
    expect(failure.conflict?.draftRevision, 3);
    expect(failure.conflict?.mediaRevision, 5);
    expect(failure.toString(), 'ExerciseMediaFailure(draftAlreadyExists)');
  });
}
