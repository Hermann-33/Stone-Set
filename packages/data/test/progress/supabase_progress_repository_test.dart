import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/progress.dart';
import 'package:stone_set_domain/progress.dart';

void main() {
  test('decodes authoritative progress snapshot', () async {
    final repository = SupabaseProgressRepository(
      _FakeProgressRemoteService(),
    );

    final value = await repository.getProgress();

    expect(value.account.rankId, 'platinum_ii');
    expect(value.account.rrBalance, 1910);
    expect(value.account.lifetimeXp, 4860);
    expect(value.account.progress, closeTo(0.45, 0.0001));
    expect(value.ranks, hasLength(2));
    expect(value.transactions.single.delta, 20);
    expect(value.workouts.single.status, WorkoutHistoryStatus.completed);
  });

  test('invalid shape fails decoding', () async {
    final repository = SupabaseProgressRepository(
      _FakeProgressRemoteService(
        response: <String, Object?>{'account': 'invalid'},
      ),
    );

    await expectLater(repository.getProgress(), throwsA(isA<FormatException>()));
  });
}

final class _FakeProgressRemoteService implements ProgressRemoteService {
  _FakeProgressRemoteService({Map<String, Object?>? response})
    : response = response ?? _response;

  final Map<String, Object?> response;

  @override
  Future<Map<String, Object?>> getProgress() async => response;
}

final _response = <String, Object?>{
  'account': <String, Object?>{
    'userId': '00000000-0000-4000-8000-000000000001',
    'rrBalance': 1910,
    'lifetimeXp': 4860,
    'rankId': 'platinum_ii',
    'currentMinimum': 1775,
    'nextRankId': 'platinum_iii',
    'nextMinimum': 2075,
    'progress': 0.45,
  },
  'ranks': <Object?>[
    <String, Object?>{
      'id': 'platinum_ii',
      'displayName': 'Platinum II',
      'minimumRr': 1775,
    },
    <String, Object?>{
      'id': 'platinum_iii',
      'displayName': 'Platinum III',
      'minimumRr': 2075,
    },
  ],
  'transactions': <Object?>[
    <String, Object?>{
      'id': '10000000-0000-4000-8000-000000000001',
      'kind': 'rr',
      'sourceType': 'workout_reward',
      'sourceId': '20000000-0000-4000-8000-000000000001',
      'delta': 20,
      'createdAt': '2026-08-10T02:00:00.000Z',
    },
  ],
  'workouts': <Object?>[
    <String, Object?>{
      'resultId': '30000000-0000-4000-8000-000000000001',
      'planItemId': '40000000-0000-4000-8000-000000000001',
      'date': '2026-08-10',
      'status': 'completed',
      'plannedSets': 12,
      'completedSets': 12,
      'submittedAt': '2026-08-10T02:00:00.000Z',
    },
  ],
};
