import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SchedulingRemoteService {
  Future<Map<String, Object?>> call(
    String function,
    Map<String, Object?> params,
  );
}

final class SupabaseSchedulingRemoteService implements SchedulingRemoteService {
  const SupabaseSchedulingRemoteService(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, Object?>> call(
    String function,
    Map<String, Object?> params,
  ) async => _map(await _client.rpc<Object?>(function, params: params));
}

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) {
    throw const FormatException('Expected scheduling object response.');
  }
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
