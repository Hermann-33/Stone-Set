import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProgressionRemoteService {
  Future<Map<String, Object?>> getProgression();

  Future<Map<String, Object?>> updateSetting(Map<String, Object?> params);

  Future<Map<String, Object?>> applyCorrection(Map<String, Object?> params);

  Future<Map<String, Object?>> reverseCorrection(Map<String, Object?> params);
}

final class SupabaseProgressionRemoteService implements ProgressionRemoteService {
  const SupabaseProgressionRemoteService(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, Object?>> getProgression() async =>
      _map(await _client.rpc<Object?>('get_progression_v1'));

  @override
  Future<Map<String, Object?>> updateSetting(Map<String, Object?> params) async =>
      _map(await _client.rpc<Object?>('update_progression_setting_v1', params: params));

  @override
  Future<Map<String, Object?>> applyCorrection(Map<String, Object?> params) async =>
      _map(await _client.rpc<Object?>('apply_progress_correction_v1', params: params));

  @override
  Future<Map<String, Object?>> reverseCorrection(Map<String, Object?> params) async =>
      _map(await _client.rpc<Object?>('reverse_progress_correction_v1', params: params));
}

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) {
    throw const FormatException('Expected progression object response.');
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
