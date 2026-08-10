import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProgressRemoteService {
  Future<Map<String, Object?>> getProgress();
}

final class SupabaseProgressRemoteService implements ProgressRemoteService {
  const SupabaseProgressRemoteService(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, Object?>> getProgress() async => _map(
    await _client.rpc<Object?>('get_progress_v1'),
  );
}

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) {
    throw const FormatException('Expected progress object response.');
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
