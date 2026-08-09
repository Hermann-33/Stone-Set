import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_dashboard/src/features/exercises/views/dashboard_youtube_preview.dart';

void main() {
  testWidgets('does not create the platform player before explicit activation', (tester) async {
    final platform = _FakeYouTubePlatform();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardYouTubePreview(
            videoId: 'dQw4w9WgXcQ',
            canonicalWatchUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            platform: platform,
          ),
        ),
      ),
    );

    expect(platform.buildCount, 0);
    expect(find.textContaining('not loaded'), findsOneWidget);

    await tester.tap(find.byKey(const Key('youtube-load-preview')));
    await tester.pump();

    expect(platform.buildCount, 1);
    expect(find.text('Loading YouTube preview…'), findsOneWidget);
  });

  testWidgets('announces ready and error recovery states with external fallback', (tester) async {
    final platform = _FakeYouTubePlatform();
    var validated = false;
    var invalidated = false;
    var externalOpenCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardYouTubePreview(
            videoId: 'dQw4w9WgXcQ',
            canonicalWatchUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            platform: platform,
            onValidated: () => validated = true,
            onInvalidated: () => invalidated = true,
            onOpenExternal: () => externalOpenCount += 1,
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('youtube-load-preview')));
    await tester.pump();
    platform.playable!();
    await tester.pump();
    expect(validated, isTrue);
    expect(find.text('YouTube preview ready.'), findsOneWidget);

    platform.error!('Embedding is unavailable. Open the video in YouTube.');
    await tester.pump();
    expect(invalidated, isTrue);
    expect(find.byKey(const Key('youtube-retry-preview')), findsOneWidget);
    await tester.tap(find.byKey(const Key('youtube-open-external')));
    expect(externalOpenCount, 1);
  });
}

final class _FakeYouTubePlatform implements DashboardYouTubePreviewPlatform {
  int buildCount = 0;
  VoidCallback? playable;
  ValueChanged<String>? error;

  @override
  Widget build({
    required String videoId,
    required int? startSeconds,
    required VoidCallback onPlayable,
    required ValueChanged<String> onError,
  }) {
    buildCount += 1;
    playable = onPlayable;
    error = onError;
    return const ColoredBox(color: Colors.black);
  }
}
