import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/routines.dart';

import '../../exercises/controllers/dashboard_exercise_controllers.dart';

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  throw StateError('routineRepositoryProvider must be overridden.');
});

final dashboardRoutineLibraryControllerProvider =
    AsyncNotifierProvider.autoDispose<DashboardRoutineLibraryController, List<RoutineSummary>>(
      DashboardRoutineLibraryController.new,
    );

final class DashboardRoutineLibraryController extends AsyncNotifier<List<RoutineSummary>> {
  RoutineRepository get _repository => ref.read(routineRepositoryProvider);

  String _operationId(String operation) =>
      ref.read(dashboardOperationIdFactoryProvider).create(operation);

  @override
  Future<List<RoutineSummary>> build() => _repository.listRoutines();

  Future<void> refresh() async {
    state = const AsyncLoading<List<RoutineSummary>>();
    state = await AsyncValue.guard(_repository.listRoutines);
  }

  Future<void> archive(RoutineSummary routine) async {
    await _repository.archiveDraft(
      routine.id,
      routine.revision,
      _operationId('archive-routine'),
    );
    await refresh();
  }
}

final class DashboardRoutineEditorRequest {
  const DashboardRoutineEditorRequest({this.routineId});

  final String? routineId;

  @override
  bool operator ==(Object other) =>
      other is DashboardRoutineEditorRequest && other.routineId == routineId;

  @override
  int get hashCode => routineId.hashCode;
}

enum DashboardRoutineActionState {
  idle,
  saving,
  saved,
  validating,
  submitting,
  submitted,
  publishing,
  published,
  stale,
  failed,
}

final class DashboardRoutineEditorState {
  const DashboardRoutineEditorState({
    required this.draft,
    required this.action,
    this.validation,
    this.message,
    this.dirty = false,
  });

  final RoutineDraft draft;
  final DashboardRoutineActionState action;
  final RoutineValidationResult? validation;
  final String? message;
  final bool dirty;

  DashboardRoutineEditorState copyWith({
    RoutineDraft? draft,
    DashboardRoutineActionState? action,
    RoutineValidationResult? validation,
    bool clearValidation = false,
    String? message,
    bool clearMessage = false,
    bool? dirty,
  }) => DashboardRoutineEditorState(
    draft: draft ?? this.draft,
    action: action ?? this.action,
    validation: clearValidation ? null : validation ?? this.validation,
    message: clearMessage ? null : message ?? this.message,
    dirty: dirty ?? this.dirty,
  );
}

final dashboardRoutineEditorControllerProvider = AsyncNotifierProvider.autoDispose
    .family<
      DashboardRoutineEditorController,
      DashboardRoutineEditorState,
      DashboardRoutineEditorRequest
    >(
      DashboardRoutineEditorController.new,
    );

final class DashboardRoutineEditorController extends AsyncNotifier<DashboardRoutineEditorState> {
  DashboardRoutineEditorController(this.request);

  final DashboardRoutineEditorRequest request;

  RoutineRepository get _repository => ref.read(routineRepositoryProvider);

  String _operationId(String operation) =>
      ref.read(dashboardOperationIdFactoryProvider).create(operation);

  @override
  Future<DashboardRoutineEditorState> build() async {
    final routineId = request.routineId;
    final draft = routineId == null
        ? (await _repository.createDraft(
            'Untitled routine',
            null,
            _operationId('create-routine'),
          )).value
        : await _repository.getDraft(routineId);
    return DashboardRoutineEditorState(
      draft: draft,
      action: DashboardRoutineActionState.idle,
    );
  }

  void updateName(String value) => _updateDraft((draft) => _copyDraft(draft, name: value));

  void updateDescription(String value) => _updateDraft(
    (draft) => _copyDraft(
      draft,
      description: value.trim().isEmpty ? null : value,
      replaceDescription: true,
    ),
  );

  void updateDayKind(int dayIndex, RoutineDayKind kind) => _updateDay(dayIndex, (day) {
    return _copyDay(
      day,
      kind: kind,
      prescriptions: kind == RoutineDayKind.rest ? const <RoutinePrescription>[] : null,
    );
  });

