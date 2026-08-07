import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../fixtures/dashboard_overview_fixtures.dart';
import '../controllers/dashboard_overview_controller.dart';

class DashboardOverviewView extends ConsumerWidget {
  const DashboardOverviewView({
    this.scenario = DashboardOverviewFixtureScenario.populated,
    super.key,
  });

  final DashboardOverviewFixtureScenario scenario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardOverviewControllerProvider(scenario));
    return state.when(
      data: (fixture) => _DashboardOverviewContent(fixture: fixture),
      loading: () => const _DashboardOverviewLoading(),
      error: (error, stackTrace) => _DashboardOverviewError(
        message: error is DashboardFixtureException
            ? error.message
            : 'The preview could not be prepared. No saved work was changed.',
        onRetry: () => ref.invalidate(dashboardOverviewControllerProvider(scenario)),
      ),
    );
  }
}

class _DashboardOverviewContent extends StatelessWidget {
  const _DashboardOverviewContent({required this.fixture});

  final DashboardOverviewFixture fixture;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('dashboard-overview-scroll'),
        padding: const EdgeInsets.all(StoneSetSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text('Overview', style: Theme.of(context).textTheme.headlineLarge),
                ),
                const SizedBox(height: StoneSetSpacing.xs),
                Text(fixture.heading, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: StoneSetSpacing.xxs),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    fixture.supportingText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: StoneSetSemanticColors.of(context).textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: StoneSetSpacing.lg),
                StoneSetStatusBanner(
                  kind: StoneSetStatusKind.information,
                  message: fixture.previewNotice,
                ),
                const SizedBox(height: StoneSetSpacing.section),
                _AttentionSection(items: fixture.attentionItems),
                const SizedBox(height: StoneSetSpacing.section),
                _ResumeWorkSection(drafts: fixture.resumeDrafts),
                const SizedBox(height: StoneSetSpacing.section),
                _PublishedRoutineSection(summary: fixture.publishedRoutine),
                const SizedBox(height: StoneSetSpacing.section),
                _RecentActivitySection(items: fixture.activity),
                const SizedBox(height: StoneSetSpacing.section),
                _SystemStatusSection(status: fixture.systemStatus),
                const SizedBox(height: StoneSetSpacing.section),
                _QuickActionsSection(actions: fixture.quickActions),
                const SizedBox(height: StoneSetSpacing.section),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.description, this.count});

  final String title;
  final String description;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            count == null ? title : '$title, $count items',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: StoneSetSpacing.xxs),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: StoneSetSemanticColors.of(context).textMuted,
          ),
        ),
      ],
    );
  }
}

class _AttentionSection extends StatelessWidget {
  const _AttentionSection({required this.items});

  final List<DashboardAttentionItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('needs-attention-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeading(
          title: 'Needs attention',
          description: 'Resolve blockers before starting less urgent work.',
          count: items.length,
        ),
        const SizedBox(height: StoneSetSpacing.md),
        if (items.isEmpty)
          const StoneSetStatePanel(
            icon: Icons.task_alt,
            title: 'Nothing needs attention',
            message: 'This deterministic preview has no unresolved blockers.',
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: StoneSetSpacing.sm),
              child: _AttentionCard(item: item),
            ),
          ),
      ],
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.item});

  final DashboardAttentionItem item;

  @override
  Widget build(BuildContext context) {
    final (kind, icon) = switch (item.tone) {
      DashboardAttentionTone.information => (
        StoneSetStatusKind.information,
        Icons.info_outline,
      ),
      DashboardAttentionTone.warning => (
        StoneSetStatusKind.warning,
        Icons.warning_amber_outlined,
      ),
      DashboardAttentionTone.destructive => (
        StoneSetStatusKind.error,
        Icons.error_outline,
      ),
    };
    return StoneSetCard(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: StoneSetSpacing.sm,
              runSpacing: StoneSetSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                ExcludeSemantics(child: Icon(icon)),
                Semantics(
                  header: true,
                  child: Text(item.title, style: StoneSetTextStyles.of(context).cardTitle),
                ),
                StoneSetStatusChip(kind: kind, label: item.context),
              ],
            ),
            const SizedBox(height: StoneSetSpacing.sm),
            Text(item.description),
            const SizedBox(height: StoneSetSpacing.md),
            _FixtureActionButton(action: item.action, keyPrefix: 'attention-${item.id}'),
          ],
        ),
      ),
    );
  }
}

class _ResumeWorkSection extends StatelessWidget {
  const _ResumeWorkSection({required this.drafts});

