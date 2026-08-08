import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/exercise_guidance.dart';

import '../data/dashboard_guidance_draft_cache.dart';

final exerciseGuidanceRepositoryProvider = Provider<ExerciseGuidanceRepository>((ref) {
  throw StateError('exerciseGuidanceRepositoryProvider must be overridden.');
});

final dashboardGuidanceDraftCacheProvider = Provider<DashboardGuidanceDraftCache>((ref) {
  throw StateError('dashboardGuidanceDraftCacheProvider must be overridden.');
});

abstract interface class DashboardOperationIdFactory {
  String create(String operation);
}

final class UuidDashboardOperationIdFactory implements DashboardOperationIdFactory {
  UuidDashboardOperationIdFactory({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  @override
  String create(String operation) {
    assert(operation.isNotEmpty, 'Operation names must not be empty.');
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256), growable: false);
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}

final dashboardOperationIdFactoryProvider = Provider<DashboardOperationIdFactory>(
  (ref) => UuidDashboardOperationIdFactory(),
);

final class DashboardExerciseLibraryRequest {
  const DashboardExerciseLibraryRequest({
    this.search,
    this.archive = ExerciseArchiveFilter.active,
    this.publication = ExercisePublicationFilter.all,
    this.equipmentKey,
    this.muscleKey,
    this.sort = ExerciseLibrarySort.updatedDescending,
    this.page = 1,
  });

  final String? search;
  final ExerciseArchiveFilter archive;
  final ExercisePublicationFilter publication;
  final String? equipmentKey;
  final String? muscleKey;
  final ExerciseLibrarySort sort;
  final int page;

  ExerciseLibraryQuery toQuery() => ExerciseLibraryQuery(
    search: search?.trim().isEmpty ?? true ? null : search!.trim(),
    archive: archive,
    publication: publication,
    equipmentKeys: equipmentKey == null ? const <String>[] : <String>[equipmentKey!],
    muscleKeys: muscleKey == null ? const <String>[] : <String>[muscleKey!],
    sort: sort,
    page: page,
  );

  @override
  bool operator ==(Object other) =>
      other is DashboardExerciseLibraryRequest &&
      other.search == search &&
      other.archive == archive &&
      other.publication == publication &&
      other.equipmentKey == equipmentKey &&
      other.muscleKey == muscleKey &&
      other.sort == sort &&
      other.page == page;

  @override
  int get hashCode =>
      Object.hash(search, archive, publication, equipmentKey, muscleKey, sort, page);
}

final class DashboardExerciseLibraryState {
  const DashboardExerciseLibraryState({required this.page, this.pendingExerciseId});

  final ExerciseLibraryPage page;
  final String? pendingExerciseId;

  DashboardExerciseLibraryState copyWith({
    ExerciseLibraryPage? page,
    String? pendingExerciseId,
    bool clearPending = false,
  }) => DashboardExerciseLibraryState(
    page: page ?? this.page,
    pendingExerciseId: clearPending ? null : pendingExerciseId ?? this.pendingExerciseId,
  );
}

final dashboardExerciseLibraryControllerProvider = AsyncNotifierProvider.autoDispose
    .family<
      DashboardExerciseLibraryController,
      DashboardExerciseLibraryState,
      DashboardExerciseLibraryRequest
    >(DashboardExerciseLibraryController.new);

final class DashboardExerciseLibraryController
    extends AsyncNotifier<DashboardExerciseLibraryState> {
  DashboardExerciseLibraryController(this.request);

  final DashboardExerciseLibraryRequest request;

  ExerciseGuidanceRepository get _repository => ref.read(exerciseGuidanceRepositoryProvider);

  DashboardOperationIdFactory get _operationIds => ref.read(dashboardOperationIdFactoryProvider);

  @override
  Future<DashboardExerciseLibraryState> build() async => DashboardExerciseLibraryState(
    page: await _repository.listExercises(request.toQuery()),
  );

  Future<void> refresh() async {
    final previous = state.value;
    state = const AsyncLoading<DashboardExerciseLibraryState>();
    state = await AsyncValue.guard(
      () async => DashboardExerciseLibraryState(
        page: await _repository.listExercises(request.toQuery()),
        pendingExerciseId: previous?.pendingExerciseId,
      ),
    );
  }

  Future<void> setArchived(ExerciseDefinition exercise, {required bool archived}) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(pendingExerciseId: exercise.id));
    final command = ArchiveExerciseCommand(
      exerciseId: exercise.id,
      expectedRevision: exercise.revision,
      idempotencyKey: _operationIds.create(archived ? 'archive-exercise' : 'unarchive-exercise'),
    );
    try {
      if (archived) {
        await _repository.archiveExercise(command);
      } else {
        await _repository.unarchiveExercise(command);
      }
      await refresh();
    } on Object catch (error, stackTrace) {
      state = AsyncError<DashboardExerciseLibraryState>(error, stackTrace);
    }
  }

  Future<String?> clone(ExerciseDefinition exercise) async {
    final current = state.value;
    if (current == null) return null;
    state = AsyncData(current.copyWith(pendingExerciseId: exercise.id));
    try {
      final result = await _repository.cloneExercise(
        CloneExerciseCommand(
          sourceExerciseId: exercise.id,
          canonicalName: '${exercise.canonicalName} copy',
          idempotencyKey: _operationIds.create('clone-exercise'),
        ),
      );
      await refresh();
      return result.exercise.id;
    } on Object catch (error, stackTrace) {
      state = AsyncError<DashboardExerciseLibraryState>(error, stackTrace);
      return null;
    }
  }
}

