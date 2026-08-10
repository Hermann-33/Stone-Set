import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/progression.dart';

import '../providers/progress_providers.dart';
import '../providers/progression_providers.dart';

class ProgressionSection extends ConsumerWidget {
  const ProgressionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(progressionSnapshotProvider);
    return progression.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Card(
        child: ListTile(
          title: const Text('Progression unavailable'),
          subtitle: const Text('Pull to refresh or try again.'),
          trailing: IconButton(
            tooltip: 'Retry progression',
            onPressed: () => ref.invalidate(progressionSnapshotProvider),
            icon: const Icon(Icons.refresh),
          ),
        ),
      ),
      data: (snapshot) => _ProgressionContent(snapshot: snapshot),
    );
  }
}

class _ProgressionContent extends ConsumerWidget {
  const _ProgressionContent({required this.snapshot});

  final ProgressionSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Progression',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            OutlinedButton.icon(
              key: const Key('progress-add-correction'),
              onPressed: () => _showCorrectionDialog(context, ref),
              icon: const Icon(Icons.tune),
              label: const Text('Correction'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (snapshot.recommendations.isEmpty)
          const Card(
            child: ListTile(
              title: Text('No progression recommendations yet.'),
              subtitle: Text(
                'Publish a routine and submit workouts to build evidence.',
              ),
            ),
          )
        else
          for (final recommendation in snapshot.recommendations) ...<Widget>[
            _RecommendationCard(
              recommendation: recommendation,
              options: snapshot.substituteOptions,
            ),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 16),
        Text('Corrections', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        if (snapshot.corrections.isEmpty)
          const Card(child: ListTile(title: Text('No manual corrections.')))
        else
          Card(
            key: const Key('progress-corrections-history'),
            child: Column(
              children: <Widget>[
                for (final correction in snapshot.corrections.take(20))
                  ListTile(
                    dense: true,
                    title: Text(
                      '${correction.delta > 0 ? '+' : ''}${correction.delta} ${correction.kind.name.toUpperCase()}',
                    ),
                    subtitle: Text(correction.reason),
                    trailing: correction.canReverse
                        ? TextButton(
                            onPressed: () =>
                                _reverseCorrection(context, ref, correction),
                            child: const Text('Reverse'),
                          )
                        : const Text('Final'),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RecommendationCard extends ConsumerWidget {
  const _RecommendationCard({
    required this.recommendation,
    required this.options,
  });

  final ProgressionRecommendation recommendation;
  final List<SubstituteExerciseOption> options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = recommendation.setting;
    return Card(
      key: Key('progression-${recommendation.exerciseId}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    recommendation.exerciseName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StateChip(state: recommendation.state),
              ],
            ),
            const SizedBox(height: 6),
            if (recommendation.latestLoad != null)
              Text(
                'Latest: ${_load(recommendation.latestLoad!, recommendation.loadUnit)}',
              ),
            if (recommendation.suggestedLoad != null)
              Text(
                'Next: ${_load(recommendation.suggestedLoad!, recommendation.loadUnit)}',
              ),
            const SizedBox(height: 4),
            Text(recommendation.reason),
            SwitchListTile.adaptive(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Protect progression'),
              value: setting.progressionProtected,
              onChanged: (value) => _saveSetting(
                context,
                ref,
                setting,
                progressionProtected: value,
              ),
            ),
            SwitchListTile.adaptive(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Pain flag'),
              subtitle: const Text(
                'Pauses progression; no medical advice is provided.',
              ),
              value: setting.painFlagged,
              onChanged: (value) =>
                  _saveSetting(context, ref, setting, painFlagged: value),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _editSetting(context, ref, setting, options),
                icon: const Icon(Icons.edit_outlined),
                label: Text(
                  setting.manualNextLoad == null &&
                          setting.preferredSubstituteExerciseId == null &&
                          setting.note.isEmpty
                      ? 'Override, substitute or note'
                      : 'Edit override, substitute or note',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.state});

  final ProgressionRecommendationState state;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(switch (state) {
      ProgressionRecommendationState.increase => 'Increase',
      ProgressionRecommendationState.hold => 'Hold',
      ProgressionRecommendationState.protected => 'Protected',
      ProgressionRecommendationState.override => 'Override',
      ProgressionRecommendationState.noData => 'No data',
    }),
  );
}

Future<void> _saveSetting(
  BuildContext context,
  WidgetRef ref,
  ProgressionSetting current, {
  bool? progressionProtected,
  bool? painFlagged,
  String? preferredSubstituteExerciseId,
  bool preserveSubstitute = true,
  double? manualNextLoad,
  bool preserveManualLoad = true,
  String? note,
}) async {
  try {
    await ref
        .read(progressionRepositoryProvider)
        .updateSetting(
          exerciseId: current.exerciseId,
          progressionProtected:
              progressionProtected ?? current.progressionProtected,
          painFlagged: painFlagged ?? current.painFlagged,
          preferredSubstituteExerciseId: preserveSubstitute
              ? (preferredSubstituteExerciseId ??
                    current.preferredSubstituteExerciseId)
              : preferredSubstituteExerciseId,
          manualNextLoad: preserveManualLoad
              ? (manualNextLoad ?? current.manualNextLoad)
              : manualNextLoad,
          note: note ?? current.note,
        );
    ref.invalidate(progressionSnapshotProvider);
  } on Object catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update progression setting.')),
      );
    }
  }
}

Future<void> _editSetting(
  BuildContext context,
  WidgetRef ref,
  ProgressionSetting setting,
  List<SubstituteExerciseOption> options,
) async {
  final loadController = TextEditingController(
    text: setting.manualNextLoad?.toString() ?? '',
  );
  final noteController = TextEditingController(text: setting.note);
  var substituteId = setting.preferredSubstituteExerciseId;
  final result = await showDialog<_SettingDraft>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Progression controls'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: loadController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Next-load override',
                  hintText: 'Leave empty for automatic',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: substituteId,
                decoration: const InputDecoration(
                  labelText: 'Preferred substitute',
                ),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None'),
                  ),
                  for (final option in options)
                    if (option.exerciseId != setting.exerciseId)
                      DropdownMenuItem<String?>(
                        value: option.exerciseId,
                        child: Text(option.exerciseName),
                      ),
                ],
                onChanged: (value) => setState(() => substituteId = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLength: 500,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final raw = loadController.text.trim();
              final load = raw.isEmpty ? null : double.tryParse(raw);
              if (raw.isNotEmpty && (load == null || load < 0)) return;
              Navigator.pop(
                context,
                _SettingDraft(
                  manualNextLoad: load,
                  preferredSubstituteExerciseId: substituteId,
                  note: noteController.text.trim(),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  loadController.dispose();
  noteController.dispose();
  if (result == null || !context.mounted) return;
  await _saveSetting(
    context,
    ref,
    setting,
    preferredSubstituteExerciseId: result.preferredSubstituteExerciseId,
    preserveSubstitute: false,
    manualNextLoad: result.manualNextLoad,
    preserveManualLoad: false,
    note: result.note,
  );
}

Future<void> _showCorrectionDialog(BuildContext context, WidgetRef ref) async {
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  var kind = ProgressCorrectionKind.rr;
  final result = await showDialog<_CorrectionDraft>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Apply correction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DropdownButtonFormField<ProgressCorrectionKind>(
              initialValue: kind,
              items: const <DropdownMenuItem<ProgressCorrectionKind>>[
                DropdownMenuItem(
                  value: ProgressCorrectionKind.rr,
                  child: Text('RR'),
                ),
                DropdownMenuItem(
                  value: ProgressCorrectionKind.xp,
                  child: Text('XP'),
                ),
              ],
              onChanged: (value) => setState(() => kind = value ?? kind),
            ),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              decoration: const InputDecoration(labelText: 'Signed amount'),
            ),
            TextField(
              controller: reasonController,
              maxLength: 500,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final delta = int.tryParse(amountController.text.trim());
              final reason = reasonController.text.trim();
              if (delta == null || delta == 0 || reason.isEmpty) return;
              Navigator.pop(
                context,
                _CorrectionDraft(kind: kind, delta: delta, reason: reason),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    ),
  );
  amountController.dispose();
  reasonController.dispose();
  if (result == null || !context.mounted) return;
  try {
    await ref
        .read(progressionRepositoryProvider)
        .applyCorrection(
          kind: result.kind,
          delta: result.delta,
          reason: result.reason,
        );
    ref.invalidate(progressionSnapshotProvider);
    ref.invalidate(progressSnapshotProvider);
  } on Object catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not apply correction.')),
      );
    }
  }
}

