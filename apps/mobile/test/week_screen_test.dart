import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_mobile/features/week/providers/scheduling_providers.dart';
import 'package:stone_set_mobile/features/week/views/week_screen.dart';

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
    expect(find.byKey(const Key('week-item-item-7')), findsOneWidget);

    await _scrollUntilVisible(tester, find.text('Swap preview'));
    expect(find.text('Swap preview'), findsOneWidget);

    await tester.tap(find.byKey(const Key('week-confirm-swap')));
    await tester.pumpAndSettle();

    expect(repository.confirmCalls, 1);
    expect(find.text('1 free swaps'), findsOneWidget);
  });

  testWidgets('shows no published routine state', (tester) async {
    await _pump(
      tester,
      FakeSchedulingRepository(initial: noPublishedRoutine()),
    );

    expect(find.text('No published routine'), findsOneWidget);
    expect(find.textContaining('Publish a routine'), findsOneWidget);
  });

  testWidgets('disables confirmation when no free credit remains', (
    tester,
  ) async {
    await _pump(
      tester,
      FakeSchedulingRepository(initial: standardWeek(freeSwapBalance: 0)),
    );

    await tester.tap(find.byKey(const Key('week-item-item-1')));
    await tester.tap(find.byKey(const Key('week-item-item-2')));
    await tester.pump();

    final paymentMessage = find.textContaining('RR payment will be available');
    await _scrollUntilVisible(tester, paymentMessage);
    expect(paymentMessage, findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('week-confirm-swap')),
    );
    expect(button.onPressed, isNull);
  });
}

Future<void> _pump(
  WidgetTester tester,
  FakeSchedulingRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [schedulingRepositoryProvider.overrideWithValue(repository)],
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