  final List<DashboardResumeDraft> drafts;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('resume-work-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeading(
          title: 'Resume work',
          description: 'Return to recently edited example drafts without losing context.',
          count: drafts.length,
        ),
        const SizedBox(height: StoneSetSpacing.md),
        if (drafts.isEmpty)
          const StoneSetStatePanel(
            icon: Icons.edit_note,
            title: 'No work to resume',
            message: 'Create an example routine or exercise when you are ready.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth >= 780
                  ? (constraints.maxWidth - StoneSetSpacing.md) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: StoneSetSpacing.md,
                runSpacing: StoneSetSpacing.md,
                children: <Widget>[
                  for (final draft in drafts)
                    SizedBox(
                      width: cardWidth,
                      child: _ResumeDraftCard(draft: draft),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _ResumeDraftCard extends StatelessWidget {
  const _ResumeDraftCard({required this.draft});

  final DashboardResumeDraft draft;

  @override
  Widget build(BuildContext context) {
    final (saveKind, saveLabel) = _saveStatePresentation(draft.saveState);
    final (validationKind, validationLabel) = _validationPresentation(draft.validationState);
    return StoneSetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            draft.kind == DashboardDraftKind.routine ? 'Routine draft' : 'Guidance draft',
            style: StoneSetTextStyles.of(context).caption.copyWith(
              color: StoneSetSemanticColors.of(context).textMuted,
            ),
          ),
          const SizedBox(height: StoneSetSpacing.xxs),
          Text(draft.title, style: StoneSetTextStyles.of(context).cardTitle),
          const SizedBox(height: StoneSetSpacing.xs),
          Text(draft.lastEditedLabel),
          const SizedBox(height: StoneSetSpacing.sm),
          Wrap(
            spacing: StoneSetSpacing.xs,
            runSpacing: StoneSetSpacing.xs,
            children: <Widget>[
              StoneSetStatusChip(kind: saveKind, label: saveLabel),
              StoneSetStatusChip(kind: validationKind, label: validationLabel),
            ],
          ),
          const SizedBox(height: StoneSetSpacing.md),
          _FixtureActionButton(action: draft.action, keyPrefix: 'draft-${draft.id}'),
        ],
      ),
    );
  }
}

class _PublishedRoutineSection extends StatelessWidget {
  const _PublishedRoutineSection({required this.summary});

  final DashboardPublishedRoutineSummary? summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('published-routine-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionHeading(
          title: 'Published routine',
          description: 'See the current example and any staged future activation.',
        ),
        const SizedBox(height: StoneSetSpacing.md),
        if (summary == null)
          const StoneSetStatePanel(
            icon: Icons.event_available_outlined,
            title: 'No published routine yet',
            message: 'Create a routine draft to begin this fixture-only workflow.',
          )
        else
          StoneSetCard(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final details = <Widget>[
                  _RoutineSummaryBlock(
                    label: 'Current',
                    name: summary!.name,
                    status: '${summary!.versionLabel} · ${summary!.scheduleLabel}',
                    detail: '${summary!.workoutDays} workout days',
                  ),
                  if (summary!.upcomingName != null)
                    _RoutineSummaryBlock(
                      label: 'Upcoming',
                      name: summary!.upcomingName!,
                      status: summary!.upcomingActivationLabel!,
                      detail: 'Staged example — not authoritative',
                    ),
                ];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (constraints.maxWidth >= 680)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          for (var index = 0; index < details.length; index++) ...<Widget>[
                            if (index > 0) const SizedBox(width: StoneSetSpacing.xl),
                            Expanded(child: details[index]),
                          ],
                        ],
                      )
                    else
                      ...details.expand(
                        (detail) => <Widget>[detail, const SizedBox(height: StoneSetSpacing.lg)],
                      ),
                    const SizedBox(height: StoneSetSpacing.md),
                    _FixtureActionButton(
                      action: summary!.action,
                      keyPrefix: 'published-routine',
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}

class _RoutineSummaryBlock extends StatelessWidget {
  const _RoutineSummaryBlock({
    required this.label,
    required this.name,
    required this.status,
    required this.detail,
  });

  final String label;
  final String name;
  final String status;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: StoneSetTextStyles.of(context).caption),
        const SizedBox(height: StoneSetSpacing.xs),
        Text(name, style: StoneSetTextStyles.of(context).cardTitle),
        const SizedBox(height: StoneSetSpacing.xs),
        StoneSetStatusChip(kind: StoneSetStatusKind.success, label: status),
        const SizedBox(height: StoneSetSpacing.xs),
        Text(detail),
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({required this.items});

  final List<DashboardActivityItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('recent-activity-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeading(
          title: 'Recent activity',
          description: 'A concise fixture timeline of immutable product events.',
          count: items.length,
        ),
        const SizedBox(height: StoneSetSpacing.md),
        if (items.isEmpty)
          const StoneSetStatePanel(
            icon: Icons.history,
            title: 'No recent activity',
            message: 'Product activity will appear here after its owning packet is implemented.',
          )
        else
          StoneSetCard(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: StoneSetSemanticColors.of(context).outline,
              ),
              itemBuilder: (context, index) => _ActivityRow(item: items[index]),
            ),
          ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final DashboardActivityItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('activity-${item.id}'),
      minVerticalPadding: StoneSetSpacing.sm,
      leading: Icon(_activityIcon(item.kind)),
      title: Text(item.title),
      subtitle: Text('${item.description}\n${item.timeLabel}'),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(item.action.location),
    );
  }
}

class _SystemStatusSection extends StatelessWidget {
  const _SystemStatusSection({required this.status});

  final DashboardSystemStatus status;

