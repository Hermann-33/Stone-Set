import 'package:flutter/material.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../models/home_view_models.dart';

class TodayPlanCard extends StatelessWidget {
  const TodayPlanCard({
    required this.data,
    required this.onAction,
    super.key,
  });

  final TodayPlanItemViewData data;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return StoneSetCard(
      key: const Key('today-plan-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text("Today's plan", style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: StoneSetStatusChip(
              kind: _statusKind(data.status),
              label: _statusLabel(data.status),
            ),
          ),
          const SizedBox(height: 16),
          Text(data.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(data.purpose),
          if (data.estimatedDuration case final duration?) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Icon(Icons.schedule_outlined, size: 20),
                const SizedBox(width: 8),
                Text(duration),
              ],
            ),
          ],
          if (data.unavailableReason case final reason?) ...<Widget>[
            const SizedBox(height: 12),
            Text(reason, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            key: Key('today-action-${data.action.name}'),
            onPressed: data.actionEnabled ? onAction : null,
            icon: Icon(_actionIcon(data.action)),
            label: Text(data.actionLabel),
          ),
        ],
      ),
    );
  }
}

StoneSetStatusKind _statusKind(TodayPlanItemStatus status) => switch (status) {
  TodayPlanItemStatus.available => StoneSetStatusKind.information,
  TodayPlanItemStatus.active => StoneSetStatusKind.success,
  TodayPlanItemStatus.pendingSynchronization => StoneSetStatusKind.pending,
  TodayPlanItemStatus.completed => StoneSetStatusKind.success,
  TodayPlanItemStatus.rest => StoneSetStatusKind.information,
  TodayPlanItemStatus.locked => StoneSetStatusKind.warning,
  TodayPlanItemStatus.unavailable => StoneSetStatusKind.error,
};

String _statusLabel(TodayPlanItemStatus status) => switch (status) {
  TodayPlanItemStatus.available => 'Available',
  TodayPlanItemStatus.active => 'In progress',
  TodayPlanItemStatus.pendingSynchronization => 'Pending sync',
  TodayPlanItemStatus.completed => 'Completed',
  TodayPlanItemStatus.rest => 'Rest day',
  TodayPlanItemStatus.locked => 'Schedule locked',
  TodayPlanItemStatus.unavailable => 'Unavailable',
};

IconData _actionIcon(TodayPlanItemAction action) => switch (action) {
  TodayPlanItemAction.start => Icons.play_arrow,
  TodayPlanItemAction.continueWorkout => Icons.play_circle_outline,
  TodayPlanItemAction.synchronize => Icons.sync,
  TodayPlanItemAction.viewResult => Icons.receipt_long_outlined,
  TodayPlanItemAction.openWeek => Icons.calendar_view_week_outlined,
  TodayPlanItemAction.retry => Icons.refresh,
  TodayPlanItemAction.none => Icons.lock_outline,
};
