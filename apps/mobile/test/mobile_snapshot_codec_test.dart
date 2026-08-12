import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_mobile/features/local/data/mobile_snapshot_codec.dart';

import 'support/fake_identity_repository.dart';
import 'support/fake_progress_repository.dart';
import 'support/fake_scheduling_repository.dart';

void main() {
  test('identity bootstrap round-trips without changing owner eligibility', () {
    final source = syntheticBootstrap();

    final decoded = decodeIdentityBootstrap(encodeIdentityBootstrap(source));

    expect(decoded.profile.userId, source.profile.userId);
    expect(decoded.profile.normalizedUsername, source.profile.normalizedUsername);
    expect(decoded.profile.mustChangePassword, isFalse);
    expect(decoded.compatibility.clientCompatible, isTrue);
    expect(decoded.serverTime, source.serverTime);
    expect(() => validateIdentityOwner(syntheticUserId, decoded), returnsNormally);
  });

  test('Week round-trip preserves materialized calendar dates and owner', () {
    final source = standardWeek();

    final decoded = decodeWeekLoadResult(encodeWeekLoadResult(source));

    expect(decoded.status, source.status);
    expect(decoded.wallet.userId, syntheticUserId);
    expect(decoded.week?.userId, syntheticUserId);
    expect(decoded.week?.weekStart, source.week?.weekStart);
    expect(decoded.week?.weekEnd, source.week?.weekEnd);
    expect(decoded.week?.items.first.currentDate, source.week?.items.first.currentDate);
    expect(decoded.week?.scheduleConfigVersion, 'schedule-v3');
    expect(() => validateWeekOwner(syntheticUserId, decoded), returnsNormally);
  });

  test('Progress round-trip preserves authoritative rank and finalized history', () {
    final decoded = decodeProgressSnapshot(encodeProgressSnapshot(defaultProgressSnapshot));

    expect(decoded.account.userId, syntheticUserId);
    expect(decoded.account.rrBalance, defaultProgressSnapshot.account.rrBalance);
    expect(decoded.account.rankId, defaultProgressSnapshot.account.rankId);
    expect(decoded.account.activeConsistencyMultiplier, 1);
    expect(decoded.transactions.single.delta, 20);
    expect(decoded.workouts.single.resultId, defaultProgressSnapshot.workouts.single.resultId);
    expect(() => validateProgressOwner(syntheticUserId, decoded), returnsNormally);
  });

  test('owner validation rejects cross-account cached payloads', () {
    const otherOwner = '00000000-0000-4000-8000-000000000099';

    expect(
      () => validateIdentityOwner(otherOwner, syntheticBootstrap()),
      throwsFormatException,
    );
    expect(() => validateWeekOwner(otherOwner, standardWeek()), throwsFormatException);
    expect(
      () => validateProgressOwner(otherOwner, defaultProgressSnapshot),
      throwsFormatException,
    );
  });
}
