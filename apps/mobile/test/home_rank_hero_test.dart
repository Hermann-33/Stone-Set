import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_mobile/features/fixtures/data/home_fixture_service.dart';
import 'package:stone_set_mobile/features/fixtures/models/home_fixture_scenario.dart';
import 'package:stone_set_mobile/features/home/models/home_view_models.dart';
import 'package:stone_set_mobile/features/home/views/home_rank_hero.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

void main() {
  const service = HomeFixtureService();

  testWidgets('reduced motion reaches the exact final value without an idle frame', (tester) async {
    final snapshot = service.load(HomeFixtureScenario.halfProgress).rank;

    await tester.pumpWidget(_hero(snapshot, reducedMotion: true));
    await tester.pump();

    expect(_ringPainter(tester).progress, snapshot.progress);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(find.byKey(const Key('home-rank-hero-repaint-boundary')), findsOneWidget);
  });

  testWidgets('animated progress settles exactly and disposes its ticker', (tester) async {
    final initial = service.load(HomeFixtureScenario.onePercent).rank;
    final updated = service.load(HomeFixtureScenario.ninetyNinePercent).rank;
    final snapshot = ValueNotifier<HomeRankViewData>(initial);
    addTearDown(snapshot.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<HomeRankViewData>(
        valueListenable: snapshot,
        builder: (context, value, _) => _hero(value),
      ),
    );
    await tester.pumpAndSettle();
    expect(_ringPainter(tester).progress, initial.progress);

    snapshot.value = updated;
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpAndSettle();

    expect(_ringPainter(tester).progress, updated.progress);
    expect(tester.binding.hasScheduledFrame, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('hero is one coherent accessible action', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      final snapshot = service.load(HomeFixtureScenario.provisional).rank;

      await tester.pumpWidget(_hero(snapshot, reducedMotion: true));
      await tester.pump();

      final node = tester.getSemantics(find.byKey(const Key('home-rank-hero')));
      expect(node.label, contains('Current rank Platinum II'));
      expect(node.label, contains('45 percent toward Platinum III'));
      expect(node.label, contains('Provisional progress is shown separately'));
      expect(node.label, contains('Pending. 30 RR provisional'));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('max rank resolves to one full authoritative ring', (tester) async {
    final snapshot = service.load(HomeFixtureScenario.maxRank).rank;

    await tester.pumpWidget(_hero(snapshot, reducedMotion: true));
    await tester.pump();

    final painter = _ringPainter(tester);
    expect(painter.progress, 1);
    expect(RankProgressRingGeometry.isComplete(painter.progress), isTrue);
    expect(find.text('MAX RANK'), findsOneWidget);
  });

  testWidgets('RR changes interpolate the displayed authoritative value', (tester) async {
    final initial = service.load(HomeFixtureScenario.standard).rank;
    const updated = HomeRankViewData(
      rankId: StoneSetRankPresentationId.platinumII,
      rankRating: 2030,
      currentMinimum: 1775,
      nextRankId: StoneSetRankPresentationId.platinumIII,
      nextMinimum: 2075,
      progress: 0.85,
      percentageLabel: '85% to Platinum III',
    );
    final snapshot = ValueNotifier<HomeRankViewData>(initial);
    addTearDown(snapshot.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<HomeRankViewData>(
        valueListenable: snapshot,
        builder: (context, value, _) => _hero(value),
      ),
    );
    await tester.pumpAndSettle();
    snapshot.value = updated;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));

    final inFlight = tester.widget<RankProgressHero>(
      find.byKey(const Key('home-rank-hero')),
    );
    expect(inFlight.data.rankRating, greaterThan(initial.rankRating));
    expect(inFlight.data.rankRating, lessThan(updated.rankRating));

    await tester.pumpAndSettle();
    final settled = tester.widget<RankProgressHero>(
      find.byKey(const Key('home-rank-hero')),
    );
    expect(settled.data.rankRating, updated.rankRating);
    expect(_ringPainter(tester).progress, updated.progress);
  });

  testWidgets('rank up completes the old ring before carried progress settles', (tester) async {
    final initial = service.load(HomeFixtureScenario.standard).rank;
    final promoted = service.load(HomeFixtureScenario.threshold).rank;
    final snapshot = ValueNotifier<HomeRankViewData>(initial);
    addTearDown(snapshot.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<HomeRankViewData>(
        valueListenable: snapshot,
        builder: (context, value, _) => _hero(value),
      ),
    );
    await tester.pumpAndSettle();
    snapshot.value = promoted;
    await tester.pump();
    expect(find.byKey(const Key('home-rank-up-treatment')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    expect(_ringPainter(tester).progress, greaterThan(0.9));

    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-rank-up-treatment')), findsNothing);
    expect(_ringPainter(tester).progress, promoted.progress);
    expect(find.text('PLATINUM III'), findsOneWidget);
  });

  testWidgets('rank down uses a neutral finite adjustment', (tester) async {
    final initial = service.load(HomeFixtureScenario.standard).rank;
    final adjusted = service.load(HomeFixtureScenario.rankDown).rank;
    final snapshot = ValueNotifier<HomeRankViewData>(initial);
    addTearDown(snapshot.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<HomeRankViewData>(
        valueListenable: snapshot,
        builder: (context, value, _) => _hero(value),
      ),
    );
    await tester.pumpAndSettle();
    snapshot.value = adjusted;
    await tester.pump();
    expect(find.byKey(const Key('home-rank-up-treatment')), findsNothing);
    await tester.pumpAndSettle();

    expect(_ringPainter(tester).progress, adjusted.progress);
    expect(find.text('PLATINUM I'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('reduced motion applies rank changes immediately', (tester) async {
    final initial = service.load(HomeFixtureScenario.standard).rank;
    final promoted = service.load(HomeFixtureScenario.threshold).rank;
    final snapshot = ValueNotifier<HomeRankViewData>(initial);
    addTearDown(snapshot.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<HomeRankViewData>(
        valueListenable: snapshot,
        builder: (context, value, _) => _hero(value, reducedMotion: true),
      ),
    );
    await tester.pump();
    snapshot.value = promoted;
    await tester.pump();

    expect(_ringPainter(tester).progress, promoted.progress);
    expect(find.byKey(const Key('home-rank-up-treatment')), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}

Widget _hero(HomeRankViewData snapshot, {bool reducedMotion = false}) {
  return MaterialApp(
    theme: StoneSetTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reducedMotion),
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: HomeRankHero(snapshot: snapshot, onTap: () {}),
          ),
        ),
      ),
    ),
  );
}

RankProgressRingPainter _ringPainter(WidgetTester tester) {
  final customPaint = tester.widget<CustomPaint>(
    find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is RankProgressRingPainter,
    ),
  );
  return customPaint.painter! as RankProgressRingPainter;
}
