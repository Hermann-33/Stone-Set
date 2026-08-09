import 'exercise_media_models.dart';

final class YouTubeReferenceNormalizer {
  const YouTubeReferenceNormalizer();

  static final RegExp _videoId = RegExp(r'^[A-Za-z0-9_-]{11}$');
  static final RegExp _timePart = RegExp(r'(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?$');
  static const maximumStartSeconds = 86400;

  GuidanceYouTubeReference parse(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment ||
        uri.hasPort) {
      throw const FormatException('YouTube URL is not supported.');
    }
    final host = uri.host.toLowerCase();
    final segments = uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
    final String? candidate;
    if (host == 'youtu.be') {
      _validateQuery(uri, allowed: const {'t', 'start', 'si'});
      candidate = segments.length == 1 ? segments.single : null;
    } else if (_isYouTubeHost(host)) {
      candidate = _candidateFromYouTubePath(uri, segments);
    } else {
      throw const FormatException('YouTube URL host is not supported.');
    }
    if (candidate == null || !_videoId.hasMatch(candidate)) {
      throw const FormatException('YouTube URL must identify one video.');
    }
    final startSeconds = _parseStart(uri);
    return GuidanceYouTubeReference(
      videoId: candidate,
      canonicalWatchUrl: Uri.https('www.youtube.com', '/watch', <String, String>{
        'v': candidate,
      }),
      startSeconds: startSeconds,
      validationStatus: YouTubeValidationStatus.previewRequired,
    );
  }

  bool _isYouTubeHost(String host) =>
      host == 'youtube.com' ||
      host == 'www.youtube.com' ||
      host == 'm.youtube.com' ||
      host == 'www.youtube-nocookie.com' ||
      host == 'youtube-nocookie.com';

  String? _candidateFromYouTubePath(Uri uri, List<String> segments) {
    if (segments.length == 1 && segments.single == 'watch') {
      if (uri.host.toLowerCase().contains('youtube-nocookie.com')) {
        return null;
      }
      _validateQuery(uri, allowed: const {'v', 't', 'start', 'si'});
      final values = uri.queryParametersAll['v'] ?? const <String>[];
      return values.length == 1 ? values.single : null;
    }
    if (segments.length == 2 && (segments.first == 'shorts' || segments.first == 'embed')) {
      if (segments.first == 'shorts' && uri.host.toLowerCase().contains('youtube-nocookie.com')) {
        return null;
      }
      _validateQuery(uri, allowed: const {'t', 'start', 'si'});
      return segments.last;
    }
    return null;
  }

  void _validateQuery(Uri uri, {required Set<String> allowed}) {
    for (final entry in uri.queryParametersAll.entries) {
      if (!allowed.contains(entry.key) || entry.value.length != 1 || entry.value.single.isEmpty) {
        throw const FormatException('YouTube URL query is not supported.');
      }
    }
    // `si` is a non-semantic YouTube share token. It is accepted once and
    // deliberately stripped from the canonical URL.
    if ((uri.queryParametersAll['si']?.length ?? 0) > 1) {
      throw const FormatException('YouTube share token is ambiguous.');
    }
  }

  int? _parseStart(Uri uri) {
    final values = <String>[
      ...?uri.queryParametersAll['start'],
      ...?uri.queryParametersAll['t'],
    ];
    if (values.isEmpty) {
      return null;
    }
    if (values.length != 1) {
      throw const FormatException('YouTube start time is ambiguous.');
    }
    final raw = values.single;
    final integer = int.tryParse(raw);
    final seconds = integer ?? _parseDuration(raw);
    if (seconds == null || seconds < 0 || seconds > maximumStartSeconds) {
      throw const FormatException('YouTube start time is out of bounds.');
    }
    return seconds;
  }

  int? _parseDuration(String value) {
    final match = _timePart.firstMatch(value);
    if (match == null || match.group(0) != value || value.isEmpty) {
      return null;
    }
    final hours = int.tryParse(match.group(1) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '') ?? 0;
    return hours * 3600 + minutes * 60 + seconds;
  }
}
