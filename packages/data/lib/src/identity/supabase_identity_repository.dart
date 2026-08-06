import 'package:stone_set_domain/identity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_identity_error_mapper.dart';
import 'user_partitioned_cache.dart';

final class SupabaseIdentityRepository implements IdentityRepository {
  SupabaseIdentityRepository({
    required SupabaseClient client,
    required UsernameAliasMapper aliasMapper,
    required String environment,
    required String clientKind,
    required int clientBuild,
    int schemaContract = 1,
    UserPartitionedCache<Object?>? cache,
  }) : _client = client,
       _aliasMapper = aliasMapper,
       _environment = environment,
       _clientKind = clientKind,
       _clientBuild = clientBuild,
       _schemaContract = schemaContract,
       _cache = cache ?? UserPartitionedCache<Object?>() {
    if (!const <String>{'local', 'staging', 'production'}.contains(environment) ||
        !const <String>{'android', 'dashboard'}.contains(clientKind) ||
        clientBuild < 1 ||
        schemaContract < 1) {
      throw ArgumentError('The identity client context is invalid.');
    }
  }

  final SupabaseClient _client;
  final UsernameAliasMapper _aliasMapper;
  final String _environment;
  final String _clientKind;
  final int _clientBuild;
  final int _schemaContract;
  final UserPartitionedCache<Object?> _cache;

  @override
  Stream<IdentityAuthEvent> get authEvents => _authEvents();

  Stream<IdentityAuthEvent> _authEvents() async* {
    try {
      await for (final state in _client.auth.onAuthStateChange) {
        yield IdentityAuthEvent(
          _mapAuthEvent(state.event),
          session: _mapSession(state.session),
        );
      }
    } on Object catch (error) {
      yield IdentityAuthEvent(
        IdentityAuthEventType.streamError,
        failure: mapSupabaseIdentityFailure(error),
      );
    }
  }

  @override
  Future<IdentitySession?> recoverSession() async => _mapSession(_client.auth.currentSession);

  @override
  Future<IdentitySession> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      final session = _mapSession(response.session);
      if (session == null) {
        throw const IdentityFailure(IdentityErrorCode.sessionExpired);
      }
      return session;
    } on IdentityFailure {
      rethrow;
    } on Object catch (error) {
      throw mapSupabaseIdentityFailure(error, fallback: IdentityErrorCode.sessionExpired);
    }
  }

  @override
  Future<void> signIn({
    required NormalizedUsername username,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: _aliasMapper.map(username),
        password: password,
      );
    } on Object catch (error) {
      throw mapSupabaseIdentityFailure(error, fallback: IdentityErrorCode.invalidCredentials);
    }
  }

  @override
  Future<IdentityBootstrap> bootstrap() async {
    try {
      final response = await _client.rpc(
        'get_authenticated_bootstrap',
        params: <String, Object?>{
          'p_environment': _environment,
          'p_client_kind': _clientKind,
          'p_client_build': _clientBuild,
          'p_schema_contract': _schemaContract,
        },
      );
      final bootstrap = decodeIdentityBootstrapResponse(response);
      _cache.write(
        userId: bootstrap.profile.userId,
        key: 'authenticated_bootstrap',
        value: bootstrap,
      );
      return bootstrap;
    } on IdentityFailure {
      rethrow;
    } on Object catch (error) {
      throw mapSupabaseIdentityFailure(error, fallback: IdentityErrorCode.profileUnavailable);
    }
  }

  @override
  Future<IdentityBootstrap> completeRequiredPasswordChange(String newPassword) async {
    final validation = PasswordPolicy.validate(newPassword);
    if (!validation.isValid) {
      throw const IdentityFailure(IdentityErrorCode.unknown);
    }
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      await _client.rpc('complete_required_password_change');
      return await bootstrap();
    } on IdentityFailure {
      rethrow;
    } on Object catch (error) {
      throw mapSupabaseIdentityFailure(error);
    }
  }

  @override
  Future<void> signOut({IdentitySignOutScope scope = IdentitySignOutScope.local}) async {
    final userId = _client.auth.currentUser?.id;
    try {
      await _client.auth.signOut(scope: _mapSignOutScope(scope));
    } on Object catch (error) {
      throw mapSupabaseIdentityFailure(error);
    } finally {
      if (userId != null) {
        _cache.clearUser(userId);
      }
    }
  }
}

IdentitySession? _mapSession(Session? session) {
  if (session == null) {
    return null;
  }
  final expiresAt = session.expiresAt;
  return IdentitySession(
    userId: session.user.id,
    expiresAt: expiresAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000, isUtc: true),
  );
}

IdentityAuthEventType _mapAuthEvent(AuthChangeEvent event) => switch (event) {
  AuthChangeEvent.initialSession => IdentityAuthEventType.initialSession,
  AuthChangeEvent.signedIn => IdentityAuthEventType.signedIn,
  AuthChangeEvent.signedOut => IdentityAuthEventType.signedOut,
  AuthChangeEvent.passwordRecovery => IdentityAuthEventType.passwordRecovery,
  AuthChangeEvent.tokenRefreshed => IdentityAuthEventType.tokenRefreshed,
  AuthChangeEvent.userUpdated => IdentityAuthEventType.userUpdated,
  AuthChangeEvent.userDeleted => IdentityAuthEventType.userDeleted,
  AuthChangeEvent.mfaChallengeVerified => IdentityAuthEventType.mfaChallengeVerified,
};

