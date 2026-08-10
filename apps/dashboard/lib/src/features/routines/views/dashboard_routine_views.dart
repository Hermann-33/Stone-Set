import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_domain/routines.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../exercises/controllers/dashboard_exercise_controllers.dart';
import '../controllers/dashboard_routine_controllers.dart';

class DashboardRoutineLibraryView extends ConsumerStatefulWidget {
  const DashboardRoutineLibraryView({super.key});

  @override
  ConsumerState<DashboardRoutineLibraryView> createState() =>
      _DashboardRoutineLibraryViewState();
}

class _DashboardRoutineLibraryViewState
    extends ConsumerState<DashboardRoutineLibraryView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routines = ref.watch(dashboardRoutineLibraryControllerProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(StoneSetSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StoneSetResponsiveToolbar(
              title: 'Routines',
              supportingText:
                  'Build a seven-day plan and publish it immediately after validation.',
              actions: <StoneSetDashboardAction>[
                StoneSetDashboardAction(
                  id: 'new-routine',
                  label: 'New routine',
                  icon: Icons.add,
                  onPressed: () => context.go('/routines/new'),
                ),
              ],
            ),
            const SizedBox(height: StoneSetSpacing.lg),
            StoneSetFilterHeader(
              searchController: _searchController,
              searchLabel: 'Search routines',
              onSearchChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
            const SizedBox(height: StoneSetSpacing.md),
            Expanded(
              child: routines.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => StoneSetDashboardStatePanel(
                  state: StoneSetDashboardPanelState.error,
                  title: 'Routines unavailable',
                  message: 'The routine library could not be loaded.',
                  actionLabel: 'Retry',
                  onAction: () =>
                      ref.invalidate(dashboardRoutineLibraryControllerProvider),
                ),
                data: (items) {
                  final visible = items
                      .where((item) => item.name.toLowerCase().contains(_query))
                      .toList(growable: false);
                  if (visible.isEmpty) {
                    return StoneSetDashboardStatePanel(
                      state: StoneSetDashboardPanelState.empty,
                      title: _query.isEmpty
                          ? 'No routines yet'
                          : 'No matching routines',
                      message: _query.isEmpty
                          ? 'Create a seven-day routine to begin.'
                          : 'Try another search term.',
                    );
                  }
                  return ListView.separated(
                    key: const Key('routine-library-list'),
                    itemCount: visible.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: StoneSetSpacing.sm),
                    itemBuilder: (context, index) {
                      final routine = visible[index];
                      return StoneSetCard(
                        key: Key('routine-${routine.id}'),
                        onTap: () => context.go('/routines/${routine.id}'),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.view_week_outlined),
                            const SizedBox(width: StoneSetSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    routine.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text('Revision ${routine.revision}'),
                                ],
                              ),
                            ),
                            StoneSetStatusChip(
                              kind: _statusKind(routine.status),
                              label: _statusLabel(routine.status),
                            ),
                            if (routine.latestVersionNumber != null) ...<Widget>[
                              const SizedBox(width: StoneSetSpacing.sm),
                              Text('v${routine.latestVersionNumber}'),
                            ],
                            if (routine.status == RoutineDraftStatus.draft ||
                                routine.status == RoutineDraftStatus.rejected)
                              IconButton(
                                key: Key('archive-routine-${routine.id}'),
                                tooltip: 'Archive ${routine.name}',
                                onPressed: () =>
                                    _confirmArchive(context, ref, routine),
                                icon: const Icon(Icons.archive_outlined),
                              ),
                            const SizedBox(width: StoneSetSpacing.xs),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmArchive(
    BuildContext context,
    WidgetRef ref,
    RoutineSummary routine,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive routine draft?'),
        content: Text('${routine.name} will leave the active routine library.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm-archive-routine'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(dashboardRoutineLibraryControllerProvider.notifier)
          .archive(routine);
    }
  }
}

class DashboardRoutineEditorView extends ConsumerWidget {
  const DashboardRoutineEditorView({this.routineId, super.key});

  final String? routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = DashboardRoutineEditorRequest(routineId: routineId);
    final editor = ref.watch(dashboardRoutineEditorControllerProvider(request));
    final exercises = ref.watch(dashboardGlobalExerciseSearchProvider);
    return editor.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.error,
        title: 'Routine unavailable',
        message: 'The routine could not be loaded.',
        actionLabel: 'Retry',
        onAction: () =>
            ref.invalidate(dashboardRoutineEditorControllerProvider(request)),
      ),
      data: (state) => _RoutineEditorBody(
        state: state,
        controller:
            ref.read(dashboardRoutineEditorControllerProvider(request).notifier),
        exercises: exercises.value ?? const <ExerciseLibraryItem>[],
        onSaved: (draft) {
          ref.invalidate(dashboardRoutineLibraryControllerProvider);
          if (routineId == null && context.mounted) {
            context.go('/routines/${draft.id}');
          }
        },
      ),
    );
  }
}

