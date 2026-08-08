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
  $dashboardShellRoute,
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

RouteBase get $dashboardShellRoute => StatefulShellRouteData.$route(
  factory: $DashboardShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/',
          hasOverriddenOnExit: false,
          factory: $DashboardOverviewRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'fixtures/:scenario',
              hasOverriddenOnExit: false,
              factory: $DashboardFixtureGalleryRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'unauthorized',
              hasOverriddenOnExit: false,
              factory: $DashboardUnauthorizedRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'error',
              hasOverriddenOnExit: false,
              factory: $DashboardSafeErrorRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/routines',
          hasOverriddenOnExit: false,
          factory: $DashboardRoutinesRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':fixtureId',
              hasOverriddenOnExit: false,
              factory: $DashboardRoutineFixtureRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'versions/:versionId',
                  hasOverriddenOnExit: false,
                  factory: $DashboardRoutineVersionFixtureRoute._fromState,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/exercises',
          hasOverriddenOnExit: false,
          factory: $DashboardExercisesRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'new',
              hasOverriddenOnExit: false,
              factory: $DashboardExerciseCreateRoute._fromState,
            ),
            GoRouteData.$route(
              path: ':exerciseId',
              hasOverriddenOnExit: false,
              factory: $DashboardExerciseDetailRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'guidance/drafts/:draftId',
                  hasOverriddenOnExit: false,
                  factory: $DashboardGuidanceDraftRoute._fromState,
                ),
                GoRouteData.$route(
                  path: 'guidance/revisions/:revisionId',
                  hasOverriddenOnExit: false,
                  factory: $DashboardGuidanceRevisionRoute._fromState,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/reviews',
          hasOverriddenOnExit: false,
          factory: $DashboardReviewsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':fixtureId',
              hasOverriddenOnExit: false,
              factory: $DashboardReviewFixtureRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/activity',
          hasOverriddenOnExit: false,
          factory: $DashboardActivityRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':fixtureId',
              hasOverriddenOnExit: false,
              factory: $DashboardActivityFixtureRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/settings',
          hasOverriddenOnExit: false,
          factory: $DashboardSettingsRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $DashboardShellRouteExtension on DashboardShellRoute {
  static DashboardShellRoute _fromState(GoRouterState state) =>
      const DashboardShellRoute();
}

mixin $DashboardOverviewRoute on GoRouteData {
  static DashboardOverviewRoute _fromState(GoRouterState state) =>
      const DashboardOverviewRoute();

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

mixin $DashboardFixtureGalleryRoute on GoRouteData {
  static DashboardFixtureGalleryRoute _fromState(GoRouterState state) =>
      DashboardFixtureGalleryRoute(scenario: state.pathParameters['scenario']!);

  DashboardFixtureGalleryRoute get _self =>
      this as DashboardFixtureGalleryRoute;

  @override
  String get location =>
      GoRouteData.$location('/fixtures/${Uri.encodeComponent(_self.scenario)}');

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

mixin $DashboardUnauthorizedRoute on GoRouteData {
  static DashboardUnauthorizedRoute _fromState(GoRouterState state) =>
      const DashboardUnauthorizedRoute();

  @override
  String get location => GoRouteData.$location('/unauthorized');

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

mixin $DashboardSafeErrorRoute on GoRouteData {
  static DashboardSafeErrorRoute _fromState(GoRouterState state) =>
      const DashboardSafeErrorRoute();

  @override
  String get location => GoRouteData.$location('/error');

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

mixin $DashboardRoutinesRoute on GoRouteData {
  static DashboardRoutinesRoute _fromState(GoRouterState state) =>
      const DashboardRoutinesRoute();

  @override
  String get location => GoRouteData.$location('/routines');

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

mixin $DashboardRoutineFixtureRoute on GoRouteData {
  static DashboardRoutineFixtureRoute _fromState(GoRouterState state) =>
      DashboardRoutineFixtureRoute(
        fixtureId: state.pathParameters['fixtureId']!,
      );

  DashboardRoutineFixtureRoute get _self =>
      this as DashboardRoutineFixtureRoute;

  @override
  String get location => GoRouteData.$location(
    '/routines/${Uri.encodeComponent(_self.fixtureId)}',
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

mixin $DashboardRoutineVersionFixtureRoute on GoRouteData {
  static DashboardRoutineVersionFixtureRoute _fromState(GoRouterState state) =>
      DashboardRoutineVersionFixtureRoute(
        fixtureId: state.pathParameters['fixtureId']!,
        versionId: state.pathParameters['versionId']!,
      );

  DashboardRoutineVersionFixtureRoute get _self =>
      this as DashboardRoutineVersionFixtureRoute;

  @override
  String get location => GoRouteData.$location(
    '/routines/${Uri.encodeComponent(_self.fixtureId)}/versions/${Uri.encodeComponent(_self.versionId)}',
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

mixin $DashboardExercisesRoute on GoRouteData {
  static DashboardExercisesRoute _fromState(GoRouterState state) =>
      DashboardExercisesRoute(
        q: state.uri.queryParameters['q'],
        archive: state.uri.queryParameters['archive'],
        publication: state.uri.queryParameters['publication'],
        equipment: state.uri.queryParameters['equipment'],
        muscle: state.uri.queryParameters['muscle'],
        sort: state.uri.queryParameters['sort'],
        page: _$convertMapValue(
          'page',
          state.uri.queryParameters,
          int.tryParse,
        ),
      );

  DashboardExercisesRoute get _self => this as DashboardExercisesRoute;

  @override
  String get location => GoRouteData.$location(
    '/exercises',
    queryParams: {
      if (_self.q != null) 'q': _self.q,
      if (_self.archive != null) 'archive': _self.archive,
      if (_self.publication != null) 'publication': _self.publication,
      if (_self.equipment != null) 'equipment': _self.equipment,
      if (_self.muscle != null) 'muscle': _self.muscle,
      if (_self.sort != null) 'sort': _self.sort,
      if (_self.page != null) 'page': _self.page!.toString(),
    },
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

mixin $DashboardExerciseCreateRoute on GoRouteData {
  static DashboardExerciseCreateRoute _fromState(GoRouterState state) =>
      const DashboardExerciseCreateRoute();

  @override
  String get location => GoRouteData.$location('/exercises/new');

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

mixin $DashboardExerciseDetailRoute on GoRouteData {
  static DashboardExerciseDetailRoute _fromState(GoRouterState state) =>
      DashboardExerciseDetailRoute(
        exerciseId: state.pathParameters['exerciseId']!,
        q: state.uri.queryParameters['q'],
        archive: state.uri.queryParameters['archive'],
        publication: state.uri.queryParameters['publication'],
        equipment: state.uri.queryParameters['equipment'],
        muscle: state.uri.queryParameters['muscle'],
        sort: state.uri.queryParameters['sort'],
        page: _$convertMapValue(
          'page',
          state.uri.queryParameters,
          int.tryParse,
        ),
        mode: state.uri.queryParameters['mode'],
      );

  DashboardExerciseDetailRoute get _self =>
      this as DashboardExerciseDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/exercises/${Uri.encodeComponent(_self.exerciseId)}',
    queryParams: {
      if (_self.q != null) 'q': _self.q,
      if (_self.archive != null) 'archive': _self.archive,
      if (_self.publication != null) 'publication': _self.publication,
      if (_self.equipment != null) 'equipment': _self.equipment,
      if (_self.muscle != null) 'muscle': _self.muscle,
      if (_self.sort != null) 'sort': _self.sort,
      if (_self.page != null) 'page': _self.page!.toString(),
      if (_self.mode != null) 'mode': _self.mode,
    },
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

mixin $DashboardGuidanceDraftRoute on GoRouteData {
  static DashboardGuidanceDraftRoute _fromState(GoRouterState state) =>
      DashboardGuidanceDraftRoute(
        exerciseId: state.pathParameters['exerciseId']!,
        draftId: state.pathParameters['draftId']!,
      );

  DashboardGuidanceDraftRoute get _self => this as DashboardGuidanceDraftRoute;

  @override
  String get location => GoRouteData.$location(
    '/exercises/${Uri.encodeComponent(_self.exerciseId)}/guidance/drafts/${Uri.encodeComponent(_self.draftId)}',
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

mixin $DashboardGuidanceRevisionRoute on GoRouteData {
  static DashboardGuidanceRevisionRoute _fromState(GoRouterState state) =>
      DashboardGuidanceRevisionRoute(
        exerciseId: state.pathParameters['exerciseId']!,
        revisionId: state.pathParameters['revisionId']!,
      );

  DashboardGuidanceRevisionRoute get _self =>
      this as DashboardGuidanceRevisionRoute;

  @override
  String get location => GoRouteData.$location(
    '/exercises/${Uri.encodeComponent(_self.exerciseId)}/guidance/revisions/${Uri.encodeComponent(_self.revisionId)}',
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

mixin $DashboardReviewsRoute on GoRouteData {
  static DashboardReviewsRoute _fromState(GoRouterState state) =>
      const DashboardReviewsRoute();

  @override
  String get location => GoRouteData.$location('/reviews');

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

mixin $DashboardReviewFixtureRoute on GoRouteData {
  static DashboardReviewFixtureRoute _fromState(GoRouterState state) =>
      DashboardReviewFixtureRoute(
        fixtureId: state.pathParameters['fixtureId']!,
      );

  DashboardReviewFixtureRoute get _self => this as DashboardReviewFixtureRoute;

  @override
  String get location =>
      GoRouteData.$location('/reviews/${Uri.encodeComponent(_self.fixtureId)}');

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

mixin $DashboardActivityRoute on GoRouteData {
  static DashboardActivityRoute _fromState(GoRouterState state) =>
      const DashboardActivityRoute();

  @override
  String get location => GoRouteData.$location('/activity');

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

mixin $DashboardActivityFixtureRoute on GoRouteData {
  static DashboardActivityFixtureRoute _fromState(GoRouterState state) =>
      DashboardActivityFixtureRoute(
        fixtureId: state.pathParameters['fixtureId']!,
      );

  DashboardActivityFixtureRoute get _self =>
      this as DashboardActivityFixtureRoute;

  @override
  String get location => GoRouteData.$location(
    '/activity/${Uri.encodeComponent(_self.fixtureId)}',
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

mixin $DashboardSettingsRoute on GoRouteData {
  static DashboardSettingsRoute _fromState(GoRouterState state) =>
      const DashboardSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

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

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
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

String _$dashboardRouterHash() => r'076e305687935bdbf1a93be620c77c16c6958f69';

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
