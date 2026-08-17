import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_domain/exercise_media.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../../session/dashboard_session_controller.dart';
import '../controllers/dashboard_exercise_controllers.dart';
import '../controllers/dashboard_guidance_media_controller.dart';
import 'dashboard_exercise_library_view.dart';
import 'dashboard_guidance_media_editor.dart';

class DashboardGuidanceEditorView extends ConsumerWidget {
  const DashboardGuidanceEditorView({
    required this.exerciseId,
    required this.draftId,
    super.key,
  });

  final String exerciseId;
  final String draftId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(dashboardSessionControllerProvider);
    final userId = session.userId;
    if (userId == null) {
      return const DashboardExerciseErrorPanel(
        error: ExerciseGuidanceFailure(ExerciseGuidanceErrorCode.sessionExpired),
      );
    }
    final request = DashboardGuidanceEditorRequest(
      userId: userId,
      exerciseId: exerciseId,
      draftId: draftId,
    );
    final editor = ref.watch(dashboardGuidanceEditorControllerProvider(request));
    final readOnly = session.bootstrap?.compatibility.readOnlyMode ?? false;
    return ColoredBox(
      color: StoneSetSemanticColors.of(context).canvas,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(StoneSetSpacing.md),
          child: editor.when(
            loading: () => const StoneSetDashboardStatePanel(
              state: StoneSetDashboardPanelState.loading,
              title: 'Recovering guidance draft',
              message: 'Checking authoritative state and private browser recovery.',
            ),
            error: (error, _) => DashboardExerciseErrorPanel(
              error: error,
              onRetry: () => ref.invalidate(dashboardGuidanceEditorControllerProvider(request)),
            ),
            data: (state) => _GuidanceEditor(
              request: request,
              state: state,
              readOnly: readOnly,
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidanceEditor extends ConsumerWidget {
  const _GuidanceEditor({
    required this.request,
    required this.state,
    required this.readOnly,
  });

  final DashboardGuidanceEditorRequest request;
  final DashboardGuidanceEditorState state;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dashboardGuidanceEditorControllerProvider(request).notifier);
    final mediaRequest = DashboardGuidanceMediaRequest(
      exerciseId: request.exerciseId,
      draftId: request.draftId,
    );
    final media = ref.watch(dashboardGuidanceMediaControllerProvider(mediaRequest));
    final mediaController = ref.read(
      dashboardGuidanceMediaControllerProvider(mediaRequest).notifier,
    );
    final effectiveStatus = readOnly ? DashboardGuidanceSaveState.readOnly : state.status;
    final publicationReady = _mediaReadyForPublication(media);
    if (state.conflict case final conflict?) {
      return _GuidanceConflictView(
        exerciseName: state.exercise?.canonicalName ?? 'Guidance draft',
        conflict: conflict,
        onAcceptServer: readOnly ? null : controller.acceptServer,
        onUseLocal: readOnly ? null : controller.useLocalAsNewDraft,
        onRetry: controller.retry,
      );
    }
    final guardExit = _guidanceNeedsExitGuard(state) || _mediaNeedsExitGuard(media.value);
    return PopScope<Object?>(
      canPop: !guardExit,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && guardExit) {
          unawaited(_requestGuidanceExit(context, state, mediaNeedsGuard: true));
        }
      },
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
            if (!readOnly) unawaited(controller.saveNow());
          },
          const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () {
            if (!readOnly) unawaited(controller.saveNow());
          },
        },
        child: FocusTraversalGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StoneSetResponsiveToolbar(
                title: state.exercise?.canonicalName ?? 'Recovered guidance draft',
                supportingText:
                    'Save keeps a draft. Publish creates the app version used by the next newly started workout.',
                actions: <StoneSetDashboardAction>[
                  StoneSetDashboardAction(
                    id: 'back-to-exercise',
                    label: 'Exercise',
                    icon: Icons.arrow_back,
                    onPressed: () => unawaited(
                      _requestGuidanceExit(
                        context,
                        state,
                        mediaNeedsGuard: _mediaNeedsExitGuard(media.value),
                      ),
                    ),
                  ),
                  StoneSetDashboardAction(
                    id: 'validate-guidance',
                    label: 'Validate',
                    icon: Icons.fact_check_outlined,
                    enabled:
                        !readOnly &&
                        state.status != DashboardGuidanceSaveState.offline &&
                        state.status != DashboardGuidanceSaveState.failed,
                    onPressed: controller.validate,
                  ),
                  StoneSetDashboardAction(
                    id: 'publish-guidance',
                    label: 'Publish',
                    icon: Icons.publish_outlined,
                    enabled:
                        !readOnly &&
                        state.status == DashboardGuidanceSaveState.saved &&
                        state.exercise != null &&
                        state.serverDraft != null &&
                        publicationReady,
                    onPressed: () {
                      final exercise = state.exercise;
                      final draft = state.serverDraft;
                      if (exercise == null || draft == null) return;
                      unawaited(
                        _confirmPublish(
                          context,
                          mediaController,
                          exerciseRevision: exercise.revision,
                          draftRevision: draft.revision,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: StoneSetSpacing.sm),
              _GuidanceSaveBanner(
                status: effectiveStatus,
                message: state.message,
                onRetry: readOnly ? null : controller.retry,
                onSave: readOnly ? null : controller.saveNow,
              ),
              const SizedBox(height: StoneSetSpacing.xs),
              _GuidancePublicationBanner(media: media, readOnly: readOnly),
              const SizedBox(height: StoneSetSpacing.md),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final editor = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _GuidanceForm(
                          state: state,
                          readOnly: readOnly,
                          controller: controller,
                        ),
                        if (state.serverDraft case final draft?) ...<Widget>[
                          const SizedBox(height: StoneSetSpacing.md),
                          DashboardGuidanceMediaEditor(
                            request: mediaRequest,
                            draftRevision: draft.revision,
                            readOnly: readOnly,
                          ),
                        ] else
                          const StoneSetDashboardStatePanel(
                            state: StoneSetDashboardPanelState.offline,
                            title: 'Media Requires Authoritative Draft',
                            message:
                                'Reconnect and recover the server draft before changing private media.',
                          ),
                      ],
                    );
                    final supporting = _GuidanceSupportingPane(
                      state: state,
                      onIssueSelected: (field) => _focusField(context, field),
                      onOpenVersions: () => context.go('/exercises/${request.exerciseId}'),
                    );
                    if (constraints.maxWidth < 1120) {
                      return ListView(
                        key: const Key('guidance-editor-compact'),
                        children: <Widget>[
                          editor,
                          const SizedBox(height: StoneSetSpacing.md),
                          supporting,
                        ],
                      );
                    }
                    return Row(
                      key: const Key('guidance-editor-expanded'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(flex: 7, child: SingleChildScrollView(child: editor)),
                        const SizedBox(width: StoneSetSpacing.md),
                        SizedBox(width: 340, child: SingleChildScrollView(child: supporting)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestGuidanceExit(
    BuildContext context,
    DashboardGuidanceEditorState current, {
    bool mediaNeedsGuard = false,
  }) async {
    if (_guidanceNeedsExitGuard(current) || mediaNeedsGuard) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Leave this guidance draft?'),
          content: const Text(
            'Stone Set keeps the in-memory value on this page and uses IndexedDB recovery after '
            'refresh or browser close. Unsynced, conflicted, or failed local work is not authoritative.',
          ),
          actions: <Widget>[
            TextButton(
              autofocus: true,
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep editing'),
            ),
            FilledButton(
              key: const Key('leave-guidance-editor'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Leave draft'),
            ),
          ],
        ),
      );
      if (leave != true) return;
    }
    if (context.mounted) context.go('/exercises/${request.exerciseId}');
  }

  Future<void> _confirmPublish(
    BuildContext context,
    DashboardGuidanceMediaController controller, {
    required int exerciseRevision,
    required int draftRevision,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish immutable guidance?'),
        content: const Text(
          'Save only updates the editable draft. Publish creates an immutable app version after '
          'revalidating the authoritative guidance and media. The next newly started workout uses '
          'that published version; workouts already in progress remain pinned to the version they started with.',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            key: const Key('confirm-publish-guidance'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publish guidance'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await controller.publish(
      exerciseRevision: exerciseRevision,
      draftRevision: draftRevision,
    );
    if (!context.mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Publication did not complete. No app guidance version changed. Resolve the publication blocker and try again.',
          ),
        ),
      );
      return;
    }
    context.go(
      '/exercises/${request.exerciseId}/guidance/revisions/${result.guidanceRevisionId}',
    );
  }
}

class _GuidanceForm extends StatelessWidget {
  const _GuidanceForm({
    required this.state,
    required this.readOnly,
    required this.controller,
  });

  final DashboardGuidanceEditorState state;
  final bool readOnly;
  final DashboardGuidanceEditorController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      _GuidanceSectionCard(
        title: 'Description',
        description: 'Explain the movement clearly before listing steps.',
        child: TextFormField(
          key: const Key('guidance-field-shortExplanation'),
          initialValue: state.content.shortExplanation,
          enabled: !readOnly,
          maxLength: 2000,
          minLines: 3,
          maxLines: 7,
          onChanged: controller.updateShortExplanation,
          decoration: const InputDecoration(labelText: 'Short explanation'),
        ),
      ),
      const SizedBox(height: StoneSetSpacing.md),
      for (final section in DashboardGuidanceSection.values) ...<Widget>[
        _GuidanceSectionCard(
          title: section.label,
          description: switch (section) {
            DashboardGuidanceSection.setup => 'Preparation and starting position.',
            DashboardGuidanceSection.execution => 'Ordered movement steps.',
            DashboardGuidanceSection.cues => 'Concise technique reminders.',
            DashboardGuidanceSection.mistakes => 'Common errors to avoid.',
            DashboardGuidanceSection.safety => 'Non-diagnostic safety notes.',
          },
          child: _GuidanceOrderedList(
            section: section,
            values: _sectionValues(state.content, section),
            readOnly: readOnly,
            controller: controller,
          ),
        ),
        const SizedBox(height: StoneSetSpacing.md),
      ],
      StoneSetCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.info_outline),
            const SizedBox(width: StoneSetSpacing.sm),
            Expanded(
              child: Text(
                'Changing canonical exercise identity, equipment, or future prescription data '
                'requires a later routine-review flow. This editor publishes content only.',
                style: StoneSetTextStyles.of(context).compactBody,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: StoneSetSpacing.xl),
    ],
  );
}

class _GuidanceSectionCard extends StatelessWidget {
  const _GuidanceSectionCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => StoneSetCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        const SizedBox(height: StoneSetSpacing.xxs),
        Text(description, style: StoneSetTextStyles.of(context).compactBody),
        const SizedBox(height: StoneSetSpacing.md),
        child,
      ],
    ),
  );
}

