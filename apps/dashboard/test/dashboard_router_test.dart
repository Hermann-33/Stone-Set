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

  group('exercise typed routes', () {
    test('preserves library query state in direct detail URLs', () {
      const route = DashboardExerciseDetailRoute(
        exerciseId: '20000000-0000-4000-8000-000000000001',
        q: 'incline press',
        archive: 'all',
        publication: 'published',
        equipment: 'dumbbell',
        muscle: 'chest',
        sort: 'nameAscending',
        page: 2,
        mode: 'edit',
      );

      final uri = Uri.parse(route.location);

      expect(uri.path, '/exercises/20000000-0000-4000-8000-000000000001');
      expect(uri.queryParameters['q'], 'incline press');
      expect(uri.queryParameters['archive'], 'all');
      expect(uri.queryParameters['page'], '2');
      expect(uri.queryParameters['mode'], 'edit');
    });

    test('draft and immutable revision URLs have distinct typed paths', () {
      const draft = DashboardGuidanceDraftRoute(
        exerciseId: '20000000-0000-4000-8000-000000000001',
        draftId: '40000000-0000-4000-8000-000000000001',
      );
      const revision = DashboardGuidanceRevisionRoute(
        exerciseId: '20000000-0000-4000-8000-000000000001',
        revisionId: '50000000-0000-4000-8000-000000000001',
      );

      expect(
        draft.location,
        '/exercises/20000000-0000-4000-8000-000000000001/guidance/drafts/'
        '40000000-0000-4000-8000-000000000001',
      );
      expect(
        revision.location,
        '/exercises/20000000-0000-4000-8000-000000000001/guidance/revisions/'
        '50000000-0000-4000-8000-000000000001',
      );
    });
  });
}
