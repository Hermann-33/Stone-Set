import 'package:flutter/material.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

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
        StoneSetSectionHeader(
          title: 'This week',
          description: 'Seven-day training rhythm.',
          action: TextButton(onPressed: onOpenWeek, child: const Text('View week')),
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
    final semantic = StoneSetSemanticColors.of(context);
    final reducedMotion = StoneSetMotion.reducedMotionOf(context);
    return Semantics(
      button: true,
      selected: data.selected,
      label: '${data.dayLabel} ${data.dateLabel}. ${data.itemLabel}. ${data.status.name}.',
      child: AnimatedContainer(
        duration: reducedMotion ? Duration.zero : StoneSetMotion.standard,
        curve: StoneSetMotion.standardCurve,
        decoration: BoxDecoration(
          color: data.selected ? colors.primary.withValues(alpha: 0.14) : semantic.raisedSurface,
          borderRadius: BorderRadius.circular(StoneSetShapes.mobileControlRadius),
          border: Border.all(
            color: data.selected ? colors.primary : semantic.outline.withValues(alpha: 0.62),
            width: data.selected ? 2 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: Key('week-day-${data.dateLabel}'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(StoneSetShapes.mobileControlRadius),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 68),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(data.dayLabel, style: StoneSetTextStyles.of(context).caption),
                      const SizedBox(height: 2),
                      Text(data.dateLabel, style: StoneSetTextStyles.of(context).label),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
