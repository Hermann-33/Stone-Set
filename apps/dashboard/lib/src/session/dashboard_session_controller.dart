import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stone_set_domain/identity.dart';

import 'dashboard_private_cache.dart';

part 'dashboard_session_controller.g.dart';

@Riverpod(keepAlive: true)
IdentityRepository dashboardIdentityRepository(Ref ref) {
  throw StateError('dashboardIdentityRepositoryProvider must be overridden.');
}

@Riverpod(keepAlive: true)
class DashboardSessionController extends _$DashboardSessionController {
  Future<void>? _activeRevalidation;
  String? _lastUserId;

  IdentityRepository get _repository => ref.read(dashboardIdentityRepositoryProvider);

  DashboardPrivateCache get _privateCache => ref.read(dashboardPrivateCacheProvider);

  @override
  IdentitySessionState build() {
    final authSubscription = _repository.authEvents.listen(
      _handleAuthEvent,
      onError: _handleAuthStreamError,
    );
    ref.onDispose(() => unawaited(authSubscription.cancel()));
    unawaited(Future<void>.microtask(restoreSession));
    return const IdentitySessionState.checking();
  }

  Future<void> restoreSession() async {
    state = IdentitySessionReducer.reduce(
      state,
      const IdentitySessionEvent(IdentitySessionEventType.checkStarted),
    );
    try {
      final recovered = await _repository.recoverSession();
      if (recovered == null) {
        state = IdentitySessionReducer.reduce(
          state,
          const IdentitySessionEvent(IdentitySessionEventType.noSession),
        );
        return;
      }
      _lastUserId = recovered.userId;
      await _refreshAndBootstrap();
    } on IdentityFailure catch (failure) {
      await _applyFailure(
        failure,
        terminateSession: failure.code == IdentityErrorCode.sessionExpired,
      );
    } on Object {
      await _applyFailure(const IdentityFailure(IdentityErrorCode.unknown));
    }
  }

  Future<void> signIn({required String username, required String password}) async {
    state = IdentitySessionReducer.reduce(
      state,
      const IdentitySessionEvent(IdentitySessionEventType.authenticationStarted),
    );
    try {
      final normalized = NormalizedUsername.parse(username);
      await _repository.signIn(username: normalized, password: password);
      await _bootstrap();
    } on UsernameValidationException {
      state = const IdentitySessionState.signedOut(
        message: IdentityFailure(IdentityErrorCode.invalidCredentials),
      );
    } on IdentityFailure catch (failure) {
      await _applyFailure(failure, duringSignIn: true);
    } on Object {
      await _applyFailure(const IdentityFailure(IdentityErrorCode.unknown), duringSignIn: true);
    }
  }

  Future<void> completeRequiredPasswordChange(String newPassword) async {
    try {
      final bootstrap = await _repository.completeRequiredPasswordChange(newPassword);
      _applyBootstrap(bootstrap);
    } on IdentityFailure {
      rethrow;
    } on Object {
      throw const IdentityFailure(IdentityErrorCode.unknown);
    }
  }

  Future<void> revalidate() {
    if (state.phase == IdentitySessionPhase.signedOut ||
        state.phase == IdentitySessionPhase.authenticating ||
        state.phase == IdentitySessionPhase.checking) {
      return Future<void>.value();
    }
    final existing = _activeRevalidation;
    if (existing != null) {
      return existing;
    }
    final operation = _refreshAndBootstrap();
    _activeRevalidation = operation;
    return operation.whenComplete(() => _activeRevalidation = null);
  }

  Future<void> signOut() async {
    final userId = state.userId ?? _lastUserId;
    state = const IdentitySessionState.checking();
    if (userId != null) {
      await _privateCache.clearForUser(userId);
    }
    _lastUserId = null;
    try {
      await _repository.signOut(scope: IdentitySignOutScope.local);
    } finally {
      state = const IdentitySessionState.signedOut();
    }
  }

