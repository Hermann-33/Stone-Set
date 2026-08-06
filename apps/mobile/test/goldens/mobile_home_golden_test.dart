import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_mobile/features/fixtures/data/home_fixture_service.dart';
import 'package:stone_set_mobile/features/fixtures/models/home_fixture_scenario.dart';
import 'package:stone_set_mobile/features/fixtures/views/fixture_gallery_screen.dart';
import 'package:stone_set_mobile/features/home/models/home_view_models.dart';
import 'package:stone_set_mobile/features/home/views/home_rank_hero.dart';
import 'package:stone_set_mobile/features/home/views/home_screen.dart';
import 'package:stone_set_mobile/features/identity/providers/identity_providers.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../support/fake_identity_repository.dart';

void main() {
  const canonicalSurfaces = <Size>[Size(360, 800), Size(412, 915)];
  const themes = <(String, Brightness)>[
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ];
  const textScales = <double>[1, 2];

  for (final surface in canonicalSurfaces) {
    for (final theme in themes) {
      for (final textScale in textScales) {
        final sizeName = '${surface.width.toInt()}x${surface.height.toInt()}';
        final scaleName = '${(textScale * 100).round()}pct';
        testWidgets('Home $sizeName ${theme.$1} $scaleName', (tester) async {
          _configureSurface(tester, surface);
          final repository = FakeIdentityRepository(
            initialSession: const IdentitySession(userId: syntheticUserId, expiresAt: null),
          );
          addTearDown(repository.close);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                identityRepositoryProvider.overrideWithValue(repository),
              ],
              child: _goldenApp(
                brightness: theme.$2,
                textScale: textScale,
                child: const HomeScreen(),
              ),
            ),
          );
          await tester.pump();
          await _precacheRankAssets(tester);
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          await expectLater(
            find.byKey(const Key('golden-surface')),
            matchesGoldenFile('home_${sizeName}_${theme.$1}_$scaleName.png'),
          );
        });
      }
    }
  }

  for (final theme in themes) {
    testWidgets('rank state contact sheet ${theme.$1}', (tester) async {
      _configureSurface(tester, const Size(412, 4600));
      await tester.pumpWidget(
        _goldenApp(
          brightness: theme.$2,
          reducedMotion: true,
          child: const _RankStateContactSheet(),
        ),
      );
      await tester.pump();
      await _precacheRankAssets(tester);
      await tester.pumpAndSettle();

      expect(tester.binding.hasScheduledFrame, isFalse);
      await expectLater(
        find.byKey(const Key('golden-surface')),
        matchesGoldenFile('rank_states_${theme.$1}_reduced_motion.png'),
      );
    });

    testWidgets('all twenty rank assets ${theme.$1}', (tester) async {
      _configureSurface(tester, const Size(412, 2200));
      await tester.pumpWidget(
        _goldenApp(
          brightness: theme.$2,
          child: const FixtureGalleryScreen(),
        ),
      );
      await tester.pump();
      await _precacheRankAssets(tester);
      await tester.pumpAndSettle();

      expect(StoneSetRankAssets.all, hasLength(20));
      await expectLater(
        find.byKey(const Key('golden-surface')),
        matchesGoldenFile('rank_gallery_all_20_${theme.$1}.png'),
      );
    });
  }
}

Future<void> _precacheRankAssets(WidgetTester tester) async {
  final context = tester.element(find.byKey(const Key('golden-surface')));
  for (final asset in StoneSetRankAssets.all) {
    await precacheImage(AssetImage(asset.assetKey), context);
  }
}

void _configureSurface(WidgetTester tester, Size logicalSize) {
  tester.view.physicalSize = logicalSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _goldenApp({
  required Brightness brightness,
  required Widget child,
  double textScale = 1,
  bool reducedMotion = false,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: StoneSetTheme.light(),
    darkTheme: StoneSetTheme.dark(),
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    home: MediaQuery(
      data: MediaQueryData(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: reducedMotion,
        accessibleNavigation: reducedMotion,
      ),
      child: RepaintBoundary(
        key: const Key('golden-surface'),
        child: child,
      ),
    ),
  );
}

class _RankStateContactSheet extends StatelessWidget {
  const _RankStateContactSheet();

  @override
  Widget build(BuildContext context) {
    const service = HomeFixtureService();
    final states = <(String, HomeRankViewData)>[
      ('Bronze I â€” 0%', service.load(HomeFixtureScenario.zeroProgress).rank),
      ('Platinum II â€” 1%', service.load(HomeFixtureScenario.onePercent).rank),
      ('Platinum II â€” 50%', service.load(HomeFixtureScenario.halfProgress).rank),
      ('Platinum II â€” 99%', service.load(HomeFixtureScenario.ninetyNinePercent).rank),
      (
        'Platinum II â€” 100%',
        const HomeRankViewData(
          rankId: StoneSetRankPresentationId.platinumII,
          rankRating: 2075,
          currentMinimum: 1775,
          nextRankId: StoneSetRankPresentationId.platinumIII,
          nextMinimum: 2075,
          progress: 1,
          percentageLabel: '100% to Platinum III',
        ),
      ),
      ('Threshold â€” new rank', service.load(HomeFixtureScenario.threshold).rank),
      ('Provisional', service.load(HomeFixtureScenario.provisional).rank),
      ('Pending sync', service.load(HomeFixtureScenario.pendingSynchronization).rank),
      ('Adonis â€” max rank', service.load(HomeFixtureScenario.maxRank).rank),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: states.length,
          separatorBuilder: (_, _) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final state = states[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(state.$1, style: Theme.of(context).textTheme.titleMedium),
                HomeRankHero(snapshot: state.$2, onTap: () {}),
              ],
            );
          },
        ),
      ),
    );
  }
}
