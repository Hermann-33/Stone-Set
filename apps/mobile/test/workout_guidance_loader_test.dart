import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_domain/exercise_media.dart';
import 'package:stone_set_domain/workouts.dart';
import 'package:stone_set_mobile/features/workout/guidance/workout_guidance_loader.dart';

void main() {
  test(
    'loads the exact guidance revision pinned by the workout snapshot',
    () async {
      final guidance = _FakeGuidanceReadRepository(<String, GuidanceRevision>{
        _revisionV1: _revision(
          id: _revisionV1,
          version: 1,
          explanation: 'Version one',
        ),
        _revisionV2: _revision(
          id: _revisionV2,
          version: 2,
          explanation: 'Version two',
        ),
      });
      final media = _FakeMediaReadRepository(<String, GuidanceMediaManifest>{
        _revisionV1: _manifest(_revisionV1),
        _revisionV2: _manifest(_revisionV2),
      });
      final loader = RepositoryWorkoutGuidanceLoader(
        guidanceRepository: guidance,
        mediaRepository: media,
      );

      final firstWorkout = await loader.load(_exercise(_revisionV1));

      expect(firstWorkout.guidance.id, _revisionV1);
      expect(firstWorkout.guidance.versionNumber, 1);
      expect(firstWorkout.guidance.content.shortExplanation, 'Version one');
      expect(guidance.requestedRevisionIds, <String>[_revisionV1]);
      expect(media.requestedRevisionIds, <String>[_revisionV1]);

      final nextWorkout = await loader.load(_exercise(_revisionV2));

      expect(nextWorkout.guidance.id, _revisionV2);
      expect(nextWorkout.guidance.versionNumber, 2);
      expect(nextWorkout.guidance.content.shortExplanation, 'Version two');
      expect(guidance.requestedRevisionIds, <String>[_revisionV1, _revisionV2]);
      expect(media.requestedRevisionIds, <String>[_revisionV1, _revisionV2]);
    },
  );

  test(
    'rejects guidance or media that does not match the pinned snapshot',
    () async {
      final guidance = _FakeGuidanceReadRepository(<String, GuidanceRevision>{
        _revisionV1: _revision(
          id: _revisionV2,
          version: 2,
          explanation: 'Wrong revision',
        ),
      });
      final media = _FakeMediaReadRepository(<String, GuidanceMediaManifest>{
        _revisionV1: _manifest(_revisionV1),
      });
      final loader = RepositoryWorkoutGuidanceLoader(
        guidanceRepository: guidance,
        mediaRepository: media,
      );

      await expectLater(
        loader.load(_exercise(_revisionV1)),
        throwsA(
          isA<WorkoutGuidanceFailure>().having(
            (failure) => failure.code,
            'code',
            'guidance_unavailable',
          ),
        ),
      );
    },
  );
}

const _exerciseId = '20000000-0000-4000-8000-000000000001';
const _ownerId = '00000000-0000-4000-8000-000000000001';
const _revisionV1 = '50000000-0000-4000-8000-000000000001';
const _revisionV2 = '50000000-0000-4000-8000-000000000002';

WorkoutExercise _exercise(String guidanceRevisionId) => WorkoutExercise(
  id: '60000000-0000-4000-8000-000000000001',
  position: 0,
  exerciseDefinitionId: _exerciseId,
  guidanceRevisionId: guidanceRevisionId,
  title: 'Guidance activation squat',
  priority: false,
  workingSets: 3,
  repMin: 8,
  repMax: 10,
  rirTarget: 2,
  restSeconds: 120,
  loadUnit: 'kg',
  notes: '',
);

GuidanceRevision _revision({
  required String id,
  required int version,
  required String explanation,
}) => GuidanceRevision(
  id: id,
  exerciseId: _exerciseId,
  userId: _ownerId,
  versionNumber: version,
  content: GuidanceContentV1(
    shortExplanation: explanation,
    setupSteps: const <String>['Set up safely'],
    executionSteps: const <String>['Move with control'],
  ),
  canonicalName: 'Guidance activation squat',
  variantKey: null,
  equipmentKeys: const <String>['none'],
  muscles: const <ExerciseMuscleSelection>[],
  contentHash:
      '${version}000000000000000000000000000000000000000000000000000000000000000',
  revisionHash:
      '${version}111111111111111111111111111111111111111111111111111111111111111',
  publishedAt: DateTime.utc(2026, 8, 17, version),
);

GuidanceMediaManifest _manifest(String guidanceRevisionId) =>
    GuidanceMediaManifest(
      exerciseId: _exerciseId,
      ownerId: _ownerId,
      guidanceRevisionId: guidanceRevisionId,
      guidanceRevisionHash: '2' * 64,
      mediaRevision: 1,
      images: const <GuidanceImageAsset>[],
      youtube: null,
      manifestHash: '3' * 64,
      bundleHash: '4' * 64,
    );

final class _FakeGuidanceReadRepository
    implements ExerciseGuidanceReadRepository {
  _FakeGuidanceReadRepository(this.revisions);

  final Map<String, GuidanceRevision> revisions;
  final List<String> requestedRevisionIds = <String>[];

  @override
  Future<GuidanceRevision> getGuidanceRevision(
    String exerciseId,
    String revisionId,
  ) async {
    expect(exerciseId, _exerciseId);
    requestedRevisionIds.add(revisionId);
    return revisions[revisionId]!;
  }

  @override
  Future<ExerciseDefinition> getExercise(String exerciseId) =>
      throw UnsupportedError('Loader must not fetch mutable exercise state.');

  @override
  Future<List<Muscle>> listMuscles() =>
      throw UnsupportedError('Loader must not fetch muscle catalog state.');
}

final class _FakeMediaReadRepository implements ExerciseMediaReadRepository {
  _FakeMediaReadRepository(this.manifests);

  final Map<String, GuidanceMediaManifest> manifests;
  final List<String> requestedRevisionIds = <String>[];

  @override
  Future<GuidanceMediaManifest> getRevisionManifest(
    String exerciseId,
    String guidanceRevisionId,
  ) async {
    expect(exerciseId, _exerciseId);
    requestedRevisionIds.add(guidanceRevisionId);
    return manifests[guidanceRevisionId]!;
  }

  @override
  Future<MediaAccessUrl> createImageAccessUrl(
    GuidanceImageAsset asset, {
    Duration lifetime = const Duration(minutes: 5),
  }) async => MediaAccessUrl(
    url: Uri.https('local.invalid', '/image'),
    expiresAt: DateTime.utc(2026, 8, 17).add(lifetime),
  );
}
