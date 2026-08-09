import 'package:stone_set_domain/routines.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class RoutineRemoteService {
  Future<Map<String, Object?>> call(String function, Map<String, Object?> params);
}

final class SupabaseRoutineRemoteService implements RoutineRemoteService {
  const SupabaseRoutineRemoteService(this._client);
  final SupabaseClient _client;

  @override
  Future<Map<String, Object?>> call(String function, Map<String, Object?> params) async =>
      _map(await _client.rpc<Object?>(function, params: params));
}

Map<String, Object?> routineDraftPayload(RoutineDraft draft) => <String, Object?>{
  'name': draft.name,
  'description': draft.description,
  'days': [
    for (final day in draft.days)
      <String, Object?>{
        'dayIndex': day.dayIndex,
        'kind': day.kind.name,
        'title': day.title,
        'purpose': day.purpose,
        'prescriptions': [
          for (final item in day.prescriptions)
            <String, Object?>{
              'id': item.id.isEmpty ? null : item.id,
              'exerciseId': item.exerciseId,
              'guidanceRevisionId': item.guidanceRevisionId,
              'position': item.position,
              'sets': item.sets,
              'minReps': item.minReps,
              'maxReps': item.maxReps,
              'rir': item.rir,
              'restSeconds': item.restSeconds,
              'priority': item.priority,
              'loadUnit': item.loadUnit,
              'notes': item.notes,
            },
        ],
      },
  ],
};

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) throw const FormatException('Expected object response.');
  return <String, Object?>{
    for (final entry in value.entries)
      if (entry.key is String) entry.key! as String: _json(entry.value),
  };
}

Object? _json(Object? value) => switch (value) {
  final Map<Object?, Object?> map => _map(map),
  final List<Object?> list => list.map(_json).toList(growable: false),
  _ => value,
};
