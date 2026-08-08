import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../../session/dashboard_session_controller.dart';
import '../controllers/dashboard_exercise_controllers.dart';
import 'dashboard_exercise_editor_view.dart';

class DashboardExerciseLibraryView extends ConsumerStatefulWidget {
  const DashboardExerciseLibraryView({
    required this.request,
    this.selectedExerciseId,
    this.editSelected = false,
    super.key,
  });

  final DashboardExerciseLibraryRequest request;
  final String? selectedExerciseId;
  final bool editSelected;

  @override
  ConsumerState<DashboardExerciseLibraryView> createState() => _DashboardExerciseLibraryViewState();
}

class _DashboardExerciseLibraryViewState extends ConsumerState<DashboardExerciseLibraryView> {
  late final TextEditingController _searchController;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.request.search);
  }

  @override
  void didUpdateWidget(covariant DashboardExerciseLibraryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request.search != widget.request.search &&
        _searchController.text != widget.request.search) {
      _searchController.text = widget.request.search ?? '';
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(dashboardExerciseLibraryControllerProvider(widget.request));
    final readOnly =
        ref.watch(dashboardSessionControllerProvider).bootstrap?.compatibility.readOnlyMode ??
        false;
    return ColoredBox(
      color: StoneSetSemanticColors.of(context).canvas,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(StoneSetSpacing.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final accessibleCompact =
                  constraints.maxWidth < 500 || MediaQuery.textScalerOf(context).scale(1) > 1.5;
              final newExercise = StoneSetDashboardAction(
                id: 'new-exercise',
                label: 'New exercise',
                icon: Icons.add,
                enabled: !readOnly,
                onPressed: () => context.go('/exercises/new'),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  StoneSetResponsiveToolbar(
                    title: 'Exercise library',
                    supportingText:
                        'Owner-scoped definitions and structured, immutable guidance history.',
                    actions: accessibleCompact
                        ? const <StoneSetDashboardAction>[]
                        : <StoneSetDashboardAction>[newExercise],
                  ),
                  if (accessibleCompact) ...<Widget>[
                    const SizedBox(height: StoneSetSpacing.sm),
                    StoneSetButton(
                      key: const Key('dashboard-toolbar-new-exercise'),
                      label: newExercise.label,
                      icon: newExercise.icon,
                      onPressed: newExercise.enabled ? newExercise.onPressed : null,
                    ),
                  ],
                  const SizedBox(height: StoneSetSpacing.md),
                  StoneSetFilterHeader(
                    searchController: _searchController,
                    searchLabel: 'Search your exercises',
                    onSearchChanged: _searchChanged,
                    filters: accessibleCompact
                        ? <Widget>[
                            SizedBox(
                              width: constraints.maxWidth,
                              child: _ExerciseFilterMenu(
                                request: widget.request,
                                onArchiveChanged: (value) => _navigate(archive: value),
                                onPublicationChanged: (value) => _navigate(publication: value),
                                onSortChanged: (value) => _navigate(sort: value),
                              ),
                            ),
                          ]
                        : <Widget>[
                            SizedBox(
                              width: 150,
                              child: _ArchiveFilter(
                                value: widget.request.archive,
                                onChanged: (value) => _navigate(archive: value),
                              ),
                            ),
                            SizedBox(
                              width: 170,
                              child: _PublicationFilter(
                                value: widget.request.publication,
                                onChanged: (value) => _navigate(publication: value),
                              ),
                            ),
                            SizedBox(
                              width: 190,
                              child: _SortFilter(
                                value: widget.request.sort,
                                onChanged: (value) => _navigate(sort: value),
                              ),
                            ),
                          ],
                  ),
                  const SizedBox(height: StoneSetSpacing.md),
                  Expanded(
                    child: library.when(
                      loading: () => const StoneSetDashboardStatePanel(
                        state: StoneSetDashboardPanelState.loading,
                        title: 'Loading exercises',
                        message: 'Fetching the permission-filtered owner library.',
                      ),
                      error: (error, _) => DashboardExerciseErrorPanel(
                        error: error,
                        onRetry: () => ref
                            .read(
                              dashboardExerciseLibraryControllerProvider(widget.request).notifier,
                            )
                            .refresh(),
                      ),
                      data: (data) => _ExerciseLibraryContent(
                        request: widget.request,
                        data: data,
                        selectedExerciseId: widget.selectedExerciseId,
                        editSelected: widget.editSelected,
                        readOnly: readOnly,
                        onSelect: _select,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _searchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _navigate(search: value, replaceSearch: true);
    });
  }

  void _select(String exerciseId) => context.go(
    _exerciseLocation(exerciseId: exerciseId, request: widget.request),
  );

  void _navigate({
    String? search,
    bool replaceSearch = false,
    ExerciseArchiveFilter? archive,
    ExercisePublicationFilter? publication,
    ExerciseLibrarySort? sort,
  }) {
    final next = DashboardExerciseLibraryRequest(
      search: replaceSearch ? search : widget.request.search,
      archive: archive ?? widget.request.archive,
      publication: publication ?? widget.request.publication,
      equipmentKey: widget.request.equipmentKey,
      muscleKey: widget.request.muscleKey,
      sort: sort ?? widget.request.sort,
    );
    context.go(_exerciseLocation(exerciseId: widget.selectedExerciseId, request: next));
  }
}

class _ExerciseLibraryContent extends ConsumerWidget {
  const _ExerciseLibraryContent({
    required this.request,
    required this.data,
    required this.selectedExerciseId,
    required this.editSelected,
    required this.readOnly,
    required this.onSelect,
  });

  final DashboardExerciseLibraryRequest request;
  final DashboardExerciseLibraryState data;
  final String? selectedExerciseId;
  final bool editSelected;
  final bool readOnly;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.page.items.isEmpty && selectedExerciseId == null) {
      return StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.empty,
        title: request.search == null ? 'No exercises yet' : 'No matching exercises',
        message: request.search == null
            ? 'Create an owner-scoped exercise to begin structured guidance.'
            : 'Adjust the search or filters. Only exercises you may read appear here.',
        actionLabel: readOnly ? null : 'Create exercise',
        onAction: readOnly ? null : () => context.go('/exercises/new'),
      );
    }
    final muscleNames = ref
        .watch(dashboardMusclesProvider)
        .maybeWhen(
          data: (muscles) => <String, String>{
            for (final muscle in muscles) muscle.id: muscle.displayName,
          },
          orElse: () => const <String, String>{},
        );
    return StoneSetListDetailScaffold(
      mediumBreakpoint: 720,
      expandedBreakpoint: 1120,
      hasSelection: selectedExerciseId != null,
      compactDetailTitle: 'Back to exercise library',
      onCompactBack: () => context.go(_exerciseLocation(request: request)),
      list: _ExerciseList(
        data: data,
        muscleNames: muscleNames,
        selectedExerciseId: selectedExerciseId,
        onSelect: onSelect,
        onNextPage: data.page.hasNextPage
            ? () => context.go(
                _exerciseLocation(
                  request: DashboardExerciseLibraryRequest(
                    search: request.search,
                    archive: request.archive,
                    publication: request.publication,
                    equipmentKey: request.equipmentKey,
                    muscleKey: request.muscleKey,
                    sort: request.sort,
                    page: request.page + 1,
                  ),
                ),
              )
            : null,
      ),
      detail: selectedExerciseId == null
          ? const SizedBox.shrink()
          : editSelected
          ? DashboardExerciseEditorView(exerciseId: selectedExerciseId!, embedded: true)
          : DashboardExerciseDetailView(
              exerciseId: selectedExerciseId!,
              libraryRequest: request,
              readOnly: readOnly,
            ),
      emptyDetail: const StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.empty,
        title: 'Choose an exercise',
        message: 'Select an owner-scoped exercise to inspect guidance and versions.',
      ),
    );
  }
}