final dashboardExerciseProvider = FutureProvider.autoDispose.family<ExerciseDefinition, String>(
  (ref, exerciseId) => ref.watch(exerciseGuidanceRepositoryProvider).getExercise(exerciseId),
);

final dashboardMusclesProvider = FutureProvider.autoDispose<List<Muscle>>(
  (ref) => ref.watch(exerciseGuidanceRepositoryProvider).listMuscles(),
);

final dashboardGuidanceRevisionsProvider = FutureProvider.autoDispose
    .family<GuidanceRevisionPage, String>(
      (ref, exerciseId) =>
          ref.watch(exerciseGuidanceRepositoryProvider).listGuidanceRevisions(exerciseId),
    );

final dashboardGuidanceRevisionProvider = FutureProvider.autoDispose
    .family<GuidanceRevision, ({String exerciseId, String revisionId})>(
      (ref, request) => ref
          .watch(exerciseGuidanceRepositoryProvider)
          .getGuidanceRevision(request.exerciseId, request.revisionId),
    );

final dashboardGlobalExerciseSearchProvider = FutureProvider.autoDispose<List<ExerciseLibraryItem>>(
  (
    ref,
  ) async {
    final page = await ref
        .watch(exerciseGuidanceRepositoryProvider)
        .listExercises(ExerciseLibraryQuery(archive: ExerciseArchiveFilter.all, pageSize: 100));
    return page.items;
  },
);

final class DashboardExerciseEditorRequest {
  const DashboardExerciseEditorRequest({required this.userId, this.exerciseId});

  final String userId;
  final String? exerciseId;

  @override
  bool operator ==(Object other) =>
      other is DashboardExerciseEditorRequest &&
      other.userId == userId &&
      other.exerciseId == exerciseId;

  @override
  int get hashCode => Object.hash(userId, exerciseId);
}

enum DashboardExerciseEditorSaveState { idle, saving, saved, duplicateWarning, stale, failed }

final class DashboardExerciseEditorState {
  DashboardExerciseEditorState({
    required this.availableMuscles,
    required this.canonicalName,
    required this.variantKey,
    required Iterable<String> equipmentKeys,
    required Iterable<String> primaryMuscleKeys,
    required Iterable<String> secondaryMuscleKeys,
    required this.saveState,
    this.dirty = false,
    this.exercise,
    this.validation,
    this.message,
  }) : equipmentKeys = List<String>.unmodifiable(equipmentKeys),
       primaryMuscleKeys = List<String>.unmodifiable(primaryMuscleKeys),
       secondaryMuscleKeys = List<String>.unmodifiable(secondaryMuscleKeys);

  final ExerciseDefinition? exercise;
  final List<Muscle> availableMuscles;
  final String canonicalName;
  final String? variantKey;
  final List<String> equipmentKeys;
  final List<String> primaryMuscleKeys;
  final List<String> secondaryMuscleKeys;
  final DashboardExerciseEditorSaveState saveState;
  final bool dirty;
  final ExerciseGuidanceValidationResult? validation;
  final String? message;

  DashboardExerciseEditorState copyWith({
    ExerciseDefinition? exercise,
    List<Muscle>? availableMuscles,
    String? canonicalName,
    String? variantKey,
    bool clearVariant = false,
    List<String>? equipmentKeys,
    List<String>? primaryMuscleKeys,
    List<String>? secondaryMuscleKeys,
    DashboardExerciseEditorSaveState? saveState,
    bool? dirty,
    ExerciseGuidanceValidationResult? validation,
    bool clearValidation = false,
    String? message,
    bool clearMessage = false,
  }) => DashboardExerciseEditorState(
    exercise: exercise ?? this.exercise,
    availableMuscles: availableMuscles ?? this.availableMuscles,
    canonicalName: canonicalName ?? this.canonicalName,
    variantKey: clearVariant ? null : variantKey ?? this.variantKey,
    equipmentKeys: equipmentKeys ?? this.equipmentKeys,
    primaryMuscleKeys: primaryMuscleKeys ?? this.primaryMuscleKeys,
    secondaryMuscleKeys: secondaryMuscleKeys ?? this.secondaryMuscleKeys,
    saveState: saveState ?? this.saveState,
    dirty: dirty ?? this.dirty,
    validation: clearValidation ? null : validation ?? this.validation,
    message: clearMessage ? null : message ?? this.message,
  );
}

final dashboardExerciseEditorControllerProvider = AsyncNotifierProvider.autoDispose
    .family<
      DashboardExerciseEditorController,
      DashboardExerciseEditorState,
      DashboardExerciseEditorRequest
    >(DashboardExerciseEditorController.new);

final class DashboardExerciseEditorController extends AsyncNotifier<DashboardExerciseEditorState> {
  DashboardExerciseEditorController(this.request);

