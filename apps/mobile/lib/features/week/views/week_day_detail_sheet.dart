import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/workouts.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../identity/providers/identity_providers.dart';
import '../../workout/guidance/workout_guidance_sheet.dart';

Future<void> showWeekDayDetailSheet(
  BuildContext context, {
  required String planItemId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.92,
      child: WeekDayDetailSheet(planItemId: planItemId),
    ),
  );
}

class WeekDayDetailSheet extends ConsumerStatefulWidget {
  const WeekDayDetailSheet({required this.planItemId, super.key});

  final String planItemId;

  @override
  ConsumerState<WeekDayDetailSheet> createState() => _WeekDayDetailSheetState();
}

class _WeekDayDetailSheetState extends ConsumerState<WeekDayDetailSheet> {
  late Future<_WeekDayDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_WeekDayDetail> _load() async {
    final raw = await ref
        .read(supabaseClientProvider)
        .rpc(
          'get_training_week_item_detail_v1',
          params: <String, Object?>{'p_week_item_id': widget.planItemId},
        );
    if (raw is! Map) {
      throw StateError('week_item_detail_unavailable');
    }
    return _WeekDayDetail.fromJson(Map<String, dynamic>.from(raw));
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_WeekDayDetail>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final detail = snapshot.data;
        if (detail == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: StoneSetStatePanel(
                title: 'Day details unavailable',
                message:
                    'Connect to the internet to load this day’s exercise details and guidance.',
                icon: Icons.event_note_outlined,
                actionLabel: 'Retry',
                onAction: _retry,
              ),
            ),
          );
        }
        return ListView(
          key: Key('week-day-detail-${widget.planItemId}'),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: <Widget>[
            StoneSetPageHeader(
              eyebrow: _weekday(detail.assignedDate),
              title: detail.title.isEmpty ? (detail.isRest ? 'Rest' : 'Workout') : detail.title,
              description: detail.purpose.isEmpty
                  ? _date(detail.assignedDate)
                  : '${_date(detail.assignedDate)} · ${detail.purpose}',
            ),
            const SizedBox(height: 20),
            if (detail.isRest)
              const StoneSetStatePanel(
                title: 'Rest day',
                message: 'There are no prescribed exercises for this day.',
                icon: Icons.self_improvement_outlined,
              )
            else
              for (final exercise in detail.exercises) ...<Widget>[
                StoneSetCard(
                  style: StoneSetCardStyle.base,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              exercise.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (exercise.priority)
                            const StoneSetStatusChip(
                              kind: StoneSetStatusKind.information,
                              label: 'Priority',
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${exercise.workingSets} sets · ${exercise.repMin}–${exercise.repMax} reps · '
                        'RIR ${exercise.rirTarget} · ${exercise.restSeconds}s rest',
                      ),
                      if (exercise.notes.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(exercise.notes),
                      ],
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: Key('week-guidance-${exercise.id}'),
                        onPressed: () => showWorkoutGuidanceSheet(context, exercise),
                        icon: const Icon(Icons.menu_book_outlined),
                        label: const Text('View guidance'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
          ],
        );
      },
    );
  }
}

final class _WeekDayDetail {
  const _WeekDayDetail({
    required this.assignedDate,
    required this.itemType,
    required this.title,
    required this.purpose,
    required this.exercises,
  });

  factory _WeekDayDetail.fromJson(Map<String, dynamic> json) {
    final exerciseRows = json['exercises'];
    return _WeekDayDetail(
      assignedDate: DateTime.parse(json['assigned_date'] as String),
      itemType: json['item_type'] as String? ?? 'rest',
      title: json['title'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      exercises: exerciseRows is List
          ? exerciseRows
                .whereType<Map>()
                .map((row) => _exercise(Map<String, dynamic>.from(row)))
                .toList(growable: false)
          : const <WorkoutExercise>[],
    );
  }

  final DateTime assignedDate;
  final String itemType;
  final String title;
  final String purpose;
  final List<WorkoutExercise> exercises;

  bool get isRest => itemType == 'rest';
}

WorkoutExercise _exercise(Map<String, dynamic> row) {
  return WorkoutExercise(
    id: row['id'] as String,
    position: (row['position'] as num).toInt(),
    exerciseDefinitionId: row['exercise_definition_id'] as String,
    guidanceRevisionId: row['guidance_revision_id'] as String,
    title: row['title'] as String? ?? 'Exercise',
    priority: row['priority'] as bool? ?? false,
    workingSets: (row['working_sets'] as num).toInt(),
    repMin: (row['rep_min'] as num).toInt(),
    repMax: (row['rep_max'] as num).toInt(),
    rirTarget: (row['rir_target'] as num).toInt(),
    restSeconds: (row['rest_seconds'] as num).toInt(),
    loadUnit: row['load_unit'] as String? ?? 'kg',
    notes: row['notes'] as String? ?? '',
  );
}

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

String _weekday(DateTime value) => const <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
][value.weekday - 1];
