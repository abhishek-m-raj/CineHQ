import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video/video.dart' hide VideoPlayer;

class OfficialPlayerStream implements PlayerStream {
  final Stream<Duration> _position;
  final Stream<Duration> _duration;
  final Stream<bool> _playing;
  final Stream<bool> _buffering;
  final Stream<double> _volume;
  final Stream<double> _rate;
  final Stream<Tracks> _tracks;
  final Stream<dynamic> _error;
  final Stream<bool> _completed;
  final Stream<Duration> _buffer;
  final Stream<String?> _subtitleText;

  OfficialPlayerStream({
    required Stream<Duration> position,
    required Stream<Duration> duration,
    required Stream<bool> playing,
    required Stream<bool> buffering,
    required Stream<double> volume,
    required Stream<double> rate,
    required Stream<Tracks> tracks,
    required Stream<dynamic> error,
    required Stream<bool> completed,
    required Stream<Duration> buffer,
    required Stream<String?> subtitleText,
  })  : _position = position,
        _duration = duration,
        _playing = playing,
        _buffering = buffering,
        _volume = volume,
        _rate = rate,
        _tracks = tracks,
        _error = error,
        _completed = completed,
        _buffer = buffer,
        _subtitleText = subtitleText;

  @override
  Stream<Duration> get position => _position;
  @override
  Stream<Duration> get duration => _duration;
  @override
  Stream<bool> get playing => _playing;
  @override
  Stream<bool> get buffering => _buffering;
  @override
  Stream<double> get volume => _volume;
  @override
  Stream<double> get rate => _rate;
  @override
  Stream<Tracks> get tracks => _tracks;
  @override
  Stream<dynamic> get error => _error;
  @override
  Stream<bool> get completed => _completed;
  @override
  Stream<Duration> get buffer => _buffer;
  @override
  Stream<String?> get subtitleText => _subtitleText;
}

class OfficialPlayerState implements PlayerState {
  final OfficialPlayer _player;
  OfficialPlayerState(this._player);

  @override
  Duration get position => _player._controller?.value.position ?? Duration.zero;
  @override
  Duration get duration => _player._controller?.value.duration ?? Duration.zero;
  @override
  bool get playing => _player._controller?.value.isPlaying ?? false;
  @override
  bool get buffering => _player._controller?.value.isBuffering ?? false;
  @override
  double get volume => _player._controller?.value.volume ?? 1.0;
  @override
  double get rate => _player._controller?.value.playbackSpeed ?? 1.0;
  @override
  Tracks get tracks => _player._tracks;
  @override
  Track get track => _player._currentTrack;
  @override
  Duration get buffer {
    final controller = _player._controller;
    if (controller != null && controller.value.buffered.isNotEmpty) {
      return controller.value.buffered.last.end;
    }
    return Duration.zero;
  }

  @override
  String? get subtitleText => _player._controller?.value.caption.text;
}

/// A [Player] implementation backed by the official [video_player] plugin.
///
/// Unlike [FvpPlayer], this class does NOT register any fvp backend — it uses
/// the platform's native decoder as shipped with the `video_player` package
/// (ExoPlayer on Android, AVPlayer on iOS/macOS, etc.).
class OfficialPlayer implements Player {
  bool _isDisposed = false;
  int _openOperationId = 0;
  VideoPlayerController? _controller;
  final _controllerNotifier = ValueNotifier<VideoPlayerController?>(null);
  final _fullscreenNotifier = ValueNotifier<bool>(false);
  Route? _fullscreenRoute;

  final _screenManager = const ScreenManager();

  Tracks _tracks = const Tracks();
  Track _currentTrack = const Track();
  bool _completed = false;
  bool _isFullscreen = false;

  @override
  bool get hasWakelock => false;

  @override
  bool get hasSubtitleSupport => false;

  @override
  bool get isFullscreen => _isFullscreen;

  @override
  void enterFullscreen() {
    if (_isFullscreen) return;
    _isFullscreen = true;
    _screenManager.setFullScreen(true);
    _fullscreenNotifier.value = true;
  }

  @override
  void exitFullscreen() {
    if (!_isFullscreen) return;
    _isFullscreen = false;
    _screenManager.setFullScreen(false);
    _fullscreenNotifier.value = false;
    if (_fullscreenRoute != null && _fullscreenRoute!.isCurrent) {
      _fullscreenRoute!.navigator?.pop();
      _fullscreenRoute = null;
    }
  }

