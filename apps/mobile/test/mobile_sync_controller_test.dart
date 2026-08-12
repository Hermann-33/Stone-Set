import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_domain/scheduling.dart';
import 'package:stone_set_domain/workouts.dart';
import 'package:stone_set_mobile/features/identity/controllers/mobile_session_controller.dart';
import 'package:stone_set_mobile/features/identity/providers/identity_providers.dart';
import 'package:stone_set_mobile/features/local/data/mobile_snapshot_store.dart';
import 'package:stone_set_mobile/features/local/providers/mobile_local_providers.dart';
import 'package:stone_set_mobile/features/sync/controllers/mobile_sync_controller.dart';
import 'package:stone_set_mobile/features/sync/providers/mobile_sync_dependencies.dart';
import 'package:stone_set_mobile/features/workout/controllers/workout_controller.dart';

import 'support/fake_identity_repository.dart';
import 'support/fake_mobile_snapshot_store.dart';
import 'support/fake_progress_repository.dart';
import 'support/fake_scheduling_repository.dart';
import 'support/fake_workout_local_store.dart';
import 'support/fake_workout_repository.dart';

void main() {
  test('pending workout sync runs before authoritative Week and Progress reads', () async {
    final calls = <String>[];
    final identity = FakeIdentityRepository(
      initialSession: const IdentitySession(userId: syntheticUserId, expiresAt: null),
    );
    final local = FakeWorkoutLocalStore();
    final workoutDelegate = FakeWorkoutRepository();
    await local.saveStarted(userId: syntheticUserId, session: workoutDelegate.session());
    await local.saveSet(
      userId: syntheticUserId,
      set: workoutDelegate.session().sets.first.copyWith(completed: true),
    );
    final store = FakeMobileSnapshotStore();
    final container = ProviderContainer(
      overrides: [
        identityRepositoryProvider.overrideWithValue(identity),
        mobileSnapshotStoreProvider.overrideWithValue(store),
        unsynchronizedPrivateWorkProvider.overrideWithValue(const NoUnsynchronizedPrivateWork()),
        mobileSyncWorkoutLocalStoreProvider.overrideWithValue(local),
        mobileSyncWorkoutControllerProvider.overrideWithValue(
          WorkoutController(
            remote: _RecordingWorkoutRepository(workoutDelegate, calls),
            local: local,
          ),
        ),
        mobileSyncSchedulingRepositoryProvider.overrideWithValue(
          _RecordingSchedulingRepository(calls),
        ),
        mobileSyncProgressRepositoryProvider.overrideWithValue(
          _RecordingProgressRepository(calls),
        ),
      ],
    );
    addTearDown(identity.close);
    addTearDown(container.dispose);
    await container.read(mobileSessionControllerProvider.future);

    final synchronized = await container
        .read(mobileSyncControllerProvider.notifier)
        .synchronize(trigger: MobileSyncTrigger.manualRefresh);

    expect(synchronized, isTrue);
    expect(calls, <String>['workout-sync', 'week', 'progress']);
    expect(store.weekByOwner[syntheticUserId]?.week?.userId, syntheticUserId);
    expect(store.progressByOwner[syntheticUserId]?.account.userId, syntheticUserId);
    expect(store.metadataByOwner[syntheticUserId]?.generationId, isNotNull);
    expect(store.metadataByOwner[syntheticUserId]?.lastErrorCode, isNull);
    expect(
      container.read(mobileSyncControllerProvider).pendingMutationCount,
      0,
    );
  });

  test('failed refresh preserves the previously committed cached generation', () async {
    final identity = FakeIdentityRepository(
      initialSession: const IdentitySession(userId: syntheticUserId, expiresAt: null),
    );
    final store = FakeMobileSnapshotStore()
      ..weekByOwner[syntheticUserId] = standardWeek()
      ..progressByOwner[syntheticUserId] = defaultProgressSnapshot
      ..metadataByOwner[syntheticUserId] = MobileSyncMetadata(
        ownerId: syntheticUserId,
        generationId: 'previous-generation',
        lastSuccessfulSyncAt: DateTime.utc(2026, 8, 12, 10),
      );
    final container = ProviderContainer(
      overrides: [
        identityRepositoryProvider.overrideWithValue(identity),
        mobileSnapshotStoreProvider.overrideWithValue(store),
        unsynchronizedPrivateWorkProvider.overrideWithValue(const NoUnsynchronizedPrivateWork()),
        mobileSyncWorkoutLocalStoreProvider.overrideWithValue(FakeWorkoutLocalStore()),
        mobileSyncSchedulingRepositoryProvider.overrideWithValue(FakeSchedulingRepository()),
        mobileSyncProgressRepositoryProvider.overrideWithValue(_FailingProgressRepository()),
      ],
    );
    addTearDown(identity.close);
    addTearDown(container.dispose);
    await container.read(mobileSessionControllerProvider.future);

    final synchronized = await container
        .read(mobileSyncControllerProvider.notifier)
        .synchronize(trigger: MobileSyncTrigger.manualRefresh);

    expect(synchronized, isFalse);
    expect(store.metadataByOwner[syntheticUserId]?.generationId, 'previous-generation');
    expect(store.metadataByOwner[syntheticUserId]?.lastErrorCode, 'network_unavailable');
    expect(store.progressByOwner[syntheticUserId]?.account.rrBalance, 1910);
    expect(store.weekByOwner[syntheticUserId]?.week?.scheduleConfigVersion, 'schedule-v3');
  });
}

final class _RecordingSchedulingRepository implements SchedulingRepository {
  _RecordingSchedulingRepository(this.calls);

  final List<String> calls;

  @override
  Future<WeekLoadResult> getOrCreateCurrentWeek() async {
    calls.add('week');
    return standardWeek();
  }

  @override
  Future<SwapResult> confirmSwap({
    required String weekId,
    required String firstItemId,
    required String secondItemId,
  }) => throw UnimplementedError();
}

final class _RecordingProgressRepository implements ProgressRepository {
  _RecordingProgressRepository(this.calls);

  final List<String> calls;

  @override
  Future<ProgressSnapshot> getProgress() async {
    calls.add('progress');
    return defaultProgressSnapshot;
  }
}

final class _FailingProgressRepository implements ProgressRepository {
  @override
  Future<ProgressSnapshot> getProgress() =>
      throw const ProgressFailure('network_unavailable');
}

final class _RecordingWorkoutRepository implements WorkoutRepository {
  _RecordingWorkoutRepository(this.delegate, this.calls);

  final FakeWorkoutRepository delegate;
  final List<String> calls;

  @override
  Future<WorkoutLoadResult> startWorkout({required String planItemId}) =>
      delegate.startWorkout(planItemId: planItemId);

  @override
  Future<WorkoutLoadResult> syncWorkout({
    required String sessionId,
    required int clientRevision,
    required List<WorkoutSetDraft> sets,
  }) {
    calls.add('workout-sync');
    return delegate.syncWorkout(
      sessionId: sessionId,
      clientRevision: clientRevision,
      sets: sets,
    );
  }

  @override
  Future<WorkoutLoadResult> submitWorkout({
    required String sessionId,
    required int clientRevision,
    required List<WorkoutSetDraft> sets,
  }) => delegate.submitWorkout(
    sessionId: sessionId,
    clientRevision: clientRevision,
    sets: sets,
  );
}
