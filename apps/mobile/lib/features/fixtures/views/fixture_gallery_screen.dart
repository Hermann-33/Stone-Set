import 'package:flutter/material.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../../app/router/mobile_routes.dart';
import '../models/home_fixture_scenario.dart';

class FixtureGalleryScreen extends StatelessWidget {
  const FixtureGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview gallery')),
      body: SafeArea(
        child: CustomScrollView(
          key: const Key('fixture-gallery'),
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Semantics(
                      header: true,
                      child: Text('Home states', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Every state below uses deterministic presentation-only data.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        for (final scenario in HomeFixtureScenario.values)
                          ActionChip(
                            key: Key('home-fixture-${scenario.name}'),
                            avatar: const Icon(Icons.visibility_outlined, size: 18),
                            label: Text(_scenarioLabel(scenario)),
                            onPressed: () => MobileFixtureHomeRoute(
                              scenario: scenario.name,
                            ).go(context),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      header: true,
                      child: Text('Rank emblems', style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverGrid.builder(
                key: const Key('rank-fixture-gallery'),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  mainAxisExtent: 196,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: StoneSetRankAssets.all.length,
                itemBuilder: (context, index) {
                  final asset = StoneSetRankAssets.all[index];
                  return StoneSetCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RankEmblem(asset: asset, size: 112),
                        const SizedBox(height: 8),
                        Text(
                          asset.displayName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${asset.minimumRankRating} RR',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _scenarioLabel(HomeFixtureScenario scenario) => switch (scenario) {
  HomeFixtureScenario.standard => 'Standard',
  HomeFixtureScenario.zeroProgress => 'Bronze I — 0%',
  HomeFixtureScenario.onePercent => '1% progress',
  HomeFixtureScenario.halfProgress => '50% progress',
  HomeFixtureScenario.ninetyNinePercent => '99% progress',
  HomeFixtureScenario.threshold => 'Rank threshold',
  HomeFixtureScenario.rankDown => 'Rank adjusted',
  HomeFixtureScenario.provisional => 'Provisional RR',
  HomeFixtureScenario.pendingSynchronization => 'Pending sync',
  HomeFixtureScenario.stale => 'Stale',
  HomeFixtureScenario.offline => 'Offline',
  HomeFixtureScenario.error => 'Error',
  HomeFixtureScenario.maxRank => 'Adonis — max',
  HomeFixtureScenario.activeWorkout => 'Active workout',
  HomeFixtureScenario.completedWorkout => 'Completed workout',
  HomeFixtureScenario.restDay => 'Rest day',
  HomeFixtureScenario.lockedWorkout => 'Locked workout',
  HomeFixtureScenario.unavailableWorkout => 'Unavailable workout',
  HomeFixtureScenario.empty => 'Empty',
};
