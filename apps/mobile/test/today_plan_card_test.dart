import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_mobile/features/fixtures/data/home_fixture_service.dart';
import 'package:stone_set_mobile/features/fixtures/models/home_fixture_scenario.dart';
import 'package:stone_set_mobile/features/home/views/today_plan_card.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

void main() {
  const service = HomeFixtureService();

  testWidgets('every today state has explicit non-color status and action text', (tester) async {
    const scenarios = <HomeFixtureScenario>[
      HomeFixtureScenario.standard,
      HomeFixtureScenario.activeWorkout,
      HomeFixtureScenario.pendingSynchronization,
      HomeFixtureScenario.completedWorkout,
      HomeFixtureScenario.restDay,
      HomeFixtureScenario.lockedWorkout,
      HomeFixtureScenario.unavailableWorkout,
    ];

    for (final scenario in scenarios) {
      final today = service.load(scenario).today;
      var invocations = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: StoneSetTheme.light(),
          home: Scaffold(
            body: TodayPlanCard(data: today, onAction: () => invocations += 1),
          ),
        ),
      );

      expect(find.text(today.actionLabel), findsOneWidget, reason: scenario.name);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed != null, today.actionEnabled, reason: scenario.name);
      expect(tester.getSize(find.byType(FilledButton)).height, greaterThanOrEqualTo(48));

      if (today.actionEnabled) {
        await tester.tap(find.byType(FilledButton));
        await tester.pump();
        expect(invocations, 1, reason: scenario.name);
      }
    }
  });

  testWidgets('today card remains usable at 200 percent text scaling', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final today = service.load(HomeFixtureScenario.unavailableWorkout).today;

    await tester.pumpWidget(
      MaterialApp(
        theme: StoneSetTheme.dark(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: TodayPlanCard(data: today, onAction: () {}),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Retry'), findsOneWidget);
    expect(find.text(today.unavailableReason!), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
