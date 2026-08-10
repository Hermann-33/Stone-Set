import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_domain/exercise_media.dart';
import 'package:stone_set_domain/workouts.dart';
import 'package:stone_set_mobile/features/workout/guidance/workout_guidance_loader.dart';

final class FakeWorkoutGuidanceLoader implements WorkoutGuidanceLoader {
  FakeWorkoutGuidanceLoader({WorkoutGuidanceBundle? bundle})
    : bundle = bundle ?? standardWorkoutGuidanceBundle();

  final WorkoutGuidanceBundle bundle;
  int calls = 0;
  WorkoutExercise? lastExercise;

  @override
  Future<WorkoutGuidanceBundle> load(WorkoutExercise exercise) async {
    calls += 1;
    lastExercise = exercise;
    return bundle;
  }
}

WorkoutGuidanceBundle standardWorkoutGuidanceBundle() {
  final now = DateTime.utc(2026, 8, 10, 10);
  final image = GuidanceImageAsset(
    id: 'image-1',
    ownerId: 'user-1',
    exerciseId: 'exercise-1',
    guidanceRevisionId: 'guidance-1',
    bucketId: GuidanceMediaManifest.bucketId,
    objectPath: 'user-1/exercise-1/revisions/guidance-1/image-1.webp',
    mimeType: GuidanceMediaMimeType.webp,
    byteSize: 1024,
    width: 800,
    height: 600,
    sha256Hex: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    altText: 'Bench press setup',
    position: 1,
    isCover: true,
    lifecycle: GuidanceMediaLifecycle.published,
    createdAt: now,
    updatedAt: now,
  );
  final guidance = GuidanceRevision(
    id: 'guidance-1',
    exerciseId: 'exercise-1',
    userId: 'user-1',
    versionNumber: 3,
    content: GuidanceContentV1(
      shortExplanation: 'Keep the bar path controlled.',
      setupSteps: const <String>['Plant your feet.', 'Set the shoulder blades.'],
      executionSteps: const <String>['Lower under control.', 'Press to lockout.'],
      techniqueCues: const <String>['Keep wrists stacked.'],
      commonMistakes: const <String>['Do not bounce the bar.'],
      safetyNotes: const <String>['Use safeties when training alone.'],
    ),
    canonicalName: 'Bench Press',
    variantKey: null,
    equipmentKeys: const <String>['barbell'],
    muscles: const <ExerciseMuscleSelection>[],
    contentHash: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
    revisionHash: 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
    publishedAt: now,
  );
  final youtube = GuidanceYouTubeReference(
    videoId: 'dQw4w9WgXcQ',
    canonicalWatchUrl: Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
    validationStatus: YouTubeValidationStatus.validated,
    startSeconds: 15,
    titleSnapshot: 'Bench press walkthrough',
    validatedAt: now,
  );
  return WorkoutGuidanceBundle(
    guidance: guidance,
    media: GuidanceMediaManifest(
      exerciseId: 'exercise-1',
      ownerId: 'user-1',
      guidanceRevisionId: 'guidance-1',
      mediaRevision: 1,
      images: <GuidanceImageAsset>[image],
      youtube: youtube,
    ),
    images: <WorkoutGuidanceImage>[
      WorkoutGuidanceImage(
        asset: image,
        url: Uri.parse('https://example.invalid/signed/image-1.webp'),
      ),
    ],
  );
}
