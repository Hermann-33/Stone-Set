import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/exercise_media.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('retains only safe typed map conflict evidence', () {
    final failure = mapSupabaseExerciseMediaFailure(
      const PostgrestException(
        message: 'stale_media_revision',
        code: '40001',
        details: <String, Object?>{
          'correlationId': 'correlation-1',
          'exerciseRevision': 3,
          'draftRevision': 4,
          'mediaRevision': 5,
          'privateObjectPath': 'must-not-escape',
        },
      ),
    );

    expect(failure.code, ExerciseMediaErrorCode.staleRevision);
    expect(failure.correlationId, 'correlation-1');
    expect(failure.conflict?.exerciseRevision, 3);
    expect(failure.conflict?.draftRevision, 4);
    expect(failure.conflict?.mediaRevision, 5);
    expect(failure.toString(), isNot(contains('must-not-escape')));
  });

  test('parses PostgREST JSON-string conflict detail through a strict allowlist', () {
    final failure = mapSupabaseExerciseMediaFailure(
      const PostgrestException(
        message: 'stale_media_revision',
        code: '40001',
        details:
            '{"correlationId":"correlation-2","exerciseRevision":8,'
            '"draftRevision":13,"mediaRevision":21,"signedUrl":"secret"}',
      ),
    );

    expect(failure.correlationId, 'correlation-2');
    expect(failure.conflict?.exerciseRevision, 8);
    expect(failure.conflict?.draftRevision, 13);
    expect(failure.conflict?.mediaRevision, 21);
    expect(failure.toString(), isNot(contains('secret')));
  });

  test('malformed or unexpected detail shapes are ignored safely', () {
    final malformed = mapSupabaseExerciseMediaFailure(
      const PostgrestException(
        message: 'stale_media_revision',
        code: '40001',
        details: '{not-json',
      ),
    );
    final wrongTypes = mapSupabaseExerciseMediaFailure(
      const PostgrestException(
        message: 'stale_media_revision',
        code: '40001',
        details: '{"correlationId":7,"mediaRevision":-1}',
      ),
    );

    expect(malformed.correlationId, isNull);
    expect(malformed.conflict, isNull);
    expect(wrongTypes.correlationId, isNull);
    expect(wrongTypes.conflict, isNull);
  });

  test('maps bounded media-specific error categories without leaking text', () {
    expect(
      mapSupabaseExerciseMediaFailure(
        const PostgrestException(message: 'preview_required', code: 'P0001'),
      ).code,
      ExerciseMediaErrorCode.previewRequired,
    );
    expect(
      mapSupabaseExerciseMediaFailure(
        const PostgrestException(message: 'upload_intent_expired', code: '22023'),
      ).code,
      ExerciseMediaErrorCode.uploadExpired,
    );
    final network = mapSupabaseExerciseMediaFailure(Exception('Socket private endpoint'));
    expect(network.code, ExerciseMediaErrorCode.networkUnavailable);
    expect(network.toString(), isNot(contains('private endpoint')));
  });
}
