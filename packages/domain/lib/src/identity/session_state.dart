import 'identity_models.dart';

enum IdentitySessionPhase {
  checking,
  signedOut,
  authenticating,
  bootstrapping,
  passwordChangeRequired,
  authenticated,
  maintenance,
  incompatible,
  accessDenied,
  sessionExpired,
  recoverableFailure,
}

final class IdentitySessionState {
  const IdentitySessionState({required this.phase, this.bootstrap, this.failure});

  const IdentitySessionState.checking()
    : phase = IdentitySessionPhase.checking,
      bootstrap = null,
      failure = null;

  const IdentitySessionState.signedOut({IdentityFailure? message})
    : phase = IdentitySessionPhase.signedOut,
      bootstrap = null,
      failure = message;

  final IdentitySessionPhase phase;
  final IdentityBootstrap? bootstrap;
  final IdentityFailure? failure;

  String? get userId => bootstrap?.profile.userId;

  bool get exposesProtectedContent => phase == IdentitySessionPhase.authenticated;
}

enum IdentitySessionEventType {
  checkStarted,
  noSession,
  authenticationStarted,
  authenticationSucceeded,
  bootstrapStarted,
  bootstrapSucceeded,
  authenticationFailed,
  refreshFailed,
  signedOut,
}

final class IdentitySessionEvent {
  const IdentitySessionEvent(this.type, {this.bootstrap, this.failure});

  final IdentitySessionEventType type;
  final IdentityBootstrap? bootstrap;
  final IdentityFailure? failure;
}

abstract final class IdentitySessionReducer {
  static IdentitySessionState reduce(IdentitySessionState current, IdentitySessionEvent event) {
    return switch (event.type) {
      IdentitySessionEventType.checkStarted => const IdentitySessionState.checking(),
      IdentitySessionEventType.noSession ||
      IdentitySessionEventType.signedOut => const IdentitySessionState.signedOut(),
      IdentitySessionEventType.authenticationStarted => const IdentitySessionState(
        phase: IdentitySessionPhase.authenticating,
      ),
      IdentitySessionEventType.authenticationSucceeded ||
      IdentitySessionEventType.bootstrapStarted => const IdentitySessionState(
        phase: IdentitySessionPhase.bootstrapping,
      ),
      IdentitySessionEventType.bootstrapSucceeded => _fromBootstrap(event.bootstrap),
      IdentitySessionEventType.authenticationFailed => IdentitySessionState(
        phase: IdentitySessionPhase.signedOut,
        failure: event.failure ?? const IdentityFailure(IdentityErrorCode.unknown),
      ),
      IdentitySessionEventType.refreshFailed => IdentitySessionState(
        phase: IdentitySessionPhase.sessionExpired,
        failure: event.failure ?? const IdentityFailure(IdentityErrorCode.sessionExpired),
      ),
    };
  }

  static IdentitySessionState _fromBootstrap(IdentityBootstrap? bootstrap) {
    if (bootstrap == null) {
      return const IdentitySessionState(
        phase: IdentitySessionPhase.recoverableFailure,
        failure: IdentityFailure(IdentityErrorCode.serverUnavailable),
      );
    }
    if (!bootstrap.profile.active) {
      return IdentitySessionState(
        phase: IdentitySessionPhase.accessDenied,
        bootstrap: bootstrap,
        failure: const IdentityFailure(IdentityErrorCode.profileDisabled),
      );
    }
    if (!bootstrap.compatibility.clientCompatible) {
      return IdentitySessionState(
        phase: IdentitySessionPhase.incompatible,
        bootstrap: bootstrap,
        failure: const IdentityFailure(IdentityErrorCode.clientIncompatible),
      );
    }
    if (bootstrap.compatibility.maintenanceMode) {
      return IdentitySessionState(
        phase: IdentitySessionPhase.maintenance,
        bootstrap: bootstrap,
        failure: const IdentityFailure(IdentityErrorCode.maintenance),
      );
    }
    if (bootstrap.profile.mustChangePassword) {
      return IdentitySessionState(
        phase: IdentitySessionPhase.passwordChangeRequired,
        bootstrap: bootstrap,
      );
    }
    return IdentitySessionState(
      phase: IdentitySessionPhase.authenticated,
      bootstrap: bootstrap,
    );
  }
}
