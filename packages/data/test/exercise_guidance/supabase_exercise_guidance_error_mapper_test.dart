import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('maps authorization evidence across PostgREST fields', () {
    final failure = mapSupabaseExerciseGuidanceFailure(
      const PostgrestException(
        message: 'product_identity_not_authorized',
        code: '42501',
        details: 'safe details',
      ),
    );

    expect(failure.code, ExerciseGuidanceErrorCode.forbidden);
    expect(failure.toString(), isNot(contains('safe details')));
  });

  test('maps SQLSTATE conflict, not-found, and invalid-input codes', () {
    expect(
      mapSupabaseExerciseGuidanceFailure(
        const PostgrestException(message: 'stale exercise', code: '40001'),
      ).code,
      ExerciseGuidanceErrorCode.staleRevision,
    );
    expect(
      mapSupabaseExerciseGuidanceFailure(
        const PostgrestException(message: 'missing', code: 'P0002'),
      ).code,
      ExerciseGuidanceErrorCode.notFound,
    );
    expect(
      mapSupabaseExerciseGuidanceFailure(
        const PostgrestException(message: 'bad payload', code: '22023'),
      ).code,
      ExerciseGuidanceErrorCode.invalidInput,
    );
  });

  test('maps network errors without exposing their source text', () {
    final failure = mapSupabaseExerciseGuidanceFailure(Exception('Socket secret endpoint'));

    expect(failure.code, ExerciseGuidanceErrorCode.networkUnavailable);
    expect(failure.toString(), isNot(contains('secret endpoint')));
  });

  test('maps server availability SQLSTATE and PostgREST codes', () {
    expect(
      mapSupabaseExerciseGuidanceFailure(
        const PostgrestException(message: 'query cancelled', code: '57014'),
      ).code,
      ExerciseGuidanceErrorCode.serverUnavailable,
    );
    expect(
      mapSupabaseExerciseGuidanceFailure(
        const PostgrestException(message: 'database unavailable', code: 'PGRST002'),
      ).code,
      ExerciseGuidanceErrorCode.serverUnavailable,
    );
  });

  test('retains only typed safe conflict and correlation evidence', () {
    final failure = mapSupabaseExerciseGuidanceFailure(
      const PostgrestException(
        message: 'stale_guidance_draft_revision',
        code: '40001',
        details: <String, Object?>{
          'correlationId': 'safe-correlation',
          'exerciseRevision': 3,
          'draftRevision': 7,
          'duplicateExerciseId': 'safe-duplicate',
          'completeGuidanceText': 'must not escape',
        },
      ),
    );

    expect(failure.correlationId, 'safe-correlation');
    expect(failure.conflict?.exerciseRevision, 3);
    expect(failure.conflict?.draftRevision, 7);
    expect(failure.conflict?.duplicateExerciseId, 'safe-duplicate');
    expect(failure.toString(), isNot(contains('must not escape')));
  });

  test('parses PostgREST JSON-string detail through the strict safe allowlist', () {
    final failure = mapSupabaseExerciseGuidanceFailure(
      const PostgrestException(
        message: 'stale_exercise_revision',
        code: '40001',
        details:
            '{"correlationId":"server-correlation","exerciseRevision":8,'
            '"draftRevision":13,"completeGuidanceText":"never expose"}',
      ),
    );

    expect(failure.correlationId, 'server-correlation');
    expect(failure.conflict?.exerciseRevision, 8);
    expect(failure.conflict?.draftRevision, 13);
    expect(failure.toString(), isNot(contains('never expose')));
  });

  test('ignores malformed and wrongly typed detail without throwing', () {
    final malformed = mapSupabaseExerciseGuidanceFailure(
      const PostgrestException(
        message: 'stale_exercise_revision',
        code: '40001',
        details: '{not-json',
      ),
    );
    final unexpected = mapSupabaseExerciseGuidanceFailure(
      const PostgrestException(
        message: 'stale_exercise_revision',
        code: '40001',
        details: '{"correlationId":7,"exerciseRevision":-1,"draftRevision":"9"}',
      ),
    );

    expect(malformed.correlationId, isNull);
    expect(malformed.conflict, isNull);
    expect(unexpected.correlationId, isNull);
    expect(unexpected.conflict, isNull);
  });
}
