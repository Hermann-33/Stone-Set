import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/scheduling.dart';

import '../../../app/router/mobile_routes.dart';
import '../../progress/providers/progress_providers.dart';
import '../providers/scheduling_providers.dart';

class WeekScreen extends ConsumerStatefulWidget {
  const WeekScreen({super.key});

  @override
  ConsumerState<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends ConsumerState<WeekScreen> {
  String? _firstItemId;
  String? _secondItemId;
  bool _confirming = false;

  @override
  Widget build(BuildContext context) {
    final week = ref.watch(currentWeekProvider);
    final progress = ref.watch(progressSnapshotProvider);
    final rrBalance = progress.when(
      data: (value) => value.account.rrBalance,
      loading: () => null,
      error: (_, _) => null,
    );
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: week.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _WeekError(
            message: 'Week could not be loaded.',
            onRetry: () => ref.invalidate(currentWeekProvider),
          ),
          data: (result) => _buildData(result, rrBalance),
        ),
      ),
    );
  }

  Widget _buildData(WeekLoadResult result, int? rrBalance) {
    if (!result.hasWeek) {
      return _WeekEmpty(
        freeSwapBalance: result.wallet.balance,
        onRetry: () => ref.invalidate(currentWeekProvider),
      );
    }

    final week = result.week!;
    final items = [...week.items]..sort((a, b) => a.currentDate.compareTo(b.currentDate));
    final first = _find(items, _firstItemId);
    final second = _find(items, _secondItemId);
    final hasPayment = result.wallet.balance > 0 || (rrBalance ?? 0) >= 5;
    final canConfirm =
        first != null &&
        second != null &&
        hasPayment &&
        week.swapsRemaining > 0 &&
        !_confirming;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(currentWeekProvider);
        ref.invalidate(progressSnapshotProvider);
        await ref.read(currentWeekProvider.future);
      },
      child: ListView(
        key: const PageStorageKey<String>('mobile-week-scroll'),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: <Widget>[
          Text('Week', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('${_date(week.weekStart)} – ${_date(week.weekEnd)}'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Chip(label: Text('${week.swapsRemaining} swaps remaining')),
              Chip(label: Text('${result.wallet.balance} free swaps')),
              if (rrBalance != null) Chip(label: Text('$rrBalance RR')),
            ],
          ),
          const SizedBox(height: 20),
          for (final item in items) ...<Widget>[
            _WeekItemCard(
              item: item,
              selected: item.id == _firstItemId || item.id == _secondItemId,
              selectionLabel: item.id == _firstItemId
                  ? 'First'
                  : item.id == _secondItemId
                  ? 'Second'
                  : null,
              onTap: item.lockState == TrainingWeekLockState.open ? () => _select(item.id) : null,
              onWorkout: item.isToday && item.isWorkout
                  ? () => MobileWorkoutRoute(planItemId: item.id).go(context)
                  : null,
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          if (first != null && second != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Swap preview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('${_label(first)} → ${_weekday(second.currentDate)}'),
                    Text('${_label(second)} → ${_weekday(first.currentDate)}'),
                    const SizedBox(height: 12),
                    if (result.wallet.balance == 0 && rrBalance != null && rrBalance < 5)
                      const Text('A paid swap needs 5 RR.'),
                    FilledButton(
                      key: const Key('week-confirm-swap'),
                      onPressed: canConfirm ? () => _confirm(week, first, second) : null,
                      child: Text(
                        _confirming
                            ? 'Swapping…'
                            : result.wallet.balance > 0
                            ? 'Use 1 free swap credit'
                            : rrBalance == null
                            ? 'Checking RR…'
                            : rrBalance >= 5
                            ? 'Use 5 RR'
                            : 'Need 5 RR',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _select(String itemId) {
    setState(() {
      if (_firstItemId == itemId) {
        _firstItemId = _secondItemId;
        _secondItemId = null;
      } else if (_secondItemId == itemId) {
        _secondItemId = null;
      } else if (_firstItemId == null) {
        _firstItemId = itemId;
      } else if (_secondItemId == null) {
        _secondItemId = itemId;
      } else {
        _firstItemId = itemId;
        _secondItemId = null;
      }
    });
  }

  Future<void> _confirm(
    TrainingWeek week,
    TrainingWeekItem first,
    TrainingWeekItem second,
  ) async {
    setState(() => _confirming = true);
    try {
      await ref
          .read(schedulingRepositoryProvider)
          .confirmSwap(
            weekId: week.id,
            firstItemId: first.id,
            secondItemId: second.id,
          );
      if (!mounted) return;
      setState(() {
        _firstItemId = null;
        _secondItemId = null;
      });
      ref.invalidate(currentWeekProvider);
      ref.invalidate(progressSnapshotProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Week updated.')));
    } on SchedulingFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_message(error.code))));
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }
}

class _WeekItemCard extends StatelessWidget {
  const _WeekItemCard({
    required this.item,
    required this.selected,
    required this.selectionLabel,
    required this.onTap,
    required this.onWorkout,
  });

  final TrainingWeekItem item;
  final bool selected;
  final String? selectionLabel;
  final VoidCallback? onTap;
  final VoidCallback? onWorkout;

  @override
  Widget build(BuildContext context) {
    final rest = item.itemType == TrainingWeekItemType.rest;
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            key: Key('week-item-${item.id}'),
            onTap: onTap,
            selected: selected,
            leading: CircleAvatar(child: Text(_weekdayShort(item.currentDate))),
            title: Text(
              rest ? 'Rest' : (item.title.isEmpty ? 'Workout' : item.title),
            ),
            subtitle: Text(
              '${_date(item.currentDate)} · ${item.lockState.name}\n'
              '${item.allocatedRr} RR · ${item.allocatedBaseXp} XP',
            ),
            isThreeLine: true,
            trailing: selectionLabel == null ? null : Chip(label: Text(selectionLabel!)),
          ),
          if (onWorkout != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: Key('week-workout-${item.id}'),
                  onPressed: onWorkout,
                  icon: const Icon(Icons.fitness_center),
                  label: Text(
                    item.lockState == TrainingWeekLockState.locked
                        ? 'Continue workout'
                        : 'Start workout',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekEmpty extends StatelessWidget {
  const _WeekEmpty({required this.freeSwapBalance, required this.onRetry});

  final int freeSwapBalance;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'No published routine',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Publish a routine from the dashboard before loading this week.',
          ),
          const SizedBox(height: 8),
          Text('$freeSwapBalance free swap credits available.'),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

class _WeekError extends StatelessWidget {
  const _WeekError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

TrainingWeekItem? _find(List<TrainingWeekItem> items, String? id) {
  if (id == null) return null;
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}

String _label(TrainingWeekItem item) => item.itemType == TrainingWeekItemType.rest
    ? 'Rest'
    : (item.title.isEmpty ? 'Workout' : item.title);

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

String _weekday(DateTime value) => const <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
][value.weekday - 1];

String _weekdayShort(DateTime value) =>
    const <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'][value.weekday - 1];

String _message(String code) => switch (code) {
  'paid_swap_insufficient_rr' => 'You need at least 5 RR for this swap.',
  'free_swap_unavailable' => 'No free swap credit is available.',
  'weekly_swap_limit_reached' => 'Both weekly swaps have already been used.',
  'weekly_item_locked' => 'One of those days is locked.',
  _ => 'The swap could not be completed.',
};