class _GuidanceOrderedList extends StatelessWidget {
  const _GuidanceOrderedList({
    required this.section,
    required this.values,
    required this.readOnly,
    required this.controller,
  });

  final DashboardGuidanceSection section;
  final List<String> values;
  final bool readOnly;
  final DashboardGuidanceEditorController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      if (values.isEmpty)
        Text(
          'No ${section.label.toLowerCase()} yet.',
          style: StoneSetTextStyles.of(context).caption,
        ),
      for (var index = 0; index < values.length; index += 1)
        Padding(
          padding: const EdgeInsets.only(bottom: StoneSetSpacing.sm),
          child: Semantics(
            container: true,
            label: '${section.label} item ${index + 1} of ${values.length}',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: StoneSetSpacing.md),
                  child: SizedBox(width: 28, child: Text('${index + 1}.')),
                ),
                Expanded(
                  child: TextFormField(
                    key: Key('guidance-field-${section.field}-$index'),
                    initialValue: values[index],
                    enabled: !readOnly,
                    maxLength: 500,
                    minLines: 1,
                    maxLines: 4,
                    onChanged: (value) => controller.updateItem(section, index, value),
                    decoration: InputDecoration(labelText: '${section.label} item ${index + 1}'),
                  ),
                ),
                Column(
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Move item up',
                      onPressed: readOnly || index == 0
                          ? null
                          : () => controller.moveItem(section, index, -1),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    IconButton(
                      tooltip: 'Move item down',
                      onPressed: readOnly || index == values.length - 1
                          ? null
                          : () => controller.moveItem(section, index, 1),
                      icon: const Icon(Icons.arrow_downward),
                    ),
                    IconButton(
                      tooltip: 'Remove item',
                      onPressed: readOnly ? null : () => controller.removeItem(section, index),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          key: Key('guidance-add-${section.field}'),
          onPressed: readOnly || values.length >= 50 ? null : () => controller.addItem(section),
          icon: const Icon(Icons.add),
          label: Text('Add ${section.label.toLowerCase()} item'),
        ),
      ),
    ],
  );
}

