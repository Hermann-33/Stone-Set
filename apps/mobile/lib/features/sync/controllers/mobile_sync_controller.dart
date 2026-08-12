import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_domain/progress.dart';
import 'package:stone_set_domain/scheduling.dart';
import 'package:stone_set_domain/workouts.dart';

import '../../identity/controllers/mobile_session_controller.dart';
import '../../local/data/mobile_snapshot_codec.dart';
import '../../local/providers/mobile_local_providers.dart';
import '../providers/mobile_sync_dependencies.dart';

final mobileSyncControllerProvider =
    NotifierProvider<MobileSyncController, MobileSyncState>(
      MobileSyncController.new,
    );

enum MobileSyncTrigger {
  startup,
  resume,
  manualRefresh,
  workoutCompletion,
  retry,
}

final class MobileSyncState {
  const MobileSyncState({
    this.ownerId,
    this.generationId,
    this.isRunning = false,
    this.lastSuccessfulSyncAt,
    this.lastAttemptAt,
    this.lastFailureCode,
    this.pendingMutationCount = 0,
  });

  final String? ownerId;
  final String? generationId;
  final bool isRunning;
  final DateTime? lastSuccessfulSyncAt;
  final DateTime? lastAttemptAt;
  final String? lastFailureCode;
  final int pendingMutationCount;

  bool get isStale => lastFailureCode != null || lastSuccessfulSyncAt == null;

  MobileSyncState copyWith({
    String? ownerId,
    String? generationId,
    bool? isRunning,
    DateTime? lastSuccessfulSyncAt,
    DateTime? lastAttemptAt,
    String? lastFailureCode,
    bool clearFailure = false,
    int? pendingMutationCount,
  }) => MobileSyncState(
    ownerId: ownerId ?? this.ownerId,
    generationId: generationId ?? this.generationId,
    isRunning: isRunning ?? this.isRunning,
    lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
    lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    lastFailureCode: clearFailure
        ? null
        : (lastFailureCode ?? this.lastFailureCode),
    pendingMutationCount: pendingMutationCount ?? this.pendingMutationCount,
  );
}

final class MobileSyncController extends Notifier<MobileSyncState> {
  Future<bool>? _inFlight;

  @override
  MobileSyncState build() => const MobileSyncState();

  Future<void> initializeForOwner(String ownerId) async {
    if (state.ownerId == ownerId && state.lastAttemptAt != null) {
      return;
    }
    final metadata = await ref
        .read(mobileSnapshotStoreProvider)
        .loadSyncMetadata(ownerId);
    final pending = await _pendingMutationCount(ownerId);
    state = MobileSyncState(
      ownerId: ownerId,
      generationId: metadata?.generationId,
      lastSuccessfulSyncAt: metadata?.lastSuccessfulSyncAt,
      lastAttemptAt: metadata?.lastAttemptAt,
      lastFailureCode: metadata?.lastErrorCode,
      pendingMutationCount: pending,
    );
  }

  Future<bool> synchronize({
    MobileSyncTrigger trigger = MobileSyncTrigger.manualRefresh,
  }) {
    final running = _inFlight;
    if (running != null) return running;
    final future = _synchronize(trigger);
    _inFlight = future;
    return future.whenComplete(() {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    });
  }

  Future<bool> _synchronize(MobileSyncTrigger trigger) async {
    final session = ref.read(mobileSessionControllerProvider).value;
    final ownerId = session?.userId;
    if (ownerId == null ||
        session?.phase != IdentitySessionPhase.authenticated) {
      return false;
    }
    if (state.ownerId != ownerId) {
      await initializeForOwner(ownerId);
    }
    final attemptedAt = DateTime.now().toUtc();
    state = state.copyWith(isRunning: true, lastAttemptAt: attemptedAt);
    try {
      await ref
          .read(mobileSessionControllerProvider.notifier)
          .foregroundRevalidate();
      final revalidated = ref.read(mobileSessionControllerProvider).value;
      if (revalidated?.phase != IdentitySessionPhase.authenticated ||
          revalidated?.userId != ownerId) {
        throw const IdentityFailure(IdentityErrorCode.sessionExpired);
      }

      final local = ref.read(mobileSyncWorkoutLocalStoreProvider);
      final active = await local.loadActive(ownerId);
      if (active?.pendingSync ?? false) {
        await ref
            .read(mobileSyncWorkoutControllerProvider)
            .sync(userId: ownerId);
      }

      final week = await ref
          .read(mobileSyncSchedulingRepositoryProvider)
          .getOrCreateCurrentWeek();
      final progress = await ref
          .read(mobileSyncProgressRepositoryProvider)
          .getProgress();
      validateWeekOwner(ownerId, week);
      validateProgressOwner(ownerId, progress);

      final synchronizedAt = DateTime.now().toUtc();
      final generationId = await ref
          .read(mobileSnapshotStoreProvider)
          .commitSynchronizedSnapshots(
            ownerId: ownerId,
            week: week,
            progress: progress,
            synchronizedAt: synchronizedAt,
          );
      final pending = await _pendingMutationCount(ownerId);
      state = MobileSyncState(
        ownerId: ownerId,
        generationId: generationId,
        lastSuccessfulSyncAt: synchronizedAt,
        lastAttemptAt: synchronizedAt,
        pendingMutationCount: pending,
      );
      return true;
    } on Object catch (error) {
      final errorCode = _errorCode(error);
      await ref
          .read(mobileSnapshotStoreProvider)
          .recordSyncFailure(
            ownerId: ownerId,
            attemptedAt: attemptedAt,
            errorCode: errorCode,
          );
      state = state.copyWith(
        isRunning: false,
        lastAttemptAt: attemptedAt,
        lastFailureCode: errorCode,
        pendingMutationCount: await _pendingMutationCount(ownerId),
      );
      return false;
    } finally {
      if (state.isRunning) {
        state = state.copyWith(isRunning: false);
      }
    }
  }

  Future<int> _pendingMutationCount(String ownerId) async {
    try {
      final active = await ref
          .read(mobileSyncWorkoutLocalStoreProvider)
          .loadActive(ownerId);
      return active?.pendingSync ?? false ? 1 : 0;
    } on Object {
      return 0;
    }
  }
}

String _errorCode(Object error) => switch (error) {
  IdentityFailure failure => failure.code.name,
  SchedulingFailure failure => failure.code,
  ProgressFailure failure => failure.code,
  WorkoutFailure failure => failure.code,
  FormatException _ => 'invalid_server_payload',
  _ => 'network_unavailable',
};
