import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stone_set_domain/identity.dart';

import '../../local/providers/mobile_local_providers.dart';
import '../providers/identity_providers.dart';

part 'mobile_session_controller.g.dart';

@Riverpod(keepAlive: true)
class MobileSessionController extends _$MobileSessionController {
  // Riverpod owns this controller's lifecycle; build registers the matching
  // cancellation callback with ref.onDispose below.
  // ignore: cancel_subscriptions
  StreamSubscription<IdentityAuthEvent>? _authSubscription;
  var _readyForAuthEvents = false;
  var _busy = false;
  var _ignoreNextSignedOut = false;

  @override
  Future<IdentitySessionState> build() async {
    final repository = ref.watch(identityRepositoryProvider);
    _authSubscription = repository.authEvents.listen((event) {
      if (_readyForAuthEvents) {
        unawaited(_handleAuthEvent(event));
      }
    });
    ref.onDispose(() {
      final subscription = _authSubscription;
      if (subscription != null) {
        unawaited(subscription.cancel());
      }
    });
    final restored = await _restore(repository);
    _readyForAuthEvents = true;
    return restored;
  }

  Future<void> signIn({
    required NormalizedUsername username,
    required String password,
  }) async {
    if (_busy) {
      return;
    }
    _busy = true;
    state = const AsyncData(
      IdentitySessionState(phase: IdentitySessionPhase.authenticating),
    );
    try {
      final repository = ref.read(identityRepositoryProvider);
      await repository.signIn(username: username, password: password);
      state = AsyncData(await _bootstrap(repository));
    } on Object catch (error) {
      state = AsyncData(
        IdentitySessionState(
          phase: IdentitySessionPhase.signedOut,
          failure: _identityFailure(
            error,
            IdentityErrorCode.invalidCredentials,
          ),
        ),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> changeRequiredPassword(String newPassword) async {
    if (_busy) {
      return;
    }
    _busy = true;
    final previous = _currentState;
    state = const AsyncData(
      IdentitySessionState(phase: IdentitySessionPhase.bootstrapping),
    );
    try {
      final bootstrap = await ref
          .read(identityRepositoryProvider)
          .completeRequiredPasswordChange(newPassword);
      state = AsyncData(
        await _verifiedBootstrapState(
          ref.read(identityRepositoryProvider),
          bootstrap,
        ),
      );
    } on Object catch (error) {
      state = AsyncData(
        IdentitySessionState(
          phase: IdentitySessionPhase.passwordChangeRequired,
          bootstrap: previous.bootstrap,
          failure: _identityFailure(error, IdentityErrorCode.serverUnavailable),
        ),
      );
    } finally {
      _busy = false;
    }
  }

  Future<LogoutDecision> requestLogout() async {
    if (_busy) {
      return LogoutDecision.remainSignedIn;
    }
    final current = _currentState;
    final userId = current.userId;
    if (userId != null &&
        await ref.read(unsynchronizedPrivateWorkProvider).hasUnsynchronizedPrivateWork(userId)) {
      return LogoutDecision.resolutionRequired;
    }
    await _signOut();
    return LogoutDecision.logoutNow;
  }

  Future<void> resolveLogout(LogoutDecision decision) async {
    final userId = _currentState.userId;
    if (userId == null || decision == LogoutDecision.remainSignedIn) {
      return;
    }
    final work = ref.read(unsynchronizedPrivateWorkProvider);
    switch (decision) {
      case LogoutDecision.synchronizeNow:
        if (await work.synchronizeNow(userId)) {
          await _signOut();
        }
        return;
      case LogoutDecision.discardAndLogout:
        await work.discard(userId);
        await _signOut();
        return;
      case LogoutDecision.logoutNow:
        await _signOut();
        return;
      case LogoutDecision.resolutionRequired:
      case LogoutDecision.remainSignedIn:
        return;
    }
  }

  Future<void> foregroundRevalidate() async {
    if (_busy || _currentState.userId == null) {
      return;
    }
    _busy = true;
    try {
      final repository = ref.read(identityRepositoryProvider);
      await repository.refreshSession();
      state = AsyncData(await _bootstrap(repository));
    } on Object catch (error) {
      final failure = _identityFailure(error, IdentityErrorCode.sessionExpired);
      if (_isRecoverableTransportFailure(failure)) {
        _setRecoverableFailure(failure);
      } else {
        await _expireSession(failure);
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> retrySessionCheck() async {
    if (_busy) {
      return;
    }
    _busy = true;
    state = const AsyncData(IdentitySessionState.checking());
    try {
      state = AsyncData(await _restore(ref.read(identityRepositoryProvider)));
    } finally {
      _busy = false;
    }
  }

  Future<IdentitySessionState> _restore(IdentityRepository repository) async {
    IdentitySession? localSession;
    try {
      localSession = await repository.recoverSession();
      if (localSession == null) {
        return const IdentitySessionState.signedOut();
      }
      final cachedAuthenticated = await _loadCachedAuthenticatedState(
        localSession.userId,
      );
      if (cachedAuthenticated != null) {
        // Cached-first startup is deliberate. The authenticated shell renders
        // immediately, then its post-frame synchronization revalidates Auth
        // and refreshes authoritative data without blocking first paint.
        return cachedAuthenticated;
      }
      await repository.refreshSession();
      return _bootstrap(repository, expectedSession: localSession);
    } on Object catch (error) {
      final failure = _identityFailure(error, IdentityErrorCode.sessionExpired);
      if (_isRecoverableTransportFailure(failure)) {
        return IdentitySessionState(
          phase: IdentitySessionPhase.recoverableFailure,
          failure: failure,
        );
      }
      if (localSession != null) {
        await ref.read(privateWorkQuarantineProvider).quarantineForSessionLoss(localSession.userId);
        try {
          _ignoreNextSignedOut = true;
          await repository.signOut();
        } on Object {
          // Local session state still expires when sign-out cannot reach Auth.
        }
      }
      return IdentitySessionState(
        phase: IdentitySessionPhase.sessionExpired,
        failure: failure,
      );
    }
  }

  Future<IdentitySessionState> _bootstrap(
    IdentityRepository repository, {
    IdentitySession? expectedSession,
  }) async {
    final session = expectedSession ?? await repository.recoverSession();
    if (session == null) {
      return const IdentitySessionState.signedOut();
    }
    late final IdentityBootstrap bootstrap;
    try {
      bootstrap = await repository.bootstrap();
    } on IdentityFailure catch (failure) {
      if (failure.code == IdentityErrorCode.profileDisabled ||
          failure.code == IdentityErrorCode.profileUnavailable ||
          failure.code == IdentityErrorCode.sessionExpired) {
        _ignoreNextSignedOut = true;
        await _bestEffortSignOut(repository);
        return IdentitySessionState(
          phase: failure.code == IdentityErrorCode.sessionExpired
              ? IdentitySessionPhase.sessionExpired
              : IdentitySessionPhase.accessDenied,
          failure: failure,
        );
      }
      rethrow;
    }
    return _verifiedBootstrapState(
      repository,
      bootstrap,
      expectedSession: session,
    );
  }

  Future<IdentitySessionState> _verifiedBootstrapState(
    IdentityRepository repository,
    IdentityBootstrap bootstrap, {
    IdentitySession? expectedSession,
  }) async {
    final session = expectedSession ?? await repository.recoverSession();
    if (session == null || session.userId != bootstrap.profile.userId) {
      _ignoreNextSignedOut = true;
      await _bestEffortSignOut(repository);
      return IdentitySessionState(
        phase: IdentitySessionPhase.accessDenied,
        failure: const IdentityFailure(IdentityErrorCode.profileUnavailable),
      );
    }
    final next = _stateFromBootstrap(bootstrap);
    if (next.phase == IdentitySessionPhase.accessDenied) {
      _ignoreNextSignedOut = true;
      await _bestEffortSignOut(repository);
      return IdentitySessionState(
        phase: IdentitySessionPhase.accessDenied,
        failure: next.failure,
      );
    }
    if (next.phase == IdentitySessionPhase.authenticated) {
      await _bestEffortSaveBootstrap(session.userId, bootstrap);
    }
    return next;
  }

  Future<IdentitySessionState?> _loadCachedAuthenticatedState(
    String ownerId,
  ) async {
    try {
      final bootstrap = await ref.read(mobileSnapshotStoreProvider).loadIdentityBootstrap(ownerId);
      if (bootstrap == null || bootstrap.profile.userId != ownerId) {
        return null;
      }
      final next = _stateFromBootstrap(bootstrap);
      return next.phase == IdentitySessionPhase.authenticated ? next : null;
    } on Object {
      // Malformed, incompatible, or unavailable cache is treated as a cache miss.
      return null;
    }
  }

  Future<void> _bestEffortSaveBootstrap(
    String ownerId,
    IdentityBootstrap bootstrap,
  ) async {
    try {
      await ref
          .read(mobileSnapshotStoreProvider)
          .saveIdentityBootstrap(
            ownerId: ownerId,
            bootstrap: bootstrap,
            cachedAt: DateTime.now().toUtc(),
          );
    } on Object {
      // An unavailable local cache must not turn a valid online sign-in into a failure.
    }
  }

  IdentitySessionState _stateFromBootstrap(IdentityBootstrap bootstrap) {
    return IdentitySessionReducer.reduce(
      _currentState,
      IdentitySessionEvent(
        IdentitySessionEventType.bootstrapSucceeded,
        bootstrap: bootstrap,
      ),
    );
  }

  Future<void> _handleAuthEvent(IdentityAuthEvent event) async {
    switch (event.type) {
      case IdentityAuthEventType.signedOut:
      case IdentityAuthEventType.userDeleted:
        if (_ignoreNextSignedOut) {
          _ignoreNextSignedOut = false;
          return;
        }
        final userId = _currentState.userId;
        if (userId != null) {
          await ref.read(privateWorkQuarantineProvider).quarantineForSessionLoss(userId);
        }
        state = const AsyncData(IdentitySessionState.signedOut());
        return;
      case IdentityAuthEventType.streamError:
        final failure = event.failure ?? const IdentityFailure(IdentityErrorCode.sessionExpired);
        if (_isRecoverableTransportFailure(failure)) {
          _setRecoverableFailure(failure);
        } else {
          await _expireSession(failure);
        }
        return;
      case IdentityAuthEventType.passwordRecovery:
        await _expireSession(
          const IdentityFailure(IdentityErrorCode.sessionExpired),
        );
        return;
      case IdentityAuthEventType.initialSession:
      case IdentityAuthEventType.signedIn:
      case IdentityAuthEventType.tokenRefreshed:
      case IdentityAuthEventType.userUpdated:
      case IdentityAuthEventType.mfaChallengeVerified:
        if (!_busy) {
          try {
            state = AsyncData(
              await _bootstrap(ref.read(identityRepositoryProvider)),
            );
          } on Object catch (error) {
            final failure = _identityFailure(
              error,
              IdentityErrorCode.sessionExpired,
            );
            if (_isRecoverableTransportFailure(failure)) {
              _setRecoverableFailure(failure);
            } else {
              await _expireSession(failure);
            }
          }
        }
        return;
    }
  }

  Future<void> _expireSession(IdentityFailure failure) async {
    final userId = _currentState.userId;
    if (userId != null) {
      await ref.read(privateWorkQuarantineProvider).quarantineForSessionLoss(userId);
    }
    try {
      _ignoreNextSignedOut = true;
      await ref.read(identityRepositoryProvider).signOut();
    } on Object {
      // Local session state still expires when sign-out cannot reach Auth.
    }
    state = AsyncData(
      IdentitySessionState(
        phase: IdentitySessionPhase.sessionExpired,
        failure: failure,
      ),
    );
  }

  Future<void> _signOut() async {
    _busy = true;
    _ignoreNextSignedOut = true;
    try {
      await ref.read(identityRepositoryProvider).signOut();
      state = const AsyncData(IdentitySessionState.signedOut());
    } on Object catch (error) {
      _ignoreNextSignedOut = false;
      state = AsyncData(
        IdentitySessionState(
          phase: IdentitySessionPhase.recoverableFailure,
          failure: _identityFailure(
            error,
            IdentityErrorCode.networkUnavailable,
          ),
        ),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> _bestEffortSignOut(IdentityRepository repository) async {
    try {
      await repository.signOut();
    } on Object {
      // Access remains denied locally even when Auth cannot be reached.
    }
  }

  IdentitySessionState get _currentState => state.when(
    data: (value) => value,
    error: (_, _) => const IdentitySessionState(
      phase: IdentitySessionPhase.recoverableFailure,
      failure: IdentityFailure(IdentityErrorCode.unknown),
    ),
    loading: () => const IdentitySessionState.checking(),
  );

  bool _isRecoverableTransportFailure(IdentityFailure failure) =>
      failure.code == IdentityErrorCode.networkUnavailable ||
      failure.code == IdentityErrorCode.serverUnavailable;

  void _setRecoverableFailure(IdentityFailure failure) {
    final current = _currentState;
    state = AsyncData(
      IdentitySessionState(
        phase: current.phase == IdentitySessionPhase.authenticated
            ? IdentitySessionPhase.authenticated
            : IdentitySessionPhase.recoverableFailure,
        bootstrap: current.bootstrap,
        failure: failure,
      ),
    );
  }
}

IdentityFailure _identityFailure(Object error, IdentityErrorCode fallback) =>
    error is IdentityFailure ? error : IdentityFailure(fallback);