  final DashboardExerciseEditorRequest request;

  ExerciseGuidanceRepository get _repository => ref.read(exerciseGuidanceRepositoryProvider);

  DashboardOperationIdFactory get _operationIds => ref.read(dashboardOperationIdFactoryProvider);

  @override
  Future<DashboardExerciseEditorState> build() async {
    final muscles = await _repository.listMuscles();
    final exerciseId = request.exerciseId;
    if (exerciseId == null) {
      return DashboardExerciseEditorState(
        availableMuscles: muscles,
        canonicalName: '',
        variantKey: null,
        equipmentKeys: const <String>[],
        primaryMuscleKeys: const <String>[],
        secondaryMuscleKeys: const <String>[],
        saveState: DashboardExerciseEditorSaveState.idle,
      );
    }
    final exercise = await _repository.getExercise(exerciseId);
    if (exercise.userId != request.userId) {
      throw const ExerciseGuidanceFailure(ExerciseGuidanceErrorCode.forbidden);
    }
    return DashboardExerciseEditorState(
      exercise: exercise,
      availableMuscles: muscles,
      canonicalName: exercise.canonicalName,
      variantKey: exercise.variantKey,
      equipmentKeys: exercise.equipmentKeys,
      primaryMuscleKeys: exercise.primaryMuscles.map((selection) => selection.muscle.key),
      secondaryMuscleKeys: exercise.secondaryMuscles.map((selection) => selection.muscle.key),
      saveState: DashboardExerciseEditorSaveState.idle,
    );
  }

  void updateName(String value) => _update((current) => current.copyWith(canonicalName: value));

  void updateVariant(String value) => _update(
    (current) => value.trim().isEmpty
        ? current.copyWith(clearVariant: true)
        : current.copyWith(variantKey: value.trim()),
  );

  void updateEquipment(String value) => _update(
    (current) => current.copyWith(
      equipmentKeys: value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
    ),
  );

  void setMuscleRole(Muscle muscle, ExerciseMuscleRole? role) => _update((current) {
    final primary = List<String>.of(current.primaryMuscleKeys)..remove(muscle.key);
    final secondary = List<String>.of(current.secondaryMuscleKeys)..remove(muscle.key);
    switch (role) {
      case ExerciseMuscleRole.primary:
        primary.add(muscle.key);
      case ExerciseMuscleRole.secondary:
        secondary.add(muscle.key);
      case null:
        break;
    }
    return current.copyWith(primaryMuscleKeys: primary, secondaryMuscleKeys: secondary);
  });

  Future<ExerciseDefinition?> save({bool confirmDuplicate = false}) async {
    final current = state.value;
    if (current == null) return null;
    final validation = const ExerciseGuidanceValidator().validateExercise(
      canonicalName: current.canonicalName,
      variantKey: current.variantKey,
      equipmentKeys: current.equipmentKeys,
      primaryMuscleKeys: current.primaryMuscleKeys,
      secondaryMuscleKeys: current.secondaryMuscleKeys,
    );
    if (!validation.isValid) {
      state = AsyncData(
        current.copyWith(
          validation: validation,
          saveState: DashboardExerciseEditorSaveState.failed,
          message: 'Resolve the listed fields before saving.',
        ),
      );
      return null;
    }
    state = AsyncData(
      current.copyWith(
        validation: validation,
        saveState: DashboardExerciseEditorSaveState.saving,
        clearMessage: true,
      ),
    );
    try {
      final result = await _repository.createOrUpdateExercise(
        CreateOrUpdateExerciseCommand(
          exerciseId: current.exercise?.id,
          canonicalName: current.canonicalName,
          variantKey: current.variantKey,
          equipmentKeys: current.equipmentKeys,
          primaryMuscleKeys: current.primaryMuscleKeys,
          secondaryMuscleKeys: current.secondaryMuscleKeys,
          expectedRevision: current.exercise?.revision,
          idempotencyKey: _operationIds.create(
            current.exercise == null ? 'create-exercise' : 'update-exercise',
          ),
          duplicateConfirmed: confirmDuplicate,
        ),
      );
      state = AsyncData(
        current.copyWith(
          exercise: result.exercise,
          saveState: DashboardExerciseEditorSaveState.saved,
          dirty: false,
          message: result.replayed ? 'Saved. Safe retry replayed.' : 'Exercise saved.',
        ),
      );
      return result.exercise;
    } on ExerciseGuidanceFailure catch (failure) {
      final editorState = switch (failure.code) {
        ExerciseGuidanceErrorCode.duplicateConfirmationRequired =>
          DashboardExerciseEditorSaveState.duplicateWarning,
        ExerciseGuidanceErrorCode.staleRevision => DashboardExerciseEditorSaveState.stale,
        _ => DashboardExerciseEditorSaveState.failed,
      };
      final message = switch (failure.code) {
        ExerciseGuidanceErrorCode.duplicateConfirmationRequired =>
          'A matching exercise already exists. Confirm only if this is intentionally separate.',
        ExerciseGuidanceErrorCode.staleRevision =>
          'This exercise changed elsewhere. Reload before saving again.',
        _ => 'Exercise could not be saved. Retry when the service is available.',
      };
      state = AsyncData(current.copyWith(saveState: editorState, message: message));
      return null;
    }
  }