class _GuidanceSupportingPane extends StatelessWidget {
  const _GuidanceSupportingPane({
    required this.state,
    required this.onIssueSelected,
    required this.onOpenVersions,
  });

  final DashboardGuidanceEditorState state;
  final ValueChanged<String> onIssueSelected;
  final VoidCallback onOpenVersions;

  @override
  Widget build(BuildContext context) {
    final issues = state.validation?.issues ?? const <ExerciseGuidanceValidationIssue>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (issues.isNotEmpty)
          StoneSetValidationSummary(
            title: 'Publication blockers',
            issues: <StoneSetValidationIssue>[
              for (var index = 0; index < issues.length; index += 1)
                StoneSetValidationIssue(
                  id: issues[index].field,
                  message: issues[index].message,
                ),
            ],
            onIssueSelected: onIssueSelected,
          )
        else
          StoneSetCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text('Validation', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: StoneSetSpacing.xs),
                Text(
                  state.validation?.isValid == true
                      ? 'The authoritative draft passed validation.'
                      : 'Validate online before publication.',
                ),
              ],
            ),
          ),
        const SizedBox(height: StoneSetSpacing.md),
        StoneSetCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text('Version history', style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: StoneSetSpacing.xs),
              Text(
                state.publishedRevision == null
                    ? 'Published versions are immutable and compared from exercise detail.'
                    : 'Version ${state.publishedRevision!.versionNumber} is now immutable.',
              ),
              const SizedBox(height: StoneSetSpacing.sm),
              OutlinedButton.icon(
                onPressed: onOpenVersions,
                icon: const Icon(Icons.history),
                label: const Text('Open versions'),
              ),
            ],
          ),
        ),
        const SizedBox(height: StoneSetSpacing.md),
      ],
    );
  }
}