SignOutScope _mapSignOutScope(IdentitySignOutScope scope) => switch (scope) {
  IdentitySignOutScope.local => SignOutScope.local,
  IdentitySignOutScope.global => SignOutScope.global,
  IdentitySignOutScope.others => SignOutScope.others,
};

IdentityBootstrap decodeIdentityBootstrapResponse(Object? response) {
  final value = switch (response) {
    final Map<String, Object?> map => map,
    final List<Object?> list when list.length == 1 && list.first is Map<String, Object?> =>
      list.first! as Map<String, Object?>,
    _ => throw const IdentityFailure(IdentityErrorCode.profileUnavailable),
  };
  final state = _requiredString(value, 'state');
  final correlationId = _requiredString(value, 'correlationId');
  final failureCode = switch (state) {
    'session_expired' => IdentityErrorCode.sessionExpired,
    'profile_unavailable' => IdentityErrorCode.profileUnavailable,
    'profile_disabled' => IdentityErrorCode.profileDisabled,
    'server_unavailable' => IdentityErrorCode.serverUnavailable,
    _ => null,
  };
  if (failureCode != null) {
    throw IdentityFailure(failureCode, correlationId: correlationId);
  }
  final profile = _requiredMap(value, 'profile');
  final preferences = _requiredMap(value, 'preferences');
  final compatibility = _requiredMap(value, 'compatibility');
  return IdentityBootstrap(
    profile: IdentityProfile(
      userId: _requiredString(profile, 'id'),
      normalizedUsername: _requiredString(profile, 'username'),
      displayName: _requiredString(profile, 'displayName'),
      active: _requiredBool(profile, 'active'),
      mustChangePassword: _requiredBool(profile, 'mustChangePassword'),
      rewardTimezone: _requiredString(profile, 'rewardTimezone'),
      revision: _requiredInt(profile, 'revision'),
    ),
    preferences: IdentityPreferences(
      loadUnit: _requiredString(preferences, 'loadUnit'),
      appearanceMode: _requiredString(preferences, 'appearanceMode'),
      reducedMotion: _requiredBool(preferences, 'reducedMotion'),
      hapticsEnabled: _requiredBool(preferences, 'hapticsEnabled'),
      locale: _requiredString(preferences, 'locale'),
      restTimerSoundEnabled: _requiredBool(preferences, 'restTimerSoundEnabled'),
      workoutRemindersEnabled: _requiredBool(preferences, 'workoutRemindersEnabled'),
      reminderLocalTime: preferences['reminderLocalTime'] as String?,
      revision: _requiredInt(preferences, 'revision'),
    ),
    compatibility: IdentityCompatibility(
      maintenanceMode: state == 'maintenance',
      readOnlyMode: _requiredBool(value, 'readOnly'),
      clientCompatible: state != 'client_incompatible',
      configVersion: _requiredInt(compatibility, 'configVersion'),
      minimumBuild: _requiredInt(compatibility, 'minimumBuild'),
      recommendedMobileBuild: _requiredInt(compatibility, 'recommendedMobileBuild'),
      messageCode: compatibility['messageCode'] as String?,
      messageText: compatibility['messageText'] as String?,
      features: _stringObjectMap(compatibility['features']),
    ),
    serverTime: DateTime.parse(_requiredString(value, 'serverTime')).toUtc(),
    correlationId: correlationId,
    capabilities: _stringSet(value['capabilities']),
    schemaContract: _requiredInt(value, 'schemaContract'),
  );
}

Set<String> _stringSet(Object? value) {
  if (value is! List<Object?> || value.any((item) => item is! String)) {
    throw const IdentityFailure(IdentityErrorCode.profileUnavailable);
  }
  return Set<String>.unmodifiable(value.cast<String>());
}

Map<String, Object?> _stringObjectMap(Object? value) {
  if (value is! Map<String, Object?>) {
    throw const IdentityFailure(IdentityErrorCode.profileUnavailable);
  }
  return Map<String, Object?>.unmodifiable(value);
}

Map<String, Object?> _requiredMap(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is! Map<String, Object?>) {
    throw const IdentityFailure(IdentityErrorCode.profileUnavailable);
  }
  return value;
}

String _requiredString(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is! String || value.isEmpty) {
    throw const IdentityFailure(IdentityErrorCode.profileUnavailable);
  }
  return value;
}

bool _requiredBool(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is! bool) {
    throw const IdentityFailure(IdentityErrorCode.profileUnavailable);
  }
  return value;
}

int _requiredInt(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is! int) {
    throw const IdentityFailure(IdentityErrorCode.profileUnavailable);
  }
  return value;
}