Future<void> _reverseCorrection(
  BuildContext context,
  WidgetRef ref,
  ProgressCorrection correction,
) async {
  final controller = TextEditingController(
    text: 'Reverse ${correction.reason}',
  );
  final reason = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reverse correction'),
      content: TextField(
        controller: controller,
        maxLength: 500,
        decoration: const InputDecoration(labelText: 'Reason'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) Navigator.pop(context, value);
          },
          child: const Text('Reverse'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (reason == null || !context.mounted) return;
  try {
    await ref
        .read(progressionRepositoryProvider)
        .reverseCorrection(correctionId: correction.id, reason: reason);
    ref.invalidate(progressionSnapshotProvider);
    ref.invalidate(progressSnapshotProvider);
  } on Object catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reverse correction.')),
      );
    }
  }
}

String _load(double value, String unit) {
  final formatted = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
  return '$formatted $unit';
}

final class _SettingDraft {
  const _SettingDraft({
    required this.manualNextLoad,
    required this.preferredSubstituteExerciseId,
    required this.note,
  });

  final double? manualNextLoad;
  final String? preferredSubstituteExerciseId;
  final String note;
}

final class _CorrectionDraft {
  const _CorrectionDraft({
    required this.kind,
    required this.delta,
    required this.reason,
  });

  final ProgressCorrectionKind kind;
  final int delta;
  final String reason;
}
