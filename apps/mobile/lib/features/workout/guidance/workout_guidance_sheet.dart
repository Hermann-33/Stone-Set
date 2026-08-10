import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/workouts.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import 'workout_guidance_loader.dart';
import 'workout_guidance_providers.dart';
import 'workout_youtube_player.dart';

Future<void> showWorkoutGuidanceSheet(
  BuildContext context,
  WorkoutExercise exercise,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => FractionallySizedBox(
    heightFactor: 0.92,
    child: WorkoutGuidanceSheet(exercise: exercise),
  ),
);

class WorkoutGuidanceSheet extends ConsumerStatefulWidget {
  const WorkoutGuidanceSheet({required this.exercise, super.key});

  final WorkoutExercise exercise;

  @override
  ConsumerState<WorkoutGuidanceSheet> createState() => _WorkoutGuidanceSheetState();
}

class _WorkoutGuidanceSheetState extends ConsumerState<WorkoutGuidanceSheet> {
  late Future<WorkoutGuidanceBundle> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<WorkoutGuidanceBundle> _load() =>
      ref.read(workoutGuidanceLoaderProvider).load(widget.exercise);

  void _retry() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkoutGuidanceBundle>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final bundle = snapshot.data;
        if (bundle == null) {
          return _GuidanceError(onRetry: _retry);
        }
        return _GuidanceContent(
          exercise: widget.exercise,
          bundle: bundle,
          onReload: _retry,
        );
      },
    );
  }
}

class _GuidanceContent extends StatelessWidget {
  const _GuidanceContent({
    required this.exercise,
    required this.bundle,
    required this.onReload,
  });

  final WorkoutExercise exercise;
  final WorkoutGuidanceBundle bundle;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final content = bundle.guidance.content;
    final youtube = bundle.media.youtube;
    final hasContent =
        content.shortExplanation.isNotEmpty ||
        content.setupSteps.isNotEmpty ||
        content.executionSteps.isNotEmpty ||
        content.techniqueCues.isNotEmpty ||
        content.commonMistakes.isNotEmpty ||
        content.safetyNotes.isNotEmpty ||
        bundle.images.isNotEmpty ||
        (youtube?.isPublishable ?? false);
    return ListView(
      key: Key('workout-guidance-${exercise.id}'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: <Widget>[
        StoneSetPageHeader(
          eyebrow: 'Workout guidance',
          title: exercise.title,
          description: 'Pinned guidance · revision ${bundle.guidance.versionNumber}',
          trailing: IconButton(
            key: const Key('workout-guidance-refresh'),
            tooltip: 'Refresh guidance',
            onPressed: onReload,
            icon: const Icon(Icons.refresh),
          ),
        ),
        const SizedBox(height: StoneSetSpacing.xl),
        if (!hasContent)
          const StoneSetStatePanel(
            title: 'No additional guidance',
            message: 'This pinned revision contains no extra coaching content.',
            icon: Icons.menu_book_outlined,
          ),
        if (content.shortExplanation.isNotEmpty) ...<Widget>[
          Text(content.shortExplanation),
          const SizedBox(height: 18),
        ],
        _GuidanceList(title: 'Setup', items: content.setupSteps),
        _GuidanceList(title: 'Execution', items: content.executionSteps),
        _GuidanceList(title: 'Technique cues', items: content.techniqueCues),
        _GuidanceList(title: 'Common mistakes', items: content.commonMistakes),
        _GuidanceList(title: 'Safety notes', items: content.safetyNotes),
        if (bundle.images.isNotEmpty) ...<Widget>[
          const StoneSetSectionHeader(title: 'Images'),
          const SizedBox(height: 8),
          for (final image in bundle.images) ...<Widget>[
            Semantics(
              image: true,
              label: image.asset.altText.isEmpty ? exercise.title : image.asset.altText,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: image.asset.width / image.asset.height,
                  child: Image.network(
                    image.url.toString(),
                    key: Key('workout-guidance-image-${image.asset.id}'),
                    fit: BoxFit.cover,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded || frame != null) return child;
                      return const ColoredBox(
                        color: Colors.black12,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: Colors.black12,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(Icons.broken_image_outlined),
                            TextButton(
                              onPressed: onReload,
                              child: const Text('Reload'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (image.asset.altText.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(image.asset.altText),
            ],
            const SizedBox(height: 12),
          ],
        ],
        if (youtube != null && youtube.isPublishable) ...<Widget>[
          const StoneSetSectionHeader(title: 'Video'),
          const SizedBox(height: 8),
          if (youtube.titleSnapshot case final title? when title.isNotEmpty) ...<Widget>[
            Text(title),
            const SizedBox(height: 8),
          ],
          WorkoutYouTubePlayer(reference: youtube),
        ],
      ],
    );
  }
}

class _GuidanceList extends StatelessWidget {
  const _GuidanceList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: StoneSetCard(
        style: StoneSetCardStyle.base,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StoneSetSectionHeader(title: title),
            const SizedBox(height: StoneSetSpacing.sm),
            for (var index = 0; index < items.length; index += 1)
              Padding(
                padding: const EdgeInsets.only(bottom: StoneSetSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${index + 1}.',
                        style: StoneSetTextStyles.of(context).tableValue,
                      ),
                    ),
                    Expanded(child: Text(items[index])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GuidanceError extends StatelessWidget {
  const _GuidanceError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(StoneSetSpacing.xl),
      child: StoneSetStatePanel(
        title: 'Guidance could not be loaded',
        message: 'Your workout remains in place. Try loading this guidance again.',
        icon: Icons.info_outline,
        actionLabel: 'Retry',
        onAction: onRetry,
      ),
    ),
  );
}
