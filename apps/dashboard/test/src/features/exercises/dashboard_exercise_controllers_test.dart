import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/src/features/exercises/controllers/dashboard_exercise_controllers.dart';
import 'package:stone_set_dashboard/src/features/exercises/data/dashboard_guidance_draft_cache.dart';
import 'package:stone_set_domain/exercise_guidance.dart';

import '../../../support/fake_exercise_guidance_repository.dart';

void main() {
  group('DashboardExerciseLibraryRequest', () {
    test('trims search and preserves plural server filter contracts', () {
      const request = DashboardExerciseLibraryRequest(
        search: '  incline press  ',
        archive: ExerciseArchiveFilter.all,
        publication: ExercisePublicationFilter.published,
        equipmentKey: 'dumbbell',
        muscleKey: 'upper-chest',
        sort: ExerciseLibrarySort.nameAscending,
        page: 3,
      );

      final query = request.toQuery();

      expect(query.search, 'incline press');
      expect(query.archive, ExerciseArchiveFilter.all);
      expect(query.publication, ExercisePublicationFilter.published);
      expect(query.equipmentKeys, <String>['dumbbell']);
      expect(query.muscleKeys, <String>['upper-chest']);
      expect(query.sort, ExerciseLibrarySort.nameAscending);
      expect(query.page, 3);
    });

    test('converts blank search and absent filters to canonical empty values', () {
      const request = DashboardExerciseLibraryRequest(search: '   ');

      final query = request.toQuery();

      expect(query.search, isNull);
      expect(query.equipmentKeys, isEmpty);
      expect(query.muscleKeys, isEmpty);
    });
  });

  test('operation factory creates RFC 4122 UUID-v4 values', () {
    final factory = UuidDashboardOperationIdFactory(random: Random(42));
    final ids = <String>{for (var index = 0; index < 20; index += 1) factory.create('save')};
    final uuidV4 = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    expect(ids, hasLength(20));
    expect(ids.every(uuidV4.hasMatch), isTrue);
  });

  group('guidance recovery codec', () {
    test('round trips all ordered structured fields', () {
      final original = GuidanceContentV1(
        shortExplanation: 'A controlled press.',
        setupSteps: const <String>['Brace', 'Set shoulders'],
        executionSteps: const <String>['Press', 'Lower'],
        techniqueCues: const <String>['Stack wrists'],
        commonMistakes: const <String>['Flaring early'],
        safetyNotes: const <String>['Use a spotter'],
      );

      final decoded = guidanceContentFromRecovery(guidanceContentToRecovery(original));

      expect(guidanceContentEquals(decoded, original), isTrue);
      expect(decoded.setupSteps, orderedEquals(<String>['Brace', 'Set shoulders']));
    });

    test('rejects an unknown schema and malformed list values', () {
      expect(
        () => guidanceContentFromRecovery(const <String, Object?>{
          'schemaVersion': 2,
        }),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => guidanceContentFromRecovery(const <String, Object?>{
          'schemaVersion': 1,
          'shortExplanation': 'Safe',
          'setupSteps': <Object>[1],
          'executionSteps': <String>[],
          'techniqueCues': <String>[],
          'commonMistakes': <String>[],
          'safetyNotes': <String>[],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('DashboardGuidanceEditorController concurrency', () {
    test('keeps and subsequently synchronizes an edit made during remote save', () async {
      final repository = FakeExerciseGuidanceRepository(
        items: <ExerciseLibraryItem>[exerciseItem()],
      );
      final firstSave = Completer<GuidanceDraftMutationResult>();
      repository.draftSaveBlocker = firstSave;
      final container = _container(repository);
      addTearDown(container.dispose);
      const request = DashboardGuidanceEditorRequest(
        userId: testUserId,
        exerciseId: '20000000-0000-4000-8000-000000000001',
        draftId: '40000000-0000-4000-8000-000000000001',
      );
      final subscription = container.listen(
        dashboardGuidanceEditorControllerProvider(request),
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(dashboardGuidanceEditorControllerProvider(request).future);
      final controller = container.read(
        dashboardGuidanceEditorControllerProvider(request).notifier,
      );

      controller.updateShortExplanation('First edit');
      final save = controller.saveNow();
      await _waitFor(() => repository.draftSaves.length == 1);
      controller.updateShortExplanation('Newer edit');
      firstSave.complete(_draftResult(repository.draftSaves.first, revision: 2));
      await save;
      await _waitFor(() => repository.draftSaves.length >= 2);
      await _waitFor(
        () =>
            container.read(dashboardGuidanceEditorControllerProvider(request)).value?.status ==
            DashboardGuidanceSaveState.saved,
      );

      final state = container
          .read(
            dashboardGuidanceEditorControllerProvider(request),
          )
          .requireValue;
      expect(state.content.shortExplanation, 'Newer edit');
      expect(repository.draftSaves.last.content.shortExplanation, 'Newer edit');
      expect(state.expectedServerRevision, 3);
    });

    test('publish never discards typing completed while RPC is in flight', () async {
      final repository = FakeExerciseGuidanceRepository(
        items: <ExerciseLibraryItem>[exerciseItem()],
      );
      final publication = Completer<GuidancePublishResult>();
      repository.publishBlocker = publication;
      final container = _container(repository);
      addTearDown(container.dispose);
      const request = DashboardGuidanceEditorRequest(
        userId: testUserId,
        exerciseId: '20000000-0000-4000-8000-000000000001',
        draftId: '40000000-0000-4000-8000-000000000001',
      );
      final subscription = container.listen(
        dashboardGuidanceEditorControllerProvider(request),
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(dashboardGuidanceEditorControllerProvider(request).future);
      final controller = container.read(
        dashboardGuidanceEditorControllerProvider(request).notifier,
      );

      controller.updateShortExplanation('Publishable edit');
      final publishing = controller.publish();
      await _waitFor(() => repository.publications.length == 1);
      controller.updateShortExplanation('Newer unpublished edit');
      publication.complete(
        GuidancePublishResult(
          revision: guidanceRevision(request.exerciseId),
          noChange: false,
          replayed: false,
          correlationId: '60000000-0000-4000-8000-000000000001',
        ),
      );
      await publishing;
      await _waitFor(
        () => repository.draftSaves.any(
          (command) => command.content.shortExplanation == 'Newer unpublished edit',
        ),
      );

      final state = container
          .read(
            dashboardGuidanceEditorControllerProvider(request),
          )
          .requireValue;
      expect(state.content.shortExplanation, 'Newer unpublished edit');
      expect(state.publishedRevision, isNotNull);
    });

    test('cache startup failure degrades to authoritative server content', () async {
      final repository = FakeExerciseGuidanceRepository(
        items: <ExerciseLibraryItem>[exerciseItem()],
      );
      final container = ProviderContainer(
        overrides: [
          exerciseGuidanceRepositoryProvider.overrideWithValue(repository),
          dashboardGuidanceDraftCacheProvider.overrideWithValue(_ThrowingCache()),
        ],
      );
      addTearDown(container.dispose);
      const request = DashboardGuidanceEditorRequest(
        userId: testUserId,
        exerciseId: '20000000-0000-4000-8000-000000000001',
        draftId: '40000000-0000-4000-8000-000000000001',
      );

      final state = await container.read(
        dashboardGuidanceEditorControllerProvider(request).future,
      );

      expect(state.status, DashboardGuidanceSaveState.failed);
      expect(state.content.shortExplanation, 'Keep the torso stable.');
      expect(state.message, contains('Browser recovery is unavailable'));
    });
  });
}

ProviderContainer _container(FakeExerciseGuidanceRepository repository) => ProviderContainer(
  overrides: [
    exerciseGuidanceRepositoryProvider.overrideWithValue(repository),
    dashboardGuidanceDraftCacheProvider.overrideWithValue(
      InMemoryDashboardGuidanceDraftCache(),
    ),
  ],
);

GuidanceDraftMutationResult _draftResult(
  SaveGuidanceDraftCommand command, {
  required int revision,
}) => GuidanceDraftMutationResult(
  draft: GuidanceDraft(
    id: command.draftId,
    exerciseId: command.exerciseId,
    userId: testUserId,
    content: command.content,
    revision: revision,
    createdAt: DateTime.utc(2026, 8, 8),
    updatedAt: DateTime.utc(2026, 8, 8),
  ),
  replayed: false,
  correlationId: '60000000-0000-4000-8000-000000000002',
);

Future<void> _waitFor(bool Function() predicate) async {
  for (var attempt = 0; attempt < 200; attempt += 1) {
    if (predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  throw StateError('Timed out waiting for asynchronous controller state.');
}

final class _ThrowingCache implements DashboardGuidanceDraftCache {
  @override
  Future<int> cleanConfirmedForUser(String userId, DateTime now) =>
      Future<int>.error(StateError('storage unavailable'));

  @override
  Future<void> clearForUser(String userId) async {}

  @override
  Future<DashboardGuidanceCacheWriteResult> compareAndSwap({
    required DashboardGuidanceRecoveryRecord record,
    required int? expectedLocalRevision,
  }) => Future<DashboardGuidanceCacheWriteResult>.error(StateError('storage unavailable'));

  @override
  Future<DashboardGuidanceRecoveryRecord?> read(DashboardGuidanceRecoveryKey key) =>
      Future<DashboardGuidanceRecoveryRecord?>.error(StateError('corrupt record'));

  @override
  Future<void> remove(DashboardGuidanceRecoveryKey key) async {}
}
