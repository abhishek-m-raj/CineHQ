import 'package:flutter/widgets.dart';
import '../models/settings.dart';

class SubtitleTrack {
  final String id;
  final String? title;
  final String? language;
  final String? data;
  final String? uri;

  const SubtitleTrack(this.id, this.title, this.language, {this.data, this.uri});

  factory SubtitleTrack.auto() => const SubtitleTrack('auto', 'auto', null);
  factory SubtitleTrack.no() => const SubtitleTrack('no', 'no', null);

  factory SubtitleTrack.data(String data, {String? title, String? language}) =>
      SubtitleTrack('data_${data.hashCode}', title, language, data: data);

  factory SubtitleTrack.uri(String uri, {String? title, String? language}) =>
      SubtitleTrack(uri, title, language, uri: uri);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SubtitleTrack && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class VideoTrack {
  final String id;
  final String? title;
  final String? language;
  final int? h;

  const VideoTrack(this.id, this.title, this.language, {this.h});

  factory VideoTrack.auto() => const VideoTrack('auto', 'auto', null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VideoTrack && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Tracks {
  final List<VideoTrack> video;
  final List<SubtitleTrack> subtitle;

  const Tracks({this.video = const [], this.subtitle = const []});
}

class Track {
  final VideoTrack video;
  final SubtitleTrack subtitle;

  const Track({
    this.video = const VideoTrack('auto', 'auto', null),
    this.subtitle = const SubtitleTrack('auto', 'auto', null),
  });
}

abstract class PlayerStream {
  Stream<Duration> get position;
  Stream<Duration> get duration;
  Stream<bool> get playing;
  Stream<bool> get buffering;
  Stream<double> get volume;
  Stream<double> get rate;
  Stream<Tracks> get tracks;
  Stream<dynamic> get error;
  Stream<bool> get completed;
  Stream<Duration> get buffer;
  Stream<String?> get subtitleText;
}

abstract class PlayerState {
  Duration get position;
  Duration get duration;
  bool get playing;
  bool get buffering;
  double get volume;
  double get rate;
  Tracks get tracks;
  Track get track;
  Duration get buffer;
  String? get subtitleText;
}

abstract class Player {
  PlayerStream get stream;
  PlayerState get state;

  Future<void> play();
  Future<void> pause();
  Future<void> playOrPause();
  Future<void> seek(Duration position);
  Future<void> setRate(double rate);
  Future<void> setVolume(double volume);
  Future<void> setSubtitleTrack(SubtitleTrack track);
  Future<void> setVideoTrack(VideoTrack track);
  Future<void> open(String resource, {Map<String, String>? headers, bool play = true});
  Future<void> setNativeProperties(Map<String, String> properties);
  void setTracks(Tracks tracks);
  bool get hasWakelock;
  bool get hasSubtitleSupport;
  bool get isFullscreen;
  void enterFullscreen();
  void exitFullscreen();
  Future<void> stop();
  Future<void> dispose();

  Widget buildVideoView(
    BuildContext context, {
    required Widget Function(BuildContext) controlsBuilder,
    required VideoSettings settings,
    required GlobalKey<State<StatefulWidget>> playerKey,
    required BoxFit fit,
  });
}
