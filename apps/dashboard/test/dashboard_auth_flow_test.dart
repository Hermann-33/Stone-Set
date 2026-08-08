import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/main.dart';
import 'package:stone_set_dashboard/src/session/dashboard_private_cache.dart';
import 'package:stone_set_dashboard/src/session/dashboard_session_controller.dart';
import 'package:stone_set_domain/identity.dart';

import 'support/fake_identity_repository.dart';
import 'support/recording_private_cache.dart';

void main() {
  testWidgets('session checking blocks protected content until restoration finishes', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(bootstrapResult: testBootstrap())
      ..recoverBlocker = Completer<IdentitySession?>();
    addTearDown(repository.dispose);
    await _pumpDashboard(tester, repository: repository, initialLocation: '/', settle: false);
    await tester.pump();

    expect(find.text('Checking your session…'), findsOneWidget);
    expect(find.byKey(const Key('needs-attention-section')), findsNothing);

    repository.recoverBlocker!.complete(null);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard-login-submit')), findsOneWidget);
  });

  testWidgets('browser refresh restores a verified session before protected content', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(),
    );
    addTearDown(repository.dispose);

    await _pumpDashboard(tester, repository: repository, initialLocation: '/');

    expect(repository.refreshCalls, 1);
    expect(repository.bootstrapCalls, 1);
    expect(find.byKey(const Key('needs-attention-section')), findsOneWidget);
  });

  testWidgets('expired restored session is terminated without exposing protected content', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(),
    )..refreshFailure = const IdentityFailure(IdentityErrorCode.sessionExpired);
    final cache = RecordingPrivateCache();
    addTearDown(repository.dispose);

    await _pumpDashboard(
      tester,
      repository: repository,
      privateCache: cache,
      initialLocation: '/',
    );

    expect(find.byKey(const Key('needs-attention-section')), findsNothing);
    expect(find.text('Your session ended. Sign in again.'), findsOneWidget);
    expect(cache.clearedUsers, [testSession.userId]);
    expect(repository.signOutCalls, 1);
  });

  testWidgets('login is keyboard operable and reports a generic authentication failure', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(bootstrapResult: testBootstrap())
      ..signInFailure = const IdentityFailure(IdentityErrorCode.invalidCredentials);
    addTearDown(repository.dispose);
    await _pumpDashboard(tester, repository: repository, size: const Size(375, 800));

    expect(find.byKey(const Key('dashboard-login-submit')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('dashboard-login-username')),
      '  TEST_USER  ',
    );
    await tester.enterText(find.byKey(const Key('dashboard-login-password')), 'incorrect');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.signInCalls, 1);
    expect(
      find.text('Unable to sign in. Check your details and try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('exists'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('auth events without a usable session do not unlock protected content', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(bootstrapResult: testBootstrap());
    addTearDown(repository.dispose);
    await _pumpDashboard(tester, repository: repository);

    repository.emit(const IdentityAuthEvent(IdentityAuthEventType.signedIn));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard-login-submit')), findsOneWidget);
    expect(find.byKey(const Key('needs-attention-section')), findsNothing);
    expect(repository.bootstrapCalls, 0);
  });

  testWidgets('show password and duplicate submission states are accessible', (tester) async {
    final blocker = Completer<void>();
    final repository = FakeIdentityRepository(bootstrapResult: testBootstrap())
      ..signInBlocker = blocker;
    addTearDown(repository.dispose);
    await _pumpDashboard(tester, repository: repository);

    final password = find.byKey(const Key('dashboard-login-password'));
    final passwordEditor = find.descendant(of: password, matching: find.byType(EditableText));
    expect(tester.widget<EditableText>(passwordEditor).obscureText, isTrue);
    await tester.tap(find.byKey(const Key('dashboard-login-password-visibility')));
    await tester.pump();
    expect(tester.widget<EditableText>(passwordEditor).obscureText, isFalse);

    await tester.enterText(find.byKey(const Key('dashboard-login-username')), 'test_user');
    await tester.enterText(password, 'Valid-password-1');
    await tester.tap(find.byKey(const Key('dashboard-login-submit')));
    await tester.pump();
    expect(repository.signInCalls, 1);
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('dashboard-login-submit'))).onPressed,
      isNull,
    );
    blocker.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('needs-attention-section')), findsOneWidget);
  });

  testWidgets('password change requires valid matching values before protected content', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(mustChangePassword: true),
      completedPasswordBootstrap: testBootstrap(),
    );
    addTearDown(repository.dispose);
    await _pumpDashboard(tester, repository: repository, initialLocation: '/');

    expect(find.text('Change your temporary password'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('dashboard-new-password')), 'Valid-password-1');
    await tester.enterText(
      find.byKey(const Key('dashboard-confirm-password')),
      'Valid-password-1',
    );
    await tester.tap(find.byKey(const Key('dashboard-password-change-submit')));
    await tester.pumpAndSettle();

    expect(repository.submittedPassword, 'Valid-password-1');
    expect(find.byKey(const Key('needs-attention-section')), findsOneWidget);
  });

  testWidgets('password-change failure keeps protected content locked', (tester) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(mustChangePassword: true),
    )..passwordChangeFailure = const IdentityFailure(IdentityErrorCode.serverUnavailable);
    addTearDown(repository.dispose);
    await _pumpDashboard(tester, repository: repository, initialLocation: '/');

    await tester.enterText(find.byKey(const Key('dashboard-new-password')), 'Valid-password-1');
    await tester.enterText(
      find.byKey(const Key('dashboard-confirm-password')),
      'Valid-password-1',
    );
    await tester.tap(find.byKey(const Key('dashboard-password-change-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('needs-attention-section')), findsNothing);
    expect(find.text('Change your temporary password'), findsOneWidget);
    expect(
      find.text('Unable to change the password. Check the requirements and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('logout clears private cache and browser back cannot expose protected content', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(),
    );
    final cache = RecordingPrivateCache();
    addTearDown(repository.dispose);
    await _pumpDashboard(tester, repository: repository, privateCache: cache);

    expect(find.byKey(const Key('needs-attention-section')), findsOneWidget);
    await tester.tap(find.byKey(const Key('dashboard-sign-out-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard-login-submit')), findsOneWidget);
    expect(cache.clearedUsers, [testSession.userId]);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('needs-attention-section')), findsNothing);
    expect(find.byKey(const Key('dashboard-login-submit')), findsOneWidget);
  });

  testWidgets('refresh failure closes the protected route until revalidation succeeds', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(),
    );
    addTearDown(repository.dispose);
    await _pumpDashboard(tester, repository: repository);
    expect(find.byKey(const Key('needs-attention-section')), findsOneWidget);

    repository.refreshFailure = const IdentityFailure(IdentityErrorCode.networkUnavailable);
    repository.emit(const IdentityAuthEvent(IdentityAuthEventType.tokenRefreshed));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('needs-attention-section')), findsNothing);
    expect(
      find.text('Unable to reach Stone Set. Check your connection and try again.'),
      findsOneWidget,
    );

    repository.refreshFailure = null;
    await tester.tap(find.byKey(const Key('dashboard-session-retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('needs-attention-section')), findsOneWidget);
  });

  testWidgets('operator revocation clears private state and locks browser history', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(),
    );
    final cache = RecordingPrivateCache();
    addTearDown(repository.dispose);
    await _pumpDashboard(tester, repository: repository, privateCache: cache);

    repository.emit(const IdentityAuthEvent(IdentityAuthEventType.userDeleted));
    await tester.pumpAndSettle();

    expect(cache.clearedUsers, [testSession.userId]);
    expect(find.byKey(const Key('needs-attention-section')), findsNothing);
    expect(find.byKey(const Key('dashboard-login-submit')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('needs-attention-section')), findsNothing);
  });

  testWidgets('direct account transition clears the previous user before exposing the next', (
    tester,
  ) async {
    const nextUserId = '00000000-0000-4000-8000-000000000002';
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(),
    );
    final clearBlocker = Completer<void>();
    final cache = RecordingPrivateCache()..clearBlocker = clearBlocker;
    addTearDown(repository.dispose);
    await _pumpDashboard(tester, repository: repository, privateCache: cache);
    expect(find.byKey(const Key('needs-attention-section')), findsOneWidget);

    repository
      ..recoveredSession = IdentitySession(
        userId: nextUserId,
        expiresAt: DateTime.utc(2026, 8, 9),
      )
      ..bootstrapResult = testBootstrap(userId: nextUserId);
    repository.emit(const IdentityAuthEvent(IdentityAuthEventType.signedIn));
    await tester.pump();
    await tester.pump();

    expect(cache.clearedUsers, <String>[testSession.userId]);
    expect(find.byKey(const Key('needs-attention-section')), findsNothing);

    clearBlocker.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('needs-attention-section')), findsOneWidget);
  });

  testWidgets('login remains usable at 200 percent text scale and expanded width', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final repository = FakeIdentityRepository(bootstrapResult: testBootstrap());
    addTearDown(repository.dispose);

    await _pumpDashboard(tester, repository: repository, size: const Size(1440, 900));

    expect(find.byKey(const Key('dashboard-login-submit')), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('login fields and password control expose useful semantics', (tester) async {
    final repository = FakeIdentityRepository(bootstrapResult: testBootstrap());
    addTearDown(repository.dispose);
    final semantics = tester.ensureSemantics();
    await _pumpDashboard(tester, repository: repository);

    expect(
      tester.getSemantics(find.byKey(const Key('dashboard-login-username'))).label,
      contains('Username'),
    );
    expect(
      tester
          .getSemantics(find.byKey(const Key('dashboard-login-password-visibility')))
          .getSemanticsData()
          .tooltip,
      'Show password',
    );
    semantics.dispose();
  });

  testWidgets('Tab moves focus from username to password', (tester) async {
    final repository = FakeIdentityRepository(bootstrapResult: testBootstrap());
    addTearDown(repository.dispose);
    await _pumpDashboard(tester, repository: repository);

    final username = find.byKey(const Key('dashboard-login-username'));
    final password = find.byKey(const Key('dashboard-login-password'));
    await tester.tap(username);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    final passwordEditor = tester.widget<EditableText>(
      find.descendant(of: password, matching: find.byType(EditableText)),
    );
    expect(passwordEditor.focusNode.hasFocus, isTrue);
  });

  testWidgets('maintenance and incompatible clients never render protected content', (
    tester,
  ) async {
    final maintenanceRepository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(maintenance: true),
    );
    addTearDown(maintenanceRepository.dispose);
    await _pumpDashboard(tester, repository: maintenanceRepository);
    expect(find.text('Stone Set is under maintenance'), findsOneWidget);
    expect(find.byKey(const Key('needs-attention-section')), findsNothing);

    final incompatibleRepository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(compatible: false),
    );
    addTearDown(incompatibleRepository.dispose);
    await _pumpDashboard(tester, repository: incompatibleRepository);
    expect(find.text('Dashboard update required'), findsOneWidget);
    expect(find.byKey(const Key('needs-attention-section')), findsNothing);
  });

  testWidgets('disabled profiles receive a generic access error without private content', (
    tester,
  ) async {
    final repository = FakeIdentityRepository(
      recoveredSession: testSession,
      bootstrapResult: testBootstrap(active: false),
    );
    addTearDown(repository.dispose);
    await _pumpDashboard(tester, repository: repository);

    expect(find.byKey(const Key('needs-attention-section')), findsNothing);
    expect(
      find.text('Unable to sign in. Check your details and try again.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required FakeIdentityRepository repository,
  DashboardPrivateCache? privateCache,
  Size size = const Size(1024, 768),
  String? initialLocation = '/login',
  bool settle = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        dashboardIdentityRepositoryProvider.overrideWithValue(repository),
        if (privateCache != null) dashboardPrivateCacheProvider.overrideWithValue(privateCache),
      ],
      child: StoneSetDashboardApp(initialLocation: initialLocation),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}
