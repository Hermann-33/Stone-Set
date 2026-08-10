import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_domain/exercise_media.dart';
import 'package:stone_set_domain/workouts.dart';

final class WorkoutGuidanceImage {
  const WorkoutGuidanceImage({required this.asset, required this.url});

  final GuidanceImageAsset asset;
  final Uri url;
}

final class WorkoutGuidanceBundle {
  const WorkoutGuidanceBundle({
    required this.guidance,
    required this.media,
    required this.images,
  });

  final GuidanceRevision guidance;
  final GuidanceMediaManifest media;
  final List<WorkoutGuidanceImage> images;
}

final class WorkoutGuidanceFailure implements Exception {
  const WorkoutGuidanceFailure(this.code);

  final String code;

  @override
  String toString() => 'WorkoutGuidanceFailure($code)';
}

abstract interface class WorkoutGuidanceLoader {
  Future<WorkoutGuidanceBundle> load(WorkoutExercise exercise);
}

final class RepositoryWorkoutGuidanceLoader implements WorkoutGuidanceLoader {
  const RepositoryWorkoutGuidanceLoader({
    required this.guidanceRepository,
    required this.mediaRepository,
  });

  final ExerciseGuidanceReadRepository guidanceRepository;
  final ExerciseMediaReadRepository mediaRepository;

  @override
  Future<WorkoutGuidanceBundle> load(WorkoutExercise exercise) async {
    try {
      final values = await Future.wait<Object>(<Future<Object>>[
        guidanceRepository.getGuidanceRevision(
          exercise.exerciseDefinitionId,
          exercise.guidanceRevisionId,
        ),
        mediaRepository.getRevisionManifest(
          exercise.exerciseDefinitionId,
          exercise.guidanceRevisionId,
        ),
      ]);
      final guidance = values[0] as GuidanceRevision;
      final media = values[1] as GuidanceMediaManifest;
      if (guidance.id != exercise.guidanceRevisionId ||
          guidance.exerciseId != exercise.exerciseDefinitionId ||
          media.exerciseId != exercise.exerciseDefinitionId ||
          media.guidanceRevisionId != exercise.guidanceRevisionId) {
        throw const FormatException('Pinned guidance/media response mismatch.');
      }

      final assets = [...media.images]
        ..sort((a, b) {
          if (a.isCover != b.isCover) return a.isCover ? -1 : 1;
          final byPosition = a.position.compareTo(b.position);
          return byPosition != 0 ? byPosition : a.id.compareTo(b.id);
        });
      final images = <WorkoutGuidanceImage>[];
      for (final asset in assets) {
        final access = await mediaRepository.createImageAccessUrl(asset);
        images.add(WorkoutGuidanceImage(asset: asset, url: access.url));
      }
      return WorkoutGuidanceBundle(
        guidance: guidance,
        media: media,
        images: List<WorkoutGuidanceImage>.unmodifiable(images),
      );
    } on WorkoutGuidanceFailure {
      rethrow;
    } on Object catch (_) {
      throw const WorkoutGuidanceFailure('guidance_unavailable');
    }
  }
}
