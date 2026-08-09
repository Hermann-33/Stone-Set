import 'package:stone_set_domain/exercise_media.dart';
import 'package:test/test.dart';

void main() {
  const normalizer = YouTubeReferenceNormalizer();
  const videoId = 'AbC_12-xYz9';

  test('normalizes supported single-video forms without changing video ID case', () {
    final cases = <String, int?>{
      'https://www.youtube.com/watch?v=$videoId': null,
      'https://youtu.be/$videoId?t=90': 90,
      'https://youtube.com/shorts/$videoId?start=1m30s': 90,
      'https://www.youtube.com/embed/$videoId?t=1h2m3s': 3723,
      'https://www.youtube-nocookie.com/embed/$videoId?start=86400': 86400,
    };

    for (final entry in cases.entries) {
      final result = normalizer.parse(entry.key);
      expect(result.videoId, videoId);
      expect(result.startSeconds, entry.value);
      expect(result.canonicalWatchUrl.host, 'www.youtube.com');
      expect(result.canonicalWatchUrl.queryParameters['v'], videoId);
    }
  });

  test('accepts one non-semantic share token and strips it', () {
    final result = normalizer.parse('https://youtu.be/$videoId?si=tracking-token&t=4');

    expect(result.startSeconds, 4);
    expect(result.canonicalWatchUrl.toString(), 'https://www.youtube.com/watch?v=$videoId');
  });

  test('rejects deceptive, playlist, ambiguous, and unsupported URLs', () {
    final rejected = <String>[
      'http://youtu.be/$videoId',
      'https://youtube.com.evil.test/watch?v=$videoId',
      'https://user@youtube.com/watch?v=$videoId',
      'https://youtube.com/watch?v=$videoId#fragment',
      'https://youtube.com/playlist?list=PL123',
      'https://youtube.com/watch?v=$videoId&list=PL123',
      'https://youtube.com/watch?v=$videoId&index=2',
      'https://youtube.com/watch?v=$videoId&feature=share',
      'https://youtube.com/watch?v=$videoId&v=01234567890',
      'https://youtu.be/$videoId?t=2&start=3',
      'https://youtu.be/$videoId?si=a&si=b',
      'https://youtube.com/watch?v=too-short',
      'https://youtube.com/watch?v=$videoId&t=86401',
      'https://www.youtube-nocookie.com/watch?v=$videoId',
      'https://www.youtube-nocookie.com/shorts/$videoId',
    ];

    for (final input in rejected) {
      expect(() => normalizer.parse(input), throwsFormatException, reason: input);
    }
  });
}
