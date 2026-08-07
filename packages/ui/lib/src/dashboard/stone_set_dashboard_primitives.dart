import 'package:flutter/material.dart';

import '../primitives/stone_set_primitives.dart';
import '../theme/stone_set_theme.dart';

/// A route-agnostic list/detail layout that adapts to its available width.
///
/// Compact layouts show one pane at a time. Wider layouts keep the list visible
/// and add the selected detail and optional supporting content without changing
/// selection ownership.
class StoneSetListDetailScaffold extends StatelessWidget {
  const StoneSetListDetailScaffold({
    required this.list,
    required this.detail,
    required this.hasSelection,
    this.emptyDetail,
    this.supportingPane,
    this.compactDetailTitle,
    this.onCompactBack,
    this.mediumBreakpoint = 720,
    this.expandedBreakpoint = 1180,
    super.key,
  });

  final Widget list;
  final Widget detail;
  final bool hasSelection;
  final Widget? emptyDetail;
  final Widget? supportingPane;
  final String? compactDetailTitle;
  final VoidCallback? onCompactBack;
  final double mediumBreakpoint;
  final double expandedBreakpoint;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final detailContent = hasSelection
          ? detail
          : emptyDetail ??
                const StoneSetDashboardStatePanel(
                  state: StoneSetDashboardPanelState.empty,
                  title: 'Select an item',
                  message: 'Choose an item from the list to view its details.',
                );

      if (constraints.maxWidth < mediumBreakpoint) {
        if (!hasSelection) return list;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (onCompactBack != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  key: const Key('dashboard-list-detail-back'),
                  onPressed: onCompactBack,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(compactDetailTitle ?? 'Back to list'),
                ),
              ),
            Expanded(child: detailContent),
          ],
        );
      }

      final showSupporting = supportingPane != null && constraints.maxWidth >= expandedBreakpoint;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Flexible(flex: 4, child: list),
          VerticalDivider(width: 1, color: StoneSetSemanticColors.of(context).outline),
          Flexible(flex: 6, child: detailContent),
          if (showSupporting) ...<Widget>[
            VerticalDivider(width: 1, color: StoneSetSemanticColors.of(context).outline),
            SizedBox(width: 320, child: supportingPane),
          ],
        ],
      );
    },
  );
}

/// A labelled, dismissible supporting pane for validation, preview, or context.
class StoneSetSupportingPane extends StatelessWidget {
  const StoneSetSupportingPane({
    required this.title,
    required this.child,
    this.onDismiss,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: StoneSetSemanticColors.of(context).surface,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(StoneSetSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    key: const Key('dashboard-supporting-pane-close'),
                    tooltip: 'Close supporting pane',
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: StoneSetSpacing.md),
            Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}

/// Search and filter controls with an optional responsive action area.
class StoneSetFilterHeader extends StatelessWidget {
  const StoneSetFilterHeader({
    required this.searchController,
    required this.searchLabel,
    this.onSearchChanged,
    this.filters = const <Widget>[],
    this.actions = const <Widget>[],
    super.key,
  });

  final TextEditingController searchController;
  final String searchLabel;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget> filters;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final search = TextField(
        key: const Key('dashboard-filter-search'),
        controller: searchController,
        onChanged: onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          labelText: searchLabel,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged?.call('');
                  },
                  icon: const Icon(Icons.close),
                ),
        ),
      );
      final controls = <Widget>[...filters, ...actions];
      if (constraints.maxWidth < 700) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            search,
            if (controls.isNotEmpty) ...<Widget>[
              const SizedBox(height: StoneSetSpacing.sm),
              Wrap(spacing: StoneSetSpacing.xs, runSpacing: StoneSetSpacing.xs, children: controls),
            ],
          ],
        );
      }
      return Row(
        children: <Widget>[
          Expanded(child: search),
          if (controls.isNotEmpty) ...<Widget>[
            const SizedBox(width: StoneSetSpacing.md),
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: StoneSetSpacing.xs,
                runSpacing: StoneSetSpacing.xs,
                children: controls,
              ),
            ),
          ],
        ],
      );
    },
  );
}

