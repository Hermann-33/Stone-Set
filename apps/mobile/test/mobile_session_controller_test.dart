import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_mobile/features/identity/controllers/mobile_session_controller.dart';
import 'package:stone_set_mobile/features/identity/providers/identity_providers.dart';
import 'package:stone_set_mobile/features/local/providers/mobile_local_providers.dart';

import 'support/fake_identity_repository.dart';
import 'support/fake_mobile_snapshot_store.dart';

void main() {
  test('restores a verified active session and caches its bootstrap', () async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(initialSession: session);
    final store = FakeMobileSnapshotStore();
    final container = _container(repository, store: store);
    addTearDown(repository.close);
    addTearDown(container.dispose);

    final state = await container.read(mobileSessionControllerProvider.future);

    expect(state.phase, IdentitySessionPhase.authenticated);
    expect(state.userId, syntheticBootstrap().profile.userId);
    expect(store.identityByOwner[syntheticUserId]?.profile.userId, syntheticUserId);
  });

  test('first launch without a persisted session remains signed out', () async {
    final repository = FakeIdentityRepository(
      refreshFailure: const IdentityFailure(IdentityErrorCode.networkUnavailable),
    );
    final store = FakeMobileSnapshotStore();
    final container = _container(repository, store: store);
    addTearDown(repository.close);
    addTearDown(container.dispose);

    final state = await container.read(mobileSessionControllerProvider.future);

    expect(state.phase, IdentitySessionPhase.signedOut);
    expect(state.exposesProtectedContent, isFalse);
  });

  test('matching verified cache renders before any network refresh is attempted', () async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(
      initialSession: session,
      refreshFailure: const IdentityFailure(IdentityErrorCode.networkUnavailable),
    );
    final store = FakeMobileSnapshotStore()
      ..identityByOwner[syntheticUserId] = syntheticBootstrap();
    final container = _container(repository, store: store);
    addTearDown(repository.close);
    addTearDown(container.dispose);

    final state = await container.read(mobileSessionControllerProvider.future);

    expect(state.phase, IdentitySessionPhase.authenticated);
    expect(state.exposesProtectedContent, isTrue);
    expect(state.userId, syntheticUserId);
    expect(state.failure, isNull);
    expect(repository.refreshCalls, 0);
    expect(repository.signOutCalls, 0);
  });

  test('transport failure without matching cache does not expose protected content', () async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(
      initialSession: session,
      refreshFailure: const IdentityFailure(IdentityErrorCode.networkUnavailable),
    );
    final store = FakeMobileSnapshotStore();
    final container = _container(repository, store: store);
    addTearDown(repository.close);
    addTearDown(container.dispose);

    final state = await container.read(mobileSessionControllerProvider.future);

    expect(state.phase, IdentitySessionPhase.recoverableFailure);
    expect(state.exposesProtectedContent, isFalse);
  });

  test('cache for the wrong owner is rejected during offline restoration', () async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(
      initialSession: session,
      refreshFailure: const IdentityFailure(IdentityErrorCode.networkUnavailable),
    );
    final store = FakeMobileSnapshotStore()
      ..identityByOwner[syntheticUserId] = syntheticBootstrap(
        userId: '00000000-0000-4000-8000-000000000002',
      );
    final container = _container(repository, store: store);
    addTearDown(repository.close);
    addTearDown(container.dispose);

    final state = await container.read(mobileSessionControllerProvider.future);

    expect(state.phase, IdentitySessionPhase.recoverableFailure);
    expect(state.exposesProtectedContent, isFalse);
  });

  test('password-change-required cache cannot authorize offline protected content', () async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(
      initialSession: session,
      refreshFailure: const IdentityFailure(IdentityErrorCode.serverUnavailable),
    );
    final store = FakeMobileSnapshotStore()
      ..identityByOwner[syntheticUserId] = syntheticBootstrap(mustChangePassword: true);
    final container = _container(repository, store: store);
    addTearDown(repository.close);
    addTearDown(container.dispose);

    final state = await container.read(mobileSessionControllerProvider.future);

    expect(state.phase, IdentitySessionPhase.recoverableFailure);
    expect(state.exposesProtectedContent, isFalse);
  });

  test('manual logout clears the active session', () async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(initialSession: session);
    final container = _container(repository);
    addTearDown(repository.close);
    addTearDown(container.dispose);
    await container.read(mobileSessionControllerProvider.future);

    final decision = await container.read(mobileSessionControllerProvider.notifier).requestLogout();

    expect(decision, LogoutDecision.logoutNow);
    expect(repository.signOutCalls, 1);
    expect(
      container.read(mobileSessionControllerProvider).value?.phase,
      IdentitySessionPhase.signedOut,
    );
  });

  test('auth stream errors expire the verified session', () async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(initialSession: session);
    final container = _container(repository);
    addTearDown(repository.close);
    addTearDown(container.dispose);
    await container.read(mobileSessionControllerProvider.future);

    repository.emit(
      const IdentityAuthEvent(
        IdentityAuthEventType.streamError,
        failure: IdentityFailure(IdentityErrorCode.sessionExpired),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(mobileSessionControllerProvider).value?.phase,
      IdentitySessionPhase.sessionExpired,
    );
  });

  test('transient auth stream failures keep a verified cached shell exposed', () async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(initialSession: session);
    final quarantine = _RecordingQuarantine();
    final container = _container(repository, quarantine: quarantine);
    addTearDown(repository.close);
    addTearDown(container.dispose);
    await container.read(mobileSessionControllerProvider.future);

    repository.emit(
      const IdentityAuthEvent(
        IdentityAuthEventType.streamError,
        failure: IdentityFailure(IdentityErrorCode.networkUnavailable),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final state = container.read(mobileSessionControllerProvider).value;
    expect(state?.phase, IdentitySessionPhase.authenticated);
    expect(state?.exposesProtectedContent, isTrue);
    expect(state?.failure?.code, IdentityErrorCode.networkUnavailable);
    expect(repository.signOutCalls, 0);
    expect(quarantine.userIds, isEmpty);
  });

  test('involuntary sign-out quarantines user-scoped private work', () async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(initialSession: session);
    final quarantine = _RecordingQuarantine();
    final container = _container(repository, quarantine: quarantine);
    addTearDown(repository.close);
    addTearDown(container.dispose);
    await container.read(mobileSessionControllerProvider.future);

    repository.emit(const IdentityAuthEvent(IdentityAuthEventType.signedOut));
    await Future<void>.delayed(Duration.zero);

    expect(quarantine.userIds, <String>[syntheticUserId]);
    expect(
      container.read(mobileSessionControllerProvider).value?.phase,
      IdentitySessionPhase.signedOut,
    );
  });

  test('password recovery events cannot become normal authenticated sessions', () async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(initialSession: session);
    final quarantine = _RecordingQuarantine();
    final container = _container(repository, quarantine: quarantine);
    addTearDown(repository.close);
    addTearDown(container.dispose);
    await container.read(mobileSessionControllerProvider.future);

    repository.emit(const IdentityAuthEvent(IdentityAuthEventType.passwordRecovery));
    await Future<void>.delayed(Duration.zero);

    expect(quarantine.userIds, <String>[syntheticUserId]);
    expect(
      container.read(mobileSessionControllerProvider).value?.phase,
      IdentitySessionPhase.sessionExpired,
    );
  });

  test('rejects a profile that does not match the authenticated user', () async {
    const session = IdentitySession(
      userId: '00000000-0000-4000-8000-000000000002',
      expiresAt: null,
    );
    final repository = FakeIdentityRepository(initialSession: session);
    final container = _container(repository);
    addTearDown(repository.close);
    addTearDown(container.dispose);

    final state = await container.read(mobileSessionControllerProvider.future);

    expect(state.phase, IdentitySessionPhase.accessDenied);
    expect(state.failure?.code, IdentityErrorCode.profileUnavailable);
    expect(repository.signOutCalls, 1);
  });
}

ProviderContainer _container(
  FakeIdentityRepository repository, {
  PrivateWorkQuarantine? quarantine,
  FakeMobileSnapshotStore? store,
}) {
  return ProviderContainer(
    overrides: [
      identityRepositoryProvider.overrideWithValue(repository),
      mobileSnapshotStoreProvider.overrideWithValue(store ?? FakeMobileSnapshotStore()),
      unsynchronizedPrivateWorkProvider.overrideWithValue(const NoUnsynchronizedPrivateWork()),
      if (quarantine != null) privateWorkQuarantineProvider.overrideWithValue(quarantine),
    ],
  );
}

final class _RecordingQuarantine implements PrivateWorkQuarantine {
  final userIds = <String>[];

  @override
  Future<void> quarantineForSessionLoss(String userId) async {
    userIds.add(userId);
  }
}
