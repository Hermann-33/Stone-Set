import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_domain/exercise_media.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../../session/dashboard_session_controller.dart';
import '../controllers/dashboard_exercise_controllers.dart';
import '../controllers/dashboard_guidance_media_controller.dart';
import 'dashboard_exercise_library_view.dart';
import 'dashboard_private_media_image.dart';

class DashboardGuidanceRevisionView extends ConsumerWidget {
  const DashboardGuidanceRevisionView({
    required this.exerciseId,
    required this.revisionId,
    super.key,
  });

  final String exerciseId;
  final String revisionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revision = ref.watch(
      dashboardGuidanceRevisionProvider((exerciseId: exerciseId, revisionId: revisionId)),
    );
    final exercise = ref.watch(dashboardExerciseProvider(exerciseId));
    return ColoredBox(
      color: StoneSetSemanticColors.of(context).canvas,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(StoneSetSpacing.md),
          child: revision.when(
            loading: () => const StoneSetDashboardStatePanel(
              state: StoneSetDashboardPanelState.loading,
              title: 'Loading immutable version',
              message: 'Fetching published guidance evidence.',
            ),
            error: (error, _) => DashboardExerciseErrorPanel(
              error: error,
              onRetry: () => ref.invalidate(
                dashboardGuidanceRevisionProvider((exerciseId: exerciseId, revisionId: revisionId)),
              ),
            ),
            data: (value) => exercise.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => DashboardExerciseErrorPanel(error: error),
              data: (definition) => _RevisionContent(
                exercise: definition,
                revision: value,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RevisionContent extends ConsumerWidget {
  const _RevisionContent({required this.exercise, required this.revision});

  final ExerciseDefinition exercise;
  final GuidanceRevision revision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(dashboardSessionControllerProvider);
    final media = ref.watch(
      dashboardGuidanceRevisionMediaProvider((
        exerciseId: exercise.id,
        revisionId: revision.id,
      )),
    );
    final draft = exercise.currentDraft;
    final canDuplicate =
        draft != null &&
        session.userId == exercise.userId &&
        !(session.bootstrap?.compatibility.readOnlyMode ?? false) &&
        !exercise.isArchived;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        StoneSetResponsiveToolbar(
          title: '${exercise.canonicalName} · Version ${revision.versionNumber}',
          supportingText: 'Published guidance is immutable. Restore always creates a new draft.',
          actions: <StoneSetDashboardAction>[
            StoneSetDashboardAction(
              id: 'back-to-exercise',
              label: 'Exercise',
              icon: Icons.arrow_back,
              onPressed: () => context.go('/exercises/${exercise.id}'),
            ),
            StoneSetDashboardAction(
              id: 'duplicate-version',
              label: 'Duplicate as draft',
              icon: Icons.copy_all_outlined,
              enabled: canDuplicate,
              onPressed: () => _duplicate(context, ref, draft!),
            ),
          ],
        ),
        const SizedBox(height: StoneSetSpacing.sm),
        StoneSetStatusBanner(
          kind: StoneSetStatusKind.information,
          message:
              'Immutable version · Published ${revision.publishedAt.toLocal()} · Content hash ${revision.contentHash}',
        ),
        const SizedBox(height: StoneSetSpacing.md),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final published = _RevisionPane(
                title: 'Published version ${revision.versionNumber}',
                content: revision.content,
                footer: 'Revision hash ${revision.revisionHash}',
                media: media.when(
                  loading: () => const LinearProgressIndicator(
                    semanticsLabel: 'Loading immutable media manifest',
                  ),
                  error: (error, _) => const Text(
                    'Immutable media evidence is unavailable. Retry from this version page.',
                  ),
                  data: (manifest) => _PublishedMediaEvidence(manifest: manifest),
                ),
              );
              final currentDraft = _RevisionPane(
                title: 'Current editable draft',
                content: draft?.content,
                footer: draft == null
                    ? 'No current draft is available.'
                    : 'Draft revision ${draft.revision} · Not published',
              );
              if (constraints.maxWidth < 900) {
                return ListView(
                  key: const Key('guidance-revision-compact'),
                  children: <Widget>[
                    published,
                    const SizedBox(height: StoneSetSpacing.md),
                    currentDraft,
                  ],
                );
              }
              return Row(
                key: const Key('guidance-revision-expanded'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: SingleChildScrollView(child: published)),
                  const SizedBox(width: StoneSetSpacing.md),
                  Expanded(child: SingleChildScrollView(child: currentDraft)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _duplicate(
    BuildContext context,
    WidgetRef ref,
    GuidanceDraft draft,
  ) async {
    final mediaRequest = DashboardGuidanceMediaRequest(
      exerciseId: exercise.id,
      draftId: draft.id,
    );
    await ref.read(dashboardGuidanceMediaControllerProvider(mediaRequest).future);
    final result = await ref
        .read(dashboardGuidanceMediaControllerProvider(mediaRequest).notifier)
        .duplicateRevisionAsDraft(
          guidanceRevisionId: revision.id,
          draftRevision: draft.revision,
        );
    if (result != null && context.mounted) {
      context.go('/exercises/${exercise.id}/guidance/drafts/${draft.id}');
    }
  }
}

class _RevisionPane extends StatelessWidget {
  const _RevisionPane({
    required this.title,
    required this.content,
    required this.footer,
    this.media,
  });

  final String title;
  final GuidanceContentV1? content;
  final String footer;
  final Widget? media;

  @override
  Widget build(BuildContext context) => StoneSetCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        const SizedBox(height: StoneSetSpacing.md),
        if (content == null)
          const Text('Nothing to compare.')
        else ...<Widget>[
          Text(content!.shortExplanation),
          _RevisionList(title: 'Setup', values: content!.setupSteps),
          _RevisionList(title: 'Execution', values: content!.executionSteps),
          _RevisionList(title: 'Technique cues', values: content!.techniqueCues),
          _RevisionList(title: 'Common mistakes', values: content!.commonMistakes),
          _RevisionList(title: 'Safety notes', values: content!.safetyNotes),
        ],
        if (media case final media?) ...<Widget>[
          const SizedBox(height: StoneSetSpacing.md),
          media,
        ],
        const SizedBox(height: StoneSetSpacing.md),
        Text(footer, style: StoneSetTextStyles.of(context).caption),
      ],
    ),
  );
}

class _PublishedMediaEvidence extends StatelessWidget {
  const _PublishedMediaEvidence({required this.manifest});

  final GuidanceMediaManifest manifest;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Semantics(
        header: true,
        child: Text('Immutable Media', style: Theme.of(context).textTheme.titleSmall),
      ),
      if (manifest.images.isEmpty && manifest.youtube == null)
        const Text('This version has no media.')
      else ...<Widget>[
        for (final image in manifest.images) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(top: StoneSetSpacing.xs),
            child: DashboardPrivateMediaImage(asset: image),
          ),
          Padding(
            padding: const EdgeInsets.only(top: StoneSetSpacing.xs),
            child: Text(
              'Image ${image.position + 1}${image.isCover ? ' · Cover' : ''}: ${image.altText} '
              '(${image.width} × ${image.height})',
            ),
          ),
        ],
        if (manifest.youtube case final youtube?) ...<Widget>[
          const SizedBox(height: StoneSetSpacing.xs),
          Text('YouTube: ${youtube.canonicalWatchUrl}'),
        ],
      ],
      if (manifest.manifestHash case final hash?) ...<Widget>[
        const SizedBox(height: StoneSetSpacing.xs),
        Text('Media manifest hash $hash', style: StoneSetTextStyles.of(context).caption),
      ],
    ],
  );
}

class _RevisionList extends StatelessWidget {
  const _RevisionList({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: StoneSetSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        if (values.isEmpty) Text('None', style: StoneSetTextStyles.of(context).caption),
        for (final value in values) Text('• $value'),
      ],
    ),
  );
}