class _RoutineEditorBody extends StatelessWidget {
  const _RoutineEditorBody({
    required this.state,
    required this.controller,
    required this.exercises,
    required this.onSaved,
  });

  final DashboardRoutineEditorState state;
  final DashboardRoutineEditorController controller;
  final List<ExerciseLibraryItem> exercises;
  final ValueChanged<RoutineDraft> onSaved;

  @override
  Widget build(BuildContext context) {
    final editable = state.draft.status == RoutineDraftStatus.draft;
    final busy = <DashboardRoutineActionState>{
      DashboardRoutineActionState.saving,
      DashboardRoutineActionState.validating,
      DashboardRoutineActionState.publishing,
    }.contains(state.action);
    final workoutDays = state.draft.days
        .where((day) => day.kind == RoutineDayKind.workout)
        .length;
    final totalSets = state.draft.days
        .expand((day) => day.prescriptions)
        .fold<int>(0, (sum, prescription) => sum + prescription.sets);

    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('routine-editor'),
        padding: const EdgeInsets.all(StoneSetSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                StoneSetResponsiveToolbar(
                  title: state.draft.name,
                  supportingText:
                      'Seven days · $workoutDays workout days · $totalSets working sets',
                  actions: <StoneSetDashboardAction>[
                    StoneSetDashboardAction(
                      id: 'save-routine',
                      label: 'Save',
                      icon: Icons.save_outlined,
                      enabled: editable && !busy,
                      onPressed: () async {
                        final saved = await controller.save();
                        if (saved != null) onSaved(saved);
                      },
                    ),
                    StoneSetDashboardAction(
                      id: 'validate-routine',
                      label: 'Validate',
                      icon: Icons.rule,
                      enabled: editable && !busy,
                      onPressed: controller.validate,
                    ),
                    StoneSetDashboardAction(
                      id: 'publish-routine',
                      label: 'Publish',
                      icon: Icons.publish,
                      enabled: editable && !busy,
                      onPressed: controller.publish,
                    ),
                  ],
                ),
                const SizedBox(height: StoneSetSpacing.md),
                if (state.message != null)
                  StoneSetStatusBanner(
                    kind:
                        state.action == DashboardRoutineActionState.failed ||
                            state.action == DashboardRoutineActionState.stale
                        ? StoneSetStatusKind.error
                        : StoneSetStatusKind.information,
                    message: state.message!,
                  ),
                if (state.message != null)
                  const SizedBox(height: StoneSetSpacing.md),
                if (state.validation != null)
                  _RoutineValidationSummary(validation: state.validation!),
                if (state.validation != null)
                  const SizedBox(height: StoneSetSpacing.md),
                StoneSetCard(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        key: Key('routine-name-${state.draft.revision}'),
                        initialValue: state.draft.name,
                        enabled: editable && !busy,
                        onChanged: controller.updateName,
                        decoration:
                            const InputDecoration(labelText: 'Routine name'),
                      ),
                      const SizedBox(height: StoneSetSpacing.sm),
                      TextFormField(
                        key: Key('routine-description-${state.draft.revision}'),
                        initialValue: state.draft.description,
                        enabled: editable && !busy,
                        onChanged: controller.updateDescription,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText:
                              'What this training week is designed to achieve',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: StoneSetSpacing.md),
                if (state.draft.days.length != 7)
                  const StoneSetStatusBanner(
                    kind: StoneSetStatusKind.error,
                    message: 'A routine must contain exactly seven day slots.',
                  ),
                for (final day in state.draft.days) ...<Widget>[
                  _RoutineDayEditor(
                    key: Key('routine-day-${day.dayIndex}'),
                    day: day,
                    enabled: editable && !busy,
                    exercises: exercises,
                    controller: controller,
                  ),
                  const SizedBox(height: StoneSetSpacing.sm),
                ],
                _RoutineVersionHistory(routineId: state.draft.id),
                const SizedBox(height: StoneSetSpacing.md),
                if (!editable)
                  const StoneSetDashboardStatePanel(
                    state: StoneSetDashboardPanelState.readOnly,
                    title: 'Published routine is read only',
                    message:
                        'Duplicate a published version to create another editable draft.',
                  ),
                const SizedBox(height: StoneSetSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoutineVersionHistory extends ConsumerWidget {
  const _RoutineVersionHistory({required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versions = ref.watch(dashboardRoutineVersionsProvider(routineId));
    return StoneSetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Version history', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: StoneSetSpacing.sm),
          versions.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) =>
                const Text('Version history could not be loaded.'),
            data: (items) => items.isEmpty
                ? const Text('No published versions yet.')
                : Column(
                    children: <Widget>[
                      for (final version in items)
                        ListTile(
                          key: Key('routine-version-${version.id}'),
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history),
                          title: Text('Version ${version.versionNumber}'),
                          subtitle:
                              Text('Published ${version.publishedAt.toLocal()}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go(
                            '/routines/$routineId/versions/${version.id}',
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _RoutineDayEditor extends StatelessWidget {
  const _RoutineDayEditor({
    required this.day,
    required this.enabled,
    required this.exercises,
    required this.controller,
    super.key,
  });

  final RoutineDay day;
  final bool enabled;
  final List<ExerciseLibraryItem> exercises;
  final DashboardRoutineEditorController controller;

  @override
  Widget build(BuildContext context) {
    final eligibleExercises = exercises
        .where(
          (exercise) =>
              exercise.published && exercise.latestGuidanceRevisionId != null,
        )
        .toList(growable: false);
    final sets =
        day.prescriptions.fold<int>(0, (sum, item) => sum + item.sets);
    final estimatedMinutes = day.kind == RoutineDayKind.rest
        ? 0
        : ((480 +
                      sets * 45 +
                      day.prescriptions.fold<int>(
                        0,
                        (sum, item) => sum + item.restSeconds,
                      )) /
                  60)
              .round();

    return StoneSetCard(
      child: ExpansionTile(
        initiallyExpanded: day.dayIndex == 1,
        tilePadding: EdgeInsets.zero,
        title: Text('Day ${day.dayIndex}: ${day.title}'),
        subtitle: Text(
          day.kind == RoutineDayKind.rest
              ? 'Rest day'
              : '${day.prescriptions.length} prescriptions · $sets sets · ~$estimatedMinutes min',
        ),
        children: <Widget>[
          SegmentedButton<RoutineDayKind>(
            segments: const <ButtonSegment<RoutineDayKind>>[
              ButtonSegment<RoutineDayKind>(
                value: RoutineDayKind.workout,
                label: Text('Workout'),
                icon: Icon(Icons.fitness_center),
              ),
              ButtonSegment<RoutineDayKind>(
                value: RoutineDayKind.rest,
                label: Text('Rest'),
                icon: Icon(Icons.hotel_outlined),
              ),
            ],
            selected: <RoutineDayKind>{day.kind},
            onSelectionChanged: enabled
                ? (selection) =>
                    controller.updateDayKind(day.dayIndex, selection.single)
                : null,
          ),
          const SizedBox(height: StoneSetSpacing.sm),
          TextFormField(
            initialValue: day.title,
            enabled: enabled,
            onChanged: (value) =>
                controller.updateDayTitle(day.dayIndex, value),
            decoration: const InputDecoration(labelText: 'Day title'),
          ),
          const SizedBox(height: StoneSetSpacing.sm),
          TextFormField(
            initialValue: day.purpose,
            enabled: enabled,
            onChanged: (value) =>
                controller.updateDayPurpose(day.dayIndex, value),
            decoration: const InputDecoration(labelText: 'Purpose'),
          ),
          if (day.kind == RoutineDayKind.workout) ...<Widget>[
            const SizedBox(height: StoneSetSpacing.md),
            for (var index = 0;
                index < day.prescriptions.length;
                index++) ...<Widget>[
              _PrescriptionEditor(
                key: Key('day-${day.dayIndex}-prescription-$index'),
                dayIndex: day.dayIndex,
                index: index,
                prescription: day.prescriptions[index],
                exercises: eligibleExercises,
                enabled: enabled,
                controller: controller,
              ),
              const SizedBox(height: StoneSetSpacing.sm),
            ],
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: StoneSetButton(
                key: Key('day-${day.dayIndex}-add-prescription'),
                label: eligibleExercises.isEmpty
                    ? 'Publish exercise guidance first'
                    : 'Add exercise',
                icon: Icons.add,
                kind: StoneSetButtonKind.secondary,
                onPressed: enabled && eligibleExercises.isNotEmpty
                    ? () {
                        final exercise = eligibleExercises.first;
                        controller.addPrescription(
                          dayIndex: day.dayIndex,
                          exerciseId: exercise.id,
                          guidanceRevisionId:
                              exercise.latestGuidanceRevisionId!,
                        );
                      }
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrescriptionEditor extends StatelessWidget {
  const _PrescriptionEditor({
    required this.dayIndex,
    required this.index,
    required this.prescription,
    required this.exercises,
    required this.enabled,
    required this.controller,
    super.key,
  });

  final int dayIndex;
  final int index;
  final RoutinePrescription prescription;
  final List<ExerciseLibraryItem> exercises;
  final bool enabled;
  final DashboardRoutineEditorController controller;

  @override
  Widget build(BuildContext context) {
    final knownExercise =
        exercises.any((exercise) => exercise.id == prescription.exerciseId);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: StoneSetSemanticColors.of(context).outline),
        borderRadius: BorderRadius.circular(StoneSetShapes.controlRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(StoneSetSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue:
                        knownExercise ? prescription.exerciseId : null,
                    decoration: const InputDecoration(labelText: 'Exercise'),
                    items: <DropdownMenuItem<String>>[
                      for (final exercise in exercises)
                        DropdownMenuItem<String>(
                          value: exercise.id,
                          child: Text(exercise.canonicalName),
                        ),
                    ],
                    onChanged: enabled
                        ? (exerciseId) {
                            if (exerciseId == null) return;
                            final exercise = exercises.firstWhere(
                              (item) => item.id == exerciseId,
                            );
                            controller.updatePrescription(
                              dayIndex,
                              index,
                              exerciseId: exerciseId,
                              guidanceRevisionId:
                                  exercise.latestGuidanceRevisionId!,
                            );
                          }
                        : null,
                  ),
                ),
                IconButton(
                  tooltip: 'Move exercise up',
                  onPressed: enabled && index > 0
                      ? () => controller.movePrescription(
                            dayIndex,
                            index,
                            index - 1,
                          )
                      : null,
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  tooltip: 'Move exercise down',
                  onPressed: enabled
                      ? () => controller.movePrescription(
                            dayIndex,
                            index,
                            index + 1,
                          )
                      : null,
                  icon: const Icon(Icons.arrow_downward),
                ),
                IconButton(
                  tooltip: 'Remove exercise',
                  onPressed: enabled
                      ? () => controller.removePrescription(dayIndex, index)
                      : null,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            Text(
              'Published guidance ${prescription.guidanceRevisionId}',
              style: StoneSetTextStyles.of(context).caption,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: StoneSetSpacing.sm),
            Wrap(
              spacing: StoneSetSpacing.sm,
              runSpacing: StoneSetSpacing.sm,
              children: <Widget>[
                _NumberField(
                  label: 'Sets',
                  value: prescription.sets,
                  enabled: enabled,
                  onChanged: (value) => controller.updatePrescription(
                    dayIndex,
                    index,
                    sets: value,
                  ),
                ),
                _NumberField(
                  label: 'Min reps',
                  value: prescription.minReps,
                  enabled: enabled,
                  onChanged: (value) => controller.updatePrescription(
                    dayIndex,
                    index,
                    minReps: value,
                  ),
                ),
                _NumberField(
                  label: 'Max reps',
                  value: prescription.maxReps,
                  enabled: enabled,
                  onChanged: (value) => controller.updatePrescription(
                    dayIndex,
                    index,
                    maxReps: value,
                  ),
                ),
                _NumberField(
                  label: 'RIR',
                  value: prescription.rir,
                  enabled: enabled,
                  onChanged: (value) => controller.updatePrescription(
                    dayIndex,
                    index,
                    rir: value,
                  ),
                ),
                _NumberField(
                  label: 'Rest seconds',
                  value: prescription.restSeconds,
                  enabled: enabled,
                  width: 140,
                  onChanged: (value) => controller.updatePrescription(
                    dayIndex,
                    index,
                    restSeconds: value,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String?>(
                    isExpanded: true,
                    initialValue: prescription.loadUnit,
                    decoration: const InputDecoration(labelText: 'Load unit'),
                    items: const <DropdownMenuItem<String?>>[
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('None'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'kg',
                        child: Text('kg'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'lb',
                        child: Text('lb'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'bodyweight',
                        child: Text('Bodyweight'),
                      ),
                    ],
                    onChanged: enabled
                        ? (value) => controller.updatePrescription(
                            dayIndex,
                            index,
                            loadUnit: value,
                            replaceLoadUnit: true,
                          )
                        : null,
                  ),
                ),
                FilterChip(
                  label: const Text('Priority'),
                  selected: prescription.priority,
                  onSelected: enabled
                      ? (value) => controller.updatePrescription(
                            dayIndex,
                            index,
                            priority: value,
                          )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: StoneSetSpacing.sm),
            TextFormField(
              initialValue: prescription.notes,
              enabled: enabled,
              onChanged: (value) => controller.updatePrescription(
                dayIndex,
                index,
                notes: value.trim().isEmpty ? null : value,
                replaceNotes: true,
              ),
              decoration:
                  const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.width = 105,
  });

  final String label;
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: TextFormField(
          initialValue: '$value',
          enabled: enabled,
          keyboardType: TextInputType.number,
          onChanged: (text) {
            final parsed = int.tryParse(text);
            if (parsed != null) onChanged(parsed);
          },
          decoration: InputDecoration(labelText: label),
        ),
      );
}

class _RoutineValidationSummary extends StatelessWidget {
  const _RoutineValidationSummary({required this.validation});

  final RoutineValidationResult validation;

  @override
  Widget build(BuildContext context) {
    if (validation.isValid) {
      return const StoneSetStatusBanner(
        kind: StoneSetStatusKind.success,
        message: 'Routine passes routine-validator-v1 and is ready to publish.',
      );
    }
    return StoneSetValidationSummary(
      title: 'Routine validation',
      issues: <StoneSetValidationIssue>[
        for (final issue in validation.issues)
          StoneSetValidationIssue(
            id: '${issue.code}-${issue.path}',
            message: '${_humanize(issue.code)} · ${issue.path}',
          ),
      ],
      onIssueSelected: (_) {},
    );
  }
}

/// Legacy generated route retained temporarily so old deep links fail closed
/// instead of breaking route generation. Routine review is no longer a feature.
class DashboardReviewQueueView extends StatelessWidget {
  const DashboardReviewQueueView({super.key});

  @override
  Widget build(BuildContext context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(StoneSetSpacing.xl),
          child: StoneSetDashboardStatePanel(
            state: StoneSetDashboardPanelState.empty,
            title: 'Routine reviews removed',
            message:
                'Routine owners now validate and publish their own routines directly.',
          ),
        ),
      );
}

/// Legacy generated route retained temporarily. There is no approval action.
class DashboardRoutineReviewView extends StatelessWidget {
  const DashboardRoutineReviewView({required this.submissionId, super.key});

  final String submissionId;

  @override
  Widget build(BuildContext context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(StoneSetSpacing.xl),
          child: StoneSetDashboardStatePanel(
            state: StoneSetDashboardPanelState.empty,
            title: 'Routine review removed',
            message:
                'This workflow no longer exists. Publish routines directly from Routines.',
          ),
        ),
      );
}

class DashboardRoutineVersionView extends ConsumerWidget {
  const DashboardRoutineVersionView({
    required this.routineId,
    required this.versionId,
    super.key,
  });

  final String routineId;
  final String versionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(
      dashboardRoutineVersionProvider(
        (routineId: routineId, versionId: versionId),
      ),
    );
    return version.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.error,
        title: 'Version unavailable',
        message: 'This published routine version could not be loaded.',
      ),
      data: (item) => SafeArea(
        child: SingleChildScrollView(
          key: const Key('routine-version-detail'),
          padding: const EdgeInsets.all(StoneSetSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  StoneSetResponsiveToolbar(
                    title: '${item.name} · version ${item.versionNumber}',
                    supportingText:
                        'Published ${item.publishedAt.toLocal()} · immutable',
                    actions: <StoneSetDashboardAction>[
                      StoneSetDashboardAction(
                        id: 'duplicate-version',
                        label: 'Duplicate as draft',
                        icon: Icons.copy,
                        onPressed: () async {
                          final draft = await duplicateRoutineVersion(
                            ref,
                            routineId: routineId,
                            versionId: versionId,
                            name: '${item.name} copy',
                          );
                          if (context.mounted) {
                            context.go('/routines/${draft.id}');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: StoneSetSpacing.md),
                  StoneSetStatusBanner(
                    kind: StoneSetStatusKind.success,
                    message: 'Content hash ${item.contentHash}',
                  ),
                  const SizedBox(height: StoneSetSpacing.md),
                  _RoutineSnapshot(
                    days: item.days,
                    validationIssues: const <RoutineValidationIssue>[],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoutineSnapshot extends StatelessWidget {
  const _RoutineSnapshot({
    required this.days,
    required this.validationIssues,
    this.description,
  });

  final String? description;
  final List<RoutineDay> days;
  final List<RoutineValidationIssue> validationIssues;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (description != null && description!.isNotEmpty) ...<Widget>[
            Text(description!),
            const SizedBox(height: StoneSetSpacing.md),
          ],
          if (validationIssues.isNotEmpty)
            _RoutineValidationSummary(
              validation: RoutineValidationResult(validationIssues),
            )
          else
            const StoneSetStatusBanner(
              kind: StoneSetStatusKind.success,
              message: 'Published routine snapshot passed routine-validator-v1.',
            ),
          const SizedBox(height: StoneSetSpacing.md),
          for (final day in days) ...<Widget>[
            StoneSetCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Day ${day.dayIndex}: ${day.title}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      StoneSetStatusChip(
                        kind: day.kind == RoutineDayKind.workout
                            ? StoneSetStatusKind.information
                            : StoneSetStatusKind.success,
                        label: day.kind == RoutineDayKind.workout
                            ? 'Workout'
                            : 'Rest',
                      ),
                    ],
                  ),
                  if (day.purpose != null) Text(day.purpose!),
                  for (final prescription in day.prescriptions)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text('${prescription.position}'),
                      title: Text(prescription.exerciseId),
                      subtitle: Text(
                        '${prescription.sets} × ${prescription.minReps}–${prescription.maxReps} · '
                        'RIR ${prescription.rir} · ${prescription.restSeconds}s rest',
                      ),
                      trailing: prescription.priority
                          ? const Tooltip(
                              message: 'Priority exercise',
                              child: Icon(Icons.star),
                            )
                          : null,
                    ),
                ],
              ),
            ),
            const SizedBox(height: StoneSetSpacing.sm),
          ],
        ],
      );
}

StoneSetStatusKind _statusKind(RoutineDraftStatus status) => switch (status) {
      RoutineDraftStatus.draft => StoneSetStatusKind.information,
      RoutineDraftStatus.submitted => StoneSetStatusKind.pending,
      RoutineDraftStatus.approved || RoutineDraftStatus.published =>
        StoneSetStatusKind.success,
      RoutineDraftStatus.rejected => StoneSetStatusKind.error,
      RoutineDraftStatus.archived => StoneSetStatusKind.stale,
    };

String _statusLabel(RoutineDraftStatus status) => switch (status) {
      RoutineDraftStatus.draft => 'Draft',
      RoutineDraftStatus.submitted => 'Legacy submitted',
      RoutineDraftStatus.approved => 'Legacy approved',
      RoutineDraftStatus.rejected => 'Legacy rejected',
      RoutineDraftStatus.published => 'Published',
      RoutineDraftStatus.archived => 'Archived',
    };

String _humanize(String code) => code.replaceAll('_', ' ');
