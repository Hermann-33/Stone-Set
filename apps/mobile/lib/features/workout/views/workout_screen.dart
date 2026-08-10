import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/workouts.dart';

import '../../identity/controllers/mobile_session_controller.dart';
import '../data/workout_local_store.dart';
import '../guidance/workout_guidance_sheet.dart';
import '../providers/workout_providers.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({required this.planItemId, super.key});

  final String planItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(workoutDraftProvider(planItemId));
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: draft.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _WorkoutLoadError(
            message: _errorMessage(error),
            onRetry: () => ref.invalidate(workoutDraftProvider(planItemId)),
          ),
          data: (value) => _WorkoutLoggerBody(
            key: ValueKey<String>(value.session.id),
            initialDraft: value,
          ),
        ),
      ),
    );
  }
}

class _WorkoutLoggerBody extends ConsumerStatefulWidget {
  const _WorkoutLoggerBody({required this.initialDraft, super.key});

  final LocalWorkoutDraft initialDraft;

  @override
  ConsumerState<_WorkoutLoggerBody> createState() => _WorkoutLoggerBodyState();
}

class _WorkoutLoggerBodyState extends ConsumerState<_WorkoutLoggerBody> {
  late LocalWorkoutDraft _draft;
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _syncing = false;
  bool _submitting = false;
  WorkoutResult? _result;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialDraft;
    _refreshTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_result case final result?) {
      return _WorkoutResultView(result: result);
    }

    final session = _draft.session;
    return ListView(
      key: const PageStorageKey<String>('workout-logger-scroll'),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Workout',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Chip(
              key: const Key('workout-sync-status'),
              label: Text(_draft.pendingSync ? 'Pending sync' : 'Synced'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${session.completedSetCount}/${session.plannedSetCount} sets completed',
        ),
        if (_remaining > Duration.zero) ...<Widget>[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('workout-rest-timer'),
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Rest timer'),
              trailing: Text(_durationLabel(_remaining)),
            ),
          ),
        ],
        const SizedBox(height: 16),
        for (final exercise in session.exercises) ...<Widget>[
          _ExerciseCard(
            exercise: exercise,
            sets: _draft.sets
                .where((set) => set.sessionExerciseId == exercise.id)
                .toList(growable: false),
            onSetChanged: (set) => _saveSet(exercise, set),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('workout-sync-button'),
          onPressed: _syncing ? null : _sync,
          icon: const Icon(Icons.sync),
          label: Text(_syncing ? 'Syncing…' : 'Sync'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          key: const Key('workout-finish-button'),
          onPressed: _submitting || _draft.sets.every((set) => !set.completed) ? null : _submit,
          icon: const Icon(Icons.check_circle_outline),
          label: Text(_submitting ? 'Finishing…' : 'Finish workout'),
        ),
      ],
    );
  }

  Future<void> _saveSet(
    WorkoutExercise exercise,
    WorkoutSetDraft next,
  ) async {
    final userId = ref.read(mobileSessionControllerProvider).value?.userId;
    if (userId == null) return;
    final restEndAt = next.completed
        ? DateTime.now().toUtc().add(Duration(seconds: exercise.restSeconds))
        : null;
    try {
      final saved = await ref
          .read(workoutControllerProvider)
          .saveSet(
            userId: userId,
            set: next,
            restEndAt: restEndAt,
          );
      if (!mounted || saved.clientRevision < _draft.clientRevision) return;
      setState(() => _draft = saved);
      if (next.completed) _refreshTimer();
    } on Object catch (error) {
      if (!mounted) return;
      _snack(_errorMessage(error));
    }
  }

  Future<void> _sync() async {
    final userId = ref.read(mobileSessionControllerProvider).value?.userId;
    if (userId == null) return;
    setState(() => _syncing = true);
    try {
      final synced = await ref.read(workoutControllerProvider).sync(userId: userId);
      if (!mounted) return;
      setState(() => _draft = synced);
      _snack('Workout synced.');
    } on Object catch (error) {
      if (!mounted) return;
      _snack('${_errorMessage(error)} Local changes are still saved.');
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _submit() async {
    final userId = ref.read(mobileSessionControllerProvider).value?.userId;
    if (userId == null) return;
    setState(() => _submitting = true);
    try {
      final submitted = await ref.read(workoutControllerProvider).submit(userId: userId);
      if (!mounted) return;
      setState(() => _result = submitted.result);
    } on Object catch (error) {
      if (!mounted) return;
      _snack('${_errorMessage(error)} Local changes are still saved.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _refreshTimer() {
    _timer?.cancel();
    void update() {
      final end = _draft.restEndAt;
      final remaining = end == null ? Duration.zero : end.difference(DateTime.now().toUtc());
      if (!mounted) return;
      setState(() => _remaining = remaining.isNegative ? Duration.zero : remaining);
      if (_remaining == Duration.zero) _timer?.cancel();
    }

    final end = _draft.restEndAt;
    if (end == null || !end.isAfter(DateTime.now().toUtc())) {
      _remaining = Duration.zero;
      return;
    }
    _remaining = end.difference(DateTime.now().toUtc());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => update());
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.sets,
    required this.onSetChanged,
  });

  final WorkoutExercise exercise;
  final List<WorkoutSetDraft> sets;
  final ValueChanged<WorkoutSetDraft> onSetChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    exercise.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  key: Key('workout-guidance-${exercise.id}'),
                  onPressed: () => showWorkoutGuidanceSheet(context, exercise),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Guidance'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${exercise.workingSets} × ${exercise.repMin}-${exercise.repMax} reps · RIR ${exercise.rirTarget} · ${exercise.restSeconds}s rest',
            ),
            if (exercise.notes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(exercise.notes),
            ],
            const SizedBox(height: 12),
            for (final set in sets) ...<Widget>[
              _SetRow(
                key: ValueKey<String>('${set.sessionExerciseId}-${set.setIndex}'),
                set: set,
                onChanged: onSetChanged,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.set, required this.onChanged, super.key});

  final WorkoutSetDraft set;
  final ValueChanged<WorkoutSetDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(width: 30, child: Text('${set.setIndex}')),
        Expanded(
          child: TextFormField(
            key: Key('workout-load-${set.sessionExerciseId}-${set.setIndex}'),
            initialValue: set.loadValue?.toString() ?? '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Load ${set.loadUnit}'),
            onChanged: (value) => onChanged(
              set.copyWith(
                loadValue: double.tryParse(value),
                clearLoadValue: value.trim().isEmpty,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            key: Key('workout-reps-${set.sessionExerciseId}-${set.setIndex}'),
            initialValue: set.repetitions?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Reps'),
            onChanged: (value) => onChanged(
              set.copyWith(
                repetitions: int.tryParse(value),
                clearRepetitions: value.trim().isEmpty,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 76,
          child: TextFormField(
            key: Key('workout-rir-${set.sessionExerciseId}-${set.setIndex}'),
            initialValue: set.rir?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'RIR'),
            onChanged: (value) => onChanged(
              set.copyWith(
                rir: int.tryParse(value),
                clearRir: value.trim().isEmpty,
              ),
            ),
          ),
        ),
        Checkbox(
          key: Key('workout-complete-${set.sessionExerciseId}-${set.setIndex}'),
          value: set.completed,
          onChanged: (value) => onChanged(
            set.copyWith(completed: value ?? false),
          ),
        ),
      ],
    );
  }
}

