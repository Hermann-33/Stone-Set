import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stone_set_domain/identity.dart';

import '../session/dashboard_session_controller.dart';
import '../views/login_view.dart';
import '../views/password_change_view.dart';
import '../views/protected_dashboard_view.dart';
import '../views/session_status_view.dart';

part 'dashboard_router.g.dart';

const _checkingPath = '/session-check';
const _loginPath = '/login';
const _passwordChangePath = '/password-change';
const _maintenancePath = '/maintenance';
const _updateRequiredPath = '/update-required';

@Riverpod(keepAlive: true)
GoRouter dashboardRouter(Ref ref, {String? initialLocation}) {
  final refresh = _RouterRefresh();
  ref
    ..listen(dashboardSessionControllerProvider, (previous, next) => refresh.notify())
    ..onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: initialLocation,
    routes: $appRoutes,
    refreshListenable: refresh,
    redirect: (context, routeState) {
      final session = ref.read(dashboardSessionControllerProvider);
      return dashboardRedirect(session, routeState.uri);
    },
    errorBuilder: (context, state) => const DashboardNotFoundView(),
  );
}

String? dashboardRedirect(IdentitySessionState session, Uri uri) {
  final requested = _routeKind(uri.path);
  final decision = IdentityRouteGuard.decide(session, requested);
  final returnTo =
      _safeReturnTo(uri.queryParameters['returnTo']) ??
      (requested == IdentityRouteKind.protected ? _safeReturnTo(uri.toString()) : null);

  return switch (decision) {
    IdentityRouteDecision.allow => null,
    IdentityRouteDecision.checking => SessionCheckingRoute(returnTo: returnTo).location,
    IdentityRouteDecision.login => LoginRoute(returnTo: returnTo).location,
    IdentityRouteDecision.passwordChange => PasswordChangeRoute(returnTo: returnTo).location,
    IdentityRouteDecision.maintenance => MaintenanceRoute(returnTo: returnTo).location,
    IdentityRouteDecision.updateRequired => UpdateRequiredRoute(returnTo: returnTo).location,
    IdentityRouteDecision.protected => returnTo ?? const ProtectedDashboardRoute().location,
  };
}

IdentityRouteKind _routeKind(String path) => switch (path) {
  _checkingPath => IdentityRouteKind.checking,
  _loginPath => IdentityRouteKind.login,
  _passwordChangePath => IdentityRouteKind.passwordChange,
  _maintenancePath => IdentityRouteKind.maintenance,
  _updateRequiredPath => IdentityRouteKind.updateRequired,
  _ => IdentityRouteKind.protected,
};

String? _safeReturnTo(String? candidate) {
  if (candidate == null || candidate.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(candidate);
  if (uri == null || uri.hasScheme || uri.hasAuthority || !uri.path.startsWith('/')) {
    return null;
  }
  if (<String>{
    _checkingPath,
    _loginPath,
    _passwordChangePath,
    _maintenancePath,
    _updateRequiredPath,
  }.contains(uri.path)) {
    return null;
  }
  return uri.toString();
}

class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

@TypedGoRoute<SessionCheckingRoute>(path: _checkingPath)
class SessionCheckingRoute extends GoRouteData with $SessionCheckingRoute {
  const SessionCheckingRoute({this.returnTo});

  final String? returnTo;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SessionCheckingView(returnTo: returnTo);
}

@TypedGoRoute<LoginRoute>(path: _loginPath)
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute({this.returnTo});

  final String? returnTo;

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginView();
}

@TypedGoRoute<PasswordChangeRoute>(path: _passwordChangePath)
class PasswordChangeRoute extends GoRouteData with $PasswordChangeRoute {
  const PasswordChangeRoute({this.returnTo});

  final String? returnTo;

  @override
  Widget build(BuildContext context, GoRouterState state) => const PasswordChangeView();
}

@TypedGoRoute<MaintenanceRoute>(path: _maintenancePath)
class MaintenanceRoute extends GoRouteData with $MaintenanceRoute {
  const MaintenanceRoute({this.returnTo});

  final String? returnTo;

  @override
  Widget build(BuildContext context, GoRouterState state) => const MaintenanceView();
}

@TypedGoRoute<UpdateRequiredRoute>(path: _updateRequiredPath)
class UpdateRequiredRoute extends GoRouteData with $UpdateRequiredRoute {
  const UpdateRequiredRoute({this.returnTo});

  final String? returnTo;

  @override
  Widget build(BuildContext context, GoRouterState state) => const UpdateRequiredView();
}

@TypedGoRoute<ProtectedDashboardRoute>(path: '/')
class ProtectedDashboardRoute extends GoRouteData with $ProtectedDashboardRoute {
  const ProtectedDashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ProtectedDashboardView();
}
