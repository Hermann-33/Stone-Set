import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_mobile/app/stone_set_mobile_app.dart';
import 'package:stone_set_mobile/features/identity/providers/identity_providers.dart';

import 'support/fake_identity_repository.dart';

void main() {
  testWidgets('shows login without flashing protected content', (tester) async {
    final repository = FakeIdentityRepository();
    addTearDown(repository.close);

    await _pumpApp(tester, repository);

    expect(find.text('Sign in'), findsWidgets);
    expect(find.byKey(const Key('mobile-primary-navigation')), findsNothing);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.textContaining('Sign up'), findsNothing);
  });

  testWidgets('keeps session-check content private while recovery is pending', (tester) async {
    final gate = Completer<void>();
    final repository = FakeIdentityRepository(recoverGate: gate);
    addTearDown(repository.close);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    expect(find.text('Checking your session…'), findsOneWidget);
    expect(find.byKey(const Key('mobile-primary-navigation')), findsNothing);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('prevents duplicate sign-in submission while busy', (tester) async {
    final gate = Completer<void>();
    final repository = FakeIdentityRepository(signInGate: gate);
    addTearDown(repository.close);
    await _pumpApp(tester, repository);

    await tester.enterText(find.byKey(const Key('username-field')), 'Member_One');
    await tester.enterText(find.byType(EditableText).at(1), 'Temporary-Password7');
    await tester.tap(find.byKey(const Key('sign-in-button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sign-in-button')), warnIfMissed: false);

    expect(repository.signInCalls, 1);
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mobile-primary-navigation')), findsOneWidget);
  });

  testWidgets('uses generic copy for invalid credentials', (tester) async {
    final repository = FakeIdentityRepository(
      signInFailure: const IdentityFailure(IdentityErrorCode.invalidCredentials),
    );
    addTearDown(repository.close);
    await _pumpApp(tester, repository);

    await tester.enterText(find.byKey(const Key('username-field')), 'member_one');
    await tester.enterText(find.byType(EditableText).at(1), 'Incorrect-Password7');
    await tester.tap(find.byKey(const Key('sign-in-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Unable to sign in. Check your details and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('submits credentials with the keyboard done action', (tester) async {
    final repository = FakeIdentityRepository();
    addTearDown(repository.close);
    await _pumpApp(tester, repository);

    await tester.enterText(find.byKey(const Key('username-field')), 'member_one');
    await tester.enterText(find.byType(EditableText).at(1), 'Temporary-Password7');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.signInCalls, 1);
    expect(find.byKey(const Key('mobile-primary-navigation')), findsOneWidget);
  });

  testWidgets('requires and completes first password change', (tester) async {
    const session = IdentitySession(
      userId: syntheticUserId,
      expiresAt: null,
    );
    final repository = FakeIdentityRepository(
      initialSession: session,
      bootstrap: syntheticBootstrap(mustChangePassword: true),
    );
    addTearDown(repository.close);
    await _pumpApp(tester, repository);

    expect(find.text('Choose a new password'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).at(0), 'Permanent-Password7');
    await tester.enterText(find.byType(EditableText).at(1), 'Permanent-Password7');
    await tester.tap(find.byKey(const Key('change-password-button')));
    await tester.pumpAndSettle();

    expect(repository.passwordChangeCalls, 1);
    expect(find.byKey(const Key('mobile-primary-navigation')), findsOneWidget);
  });

  testWidgets('login remains usable at 200 percent text scaling', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final repository = FakeIdentityRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Username'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows maintenance and incompatible states', (tester) async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final maintenanceRepository = FakeIdentityRepository(
      initialSession: session,
      bootstrap: syntheticBootstrap(maintenance: true),
    );
    addTearDown(maintenanceRepository.close);
    await _pumpApp(tester, maintenanceRepository);
    expect(find.text('Maintenance in progress'), findsOneWidget);

    final incompatibleRepository = FakeIdentityRepository(
      initialSession: session,
      bootstrap: syntheticBootstrap(compatible: false),
    );
    addTearDown(incompatibleRepository.close);
    await _pumpApp(tester, incompatibleRepository);
    expect(find.text('Update required'), findsOneWidget);
  });

  testWidgets('sign out returns protected content to login', (tester) async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(initialSession: session);
    addTearDown(repository.close);
    await _pumpApp(tester, repository);

    await tester.tap(find.byKey(const Key('mobile-destination-profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mobile-primary-navigation')), findsNothing);
    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('requires an explicit choice for unsynchronized private work', (tester) async {
    const session = IdentitySession(userId: syntheticUserId, expiresAt: null);
    final repository = FakeIdentityRepository(initialSession: session);
    final pendingWork = _PendingPrivateWork();
    addTearDown(repository.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          identityRepositoryProvider.overrideWithValue(repository),
          unsynchronizedPrivateWorkProvider.overrideWithValue(pendingWork),
        ],
        child: const StoneSetMobileApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mobile-destination-profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Unsynchronized workout'), findsOneWidget);
    expect(find.text('Synchronize now'), findsOneWidget);
    expect(find.text('Remain signed in'), findsOneWidget);
    expect(find.text('Discard draft'), findsOneWidget);
    expect(repository.signOutCalls, 0);
  });
}

Future<void> _pumpApp(WidgetTester tester, FakeIdentityRepository repository) async {
  await tester.pumpWidget(_testApp(repository));
  await tester.pumpAndSettle();
}

Widget _testApp(FakeIdentityRepository repository) {
  return ProviderScope(
    overrides: [
      identityRepositoryProvider.overrideWithValue(repository),
    ],
    child: const StoneSetMobileApp(),
  );
}

final class _PendingPrivateWork implements UnsynchronizedPrivateWork {
  @override
  Future<void> discard(String userId) async {}

  @override
  Future<bool> hasUnsynchronizedPrivateWork(String userId) async => true;

  @override
  Future<bool> synchronizeNow(String userId) async => true;
}
