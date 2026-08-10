import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/fixtures/models/home_fixture_scenario.dart';
import '../../features/fixtures/views/fixture_context_screen.dart';
import '../../features/fixtures/views/fixture_gallery_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/identity/views/access_state_screen.dart';
import '../../features/identity/views/login_screen.dart';
import '../../features/identity/views/password_change_screen.dart';
import '../../features/identity/views/session_check_screen.dart';
import '../../features/progress/views/progress_screen.dart';
import '../../features/shell/views/mobile_authenticated_shell.dart';
import '../../features/shell/views/mobile_destination_placeholder.dart';
import '../../features/week/views/week_screen.dart';
import '../../features/workout/views/workout_screen.dart';

part 'mobile_routes.g.dart';

@TypedStatefulShellRoute<MobileShellRoute>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<MobileHomeBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<MobileHomeRoute>(
          path: '/',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<MobileRankDetailRoute>(path: 'rank'),
            TypedGoRoute<MobileWorkoutRoute>(path: 'workout/:planItemId'),
            TypedGoRoute<MobileFixtureWorkoutRoute>(path: 'fixture/workout'),
            TypedGoRoute<MobileFixtureResultRoute>(path: 'fixture/result'),
            TypedGoRoute<MobileFixtureGalleryRoute>(path: 'fixture/gallery'),
            TypedGoRoute<MobileFixtureHomeRoute>(path: 'fixture/home/:scenario'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<MobileWeekBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<MobileWeekRoute>(path: '/week'),
      ],
    ),
    TypedStatefulShellBranch<MobileProgressBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<MobileProgressRoute>(path: '/progress'),
      ],
    ),
    TypedStatefulShellBranch<MobileProfileBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<MobileProfileRoute>(path: '/profile'),
      ],
    ),
  ],
)
class MobileShellRoute extends StatefulShellRouteData {
  const MobileShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => MobileAuthenticatedShell(navigationShell: navigationShell);
}

class MobileHomeBranch extends StatefulShellBranchData {
  const MobileHomeBranch();
}

class MobileWeekBranch extends StatefulShellBranchData {
  const MobileWeekBranch();
}

class MobileProgressBranch extends StatefulShellBranchData {
  const MobileProgressBranch();
}

class MobileProfileBranch extends StatefulShellBranchData {
  const MobileProfileBranch();
}

class MobileHomeRoute extends GoRouteData with $MobileHomeRoute {
  const MobileHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const HomeScreen(useLiveSchedule: true);
}

class MobileWorkoutRoute extends GoRouteData with $MobileWorkoutRoute {
  const MobileWorkoutRoute({required this.planItemId});

  final String planItemId;

  @override
  Widget build(BuildContext context, GoRouterState state) => WorkoutScreen(planItemId: planItemId);
}

class MobileWeekRoute extends GoRouteData with $MobileWeekRoute {
  const MobileWeekRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const WeekScreen();
}

class MobileProgressRoute extends GoRouteData with $MobileProgressRoute {
  const MobileProgressRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ProgressScreen();
}

class MobileProfileRoute extends GoRouteData with $MobileProfileRoute {
  const MobileProfileRoute();

  @override
  Widget build(
    BuildContext context,
    GoRouterState state,
  ) => const MobileDestinationPlaceholder(
    title: 'Profile',
    description:
        'Your verified identity remains active. Product preferences are not connected yet.',
    showProfileDetails: true,
  );
}

class MobileRankDetailRoute extends GoRouteData with $MobileRankDetailRoute {
  const MobileRankDetailRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ProgressScreen();
}

class MobileFixtureWorkoutRoute extends GoRouteData with $MobileFixtureWorkoutRoute {
  const MobileFixtureWorkoutRoute({required this.mode});

  final String mode;

  @override
  Widget build(
    BuildContext context,
    GoRouterState state,
  ) => FixtureContextScreen(
    title: 'Workout preview',
    description:
        'The ${_fixtureActionLabel(mode)} action is a labelled fixture only. It does not start, update or synchronize a workout.',
  );
}

class MobileFixtureResultRoute extends GoRouteData with $MobileFixtureResultRoute {
  const MobileFixtureResultRoute();

  @override
  Widget build(
    BuildContext context,
    GoRouterState state,
  ) => const FixtureContextScreen(
    title: 'Result preview',
    description: 'This result is fixture content. No reward or finalization has occurred.',
  );
}

class MobileFixtureGalleryRoute extends GoRouteData with $MobileFixtureGalleryRoute {
  const MobileFixtureGalleryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const FixtureGalleryScreen();
}

class MobileFixtureHomeRoute extends GoRouteData with $MobileFixtureHomeRoute {
  const MobileFixtureHomeRoute({required this.scenario});

  final String scenario;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    HomeFixtureScenario? selected;
    for (final value in HomeFixtureScenario.values) {
      if (value.name == scenario) {
        selected = value;
        break;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Home preview: ${selected?.name ?? 'standard'}'),
      ),
      body: HomeScreen(
        scenario: selected ?? HomeFixtureScenario.standard,
        useLiveSchedule: false,
      ),
    );
  }
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

String _fixtureActionLabel(String mode) => switch (mode) {
  'start' => 'Start workout',
  'continueWorkout' => 'Continue workout',
  'synchronize' => 'Sync workout',
  _ => 'Workout',
};