  void _update(DashboardExerciseEditorState Function(DashboardExerciseEditorState) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      update(current).copyWith(
        saveState: DashboardExerciseEditorSaveState.idle,
        dirty: true,
        clearValidation: true,
        clearMessage: true,
      ),
    );
  }
}

enum DashboardGuidanceSaveState {
  saving,
  saved,
  offline,
  syncing,
  conflict,
  failed,
  readOnly,
}

enum DashboardGuidanceSection {
  setup('Setup', 'setupSteps'),
  execution('Execution', 'executionSteps'),
  cues('Technique cues', 'techniqueCues'),
  mistakes('Common mistakes', 'commonMistakes'),
  safety('Safety notes', 'safetyNotes');

  const DashboardGuidanceSection(this.label, this.field);

  final String label;
  final String field;
}

final class DashboardGuidanceEditorRequest {
  const DashboardGuidanceEditorRequest({
    required this.userId,
    required this.exerciseId,
    required this.draftId,
  });

  final String userId;
  final String exerciseId;
  final String draftId;

  DashboardGuidanceRecoveryKey get recoveryKey => DashboardGuidanceRecoveryKey(
    userId: userId,
    exerciseId: exerciseId,
    draftId: draftId,
  );

  @override
  bool operator ==(Object other) =>
      other is DashboardGuidanceEditorRequest &&
      other.userId == userId &&
      other.exerciseId == exerciseId &&
      other.draftId == draftId;

  @override
  int get hashCode => Object.hash(userId, exerciseId, draftId);
}

final class DashboardGuidanceConflict {
  const DashboardGuidanceConflict({
    required this.local,
    required this.remote,
    this.concurrentLocal,
  });

  final GuidanceContentV1 local;
  final GuidanceContentV1 remote;
  final DashboardGuidanceRecoveryRecord? concurrentLocal;
}

final class DashboardGuidanceEditorState {
  const DashboardGuidanceEditorState({
    required this.content,
    required this.status,
    required this.localRevision,
    required this.persistedLocalRevision,
    required this.expectedServerRevision,
    this.exercise,
    this.serverDraft,
    this.validation,
    this.conflict,
    this.publishedRevision,
    this.message,
  });

  final ExerciseDefinition? exercise;
  final GuidanceDraft? serverDraft;
  final GuidanceContentV1 content;
  final DashboardGuidanceSaveState status;
  final int localRevision;
  final int? persistedLocalRevision;
  final int expectedServerRevision;
  final ExerciseGuidanceValidationResult? validation;
  final DashboardGuidanceConflict? conflict;
  final GuidanceRevision? publishedRevision;
  final String? message;

  DashboardGuidanceEditorState copyWith({
    ExerciseDefinition? exercise,
    GuidanceDraft? serverDraft,
    GuidanceContentV1? content,
    DashboardGuidanceSaveState? status,
    int? localRevision,
    int? persistedLocalRevision,
    bool clearPersistedLocalRevision = false,
    int? expectedServerRevision,
    ExerciseGuidanceValidationResult? validation,
    bool clearValidation = false,
    DashboardGuidanceConflict? conflict,
    bool clearConflict = false,
    GuidanceRevision? publishedRevision,
    String? message,
    bool clearMessage = false,
  }) => DashboardGuidanceEditorState(
    exercise: exercise ?? this.exercise,
    serverDraft: serverDraft ?? this.serverDraft,
    content: content ?? this.content,
    status: status ?? this.status,
    localRevision: localRevision ?? this.localRevision,
    persistedLocalRevision: clearPersistedLocalRevision
        ? null
        : persistedLocalRevision ?? this.persistedLocalRevision,
    expectedServerRevision: expectedServerRevision ?? this.expectedServerRevision,
    validation: clearValidation ? null : validation ?? this.validation,
    conflict: clearConflict ? null : conflict ?? this.conflict,
    publishedRevision: publishedRevision ?? this.publishedRevision,
    message: clearMessage ? null : message ?? this.message,
  );
}

final dashboardGuidanceEditorControllerProvider = AsyncNotifierProvider.autoDispose
    .family<
      DashboardGuidanceEditorController,
      DashboardGuidanceEditorState,
      DashboardGuidanceEditorRequest
    >(DashboardGuidanceEditorController.new);

final class DashboardGuidanceEditorController extends AsyncNotifier<DashboardGuidanceEditorState> {
  DashboardGuidanceEditorController(this.request);

  static const _localSaveDelay = Duration(milliseconds: 250);

  final DashboardGuidanceEditorRequest request;
  Timer? _saveTimer;
  Future<void>? _activeRemoteSync;

  ExerciseGuidanceRepository get _repository => ref.read(exerciseGuidanceRepositoryProvider);

  DashboardGuidanceDraftCache get _cache => ref.read(dashboardGuidanceDraftCacheProvider);

  DashboardOperationIdFactory get _operationIds => ref.read(dashboardOperationIdFactoryProvider);

