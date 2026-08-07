import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/src/routing/dashboard_router.dart';
import 'package:stone_set_domain/identity.dart';

import 'support/fake_identity_repository.dart';

void main() {
  group('dashboardRedirect', () {
    test('preserves an internal protected destination while signed out', () {
      const session = IdentitySessionState.signedOut();

      final redirect = dashboardRedirect(session, Uri.parse('/?section=profile'));

      final uri = Uri.parse(redirect!);
      expect(uri.path, '/login');
      expect(uri.queryParameters.values, contains('/?section=profile'));
    });

    test('rejects an external return destination after authentication', () {
      final session = IdentitySessionState(
        phase: IdentitySessionPhase.authenticated,
        bootstrap: testBootstrap(),
      );

      final redirect = dashboardRedirect(
        session,
        Uri.parse('/login?returnTo=https%3A%2F%2Fexample.com'),
      );

      expect(redirect, '/');
    });

    test('routes a required password change before protected content', () {
      final session = IdentitySessionState(
        phase: IdentitySessionPhase.passwordChangeRequired,
        bootstrap: testBootstrap(mustChangePassword: true),
      );

      final redirect = dashboardRedirect(session, Uri.parse('/'));

      final uri = Uri.parse(redirect!);
      expect(uri.path, '/password-change');
      expect(uri.queryParameters.values, contains('/'));
    });

    test('restores the generated return-to query after session verification', () {
      final session = IdentitySessionState(
        phase: IdentitySessionPhase.authenticated,
        bootstrap: testBootstrap(),
      );

      final redirect = dashboardRedirect(
        session,
        Uri.parse('/session-check?return-to=%2Fexercises%2Fincline-dumbbell-press'),
      );

      expect(redirect, '/exercises/incline-dumbbell-press');
    });
  });
}
