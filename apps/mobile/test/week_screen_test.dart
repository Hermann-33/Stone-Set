import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_mobile/features/progress/providers/progress_providers.dart';
import 'package:stone_set_mobile/features/week/providers/scheduling_providers.dart';
import 'package:stone_set_mobile/features/week/views/week_screen.dart';

import 'support/fake_progress_repository.dart';
import 'support/fake_scheduling_repository.dart';

void main() {
  testWidgets('renders seven real items and confirms a free-credit swap', (
    tester,
  ) async {
    final repository = FakeSchedulingRepository();
    await _pump(tester, repository);

    expect(find.byKey(const Key('week-item-item-1')), findsOneWidget);
    expect(find.text('2 free swaps'), findsOneWidget);

    await tester.tap(find.byKey(const Key('week-item-item-1')));
    await tester.tap(find.byKey(const Key('week-item-item-2')));
    await tester.pump();

    await _scrollUntilVisible(tester, find.byKey(const Key('week-item-item-7')));
    await _scrollUntilVisible(tester, find.text('Swap preview'));

    await tester.tap(find.byKey(const Key('week-confirm-swap')));
    await tester.pumpAndSettle();

    expect(repository.confirmCalls, 1);
    expect(repository.current.wallet.balance, 1);
  });

  testWidgets('shows no published routine state', (tester) async {
    await _pump(
      tester,
      FakeSchedulingRepository(initial: noPublishedRoutine()),
    );

    expect(find.text('No published routine'), findsOneWidget);
    expect(find.textContaining('Publish a routine'), findsOneWidget);
  });

  testWidgets('offers 5 RR when free credits are exhausted', (tester) async {
    await _pump(
      tester,
      FakeSchedulingRepository(initial: standardWeek(freeSwapBalance: 0)),
    );

    await tester.tap(find.byKey(const Key('week-item-item-1')));
    await tester.tap(find.byKey(const Key('week-item-item-2')));
    await tester.pump();
    await _scrollUntilVisible(tester, find.text('Use 5 RR'));

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('week-confirm-swap')),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('disables paid swap when RR is below five', (tester) async {
    final lowRr = ProgressSnapshot(
      account: const RankAccount(
        userId: '00000000-0000-4000-8000-000000000001',
        rrBalance: 4,
        lifetimeXp: 0,
        rankId: 'bronze_i',
        currentMinimum: 0,
        activeConsistencyMultiplier: 1,
        nextRankId: 'bronze_ii',
        nextMinimum: 100,
        progress: 0.04,
      ),
      ranks: defaultProgressSnapshot.ranks,
      transactions: const <ProgressTransaction>[],
      workouts: const <WorkoutHistoryItem>[],
    );
    await _pump(
      tester,
      FakeSchedulingRepository(initial: standardWeek(freeSwapBalance: 0)),
      progress: lowRr,
    );

    await tester.tap(find.byKey(const Key('week-item-item-1')));
    await tester.tap(find.byKey(const Key('week-item-item-2')));
    await tester.pump();
    await _scrollUntilVisible(tester, find.text('Need 5 RR'));

    expect(find.text('A paid swap needs 5 RR.'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('week-confirm-swap')),
    );
    expect(button.onPressed, isNull);
  });
}

Future<void> _pump(
  WidgetTester tester,
  FakeSchedulingRepository repository, {
  ProgressSnapshot? progress,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        schedulingRepositoryProvider.overrideWithValue(repository),
        currentWeekProvider.overrideWith((ref) async => repository.current),
        progressSnapshotProvider.overrideWith(
          (ref) async => progress ?? defaultProgressSnapshot,
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: WeekScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollUntilVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    320,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}
