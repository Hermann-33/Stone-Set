import 'package:flutter/material.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

enum DashboardSaveState { saved, saving, offline, syncing, conflict, failed, readOnly }

extension DashboardSaveStatePresentation on DashboardSaveState {
  String get label => switch (this) {
    DashboardSaveState.saved => 'Saved',
    DashboardSaveState.saving => 'Saving',
    DashboardSaveState.offline => 'Offline',
    DashboardSaveState.syncing => 'Syncing',
    DashboardSaveState.conflict => 'Conflict',
    DashboardSaveState.failed => 'Failed to save',
    DashboardSaveState.readOnly => 'Read only',
  };

  String get fixtureDetail => switch (this) {
    DashboardSaveState.saved => 'Fixture preview only; no browser or server record was written.',
    DashboardSaveState.saving => 'Fixture preview of an in-progress save.',
    DashboardSaveState.offline => 'Fixture preview; local draft storage is not implemented yet.',
    DashboardSaveState.syncing => 'Fixture preview of synchronization in progress.',
    DashboardSaveState.conflict => 'Fixture versions differ and require an explicit comparison.',
    DashboardSaveState.failed =>
      'Fixture save failed. The represented draft remains available here.',
    DashboardSaveState.readOnly => 'Editing is unavailable in this fixture state.',
  };

  StoneSetStatusKind get statusKind => switch (this) {
    DashboardSaveState.saved => StoneSetStatusKind.success,
    DashboardSaveState.saving || DashboardSaveState.syncing => StoneSetStatusKind.pending,
    DashboardSaveState.offline => StoneSetStatusKind.offline,
    DashboardSaveState.conflict => StoneSetStatusKind.conflict,
    DashboardSaveState.failed => StoneSetStatusKind.error,
    DashboardSaveState.readOnly => StoneSetStatusKind.information,
  };
}

/// Explicit save/synchronization status for fixture-only dashboard surfaces.
class DashboardSaveStatus extends StatelessWidget {
  const DashboardSaveStatus({
    required this.state,
    this.onRetry,
    this.onCompare,
    this.onRestore,
    this.compact = false,
    super.key,
  });

  final DashboardSaveState state;
  final VoidCallback? onRetry;
  final VoidCallback? onCompare;
  final VoidCallback? onRestore;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Semantics(
        liveRegion: state != DashboardSaveState.saved,
        label: '${state.label}. ${state.fixtureDetail}',
        child: ExcludeSemantics(
          child: StoneSetStatusChip(kind: state.statusKind, label: state.label),
        ),
      );
    }
    return StoneSetStatusBanner(
      key: Key('dashboard-save-status-${state.name}'),
      kind: state.statusKind,
      message: '${state.label}. ${state.fixtureDetail}',
      actionLabel: _actionLabel,
      onAction: _action,
    );
  }

  String? get _actionLabel => switch (state) {
    DashboardSaveState.failed when onRetry != null => 'Retry fixture',
    DashboardSaveState.conflict when onCompare != null => 'Compare',
    DashboardSaveState.conflict when onRestore != null => 'Restore fixture',
    _ => null,
  };

  VoidCallback? get _action => switch (state) {
    DashboardSaveState.failed => onRetry,
    DashboardSaveState.conflict when onCompare != null => onCompare,
    DashboardSaveState.conflict => onRestore,
    _ => null,
  };
}

/// A deterministic conflict-resolution preview; it does not mutate persisted data.
class DashboardConflictSurface extends StatelessWidget {
  const DashboardConflictSurface({
    required this.onCompare,
    required this.onRestoreFixture,
    this.onKeepCurrentFixture,
    super.key,
  });

  final VoidCallback onCompare;
  final VoidCallback onRestoreFixture;
  final VoidCallback? onKeepCurrentFixture;

  @override
  Widget build(BuildContext context) => StoneSetCard(
    key: const Key('dashboard-conflict-surface'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const DashboardSaveStatus(state: DashboardSaveState.conflict),
        const SizedBox(height: StoneSetSpacing.md),
        Semantics(
          header: true,
          child: Text('Choose a fixture version', style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: StoneSetSpacing.xs),
        const Text(
          'Compare the represented versions before choosing. This preview does not write to '
          'browser storage or a server.',
        ),
        const SizedBox(height: StoneSetSpacing.md),
        Wrap(
          spacing: StoneSetSpacing.xs,
          runSpacing: StoneSetSpacing.xs,
          children: <Widget>[
            StoneSetButton(
              key: const Key('dashboard-conflict-compare'),
              label: 'Compare versions',
              icon: Icons.compare_arrows_outlined,
              onPressed: onCompare,
            ),
            StoneSetButton(
              key: const Key('dashboard-conflict-restore'),
              label: 'Restore fixture version',
              kind: StoneSetButtonKind.secondary,
              icon: Icons.restore_outlined,
              onPressed: onRestoreFixture,
            ),
            if (onKeepCurrentFixture != null)
              StoneSetButton(
                key: const Key('dashboard-conflict-keep-current'),
                label: 'Keep current fixture',
                kind: StoneSetButtonKind.quiet,
                onPressed: onKeepCurrentFixture,
              ),
          ],
        ),
      ],
    ),
  );
}
