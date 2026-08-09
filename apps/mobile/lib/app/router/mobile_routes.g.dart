// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $mobileShellRoute,
  $mobileSessionCheckRoute,
  $mobileLoginRoute,
  $mobilePasswordChangeRoute,
  $mobileMaintenanceRoute,
  $mobileUpdateRequiredRoute,
];

RouteBase get $mobileShellRoute => StatefulShellRouteData.$route(
  factory: $MobileShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/',
          hasOverriddenOnExit: false,
          factory: $MobileHomeRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'rank',
              hasOverriddenOnExit: false,
              factory: $MobileRankDetailRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'fixture/workout',
              hasOverriddenOnExit: false,
              factory: $MobileFixtureWorkoutRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'fixture/result',
              hasOverriddenOnExit: false,
              factory: $MobileFixtureResultRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'fixture/gallery',
              hasOverriddenOnExit: false,
              factory: $MobileFixtureGalleryRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'fixture/home/:scenario',
              hasOverriddenOnExit: false,
              factory: $MobileFixtureHomeRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/week',
          hasOverriddenOnExit: false,
          factory: $MobileWeekRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/progress',
          hasOverriddenOnExit: false,
          factory: $MobileProgressRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/profile',
          hasOverriddenOnExit: false,
          factory: $MobileProfileRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $MobileShellRouteExtension on MobileShellRoute {
  static MobileShellRoute _fromState(GoRouterState state) => const MobileShellRoute();
}

mixin $MobileHomeRoute on GoRouteData {
  static MobileHomeRoute _fromState(GoRouterState state) => const MobileHomeRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MobileRankDetailRoute on GoRouteData {
  static MobileRankDetailRoute _fromState(GoRouterState state) => const MobileRankDetailRoute();

  @override
  String get location => GoRouteData.$location('/rank');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MobileFixtureWorkoutRoute on GoRouteData {
  static MobileFixtureWorkoutRoute _fromState(GoRouterState state) =>
      MobileFixtureWorkoutRoute(mode: state.uri.queryParameters['mode']!);

  MobileFixtureWorkoutRoute get _self => this as MobileFixtureWorkoutRoute;

  @override
  String get location => GoRouteData.$location(
    '/fixture/workout',
    queryParams: {'mode': _self.mode},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MobileFixtureResultRoute on GoRouteData {
  static MobileFixtureResultRoute _fromState(GoRouterState state) =>
      const MobileFixtureResultRoute();

  @override
  String get location => GoRouteData.$location('/fixture/result');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MobileFixtureGalleryRoute on GoRouteData {
  static MobileFixtureGalleryRoute _fromState(GoRouterState state) =>
      const MobileFixtureGalleryRoute();

  @override
  String get location => GoRouteData.$location('/fixture/gallery');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MobileFixtureHomeRoute on GoRouteData {
  static MobileFixtureHomeRoute _fromState(GoRouterState state) =>
      MobileFixtureHomeRoute(scenario: state.pathParameters['scenario']!);

  MobileFixtureHomeRoute get _self => this as MobileFixtureHomeRoute;

  @override
  String get location => GoRouteData.$location(
    '/fixture/home/${Uri.encodeComponent(_self.scenario)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MobileWeekRoute on GoRouteData {
  static MobileWeekRoute _fromState(GoRouterState state) => const MobileWeekRoute();

  @override
  String get location => GoRouteData.$location('/week');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MobileProgressRoute on GoRouteData {
  static MobileProgressRoute _fromState(GoRouterState state) => const MobileProgressRoute();

  @override
  String get location => GoRouteData.$location('/progress');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MobileProfileRoute on GoRouteData {
  static MobileProfileRoute _fromState(GoRouterState state) => const MobileProfileRoute();

  @override
  String get location => GoRouteData.$location('/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mobileSessionCheckRoute => GoRouteData.$route(
  path: '/session-check',
  hasOverriddenOnExit: false,
  factory: $MobileSessionCheckRoute._fromState,
);

mixin $MobileSessionCheckRoute on GoRouteData {
  static MobileSessionCheckRoute _fromState(GoRouterState state) => const MobileSessionCheckRoute();

  @override
  String get location => GoRouteData.$location('/session-check');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

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
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

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
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mobileMaintenanceRoute => GoRouteData.$route(
  path: '/maintenance',
  hasOverriddenOnExit: false,
  factory: $MobileMaintenanceRoute._fromState,
);

mixin $MobileMaintenanceRoute on GoRouteData {
  static MobileMaintenanceRoute _fromState(GoRouterState state) => const MobileMaintenanceRoute();

  @override
  String get location => GoRouteData.$location('/maintenance');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

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
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
