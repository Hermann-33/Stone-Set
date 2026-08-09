import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'dashboard_youtube_preview_platform.dart';

DashboardYouTubePreviewPlatform createDashboardYouTubePreviewPlatform() =>
    const _WebYouTubePreviewPlatform();

final class _WebYouTubePreviewPlatform implements DashboardYouTubePreviewPlatform {
  const _WebYouTubePreviewPlatform();

  @override
  Widget build({
    required String videoId,
    required int? startSeconds,
    required VoidCallback onPlayable,
    required ValueChanged<String> onError,
  }) => _YouTubeHtmlView(
    videoId: videoId,
    startSeconds: startSeconds,
    onPlayable: onPlayable,
    onError: onError,
  );
}

class _YouTubeHtmlView extends StatefulWidget {
  const _YouTubeHtmlView({
    required this.videoId,
    required this.startSeconds,
    required this.onPlayable,
    required this.onError,
  });

  final String videoId;
  final int? startSeconds;
  final VoidCallback onPlayable;
  final ValueChanged<String> onError;

  @override
  State<_YouTubeHtmlView> createState() => _YouTubeHtmlViewState();
}

class _YouTubeHtmlViewState extends State<_YouTubeHtmlView> {
  static var _nextViewId = 0;
  late final String _viewType;
  _YouTubePlayer? _player;
  bool _disposed = false;
  JSFunction? _visibilityListener;

  @override
  void initState() {
    super.initState();
    _viewType = 'stone-set-youtube-preview-${_nextViewId++}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (_) {
      final host = web.HTMLDivElement()
        ..id = _viewType
        ..style.width = '100%'
        ..style.height = '100%';
      unawaited(_initialize(host));
      return host;
    });
  }

  Future<void> _initialize(web.HTMLDivElement host) async {
    try {
      await _YouTubeApiLoader.load();
      if (_disposed) return;
      final playerVars = _PlayerVars(
        autoplay: 0,
        controls: 1,
        playsinline: 1,
        enablejsapi: 1,
        origin: web.window.location.origin,
        start: widget.startSeconds ?? 0,
      );
      final events = _PlayerEvents(
        onReady: ((JSAny _) {}).toJS,
        onStateChange: ((JSAny event) {
          final stateValue = (event as JSObject)['data']?.dartify();
          if (!_disposed && (stateValue == 1 || stateValue == 5)) {
            widget.onPlayable();
          }
        }).toJS,
        onError: ((JSAny _) {
          if (!_disposed) {
            widget.onError('YouTube could not play this video. Try the external link.');
          }
        }).toJS,
      );
      _player = _YouTubePlayer(
        host,
        _PlayerOptions(
          videoId: widget.videoId,
          host: 'https://www.youtube-nocookie.com',
          playerVars: playerVars,
          events: events,
        ),
      );
      _visibilityListener = ((web.Event _) {
        if (web.document.hidden) _player?.pauseVideo();
      }).toJS;
      web.document.addEventListener('visibilitychange', _visibilityListener);
    } on Object {
      if (!_disposed) {
        widget.onError('YouTube preview could not initialize. Check the connection and retry.');
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    final visibilityListener = _visibilityListener;
    if (visibilityListener != null) {
      web.document.removeEventListener('visibilitychange', visibilityListener);
      _visibilityListener = null;
    }
    _player?.destroy();
    _player = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}

abstract final class _YouTubeApiLoader {
  static Future<void>? _loading;

  static Future<void> load() => _loading ??= _load();

  static Future<void> _load() async {
    if (globalContext.has('YT') && globalContext['YT'].isA<JSObject>()) return;
    final completer = Completer<void>();
    globalContext['onYouTubeIframeAPIReady'] = (() {
      if (!completer.isCompleted) completer.complete();
    }).toJS;
    final script = web.HTMLScriptElement()
      ..src = 'https://www.youtube.com/iframe_api'
      ..async = true;
    script.onerror = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('YouTube IFrame API failed to load.'));
      }
    }).toJS;
    web.document.head?.append(script);
    await completer.future.timeout(const Duration(seconds: 12));
  }
}

@JS('YT.Player')
extension type _YouTubePlayer._(JSObject _) implements JSObject {
  external factory _YouTubePlayer(web.Element element, _PlayerOptions options);
  external void destroy();
  external void pauseVideo();
}

@JS()
@anonymous
extension type _PlayerOptions._(JSObject _) implements JSObject {
  external factory _PlayerOptions({
    String videoId,
    String host,
    _PlayerVars playerVars,
    _PlayerEvents events,
  });
}

@JS()
@anonymous
extension type _PlayerVars._(JSObject _) implements JSObject {
  external factory _PlayerVars({
    int autoplay,
    int controls,
    int playsinline,
    int enablejsapi,
    String origin,
    int start,
  });
}

@JS()
@anonymous
extension type _PlayerEvents._(JSObject _) implements JSObject {
  external factory _PlayerEvents({
    JSFunction onReady,
    JSFunction onStateChange,
    JSFunction onError,
  });
}
