import 'package:stone_set_domain/identity.dart';
import 'package:test/test.dart';

void main() {
  group('IdentitySessionReducer', () {
    test('requires password change before protected access', () {
      final state = IdentitySessionReducer.reduce(
        const IdentitySessionState.checking(),
        IdentitySessionEvent(
          IdentitySessionEventType.bootstrapSucceeded,
          bootstrap: _bootstrap(mustChangePassword: true),
        ),
      );

      expect(state.phase, IdentitySessionPhase.passwordChangeRequired);
      expect(
        IdentityRouteGuard.decide(state, IdentityRouteKind.protected),
        IdentityRouteDecision.passwordChange,
      );
    });

    test('does not expose a disabled profile', () {
      final state = IdentitySessionReducer.reduce(
        const IdentitySessionState.checking(),
        IdentitySessionEvent(
          IdentitySessionEventType.bootstrapSucceeded,
          bootstrap: _bootstrap(active: false),
        ),
      );

      expect(state.phase, IdentitySessionPhase.accessDenied);
      expect(state.exposesProtectedContent, isFalse);
    });

    test('routes a compatible active profile to protected content', () {
      final state = IdentitySessionReducer.reduce(
        const IdentitySessionState.checking(),
        IdentitySessionEvent(
          IdentitySessionEventType.bootstrapSucceeded,
          bootstrap: _bootstrap(),
        ),
      );

      expect(state.phase, IdentitySessionPhase.authenticated);
      expect(state.exposesProtectedContent, isTrue);
      expect(
        IdentityRouteGuard.decide(state, IdentityRouteKind.login),
        IdentityRouteDecision.protected,
      );
    });

    test('maps refresh failure to an expired session', () {
      final state = IdentitySessionReducer.reduce(
        const IdentitySessionState(phase: IdentitySessionPhase.authenticated),
        const IdentitySessionEvent(IdentitySessionEventType.refreshFailed),
      );

      expect(state.phase, IdentitySessionPhase.sessionExpired);
      expect(state.failure?.code, IdentityErrorCode.sessionExpired);
    });

    test('routes maintenance and incompatible clients to bounded states', () {
      final maintenance = IdentitySessionReducer.reduce(
        const IdentitySessionState.checking(),
        IdentitySessionEvent(
          IdentitySessionEventType.bootstrapSucceeded,
          bootstrap: _bootstrap(maintenance: true),
        ),
      );
      final incompatible = IdentitySessionReducer.reduce(
        const IdentitySessionState.checking(),
        IdentitySessionEvent(
          IdentitySessionEventType.bootstrapSucceeded,
          bootstrap: _bootstrap(compatible: false),
        ),
      );

      expect(
        IdentityRouteGuard.decide(maintenance, IdentityRouteKind.protected),
        IdentityRouteDecision.maintenance,
      );
      expect(
        IdentityRouteGuard.decide(incompatible, IdentityRouteKind.protected),
        IdentityRouteDecision.updateRequired,
      );
    });
  });
}

IdentityBootstrap _bootstrap({
  bool active = true,
  bool mustChangePassword = false,
  bool maintenance = false,
  bool compatible = true,
}) {
  return IdentityBootstrap(
    profile: IdentityProfile(
      userId: '00000000-0000-4000-8000-000000000001',
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
      readOnlyMode: false,
      clientCompatible: compatible,
    ),
    serverTime: DateTime.utc(2026, 8, 6),
    correlationId: 'test-correlation',
  );
}