class _GuidanceSaveBanner extends StatelessWidget {
  const _GuidanceSaveBanner({
    required this.status,
    required this.message,
    required this.onRetry,
    required this.onSave,
  });

  final DashboardGuidanceSaveState status;
  final String? message;
  final Future<void> Function()? onRetry;
  final Future<void> Function()? onSave;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      DashboardGuidanceSaveState.saving => 'Saving browser recovery',
      DashboardGuidanceSaveState.saved => 'Draft saved',
      DashboardGuidanceSaveState.offline => 'Offline — browser recovery only',
      DashboardGuidanceSaveState.syncing => 'Syncing authoritative draft',
      DashboardGuidanceSaveState.conflict => 'Conflict — review required',
      DashboardGuidanceSaveState.failed => 'Failed to save browser recovery',
      DashboardGuidanceSaveState.readOnly => 'Read only',
    };
    final kind = switch (status) {
      DashboardGuidanceSaveState.saving ||
      DashboardGuidanceSaveState.syncing => StoneSetStatusKind.pending,
      DashboardGuidanceSaveState.saved => StoneSetStatusKind.success,
      DashboardGuidanceSaveState.offline => StoneSetStatusKind.offline,
      DashboardGuidanceSaveState.conflict => StoneSetStatusKind.conflict,
      DashboardGuidanceSaveState.failed => StoneSetStatusKind.error,
      DashboardGuidanceSaveState.readOnly => StoneSetStatusKind.information,
    };
    return Semantics(
      liveRegion: status != DashboardGuidanceSaveState.saved,
      label: '$label. ${message ?? ''}',
      child: StoneSetCard(
        child: Row(
          children: <Widget>[
            StoneSetStatusIndicator(kind: kind, label: label),
            if (message != null) ...<Widget>[
              const SizedBox(width: StoneSetSpacing.sm),
              Expanded(child: Text(message!)),
            ] else
              const Spacer(),
            if (status == DashboardGuidanceSaveState.failed && onRetry != null)
              TextButton(onPressed: () => unawaited(onRetry!()), child: const Text('Retry')),
            if (status == DashboardGuidanceSaveState.offline && onSave != null)
              TextButton(onPressed: () => unawaited(onSave!()), child: const Text('Sync now')),
          ],
        ),
      ),
    );
  }
}

class _GuidancePublicationBanner extends StatelessWidget {
  const _GuidancePublicationBanner({required this.media, required this.readOnly});

