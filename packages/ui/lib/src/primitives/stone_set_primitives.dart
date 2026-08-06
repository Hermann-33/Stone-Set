import 'package:flutter/material.dart';

import '../theme/stone_set_theme.dart';

enum StoneSetButtonKind { primary, secondary, quiet, destructive }

class StoneSetButton extends StatelessWidget {
  const StoneSetButton({
    required this.label,
    required this.onPressed,
    this.kind = StoneSetButtonKind.primary,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final StoneSetButtonKind kind;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size(StoneSetSpacing.minimumTouchTarget, StoneSetSpacing.minimumTouchTarget),
      ),
      foregroundColor: kind == StoneSetButtonKind.destructive
          ? WidgetStatePropertyAll(Theme.of(context).colorScheme.error)
          : null,
    );
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 20),
              const SizedBox(width: StoneSetSpacing.xs),
              Flexible(child: Text(label)),
            ],
          );
    return switch (kind) {
      StoneSetButtonKind.primary => FilledButton(onPressed: onPressed, style: style, child: child),
      StoneSetButtonKind.secondary => OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
      StoneSetButtonKind.quiet || StoneSetButtonKind.destructive => TextButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    };
  }
}

class StoneSetCard extends StatelessWidget {
  const StoneSetCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(StoneSetSpacing.md),
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = StoneSetSemanticColors.of(context);
    final content = Padding(padding: padding, child: child);
    return Material(
      color: colors.raisedSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StoneSetShapes.cardRadius),
        side: BorderSide(color: colors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: StoneSetSpacing.minimumTouchTarget,
                ),
                child: content,
              ),
            ),
    );
  }
}

enum StoneSetStatusKind {
  information,
  success,
  warning,
  error,
  pending,
  provisional,
  stale,
  offline,
  conflict,
}

({Color color, IconData icon, String semanticName}) _statusVisuals(
  BuildContext context,
  StoneSetStatusKind kind,
) {
  final colors = StoneSetSemanticColors.of(context);
  return switch (kind) {
    StoneSetStatusKind.information => (
      color: colors.information,
      icon: Icons.info_outline,
      semanticName: 'Information',
    ),
    StoneSetStatusKind.success => (
      color: colors.success,
      icon: Icons.check_circle_outline,
      semanticName: 'Success',
    ),
    StoneSetStatusKind.warning => (
      color: colors.warning,
      icon: Icons.warning_amber_outlined,
      semanticName: 'Warning',
    ),
    StoneSetStatusKind.error => (
      color: colors.destructive,
      icon: Icons.error_outline,
      semanticName: 'Error',
    ),
    StoneSetStatusKind.pending => (
      color: colors.pending,
      icon: Icons.schedule_outlined,
      semanticName: 'Pending',
    ),
    StoneSetStatusKind.provisional => (
      color: colors.provisional,
      icon: Icons.change_circle_outlined,
      semanticName: 'Provisional',
    ),
    StoneSetStatusKind.stale => (
      color: colors.stale,
      icon: Icons.history_outlined,
      semanticName: 'Stale',
    ),
    StoneSetStatusKind.offline => (
      color: colors.stale,
      icon: Icons.cloud_off_outlined,
      semanticName: 'Offline',
    ),
    StoneSetStatusKind.conflict => (
      color: colors.conflict,
      icon: Icons.compare_arrows_outlined,
      semanticName: 'Conflict',
    ),
  };
}