  void updateDayTitle(int dayIndex, String value) =>
      _updateDay(dayIndex, (day) => _copyDay(day, title: value));

  void updateDayPurpose(int dayIndex, String value) => _updateDay(
    dayIndex,
    (day) => _copyDay(
      day,
      purpose: value.trim().isEmpty ? null : value,
      replacePurpose: true,
    ),
  );

  void addPrescription({
    required int dayIndex,
    required String exerciseId,
    required String guidanceRevisionId,
  }) => _updateDay(dayIndex, (day) {
    final prescriptions = List<RoutinePrescription>.of(day.prescriptions)
      ..add(
        RoutinePrescription(
          id: '',
          exerciseId: exerciseId,
          guidanceRevisionId: guidanceRevisionId,
          position: day.prescriptions.length + 1,
          sets: 3,
          minReps: 8,
          maxReps: 12,
          rir: 2,
          restSeconds: 90,
          priority: day.prescriptions.isEmpty,
          loadUnit: 'kg',
          notes: null,
        ),
      );
    return _copyDay(day, prescriptions: prescriptions);
  });

  void removePrescription(int dayIndex, int prescriptionIndex) =>
      _updatePrescriptions(dayIndex, (items) => items..removeAt(prescriptionIndex));

  void movePrescription(int dayIndex, int from, int to) {
    if (to < 0) return;
    _updatePrescriptions(dayIndex, (items) {
      if (to >= items.length) return items;
      final item = items.removeAt(from);
      items.insert(to, item);
      return items;
    });
  }

  void updatePrescription(
    int dayIndex,
    int prescriptionIndex, {
    String? exerciseId,
    String? guidanceRevisionId,
    int? sets,
    int? minReps,
    int? maxReps,
    int? rir,
    int? restSeconds,
    bool? priority,
    String? loadUnit,
    bool replaceLoadUnit = false,
    String? notes,
    bool replaceNotes = false,
  }) => _updatePrescriptions(dayIndex, (items) {
    final current = items[prescriptionIndex];
    items[prescriptionIndex] = RoutinePrescription(
      id: current.id,
      exerciseId: exerciseId ?? current.exerciseId,
      guidanceRevisionId: guidanceRevisionId ?? current.guidanceRevisionId,
      position: current.position,
      sets: sets ?? current.sets,
      minReps: minReps ?? current.minReps,
      maxReps: maxReps ?? current.maxReps,
      rir: rir ?? current.rir,
      restSeconds: restSeconds ?? current.restSeconds,
      priority: priority ?? current.priority,
      loadUnit: replaceLoadUnit ? loadUnit : loadUnit ?? current.loadUnit,
      notes: replaceNotes ? notes : notes ?? current.notes,
    );
    return items;
  });

  Future<RoutineDraft?> save() async {
    final current = state.value;
    if (current == null) return null;
    state = AsyncData(current.copyWith(action: DashboardRoutineActionState.saving));
    try {
      final result = await _repository.saveDraft(
        SaveRoutineDraftCommand(
          draft: current.draft,
          expectedRevision: current.draft.revision,
          idempotencyKey: _operationId('save-routine'),
        ),
      );
      state = AsyncData(
        current.copyWith(
          draft: result.value,
          action: DashboardRoutineActionState.saved,
          dirty: false,
          message: result.replayed ? 'Routine save safely replayed.' : 'Routine saved.',
        ),
      );
      return result.value;
    } on RoutineFailure catch (failure) {
      state = AsyncData(
        current.copyWith(
          action: failure.code == 'stale_revision'
              ? DashboardRoutineActionState.stale
              : DashboardRoutineActionState.failed,
          message: failure.code == 'stale_revision'
              ? 'This routine changed elsewhere. Reload before saving.'
              : 'Routine could not be saved.',
        ),
      );
      return null;
    }
  }

