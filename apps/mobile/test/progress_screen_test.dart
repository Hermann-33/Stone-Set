import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_mobile/features/progress/providers/progress_providers.dart';
import 'package:stone_set_mobile/features/progress/views/progress_screen.dart';

import 'support/fake_progress_repository.dart';

void main() {
  testWidgets('renders authoritative rank totals and history', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
        ],
        child: const MaterialApp(home: Scaffold(body: ProgressScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('progress-rank-card')), findsOneWidget);
    expect(find.text('Platinum II'), findsWidgets);
    expect(find.text('1910 RR'), findsWidgets);
    expect(find.text('4860'), findsOneWidget);
    expect(find.byKey(const Key('progress-transactions')), findsOneWidget);
    expect(find.byKey(const Key('progress-workout-history')), findsOneWidget);
    expect(find.text('Workout completed'), findsOneWidget);
  });
}
