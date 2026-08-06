// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $mobileProtectedRoute,
  $mobileSessionCheckRoute,
  $mobileLoginRoute,
  $mobilePasswordChangeRoute,
  $mobileMaintenanceRoute,
  $mobileUpdateRequiredRoute,
];

RouteBase get $mobileProtectedRoute => GoRouteData.$route(
  path: '/',
  hasOverriddenOnExit: false,
  factory: $MobileProtectedRoute._fromState,
);

mixin $MobileProtectedRoute on GoRouteData {
  static MobileProtectedRoute _fromState(GoRouterState state) =>
      const MobileProtectedRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mobileSessionCheckRoute => GoRouteData.$route(
  path: '/session-check',
  hasOverriddenOnExit: false,
  factory: $MobileSessionCheckRoute._fromState,
);

mixin $MobileSessionCheckRoute on GoRouteData {
  static MobileSessionCheckRoute _fromState(GoRouterState state) =>
      const MobileSessionCheckRoute();

  @override
  String get location => GoRouteData.$location('/session-check');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mobileLoginRoute => GoRouteData.$route(
  path: '/login',
  hasOverriddenOnExit: false,
  factory: $MobileLoginRoute._fromState,
);

mixin $MobileLoginRoute on GoRouteData {
  static MobileLoginRoute _fromState(GoRouterState state) =>
      MobileLoginRoute(returnTo: state.uri.queryParameters['return-to']);

  MobileLoginRoute get _self => this as MobileLoginRoute;

  @override
  String get location => GoRouteData.$location(
    '/login',
    queryParams: {if (_self.returnTo != null) 'return-to': _self.returnTo},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mobilePasswordChangeRoute => GoRouteData.$route(
  path: '/password-change',
  hasOverriddenOnExit: false,
  factory: $MobilePasswordChangeRoute._fromState,
);

mixin $MobilePasswordChangeRoute on GoRouteData {
  static MobilePasswordChangeRoute _fromState(GoRouterState state) =>
      const MobilePasswordChangeRoute();

  @override
  String get location => GoRouteData.$location('/password-change');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mobileMaintenanceRoute => GoRouteData.$route(
  path: '/maintenance',
  hasOverriddenOnExit: false,
  factory: $MobileMaintenanceRoute._fromState,
);

mixin $MobileMaintenanceRoute on GoRouteData {
  static MobileMaintenanceRoute _fromState(GoRouterState state) =>
      const MobileMaintenanceRoute();

  @override
  String get location => GoRouteData.$location('/maintenance');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mobileUpdateRequiredRoute => GoRouteData.$route(
  path: '/update-required',
  hasOverriddenOnExit: false,
  factory: $MobileUpdateRequiredRoute._fromState,
);

mixin $MobileUpdateRequiredRoute on GoRouteData {
  static MobileUpdateRequiredRoute _fromState(GoRouterState state) =>
      const MobileUpdateRequiredRoute();

  @override
  String get location => GoRouteData.$location('/update-required');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