  @override
  Future<DashboardGuidanceEditorState> build() async {
    ref.onDispose(() => _saveTimer?.cancel());
    DashboardGuidanceRecoveryRecord? recovery;
    var recoveryUnavailable = false;
    try {
      recovery = await _cache.read(request.recoveryKey);
    } on Object {
      recoveryUnavailable = true;
    }
    try {
      await _cache.cleanConfirmedForUser(request.userId, DateTime.now().toUtc());
    } on Object {
      recoveryUnavailable = true;
    }
    try {
      final exercise = await _repository.getExercise(request.exerciseId);
      final draft = await _repository.getGuidanceDraft(request.exerciseId);
      if (draft.id != request.draftId || draft.userId != request.userId) {
        throw const ExerciseGuidanceFailure(ExerciseGuidanceErrorCode.forbidden);
      }
      if (recovery == null) {
        return DashboardGuidanceEditorState(
          exercise: exercise,
          serverDraft: draft,
          content: draft.content,
          status: recoveryUnavailable
              ? DashboardGuidanceSaveState.failed
              : DashboardGuidanceSaveState.saved,
          localRevision: 0,
          persistedLocalRevision: null,
          expectedServerRevision: draft.revision,
          message: recoveryUnavailable
              ? 'Browser recovery is unavailable. Server content is loaded; keep this page open and retry before editing.'
              : null,
        );
      }
      final localContent = guidanceContentFromRecovery(recovery.structuredPayload);
      if (recovery.expectedServerRevision != draft.revision) {
        return DashboardGuidanceEditorState(
          exercise: exercise,
          serverDraft: draft,
          content: localContent,
          status: DashboardGuidanceSaveState.conflict,
          localRevision: recovery.localRevision,
          persistedLocalRevision: recovery.localRevision,
          expectedServerRevision: recovery.expectedServerRevision,
          conflict: DashboardGuidanceConflict(local: localContent, remote: draft.content),
          message: 'The server draft changed while this recovery copy was offline.',
        );
      }
      final changed = !guidanceContentEquals(localContent, draft.content);
      return DashboardGuidanceEditorState(
        exercise: exercise,
        serverDraft: draft,
        content: localContent,
        status: changed ? DashboardGuidanceSaveState.offline : DashboardGuidanceSaveState.saved,
        localRevision: recovery.localRevision,
        persistedLocalRevision: recovery.localRevision,
        expectedServerRevision: draft.revision,
        message: changed ? 'Recovered browser-local changes. Sync when ready.' : null,
      );
    } on ExerciseGuidanceFailure catch (failure) {
      if (failure.code != ExerciseGuidanceErrorCode.networkUnavailable || recovery == null) {
        rethrow;
      }
      final localContent = guidanceContentFromRecovery(recovery.structuredPayload);
      return DashboardGuidanceEditorState(
        content: localContent,
        status: DashboardGuidanceSaveState.offline,
        localRevision: recovery.localRevision,
        persistedLocalRevision: recovery.localRevision,
        expectedServerRevision: recovery.expectedServerRevision,
        message: 'Offline. Browser-local recovery is available; publication is unavailable.',
      );
    }
  }

  void updateShortExplanation(String value) => _edit(
    (content) => GuidanceContentV1(
      shortExplanation: value,
      setupSteps: content.setupSteps,
      executionSteps: content.executionSteps,
      techniqueCues: content.techniqueCues,
      commonMistakes: content.commonMistakes,
      safetyNotes: content.safetyNotes,
    ),
  );

  void addItem(DashboardGuidanceSection section) =>
      _replaceSection(section, <String>[..._items(state.requireValue.content, section), '']);

  void updateItem(DashboardGuidanceSection section, int index, String value) {
    final values = List<String>.of(_items(state.requireValue.content, section));
    values[index] = value;
    _replaceSection(section, values);
  }

  void removeItem(DashboardGuidanceSection section, int index) {
    final values = List<String>.of(_items(state.requireValue.content, section))..removeAt(index);
    _replaceSection(section, values);
  }

  void moveItem(DashboardGuidanceSection section, int index, int delta) {
    final values = List<String>.of(_items(state.requireValue.content, section));
    final target = index + delta;
    if (target < 0 || target >= values.length) return;
    final value = values.removeAt(index);
    values.insert(target, value);
    _replaceSection(section, values);
  }

  Future<void> saveNow() async {
    _saveTimer?.cancel();
    final current = state.value;
    if (current == null || current.status == DashboardGuidanceSaveState.conflict) return;
    final locallySaved = await _persistLocal(current);
    if (!locallySaved) return;
    await _syncRemote();
  }

  Future<void> retry() async {
    final current = state.value;
    if (current == null) return;
    if (current.status == DashboardGuidanceSaveState.conflict) {
      final remote = await _repository.getGuidanceDraft(request.exerciseId);
      final latest = state.value;
      if (latest == null) return;
      state = AsyncData(
        latest.copyWith(
          serverDraft: remote,
          conflict: DashboardGuidanceConflict(local: latest.content, remote: remote.content),
          expectedServerRevision: remote.revision,
          message: 'Compare both versions before choosing a recovery action.',
        ),
      );
      return;
    }
    await saveNow();
  }

