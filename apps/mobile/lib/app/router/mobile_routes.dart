import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/identity/views/access_state_screen.dart';
import '../../features/identity/views/login_screen.dart';
import '../../features/identity/views/password_change_screen.dart';
import '../../features/identity/views/session_check_screen.dart';
import '../../features/protected/protected_foundation_screen.dart';

part 'mobile_routes.g.dart';

@TypedGoRoute<MobileProtectedRoute>(path: '/')
class MobileProtectedRoute extends GoRouteData with $MobileProtectedRoute {
  const MobileProtectedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ProtectedFoundationScreen();
}

@TypedGoRoute<MobileSessionCheckRoute>(path: '/session-check')
class MobileSessionCheckRoute extends GoRouteData with $MobileSessionCheckRoute {
  const MobileSessionCheckRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SessionCheckScreen();
}

@TypedGoRoute<MobileLoginRoute>(path: '/login')
class MobileLoginRoute extends GoRouteData with $MobileLoginRoute {
  const MobileLoginRoute({this.returnTo});

  final String? returnTo;

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginScreen();
}

@TypedGoRoute<MobilePasswordChangeRoute>(path: '/password-change')
class MobilePasswordChangeRoute extends GoRouteData with $MobilePasswordChangeRoute {
  const MobilePasswordChangeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const PasswordChangeScreen();
}

@TypedGoRoute<MobileMaintenanceRoute>(path: '/maintenance')
class MobileMaintenanceRoute extends GoRouteData with $MobileMaintenanceRoute {
  const MobileMaintenanceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AccessStateScreen(
    title: 'Maintenance in progress',
    description: 'Stone Set is temporarily unavailable. Try again shortly.',
    allowRetry: true,
  );
}

@TypedGoRoute<MobileUpdateRequiredRoute>(path: '/update-required')
class MobileUpdateRequiredRoute extends GoRouteData with $MobileUpdateRequiredRoute {
  const MobileUpdateRequiredRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AccessStateScreen(
    title: 'Update required',
    description: 'This version of Stone Set can no longer access private data.',
    allowRetry: false,
  );
}
