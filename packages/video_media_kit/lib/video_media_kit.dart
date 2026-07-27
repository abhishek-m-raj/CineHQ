import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart' as mkv;
import 'package:video/video.dart';

class MediaKitPlayerStream implements PlayerStream {
  final mk.Player _player;
  MediaKitPlayerStream(this._player);

  @override
  Stream<Duration> get position => _player.stream.position;
  @override
  Stream<Duration> get duration => _player.stream.duration;
  @override
  Stream<bool> get playing => _player.stream.playing;
  @override
  Stream<bool> get buffering => _player.stream.buffering;
  @override
  Stream<double> get volume => _player.stream.volume;
  @override
  Stream<double> get rate => _player.stream.rate;
  @override
  Stream<Tracks> get tracks => _player.stream.tracks.map((t) => _mapTracks(t));
  @override
  Stream<dynamic> get error => _player.stream.error;
  @override
  Stream<bool> get completed => _player.stream.completed;
  @override
  Stream<Duration> get buffer => _player.stream.buffer;
  @override
  Stream<String?> get subtitleText => const Stream.empty();
}

class MediaKitPlayerState implements PlayerState {
  final mk.Player _player;
  MediaKitPlayerState(this._player);

  @override
  Duration get position => _player.state.position;
  @override
  Duration get duration => _player.state.duration;
  @override
  bool get playing => _player.state.playing;
  @override
  bool get buffering => _player.state.buffering;
  @override
  double get volume => _player.state.volume;
  @override
  double get rate => _player.state.rate;
  @override
  Tracks get tracks => _mapTracks(_player.state.tracks);
  @override
  Track get track => _mapTrack(_player.state.track);
  @override
  Duration get buffer => _player.state.buffer;
  @override
  String? get subtitleText => null;
}

Tracks _mapTracks(mk.Tracks t) {
  return Tracks(
    video: t.video.map((v) => VideoTrack(v.id, v.title, v.language, h: v.h)).toList(),
    subtitle: t.subtitle.map((s) => SubtitleTrack(s.id, s.title, s.language)).toList(),
  );
}

Track _mapTrack(mk.Track t) {
  return Track(
    video: VideoTrack(t.video.id, t.video.title, t.video.language, h: t.video.h),
    subtitle: SubtitleTrack(t.subtitle.id, t.subtitle.title, t.subtitle.language),
  );
}

class MediaKitPlayer implements Player {
  final mk.Player _player;
  late final MediaKitPlayerStream _stream;
  late final MediaKitPlayerState _state;

  factory MediaKitPlayer({mk.MPVLogLevel logLevel = mk.MPVLogLevel.error}) {
    mk.MediaKit.ensureInitialized();
    return MediaKitPlayer._(logLevel: logLevel);
  }

  MediaKitPlayer._({mk.MPVLogLevel logLevel = mk.MPVLogLevel.error})
    : _player = mk.Player(configuration: mk.PlayerConfiguration(logLevel: logLevel)) {
    _stream = MediaKitPlayerStream(_player);
    _state = MediaKitPlayerState(_player);
  }

  static void initialize() {
    mk.MediaKit.ensureInitialized();
  }

  @override
  PlayerStream get stream => _stream;
  @override
  PlayerState get state => _state;

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> playOrPause() => _player.playOrPause();
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> setRate(double rate) => _player.setRate(rate);
  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> setSubtitleTrack(SubtitleTrack track) {
    if (track.id == 'auto') {
      return _player.setSubtitleTrack(mk.SubtitleTrack.auto());
    } else if (track.id == 'no') {
      return _player.setSubtitleTrack(mk.SubtitleTrack.no());
    } else if (track.data != null) {
      return _player.setSubtitleTrack(mk.SubtitleTrack.data(track.data!, title: track.title, language: track.language));
    } else if (track.uri != null) {
      return _player.setSubtitleTrack(mk.SubtitleTrack.uri(track.uri!, title: track.title, language: track.language));
    } else {
      return _player.setSubtitleTrack(mk.SubtitleTrack(track.id, track.title, track.language));
    }
  }

  @override
  Future<void> setVideoTrack(VideoTrack track) {
    if (track.id == 'auto') {
      return _player.setVideoTrack(mk.VideoTrack.auto());
    } else if (track.id == 'no') {
      return _player.setVideoTrack(mk.VideoTrack.no());
    } else {
      return _player.setVideoTrack(mk.VideoTrack(track.id, track.title, track.language, h: track.h));
    }
  }

  @override
  Future<void> open(String resource, {Map<String, String>? headers, bool play = true}) {
    return _player.open(mk.Media(resource, httpHeaders: headers), play: play);
  }

  @override
  Future<void> setNativeProperties(Map<String, String> properties) async {
    if (_player.platform is mk.NativePlayer) {
      final native = _player.platform as mk.NativePlayer;
      for (final entry in properties.entries) {
        native.setProperty(entry.key, entry.value);
      }
    }
  }

  final _videoKey = GlobalKey<mkv.VideoState>();

  @override
  bool get hasWakelock => true;

  @override
  bool get hasSubtitleSupport => true;

  @override
  bool get isFullscreen => _videoKey.currentState?.isFullscreen() ?? false;
  @override
  void enterFullscreen() => _videoKey.currentState?.enterFullscreen();
  @override
  void exitFullscreen() => _videoKey.currentState?.exitFullscreen();

  @override
  void setTracks(Tracks tracks) {}

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();

  @override
  Widget buildVideoView(
    BuildContext context, {
    required Widget Function(BuildContext) controlsBuilder,
    required VideoSettings settings,
    required GlobalKey<State<StatefulWidget>> playerKey,
    required BoxFit fit,
  }) {
    final videoController = mkv.VideoController(
      _player,
      configuration: mkv.VideoControllerConfiguration(
        androidAttachSurfaceAfterVideoParameters: false,
        enableHardwareAcceleration: settings.hardwareAcceleration,
      ),
    );

    return mkv.Video(
      key: _videoKey,
      controller: videoController,
      fit: fit,
      subtitleViewConfiguration: mkv.SubtitleViewConfiguration(
        style: TextStyle(
          height: 1.4,
          fontSize: settings.usePackageSubtitleViewer ? 0 : settings.subtitleFontSize * 2.5,
          fontFamily: settings.usePackageSubtitleViewer ? null : settings.subtitleFont.fontFamily,
          letterSpacing: 0.0,
          wordSpacing: 0.0,
          color: settings.usePackageSubtitleViewer ? Colors.transparent : HexColor.fromHex(settings.subtitleColorHex),
          fontWeight: FontWeight.bold,
          shadows: settings.usePackageSubtitleViewer ? [] : settings.subtitleShadowIntensity.boxShadows,
        ),
        textAlign: TextAlign.center,
        padding: const EdgeInsets.all(24.0),
      ),
      controls: (state) => controlsBuilder(context),
      wakelock: true,
      pauseUponEnteringBackgroundMode: true,
      resumeUponEnteringForegroundMode: true,
    );
  }
}