  Future<void> _refreshAndBootstrap() async {
    try {
      await _repository.refreshSession();
      await _bootstrap();
    } on IdentityFailure catch (failure) {
      await _applyFailure(
        failure,
        terminateSession: failure.code == IdentityErrorCode.sessionExpired,
      );
    } on Object {
      await _applyFailure(const IdentityFailure(IdentityErrorCode.unknown));
    }
  }

  Future<void> _bootstrap() async {
    state = IdentitySessionReducer.reduce(
      state,
      const IdentitySessionEvent(IdentitySessionEventType.bootstrapStarted),
    );
    final bootstrap = await _repository.bootstrap();
    _applyBootstrap(bootstrap);
  }

  void _applyBootstrap(IdentityBootstrap bootstrap) {
    _lastUserId = bootstrap.profile.userId;
    state = IdentitySessionReducer.reduce(
      state,
      IdentitySessionEvent(IdentitySessionEventType.bootstrapSucceeded, bootstrap: bootstrap),
    );
    if (state.phase == IdentitySessionPhase.accessDenied) {
      unawaited(
        _terminateDeniedSession(
          state.failure ?? const IdentityFailure(IdentityErrorCode.profileDisabled),
        ),
      );
    }
  }

  Future<void> _terminateDeniedSession(IdentityFailure failure) async {
    final userId = state.userId ?? _lastUserId;
    if (userId != null) {
      await _privateCache.clearForUser(userId);
    }
    _lastUserId = null;
    try {
      await _repository.signOut(scope: IdentitySignOutScope.local);
    } on Object {
      // The access-denied gate remains closed even when remote sign-out fails.
    }
    state = IdentitySessionState.signedOut(message: failure);
  }

  Future<void> _applyFailure(
    IdentityFailure failure, {
    bool duringSignIn = false,
    bool terminateSession = false,
  }) async {
    if (duringSignIn || failure.code == IdentityErrorCode.invalidCredentials) {
      state = IdentitySessionState.signedOut(message: failure);
      return;
    }

    if (failure.code == IdentityErrorCode.profileDisabled ||
        failure.code == IdentityErrorCode.profileUnavailable ||
        terminateSession) {
      final userId = state.userId ?? _lastUserId;
      if (userId != null) {
        await _privateCache.clearForUser(userId);
      }
      try {
        await _repository.signOut(scope: IdentitySignOutScope.local);
      } on Object {
        // The local UI still becomes signed out. No credential detail is surfaced.
      }
      _lastUserId = null;
      state = IdentitySessionState.signedOut(message: failure);
      return;
    }

    state = IdentitySessionState(
      phase: IdentitySessionPhase.recoverableFailure,
      bootstrap: state.bootstrap,
      failure: failure,
    );
  }

  void _handleAuthEvent(IdentityAuthEvent event) {
    switch (event.type) {
      case IdentityAuthEventType.initialSession:
        if (event.session == null) {
          unawaited(_finishExternalSignOut(event.failure));
        } else {
          unawaited(revalidate());
        }
        break;
      case IdentityAuthEventType.signedIn:
      case IdentityAuthEventType.tokenRefreshed:
      case IdentityAuthEventType.userUpdated:
        unawaited(revalidate());
        break;
      case IdentityAuthEventType.signedOut:
      case IdentityAuthEventType.userDeleted:
        unawaited(_finishExternalSignOut(event.failure));
        break;
      case IdentityAuthEventType.streamError:
        _handleAuthStreamError(event.failure ?? const IdentityFailure(IdentityErrorCode.unknown));
        break;
      case IdentityAuthEventType.passwordRecovery:
      case IdentityAuthEventType.mfaChallengeVerified:
        // Public recovery and MFA are not product routes in this packet.
        break;
    }
  }

  void _handleAuthStreamError(Object error, [StackTrace? stackTrace]) {
    final failure = error is IdentityFailure
        ? error
        : const IdentityFailure(IdentityErrorCode.networkUnavailable);
    unawaited(_applyFailure(failure));
  }

  Future<void> _finishExternalSignOut(IdentityFailure? message) async {
    final userId = state.userId ?? _lastUserId;
    if (userId != null) {
      await _privateCache.clearForUser(userId);
    }
    _lastUserId = null;
    state = IdentitySessionState.signedOut(message: message);
  }
}