  Future<void> acceptServer() async {
    final current = state.value;
    final conflict = current?.conflict;
    final remoteDraft = current?.serverDraft;
    if (current == null || conflict == null || remoteDraft == null) return;
    final next = current.copyWith(
      content: conflict.remote,
      status: DashboardGuidanceSaveState.saving,
      localRevision: current.localRevision + 1,
      expectedServerRevision: remoteDraft.revision,
      clearConflict: true,
      clearValidation: true,
      message: 'Server version accepted. Browser recovery updated.',
    );
    state = AsyncData(next);
    await _persistLocal(next, serverConfirmed: true);
    final saved = state.value;
    if (saved != null) {
      state = AsyncData(saved.copyWith(status: DashboardGuidanceSaveState.saved));
    }
  }

  Future<void> useLocalAsNewDraft() async {
    final current = state.value;
    final remoteDraft = current?.serverDraft;
    if (current == null || current.conflict == null || remoteDraft == null) return;
    state = AsyncData(
      current.copyWith(
        status: DashboardGuidanceSaveState.syncing,
        expectedServerRevision: remoteDraft.revision,
        clearConflict: true,
        message: 'Saving the reviewed local version as the current draft.',
      ),
    );
    await _syncRemote();
  }

  Future<void> validate() async {
    final current = state.value;
    if (current == null || current.exercise == null || current.serverDraft == null) return;
    try {
      final result = await _repository.validateGuidanceDraft(
        ValidateGuidanceDraftCommand(
          exerciseId: request.exerciseId,
          draftId: request.draftId,
          expectedExerciseRevision: current.exercise!.revision,
          expectedDraftRevision: current.serverDraft!.revision,
        ),
      );
      final latest = state.value;
      if (latest == null) return;
      if (latest.localRevision != current.localRevision) {
        state = AsyncData(
          latest.copyWith(
            clearValidation: true,
            message: 'Guidance changed during validation. Validate the current draft again.',
          ),
        );
        return;
      }
      state = AsyncData(
        latest.copyWith(
          validation: result,
          message: result.isValid
              ? 'Guidance is ready to publish.'
              : 'Resolve the listed issues before publishing.',
        ),
      );
    } on Object catch (error, stackTrace) {
      state = AsyncError<DashboardGuidanceEditorState>(error, stackTrace);
    }
  }

  Future<GuidancePublishResult?> publish() async {
    await saveNow();
    var current = state.value;
    if (current == null ||
        current.status != DashboardGuidanceSaveState.saved ||
        current.exercise == null ||
        current.serverDraft == null) {
      return null;
    }
    final validation = await _repository.validateGuidanceDraft(
      ValidateGuidanceDraftCommand(
        exerciseId: request.exerciseId,
        draftId: request.draftId,
        expectedExerciseRevision: current.exercise!.revision,
        expectedDraftRevision: current.serverDraft!.revision,
      ),
    );
    final afterValidation = state.value;
    if (afterValidation == null) return null;
    if (afterValidation.localRevision != current.localRevision) {
      state = AsyncData(
        afterValidation.copyWith(
          clearValidation: true,
          message: 'Guidance changed during validation. Save and publish the current draft again.',
        ),
      );
      return null;
    }
    current = afterValidation.copyWith(validation: validation);
    state = AsyncData(current);
    if (!validation.isValid) return null;
    state = AsyncData(current.copyWith(status: DashboardGuidanceSaveState.syncing));
    try {
      final result = await _repository.publishGuidance(
        PublishGuidanceCommand(
          exerciseId: request.exerciseId,
          draftId: request.draftId,
          expectedExerciseRevision: current.exercise!.revision,
          expectedDraftRevision: current.serverDraft!.revision,
          idempotencyKey: _operationIds.create('publish-guidance'),
        ),
      );
      final latest = state.value;
      if (latest == null) return result;
      if (latest.localRevision != current.localRevision) {
        final newer = latest.copyWith(
          serverDraft: current.serverDraft,
          status: DashboardGuidanceSaveState.saving,
          publishedRevision: result.revision,
          message:
              'Version ${result.revision.versionNumber} published. Newer edits remain unpublished and are being saved.',
        );
        state = AsyncData(newer);
        await _persistLocal(newer);
        await _syncRemote();
        return result;
      }
      await _cache.remove(request.recoveryKey);
      state = AsyncData(
        current.copyWith(
          status: DashboardGuidanceSaveState.saved,
          publishedRevision: result.revision,
          message: result.noChange
              ? 'No content changed; the existing revision remains current.'
              : 'Guidance version ${result.revision.versionNumber} published.',
          clearPersistedLocalRevision: true,
        ),
      );
      return result;
    } on ExerciseGuidanceFailure catch (failure, stackTrace) {
      if (failure.code == ExerciseGuidanceErrorCode.staleRevision) {
        await _openRemoteConflict(current);
        return null;
      }
      state = AsyncError<DashboardGuidanceEditorState>(failure, stackTrace);
      return null;
    }
  }

