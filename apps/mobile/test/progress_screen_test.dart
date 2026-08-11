import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_mobile/features/progress/providers/progress_providers.dart';
import 'package:stone_set_mobile/features/progress/providers/progression_providers.dart';
import 'package:stone_set_mobile/features/progress/views/progress_screen.dart';

import 'support/fake_progress_repository.dart';
import 'support/fake_progression_repository.dart';

void main() {
  testWidgets('renders authoritative rank totals, progression and history', (
    tester,
  ) async {
    final progressionRepository = FakeProgressionRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
          progressionRepositoryProvider.overrideWithValue(progressionRepository),
        ],
        child: const MaterialApp(home: Scaffold(body: ProgressScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('progress-rank-card')), findsOneWidget);
    expect(find.text('Platinum II'), findsWidgets);
    expect(find.text('1910 RR'), findsWidgets);
    expect(find.text('4860'), findsOneWidget);
    expect(find.byKey(const Key('progress-multiplier-card')), findsOneWidget);
    expect(find.text('1.00×'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Progression'), 400);
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Increase'), findsOneWidget);
    expect(find.text('Next: 82.5 kg'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Protect progression'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    final protectionTile = find.ancestor(
      of: find.text('Protect progression'),
      matching: find.byType(SwitchListTile),
    );
    await tester.ensureVisible(protectionTile);
    await tester.pumpAndSettle();
    await tester.tap(protectionTile);
    await tester.pumpAndSettle();
    expect(progressionRepository.settingUpdates, 1);

    await tester.scrollUntilVisible(
      find.byKey(const Key('progress-transactions')),
      400,
    );
    expect(find.byKey(const Key('progress-transactions')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('progress-workout-history')),
      400,
    );
    expect(find.byKey(const Key('progress-workout-history')), findsOneWidget);
    expect(find.text('Workout completed'), findsOneWidget);
  });

  testWidgets('authoritative multiplier remains usable at 200 percent text', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
          progressionRepositoryProvider.overrideWithValue(FakeProgressionRepository()),
        ],
        child: const MaterialApp(home: Scaffold(body: ProgressScreen())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('progress-multiplier-card')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('progress-multiplier-card')), findsOneWidget);
    expect(find.text('1.00×'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
