import 'package:flutter/material.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import 'dashboard_youtube_preview_platform.dart';
import 'dashboard_youtube_preview_platform_stub.dart'
    if (dart.library.js_interop) 'dashboard_youtube_preview_platform_web.dart';
export 'dashboard_youtube_preview_platform.dart';

enum DashboardYouTubePreviewState { idle, loading, ready, unavailable }

class DashboardYouTubePreview extends StatefulWidget {
  const DashboardYouTubePreview({
    super.key,
    required this.videoId,
    required this.canonicalWatchUrl,
    this.startSeconds,
    this.onValidated,
    this.onInvalidated,
    this.onOpenExternal,
    this.platform,
  });

  final String videoId;
  final String canonicalWatchUrl;
  final int? startSeconds;
  final VoidCallback? onValidated;
  final VoidCallback? onInvalidated;
  final VoidCallback? onOpenExternal;
  final DashboardYouTubePreviewPlatform? platform;

  @override
  State<DashboardYouTubePreview> createState() => _DashboardYouTubePreviewState();
}

class _DashboardYouTubePreviewState extends State<DashboardYouTubePreview> {
  DashboardYouTubePreviewState _state = DashboardYouTubePreviewState.idle;
  String? _error;
  bool _wasPlayable = false;

  DashboardYouTubePreviewPlatform get _platform =>
      widget.platform ?? createDashboardYouTubePreviewPlatform();

  @override
  void didUpdateWidget(covariant DashboardYouTubePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId || oldWidget.startSeconds != widget.startSeconds) {
      _state = DashboardYouTubePreviewState.idle;
      _error = null;
      _wasPlayable = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveMessage = switch (_state) {
      DashboardYouTubePreviewState.idle =>
        'YouTube preview is not loaded. YouTube is contacted only after activation.',
      DashboardYouTubePreviewState.loading => 'Loading YouTube preview…',
      DashboardYouTubePreviewState.ready => 'YouTube preview ready.',
      DashboardYouTubePreviewState.unavailable =>
        _error ?? 'YouTube preview is unavailable. Open the video in YouTube instead.',
    };
    return Semantics(
      container: true,
      liveRegion: _state != DashboardYouTubePreviewState.idle,
      label: liveMessage,
      child: StoneSetCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text('YouTube Preview', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: StoneSetSpacing.xs),
            Text(liveMessage, style: StoneSetTextStyles.of(context).compactBody),
            const SizedBox(height: StoneSetSpacing.md),
            if (_state == DashboardYouTubePreviewState.idle)
              FilledButton.icon(
                key: const Key('youtube-load-preview'),
                onPressed: () => setState(() => _state = DashboardYouTubePreviewState.loading),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Load YouTube Preview'),
              )
            else if (_state == DashboardYouTubePreviewState.loading ||
                _state == DashboardYouTubePreviewState.ready)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200, minHeight: 200),
                  child: _platform.build(
                    videoId: widget.videoId,
                    startSeconds: widget.startSeconds,
                    onPlayable: () {
                      if (!mounted) return;
                      setState(() {
                        _state = DashboardYouTubePreviewState.ready;
                        _error = null;
                        _wasPlayable = true;
                      });
                      widget.onValidated?.call();
                    },
                    onError: (message) {
                      if (!mounted) return;
                      final invalidate = _wasPlayable;
                      setState(() {
                        _state = DashboardYouTubePreviewState.unavailable;
                        _error = message;
                        _wasPlayable = false;
                      });
                      if (invalidate) widget.onInvalidated?.call();
                    },
                  ),
                ),
              ),
            if (_state == DashboardYouTubePreviewState.unavailable) ...<Widget>[
              FilledButton.icon(
                key: const Key('youtube-retry-preview'),
                onPressed: () => setState(() {
                  _state = DashboardYouTubePreviewState.loading;
                  _error = null;
                }),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Preview'),
              ),
              const SizedBox(height: StoneSetSpacing.xs),
            ],
            if (_state != DashboardYouTubePreviewState.idle)
              OutlinedButton.icon(
                key: const Key('youtube-open-external'),
                onPressed: widget.onOpenExternal,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in YouTube'),
              ),
          ],
        ),
      ),
    );
  }
}
