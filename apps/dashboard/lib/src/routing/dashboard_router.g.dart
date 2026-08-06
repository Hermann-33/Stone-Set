// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $sessionCheckingRoute,
  $loginRoute,
  $passwordChangeRoute,
  $maintenanceRoute,
  $updateRequiredRoute,
  $protectedDashboardRoute,
];

RouteBase get $sessionCheckingRoute => GoRouteData.$route(
  path: '/session-check',
  hasOverriddenOnExit: false,
  factory: $SessionCheckingRoute._fromState,
);

mixin $SessionCheckingRoute on GoRouteData {
  static SessionCheckingRoute _fromState(GoRouterState state) =>
      SessionCheckingRoute(returnTo: state.uri.queryParameters['return-to']);

  SessionCheckingRoute get _self => this as SessionCheckingRoute;

  @override
  String get location => GoRouteData.$location(
    '/session-check',
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

RouteBase get $loginRoute => GoRouteData.$route(
  path: '/login',
  hasOverriddenOnExit: false,
  factory: $LoginRoute._fromState,
);

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) =>
      LoginRoute(returnTo: state.uri.queryParameters['return-to']);

  LoginRoute get _self => this as LoginRoute;

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

RouteBase get $passwordChangeRoute => GoRouteData.$route(
  path: '/password-change',
  hasOverriddenOnExit: false,
  factory: $PasswordChangeRoute._fromState,
);

mixin $PasswordChangeRoute on GoRouteData {
  static PasswordChangeRoute _fromState(GoRouterState state) =>
      PasswordChangeRoute(returnTo: state.uri.queryParameters['return-to']);

  PasswordChangeRoute get _self => this as PasswordChangeRoute;

  @override
  String get location => GoRouteData.$location(
    '/password-change',
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

RouteBase get $maintenanceRoute => GoRouteData.$route(
  path: '/maintenance',
  hasOverriddenOnExit: false,
  factory: $MaintenanceRoute._fromState,
);

mixin $MaintenanceRoute on GoRouteData {
  static MaintenanceRoute _fromState(GoRouterState state) =>
      MaintenanceRoute(returnTo: state.uri.queryParameters['return-to']);

  MaintenanceRoute get _self => this as MaintenanceRoute;

  @override
  String get location => GoRouteData.$location(
    '/maintenance',
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

RouteBase get $updateRequiredRoute => GoRouteData.$route(
  path: '/update-required',
  hasOverriddenOnExit: false,
  factory: $UpdateRequiredRoute._fromState,
);

mixin $UpdateRequiredRoute on GoRouteData {
  static UpdateRequiredRoute _fromState(GoRouterState state) =>
      UpdateRequiredRoute(returnTo: state.uri.queryParameters['return-to']);

  UpdateRequiredRoute get _self => this as UpdateRequiredRoute;

  @override
  String get location => GoRouteData.$location(
    '/update-required',
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

RouteBase get $protectedDashboardRoute => GoRouteData.$route(
  path: '/',
  hasOverriddenOnExit: false,
  factory: $ProtectedDashboardRoute._fromState,
);

mixin $ProtectedDashboardRoute on GoRouteData {
  static ProtectedDashboardRoute _fromState(GoRouterState state) =>
      const ProtectedDashboardRoute();

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

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardRouter)
final dashboardRouterProvider = DashboardRouterFamily._();

final class DashboardRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  DashboardRouterProvider._({
    required DashboardRouterFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'dashboardRouterProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dashboardRouterHash();

  @override
  String toString() {
    return r'dashboardRouterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    final argument = this.argument as String?;
    return dashboardRouter(ref, initialLocation: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DashboardRouterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dashboardRouterHash() => r'e7f5ba29e1fd049770497834e820ad5f5948d2da';

final class DashboardRouterFamily extends $Family
    with $FunctionalFamilyOverride<GoRouter, String?> {
  DashboardRouterFamily._()
    : super(
        retry: null,
        name: r'dashboardRouterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  DashboardRouterProvider call({String? initialLocation}) =>
      DashboardRouterProvider._(argument: initialLocation, from: this);

  @override
  String toString() => r'dashboardRouterProvider';
}
