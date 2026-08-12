import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/workouts.dart';
import 'package:stone_set_mobile/features/workout/controllers/workout_controller.dart';

import '../support/fake_workout_local_store.dart';
import '../support/fake_workout_repository.dart';

void main() {
  test('starts online once then restores local workout', () async {
    final remote = FakeWorkoutRepository();
    final local = FakeWorkoutLocalStore();
    final controller = WorkoutController(remote: remote, local: local);

    final first = await controller.loadOrStart(
      userId: FakeWorkoutRepository.userId,
      planItemId: FakeWorkoutRepository.planItemId,
    );
    final restored = await controller.loadOrStart(
      userId: FakeWorkoutRepository.userId,
      planItemId: FakeWorkoutRepository.planItemId,
    );

    expect(first.session.id, FakeWorkoutRepository.sessionId);
    expect(restored.session.id, first.session.id);
    expect(local.draft, isNotNull);
  });

  test('set edit remains local when sync fails', () async {
    final remote = FakeWorkoutRepository(failSync: true);
    final local = FakeWorkoutLocalStore();
    final controller = WorkoutController(remote: remote, local: local);
    await controller.loadOrStart(
      userId: FakeWorkoutRepository.userId,
      planItemId: FakeWorkoutRepository.planItemId,
    );

    final edited = await controller.saveSet(
      userId: FakeWorkoutRepository.userId,
      set: local.draft!.sets.first.copyWith(
        loadValue: 80,
        repetitions: 10,
        rir: 2,
        completed: true,
      ),
    );
    expect(edited.pendingSync, isTrue);

    await expectLater(
      controller.sync(userId: FakeWorkoutRepository.userId),
      throwsA(isA<WorkoutFailure>()),
    );
    expect(local.draft!.sets.first.completed, isTrue);
    expect(local.draft!.pendingSync, isTrue);
  });

  test('successful sync clears pending state', () async {
    final remote = FakeWorkoutRepository();
    final local = FakeWorkoutLocalStore();
    final controller = WorkoutController(remote: remote, local: local);
    await controller.loadOrStart(
      userId: FakeWorkoutRepository.userId,
      planItemId: FakeWorkoutRepository.planItemId,
    );
    await controller.saveSet(
      userId: FakeWorkoutRepository.userId,
      set: local.draft!.sets.first.copyWith(completed: true),
    );

    final synced = await controller.sync(userId: FakeWorkoutRepository.userId);

    expect(synced.pendingSync, isFalse);
    expect(remote.syncCalls, 1);
  });

  test('submit clears local draft then invokes authoritative read refresh', () async {
    final remote = FakeWorkoutRepository();
    final local = FakeWorkoutLocalStore();
    var refreshCalls = 0;
    String? refreshedOwner;
    final controller = WorkoutController(
      remote: remote,
      local: local,
      afterSubmit: (userId) async {
        refreshCalls += 1;
        refreshedOwner = userId;
        expect(local.draft, isNull);
      },
    );
    await controller.loadOrStart(
      userId: FakeWorkoutRepository.userId,
      planItemId: FakeWorkoutRepository.planItemId,
    );
    await controller.saveSet(
      userId: FakeWorkoutRepository.userId,
      set: local.draft!.sets.first.copyWith(completed: true),
    );

    final submitted = await controller.submit(
      userId: FakeWorkoutRepository.userId,
    );

    expect(submitted.result!.status, WorkoutResultStatus.partial);
    expect(local.draft, isNull);
    expect(remote.submitCalls, 1);
    expect(refreshCalls, 1);
    expect(refreshedOwner, FakeWorkoutRepository.userId);
  });

  test('post-submit refresh failure cannot undo accepted server submission', () async {
    final remote = FakeWorkoutRepository();
    final local = FakeWorkoutLocalStore();
    final controller = WorkoutController(
      remote: remote,
      local: local,
      afterSubmit: (_) async => throw StateError('offline again'),
    );
    await controller.loadOrStart(
      userId: FakeWorkoutRepository.userId,
      planItemId: FakeWorkoutRepository.planItemId,
    );

    final submitted = await controller.submit(
      userId: FakeWorkoutRepository.userId,
    );

    expect(submitted.result, isNotNull);
    expect(remote.submitCalls, 1);
    expect(local.draft, isNull);
  });
}