  final AsyncValue<DashboardGuidanceMediaState> media;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      return const _PublicationStatusCard(
        kind: StoneSetStatusKind.information,
        label: 'Publication unavailable',
        message: 'This dashboard session is read only. No app guidance version can change.',
      );
    }
    return KeyedSubtree(
      key: const Key('guidance-publication-boundary'),
      child: media.when(
        loading: () => const _PublicationStatusCard(
          kind: StoneSetStatusKind.pending,
          label: 'Checking publication readiness',
          message: 'Loading the authoritative media draft before Publish can be enabled.',
        ),
        error: (_, __) => const _PublicationStatusCard(
          kind: StoneSetStatusKind.error,
          label: 'Publication blocked',
          message: 'The authoritative media draft could not be loaded. Reload before publishing.',
        ),
        data: (state) {
          final youtube = state.manifest.youtube;
          if (youtube?.validationStatus == YouTubeValidationStatus.previewRequired) {
            return const _PublicationStatusCard(
              kind: StoneSetStatusKind.error,
              label: 'Publication blocked',
              message:
                  'YouTube preview validation is required. Load the preview in Media, play it until Stone Set marks it validated, then Publish. Validation expires after one hour.',
            );
          }
          if (state.status != DashboardGuidanceMediaStatus.ready) {
            return _PublicationStatusCard(
              kind: _mediaPublicationKind(state.status),
              label: 'Publication blocked',
              message: state.message ?? _mediaPublicationFallback(state.status),
            );
          }
          return const _PublicationStatusCard(
            kind: StoneSetStatusKind.information,
            label: 'Draft is not live',
            message:
                'Saving does not update the Android app. Publish must succeed first. The next newly started workout uses the published version; an active workout stays pinned to its existing version.',
          );
        },
      ),
    );
  }
}

class _PublicationStatusCard extends StatelessWidget {
  const _PublicationStatusCard({
    required this.kind,
    required this.label,
    required this.message,
  });

  final StoneSetStatusKind kind;
  final String label;
  final String message;

  @override
  Widget build(BuildContext context) => StoneSetCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StoneSetStatusIndicator(kind: kind, label: label),
        const SizedBox(width: StoneSetSpacing.sm),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class _GuidanceConflictView extends StatelessWidget {
  const _GuidanceConflictView({
    required this.exerciseName,
    required this.conflict,
    required this.onAcceptServer,
    required this.onUseLocal,
    required this.onRetry,
  });

  final String exerciseName;
  final DashboardGuidanceConflict conflict;
  final Future<void> Function()? onAcceptServer;
  final Future<void> Function()? onUseLocal;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      StoneSetResponsiveToolbar(
        title: '$exerciseName conflict',
        supportingText: 'Both variants are preserved. Choose explicitly; nothing is overwritten.',
        actions: <StoneSetDashboardAction>[
          StoneSetDashboardAction(
            id: 'refresh-conflict',
            label: 'Refresh comparison',
            icon: Icons.refresh,
            onPressed: () => unawaited(onRetry()),
          ),
        ],
      ),
      const SizedBox(height: StoneSetSpacing.md),
      const StoneSetStatusBanner(
        kind: StoneSetStatusKind.conflict,
        message:
            'Conflict. Compare browser-local and authoritative server content before continuing.',
      ),
      const SizedBox(height: StoneSetSpacing.md),
      Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final local = _GuidanceComparisonPane(
              title: 'Browser-local version',
              content: conflict.local,
              actionLabel: 'Use local as current draft',
              onAction: onUseLocal,
            );
            final remote = _GuidanceComparisonPane(
              title: 'Authoritative server version',
              content: conflict.remote,
              actionLabel: 'Accept server version',
              onAction: onAcceptServer,
            );
            if (constraints.maxWidth < 900) {
              return ListView(
                children: <Widget>[
                  local,
                  const SizedBox(height: StoneSetSpacing.md),
                  remote,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: SingleChildScrollView(child: local)),
                const SizedBox(width: StoneSetSpacing.md),
                Expanded(child: SingleChildScrollView(child: remote)),
              ],
            );
          },
        ),
      ),
    ],
  );
}

