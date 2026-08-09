import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_domain/exercise_media.dart';
import 'package:test/test.dart';

void main() {
  const assetHash = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
  const revisionHash = '1111111111111111111111111111111111111111111111111111111111111111';
  const manifestHash = '2222222222222222222222222222222222222222222222222222222222222222';
  const canonicalizer = ExerciseMediaCanonicalizer(
    unicodeNormalizer: AlreadyNormalizedUnicodeNormalizer(),
  );

  test('empty manifest has an exact canonical vector', () {
    final manifest = GuidanceMediaManifest(
      exerciseId: 'exercise-1',
      ownerId: 'owner-1',
      draftId: 'draft-1',
      mediaRevision: 0,
      images: const [],
      youtube: null,
    );

    expect(
      canonicalizer.manifestJsonbText(manifest),
      '["stone-set-guidance-media-manifest-v1", [], null]',
    );
    expect(
      canonicalizer.manifestHash(manifest),
      '6801a668fbd147909ee9500438dafca67256967730b112ec770639593b366fc1',
    );
  });

  test('image and YouTube evidence is ordered and canonicalized exactly', () {
    final manifest = GuidanceMediaManifest(
      exerciseId: 'exercise-1',
      ownerId: 'owner-1',
      mediaRevision: 4,
      images: [
        _image(id: 'image-b', position: 1, isCover: false),
        _image(id: 'image-a', position: 0, isCover: true),
      ],
      youtube: GuidanceYouTubeReference(
        videoId: 'AbC_12-xYz9',
        canonicalWatchUrl: Uri.parse('https://www.youtube.com/watch?v=AbC_12-xYz9'),
        startSeconds: 90,
        titleSnapshot: '  Safe title  ',
        thumbnailUrlSnapshot: Uri.parse('https://i.ytimg.com/vi/AbC_12-xYz9/hqdefault.jpg'),
        validationStatus: YouTubeValidationStatus.validated,
        validatedAt: DateTime.parse('2026-08-08T01:02:03.004005Z'),
      ),
    );

    expect(
      canonicalizer.manifestJsonbText(manifest),
      '["stone-set-guidance-media-manifest-v1", '
      '[["image-a", "exercise-media", "owner/exercise/drafts/draft/image-a.webp", '
      '"image/webp", 100, 640, 480, "$assetHash", "Alt image-a", 0, true], '
      '["image-b", "exercise-media", "owner/exercise/drafts/draft/image-b.webp", '
      '"image/webp", 100, 640, 480, "$assetHash", "Alt image-b", 1, false]], '
      '["youtube", "AbC_12-xYz9", "https://www.youtube.com/watch?v=AbC_12-xYz9", '
      '90, "Safe title", "https://i.ytimg.com/vi/AbC_12-xYz9/hqdefault.jpg", '
      '"2026-08-08T01:02:03.004005Z"]]',
    );
  });

  test('bundle has an exact canonical vector and immutable image snapshot', () {
    final source = <GuidanceImageAsset>[_image(id: 'image-a', position: 0, isCover: true)];
    final manifest = GuidanceMediaManifest(
      exerciseId: 'exercise-1',
      ownerId: 'owner-1',
      mediaRevision: 1,
      images: source,
      youtube: null,
    );
    source.clear();
    expect(manifest.images, hasLength(1));
    expect(
      canonicalizer.bundleJsonbText(
        guidanceRevisionHash: revisionHash,
        manifestHash: manifestHash,
      ),
      '["stone-set-guidance-bundle-v1", "$revisionHash", "$manifestHash"]',
    );
    expect(
      canonicalizer.bundleHash(
        guidanceRevisionHash: revisionHash,
        manifestHash: manifestHash,
      ),
      'e0e75e701d5061f532825a33eac0e5640f8c332d005cde36974db2ab521e457b',
    );
  });

  test('matches the SQL fixed-UTC YouTube manifest and bundle vectors', () {
    final manifest = GuidanceMediaManifest(
      exerciseId: 'exercise-1',
      ownerId: 'owner-1',
      mediaRevision: 1,
      images: const [],
      youtube: GuidanceYouTubeReference(
        videoId: 'dQw4w9WgXcQ',
        canonicalWatchUrl: Uri.parse(
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        startSeconds: 30,
        thumbnailUrlSnapshot: Uri.parse(
          'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
        ),
        validationStatus: YouTubeValidationStatus.validated,
        validatedAt: DateTime.parse('2026-08-08T01:02:03.004005Z'),
      ),
    );

    const sqlManifestHash = '098895820f77af9654b3c10dbd7d184047ab70bfb723a7fc9ac25c9668018670';
    expect(canonicalizer.manifestHash(manifest), sqlManifestHash);
    expect(
      canonicalizer.bundleHash(
        guidanceRevisionHash: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        manifestHash: sqlManifestHash,
      ),
      '130a7e445de63c7aa7fb46332a12606a4f4b346688a63fcfe61dcca441c8c269',
    );
  });
}

GuidanceImageAsset _image({
  required String id,
  required int position,
  required bool isCover,
}) => GuidanceImageAsset(
  id: id,
  ownerId: 'owner-1',
  exerciseId: 'exercise-1',
  draftId: 'draft-1',
  bucketId: GuidanceMediaManifest.bucketId,
  objectPath: 'owner/exercise/drafts/draft/$id.webp',
  mimeType: GuidanceMediaMimeType.webp,
  byteSize: 100,
  width: 640,
  height: 480,
  sha256Hex: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  altText: 'Alt $id',
  position: position,
  isCover: isCover,
  lifecycle: GuidanceMediaLifecycle.ready,
  createdAt: DateTime.parse('2026-08-08T00:00:00Z'),
  updatedAt: DateTime.parse('2026-08-08T00:00:00Z'),
);
