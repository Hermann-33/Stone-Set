import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../../app/router/mobile_routes.dart';
import '../../fixtures/data/home_fixture_service.dart';
import '../../fixtures/models/home_fixture_scenario.dart';
import '../../identity/controllers/mobile_session_controller.dart';
import '../controllers/home_controller.dart';
import '../models/home_view_models.dart';
import 'compact_week_strip.dart';
import 'home_rank_hero.dart';
import 'home_state_banner.dart';
import 'today_plan_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    this.scenario = HomeFixtureScenario.standard,
    this.useLiveSchedule = false,
    super.key,
  });

  final HomeFixtureScenario scenario;
  final bool useLiveSchedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(mobileSessionControllerProvider).value;
    final userId = session?.userId;
    if (userId == null) {
      return const SizedBox.shrink();
    }
    final request = HomeRequest(
      userId: userId,
      scenario: scenario,
      useLiveSchedule: useLiveSchedule,
    );
    final home = ref.watch(homeControllerProvider(request));
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: home.when(
          loading: () => const _HomeLoadingView(),
          error: (error, _) => _HomeErrorView(
            message: error is HomeFixtureFailure
                ? error.message
                : 'The preview could not be loaded.',
            onRetry: () => ref.invalidate(homeControllerProvider(request)),
          ),
          data: (data) => _HomeContent(
            data: data,
            displayName: session?.bootstrap?.profile.displayName ?? 'Stone Set member',
            onRetry: () => ref.invalidate(homeControllerProvider(request)),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    required this.displayName,
    required this.onRetry,
  });

  final HomeViewData data;
  final String displayName;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _HomeEmptyView(
        onOpenWeek: () => const MobileWeekRoute().go(context),
      );
    }
    return CustomScrollView(
      key: const PageStorageKey<String>('mobile-home-scroll'),
      restorationId: 'mobile-home-scroll',
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          sliver: SliverList.list(
            children: <Widget>[
              _HomeHeader(
                displayName: displayName,
                fixtureLabel: data.fixtureLabel,
              ),
              const SizedBox(height: 16),
              HomeRankHero(
                snapshot: data.rank,
                onTap: () => const MobileRankDetailRoute().go(context),
              ),
              if (data.banner case final banner?) ...<Widget>[
                const SizedBox(height: 16),
                HomeStateBanner(data: banner),
              ],
              const SizedBox(height: 20),
              TodayPlanCard(
                data: data.today,
                onAction: _todayAction(context, data.today.action, onRetry),
              ),
              const SizedBox(height: 24),
              CompactWeekStrip(
                days: data.week,
                onOpenWeek: () => const MobileWeekRoute().go(context),
              ),
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text(
                  'Progress summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              _MetricsGrid(metrics: data.metrics),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                key: const Key('open-fixture-gallery'),
                onPressed: () => const MobileFixtureGalleryRoute().go(context),
                icon: const Icon(Icons.grid_view_outlined),
                label: const Text('Open preview gallery'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  VoidCallback? _todayAction(
    BuildContext context,
    TodayPlanItemAction action,
    VoidCallback retry,
  ) => switch (action) {
    TodayPlanItemAction.start ||
    TodayPlanItemAction.continueWorkout ||
    TodayPlanItemAction.synchronize => () => MobileFixtureWorkoutRoute(
      mode: action.name,
    ).go(context),
    TodayPlanItemAction.viewResult => () => const MobileFixtureResultRoute().go(
      context,
    ),
    TodayPlanItemAction.openWeek => () => const MobileWeekRoute().go(context),
    TodayPlanItemAction.retry => retry,
    TodayPlanItemAction.none => null,
  };
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.displayName, required this.fixtureLabel});

  final String displayName;
  final String fixtureLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Semantics(
                    header: true,
                    child: Text(
                      displayName,
                      key: const Key('home-display-name'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: const Key('home-profile-action'),
              tooltip: 'Open Profile',
              onPressed: () => const MobileProfileRoute().go(context),
              icon: const Icon(Icons.account_circle_outlined),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StoneSetStatusChip(
          kind: StoneSetStatusKind.information,
          label: fixtureLabel,
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics});

  final List<HomeMetricViewData> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final columns = textScale >= 1.5 || constraints.maxWidth < 340 ? 1 : 3;
        const gap = 8.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final metric in metrics)
              SizedBox(
                width: width,
                child: StoneSetMetricTile(
                  label: metric.label,
                  value: metric.value,
                  supportingText: metric.supportingText,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        liveRegion: true,
        label: 'Loading Home preview',
        child: const CircularProgressIndicator(
          key: Key('home-loading-indicator'),
        ),
      ),
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: StoneSetStatusBanner(
          key: const Key('home-error-state'),
          kind: StoneSetStatusKind.error,
          message: message,
          actionLabel: 'Retry',
          onAction: onRetry,
        ),
      ),
    );
  }
}

class _HomeEmptyView extends StatelessWidget {
  const _HomeEmptyView({required this.onOpenWeek});

  final VoidCallback onOpenWeek;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: StoneSetStatusBanner(
          key: const Key('home-empty-state'),
          kind: StoneSetStatusKind.information,
          message: 'No weekly plan is available.',
          actionLabel: 'Open Week',
          onAction: onOpenWeek,
        ),
      ),
    );
  }
}
