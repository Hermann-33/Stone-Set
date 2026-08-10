import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stone_set_domain/exercise_media.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WorkoutYouTubePlayer extends StatefulWidget {
  const WorkoutYouTubePlayer({required this.reference, super.key});

  final GuidanceYouTubeReference reference;

  @override
  State<WorkoutYouTubePlayer> createState() => _WorkoutYouTubePlayerState();
}

class _WorkoutYouTubePlayerState extends State<WorkoutYouTubePlayer> {
  WebViewController? _controller;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _createController();
    }
  }

  void _createController() {
    final controller = WebViewController();
    unawaited(controller.setJavaScriptMode(JavaScriptMode.unrestricted));
    unawaited(controller.setBackgroundColor(Colors.black));
    unawaited(
      controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _loading = true;
                _failed = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() {
                _loading = false;
                _failed = true;
              });
            }
          },
        ),
      ),
    );
    unawaited(controller.loadRequest(_embedUri(widget.reference)));
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.ondemand_video_outlined),
          title: Text('YouTube playback is available on Android.'),
        ),
      );
    }
    if (_failed) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.error_outline),
          title: const Text('Video could not be loaded.'),
          trailing: TextButton(
            onPressed: () {
              setState(() {
                _failed = false;
                _loading = true;
              });
              final controller = _controller;
              if (controller != null) {
                unawaited(controller.loadRequest(_embedUri(widget.reference)));
              }
            },
            child: const Text('Retry'),
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      return const SizedBox(
        height: 210,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: WebViewWidget(controller: controller)),
          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black12,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

Uri _embedUri(GuidanceYouTubeReference reference) {
  final query = <String, String>{
    'autoplay': '0',
    'playsinline': '1',
    if ((reference.startSeconds ?? 0) > 0) 'start': reference.startSeconds.toString(),
  };
  return Uri.https(
    'www.youtube-nocookie.com',
    '/embed/${reference.videoId}',
    query,
  );
}