  Future<void> duplicateRevision(GuidanceRevision revision) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(status: DashboardGuidanceSaveState.syncing));
    try {
      final result = await _repository.duplicateGuidanceRevisionAsDraft(
        DuplicateGuidanceRevisionAsDraftCommand(
          exerciseId: request.exerciseId,
          revisionId: revision.id,
          expectedDraftRevision: current.expectedServerRevision,
          idempotencyKey: _operationIds.create('duplicate-guidance-revision'),
        ),
      );
      final latest = state.value;
      if (latest == null) return;
      if (latest.localRevision != current.localRevision) {
        final newer = latest.copyWith(
          serverDraft: result.draft,
          expectedServerRevision: result.draft.revision,
          status: DashboardGuidanceSaveState.saving,
          message:
              'The selected version was duplicated on the server. Newer local edits were kept and are being saved.',
        );
        state = AsyncData(newer);
        await _persistLocal(newer);
        await _syncRemote();
        return;
      }
      final next = current.copyWith(
        serverDraft: result.draft,
        content: result.draft.content,
        status: DashboardGuidanceSaveState.saved,
        localRevision: current.localRevision + 1,
        expectedServerRevision: result.draft.revision,
        clearConflict: true,
        message: 'Version ${revision.versionNumber} duplicated into the editable draft.',
      );
      state = AsyncData(next);
      await _persistLocal(next, serverConfirmed: true);
    } on Object catch (error, stackTrace) {
      state = AsyncError<DashboardGuidanceEditorState>(error, stackTrace);
    }
  }

  void _replaceSection(DashboardGuidanceSection section, List<String> values) => _edit((content) {
    return GuidanceContentV1(
      shortExplanation: content.shortExplanation,
      setupSteps: section == DashboardGuidanceSection.setup ? values : content.setupSteps,
      executionSteps: section == DashboardGuidanceSection.execution
          ? values
          : content.executionSteps,
      techniqueCues: section == DashboardGuidanceSection.cues ? values : content.techniqueCues,
      commonMistakes: section == DashboardGuidanceSection.mistakes
          ? values
          : content.commonMistakes,
      safetyNotes: section == DashboardGuidanceSection.safety ? values : content.safetyNotes,
    );
  });

  void _edit(GuidanceContentV1 Function(GuidanceContentV1 content) update) {
    final current = state.value;
    if (current == null) return;
    final next = current.copyWith(
      content: update(current.content),
      status: DashboardGuidanceSaveState.saving,
      localRevision: current.localRevision + 1,
      clearValidation: true,
      clearConflict: true,
      clearMessage: true,
    );
    state = AsyncData(next);
    _saveTimer?.cancel();
    _saveTimer = Timer(_localSaveDelay, () => unawaited(saveNow()));
  }

  Future<bool> _persistLocal(
    DashboardGuidanceEditorState current, {
    bool serverConfirmed = false,
  }) async {
    state = AsyncData(current.copyWith(status: DashboardGuidanceSaveState.saving));
    try {
      final result = await _cache.compareAndSwap(
        record: DashboardGuidanceRecoveryRecord(
          key: request.recoveryKey,
          localRevision: current.localRevision,
          expectedServerRevision: current.expectedServerRevision,
          structuredPayload: guidanceContentToRecovery(current.content),
          updatedAt: DateTime.now().toUtc(),
          synchronizedAt: serverConfirmed ? DateTime.now().toUtc() : null,
          serverConfirmed: serverConfirmed,
        ),
        expectedLocalRevision: current.persistedLocalRevision,
      );
      if (result.status == DashboardGuidanceCacheWriteStatus.conflict) {
        final latest = state.value ?? current;
        final concurrent = result.current;
        final concurrentContent = concurrent == null
            ? current.serverDraft?.content ?? current.content
            : guidanceContentFromRecovery(concurrent.structuredPayload);
        state = AsyncData(
          latest.copyWith(
            status: DashboardGuidanceSaveState.conflict,
            conflict: DashboardGuidanceConflict(
              local: latest.content,
              remote: latest.serverDraft?.content ?? concurrentContent,
              concurrentLocal: concurrent,
            ),
            message: 'Another browser tab changed this recovery draft.',
          ),
        );
        return false;
      }
      final latest = state.value;
      if (latest != null && latest.localRevision != current.localRevision) {
        final advanced = latest.copyWith(
          persistedLocalRevision: current.localRevision,
          status: DashboardGuidanceSaveState.saving,
        );
        state = AsyncData(advanced);
        return _persistLocal(advanced);
      }
      state = AsyncData(
        current.copyWith(
          persistedLocalRevision: current.localRevision,
          status: serverConfirmed
              ? DashboardGuidanceSaveState.saved
              : DashboardGuidanceSaveState.syncing,
        ),
      );
      return true;
    } on Object {
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          status: DashboardGuidanceSaveState.failed,
          message: 'Browser recovery could not save. Keep this page open and retry.',
        ),
      );
      return false;
    }
  }

  Future<void> _syncRemote() async {
    final active = _activeRemoteSync;
    if (active != null) {
      await active;
      final current = state.value;
      if (current != null &&
          current.status != DashboardGuidanceSaveState.saved &&
          current.status != DashboardGuidanceSaveState.conflict &&
          current.status != DashboardGuidanceSaveState.readOnly) {
        await _syncRemote();
      }
      return;
    }
    final operation = _syncRemoteOnce();
    _activeRemoteSync = operation;
    try {
      await operation;
    } finally {
      _activeRemoteSync = null;
    }
  }

  Future<void> _syncRemoteOnce() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(status: DashboardGuidanceSaveState.syncing));
    try {
      final result = await _repository.saveGuidanceDraft(
        SaveGuidanceDraftCommand(
          exerciseId: request.exerciseId,
          draftId: request.draftId,
          content: current.content,
          expectedRevision: current.expectedServerRevision,
          idempotencyKey: _operationIds.create('save-guidance-draft'),
        ),
      );
      final latest = state.value;
      if (latest == null) return;
      if (latest.localRevision != current.localRevision) {
        final newer = latest.copyWith(
          serverDraft: result.draft,
          expectedServerRevision: result.draft.revision,
          status: DashboardGuidanceSaveState.saving,
          message: 'Newer edits were kept and will be saved next.',
        );
        state = AsyncData(newer);
        await _persistLocal(newer);
        return;
      }
      final synced = current.copyWith(
        serverDraft: result.draft,
        status: DashboardGuidanceSaveState.saved,
        expectedServerRevision: result.draft.revision,
        message: result.replayed ? 'Saved. A safe retry returned the existing result.' : 'Saved.',
        clearConflict: true,
      );
      state = AsyncData(synced);
      await _persistLocal(synced, serverConfirmed: true);
    } on ExerciseGuidanceFailure catch (failure, stackTrace) {
      switch (failure.code) {
        case ExerciseGuidanceErrorCode.networkUnavailable:
        case ExerciseGuidanceErrorCode.serverUnavailable:
          state = AsyncData(
            current.copyWith(
              status: DashboardGuidanceSaveState.offline,
              message: 'Offline. Changes are stored only in this browser until sync succeeds.',
            ),
          );
          return;
        case ExerciseGuidanceErrorCode.staleRevision:
          await _openRemoteConflict(current);
          return;
        default:
          state = AsyncError<DashboardGuidanceEditorState>(failure, stackTrace);
          return;
      }
    }
  }

  Future<void> _openRemoteConflict(DashboardGuidanceEditorState current) async {
    try {
      final remote = await _repository.getGuidanceDraft(request.exerciseId);
      state = AsyncData(
        current.copyWith(
          serverDraft: remote,
          status: DashboardGuidanceSaveState.conflict,
          conflict: DashboardGuidanceConflict(local: current.content, remote: remote.content),
          message: 'The server draft changed. Compare both versions before continuing.',
        ),
      );
    } on Object catch (error, stackTrace) {
      state = AsyncError<DashboardGuidanceEditorState>(error, stackTrace);
    }
  }
}