  final _positionStreamController = StreamController<Duration>.broadcast();
  final _durationStreamController = StreamController<Duration>.broadcast();
  final _playingStreamController = StreamController<bool>.broadcast();
  final _bufferingStreamController = StreamController<bool>.broadcast();
  final _volumeStreamController = StreamController<double>.broadcast();
  final _rateStreamController = StreamController<double>.broadcast();
  final _tracksStreamController = StreamController<Tracks>.broadcast();
  final _errorStreamController = StreamController<dynamic>.broadcast();
  final _completedStreamController = StreamController<bool>.broadcast();
  final _bufferStreamController = StreamController<Duration>.broadcast();
  final _subtitleTextStreamController = StreamController<String?>.broadcast();

  late final OfficialPlayerStream _stream;
  late final OfficialPlayerState _state;

  OfficialPlayer() {
    _stream = OfficialPlayerStream(
      position: _positionStreamController.stream,
      duration: _durationStreamController.stream,
      playing: _playingStreamController.stream,
      buffering: _bufferingStreamController.stream,
      volume: _volumeStreamController.stream,
      rate: _rateStreamController.stream,
      tracks: _tracksStreamController.stream,
      error: _errorStreamController.stream,
      completed: _completedStreamController.stream,
      buffer: _bufferStreamController.stream,
      subtitleText: _subtitleTextStreamController.stream,
    );
    _state = OfficialPlayerState(this);
  }

  @override
  PlayerStream get stream => _stream;
  @override
  PlayerState get state => _state;

  void _controllerListener() {
    if (_isDisposed) return;
    final controller = _controller;
    if (controller == null) return;

    final val = controller.value;
    _positionStreamController.add(val.position);
    _durationStreamController.add(val.duration);
    _playingStreamController.add(val.isPlaying);
    _bufferingStreamController.add(val.isBuffering);
    _volumeStreamController.add(val.volume);
    _rateStreamController.add(val.playbackSpeed);

    if (val.hasError) {
      _errorStreamController.add(val.errorDescription);
    }

    final isCompleted = val.isCompleted;
    if (_completed != isCompleted) {
      _completed = isCompleted;
      _completedStreamController.add(isCompleted);
    }

    if (val.buffered.isNotEmpty) {
      _bufferStreamController.add(val.buffered.last.end);
    } else {
      _bufferStreamController.add(Duration.zero);
    }

    _subtitleTextStreamController.add(val.caption.text);
  }

  @override
  Future<void> play() async => _controller?.play();

  @override
  Future<void> pause() async => _controller?.pause();

  @override
  Future<void> playOrPause() async {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  @override
  Future<void> seek(Duration position) async => _controller?.seekTo(position);

  @override
  Future<void> setRate(double rate) async => _controller?.setPlaybackSpeed(rate);

  @override
  Future<void> setVolume(double volume) async => _controller?.setVolume(volume);

  Future<ClosedCaptionFile?> _loadClosedCaptionFile(SubtitleTrack track) async {
    if (track.id == 'no' || track.id == 'auto') return null;

    String? data = track.data;
    if (data == null && track.uri != null) {
      HttpClient? client;
      try {
        client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 5);
        final request = await client.getUrl(Uri.parse(track.uri!));
        final response = await request.close();
        if (response.statusCode == 200) {
          data = await utf8.decodeStream(response);
        }
      } catch (e) {
        debugPrint('[OfficialPlayer] Failed to load subtitle from uri: ${track.uri}, error: $e');
      } finally {
        client?.close(force: true);
      }
    }

    if (data != null) {
      if (data.contains('WEBVTT')) {
        return WebVTTCaptionFile(data);
      } else {
        return SubRipCaptionFile(data);
      }
    }
    return null;
  }

  @override
  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    _currentTrack = Track(video: _currentTrack.video, subtitle: track);
    _tracksStreamController.add(_tracks);

    final controller = _controller;
    if (controller == null) return;

