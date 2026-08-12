import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_mobile/app/stone_set_mobile_app.dart';
import 'package:stone_set_mobile/features/identity/providers/identity_providers.dart';
import 'package:stone_set_mobile/features/local/providers/mobile_local_providers.dart';
import 'package:stone_set_mobile/features/progress/providers/progress_providers.dart';
import 'package:stone_set_mobile/features/sync/providers/mobile_sync_dependencies.dart';
import 'package:stone_set_mobile/features/week/providers/scheduling_providers.dart';

import 'support/fake_identity_repository.dart';
import 'support/fake_mobile_snapshot_store.dart';
import 'support/fake_progress_repository.dart';
import 'support/fake_scheduling_repository.dart';
import 'support/fake_workout_local_store.dart';

void main() {
  testWidgets(
    'authenticated shell exposes exactly Home Week Progress and Profile',
    (tester) async {
      final repository = _authenticatedRepository();
      addTearDown(repository.close);
      await _pumpApp(tester, repository);

      expect(
        find.byKey(const Key('mobile-primary-navigation')),
        findsOneWidget,
      );
      for (final label in const <String>[
        'Home',
        'Week',
        'Progress',
        'Profile',
      ]) {
        expect(find.text(label), findsWidgets);
      }
      expect(find.text('History'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('1.00×'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('1.00×'), findsOneWidget);
      expect(find.text('1.5×'), findsNothing);
      expect(_targetSize(tester, 'home'), greaterThanOrEqualTo(48));
      expect(_targetSize(tester, 'week'), greaterThanOrEqualTo(48));
      expect(_targetSize(tester, 'progress'), greaterThanOrEqualTo(48));
      expect(_targetSize(tester, 'profile'), greaterThanOrEqualTo(48));
    },
  );

  testWidgets(
    'Home pull-to-refresh updates rank while the mounted shell remains intact',
    (tester) async {
      final identity = _authenticatedRepository();
      final progress = FakeProgressRepository();
      final scheduling = FakeSchedulingRepository();
      final store = _primedStore();
      addTearDown(identity.close);
      await _pumpApp(
        tester,
        identity,
        progressRepository: progress,
        schedulingRepository: scheduling,
        store: store,
      );

      final navigationBefore = tester.widget<NavigationBar>(
        find.byKey(const Key('mobile-primary-navigation')),
      );
      expect(find.text('PLATINUM II'), findsOneWidget);
      expect(find.text('1,910 / 2,075 RR'), findsOneWidget);

      progress.snapshot = ProgressSnapshot(
        account: const RankAccount(
          userId: syntheticUserId,
          rrBalance: 2100,
          lifetimeXp: 5000,
          rankId: 'platinum_iii',
          currentMinimum: 2075,
          activeConsistencyMultiplier: 1,
          nextRankId: null,
          nextMinimum: null,
          progress: 1,
        ),
        ranks: defaultProgressSnapshot.ranks,
        transactions: defaultProgressSnapshot.transactions,
        workouts: defaultProgressSnapshot.workouts,
      );

      await tester.drag(
        find.byKey(const PageStorageKey<String>('mobile-home-scroll')),
        const Offset(0, 320),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('PLATINUM III'), findsOneWidget);
      expect(find.text('2,100+ RR'), findsOneWidget);
      expect(find.text('PLATINUM II'), findsNothing);
      expect(
        identical(
          navigationBefore,
          tester.widget<NavigationBar>(
            find.byKey(const Key('mobile-primary-navigation')),
          ),
        ),
        isTrue,
      );
    },
  );

  testWidgets(
    'each branch preserves its stack and returning to the selected tab resets it',
    (tester) async {
      final repository = _authenticatedRepository();
      addTearDown(repository.close);
      await _pumpApp(tester, repository);

      await tester.tap(find.byKey(const Key('home-rank-hero')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('progress-rank-card')), findsOneWidget);

      await _selectDestination(tester, 'week');
      expect(find.byKey(const Key('week-item-item-1')), findsOneWidget);
      await _selectDestination(tester, 'home');
      expect(find.byKey(const Key('progress-rank-card')), findsOneWidget);

      await _selectDestination(tester, 'home');
      expect(find.byKey(const Key('home-rank-hero')), findsOneWidget);
      expect(find.byKey(const Key('progress-rank-card')), findsNothing);
    },
  );

  testWidgets('Home scroll state survives branch changes for the same user', (
    tester,
  ) async {
    final repository = _authenticatedRepository();
    addTearDown(repository.close);
    _setSurface(tester, const Size(360, 640));
    await _pumpApp(tester, repository);

    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -420));
    await tester.pumpAndSettle();
    final before = tester.state<ScrollableState>(scrollable).position.pixels;
    expect(before, greaterThan(0));

    await _selectDestination(tester, 'progress');
    await _selectDestination(tester, 'home');

    final after = tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels;
    expect(after, closeTo(before, 0.01));
  });

  testWidgets(
    'authenticated user change destroys prior shell and never exposes prior cached rank',
    (tester) async {
      final repository = _authenticatedRepository();
      addTearDown(repository.close);
      await _pumpApp(tester, repository);

      await tester.tap(find.byKey(const Key('home-rank-hero')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('progress-rank-card')), findsOneWidget);

      repository.replaceAuthenticatedUser(
        '00000000-0000-4000-8000-000000000002',
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('progress-rank-card')), findsNothing);
      expect(find.text('PLATINUM II'), findsNothing);
      expect(find.byKey(const Key('home-error-state')), findsOneWidget);
    },
  );

  testWidgets('Home and navigation remain usable at 200 percent text scaling', (
    tester,
  ) async {
    final repository = _authenticatedRepository();
    addTearDown(repository.close);
    _setSurface(tester, const Size(360, 800));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpApp(tester, repository);

    expect(find.byKey(const Key('mobile-primary-navigation')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('today-plan-card')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('today-plan-card')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow portrait remains usable at 150 percent text scaling', (
    tester,
  ) async {
    final repository = _authenticatedRepository();
    addTearDown(repository.close);
    _setSurface(tester, const Size(320, 640));
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpApp(tester, repository);

    expect(find.byKey(const Key('mobile-primary-navigation')), findsOneWidget);
    expect(find.byKey(const Key('home-rank-hero')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('landscape fallback keeps Home content reachable', (
    tester,
  ) async {
    final repository = _authenticatedRepository();
    addTearDown(repository.close);
    _setSurface(tester, const Size(800, 360));
    await _pumpApp(tester, repository);

    await tester.scrollUntilVisible(
      find.byKey(const Key('today-plan-card')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('today-plan-card')), findsOneWidget);
    expect(find.byKey(const Key('mobile-primary-navigation')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

FakeIdentityRepository _authenticatedRepository() => FakeIdentityRepository(
  initialSession: const IdentitySession(
    userId: syntheticUserId,
    expiresAt: null,
  ),
);

FakeMobileSnapshotStore _primedStore() {
  final store = FakeMobileSnapshotStore();
  store.weekByOwner[syntheticUserId] = standardWeek();
  store.progressByOwner[syntheticUserId] = defaultProgressSnapshot;
  return store;
}

Future<void> _pumpApp(
  WidgetTester tester,
  FakeIdentityRepository repository, {
  FakeProgressRepository? progressRepository,
  FakeSchedulingRepository? schedulingRepository,
  FakeMobileSnapshotStore? store,
}) async {
  final progress = progressRepository ?? FakeProgressRepository();
  final scheduling = schedulingRepository ?? FakeSchedulingRepository();
  final snapshots = store ?? _primedStore();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        identityRepositoryProvider.overrideWithValue(repository),
        mobileSnapshotStoreProvider.overrideWithValue(snapshots),
        schedulingRepositoryProvider.overrideWithValue(scheduling),
        progressRepositoryProvider.overrideWithValue(progress),
        mobileSyncSchedulingRepositoryProvider.overrideWithValue(scheduling),
        mobileSyncProgressRepositoryProvider.overrideWithValue(progress),
        mobileSyncWorkoutLocalStoreProvider.overrideWithValue(
          FakeWorkoutLocalStore(),
        ),
      ],
      child: const StoneSetMobileApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectDestination(WidgetTester tester, String destination) async {
  await tester.tap(find.byKey(Key('mobile-destination-$destination')));
  await tester.pumpAndSettle();
}

double _targetSize(WidgetTester tester, String destination) =>
    tester.getSize(find.byKey(Key('mobile-destination-$destination'))).height;

void _setSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