class _ExerciseList extends StatelessWidget {
  const _ExerciseList({
    required this.data,
    required this.muscleNames,
    required this.selectedExerciseId,
    required this.onSelect,
    required this.onNextPage,
  });

  final DashboardExerciseLibraryState data;
  final Map<String, String> muscleNames;
  final String? selectedExerciseId;
  final ValueChanged<String> onSelect;
  final VoidCallback? onNextPage;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Semantics(
        liveRegion: true,
        label: '${data.page.totalCount} exercises',
        child: ExcludeSemantics(
          child: Text(
            '${data.page.totalCount} ${data.page.totalCount == 1 ? 'exercise' : 'exercises'}',
            style: StoneSetTextStyles.of(context).caption,
          ),
        ),
      ),
      const SizedBox(height: StoneSetSpacing.xs),
      Expanded(
        child: ListView.builder(
          key: const Key('exercise-library-list'),
          itemCount: data.page.items.length + (onNextPage == null ? 0 : 1),
          itemBuilder: (context, index) {
            if (index == data.page.items.length) {
              return Padding(
                padding: const EdgeInsets.all(StoneSetSpacing.sm),
                child: OutlinedButton(
                  key: const Key('exercise-library-next-page'),
                  onPressed: onNextPage,
                  child: const Text('Next page'),
                ),
              );
            }
            final exercise = data.page.items[index];
            final primary = exercise.primaryMuscleIds
                .map((id) => muscleNames[id])
                .whereType<String>()
                .join(', ');
            final state = exercise.isArchived
                ? 'Archived'
                : !exercise.published
                ? 'Draft guidance'
                : 'Published guidance v${exercise.latestGuidanceVersionNumber}';
            return StoneSetSelectableRow(
              key: Key('exercise-row-${exercise.id}'),
              title: exercise.canonicalName,
              subtitle:
                  '${exercise.equipmentKeys.join(', ')} · ${primary.isEmpty ? 'Muscle taxonomy loading' : primary} · $state',
              selected: selectedExerciseId == exercise.id,
              onSelect: () => onSelect(exercise.id),
              leading: Icon(
                exercise.isArchived ? Icons.archive_outlined : Icons.fitness_center_outlined,
              ),
              trailing: data.pendingExerciseId == exercise.id
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
            );
          },
        ),
      ),
    ],
  );
}

