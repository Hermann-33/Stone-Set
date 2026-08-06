import 'package:flutter/material.dart';

import '../models/home_view_models.dart';

class CompactWeekStrip extends StatelessWidget {
  const CompactWeekStrip({
    required this.days,
    required this.onOpenWeek,
    super.key,
  });

  final List<WeekDayViewData> days;
  final VoidCallback onOpenWeek;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Semantics(
                header: true,
                child: Text('This week', style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            TextButton(onPressed: onOpenWeek, child: const Text('View week')),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 360 ? 7 : 4;
            const gap = 4.0;
            final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: 8,
              children: <Widget>[
                for (final day in days)
                  SizedBox(
                    width: width,
                    child: _WeekDayTile(data: day, onTap: onOpenWeek),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WeekDayTile extends StatelessWidget {
  const _WeekDayTile({required this.data, required this.onTap});

  final WeekDayViewData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: data.selected,
      label: '${data.dayLabel} ${data.dateLabel}. ${data.itemLabel}. ${data.status.name}.',
      child: Material(
        color: data.selected ? colors.secondaryContainer : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: Key('week-day-${data.dateLabel}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: ExcludeSemantics(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(data.dayLabel, style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 2),
                    Text(data.dateLabel, style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
