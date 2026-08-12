import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../../app/router/mobile_routes.dart';
import '../../fixtures/data/home_fixture_service.dart';
import '../../fixtures/models/home_fixture_scenario.dart';
import '../../identity/controllers/mobile_session_controller.dart';
import '../../sync/controllers/mobile_sync_controller.dart';
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
    final sync = ref.watch(mobileSyncControllerProvider);

    Future<void> refresh() async {
      final coordinator = ref.read(mobileSyncControllerProvider.notifier);
      await coordinator.initializeForOwner(userId);
      await coordinator.synchronize(trigger: MobileSyncTrigger.manualRefresh);
    }

    void retry() {
      if (useLiveSchedule) {
        unawaited(refresh());
      } else {
        ref.invalidate(homeControllerProvider(request));
      }
    }

    Widget content(HomeViewData data) {
      final view = _HomeContent(
        data: data,
        displayName:
            session?.bootstrap?.profile.displayName ?? 'Stone Set member',
        onRetry: retry,
        useLiveSchedule: useLiveSchedule,
        statusLabel: useLiveSchedule ? _syncLabel(sync) : data.fixtureLabel,
        statusKind: useLiveSchedule
            ? _syncKind(sync)
            : StoneSetStatusKind.information,
      );
      if (!useLiveSchedule) return view;
      return RefreshIndicator(
        key: const Key('home-refresh-indicator'),
        onRefresh: refresh,
        child: view,
      );
    }

    final retained = home.value;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: StoneSetBackdrop(
        child: SafeArea(
          child: retained != null
              ? content(retained)
              : home.when(
                  loading: () => const _HomeLoadingView(),
                  error: (error, _) => _HomeErrorView(
                    message: error is HomeFixtureFailure
                        ? error.message
                        : useLiveSchedule
                        ? 'No cached Home data is available yet. Connect to the internet and retry.'
                        : 'The preview could not be loaded.',
                    onRetry: retry,
                  ),
                  data: content,
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
    required this.useLiveSchedule,
    required this.statusLabel,
    required this.statusKind,
  });

  final HomeViewData data;
  final String displayName;
  final VoidCallback onRetry;
  final bool useLiveSchedule;
  final String statusLabel;
  final StoneSetStatusKind statusKind;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return CustomScrollView(
        key: const PageStorageKey<String>('mobile-home-empty-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverFillRemaining(
            hasScrollBody: false,
            child: _HomeEmptyView(
              onOpenWeek: () => const MobileWeekRoute().go(context),
            ),
          ),
        ],
      );
    }
    return CustomScrollView(
      key: const PageStorageKey<String>('mobile-home-scroll'),
      restorationId: 'mobile-home-scroll',
      physics: useLiveSchedule ? const AlwaysScrollableScrollPhysics() : null,
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          sliver: SliverList.list(
            children: <Widget>[
              _HomeHeader(
                displayName: displayName,
                statusLabel: statusLabel,
                statusKind: statusKind,
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
                onAction: _todayAction(context, data.today, onRetry),
              ),
              const SizedBox(height: 24),
              CompactWeekStrip(
                days: data.week,
                onOpenWeek: () => const MobileWeekRoute().go(context),
              ),
              const SizedBox(height: 24),
              const StoneSetSectionHeader(
                title: 'Progress summary',
                description: 'Finalized training and rank signals.',
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
    TodayPlanItemViewData item,
    VoidCallback retry,
  ) {
    final action = item.action;
    if (useLiveSchedule && action == TodayPlanItemAction.viewResult) {
      return () => const MobileProgressRoute().go(context);
    }
    if (useLiveSchedule &&
        item.sourcePlanItemId != null &&
        (action == TodayPlanItemAction.start ||
            action == TodayPlanItemAction.continueWorkout ||
            action == TodayPlanItemAction.synchronize)) {
      return () =>
          MobileWorkoutRoute(planItemId: item.sourcePlanItemId!).go(context);
    }
    return switch (action) {
      TodayPlanItemAction.start ||
      TodayPlanItemAction.continueWorkout ||
      TodayPlanItemAction.synchronize => () => MobileFixtureWorkoutRoute(
        mode: action.name,
      ).go(context),
      TodayPlanItemAction.viewResult =>
        () => const MobileFixtureResultRoute().go(context),
      TodayPlanItemAction.openWeek => () => const MobileWeekRoute().go(context),
      TodayPlanItemAction.retry => retry,
      TodayPlanItemAction.none => null,
    };
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.displayName,
    required this.statusLabel,
    required this.statusKind,
  });

  final String displayName;
  final String statusLabel;
  final StoneSetStatusKind statusKind;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StoneSetPageHeader(
          eyebrow: 'Welcome back',
          title: displayName,
          trailing: IconButton.filledTonal(
            key: const Key('home-profile-action'),
            tooltip: 'Open Profile',
            onPressed: () => const MobileProfileRoute().go(context),
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 8),
        StoneSetStatusChip(
          key: const Key('home-sync-status'),
          kind: statusKind,
          label: statusLabel,
        ),
      ],
    );
  }
}

String _syncLabel(MobileSyncState state) {
  if (state.isRunning) return 'Synchronizing…';
  if (state.pendingMutationCount > 0) {
    return state.pendingMutationCount == 1
        ? '1 workout waiting to sync'
        : '${state.pendingMutationCount} workouts waiting to sync';
  }
  if (state.lastFailureCode != null) {
    final last = state.lastSuccessfulSyncAt;
    return last == null
        ? 'Offline · Cached data'
        : 'Offline · Last synchronized ${_clock(last)}';
  }
  final last = state.lastSuccessfulSyncAt;
  return last == null ? 'Cached data' : 'Synchronized ${_clock(last)}';
}

StoneSetStatusKind _syncKind(MobileSyncState state) {
  if (state.isRunning || state.pendingMutationCount > 0)
    return StoneSetStatusKind.pending;
  if (state.lastFailureCode != null) return StoneSetStatusKind.information;
  return state.lastSuccessfulSyncAt == null
      ? StoneSetStatusKind.information
      : StoneSetStatusKind.success;
}

String _clock(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
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
