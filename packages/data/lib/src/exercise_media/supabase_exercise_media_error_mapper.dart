import 'dart:convert';

import 'package:stone_set_domain/exercise_media.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

ExerciseMediaFailure mapSupabaseExerciseMediaFailure(Object error) {
  if (error is ExerciseMediaFailure) {
    return error;
  }
  if (error is FormatException || error is TypeError) {
    return const ExerciseMediaFailure(ExerciseMediaErrorCode.unknown);
  }
  final evidence = switch (error) {
    final PostgrestException exception => <Object?>[
      exception.code,
      exception.message,
      exception.details,
      exception.hint,
    ].whereType<Object>().join(' ').toLowerCase(),
    final StorageException exception => <Object?>[
      exception.statusCode,
      exception.error,
      exception.message,
    ].whereType<Object>().join(' ').toLowerCase(),
    _ => error.toString().toLowerCase(),
  };
  final code = switch (evidence) {
    final value when value.contains('preview_required') => ExerciseMediaErrorCode.previewRequired,
    final value
        when value.contains('upload_intent_expired') || value.contains('reservation_expired') =>
      ExerciseMediaErrorCode.uploadExpired,
    final value when value.contains('stale_') || value.contains('40001') =>
      ExerciseMediaErrorCode.staleRevision,
    final value
        when value.contains('already exists') ||
            value.contains('duplicate') ||
            (error is StorageException && error.statusCode == '409') =>
      ExerciseMediaErrorCode.uploadConflict,
    final value when value.contains('_not_found') || value.contains('p0002') =>
      ExerciseMediaErrorCode.notFound,
    final value when value.contains('inactive_profile') => ExerciseMediaErrorCode.inactiveProfile,
    final value when value.contains('password_change_required') =>
      ExerciseMediaErrorCode.passwordChangeRequired,
    final value when value.contains('session_expired') || value.contains('jwt') =>
      ExerciseMediaErrorCode.sessionExpired,
    final value
        when value.contains('42501') ||
            value.contains('permission denied') ||
            (error is StorageException &&
                (error.statusCode == '401' || error.statusCode == '403')) =>
      ExerciseMediaErrorCode.forbidden,
    final value when value.contains('22023') || value.contains('invalid_') =>
      ExerciseMediaErrorCode.invalidInput,
    final value
        when value.contains('57014') ||
            value.contains('57p01') ||
            value.contains('53300') ||
            value.contains('pgrst00') ||
            (error is StorageException && error.statusCode?.startsWith('5') == true) =>
      ExerciseMediaErrorCode.serverUnavailable,
    final value
        when value.contains('socket') ||
            value.contains('network') ||
            value.contains('connection') ||
            value.contains('timeout') =>
      ExerciseMediaErrorCode.networkUnavailable,
    _ => ExerciseMediaErrorCode.unknown,
  };
  final details = error is PostgrestException ? _safeDetails(error.details) : null;
  final exerciseRevision = details?['exerciseRevision'];
  final draftRevision = details?['draftRevision'];
  final mediaRevision = details?['mediaRevision'];
  final conflict = exerciseRevision is int || draftRevision is int || mediaRevision is int
      ? ExerciseMediaConflictEvidence(
          exerciseRevision: exerciseRevision is int ? exerciseRevision : null,
          draftRevision: draftRevision is int ? draftRevision : null,
          mediaRevision: mediaRevision is int ? mediaRevision : null,
        )
      : null;
  final correlationId = details?['correlationId'];
  return ExerciseMediaFailure(
    code,
    correlationId: correlationId is String ? correlationId : null,
    conflict: conflict,
  );
}

Map<String, Object?>? _safeDetails(Object? value) {
  final Object? decoded;
  if (value is String) {
    if (value.length > 4096) {
      return null;
    }
    try {
      decoded = jsonDecode(value);
    } on FormatException {
      return null;
    }
  } else {
    decoded = value;
  }
  if (decoded is! Map<Object?, Object?>) {
    return null;
  }
  final correlationId = decoded['correlationId'];
  final exerciseRevision = decoded['exerciseRevision'];
  final draftRevision = decoded['draftRevision'];
  final mediaRevision = decoded['mediaRevision'];
  return <String, Object?>{
    if (correlationId is String && correlationId.isNotEmpty) 'correlationId': correlationId,
    if (exerciseRevision is int && exerciseRevision >= 0) 'exerciseRevision': exerciseRevision,
    if (draftRevision is int && draftRevision >= 0) 'draftRevision': draftRevision,
    if (mediaRevision is int && mediaRevision >= 0) 'mediaRevision': mediaRevision,
  };
}