class DashboardExerciseDetailView extends ConsumerWidget {
  const DashboardExerciseDetailView({
    required this.exerciseId,
    required this.libraryRequest,
    required this.readOnly,
    super.key,
  });

  final String exerciseId;
  final DashboardExerciseLibraryRequest libraryRequest;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(dashboardExerciseProvider(exerciseId));
    return exercise.when(
      loading: () => const StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.loading,
        title: 'Loading exercise',
        message: 'Fetching the current owner-scoped definition.',
      ),
      error: (error, _) => DashboardExerciseErrorPanel(
        error: error,
        onRetry: () => ref.invalidate(dashboardExerciseProvider(exerciseId)),
      ),
      data: (value) => _content(context, ref, value),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, ExerciseDefinition exercise) {
    final revisions = ref.watch(dashboardGuidanceRevisionsProvider(exercise.id));
    return ListView(
      key: const Key('exercise-detail'),
      padding: const EdgeInsets.all(StoneSetSpacing.md),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(
                      exercise.canonicalName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: StoneSetSpacing.xxs),
                  Text(
                    exercise.variantKey == null
                        ? 'Stable owner-scoped definition'
                        : 'Variant: ${exercise.variantKey}',
                    style: StoneSetTextStyles.of(context).compactBody,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              key: const Key('exercise-detail-actions'),
              tooltip: 'Exercise actions',
              onSelected: (action) => _action(context, ref, exercise, action),
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  enabled: !readOnly && !exercise.hasPublishedGuidance,
                  child: const Text('Edit identity'),
                ),
                PopupMenuItem<String>(
                  value: 'clone',
                  enabled: !readOnly,
                  child: const Text('Clone into my library'),
                ),
                PopupMenuItem<String>(
                  value: exercise.isArchived ? 'unarchive' : 'archive',
                  enabled: !readOnly,
                  child: Text(exercise.isArchived ? 'Unarchive' : 'Archive'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: StoneSetSpacing.md),
        _DetailSection(
          title: 'Overview',
          child: Wrap(
            spacing: StoneSetSpacing.xs,
            runSpacing: StoneSetSpacing.xs,
            children: <Widget>[
              for (final equipment in exercise.equipmentKeys) Chip(label: Text(equipment)),
              for (final muscle in exercise.primaryMuscles)
                Chip(label: Text('${muscle.muscle.displayName} · Primary')),
              for (final muscle in exercise.secondaryMuscles)
                Chip(label: Text('${muscle.muscle.displayName} · Secondary')),
            ],
          ),
        ),
        const SizedBox(height: StoneSetSpacing.sm),
        _DetailSection(
          title: 'Guidance',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                !exercise.hasPublishedGuidance
                    ? 'No immutable guidance version has been published.'
                    : 'Published version ${exercise.latestGuidanceVersionNumber}. Open Versions for immutable timestamps and hashes.',
              ),
              const SizedBox(height: StoneSetSpacing.sm),
              if (exercise.currentDraft case final draft?)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: StoneSetButton(
                    key: const Key('open-guidance-draft'),
                    label: 'Edit structured guidance',
                    icon: Icons.edit_note_outlined,
                    onPressed: readOnly
                        ? null
                        : () => context.go(
                            '/exercises/${exercise.id}/guidance/drafts/${draft.id}',
                          ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: StoneSetSpacing.sm),
        _DetailSection(
          title: 'Versions',
          child: revisions.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Version history is unavailable: ${_safeError(error)}'),
            data: (page) => page.items.isEmpty
                ? const Text('Published guidance versions will appear here.')
                : Column(
                    children: <Widget>[
                      for (final revision in page.items)
                        ListTile(
                          key: Key('guidance-version-${revision.id}'),
                          title: Text('Version ${revision.versionNumber}'),
                          subtitle: Text(
                            '${revision.publishedAt.toLocal()} · ${revision.contentHash.substring(0, 12)}…',
                          ),
                          trailing: const Icon(Icons.compare_arrows),
                          onTap: () => context.go(
                            '/exercises/${exercise.id}/guidance/revisions/${revision.id}',
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: StoneSetSpacing.sm),
        const _UnavailableSection(
          title: 'Media',
          message: 'Images and YouTube arrive in TASK-IMP-003B. No media is persisted here.',
        ),
        const SizedBox(height: StoneSetSpacing.sm),
        const _UnavailableSection(
          title: 'Routine usage',
          message: 'Routine references arrive in TASK-IMP-003C. No usage count is inferred.',
        ),
      ],
    );
  }

  Future<void> _action(
    BuildContext context,
    WidgetRef ref,
    ExerciseDefinition exercise,
    String action,
  ) async {
    if (action == 'edit') {
      context.go(
        _exerciseLocation(exerciseId: exercise.id, request: libraryRequest, mode: 'edit'),
      );
      return;
    }
    final controller = ref.read(
      dashboardExerciseLibraryControllerProvider(libraryRequest).notifier,
    );
    if (action == 'clone') {
      final cloneId = await controller.clone(exercise);
      if (context.mounted && cloneId != null) {
        context.go(_exerciseLocation(exerciseId: cloneId, request: libraryRequest));
      }
      return;
    }
    await controller.setArchived(exercise, archived: action == 'archive');
    if (context.mounted) {
      context.go(_exerciseLocation(request: libraryRequest));
    }
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => StoneSetCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
        const SizedBox(height: StoneSetSpacing.sm),
        child,
      ],
    ),
  );
}

class _UnavailableSection extends StatelessWidget {
  const _UnavailableSection({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => _DetailSection(
    title: title,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Icon(Icons.lock_clock_outlined),
        const SizedBox(width: StoneSetSpacing.sm),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class DashboardExerciseErrorPanel extends StatelessWidget {
  const DashboardExerciseErrorPanel({required this.error, this.onRetry, super.key});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = error is ExerciseGuidanceFailure ? error as ExerciseGuidanceFailure : null;
    final state = switch (failure?.code) {
      ExerciseGuidanceErrorCode.forbidden ||
      ExerciseGuidanceErrorCode.inactiveProfile ||
      ExerciseGuidanceErrorCode.passwordChangeRequired =>
        StoneSetDashboardPanelState.permissionDenied,
      ExerciseGuidanceErrorCode.networkUnavailable ||
      ExerciseGuidanceErrorCode.serverUnavailable => StoneSetDashboardPanelState.offline,
      _ => StoneSetDashboardPanelState.error,
    };
    final title = switch (failure?.code) {
      ExerciseGuidanceErrorCode.notFound => 'Exercise not found',
      ExerciseGuidanceErrorCode.forbidden => 'Exercise unavailable',
      ExerciseGuidanceErrorCode.inactiveProfile => 'Profile is not active',
      ExerciseGuidanceErrorCode.passwordChangeRequired => 'Password change required',
      ExerciseGuidanceErrorCode.networkUnavailable => 'You are offline',
      _ => 'Exercise library unavailable',
    };
    final message = switch (failure?.code) {
      ExerciseGuidanceErrorCode.notFound =>
        'This owner-scoped exercise does not exist or is no longer available.',
      ExerciseGuidanceErrorCode.forbidden =>
        'You do not have permission to read this owner-scoped exercise.',
      ExerciseGuidanceErrorCode.networkUnavailable =>
        'Reconnect and retry. Existing browser recovery remains non-authoritative.',
      _ => 'Stone Set could not safely load this content. Retry without changing the URL.',
    };
    return StoneSetDashboardStatePanel(
      state: state,
      title: title,
      message: message,
      actionLabel: onRetry == null ? null : 'Retry',
      onAction: onRetry,
    );
  }
}

class _ArchiveFilter extends StatelessWidget {
  const _ArchiveFilter({required this.value, required this.onChanged});

  final ExerciseArchiveFilter value;
  final ValueChanged<ExerciseArchiveFilter> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButton<ExerciseArchiveFilter>(
    key: const Key('exercise-archive-filter'),
    isExpanded: true,
    value: value,
    onChanged: (next) {
      if (next != null) onChanged(next);
    },
    items: const <DropdownMenuItem<ExerciseArchiveFilter>>[
      DropdownMenuItem(value: ExerciseArchiveFilter.active, child: Text('Active')),
      DropdownMenuItem(value: ExerciseArchiveFilter.archived, child: Text('Archived')),
      DropdownMenuItem(value: ExerciseArchiveFilter.all, child: Text('All states')),
    ],
  );
}

enum _ExerciseFilterAction {
  active,
  archived,
  allArchives,
  allGuidance,
  drafts,
  published,
  recentlyUpdated,
  nameAscending,
  nameDescending,
}

class _ExerciseFilterMenu extends StatelessWidget {
  const _ExerciseFilterMenu({
    required this.request,
    required this.onArchiveChanged,
    required this.onPublicationChanged,
    required this.onSortChanged,
  });

  final DashboardExerciseLibraryRequest request;
  final ValueChanged<ExerciseArchiveFilter> onArchiveChanged;
  final ValueChanged<ExercisePublicationFilter> onPublicationChanged;
  final ValueChanged<ExerciseLibrarySort> onSortChanged;

  @override
  Widget build(BuildContext context) => PopupMenuButton<_ExerciseFilterAction>(
    key: const Key('exercise-filter-menu'),
    tooltip: 'Exercise filters and sort',
    onSelected: (action) {
      switch (action) {
        case _ExerciseFilterAction.active:
          onArchiveChanged(ExerciseArchiveFilter.active);
        case _ExerciseFilterAction.archived:
          onArchiveChanged(ExerciseArchiveFilter.archived);
        case _ExerciseFilterAction.allArchives:
          onArchiveChanged(ExerciseArchiveFilter.all);
        case _ExerciseFilterAction.allGuidance:
          onPublicationChanged(ExercisePublicationFilter.all);
        case _ExerciseFilterAction.drafts:
          onPublicationChanged(ExercisePublicationFilter.draftOnly);
        case _ExerciseFilterAction.published:
          onPublicationChanged(ExercisePublicationFilter.published);
        case _ExerciseFilterAction.recentlyUpdated:
          onSortChanged(ExerciseLibrarySort.updatedDescending);
        case _ExerciseFilterAction.nameAscending:
          onSortChanged(ExerciseLibrarySort.nameAscending);
        case _ExerciseFilterAction.nameDescending:
          onSortChanged(ExerciseLibrarySort.nameDescending);
      }
    },
    itemBuilder: (context) => <PopupMenuEntry<_ExerciseFilterAction>>[
      const PopupMenuItem(enabled: false, child: Text('Archive state')),
      _filterItem(
        _ExerciseFilterAction.active,
        'Active',
        request.archive == ExerciseArchiveFilter.active,
      ),
      _filterItem(
        _ExerciseFilterAction.archived,
        'Archived',
        request.archive == ExerciseArchiveFilter.archived,
      ),
      _filterItem(
        _ExerciseFilterAction.allArchives,
        'All states',
        request.archive == ExerciseArchiveFilter.all,
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(enabled: false, child: Text('Guidance state')),
      _filterItem(
        _ExerciseFilterAction.allGuidance,
        'All guidance',
        request.publication == ExercisePublicationFilter.all,
      ),
      _filterItem(
        _ExerciseFilterAction.drafts,
        'Draft only',
        request.publication == ExercisePublicationFilter.draftOnly,
      ),
      _filterItem(
        _ExerciseFilterAction.published,
        'Published',
        request.publication == ExercisePublicationFilter.published,
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(enabled: false, child: Text('Sort order')),
      _filterItem(
        _ExerciseFilterAction.recentlyUpdated,
        'Recently updated',
        request.sort == ExerciseLibrarySort.updatedDescending,
      ),
      _filterItem(
        _ExerciseFilterAction.nameAscending,
        'Name A–Z',
        request.sort == ExerciseLibrarySort.nameAscending,
      ),
      _filterItem(
        _ExerciseFilterAction.nameDescending,
        'Name Z–A',
        request.sort == ExerciseLibrarySort.nameDescending,
      ),
    ],
    child: InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Filters and sort',
        suffixIcon: Icon(Icons.tune),
      ),
      child: Text(
        '${request.archive.name} · ${request.publication.name} · ${request.sort.name}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

PopupMenuItem<_ExerciseFilterAction> _filterItem(
  _ExerciseFilterAction value,
  String label,
  bool selected,
) => PopupMenuItem<_ExerciseFilterAction>(
  value: value,
  child: Row(
    children: <Widget>[
      Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 20),
      const SizedBox(width: StoneSetSpacing.xs),
      Expanded(child: Text(label)),
    ],
  ),
);

class _PublicationFilter extends StatelessWidget {
  const _PublicationFilter({required this.value, required this.onChanged});

  final ExercisePublicationFilter value;
  final ValueChanged<ExercisePublicationFilter> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButton<ExercisePublicationFilter>(
    key: const Key('exercise-publication-filter'),
    isExpanded: true,
    value: value,
    onChanged: (next) {
      if (next != null) onChanged(next);
    },
    items: const <DropdownMenuItem<ExercisePublicationFilter>>[
      DropdownMenuItem(value: ExercisePublicationFilter.all, child: Text('All guidance')),
      DropdownMenuItem(value: ExercisePublicationFilter.draftOnly, child: Text('Draft only')),
      DropdownMenuItem(value: ExercisePublicationFilter.published, child: Text('Published')),
    ],
  );
}

class _SortFilter extends StatelessWidget {
  const _SortFilter({required this.value, required this.onChanged});

  final ExerciseLibrarySort value;
  final ValueChanged<ExerciseLibrarySort> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButton<ExerciseLibrarySort>(
    key: const Key('exercise-sort-filter'),
    isExpanded: true,
    value: value,
    onChanged: (next) {
      if (next != null) onChanged(next);
    },
    items: const <DropdownMenuItem<ExerciseLibrarySort>>[
      DropdownMenuItem(
        value: ExerciseLibrarySort.updatedDescending,
        child: Text('Recently updated'),
      ),
      DropdownMenuItem(value: ExerciseLibrarySort.nameAscending, child: Text('Name A–Z')),
      DropdownMenuItem(value: ExerciseLibrarySort.nameDescending, child: Text('Name Z–A')),
    ],
  );
}

String _exerciseLocation({
  String? exerciseId,
  required DashboardExerciseLibraryRequest request,
  String? mode,
}) {
  final query = <String, String>{
    if (request.search?.isNotEmpty ?? false) 'q': request.search!,
    if (request.archive != ExerciseArchiveFilter.active) 'archive': request.archive.name,
    if (request.publication != ExercisePublicationFilter.all)
      'publication': request.publication.name,
    'equipment': ?request.equipmentKey,
    'muscle': ?request.muscleKey,
    if (request.sort != ExerciseLibrarySort.updatedDescending) 'sort': request.sort.name,
    if (request.page != 1) 'page': request.page.toString(),
    'mode': ?mode,
  };
  return Uri(
    path: exerciseId == null ? '/exercises' : '/exercises/$exerciseId',
    queryParameters: query,
  ).toString();
}

String _safeError(Object error) => error is ExerciseGuidanceFailure
    ? switch (error.code) {
        ExerciseGuidanceErrorCode.networkUnavailable => 'offline',
        ExerciseGuidanceErrorCode.forbidden => 'permission denied',
        ExerciseGuidanceErrorCode.notFound => 'not found',
        _ => 'safe service error',
      }
    : 'safe service error';