class _GuidanceComparisonPane extends StatelessWidget {
  const _GuidanceComparisonPane({
    required this.title,
    required this.content,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final GuidanceContentV1 content;
  final String actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) => StoneSetCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        const SizedBox(height: StoneSetSpacing.md),
        Text(content.shortExplanation),
        for (final section in DashboardGuidanceSection.values) ...<Widget>[
          const SizedBox(height: StoneSetSpacing.md),
          Text(section.label, style: Theme.of(context).textTheme.titleSmall),
          for (final item in _sectionValues(content, section)) Text('• $item'),
        ],
        const SizedBox(height: StoneSetSpacing.md),
        FilledButton(
          onPressed: onAction == null ? null : () => unawaited(onAction!()),
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}

List<String> _sectionValues(GuidanceContentV1 content, DashboardGuidanceSection section) =>
    switch (section) {
      DashboardGuidanceSection.setup => content.setupSteps,
      DashboardGuidanceSection.execution => content.executionSteps,
      DashboardGuidanceSection.cues => content.techniqueCues,
      DashboardGuidanceSection.mistakes => content.commonMistakes,
      DashboardGuidanceSection.safety => content.safetyNotes,
    };

bool _guidanceNeedsExitGuard(DashboardGuidanceEditorState state) => switch (state.status) {
  DashboardGuidanceSaveState.saving ||
  DashboardGuidanceSaveState.offline ||
  DashboardGuidanceSaveState.syncing ||
  DashboardGuidanceSaveState.conflict ||
  DashboardGuidanceSaveState.failed => true,
  DashboardGuidanceSaveState.saved || DashboardGuidanceSaveState.readOnly => false,
};

bool _mediaNeedsExitGuard(DashboardGuidanceMediaState? state) => switch (state?.status) {
  DashboardGuidanceMediaStatus.processing ||
  DashboardGuidanceMediaStatus.uploading ||
  DashboardGuidanceMediaStatus.saving ||
  DashboardGuidanceMediaStatus.failed ||
  DashboardGuidanceMediaStatus.offline ||
  DashboardGuidanceMediaStatus.conflict => true,
  _ => false,
};

bool _mediaReadyForPublication(AsyncValue<DashboardGuidanceMediaState> media) {
  final state = media.value;
  if (state == null || state.status != DashboardGuidanceMediaStatus.ready) return false;
  return state.manifest.youtube?.validationStatus != YouTubeValidationStatus.previewRequired;
}

StoneSetStatusKind _mediaPublicationKind(DashboardGuidanceMediaStatus status) => switch (status) {
  DashboardGuidanceMediaStatus.loading ||
  DashboardGuidanceMediaStatus.processing ||
  DashboardGuidanceMediaStatus.uploading ||
  DashboardGuidanceMediaStatus.saving => StoneSetStatusKind.pending,
  DashboardGuidanceMediaStatus.offline => StoneSetStatusKind.offline,
  DashboardGuidanceMediaStatus.conflict => StoneSetStatusKind.conflict,
  DashboardGuidanceMediaStatus.failed ||
  DashboardGuidanceMediaStatus.permissionDenied => StoneSetStatusKind.error,
  DashboardGuidanceMediaStatus.cancelled ||
  DashboardGuidanceMediaStatus.readOnly ||
  DashboardGuidanceMediaStatus.ready => StoneSetStatusKind.information,
};

String _mediaPublicationFallback(DashboardGuidanceMediaStatus status) => switch (status) {
  DashboardGuidanceMediaStatus.loading => 'Media is still loading.',
  DashboardGuidanceMediaStatus.processing => 'Wait for image processing to finish.',
  DashboardGuidanceMediaStatus.uploading => 'Wait for image upload to finish.',
  DashboardGuidanceMediaStatus.saving => 'Wait for the media draft to finish saving.',
  DashboardGuidanceMediaStatus.cancelled => 'Media work was cancelled. Reload before publishing.',
  DashboardGuidanceMediaStatus.offline => 'Reconnect before publishing.',
  DashboardGuidanceMediaStatus.permissionDenied => 'This session cannot publish media.',
  DashboardGuidanceMediaStatus.conflict => 'Reload the authoritative media draft before publishing.',
  DashboardGuidanceMediaStatus.failed => 'Resolve the media error before publishing.',
  DashboardGuidanceMediaStatus.readOnly => 'This dashboard session is read only.',
  DashboardGuidanceMediaStatus.ready => 'Media is ready for publication.',
};

void _focusField(BuildContext context, String field) {
  final normalized = field == 'content' ? 'setupSteps' : field.split('[').first;
  final key = normalized == 'shortExplanation'
      ? const Key('guidance-field-shortExplanation')
      : Key('guidance-field-$normalized-0');
  final element = _findElement(context as Element, key);
  if (element == null) return;
  unawaited(Scrollable.ensureVisible(element, alignment: 0.15));
  final editable = _findEditable(element);
  editable?.widget.focusNode.requestFocus();
}

Element? _findElement(Element root, Key key) {
  Element? result;
  void visit(Element element) {
    if (result != null) return;
    if (element.widget.key == key) {
      result = element;
      return;
    }
    element.visitChildren(visit);
  }

  visit(root);
  return result;
}

EditableTextState? _findEditable(Element root) {
  EditableTextState? result;
  void visit(Element element) {
    if (result != null) return;
    if (element is StatefulElement && element.state is EditableTextState) {
      result = element.state as EditableTextState;
      return;
    }
    element.visitChildren(visit);
  }

  visit(root);
  return result;
}