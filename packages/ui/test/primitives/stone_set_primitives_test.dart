import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

void main() {
  testWidgets('button meets the Android touch target and invokes its callback', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: StoneSetTheme.dark(),
        home: Scaffold(
          body: Center(
            child: StoneSetButton(label: 'Continue', onPressed: () => pressed = true),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(FilledButton)).height, greaterThanOrEqualTo(48));
    await tester.tap(find.text('Continue'));
    expect(pressed, isTrue);
  });

  testWidgets('status banner communicates state without relying on color', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: StoneSetTheme.light(),
          home: const Scaffold(
            body: StoneSetStatusBanner(
              kind: StoneSetStatusKind.pending,
              message: 'Workout validation is pending.',
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Pending. Workout validation is pending.'),
        findsOneWidget,
      );
      expect(find.text('Workout validation is pending.'), findsOneWidget);
      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('metric tile wraps safely at 200 percent text scale', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: StoneSetTheme.dark(),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: StoneSetMetricTile(
                label: 'Lifetime experience points',
                value: '12,450 XP',
                supportingText: 'Finalized server value',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('12,450 XP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skeleton schedules no idle animation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StoneSetTheme.dark(),
        home: const StoneSetSkeleton(width: 120, height: 48),
      ),
    );
    await tester.pump();

    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(find.byType(StoneSetSkeleton), findsOneWidget);
  });

  testWidgets('mobile page hierarchy remains usable at 200 percent text', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: StoneSetTheme.mobileDark(),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  StoneSetPageHeader(
                    eyebrow: 'Private training',
                    title: 'Progress',
                    description: 'Authoritative training history and progression controls.',
                  ),
                  SizedBox(height: 24),
                  StoneSetCard(
                    style: StoneSetCardStyle.hero,
                    child: StoneSetSectionHeader(
                      title: 'Rank progression',
                      description: 'Finalized values only.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Rank progression'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
