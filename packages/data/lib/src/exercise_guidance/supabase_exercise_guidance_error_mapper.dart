import 'dart:convert';

import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

ExerciseGuidanceFailure mapSupabaseExerciseGuidanceFailure(Object error) {
  if (error is ExerciseGuidanceFailure) {
    return error;
  }
  final evidence = switch (error) {
    final PostgrestException exception => <Object?>[
      exception.code,
      exception.message,
      exception.details,
      exception.hint,
    ].whereType<Object>().join(' ').toLowerCase(),
    _ => error.toString().toLowerCase(),
  };
  final code = switch (evidence) {
    final value when value.contains('duplicate_exercise_confirmation_required') =>
      ExerciseGuidanceErrorCode.duplicateConfirmationRequired,
    final value when value.contains('stale_') || value.contains('40001') =>
      ExerciseGuidanceErrorCode.staleRevision,
    final value when value.contains('_not_found') || value.contains('p0002') =>
      ExerciseGuidanceErrorCode.notFound,
    final value when value.contains('inactive_profile') =>
      ExerciseGuidanceErrorCode.inactiveProfile,
    final value when value.contains('password_change_required') =>
      ExerciseGuidanceErrorCode.passwordChangeRequired,
    final value when value.contains('session_expired') || value.contains('jwt') =>
      ExerciseGuidanceErrorCode.sessionExpired,
    final value
        when value.contains('42501') ||
            value.contains('permission denied') ||
            value.contains('product_identity_not_authorized') =>
      ExerciseGuidanceErrorCode.forbidden,
    final value when value.contains('22023') || value.contains('invalid_') =>
      ExerciseGuidanceErrorCode.invalidInput,
    final value
        when value.contains('57014') ||
            value.contains('57p01') ||
            value.contains('53300') ||
            value.contains('pgrst000') ||
            value.contains('pgrst001') ||
            value.contains('pgrst002') ||
            value.contains('pgrst003') =>
      ExerciseGuidanceErrorCode.serverUnavailable,
    final value
        when value.contains('socket') ||
            value.contains('network') ||
            value.contains('connection') =>
      ExerciseGuidanceErrorCode.networkUnavailable,
    _ => ExerciseGuidanceErrorCode.unknown,
  };
  final details = error is PostgrestException ? _safeDetails(error.details) : null;
  final exerciseRevision = details?['exerciseRevision'];
  final draftRevision = details?['draftRevision'];
  final duplicateExerciseId = details?['duplicateExerciseId'];
  final conflict = exerciseRevision is int || draftRevision is int || duplicateExerciseId is String
      ? ExerciseGuidanceConflictEvidence(
          exerciseRevision: exerciseRevision is int ? exerciseRevision : null,
          draftRevision: draftRevision is int ? draftRevision : null,
          duplicateExerciseId: duplicateExerciseId is String && duplicateExerciseId.isNotEmpty
              ? duplicateExerciseId
              : null,
        )
      : null;
  final correlationId = details?['correlationId'];
  return ExerciseGuidanceFailure(
    code,
    correlationId: correlationId is String && correlationId.isNotEmpty ? correlationId : null,
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
  final duplicateExerciseId = decoded['duplicateExerciseId'];
  return <String, Object?>{
    if (correlationId is String && correlationId.isNotEmpty) 'correlationId': correlationId,
    if (exerciseRevision is int && exerciseRevision >= 0) 'exerciseRevision': exerciseRevision,
    if (draftRevision is int && draftRevision >= 0) 'draftRevision': draftRevision,
    if (duplicateExerciseId is String && duplicateExerciseId.isNotEmpty)
      'duplicateExerciseId': duplicateExerciseId,
  };
}
