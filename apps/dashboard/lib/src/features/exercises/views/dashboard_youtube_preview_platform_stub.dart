import 'package:flutter/material.dart';

import 'dashboard_youtube_preview_platform.dart';

DashboardYouTubePreviewPlatform createDashboardYouTubePreviewPlatform() =>
    const _UnsupportedYouTubePreviewPlatform();

final class _UnsupportedYouTubePreviewPlatform implements DashboardYouTubePreviewPlatform {
  const _UnsupportedYouTubePreviewPlatform();

  @override
  Widget build({
    required String videoId,
    required int? startSeconds,
    required VoidCallback onPlayable,
    required ValueChanged<String> onError,
  }) => _UnsupportedPreview(onError: onError);
}

class _UnsupportedPreview extends StatefulWidget {
  const _UnsupportedPreview({required this.onError});

  final ValueChanged<String> onError;

  @override
  State<_UnsupportedPreview> createState() => _UnsupportedPreviewState();
}

class _UnsupportedPreviewState extends State<_UnsupportedPreview> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onError('YouTube preview is available only in the Web dashboard.');
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