  Future<RoutineValidationResult?> validate() async {
    final saved = await save();
    final current = state.value;
    if (saved == null || current == null) return null;
    state = AsyncData(current.copyWith(action: DashboardRoutineActionState.validating));
    try {
      final result = await _repository.validateDraft(saved.id, saved.revision);
      final latest = state.requireValue;
      state = AsyncData(
        latest.copyWith(
          action: DashboardRoutineActionState.idle,
          validation: result,
          message: result.isValid
              ? 'Routine passes routine-validator-v1.'
              : 'Resolve ${result.issues.length} validation issue(s).',
        ),
      );
      return result;
    } on Object {
      final latest = state.requireValue;
      state = AsyncData(
        latest.copyWith(
          action: DashboardRoutineActionState.failed,
          message: 'Routine validation could not be completed.',
        ),
      );
      return null;
    }
  }

  /// Compatibility entrypoint for the old Submit button. It now publishes the
  /// routine directly; there is no review stage.
  Future<RoutineVersion?> submit() => publish();

  /// Saves, validates, and publishes the owner's routine in one action.
  Future<RoutineVersion?> publish([DateTime? ignoredEffectiveDate]) async {
    final validation = await validate();
    final current = state.value;
    if (validation == null || current == null) return null;
    if (!validation.isValid) {
      state = AsyncData(
        current.copyWith(message: 'Publication is blocked until validation passes.'),
      );
      return null;
    }

    final savedDraft = state.requireValue.draft;
    if (savedDraft.status != RoutineDraftStatus.draft) return null;

    state = AsyncData(
      state.requireValue.copyWith(action: DashboardRoutineActionState.publishing),
    );
    try {
      final result = await _repository.publishDraft(
        savedDraft.id,
        savedDraft.revision,
        _operationId('publish-routine'),
      );
      final publishedDraft = await _repository.getDraft(savedDraft.id);
      final latest = state.requireValue;
      state = AsyncData(
        latest.copyWith(
          draft: publishedDraft,
          action: DashboardRoutineActionState.published,
          dirty: false,
          message: 'Routine version ${result.value.versionNumber} published immediately.',
        ),
      );
      ref
        ..invalidate(dashboardRoutineVersionsProvider(savedDraft.id))
        ..invalidate(dashboardRoutineLibraryControllerProvider);
      return result.value;
    } on RoutineFailure catch (failure) {
      final latest = state.requireValue;
      state = AsyncData(
        latest.copyWith(
          action: failure.code == 'stale_revision'
              ? DashboardRoutineActionState.stale
              : DashboardRoutineActionState.failed,
          message: failure.code == 'stale_revision'
              ? 'This routine changed elsewhere. Reload before publishing.'
              : 'Publication failed.',
        ),
      );
      return null;
    } on Object {
      final latest = state.requireValue;
      state = AsyncData(
        latest.copyWith(
          action: DashboardRoutineActionState.failed,
          message: 'Publication failed.',
        ),
      );
      return null;
    }
  }

  void _updateDraft(RoutineDraft Function(RoutineDraft) update) {
    final current = state.value;
    if (current == null || current.draft.status != RoutineDraftStatus.draft) return;
    state = AsyncData(
      current.copyWith(
        draft: update(current.draft),
        action: DashboardRoutineActionState.idle,
        dirty: true,
        clearValidation: true,
        clearMessage: true,
      ),
    );
  }

  void _updateDay(int dayIndex, RoutineDay Function(RoutineDay) update) => _updateDraft((draft) {
    final days = List<RoutineDay>.of(draft.days);
    final index = days.indexWhere((day) => day.dayIndex == dayIndex);
    days[index] = update(days[index]);
    return _copyDraft(draft, days: days);
  });

  void _updatePrescriptions(
    int dayIndex,
    List<RoutinePrescription> Function(List<RoutinePrescription>) update,
  ) => _updateDay(dayIndex, (day) {
    final reordered = update(List<RoutinePrescription>.of(day.prescriptions));
    return _copyDay(
      day,
      prescriptions: <RoutinePrescription>[
        for (var index = 0; index < reordered.length; index++)
          _copyPrescription(reordered[index], position: index + 1),
      ],
    );
  });
}