  @override
  Widget build(BuildContext context) {
    final kind = switch (status.condition) {
      DashboardSystemCondition.available => StoneSetStatusKind.success,
      DashboardSystemCondition.readOnly => StoneSetStatusKind.warning,
      DashboardSystemCondition.offline => StoneSetStatusKind.offline,
      DashboardSystemCondition.degraded => StoneSetStatusKind.error,
    };
    return Column(
      key: const Key('system-status-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionHeading(
          title: 'System status',
          description: 'Compact context for whether product actions can proceed.',
        ),
        const SizedBox(height: StoneSetSpacing.md),
        StoneSetCard(
          child: Wrap(
            spacing: StoneSetSpacing.lg,
            runSpacing: StoneSetSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              StoneSetStatusIndicator(kind: kind, label: status.label),
              Text(status.description),
              Text(
                status.lastCheckedLabel,
                style: StoneSetTextStyles.of(context).caption.copyWith(
                  color: StoneSetSemanticColors.of(context).textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.actions});

  final List<DashboardFixtureAction> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('quick-actions-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionHeading(
          title: 'Quick actions',
          description: 'Move directly to the next relevant dashboard destination.',
        ),
        const SizedBox(height: StoneSetSpacing.md),
        Wrap(
          spacing: StoneSetSpacing.sm,
          runSpacing: StoneSetSpacing.sm,
          children: <Widget>[
            for (var index = 0; index < actions.length; index++)
              _FixtureActionButton(action: actions[index], keyPrefix: 'quick-action-$index'),
          ],
        ),
      ],
    );
  }
}

class _FixtureActionButton extends StatelessWidget {
  const _FixtureActionButton({required this.action, required this.keyPrefix});

  final DashboardFixtureAction action;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StoneSetButton(
          key: Key('$keyPrefix-action'),
          label: action.label,
          icon: Icons.arrow_forward,
          kind: StoneSetButtonKind.secondary,
          onPressed: action.enabled ? () => context.go(action.location) : null,
        ),
        if (action.disabledReason != null) ...<Widget>[
          const SizedBox(height: StoneSetSpacing.xxs),
          Text(action.disabledReason!, style: StoneSetTextStyles.of(context).caption),
        ],
      ],
    );
  }
}

class _DashboardOverviewLoading extends StatelessWidget {
  const _DashboardOverviewLoading();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('dashboard-overview-loading'),
        padding: const EdgeInsets.all(StoneSetSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Semantics(
              liveRegion: true,
              label: 'Loading dashboard Overview preview.',
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const <Widget>[
                    StoneSetSkeleton(width: 280, height: 40),
                    SizedBox(height: StoneSetSpacing.xl),
                    StoneSetSkeleton(width: double.infinity, height: 132),
                    SizedBox(height: StoneSetSpacing.md),
                    StoneSetSkeleton(width: double.infinity, height: 180),
                    SizedBox(height: StoneSetSpacing.md),
                    StoneSetSkeleton(width: double.infinity, height: 180),
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

class _DashboardOverviewError extends StatelessWidget {
  const _DashboardOverviewError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(StoneSetSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: StoneSetStatePanel(
              icon: Icons.error_outline,
              title: 'Overview unavailable',
              message: message,
              actionLabel: 'Retry preview',
              onAction: onRetry,
            ),
          ),
        ),
      ),
    );
  }
}

(StoneSetStatusKind, String) _saveStatePresentation(DashboardDraftSaveState state) =>
    switch (state) {
      DashboardDraftSaveState.saved => (StoneSetStatusKind.success, 'Saved'),
      DashboardDraftSaveState.saving => (StoneSetStatusKind.pending, 'Saving'),
      DashboardDraftSaveState.offline => (StoneSetStatusKind.offline, 'Offline'),
      DashboardDraftSaveState.syncing => (StoneSetStatusKind.pending, 'Syncing'),
      DashboardDraftSaveState.conflict => (StoneSetStatusKind.conflict, 'Conflict'),
      DashboardDraftSaveState.failed => (StoneSetStatusKind.error, 'Failed to save'),
      DashboardDraftSaveState.readOnly => (StoneSetStatusKind.warning, 'Read only'),
    };

(StoneSetStatusKind, String) _validationPresentation(DashboardValidationState state) =>
    switch (state) {
      DashboardValidationState.ready => (StoneSetStatusKind.success, 'Ready'),
      DashboardValidationState.warning => (StoneSetStatusKind.warning, 'Warnings'),
      DashboardValidationState.blocked => (StoneSetStatusKind.error, 'Blocked'),
      DashboardValidationState.notRun => (StoneSetStatusKind.information, 'Not validated'),
    };

IconData _activityIcon(DashboardActivityKind kind) => switch (kind) {
  DashboardActivityKind.guidance => Icons.menu_book_outlined,
  DashboardActivityKind.routine => Icons.view_week_outlined,
  DashboardActivityKind.review => Icons.fact_check_outlined,
  DashboardActivityKind.media => Icons.image_outlined,
  DashboardActivityKind.account => Icons.manage_accounts_outlined,
};
