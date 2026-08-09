import 'dart:convert';

import '../exercise_guidance/exercise_guidance_canonicalizer.dart';
import 'exercise_media_models.dart';

final class ExerciseMediaCanonicalizer {
  const ExerciseMediaCanonicalizer({required UnicodeNormalizer unicodeNormalizer})
    // This public constructor label intentionally maps to a private dependency.
    // ignore: prefer_initializing_formals
    : _unicodeNormalizer = unicodeNormalizer;

  final UnicodeNormalizer _unicodeNormalizer;

  List<Object?> manifestArray(GuidanceMediaManifest manifest) {
    final images = List<GuidanceImageAsset>.of(manifest.images)
      ..sort((left, right) => left.position.compareTo(right.position));
    return <Object?>[
      'stone-set-guidance-media-manifest-v1',
      images
          .map(
            (image) => <Object?>[
              image.id,
              image.bucketId,
              image.objectPath,
              image.mimeType.wireValue,
              image.byteSize,
              image.width,
              image.height,
              image.sha256Hex,
              _normalizeText(image.altText),
              image.position,
              image.isCover,
            ],
          )
          .toList(growable: false),
      _youtubeArray(manifest.youtube),
    ];
  }

  String manifestJsonbText(GuidanceMediaManifest manifest) =>
      canonicalJsonbText(manifestArray(manifest));

  String manifestHash(GuidanceMediaManifest manifest) =>
      sha256Hex(utf8.encode(manifestJsonbText(manifest)));

  List<Object?> bundleArray({
    required String guidanceRevisionHash,
    required String manifestHash,
  }) => <Object?>[
    'stone-set-guidance-bundle-v1',
    guidanceRevisionHash,
    manifestHash,
  ];

  String bundleJsonbText({
    required String guidanceRevisionHash,
    required String manifestHash,
  }) => canonicalJsonbText(
    bundleArray(guidanceRevisionHash: guidanceRevisionHash, manifestHash: manifestHash),
  );

  String bundleHash({
    required String guidanceRevisionHash,
    required String manifestHash,
  }) => sha256Hex(
    utf8.encode(
      bundleJsonbText(
        guidanceRevisionHash: guidanceRevisionHash,
        manifestHash: manifestHash,
      ),
    ),
  );

  List<Object?>? _youtubeArray(GuidanceYouTubeReference? youtube) {
    if (youtube == null) {
      return null;
    }
    return <Object?>[
      GuidanceYouTubeReference.provider,
      youtube.videoId,
      youtube.canonicalWatchUrl.toString(),
      youtube.startSeconds,
      youtube.titleSnapshot == null ? null : _normalizeText(youtube.titleSnapshot!),
      youtube.thumbnailUrlSnapshot?.toString(),
      youtube.validatedAt == null ? null : _canonicalUtc(youtube.validatedAt!),
    ];
  }

  String _normalizeText(String value) => _unicodeNormalizer.normalizeNfc(value).trim();

  String _canonicalUtc(DateTime value) {
    final utc = value.toUtc();
    String two(int part) => part.toString().padLeft(2, '0');
    final fraction = (utc.millisecond * 1000 + utc.microsecond).toString().padLeft(6, '0');
    return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-${two(utc.day)}T'
        '${two(utc.hour)}:${two(utc.minute)}:${two(utc.second)}.${fraction}Z';
  }
}
