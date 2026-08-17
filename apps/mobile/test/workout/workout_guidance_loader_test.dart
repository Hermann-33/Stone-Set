import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_domain/exercise_media.dart';
import 'package:stone_set_domain/workouts.dart';
import 'package:stone_set_mobile/features/workout/guidance/workout_guidance_loader.dart';

import '../support/fake_workout_guidance_loader.dart';

void main() {
  test('loads exact pinned guidance/media and signs revision images', () async {
    final fixture = standardWorkoutGuidanceBundle();
    final guidance = _GuidanceRead(fixture.guidance);
    final media = _MediaRead(fixture.media);
    final loader = RepositoryWorkoutGuidanceLoader(
      guidanceRepository: guidance,
      mediaRepository: media,
    );

    final result = await loader.load(_exercise);

    expect(guidance.exerciseId, 'exercise-1');
    expect(guidance.revisionId, 'guidance-1');
    expect(media.exerciseId, 'exercise-1');
    expect(media.revisionId, 'guidance-1');
    expect(media.signedAssetIds, <String>['image-1']);
    expect(result.guidance.id, 'guidance-1');
    expect(result.images.single.url.host, 'signed.example.invalid');
  });

  test(
    'loads a newer revision only when the workout snapshot pins it',
    () async {
      final fixture = standardWorkoutGuidanceBundle();
      final newerGuidance = GuidanceRevision(
        id: 'guidance-2',
        exerciseId: fixture.guidance.exerciseId,
        userId: fixture.guidance.userId,
        versionNumber: fixture.guidance.versionNumber + 1,
        content: fixture.guidance.content,
        canonicalName: fixture.guidance.canonicalName,
        variantKey: fixture.guidance.variantKey,
        equipmentKeys: fixture.guidance.equipmentKeys,
        muscles: fixture.guidance.muscles,
        contentHash: fixture.guidance.contentHash,
        revisionHash: fixture.guidance.revisionHash,
        publishedAt: fixture.guidance.publishedAt.add(
          const Duration(minutes: 1),
        ),
      );
      final newerMedia = GuidanceMediaManifest(
        exerciseId: fixture.media.exerciseId,
        ownerId: fixture.media.ownerId,
        guidanceRevisionId: 'guidance-2',
        mediaRevision: fixture.media.mediaRevision + 1,
        images: const <GuidanceImageAsset>[],
        youtube: null,
      );
      final guidance = _GuidanceRead(newerGuidance);
      final media = _MediaRead(newerMedia);
      final loader = RepositoryWorkoutGuidanceLoader(
        guidanceRepository: guidance,
        mediaRepository: media,
      );

      final result = await loader.load(_newerExercise);

      expect(guidance.revisionId, 'guidance-2');
      expect(media.revisionId, 'guidance-2');
      expect(result.guidance.id, 'guidance-2');
      expect(result.media.guidanceRevisionId, 'guidance-2');
    },
  );

  test('rejects guidance that does not match the workout pin', () async {
    final fixture = standardWorkoutGuidanceBundle();
    final mismatchedGuidance = GuidanceRevision(
      id: 'wrong-guidance',
      exerciseId: fixture.guidance.exerciseId,
      userId: fixture.guidance.userId,
      versionNumber: fixture.guidance.versionNumber,
      content: fixture.guidance.content,
      canonicalName: fixture.guidance.canonicalName,
      variantKey: fixture.guidance.variantKey,
      equipmentKeys: fixture.guidance.equipmentKeys,
      muscles: fixture.guidance.muscles,
      contentHash: fixture.guidance.contentHash,
      revisionHash: fixture.guidance.revisionHash,
      publishedAt: fixture.guidance.publishedAt,
    );
    final loader = RepositoryWorkoutGuidanceLoader(
      guidanceRepository: _GuidanceRead(mismatchedGuidance),
      mediaRepository: _MediaRead(fixture.media),
    );

    await expectLater(
      loader.load(_exercise),
      throwsA(
        isA<WorkoutGuidanceFailure>().having(
          (error) => error.code,
          'code',
          'guidance_unavailable',
        ),
      ),
    );
  });
}

const _exercise = WorkoutExercise(
  id: 'session-exercise-1',
  position: 1,
  exerciseDefinitionId: 'exercise-1',
  guidanceRevisionId: 'guidance-1',
  title: 'Bench Press',
  priority: false,
  workingSets: 3,
  repMin: 8,
  repMax: 10,
  rirTarget: 2,
  restSeconds: 120,
  loadUnit: 'kg',
  notes: '',
);

const _newerExercise = WorkoutExercise(
  id: 'session-exercise-2',
  position: 1,
  exerciseDefinitionId: 'exercise-1',
  guidanceRevisionId: 'guidance-2',
  title: 'Bench Press',
  priority: false,
  workingSets: 3,
  repMin: 8,
  repMax: 10,
  rirTarget: 2,
  restSeconds: 120,
  loadUnit: 'kg',
  notes: '',
);

final class _GuidanceRead implements ExerciseGuidanceReadRepository {
  _GuidanceRead(this.revision);

  final GuidanceRevision revision;
  String? exerciseId;
  String? revisionId;

  @override
  Future<GuidanceRevision> getGuidanceRevision(
    String exerciseId,
    String revisionId,
  ) async {
    this.exerciseId = exerciseId;
    this.revisionId = revisionId;
    return revision;
  }

  @override
  Future<ExerciseDefinition> getExercise(String exerciseId) =>
      throw UnsupportedError('not needed');

  @override
  Future<List<Muscle>> listMuscles() => throw UnsupportedError('not needed');
}

final class _MediaRead implements ExerciseMediaReadRepository {
  _MediaRead(this.manifest);

  final GuidanceMediaManifest manifest;
  String? exerciseId;
  String? revisionId;
  final List<String> signedAssetIds = <String>[];

  @override
  Future<GuidanceMediaManifest> getRevisionManifest(
    String exerciseId,
    String guidanceRevisionId,
  ) async {
    this.exerciseId = exerciseId;
    revisionId = guidanceRevisionId;
    return manifest;
  }

  @override
  Future<MediaAccessUrl> createImageAccessUrl(
    GuidanceImageAsset asset, {
    Duration lifetime = const Duration(minutes: 5),
  }) async {
    signedAssetIds.add(asset.id);
    return MediaAccessUrl(
      url: Uri.parse('https://signed.example.invalid/${asset.id}'),
      expiresAt: DateTime.utc(2026, 8, 10, 10, 5),
    );
  }
}