class StoneSetStatusBanner extends StatelessWidget {
  const StoneSetStatusBanner({
    required this.kind,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : assert((actionLabel == null) == (onAction == null));

  final StoneSetStatusKind kind;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final visual = _statusVisuals(context, kind);
    return Semantics(
      container: true,
      liveRegion: true,
      explicitChildNodes: true,
      label: '${visual.semanticName}. $message',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: visual.color.withValues(alpha: 0.12),
          border: Border.all(color: visual.color),
          borderRadius: BorderRadius.circular(StoneSetShapes.controlRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(StoneSetSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExcludeSemantics(
                child: Icon(visual.icon, color: visual.color),
              ),
              const SizedBox(width: StoneSetSpacing.sm),
              Expanded(child: ExcludeSemantics(child: Text(message))),
              if (actionLabel != null) ...<Widget>[
                const SizedBox(width: StoneSetSpacing.xs),
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StoneSetStatusChip extends StatelessWidget {
  const StoneSetStatusChip({required this.kind, required this.label, super.key});

  final StoneSetStatusKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final visual = _statusVisuals(context, kind);
    return Semantics(
      label: '${visual.semanticName}. $label',
      child: ExcludeSemantics(
        child: Chip(
          avatar: Icon(visual.icon, color: visual.color, size: 18),
          label: Text(label),
          side: BorderSide(color: visual.color),
        ),
      ),
    );
  }
}

class StoneSetMetricTile extends StatelessWidget {
  const StoneSetMetricTile({
    required this.label,
    required this.value,
    this.supportingText,
    super.key,
  });

  final String label;
  final String value;
  final String? supportingText;

  @override
  Widget build(BuildContext context) => StoneSetCard(
    child: Semantics(
      container: true,
      label: '$label, $value${supportingText == null ? '' : ', $supportingText'}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(label, style: StoneSetTextStyles.of(context).caption),
            const SizedBox(height: StoneSetSpacing.xs),
            Text(value, style: StoneSetTextStyles.of(context).dataValue),
            if (supportingText != null) ...<Widget>[
              const SizedBox(height: StoneSetSpacing.xxs),
              Text(supportingText!, style: StoneSetTextStyles.of(context).compactBody),
            ],
          ],
        ),
      ),
    ),
  );
}

class StoneSetStatePanel extends StatelessWidget {
  const StoneSetStatePanel({
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : assert((actionLabel == null) == (onAction == null));

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => StoneSetCard(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 32),
        const SizedBox(height: StoneSetSpacing.sm),
        Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
        const SizedBox(height: StoneSetSpacing.xs),
        Text(message, textAlign: TextAlign.center),
        if (actionLabel != null) ...<Widget>[
          const SizedBox(height: StoneSetSpacing.md),
          StoneSetButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    ),
  );
}

/// A motion-free structural placeholder safe for reduced-motion mode.
class StoneSetSkeleton extends StatelessWidget {
  const StoneSetSkeleton({required this.width, required this.height, super.key});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: StoneSetSemanticColors.of(context).interactiveSurface,
          borderRadius: BorderRadius.circular(StoneSetShapes.controlRadius),
        ),
      ),
    ),
  );
}

class StoneSetStatusIndicator extends StatelessWidget {
  const StoneSetStatusIndicator({required this.kind, required this.label, super.key});

  final StoneSetStatusKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final visual = _statusVisuals(context, kind);
    return Semantics(
      label: '${visual.semanticName}. $label',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(visual.icon, color: visual.color, size: 18),
            const SizedBox(width: StoneSetSpacing.xs),
            Flexible(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

class StoneSetNavigationItem {
  const StoneSetNavigationItem({required this.icon, required this.label, this.selectedIcon});

  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  NavigationDestination destination() => NavigationDestination(
    icon: Icon(icon),
    selectedIcon: Icon(selectedIcon ?? icon),
    label: label,
  );
}

class StoneSetTextField extends StatelessWidget {
  const StoneSetTextField({
    required this.controller,
    required this.label,
    this.helperText,
    this.enabled = true,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? helperText;
  final bool enabled;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    enabled: enabled,
    validator: validator,
    decoration: InputDecoration(labelText: label, helperText: helperText),
  );
}

class StoneSetDialog extends StatelessWidget {
  const StoneSetDialog({
    required this.title,
    required this.content,
    required this.actions,
    super.key,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: content,
    actions: actions,
  );
}

class StoneSetSheet extends StatelessWidget {
  const StoneSetSheet({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(StoneSetSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: StoneSetSpacing.md),
          child,
        ],
      ),
    ),
  );
}
