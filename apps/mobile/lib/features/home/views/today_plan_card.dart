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
    final colors = StoneSetSemanticColors.of(context);
    final styles = StoneSetTextStyles.of(context);
    final statusKind = _statusKind(data.status);
    return StoneSetCard(
      key: const Key('today-plan-card'),
      style: StoneSetCardStyle.hero,
      accentColor: data.status == TodayPlanItemStatus.active
          ? colors.success
          : Theme.of(context).colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StoneSetIconBadge(
                icon: data.status == TodayPlanItemStatus.rest
                    ? Icons.self_improvement_outlined
                    : Icons.fitness_center_rounded,
                color: data.status == TodayPlanItemStatus.completed
                    ? colors.success
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: StoneSetSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Semantics(
                      header: true,
                      child: Text("Today's plan", style: styles.sectionTitle),
                    ),
                    const SizedBox(height: StoneSetSpacing.xxs),
                    Text(
                      'Your next available training action.',
                      style: styles.caption.copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: StoneSetSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: StoneSetStatusChip(
              kind: statusKind,
              label: _statusLabel(data.status),
            ),
          ),
          const SizedBox(height: StoneSetSpacing.md),
          Text(data.title, style: styles.cardTitle),
          const SizedBox(height: StoneSetSpacing.xs),
          Text(data.purpose, style: styles.body.copyWith(color: colors.textMuted)),
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
          const SizedBox(height: StoneSetSpacing.lg),
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
