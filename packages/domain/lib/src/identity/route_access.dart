import 'session_state.dart';

enum IdentityRouteKind { checking, login, passwordChange, maintenance, updateRequired, protected }

enum IdentityRouteDecision {
  allow,
  checking,
  login,
  passwordChange,
  maintenance,
  updateRequired,
  protected,
}

abstract final class IdentityRouteGuard {
  static IdentityRouteDecision decide(IdentitySessionState session, IdentityRouteKind requested) {
    return switch (session.phase) {
      IdentitySessionPhase.checking || IdentitySessionPhase.bootstrapping =>
        requested == IdentityRouteKind.checking
            ? IdentityRouteDecision.allow
            : IdentityRouteDecision.checking,
      IdentitySessionPhase.signedOut ||
      IdentitySessionPhase.authenticating ||
      IdentitySessionPhase.sessionExpired ||
      IdentitySessionPhase.accessDenied ||
      IdentitySessionPhase.recoverableFailure =>
        requested == IdentityRouteKind.login
            ? IdentityRouteDecision.allow
            : IdentityRouteDecision.login,
      IdentitySessionPhase.passwordChangeRequired =>
        requested == IdentityRouteKind.passwordChange
            ? IdentityRouteDecision.allow
            : IdentityRouteDecision.passwordChange,
      IdentitySessionPhase.maintenance =>
        requested == IdentityRouteKind.maintenance
            ? IdentityRouteDecision.allow
            : IdentityRouteDecision.maintenance,
      IdentitySessionPhase.incompatible =>
        requested == IdentityRouteKind.updateRequired
            ? IdentityRouteDecision.allow
            : IdentityRouteDecision.updateRequired,
      IdentitySessionPhase.authenticated =>
        requested == IdentityRouteKind.protected
            ? IdentityRouteDecision.allow
            : IdentityRouteDecision.protected,
    };
  }
}