// The old review routes are kept inert for generated-router compatibility.
// They are no longer part of routine publication and the backend review RPCs
// are revoked from authenticated users.
final dashboardReviewQueueProvider = FutureProvider.autoDispose<List<RoutineSubmission>>(
  (ref) async => const <RoutineSubmission>[],
);

enum DashboardReviewActionState { idle, deciding, publishing, completed, failed }

final class DashboardRoutineReviewState {
  const DashboardRoutineReviewState({
    required this.submission,
    required this.action,
    this.version,
    this.message,
  });

  final RoutineSubmission submission;
  final DashboardReviewActionState action;
  final RoutineVersion? version;
  final String? message;
}

final dashboardRoutineReviewControllerProvider = AsyncNotifierProvider.autoDispose
    .family<DashboardRoutineReviewController, DashboardRoutineReviewState, String>(
      DashboardRoutineReviewController.new,
    );

final class DashboardRoutineReviewController extends AsyncNotifier<DashboardRoutineReviewState> {
  DashboardRoutineReviewController(this.submissionId);

  final String submissionId;

  @override
  Future<DashboardRoutineReviewState> build() async {
    throw StateError('Routine review has been removed. Publish routines directly from the editor.');
  }

  Future<void> approve({String? note}) async {}
  Future<void> reject(String note) async {}
}

final dashboardRoutineVersionsProvider = FutureProvider.autoDispose
    .family<List<RoutineVersion>, String>(
      (ref, routineId) => ref.watch(routineRepositoryProvider).listVersions(routineId),
    );

final dashboardRoutineVersionProvider = FutureProvider.autoDispose
    .family<RoutineVersion, ({String routineId, String versionId})>(
      (ref, request) =>
          ref.watch(routineRepositoryProvider).getVersion(request.routineId, request.versionId),
    );

Future<RoutineDraft> duplicateRoutineVersion(
  WidgetRef ref, {
  required String routineId,
  required String versionId,
  required String name,
}) async {
  final result = await ref
      .read(routineRepositoryProvider)
      .duplicateVersion(
        routineId,
        versionId,
        name,
        ref.read(dashboardOperationIdFactoryProvider).create('duplicate-routine-version'),
      );
  ref.invalidate(dashboardRoutineLibraryControllerProvider);
  return result.value;
}

RoutineDraft _copyDraft(
  RoutineDraft draft, {
  String? name,
  String? description,
  bool replaceDescription = false,
  List<RoutineDay>? days,
}) => RoutineDraft(
  id: draft.id,
  ownerId: draft.ownerId,
  name: name ?? draft.name,
  description: replaceDescription ? description : description ?? draft.description,
  status: draft.status,
  revision: draft.revision,
  days: days ?? draft.days,
  baseVersionId: draft.baseVersionId,
  latestSubmissionId: draft.latestSubmissionId,
  createdAt: draft.createdAt,
  updatedAt: draft.updatedAt,
);

RoutineDay _copyDay(
  RoutineDay day, {
  RoutineDayKind? kind,
  String? title,
  String? purpose,
  bool replacePurpose = false,
  List<RoutinePrescription>? prescriptions,
}) => RoutineDay(
  id: day.id,
  dayIndex: day.dayIndex,
  kind: kind ?? day.kind,
  title: title ?? day.title,
  purpose: replacePurpose ? purpose : purpose ?? day.purpose,
  prescriptions: prescriptions ?? day.prescriptions,
);

RoutinePrescription _copyPrescription(
  RoutinePrescription prescription, {
  required int position,
}) => RoutinePrescription(
  id: prescription.id,
  exerciseId: prescription.exerciseId,
  guidanceRevisionId: prescription.guidanceRevisionId,
  position: position,
  sets: prescription.sets,
  minReps: prescription.minReps,
  maxReps: prescription.maxReps,
  rir: prescription.rir,
  restSeconds: prescription.restSeconds,
  priority: prescription.priority,
  loadUnit: prescription.loadUnit,
  notes: prescription.notes,
);
