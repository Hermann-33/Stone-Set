import 'dart:async';

import 'package:stone_set_domain/identity.dart';

final class FakeIdentityRepository implements IdentityRepository {
  FakeIdentityRepository({
    this.recoveredSession,
    required this.bootstrapResult,
    IdentityBootstrap? completedPasswordBootstrap,
  }) : completedPasswordBootstrap = completedPasswordBootstrap ?? bootstrapResult;

  final StreamController<IdentityAuthEvent> _events =
      StreamController<IdentityAuthEvent>.broadcast();

  IdentitySession? recoveredSession;
  IdentityBootstrap bootstrapResult;
  IdentityBootstrap completedPasswordBootstrap;
  IdentityFailure? signInFailure;
  IdentityFailure? refreshFailure;
  IdentityFailure? bootstrapFailure;
  IdentityFailure? passwordChangeFailure;
  Completer<IdentitySession?>? recoverBlocker;
  Completer<void>? signInBlocker;
  int signInCalls = 0;
  int signOutCalls = 0;
  int refreshCalls = 0;
  int bootstrapCalls = 0;
  String? submittedPassword;

  @override
  Stream<IdentityAuthEvent> get authEvents => _events.stream;

  @override
  Future<IdentitySession?> recoverSession() async {
    final blocker = recoverBlocker;
    return blocker == null ? recoveredSession : blocker.future;
  }

  @override
  Future<IdentitySession> refreshSession() async {
    refreshCalls += 1;
    final failure = refreshFailure;
    if (failure != null) {
      throw failure;
    }
    return recoveredSession ?? testSession;
  }

  @override
  Future<void> signIn({required NormalizedUsername username, required String password}) async {
    signInCalls += 1;
    final failure = signInFailure;
    if (failure != null) {
      throw failure;
    }
    await signInBlocker?.future;
    recoveredSession = testSession;
  }

  @override
  Future<IdentityBootstrap> bootstrap() async {
    bootstrapCalls += 1;
    final failure = bootstrapFailure;
    if (failure != null) {
      throw failure;
    }
    return bootstrapResult;
  }

  @override
  Future<IdentityBootstrap> completeRequiredPasswordChange(String newPassword) async {
    submittedPassword = newPassword;
    final failure = passwordChangeFailure;
    if (failure != null) {
      throw failure;
    }
    bootstrapResult = completedPasswordBootstrap;
    return completedPasswordBootstrap;
  }

  @override
  Future<void> signOut({IdentitySignOutScope scope = IdentitySignOutScope.local}) async {
    signOutCalls += 1;
    recoveredSession = null;
  }

  void emit(IdentityAuthEvent event) => _events.add(event);

  Future<void> dispose() => _events.close();
}

final testSession = IdentitySession(
  userId: '00000000-0000-4000-8000-000000000001',
  expiresAt: DateTime.utc(2026, 8, 7),
);

IdentityBootstrap testBootstrap({
  bool mustChangePassword = false,
  bool active = true,
  bool maintenance = false,
  bool compatible = true,
  bool readOnly = false,
}) {
  return IdentityBootstrap(
    profile: IdentityProfile(
      userId: testSession.userId,
      normalizedUsername: 'test_user',
      displayName: 'Test User',
      active: active,
      mustChangePassword: mustChangePassword,
      rewardTimezone: 'UTC',
    ),
    preferences: const IdentityPreferences(
      loadUnit: 'kg',
      appearanceMode: 'system',
      reducedMotion: false,
      hapticsEnabled: false,
      locale: 'en',
    ),
    compatibility: IdentityCompatibility(
      maintenanceMode: maintenance,
      readOnlyMode: readOnly,
      clientCompatible: compatible,
      messageText: maintenance ? 'Scheduled maintenance is active.' : null,
    ),
    serverTime: DateTime.utc(2026, 8, 6),
    correlationId: 'test-correlation-id',
  );
}
