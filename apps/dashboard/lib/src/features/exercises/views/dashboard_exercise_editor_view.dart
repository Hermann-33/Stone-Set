import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../../session/dashboard_session_controller.dart';
import '../controllers/dashboard_exercise_controllers.dart';
import 'dashboard_exercise_library_view.dart';

class DashboardExerciseEditorView extends ConsumerWidget {
  const DashboardExerciseEditorView({this.exerciseId, this.embedded = false, super.key});

  final String? exerciseId;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(dashboardSessionControllerProvider);
    final userId = session.userId;
    if (userId == null) {
      return const DashboardExerciseErrorPanel(
        error: ExerciseGuidanceFailure(ExerciseGuidanceErrorCode.sessionExpired),
      );
    }
    final request = DashboardExerciseEditorRequest(userId: userId, exerciseId: exerciseId);
    final editor = ref.watch(dashboardExerciseEditorControllerProvider(request));
    final body = editor.when(
      loading: () => const StoneSetDashboardStatePanel(
        state: StoneSetDashboardPanelState.loading,
        title: 'Preparing exercise editor',
        message: 'Loading the fixed muscle taxonomy and owner-scoped definition.',
      ),
      error: (error, _) => DashboardExerciseErrorPanel(
        error: error,
        onRetry: () => ref.invalidate(dashboardExerciseEditorControllerProvider(request)),
      ),
      data: (state) => _ExerciseEditorForm(
        request: request,
        state: state,
        readOnly:
            (session.bootstrap?.compatibility.readOnlyMode ?? false) ||
            state.exercise?.hasPublishedGuidance == true,
      ),
    );
    if (embedded) return body;
    return ColoredBox(
      color: StoneSetSemanticColors.of(context).canvas,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(StoneSetSpacing.md),
          child: body,
        ),
      ),
    );
  }
}

class _ExerciseEditorForm extends ConsumerWidget {
  const _ExerciseEditorForm({
    required this.request,
    required this.state,
    required this.readOnly,
  });

