import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../providers/progress_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(progressSnapshotProvider);
    return SafeArea(
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ProgressError(
          onRetry: () => ref.invalidate(progressSnapshotProvider),
        ),
        data: (value) => RefreshIndicator(
          onRefresh: () => ref.refresh(progressSnapshotProvider.future),
          child: _ProgressBody(snapshot: value),
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
        Text('Progress', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Card(
          key: const Key('progress-rank-card'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Image.asset(rank.assetKey, width: 72, height: 72),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(rank.displayName, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('${account.rrBalance} RR'),
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
        Row(
          children: <Widget>[
            Expanded(
              child: _MetricCard(
                key: const Key('progress-rr-card'),
                label: 'Rank rating',
                value: '${account.rrBalance} RR',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                key: const Key('progress-xp-card'),
                label: 'Lifetime XP',
                value: '${account.lifetimeXp}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Rank ladder', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
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
        Text('Recent activity', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (snapshot.transactions.isEmpty)
          const Card(child: ListTile(title: Text('No reward activity yet.')))
        else
          Card(
            key: const Key('progress-transactions'),
            child: Column(
              children: <Widget>[
                for (final transaction in snapshot.transactions.take(20))
                  ListTile(
                    dense: true,
                    leading: Icon(
                      transaction.delta < 0 ? Icons.remove_circle_outline : Icons.add_circle_outline,
                    ),
                    title: Text(_transactionLabel(transaction)),
                    subtitle: Text(_dateTimeLabel(transaction.createdAt)),
                    trailing: Text('${transaction.delta > 0 ? '+' : ''}${transaction.delta} ${transaction.kind == ProgressTransactionKind.rr ? 'RR' : 'XP'}'),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        Text('Workout history', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (snapshot.workouts.isEmpty)
          const Card(child: ListTile(title: Text('No submitted workouts yet.')))
        else
          Card(
            key: const Key('progress-workout-history'),
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
                    trailing: Text('${workout.completedSets}/${workout.plannedSets} sets'),
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
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Progress could not be loaded.', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

String _transactionLabel(ProgressTransaction value) => switch (value.sourceType) {
  'workout_reward' => 'Workout reward',
  'rest_reward' => 'Rest-day reward',
  'missed_workout' => 'Missed workout',
  'paid_swap' => 'Paid weekly swap',
  _ => value.sourceType,
};

String _dateLabel(DateTime value) => '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

String _dateTimeLabel(DateTime value) => _dateLabel(value.toLocal());
