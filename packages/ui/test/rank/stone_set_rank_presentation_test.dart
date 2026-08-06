import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

void main() {
  test('catalog is closed, ordered, explicit, and presentation-only', () {
    expect(StoneSetRankAssets.all, hasLength(20));
    expect(
      StoneSetRankAssets.all.map((asset) => asset.id).toSet(),
      hasLength(20),
    );
    expect(
      StoneSetRankAssets.all.map((asset) => asset.fileName).toSet(),
      hasLength(20),
    );
    for (var index = 0; index < StoneSetRankAssets.all.length; index++) {
      final asset = StoneSetRankAssets.all[index];
      expect(asset.order, index + 1);
      expect(
        asset.assetKey,
        '.dart_tool/stone_set_assets/ranks/${asset.fileName}',
      );
      expect(StoneSetRankAssets.parse(asset.id.wireId), same(asset));
      expect(StoneSetRankAssets.byId(asset.id), same(asset));
    }
    expect(
      () => StoneSetRankAssets.parse('future_server_rank'),
      throwsArgumentError,
    );
    expect(StoneSetRankAssets.all.first.minimumRankRating, 0);
    expect(StoneSetRankAssets.all.last.minimumRankRating, 5500);
  });

  test('ring geometry clamps and uses a clockwise sweep from twelve o’clock', () {
    expect(RankProgressRingGeometry.startAngle, closeTo(-math.pi / 2, 0.000001));
    expect(RankProgressRingGeometry.sweep(-1), 0);
    expect(RankProgressRingGeometry.sweep(0.5), closeTo(math.pi, 0.000001));
    expect(RankProgressRingGeometry.sweep(2), closeTo(math.pi * 2, 0.000001));
    expect(RankProgressRingGeometry.isComplete(0.99), isFalse);
    expect(RankProgressRingGeometry.isComplete(1), isTrue);
  });

  test('painter repaints only when its visual inputs change', () {
    const original = RankProgressRingPainter(
      progress: 0.5,
      trackColor: Colors.black,
      activeColor: Colors.white,
    );
    const same = RankProgressRingPainter(
      progress: 0.5,
      trackColor: Colors.black,
      activeColor: Colors.white,
    );
    const changed = RankProgressRingPainter(
      progress: 1,
      trackColor: Colors.black,
      activeColor: Colors.white,
    );
    expect(same.shouldRepaint(original), isFalse);
    expect(changed.shouldRepaint(original), isTrue);
  });

  testWidgets('hero exposes one coherent zero-percent semantic action and no idle ticker', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      var tapped = false;
      final data = RankProgressHeroData(
        asset: StoneSetRankAssets.byId(StoneSetRankPresentationId.bronzeI),
        rankRating: 0,
        progressFraction: 0,
        nextRankName: 'Bronze II',
        nextRankThreshold: 100,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: StoneSetTheme.dark(),
          home: Scaffold(
            body: RankProgressHero(
              key: const Key('hero'),
              data: data,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.bySemanticsLabel(
          'Current rank Bronze I. 0 rank rating. 0 percent toward Bronze II at 100 rank rating.',
        ),
        findsOneWidget,
      );
      expect(find.byType(RepaintBoundary), findsWidgets);
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.tap(find.byKey(const Key('hero')));
      expect(tapped, isTrue);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('max-rank hero is full and remains safe at 200 percent text scale', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final data = RankProgressHeroData(
      asset: StoneSetRankAssets.byId(StoneSetRankPresentationId.adonis),
      rankRating: 5500,
      progressFraction: 0,
      isMaxRank: true,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: StoneSetTheme.light(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(child: RankProgressHero(data: data)),
          ),
        ),
      ),
    );
    await tester.pump();

    final painter = tester.widget<CustomPaint>(find.byType(CustomPaint).last).painter;
    expect(painter, isA<RankProgressRingPainter>());
    expect((painter! as RankProgressRingPainter).progress, 1);
    expect(find.text('MAX RANK'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