  final DashboardExerciseEditorRequest request;
  final DashboardExerciseEditorState state;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dashboardExerciseEditorControllerProvider(request).notifier);
    final issues = state.validation?.issues ?? const <ExerciseGuidanceValidationIssue>[];
    return PopScope<Object?>(
      canPop: !state.dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && state.dirty) unawaited(_requestExit(context));
      },
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StoneSetResponsiveToolbar(
              title: state.exercise == null ? 'Create exercise' : 'Edit exercise identity',
              supportingText: state.exercise?.hasPublishedGuidance != true
                  ? 'Names are owner-scoped. Equipment uses stable lowercase keys.'
                  : 'Published identity is immutable. Clone to make a materially different definition.',
              actions: <StoneSetDashboardAction>[
                StoneSetDashboardAction(
                  id: 'cancel-exercise',
                  label: 'Cancel',
                  icon: Icons.close,
                  onPressed: () => unawaited(_requestExit(context)),
                ),
                StoneSetDashboardAction(
                  id: 'save-exercise',
                  label: state.saveState == DashboardExerciseEditorSaveState.saving
                      ? 'Saving…'
                      : 'Save exercise',
                  icon: Icons.save_outlined,
                  enabled: !readOnly && state.saveState != DashboardExerciseEditorSaveState.saving,
                  onPressed: () => _save(context, ref, controller),
                ),
              ],
            ),
            if (readOnly) ...<Widget>[
              const SizedBox(height: StoneSetSpacing.sm),
              const StoneSetStatusBanner(
                kind: StoneSetStatusKind.warning,
                message:
                    'Read only. Published exercise identity cannot be redefined in this phase.',
              ),
            ],
            if (state.saveState == DashboardExerciseEditorSaveState.saving) ...<Widget>[
              const SizedBox(height: StoneSetSpacing.sm),
              Semantics(
                liveRegion: true,
                child: const StoneSetStatusBanner(
                  kind: StoneSetStatusKind.information,
                  message: 'Saving exercise. Editing is temporarily paused.',
                ),
              ),
            ],
            if (state.message case final message?) ...<Widget>[
              const SizedBox(height: StoneSetSpacing.sm),
              Semantics(
                liveRegion: true,
                child: StoneSetStatusBanner(
                  kind: state.saveState == DashboardExerciseEditorSaveState.saved
                      ? StoneSetStatusKind.success
                      : StoneSetStatusKind.warning,
                  message: message,
                ),
              ),
            ],
            if (state.saveState == DashboardExerciseEditorSaveState.duplicateWarning) ...<Widget>[
              const SizedBox(height: StoneSetSpacing.sm),
              StoneSetConfirmationSurface(
                message:
                    'A normalized duplicate exists. Confirm only when a separate stable identity is intentional.',
                undoLabel: 'Create separately',
                onUndo: () => _save(context, ref, controller, confirmDuplicate: true),
              ),
            ],
            if (issues.isNotEmpty) ...<Widget>[
              const SizedBox(height: StoneSetSpacing.sm),
              StoneSetValidationSummary(
                title: 'Exercise fields need attention',
                issues: <StoneSetValidationIssue>[
                  for (var index = 0; index < issues.length; index += 1)
                    StoneSetValidationIssue(
                      id: '${issues[index].field}-$index',
                      message: issues[index].message,
                    ),
                ],
                onIssueSelected: (id) => _focusIssue(context, id),
              ),
            ],
            const SizedBox(height: StoneSetSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                key: const Key('exercise-editor-scroll'),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        StoneSetCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Semantics(
                                header: true,
                                child: Text(
                                  'Identity',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              const SizedBox(height: StoneSetSpacing.md),
                              TextFormField(
                                key: const Key('exercise-name-field'),
                                initialValue: state.canonicalName,
                                enabled:
                                    !readOnly &&
                                    state.saveState != DashboardExerciseEditorSaveState.saving,
                                onChanged: controller.updateName,
                                maxLength: 120,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Exercise name',
                                  helperText:
                                      'Use the familiar display name. Normalization is server-owned.',
                                ),
                              ),
                              const SizedBox(height: StoneSetSpacing.sm),
                              TextFormField(
                                key: const Key('exercise-variant-field'),
                                initialValue: state.variantKey,
                                enabled:
                                    !readOnly &&
                                    state.saveState != DashboardExerciseEditorSaveState.saving,
                                onChanged: controller.updateVariant,
                                maxLength: 64,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Variant key (optional)',
                                  hintText: 'incline_30_degrees',
                                  helperText: 'Lowercase letters, numbers, and underscores only.',
                                ),
                              ),
                              const SizedBox(height: StoneSetSpacing.sm),
                              TextFormField(
                                key: const Key('exercise-equipment-field'),
                                initialValue: state.equipmentKeys.join(', '),
                                enabled:
                                    !readOnly &&
                                    state.saveState != DashboardExerciseEditorSaveState.saving,
                                onChanged: controller.updateEquipment,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Equipment keys',
                                  hintText: 'dumbbell, adjustable_bench',
                                  helperText:
                                      'Enter 1–10 stable lowercase keys, separated by commas.',
                                ),
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
                                child: Text(
                                  'Muscles',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              const SizedBox(height: StoneSetSpacing.xxs),
                              Text(
                                'Choose at least one primary muscle. A muscle cannot appear in both roles.',
                                style: StoneSetTextStyles.of(context).compactBody,
                              ),
                              const SizedBox(height: StoneSetSpacing.sm),
                              for (final muscle in state.availableMuscles)
                                _MuscleRoleRow(
                                  muscle: muscle,
                                  value: state.primaryMuscleKeys.contains(muscle.key)
                                      ? ExerciseMuscleRole.primary
                                      : state.secondaryMuscleKeys.contains(muscle.key)
                                      ? ExerciseMuscleRole.secondary
                                      : null,
                                  enabled:
                                      !readOnly &&
                                      state.saveState != DashboardExerciseEditorSaveState.saving,
                                  onChanged: (role) => controller.setMuscleRole(muscle, role),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: StoneSetSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestExit(BuildContext context) async {
    if (state.dirty) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard unsaved exercise changes?'),
          content: const Text(
            'Exercise identity changes are not stored in browser recovery. Leave only if you '
            'intend to discard the fields entered on this page.',
          ),
          actions: <Widget>[
            TextButton(
              autofocus: true,
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep editing'),
            ),
            FilledButton(
              key: const Key('discard-exercise-editor'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard changes'),
            ),
          ],
        ),
      );
      if (leave != true) return;
    }
    if (context.mounted) {
      context.go(state.exercise == null ? '/exercises' : '/exercises/${state.exercise!.id}');
    }
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    DashboardExerciseEditorController controller, {
    bool confirmDuplicate = false,
  }) async {
    final exercise = await controller.save(confirmDuplicate: confirmDuplicate);
    if (context.mounted && exercise != null) {
      ref.invalidate(dashboardExerciseLibraryControllerProvider);
      context.go('/exercises/${exercise.id}');
    }
  }

  void _focusIssue(BuildContext context, String id) {
    final key = id.startsWith('canonicalName')
        ? const Key('exercise-name-field')
        : id.startsWith('variantKey')
        ? const Key('exercise-variant-field')
        : id.startsWith('equipment')
        ? const Key('exercise-equipment-field')
        : const Key('exercise-muscle-chest');
    final element = _findElementByKey(context as Element, key);
    if (element != null) {
      unawaited(Scrollable.ensureVisible(element, alignment: 0.2));
      FocusScope.of(element).requestFocus();
    }
  }
}

class _MuscleRoleRow extends StatelessWidget {
  const _MuscleRoleRow({
    required this.muscle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final Muscle muscle;
  final ExerciseMuscleRole? value;
  final bool enabled;
  final ValueChanged<ExerciseMuscleRole?> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${muscle.displayName} muscle role',
    child: Padding(
      padding: const EdgeInsets.only(bottom: StoneSetSpacing.xs),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(muscle.displayName)),
          DropdownButton<ExerciseMuscleRole?>(
            key: Key('exercise-muscle-${muscle.key}'),
            value: value,
            onChanged: enabled ? onChanged : null,
            items: const <DropdownMenuItem<ExerciseMuscleRole?>>[
              DropdownMenuItem<ExerciseMuscleRole?>(value: null, child: Text('Not targeted')),
              DropdownMenuItem<ExerciseMuscleRole?>(
                value: ExerciseMuscleRole.primary,
                child: Text('Primary'),
              ),
              DropdownMenuItem<ExerciseMuscleRole?>(
                value: ExerciseMuscleRole.secondary,
                child: Text('Secondary'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Element? _findElementByKey(Element root, Key key) {
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