class _WorkoutResultView extends StatelessWidget {
  const _WorkoutResultView({required this.result});

  final WorkoutResult result;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.check_circle, size: 48),
              const SizedBox(height: 12),
              Text(
                result.status == WorkoutResultStatus.completed
                    ? 'Workout completed'
                    : 'Workout submitted as partial',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('${result.completedSets}/${result.plannedSets} sets completed'),
            ],
          ),
        ),
      ),
    ),
  );
}

class _WorkoutLoadError extends StatelessWidget {
  const _WorkoutLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

String _durationLabel(Duration value) {
  final seconds = value.inSeconds.clamp(0, 3599);
  final minutesPart = seconds ~/ 60;
  final secondsPart = seconds % 60;
  return '$minutesPart:${secondsPart.toString().padLeft(2, '0')}';
}

String _errorMessage(Object error) {
  if (error is WorkoutFailure) {
    return switch (error.code) {
      'workout_not_today' => 'Only today’s workout can be started.',
      'workout_item_is_rest' => 'Rest days do not start workouts.',
      'another_workout_is_active' => 'Finish the active workout first.',
      'workout_no_completed_sets' => 'Complete at least one set before finishing.',
      _ => 'Workout could not be updated.',
    };
  }
  return 'Workout could not be updated.';
}
