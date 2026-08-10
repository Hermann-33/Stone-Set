import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/routines.dart';
import 'package:stone_set_domain/routines.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('decodes owner routine list', () async {
    final repository = SupabaseRoutineRepository(remote: _FakeRemote());
    final items = await repository.listRoutines();
    expect(items.single.name, 'Strength');
    expect(items.single.status, RoutineDraftStatus.draft);
  });

  test('save sends optimistic revision and exact seven-day payload', () async {
    final remote = _FakeRemote();
    final repository = SupabaseRoutineRepository(remote: remote);
    final draft = await repository.getDraft(_FakeRemote.draftId);
    final result = await repository.saveDraft(
      SaveRoutineDraftCommand(draft: draft, expectedRevision: 1, idempotencyKey: _FakeRemote.key),
    );
    final save = remote.calls.singleWhere((call) => call.$1 == 'save_routine_draft_v1');
    expect(save.$2['p_expected_revision'], 1);
    expect((save.$2['p_days']! as List<Object?>), hasLength(7));
    expect(result.value.revision, 1);
  });

  test('publishes a validated draft directly without submission or review', () async {
    final remote = _FakeRemote();
    final repository = SupabaseRoutineRepository(remote: remote);
    final published = await repository.publishDraft(
      _FakeRemote.draftId,
      1,
      _FakeRemote.key,
    );
    final call = remote.calls.singleWhere((call) => call.$1 == 'publish_routine_draft_v1');
    expect(call.$2['p_routine_draft_id'], _FakeRemote.draftId);
    expect(call.$2['p_expected_revision'], 1);
    expect(published.value.versionNumber, 1);
    expect(published.value.routineDraftId, _FakeRemote.draftId);
    expect(
      remote.calls.where((call) => call.$1.contains('submission') || call.$1.contains('review')),
      isEmpty,
    );
  });

  test('maps stale revision evidence without leaking server detail', () async {
    final remote = _FakeRemote(throwStaleSave: true);
    final repository = SupabaseRoutineRepository(remote: remote);
    final draft = await repository.getDraft(_FakeRemote.draftId);
    await expectLater(
      repository.saveDraft(
        SaveRoutineDraftCommand(
          draft: draft,
          expectedRevision: 1,
          idempotencyKey: _FakeRemote.key,
        ),
      ),
      throwsA(
        isA<RoutineFailure>()
            .having((failure) => failure.code, 'code', 'stale_revision')
            .having((failure) => failure.currentRevision, 'currentRevision', 4),
      ),
    );
  });
}

final class _FakeRemote implements RoutineRemoteService {
  _FakeRemote({this.throwStaleSave = false});

  static const draftId = '00000000-0000-4000-8000-000000000001';
  static const ownerId = '00000000-0000-4000-8000-000000000002';
  static const key = '00000000-0000-4000-8000-000000000003';
  static const versionId = '00000000-0000-4000-8000-000000000005';
  final bool throwStaleSave;
  String? lastFunction;
  Map<String, Object?> lastParams = const <String, Object?>{};
  final calls = <(String, Map<String, Object?>)>[];

  @override
  Future<Map<String, Object?>> call(String function, Map<String, Object?> params) async {
    lastFunction = function;
    lastParams = params;
    calls.add((function, params));
    if (function == 'list_my_routines_v1') {
      return <String, Object?>{
        'items': <Object?>[_summary()],
      };
    }
    if (function == 'get_routine_draft_v1') return <String, Object?>{'item': _draft()};
    if (function == 'save_routine_draft_v1') {
      if (throwStaleSave) {
        throw const PostgrestException(
          message: 'routine_draft_revision_conflict',
          code: '40001',
          details:
              '{"correlationId":"00000000-0000-4000-8000-000000000099","routineDraftRevision":4}',
        );
      }
      return <String, Object?>{
        'operation': function,
        'replayed': false,
        'correlationId': key,
        'routineDraftId': draftId,
      };
    }
    if (function == 'publish_routine_draft_v1') {
      return _mutation(<String, Object?>{
        'routineDraftId': draftId,
        'routineVersionId': versionId,
      });
    }
    if (function == 'get_routine_version_v1') return _version();
    throw UnsupportedError(function);
  }

  Map<String, Object?> _mutation(Map<String, Object?> values) => <String, Object?>{
    'operation': lastFunction,
    'replayed': false,
    'correlationId': key,
    ...values,
  };

  Map<String, Object?> _summary() => <String, Object?>{
    'id': draftId,
    'name': 'Strength',
    'status': 'draft',
    'revision': 1,
    'updatedAt': '2026-08-09T00:00:00Z',
  };

  Map<String, Object?> _draft() => <String, Object?>{
    ..._summary(),
    'ownerId': ownerId,
    'description': 'Seven day plan',
    'createdAt': '2026-08-09T00:00:00Z',
    'days': <Object?>[
      for (var index = 1; index <= 7; index += 1)
        <String, Object?>{
          'id': 'day-$index',
          'dayIndex': index,
          'kind': index <= 5 ? 'workout' : 'rest',
          'title': 'Day $index',
          'purpose': null,
          'prescriptions': const <Object?>[],
        },
    ],
  };

  Map<String, Object?> _version() => <String, Object?>{
    'id': versionId,
    'routineDraftId': draftId,
    'ownerId': ownerId,
    'versionNumber': 1,
    'name': 'Strength',
    'description': 'Seven day plan',
    'days': const <Object?>[],
    'contentHash': 'abc123',
    'publishedAt': '2026-08-10T00:00:00Z',
    'effectiveDate': '2026-08-10',
  };
}