List<String> _items(GuidanceContentV1 content, DashboardGuidanceSection section) =>
    switch (section) {
      DashboardGuidanceSection.setup => content.setupSteps,
      DashboardGuidanceSection.execution => content.executionSteps,
      DashboardGuidanceSection.cues => content.techniqueCues,
      DashboardGuidanceSection.mistakes => content.commonMistakes,
      DashboardGuidanceSection.safety => content.safetyNotes,
    };

Map<String, Object?> guidanceContentToRecovery(GuidanceContentV1 content) => <String, Object?>{
  'schemaVersion': GuidanceContentV1.schemaVersion,
  'shortExplanation': content.shortExplanation,
  'setupSteps': content.setupSteps,
  'executionSteps': content.executionSteps,
  'techniqueCues': content.techniqueCues,
  'commonMistakes': content.commonMistakes,
  'safetyNotes': content.safetyNotes,
};

GuidanceContentV1 guidanceContentFromRecovery(Map<String, Object?> value) {
  if (value['schemaVersion'] != GuidanceContentV1.schemaVersion) {
    throw const FormatException('Unsupported guidance recovery schema');
  }

  List<String> strings(String key) {
    final field = value[key];
    if (field is! List || field.any((item) => item is! String)) {
      throw FormatException('Invalid guidance recovery content: $key');
    }
    return field.cast<String>();
  }

  final shortExplanation = value['shortExplanation'];
  if (shortExplanation is! String) {
    throw const FormatException('Invalid guidance recovery short explanation');
  }
  return GuidanceContentV1(
    shortExplanation: shortExplanation,
    setupSteps: strings('setupSteps'),
    executionSteps: strings('executionSteps'),
    techniqueCues: strings('techniqueCues'),
    commonMistakes: strings('commonMistakes'),
    safetyNotes: strings('safetyNotes'),
  );
}

bool guidanceContentEquals(GuidanceContentV1 left, GuidanceContentV1 right) =>
    left.shortExplanation == right.shortExplanation &&
    _listEquals(left.setupSteps, right.setupSteps) &&
    _listEquals(left.executionSteps, right.executionSteps) &&
    _listEquals(left.techniqueCues, right.techniqueCues) &&
    _listEquals(left.commonMistakes, right.commonMistakes) &&
    _listEquals(left.safetyNotes, right.safetyNotes);

bool _listEquals(List<String> left, List<String> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
