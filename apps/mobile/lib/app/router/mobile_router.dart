import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stone_set_domain/identity.dart';

import '../../features/identity/controllers/mobile_session_controller.dart';
import 'mobile_routes.dart';

part 'mobile_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter mobileRouter(Ref ref) {
  final refresh = _RouterRefresh();
  ref
    ..onDispose(refresh.dispose)
    ..listen(mobileSessionControllerProvider, (_, _) => refresh.notify());
  return GoRouter(
    routes: $appRoutes,
    initialLocation: const MobileSessionCheckRoute().location,
    refreshListenable: refresh,
    redirect: (_, state) {
      final session = ref
          .read(mobileSessionControllerProvider)
          .when(
            data: (value) => value,
            error: (_, _) => const IdentitySessionState(
              phase: IdentitySessionPhase.recoverableFailure,
            ),
            loading: () => const IdentitySessionState.checking(),
          );
      final requested = _routeKind(state.matchedLocation);
      return switch (IdentityRouteGuard.decide(session, requested)) {
        IdentityRouteDecision.allow => null,
        IdentityRouteDecision.checking => const MobileSessionCheckRoute().location,
        IdentityRouteDecision.login => MobileLoginRoute(
          returnTo: _safeReturnTo(state.uri),
        ).location,
        IdentityRouteDecision.passwordChange => const MobilePasswordChangeRoute().location,
        IdentityRouteDecision.maintenance => const MobileMaintenanceRoute().location,
        IdentityRouteDecision.updateRequired => const MobileUpdateRequiredRoute().location,
        IdentityRouteDecision.protected => const MobileProtectedRoute().location,
      };
    },
  );
}

IdentityRouteKind _routeKind(String path) => switch (path) {
  '/session-check' => IdentityRouteKind.checking,
  '/login' => IdentityRouteKind.login,
  '/password-change' => IdentityRouteKind.passwordChange,
  '/maintenance' => IdentityRouteKind.maintenance,
  '/update-required' => IdentityRouteKind.updateRequired,
  _ => IdentityRouteKind.protected,
};

String? _safeReturnTo(Uri uri) {
  final path = uri.path;
  if (!path.startsWith('/') ||
      path.startsWith('//') ||
      const <String>{
        '/login',
        '/session-check',
        '/password-change',
        '/maintenance',
        '/update-required',
      }.contains(path)) {
    return null;
  }
  return path;
}

final class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}