    final captionFile = await _loadClosedCaptionFile(track);
    if (_controller != controller) return;
    if (captionFile == null) {
      await controller.setClosedCaptionFile(null);
    } else {
      await controller.setClosedCaptionFile(Future<ClosedCaptionFile>.value(captionFile));
    }
  }

  @override
  Future<void> setVideoTrack(VideoTrack track) async {
    _currentTrack = Track(video: track, subtitle: _currentTrack.subtitle);
    _tracksStreamController.add(_tracks);
  }

  @override
  void setTracks(Tracks tracks) {
    _tracks = tracks;
    _tracksStreamController.add(tracks);
  }

  @override
  Future<void> open(String resource, {Map<String, String>? headers, bool play = true}) async {
    debugPrint('[OfficialPlayer] open: $resource, headers: $headers');
    final operationId = ++_openOperationId;
    final oldController = _controller;
    _controller = null;
    _controllerNotifier.value = null;
    if (oldController != null) {
      oldController.removeListener(_controllerListener);
      await oldController.dispose();
    }

    if (_completed) {
      _completed = false;
      _completedStreamController.add(false);
    }

    VideoFormat? formatHint;
    final lowerResource = resource.toLowerCase();
    if (lowerResource.contains('.m3u8') || lowerResource.contains('m3u8') || lowerResource.contains('hls')) {
      formatHint = VideoFormat.hls;
    } else if (lowerResource.contains('.mpd') || lowerResource.contains('mpd')) {
      formatHint = VideoFormat.dash;
    } else if (lowerResource.contains('.ism') || lowerResource.contains('ism')) {
      formatHint = VideoFormat.ss;
    }

    final bool isKnownProgressive = lowerResource.endsWith('.mp4') ||
        lowerResource.contains('.mp4?') ||
        lowerResource.endsWith('.webm') ||
        lowerResource.contains('.webm?') ||
        lowerResource.endsWith('.mkv') ||
        lowerResource.contains('.mkv?') ||
        lowerResource.endsWith('.avi') ||
        lowerResource.contains('.avi?') ||
        lowerResource.endsWith('.mov') ||
        lowerResource.contains('.mov?') ||
        lowerResource.endsWith('.flv') ||
        lowerResource.contains('.flv?');

    // Fallback: If formatHint couldn't be determined from the URL and not a known progressive file, probe the headers
    if (formatHint == null && !isKnownProgressive && (resource.startsWith('http://') || resource.startsWith('https://'))) {
      HttpClient? client;
      try {
        client = HttpClient();
        client.connectionTimeout = const Duration(milliseconds: 2500);
        final request = await client.getUrl(Uri.parse(resource));

        if (headers != null) {
          headers.forEach((key, value) {
            request.headers.set(key, value);
          });
        }
        // Use range header to prevent downloading full files for progressive streams
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-0');

        final response = await request.close().timeout(const Duration(milliseconds: 2500));
        final contentType = response.headers.value(HttpHeaders.contentTypeHeader)?.toLowerCase() ?? '';

        String finalUrl = resource.toLowerCase();
        if (response.redirects.isNotEmpty) {
          finalUrl = response.redirects.last.location.toString().toLowerCase();
        }

        debugPrint(
          '[OfficialPlayer] Probed content-type: "$contentType", finalUrl: "$finalUrl", statusCode: ${response.statusCode}',
        );

        if (contentType.contains('mpegurl') ||
            contentType.contains('m3u8') ||
            finalUrl.contains('m3u8') ||
            contentType.contains('apple.mpegurl')) {
          formatHint = VideoFormat.hls;
        } else if (contentType.contains('dash') || contentType.contains('mpd') || finalUrl.contains('mpd')) {
          formatHint = VideoFormat.dash;
        } else if (contentType.contains('smoothstreaming') || finalUrl.contains('ism')) {
          formatHint = VideoFormat.ss;
        }

        final subscription = response.listen((_) {});
        await subscription.cancel();
      } catch (e) {
        debugPrint('[OfficialPlayer] Probing stream format failed: $e');
      } finally {
        client?.close(force: true);
      }
    }

    final controller = resource.startsWith('http://') || resource.startsWith('https://')
        ? VideoPlayerController.networkUrl(
            Uri.parse(resource),
            formatHint: formatHint,
            httpHeaders: headers ?? const {},
          )
        : VideoPlayerController.file(File(resource));

    if (operationId != _openOperationId) {
      await controller.dispose();
      return;
    }

    _controller = controller;
    _controllerNotifier.value = controller;

    try {
      await controller.initialize();
      if (_controller == controller && operationId == _openOperationId) {
        controller.addListener(_controllerListener);
        _controllerListener();
        if (play) {
          await controller.play();
        }
      } else {
        await controller.dispose();
      }
    } catch (e) {
      debugPrint('[OfficialPlayer] Error initializing VideoPlayerController: $e');
      _errorStreamController.add(e);
      rethrow;
    }
  }

  @override
  Future<void> setNativeProperties(Map<String, String> properties) async {}

  @override
  Future<void> stop() async {
    await _controller?.pause();
    await _controller?.seekTo(Duration.zero);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    _openOperationId++;
    if (_fullscreenRoute != null && _fullscreenRoute!.isCurrent) {
      _fullscreenRoute!.navigator?.pop();
    }
    _fullscreenRoute = null;
    final oldController = _controller;
    _controller = null;
    oldController?.removeListener(_controllerListener);
    await oldController?.dispose();

    _fullscreenNotifier.dispose();
    _controllerNotifier.dispose();

    await _positionStreamController.close();
    await _durationStreamController.close();
    await _playingStreamController.close();
    await _bufferingStreamController.close();
    await _volumeStreamController.close();
    await _rateStreamController.close();
    await _tracksStreamController.close();
    await _errorStreamController.close();
    await _completedStreamController.close();
    await _bufferStreamController.close();
    await _subtitleTextStreamController.close();
  }

  @override
  Widget buildVideoView(
    BuildContext context, {
    required Widget Function(BuildContext) controlsBuilder,
    required VideoSettings settings,
    required GlobalKey<State<StatefulWidget>> playerKey,
    required BoxFit fit,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: _fullscreenNotifier,
      builder: (context, isFullscreen, child) {
        if (isFullscreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showFullscreenRoute(context, controlsBuilder, fit);
          });
          return Container(color: Colors.black);
        }

        return ValueListenableBuilder<VideoPlayerController?>(
          valueListenable: _controllerNotifier,
          builder: (context, controller, child) {
            if (controller == null) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.black),
                  controlsBuilder(context),
                ],
              );
            }

            return ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                if (!value.isInitialized) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Colors.black),
                      controlsBuilder(context),
                    ],
                  );
                }

                Widget videoWidget;
                if (fit == BoxFit.cover || fit == BoxFit.fill) {
                  videoWidget = SizedBox.expand(
                    child: FittedBox(
                      fit: fit,
                      child: SizedBox(
                        width: value.size.width > 0 ? value.size.width : 16,
                        height: value.size.height > 0 ? value.size.height : 9,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  );
                } else {
                  videoWidget = Center(
                    child: AspectRatio(
                      aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16 / 9,
                      child: VideoPlayer(controller),
                    ),
                  );
                }

                return Stack(key: playerKey, fit: StackFit.expand, children: [videoWidget, controlsBuilder(context)]);
              },
            );
          },
        );
      },
    );
  }

  void _showFullscreenRoute(BuildContext context, Widget Function(BuildContext) controlsBuilder, BoxFit fit) {
    if (_fullscreenRoute != null) return;

    final route = PageRouteBuilder(
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) {
        return _FullscreenVideoPage(
          screenManager: _screenManager,
          child: Material(
            color: Colors.black,
            child: ValueListenableBuilder<VideoPlayerController?>(
              valueListenable: _controllerNotifier,
              builder: (context, controller, child) {
                if (controller == null) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Colors.black),
                      controlsBuilder(context),
                    ],
                  );
                }
                return ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    if (!value.isInitialized) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: Colors.black),
                          controlsBuilder(context),
                        ],
                      );
                    }

                    Widget videoWidget;
                    if (fit == BoxFit.cover || fit == BoxFit.fill) {
                      videoWidget = SizedBox.expand(
                        child: FittedBox(
                          fit: fit,
                          child: SizedBox(
                            width: value.size.width > 0 ? value.size.width : 16,
                            height: value.size.height > 0 ? value.size.height : 9,
                            child: VideoPlayer(controller),
                          ),
                        ),
                      );
                    } else {
                      videoWidget = Center(
                        child: AspectRatio(
                          aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16 / 9,
                          child: VideoPlayer(controller),
                        ),
                      );
                    }

                    return Stack(fit: StackFit.expand, children: [videoWidget, controlsBuilder(context)]);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    _fullscreenRoute = route;
    Navigator.of(context, rootNavigator: true).push(route).then((_) {
      _fullscreenRoute = null;
      if (_isFullscreen) {
        exitFullscreen();
      }
    });
  }
}

class _FullscreenVideoPage extends StatefulWidget {
  final Widget child;
  final ScreenManager screenManager;
  const _FullscreenVideoPage({required this.child, required this.screenManager});

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  @override
  void initState() {
    super.initState();
    widget.screenManager.setFullScreen(true);
  }

  @override
  void dispose() {
    widget.screenManager.setFullScreen(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

