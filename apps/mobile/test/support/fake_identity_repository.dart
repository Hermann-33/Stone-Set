import 'dart:async';

import 'package:stone_set_domain/identity.dart';

const syntheticUserId = '00000000-0000-4000-8000-000000000001';

final class FakeIdentityRepository implements IdentityRepository {
  FakeIdentityRepository({
    IdentitySession? initialSession,
    IdentityBootstrap? bootstrap,
    this.signInFailure,
    this.signInGate,
    this.recoverGate,
    this.userId = syntheticUserId,
  }) : _session = initialSession,
       _bootstrap = bootstrap ?? syntheticBootstrap(userId: userId);

  final _events = StreamController<IdentityAuthEvent>.broadcast();
  final IdentityFailure? signInFailure;
  final Completer<void>? signInGate;
  final Completer<void>? recoverGate;
  final String userId;
  IdentitySession? _session;
  IdentityBootstrap _bootstrap;
  var signInCalls = 0;
  var signOutCalls = 0;
  var passwordChangeCalls = 0;

  @override
  Stream<IdentityAuthEvent> get authEvents => _events.stream;

  @override
  Future<IdentitySession?> recoverSession() async {
    await recoverGate?.future;
    return _session;
  }

  @override
  Future<IdentitySession> refreshSession() async {
    final session = _session;
    if (session == null) {
      throw const IdentityFailure(IdentityErrorCode.sessionExpired);
    }
    return session;
  }

  @override
  Future<void> signIn({required NormalizedUsername username, required String password}) async {
    signInCalls += 1;
    await signInGate?.future;
    final failure = signInFailure;
    if (failure != null) {
      throw failure;
    }
    _session = IdentitySession(
      userId: userId,
      expiresAt: null,
    );
  }

  @override
  Future<IdentityBootstrap> bootstrap() async => _bootstrap;

  @override
  Future<IdentityBootstrap> completeRequiredPasswordChange(String newPassword) async {
    passwordChangeCalls += 1;
    _bootstrap = syntheticBootstrap();
    return _bootstrap;
  }

  @override
  Future<void> signOut({IdentitySignOutScope scope = IdentitySignOutScope.local}) async {
    signOutCalls += 1;
    _session = null;
  }

  void emit(IdentityAuthEvent event) => _events.add(event);

  void replaceAuthenticatedUser(String replacementUserId) {
    final replacement = IdentitySession(userId: replacementUserId, expiresAt: null);
    _session = replacement;
    _bootstrap = syntheticBootstrap(userId: replacementUserId);
    emit(
      IdentityAuthEvent(
        IdentityAuthEventType.tokenRefreshed,
        session: replacement,
      ),
    );
  }

  Future<void> close() => _events.close();
}

IdentityBootstrap syntheticBootstrap({
  String userId = syntheticUserId,
  bool active = true,
  bool mustChangePassword = false,
  bool maintenance = false,
  bool compatible = true,
  bool readOnly = false,
}) {
  return IdentityBootstrap(
    profile: IdentityProfile(
      userId: userId,
      normalizedUsername: 'member_one',
      displayName: 'Member One',
      active: active,
      mustChangePassword: mustChangePassword,
      rewardTimezone: 'Etc/UTC',
    ),
    preferences: const IdentityPreferences(
      loadUnit: 'kg',
      appearanceMode: 'system',
      reducedMotion: false,
      hapticsEnabled: true,
      locale: 'en',
    ),
    compatibility: IdentityCompatibility(
      maintenanceMode: maintenance,
      readOnlyMode: readOnly,
      clientCompatible: compatible,
    ),
    serverTime: DateTime.utc(2026, 8, 6),
    correlationId: 'synthetic-correlation',
  );
}
