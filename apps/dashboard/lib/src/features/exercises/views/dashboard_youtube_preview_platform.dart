import 'package:flutter/widgets.dart';

abstract interface class DashboardYouTubePreviewPlatform {
  Widget build({
    required String videoId,
    required int? startSeconds,
    required VoidCallback onPlayable,
    required ValueChanged<String> onError,
  });
}
