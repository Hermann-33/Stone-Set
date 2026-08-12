import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../sync/controllers/mobile_sync_controller.dart';
import '../providers/progress_providers.dart';
import '../providers/progression_providers.dart';
import 'progression_section.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(progressSnapshotProvider);

    Future<void> refresh() async {
      final synchronized = await ref
          .read(mobileSyncControllerProvider.notifier)
          .synchronize(trigger: MobileSyncTrigger.manualRefresh);
      if (synchronized) {
        ref.invalidate(progressionSnapshotProvider);
      }
    }

    final retained = snapshot.value;
    return StoneSetBackdrop(
      child: SafeArea(
        child: retained != null
            ? RefreshIndicator(
                key: const Key('progress-refresh-indicator'),
                onRefresh: refresh,
                child: _ProgressBody(snapshot: retained),
              )
            : snapshot.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ProgressError(
                  onRetry: () => unawaited(refresh()),
                ),
                data: (value) => RefreshIndicator(
                  key: const Key('progress-refresh-indicator'),
                  onRefresh: refresh,
                  child: _ProgressBody(snapshot: value),
                ),
              ),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.snapshot});

  final ProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final account = snapshot.account;
    final rank = StoneSetRankAssets.parse(account.rankId);
    final next = account.nextRankId == null ? null : StoneSetRankAssets.parse(account.nextRankId!);
    return ListView(
      key: const PageStorageKey<String>('progress-scroll'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: <Widget>[
        const StoneSetPageHeader(
          eyebrow: 'Authoritative history',
          title: 'Progress',
          description: 'Rank, progression and finalized workout evidence.',
        ),
        const SizedBox(height: 16),
        StoneSetCard(
          key: const Key('progress-rank-card'),
          style: StoneSetCardStyle.hero,
          accentColor: StoneSetRankPalette.forFamily(rank.family).highlight,
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: StoneSetRankPalette.forFamily(
                      rank.family,
                    ).base.withValues(alpha: 0.10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(StoneSetSpacing.xs),
                    child: Image.asset(
                      rank.assetKey,
                      width: constraints.maxWidth < 340 ? 58 : 76,
                      height: constraints.maxWidth < 340 ? 58 : 76,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(rank.displayName, style: StoneSetTextStyles.of(context).sectionTitle),
                      const SizedBox(height: 4),
                      Text(
                        '${account.rrBalance} RR',
                        style: StoneSetTextStyles.of(context).dataValue,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: account.progress),
                      const SizedBox(height: 6),
                      Text(
                        next == null
                            ? 'Max rank'
                            : '${(account.progress * 100).round()}% to ${next.displayName}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < 340 || MediaQuery.textScalerOf(context).scale(1) >= 1.5;
            final cards = <Widget>[
              _MetricCard(
                key: const Key('progress-rr-card'),
                label: 'Rank rating',
                value: '${account.rrBalance} RR',
              ),
              _MetricCard(
                key: const Key('progress-xp-card'),
                label: 'Lifetime XP',
                value: '${account.lifetimeXp}',
              ),
              _MetricCard(
                key: const Key('progress-multiplier-card'),
                label: 'Consistency multiplier',
                value: '${account.activeConsistencyMultiplier.toStringAsFixed(2)}×',
              ),
            ];
            if (stacked) {
              return Column(
                children: <Widget>[
                  cards.first,
                  for (final card in cards.skip(1)) ...<Widget>[
                    const SizedBox(height: StoneSetSpacing.sm),
                    card,
                  ],
                ],
              );
            }
            return Wrap(
              spacing: StoneSetSpacing.sm,
              runSpacing: StoneSetSpacing.sm,
              children: <Widget>[
                for (final card in cards)
                  SizedBox(width: (constraints.maxWidth - StoneSetSpacing.sm) / 2, child: card),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const ProgressionSection(),
        const SizedBox(height: 24),
        const StoneSetSectionHeader(
          title: 'Rank ladder',
          description: 'Server-defined thresholds from Bronze I to Adonis.',
        ),
        const SizedBox(height: 8),
        StoneSetCard(
          style: StoneSetCardStyle.base,
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              for (final definition in snapshot.ranks)
                ListTile(
                  dense: true,
                  leading: definition.id == account.rankId ? const Icon(Icons.check_circle) : null,
                  title: Text(definition.displayName),
                  trailing: Text('${definition.minimumRr} RR'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const StoneSetSectionHeader(
          title: 'Recent activity',
          description: 'Finalized RR and XP ledger entries.',
        ),
        const SizedBox(height: 8),
        if (snapshot.transactions.isEmpty)
          const StoneSetStatePanel(
            title: 'No reward activity yet',
            message: 'Finalized RR and XP entries will appear here.',
            icon: Icons.receipt_long_outlined,
          )
        else
          StoneSetCard(
            key: const Key('progress-transactions'),
            style: StoneSetCardStyle.base,
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                for (final transaction in snapshot.transactions.take(20))
                  ListTile(
                    dense: true,
                    leading: Icon(
                      transaction.delta < 0
                          ? Icons.remove_circle_outline
                          : Icons.add_circle_outline,
                    ),
                    title: Text(_transactionLabel(transaction)),
                    subtitle: Text(_dateTimeLabel(transaction.createdAt)),
                    trailing: Text(
                      '${transaction.delta > 0 ? '+' : ''}${transaction.delta} '
                      '${transaction.kind == ProgressTransactionKind.rr ? 'RR' : 'XP'}',
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        const StoneSetSectionHeader(
          title: 'Workout history',
          description: 'Authoritatively submitted session results.',
        ),
        const SizedBox(height: 8),
        if (snapshot.workouts.isEmpty)
          const StoneSetStatePanel(
            title: 'No submitted workouts yet',
            message: 'Completed and partial submissions will appear here.',
            icon: Icons.history_toggle_off_outlined,
          )
        else
          StoneSetCard(
            key: const Key('progress-workout-history'),
            style: StoneSetCardStyle.base,
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                for (final workout in snapshot.workouts.take(20))
                  ListTile(
                    leading: Icon(
                      workout.status == WorkoutHistoryStatus.completed
                          ? Icons.check_circle_outline
                          : Icons.timelapse,
                    ),
                    title: Text(
                      workout.status == WorkoutHistoryStatus.completed
                          ? 'Workout completed'
                          : 'Partial workout',
                    ),
                    subtitle: Text(_dateLabel(workout.date)),
                    trailing: Text(
                      '${workout.completedSets}/${workout.plannedSets} sets',
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => StoneSetCard(
    style: StoneSetCardStyle.base,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: StoneSetTextStyles.of(context).label),
        const SizedBox(height: 6),
        Text(value, style: StoneSetTextStyles.of(context).dataValue),
      ],
    ),
  );
}

class _ProgressError extends StatelessWidget {
  const _ProgressError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: StoneSetStatePanel(
        title: 'Progress unavailable',
        message: 'No cached Progress data is available yet. Connect to the internet and retry.',
        icon: Icons.query_stats_outlined,
        actionLabel: 'Retry',
        onAction: onRetry,
      ),
    ),
  );
}

String _transactionLabel(ProgressTransaction value) => switch (value.sourceType) {
  'workout_reward' => 'Workout reward',
  'rest_reward' => 'Rest-day reward',
  'missed_workout' => 'Missed workout',
  'paid_swap' => 'Paid weekly swap',
  'manual_correction' => 'Manual correction',
  _ => value.sourceType,
};

String _dateLabel(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

String _dateTimeLabel(DateTime value) => _dateLabel(value.toLocal());
