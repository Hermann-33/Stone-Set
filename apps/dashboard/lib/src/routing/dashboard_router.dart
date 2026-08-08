import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_domain/identity.dart';

import '../features/exercises/controllers/dashboard_exercise_controllers.dart';
import '../features/exercises/views/dashboard_exercise_editor_view.dart';
import '../features/exercises/views/dashboard_exercise_library_view.dart';
import '../features/exercises/views/dashboard_guidance_editor_view.dart';
import '../features/exercises/views/dashboard_guidance_revision_view.dart';
import '../features/fixtures/views/dashboard_fixture_gallery_view.dart';
import '../features/overview/views/dashboard_overview_view.dart';
import '../features/shell/models/dashboard_destination.dart';
import '../features/shell/views/dashboard_authenticated_shell.dart';
import '../features/shell/views/dashboard_destination_placeholder.dart';
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

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: $appRoutes,
    refreshListenable: refresh,
    redirect: (context, routeState) {
      final session = ref.read(dashboardSessionControllerProvider);
      return dashboardRedirect(session, routeState.uri);
    },
    errorBuilder: (context, state) => const DashboardNotFoundView(),
  );
  ref.onDispose(router.dispose);
  return router;
}

String? dashboardRedirect(IdentitySessionState session, Uri uri) {
  final requested = _routeKind(uri.path);
  // Keep the stateful shell mounted while an already-authenticated account is
  // being re-bootstrapped. ProtectedDashboardView replaces its child with the
  // checking surface until the new bootstrap is safe to expose. Redirecting
  // the shell away and back in the same frame can reparent go_router's global
  // navigation key during layout.
  if (session.phase == IdentitySessionPhase.bootstrapping &&
      requested == IdentityRouteKind.protected) {
    return null;
  }
  final decision = IdentityRouteGuard.decide(session, requested);
  final returnTo =
      _safeReturnTo(uri.queryParameters['return-to'] ?? uri.queryParameters['returnTo']) ??
      (requested == IdentityRouteKind.protected ? _safeReturnTo(uri.toString()) : null);

  return switch (decision) {
    IdentityRouteDecision.allow => null,
    IdentityRouteDecision.checking => SessionCheckingRoute(returnTo: returnTo).location,
    IdentityRouteDecision.login => LoginRoute(returnTo: returnTo).location,
    IdentityRouteDecision.passwordChange => PasswordChangeRoute(returnTo: returnTo).location,
    IdentityRouteDecision.maintenance => MaintenanceRoute(returnTo: returnTo).location,
    IdentityRouteDecision.updateRequired => UpdateRequiredRoute(returnTo: returnTo).location,
    IdentityRouteDecision.protected => returnTo ?? const DashboardOverviewRoute().location,
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

@TypedStatefulShellRoute<DashboardShellRoute>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<DashboardOverviewBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<DashboardOverviewRoute>(
          path: '/',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<DashboardFixtureGalleryRoute>(path: 'fixtures/:scenario'),
            TypedGoRoute<DashboardUnauthorizedRoute>(path: 'unauthorized'),
            TypedGoRoute<DashboardSafeErrorRoute>(path: 'error'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<DashboardRoutinesBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<DashboardRoutinesRoute>(
          path: '/routines',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<DashboardRoutineFixtureRoute>(
              path: ':fixtureId',
              routes: <TypedRoute<RouteData>>[
                TypedGoRoute<DashboardRoutineVersionFixtureRoute>(
                  path: 'versions/:versionId',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<DashboardExercisesBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<DashboardExercisesRoute>(
          path: '/exercises',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<DashboardExerciseCreateRoute>(path: 'new'),
            TypedGoRoute<DashboardExerciseDetailRoute>(
              path: ':exerciseId',
              routes: <TypedRoute<RouteData>>[
                TypedGoRoute<DashboardGuidanceDraftRoute>(
                  path: 'guidance/drafts/:draftId',
                ),
                TypedGoRoute<DashboardGuidanceRevisionRoute>(
                  path: 'guidance/revisions/:revisionId',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<DashboardReviewsBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<DashboardReviewsRoute>(
          path: '/reviews',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<DashboardReviewFixtureRoute>(path: ':fixtureId'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<DashboardActivityBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<DashboardActivityRoute>(
          path: '/activity',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<DashboardActivityFixtureRoute>(path: ':fixtureId'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<DashboardSettingsBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<DashboardSettingsRoute>(path: '/settings'),
      ],
    ),
  ],
)
class DashboardShellRoute extends StatefulShellRouteData {
  const DashboardShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => ProtectedDashboardView(
    child: DashboardAuthenticatedShell(navigationShell: navigationShell),
  );
}

class DashboardOverviewBranch extends StatefulShellBranchData {
  const DashboardOverviewBranch();
}

class DashboardRoutinesBranch extends StatefulShellBranchData {
  const DashboardRoutinesBranch();
}

class DashboardExercisesBranch extends StatefulShellBranchData {
  const DashboardExercisesBranch();
}

class DashboardReviewsBranch extends StatefulShellBranchData {
  const DashboardReviewsBranch();
}

class DashboardActivityBranch extends StatefulShellBranchData {
  const DashboardActivityBranch();
}

class DashboardSettingsBranch extends StatefulShellBranchData {
  const DashboardSettingsBranch();
}

class DashboardOverviewRoute extends GoRouteData with $DashboardOverviewRoute {
  const DashboardOverviewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const DashboardOverviewView();
}

class DashboardRoutinesRoute extends GoRouteData with $DashboardRoutinesRoute {
  const DashboardRoutinesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const DashboardDestinationPlaceholder(
    destination: DashboardDestination.routines,
  );
}

class DashboardRoutineFixtureRoute extends GoRouteData with $DashboardRoutineFixtureRoute {
  const DashboardRoutineFixtureRoute({required this.fixtureId});

  final String fixtureId;

  @override
  Widget build(BuildContext context, GoRouterState state) => DashboardDestinationPlaceholder(
    destination: DashboardDestination.routines,
    fixtureId: fixtureId,
  );
}

class DashboardRoutineVersionFixtureRoute extends GoRouteData
    with $DashboardRoutineVersionFixtureRoute {
  const DashboardRoutineVersionFixtureRoute({
    required this.fixtureId,
    required this.versionId,
  });

  final String fixtureId;
  final String versionId;

  @override
  Widget build(BuildContext context, GoRouterState state) => DashboardDestinationPlaceholder(
    destination: DashboardDestination.routines,
    fixtureId: '$fixtureId version $versionId',
  );
}

class DashboardExercisesRoute extends GoRouteData with $DashboardExercisesRoute {
  const DashboardExercisesRoute({
    this.q,
    this.archive,
    this.publication,
    this.equipment,
    this.muscle,
    this.sort,
    this.page,
  });

  final String? q;
  final String? archive;
  final String? publication;
  final String? equipment;
  final String? muscle;
  final String? sort;
  final int? page;

  @override
  Widget build(BuildContext context, GoRouterState state) => DashboardExerciseLibraryView(
    request: _exerciseLibraryRequest(
      q: q,
      archive: archive,
      publication: publication,
      equipment: equipment,
      muscle: muscle,
      sort: sort,
      page: page,
    ),
  );
}

class DashboardExerciseCreateRoute extends GoRouteData with $DashboardExerciseCreateRoute {
  const DashboardExerciseCreateRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const DashboardExerciseEditorView();
}

class DashboardExerciseDetailRoute extends GoRouteData with $DashboardExerciseDetailRoute {
  const DashboardExerciseDetailRoute({
    required this.exerciseId,
    this.q,
    this.archive,
    this.publication,
    this.equipment,
    this.muscle,
    this.sort,
    this.page,
    this.mode,
  });

  final String exerciseId;
  final String? q;
  final String? archive;
  final String? publication;
  final String? equipment;
  final String? muscle;
  final String? sort;
  final int? page;
  final String? mode;

  @override
  Widget build(BuildContext context, GoRouterState state) => _isUuid(exerciseId)
      ? DashboardExerciseLibraryView(
          selectedExerciseId: exerciseId,
          editSelected: mode == 'edit',
          request: _exerciseLibraryRequest(
            q: q,
            archive: archive,
            publication: publication,
            equipment: equipment,
            muscle: muscle,
            sort: sort,
            page: page,
          ),
        )
      : const DashboardNotFoundView();
}

class DashboardGuidanceDraftRoute extends GoRouteData with $DashboardGuidanceDraftRoute {
  const DashboardGuidanceDraftRoute({required this.exerciseId, required this.draftId});

  final String exerciseId;
  final String draftId;

  @override
  Widget build(BuildContext context, GoRouterState state) => _isUuid(exerciseId) && _isUuid(draftId)
      ? DashboardGuidanceEditorView(exerciseId: exerciseId, draftId: draftId)
      : const DashboardNotFoundView();
}

class DashboardGuidanceRevisionRoute extends GoRouteData with $DashboardGuidanceRevisionRoute {
  const DashboardGuidanceRevisionRoute({required this.exerciseId, required this.revisionId});

  final String exerciseId;
  final String revisionId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      _isUuid(exerciseId) && _isUuid(revisionId)
      ? DashboardGuidanceRevisionView(exerciseId: exerciseId, revisionId: revisionId)
      : const DashboardNotFoundView();
}

DashboardExerciseLibraryRequest _exerciseLibraryRequest({
  String? q,
  String? archive,
  String? publication,
  String? equipment,
  String? muscle,
  String? sort,
  int? page,
}) => DashboardExerciseLibraryRequest(
  search: q,
  archive: _enumByName(ExerciseArchiveFilter.values, archive) ?? ExerciseArchiveFilter.active,
  publication:
      _enumByName(ExercisePublicationFilter.values, publication) ?? ExercisePublicationFilter.all,
  equipmentKey: equipment,
  muscleKey: muscle,
  sort: _enumByName(ExerciseLibrarySort.values, sort) ?? ExerciseLibrarySort.updatedDescending,
  page: page == null || page < 1 ? 1 : page,
);

T? _enumByName<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

bool _isUuid(String value) => RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
).hasMatch(value);

class DashboardReviewsRoute extends GoRouteData with $DashboardReviewsRoute {
  const DashboardReviewsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const DashboardDestinationPlaceholder(
    destination: DashboardDestination.reviews,
  );
}

class DashboardReviewFixtureRoute extends GoRouteData with $DashboardReviewFixtureRoute {
  const DashboardReviewFixtureRoute({required this.fixtureId});

  final String fixtureId;

  @override
  Widget build(BuildContext context, GoRouterState state) => DashboardDestinationPlaceholder(
    destination: DashboardDestination.reviews,
    fixtureId: fixtureId,
  );
}

class DashboardActivityRoute extends GoRouteData with $DashboardActivityRoute {
  const DashboardActivityRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const DashboardDestinationPlaceholder(
    destination: DashboardDestination.activity,
  );
}

class DashboardActivityFixtureRoute extends GoRouteData with $DashboardActivityFixtureRoute {
  const DashboardActivityFixtureRoute({required this.fixtureId});

  final String fixtureId;

  @override
  Widget build(BuildContext context, GoRouterState state) => DashboardDestinationPlaceholder(
    destination: DashboardDestination.activity,
    fixtureId: fixtureId,
  );
}

class DashboardSettingsRoute extends GoRouteData with $DashboardSettingsRoute {
  const DashboardSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const DashboardDestinationPlaceholder(
    destination: DashboardDestination.settings,
  );
}

class DashboardFixtureGalleryRoute extends GoRouteData with $DashboardFixtureGalleryRoute {
  const DashboardFixtureGalleryRoute({required this.scenario});

  final String scenario;

  @override
  Widget build(BuildContext context, GoRouterState state) => DashboardFixtureGalleryView(
    scenario: scenario,
  );
}

class DashboardUnauthorizedRoute extends GoRouteData with $DashboardUnauthorizedRoute {
  const DashboardUnauthorizedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const DashboardUnauthorizedView();
}

class DashboardSafeErrorRoute extends GoRouteData with $DashboardSafeErrorRoute {
  const DashboardSafeErrorRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const DashboardSafeErrorView();
}
