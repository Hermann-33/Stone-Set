import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/main.dart';
import 'package:stone_set_dashboard/src/features/routines/controllers/dashboard_routine_controllers.dart';
import 'package:stone_set_dashboard/src/session/dashboard_session_controller.dart';

import 'src/features/routines/fake_routine_repository.dart';
import 'support/fake_identity_repository.dart';

void main() {
  testWidgets('available width selects expanded, medium, and compact shells without losing route', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(),
    );
    addTearDown(repository.dispose);
    await _pumpAuthenticated(
      tester,
      repository: repository,
      size: const Size(1360, 900),
    );

    expect(find.byKey(const Key('dashboard-shell-expanded')), findsOneWidget);
    await tester.tap(find.byKey(const Key('dashboard-sidebar-routines')));
    await tester.pumpAndSettle();
    expect(find.text('Strength and size'), findsOneWidget);

    tester.view.physicalSize = const Size(900, 900);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard-shell-medium')), findsOneWidget);
    expect(find.text('Strength and size'), findsOneWidget);

    tester.view.physicalSize = const Size(600, 900);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard-shell-compact')), findsOneWidget);
    expect(find.text('Routines'), findsWidgets);
    expect(find.text('Strength and size'), findsOneWidget);
  });

  testWidgets('direct protected routine version links restore through the identity guard', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(),
    );
    addTearDown(repository.dispose);
    await _pumpAuthenticated(
      tester,
      repository: repository,
      initialLocation: '/routines/$draftId/versions/$versionId',
      size: const Size(1360, 900),
    );

    expect(repository.refreshCalls, 1);
    expect(repository.bootstrapCalls, 1);
    expect(find.byKey(const Key('routine-version-detail')), findsOneWidget);
    expect(find.textContaining('Strength and size'), findsOneWidget);
  });

  testWidgets('unknown protected routes show a safe not-found state after verification', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(),
    );
    addTearDown(repository.dispose);
    await _pumpAuthenticated(
      tester,
      repository: repository,
      initialLocation: '/missing-fixture',
    );

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.byKey(const Key('needs-attention-section')), findsNothing);
  });

  testWidgets('read-only bootstrap remains visible without claiming fixture persistence', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(readOnly: true),
    );
    addTearDown(repository.dispose);
    await _pumpAuthenticated(tester, repository: repository);

    expect(
      find.textContaining('Read only. Product changes are temporarily unavailable'),
      findsOneWidget,
    );
    expect(find.textContaining('Fixture preview'), findsWidgets);
  });

  testWidgets('compact Overview remains usable at 200 percent text scale', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(),
    );
    addTearDown(repository.dispose);
    await _pumpAuthenticated(
      tester,
      repository: repository,
      size: const Size(375, 900),
    );

    expect(find.byKey(const Key('dashboard-shell-compact')), findsOneWidget);
    expect(find.byKey(const Key('needs-attention-section')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('common shell interactions return to an idle frame', (tester) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(),
    );
    addTearDown(repository.dispose);
    await _pumpAuthenticated(
      tester,
      repository: repository,
      size: const Size(1360, 900),
    );

    await tester.tap(find.byKey(const Key('dashboard-sidebar-activity')));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(900, 900);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard-shell-medium')), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpAuthenticated(
  WidgetTester tester, {
  required FakeIdentityRepository repository,
  String initialLocation = '/',
  Size size = const Size(1024, 768),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardIdentityRepositoryProvider.overrideWithValue(repository),
        routineRepositoryProvider.overrideWithValue(FakeRoutineRepository()),
      ],
      child: StoneSetDashboardApp(initialLocation: initialLocation),
    ),
  );
  await tester.pumpAndSettle();
}