@immutable
class StoneSetDashboardAction {
  const StoneSetDashboardAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
  });

  final String id;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;
}

/// Keeps the primary action visible and moves excess actions into an overflow.
class StoneSetResponsiveToolbar extends StatelessWidget {
  const StoneSetResponsiveToolbar({
    required this.title,
    required this.actions,
    this.supportingText,
    super.key,
  });

  final String title;
  final String? supportingText;
  final List<StoneSetDashboardAction> actions;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final visibleCount = constraints.maxWidth >= 900
          ? actions.length
          : actions.length.clamp(0, 1);
      final visible = actions.take(visibleCount).toList(growable: false);
      final overflow = actions.skip(visibleCount).toList(growable: false);
      return Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
                ),
                if (supportingText != null) ...<Widget>[
                  const SizedBox(height: StoneSetSpacing.xxs),
                  Text(supportingText!, style: StoneSetTextStyles.of(context).compactBody),
                ],
              ],
            ),
          ),
          for (final action in visible) ...<Widget>[
            const SizedBox(width: StoneSetSpacing.xs),
            StoneSetButton(
              key: Key('dashboard-toolbar-${action.id}'),
              label: action.label,
              icon: action.icon,
              onPressed: action.enabled ? action.onPressed : null,
            ),
          ],
          if (overflow.isNotEmpty)
            PopupMenuButton<String>(
              key: const Key('dashboard-toolbar-overflow'),
              tooltip: 'More actions',
              onSelected: (id) => overflow.firstWhere((action) => action.id == id).onPressed(),
              itemBuilder: (context) => overflow
                  .map(
                    (action) => PopupMenuItem<String>(
                      value: action.id,
                      enabled: action.enabled,
                      child: Row(
                        children: <Widget>[
                          Icon(action.icon, size: 20),
                          const SizedBox(width: StoneSetSpacing.xs),
                          Flexible(child: Text(action.label)),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      );
    },
  );
}

/// A keyboard- and pointer-operable selected row for list/detail surfaces.
class StoneSetSelectableRow extends StatelessWidget {
  const StoneSetSelectableRow({
    required this.title,
    required this.selected,
    required this.onSelect,
    this.subtitle,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onSelect;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected ? StoneSetSemanticColors.of(context).interactiveSurface : Colors.transparent,
      child: ListTile(
        selected: selected,
        minTileHeight: StoneSetSpacing.minimumTouchTarget,
        leading: leading,
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: trailing,
        onTap: onSelect,
      ),
    ),
  );
}

enum StoneSetDashboardPanelState { loading, empty, error, permissionDenied, offline, readOnly }

class StoneSetDashboardStatePanel extends StatelessWidget {
  const StoneSetDashboardStatePanel({
    required this.state,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : assert((actionLabel == null) == (onAction == null));

  final StoneSetDashboardPanelState state;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  IconData get _icon => switch (state) {
    StoneSetDashboardPanelState.loading => Icons.hourglass_empty,
    StoneSetDashboardPanelState.empty => Icons.inbox_outlined,
    StoneSetDashboardPanelState.error => Icons.error_outline,
    StoneSetDashboardPanelState.permissionDenied => Icons.lock_outline,
    StoneSetDashboardPanelState.offline => Icons.cloud_off_outlined,
    StoneSetDashboardPanelState.readOnly => Icons.visibility_outlined,
  };

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: state == StoneSetDashboardPanelState.error,
    child: StoneSetStatePanel(
      title: title,
      message: message,
      icon: _icon,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
  );
}

@immutable
class StoneSetValidationIssue {
  const StoneSetValidationIssue({required this.id, required this.message, this.blocking = true});

  final String id;
  final String message;
  final bool blocking;
}

class StoneSetValidationSummary extends StatelessWidget {
  const StoneSetValidationSummary({
    required this.title,
    required this.issues,
    required this.onIssueSelected,
    super.key,
  });

  final String title;
  final List<StoneSetValidationIssue> issues;
  final ValueChanged<String> onIssueSelected;

  @override
  Widget build(BuildContext context) {
    final colors = StoneSetSemanticColors.of(context);
    return Semantics(
      container: true,
      liveRegion: issues.any((issue) => issue.blocking),
      label: '$title. ${issues.length} ${issues.length == 1 ? 'issue' : 'issues'}.',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.destructive.withValues(alpha: 0.08),
          border: Border.all(color: colors.destructive),
          borderRadius: BorderRadius.circular(StoneSetShapes.controlRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(StoneSetSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: StoneSetSpacing.xs),
              for (final issue in issues)
                TextButton.icon(
                  key: Key('dashboard-validation-${issue.id}'),
                  onPressed: () => onIssueSelected(issue.id),
                  icon: Icon(issue.blocking ? Icons.error_outline : Icons.warning_amber_outlined),
                  label: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(issue.message),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A non-modal confirmation with optional undo.
class StoneSetConfirmationSurface extends StatelessWidget {
  const StoneSetConfirmationSurface({
    required this.message,
    this.onUndo,
    this.undoLabel = 'Undo',
    super.key,
  });

  final String message;
  final VoidCallback? onUndo;
  final String undoLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: true,
    label: message,
    child: Material(
      color: StoneSetSemanticColors.of(context).interactiveSurface,
      borderRadius: BorderRadius.circular(StoneSetShapes.controlRadius),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          StoneSetSpacing.md,
          StoneSetSpacing.xs,
          StoneSetSpacing.xs,
          StoneSetSpacing.xs,
        ),
        child: Row(
          children: <Widget>[
            const ExcludeSemantics(child: Icon(Icons.check_circle_outline)),
            const SizedBox(width: StoneSetSpacing.sm),
            Expanded(child: ExcludeSemantics(child: Text(message))),
            if (onUndo != null) TextButton(onPressed: onUndo, child: Text(undoLabel)),
          ],
        ),
      ),
    ),
  );
}

/// Constrains a fixture preview to a phone-like canvas without claiming a live app render.
class StoneSetMobilePreview extends StatelessWidget {
  const StoneSetMobilePreview({required this.child, this.label = 'Mobile preview', super.key});

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '$label. Preview only.',
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390, minHeight: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: StoneSetSemanticColors.of(context).canvas,
            border: Border.all(color: StoneSetSemanticColors.of(context).outline, width: 2),
            borderRadius: BorderRadius.circular(StoneSetShapes.cardRadius + StoneSetSpacing.xs),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(StoneSetShapes.cardRadius + StoneSetSpacing.xs - 2),
            child: child,
          ),
        ),
      ),
    ),
  );
}

/// A focusable reorder row with explicit keyboard alternatives.
///
/// Drag persistence is intentionally not provided by this presentation primitive.
class StoneSetReorderPlaceholder extends StatelessWidget {
  const StoneSetReorderPlaceholder({
    required this.label,
    required this.position,
    required this.total,
    this.onMoveUp,
    this.onMoveDown,
    super.key,
  });

  final String label;
  final int position;
  final int total;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '$label. Position $position of $total.',
    child: StoneSetCard(
      child: Row(
        children: <Widget>[
          const ExcludeSemantics(child: Icon(Icons.drag_indicator)),
          const SizedBox(width: StoneSetSpacing.sm),
          Expanded(child: ExcludeSemantics(child: Text(label))),
          IconButton(
            key: Key('dashboard-reorder-up-$position'),
            tooltip: 'Move $label up',
            onPressed: onMoveUp,
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            key: Key('dashboard-reorder-down-$position'),
            tooltip: 'Move $label down',
            onPressed: onMoveDown,
            icon: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    ),
  );
}
