import 'dart:async';
import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:video/player/player.dart';
import 'package:vibration/vibration.dart';
import 'package:video/models/chapter.dart';
import 'package:video/models/datasource.dart';
import 'package:video/models/streams.dart';
import 'package:video/models/settings.dart';
import 'package:video/models/track.dart';
import 'package:video/other/brightness.dart';
import 'package:video/other/volume.dart';
import 'package:video/widgets/btns/settings/settings_overlay.dart';
import 'package:video/other/overlay_controller.dart';
import 'other/logging.dart';

class Controller {
  final Player player;
  VideoSettings settings;
  List<Chapter> chapters;
  int? quality;
  late Function seek;

  final _packageSubtitleStreamController = StreamController<String?>.broadcast();
  Stream<String?> get packageSubtitleStream => _packageSubtitleStreamController.stream;
  
  List<SubtitleCue> _packageSubtitleCues = [];
  StreamSubscription? _posSub;

  Controller({required this.player, this.settings = const VideoSettings(), this.chapters = const [], this.quality}) {
    init();
  }

  Timer? _controlsVisibilityTimer;
  late double _playbackSpeed;
  late final VideoStreams streams;
  late final VidScreenBrightness brightness;
  late final VidVolume volume;
  late final GlobalKey<State<StatefulWidget>> key;
  late final FocusNode playBtnFocusNode;
  Datasource? datasource;
  bool isTimestampSkipping = false;
  bool isControlsVisble = true;
  bool isFastForwarding = false;
  bool isDragSeeking = false;
  bool isForwardRewinding = false;
  Duration? seekDragedDur;
  late BoxFit fit = BoxFit.contain;
  late final List<StreamSubscription> _subs;
  late final StreamController<BoxFit> fitController = StreamController<BoxFit>.broadcast();
  late SettingsOverlayController settingsOverlayController;
  late OverlayController episodeOverlayController;
  late OverlayController framesOverlayController;
  late final void Function() onBack;
  Future<List<Map<String, dynamic>>> Function(String query)? onSearchSubtitles;
  Future<String?> Function(String subtitleId)? onDownloadSubtitle;

  String? coverImg;
  Uint8List? thumbnailVtt;
  String? thumbnailVttBaseUrl;

  void init() async {
    key = GlobalKey<State<StatefulWidget>>();
    playBtnFocusNode = FocusNode();
    _playbackSpeed = 1.0;
    brightness = VidScreenBrightness();
    volume = VidVolume(player);
    settingsOverlayController = SettingsOverlayController();
    episodeOverlayController = OverlayController();
    framesOverlayController = OverlayController();
    streams = VideoStreams(controller: this);
    await player.setNativeProperties(settings.nativePlayerProperties);
    _subs = [player.stream.position.listen(skipTimestamps)];
  }

  void setOnBack(void Function() callback) {
    onBack = callback;
  }

  void cycleFit() {
    const List<BoxFit> fits = [BoxFit.contain, BoxFit.cover, BoxFit.fill];
    final int currentIndex = fits.indexOf(fit);
    fit = fits[(currentIndex + 1) % fits.length];
    fitController.add(fit);
  }

  void setSettings(VideoSettings data) {
    settings = data;
  }

  void dispose() {
    for (final i in _subs) {
      i.cancel();
    }
    _posSub?.cancel();
    _packageSubtitleStreamController.close();
    playBtnFocusNode.dispose();
    volume.dispose();
    fitController.close();
    player.dispose();
    streams.dispose();
  }

  bool get isFullscreen => player.isFullscreen;

  Chapter? get currentChapter {
    if (chapters.isEmpty) {
      return null;
    }
    final int index = chapters.indexWhere((element) {
      return element.at >= player.state.position.inSeconds;
    });
    try {
      if (index == 0) {
        return null;
      } else if (index == chapters.length) {
        return chapters.last;
      } else {
        return chapters[index - 1];
      }
    } catch (e) {
      return null;
    }
  }

  List<VideoTrack> get videoTracks {
    if (datasource is MultiDatasource) {
      List<VideoTrack> tracks = [];
      final List<int> keys = List.from((datasource as MultiDatasource).links.keys.toList());
      for (int i in keys) {
        tracks.add(VideoTrack((keys.indexOf(i) + 1).toString(), "", "en", h: i));
      }
      return tracks;
    }
    List<VideoTrack> tracks = List.from(player.state.tracks.video);
    tracks.removeWhere((element) => element.id == "no");
    return tracks;
  }

  VideoTrack get currentTrack {
    if (datasource is MultiDatasource) {
      return VideoTrack("0", "", "en", h: quality);
    }
    return player.state.track.video;
  }

  void skipTimestamps(Duration pos) async {
    if (settings.skipTimestamps) {
      for (Chapter i in chapters) {
        final bool isSkippable = i.isSkippable && !isTimestampSkipping;
        final int index = chapters.indexOf(i);
        if ((pos.inSeconds == i.at.floor()) && isSkippable && player.state.playing) {
          isTimestampSkipping = true;
          late final int nextTimestampInSecond;
          if (index != chapters.length - 1) {
            Chapter nextTimestamp = chapters[index + 1];
            for (Chapter j in chapters.sublist(index)) {
              if (chapters.sublist(index).indexOf(j) == 0) {
                continue;
              }
              if (j.isSkippable) {
                try {
                  Chapter nextnext = chapters.sublist(index)[chapters.sublist(index).indexOf(j) + 1];
                  if (nextnext.isSkippable) {
                    continue;
                  } else {
                    nextTimestamp = j;
                    break;
                  }
                } catch (_) {}
              } else {
                break;
              }
            }
            log.i("skipping till ${nextTimestamp.name}");
            nextTimestampInSecond = nextTimestamp.at.floor();
          } else {
            log.i("skipping to duration");
            nextTimestampInSecond = player.state.duration.inSeconds;
          }
          await player.seek(Duration(seconds: nextTimestampInSecond));
          isTimestampSkipping = false;
        }
      }
    }
  }

  void skipChapter([Chapter? chapter]) async {
    final Chapter? skippingChapter = chapter ?? currentChapter;
    if (skippingChapter == null) return;
    final int index = chapters.indexOf(skippingChapter);
    if (!isTimestampSkipping) {
      isTimestampSkipping = true;
      late final int nextTimestampInSecond;
      if (index != (chapters.length - 1)) {
        Chapter nextTimestamp = chapters[index + 1];
        log.i("skipping till ${nextTimestamp.name}");
        nextTimestampInSecond = nextTimestamp.at.floor();
      } else {
        log.i("skipping to duration");
        nextTimestampInSecond = player.state.duration.inSeconds;
      }
      await player.seek(Duration(seconds: nextTimestampInSecond));
      isTimestampSkipping = false;
    }
  }

  void setControlsVisibility(bool visible) {
    if (isControlsVisble != visible) {
      if (Device.isTv && visible) {
        playBtnFocusNode.requestFocus();
      }
      isControlsVisble = visible;
      streams.isControlsVisbleController.add(visible);
    }
    _controlsVisibilityTimer?.cancel();
    if (visible) {
      _controlsVisibilityTimer = Timer(const Duration(seconds: 5), () {
        if (isControlsVisble != false) {
          isControlsVisble = false;
          streams.isControlsVisbleController.add(false);
        }
      });
    }
  }

  void setChapters(List<Chapter> chaptersData) {
    chapters = chaptersData;
  }

  void setPlaybackSpeed(double speed) async {
    await player.setRate(speed);
    _playbackSpeed = speed;
  }

  void _setTracks() async {
    thumbnailVtt = null;
    thumbnailVttBaseUrl = null;
    bool subtitleSet = false;

    final subtitleTracks = (datasource?.tracks ?? [])
        .where((track) => track.type == VidTrackType.caption)
        .map((track) => SubtitleTrack.uri(track.url, title: track.label, language: track.label))
        .toList();
    player.setTracks(Tracks(subtitle: subtitleTracks));

    for (VidTrack track in datasource?.tracks ?? []) {
      if (track.type == VidTrackType.caption) {
        if (track.headers != null && track.headers!.isNotEmpty) {
          try {
            final res = await http.get(Uri.parse(track.url), headers: track.headers!);
            if (res.statusCode == 200) {
              await setSubtitleTrack(SubtitleTrack.data(res.body, title: track.label, language: track.label));
              subtitleSet = true;
              continue;
            }
          } catch (_) {}
        }
        await setSubtitleTrack(SubtitleTrack.uri(track.url, title: track.label, language: track.label));
        subtitleSet = true;
      } else {
        if (datasource?.thumbnailVttUrl != null) {
          try {
            final vttUrl = datasource!.thumbnailVttUrl!;
            final response = await http.get(Uri.parse(vttUrl));
            if (response.statusCode == 200) {
              thumbnailVtt = response.bodyBytes;
              final lastSlash = vttUrl.lastIndexOf('/');
              thumbnailVttBaseUrl = lastSlash > 0 ? "${vttUrl.substring(0, lastSlash)}/" : null;
            }
          } catch (_) {}
        }
      }
    }
    if (datasource is MultiDatasource) {
      player.setVideoTrack(const VideoTrack('auto', 'auto', null));
    }
    if (!subtitleSet) {
      setSubtitleTrack(SubtitleTrack.auto());
    }
  }

  Future<void> loadVideo({required Datasource data, Duration? startTime}) async {
    try {
      datasource = data;
      streams.videoLoadedController.add(datasource);
      if (data is SingleDatasource) {
        log.i("loading single datasource: ${data.url} headers=${data.headers?.entries.toList()}");
        await player.open(data.url, headers: data.headers, play: Device.isWeb ? false : settings.autoPlay);
        _setTracks();
      } else if (data is MultiDatasource) {
        log.i("loading multi datasource video");
        final int? targetKey = data.links.containsKey(quality) ? quality : (data.links.isNotEmpty ? data.links.keys.first : null);
        if (targetKey != null && data.links[targetKey] != null) {
          quality = targetKey;
          await player.open(
            data.links[targetKey]!,
            headers: data.headers,
            play: Device.isWeb ? false : settings.autoPlay,
          );
        }
        _setTracks();
      } else if (data is FileDatasource) {
        await player.open(data.path, play: settings.autoPlay);
      }
      await player.stream.buffer.first.timeout(const Duration(seconds: 2), onTimeout: () => Duration.zero);
      if (startTime != null) {
        await player.seek(startTime);
      }
      if (Device.isWeb && settings.autoPlay) {
        await player.play();
      }
    } catch (e) {
      datasource = null;
      log.e(e);
    }
  }

  Future<void> switchQuality(VideoTrack track) async {
    if (datasource is MultiDatasource) {
      quality = track.h;
      final MultiDatasource multi = datasource as MultiDatasource;
      final String? linkToPlay = multi.links[quality] ?? (multi.links.isNotEmpty ? multi.links.values.first : null);
      if (linkToPlay != null) {
        final startTime = player.state.position;
        await player.open(
          linkToPlay,
          headers: datasource?.headers,
          play: Device.isWeb ? false : true,
        );
        await player.stream.buffer.first.timeout(const Duration(seconds: 2), onTimeout: () => Duration.zero);
        await player.seek(startTime);
        if (Device.isWeb) {
          await player.play();
        }
      }
    } else {
      quality = track.h;
      player.setVideoTrack(track);
    }
  }


  void fastForward(bool forward) async {
    if (forward && isFastForwarding) {
      return;
    }
    final double speed = settings.fastForwardRate;
    if (forward) {
      isFastForwarding = true;
      if (!Device.isWeb && !Device.isLinux) {
        try {
          if ((await Vibration.hasVibrator()) == true) {
            Vibration.vibrate(amplitude: (255 * (1 / 3)).toInt(), duration: 100);
          }
        } catch (_) {}
      }
      SystemSound.play(SystemSoundType.click);
      player.setRate(speed.toDouble() * _playbackSpeed);
    } else {
      isFastForwarding = false;
      player.setRate(_playbackSpeed);
    }
  }

  void enFullscreen() async {
    try {
      player.enterFullscreen();
      streams.fullscreenController.add(true);
      SystemChrome.setPreferredOrientations(const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      if (Device.isTv) {
        await Future.delayed(Duration(milliseconds: 500), () => playBtnFocusNode.requestFocus());
      }
    } catch (_) {}
  }

  void exFullscreen() {
    try {
      player.exitFullscreen();
      streams.fullscreenController.add(false);
      if (Device.isMobile) {
        SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      } else {
        SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    } catch (_) {}
  }

  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    await player.setSubtitleTrack(track);
    await _updatePackageSubtitle(track);
  }

  Future<void> _updatePackageSubtitle(SubtitleTrack track) async {
    _posSub?.cancel();
    _packageSubtitleCues.clear();
    _packageSubtitleStreamController.add(null);
    
    if (track.id == 'no' || track.id == 'auto') {
      return;
    }
    
    String? content = track.data;
    if (content == null && track.uri != null) {
      try {
        final headers = datasource?.headers;
        final res = await http.get(Uri.parse(track.uri!), headers: headers);
        if (res.statusCode == 200) {
          content = res.body;
        }
      } catch (e) {
        debugPrint('[Controller] Failed to download package subtitle: $e');
      }
    }
    
    if (content != null) {
      _packageSubtitleCues = parseSubtitles(content);
      _packageSubtitleCues.sort((a, b) => a.start.compareTo(b.start));
      
      _posSub = player.stream.position.listen((pos) {
        String? activeText;
        for (final cue in _packageSubtitleCues) {
          if (pos >= cue.start && pos <= cue.end) {
            activeText = cue.text;
            break;
          }
        }
        _packageSubtitleStreamController.add(activeText);
      });
    }
  }
}

class SubtitleCue {
  final Duration start;
  final Duration end;
  final String text;

  SubtitleCue({required this.start, required this.end, required this.text});
}

List<SubtitleCue> parseSubtitles(String content) {
  final List<SubtitleCue> cues = [];
  final lines = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
  
  Duration? parseTime(String s) {
    s = s.trim().replaceAll(',', '.');
    final parts = s.split(':');
    if (parts.isEmpty) return null;
    
    try {
      double seconds = 0;
      int minutes = 0;
      int hours = 0;
      
      if (parts.length == 3) {
        hours = int.parse(parts[0]);
        minutes = int.parse(parts[1]);
        seconds = double.parse(parts[2]);
      } else if (parts.length == 2) {
        minutes = int.parse(parts[0]);
        seconds = double.parse(parts[1]);
      } else {
        seconds = double.parse(parts[0]);
      }
      
      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds.truncate(),
        milliseconds: ((seconds - seconds.truncate()) * 1000).round(),
      );
    } catch (_) {
      return null;
    }
  }
  
  int i = 0;
  while (i < lines.length) {
    var line = lines[i].trim();
    if (line.isEmpty) {
      i++;
      continue;
    }
    
    if (line.contains('-->')) {
      final times = line.split('-->');
      if (times.length == 2) {
        final start = parseTime(times[0]);
        final end = parseTime(times[1]);
        if (start != null && end != null) {
          final List<String> textLines = [];
          i++;
          while (i < lines.length && lines[i].trim().isNotEmpty && !lines[i].contains('-->')) {
            textLines.add(lines[i].trim());
            i++;
          }
          final text = textLines.join('\n');
          final cleanText = text.replaceAll(RegExp(r'<[^>]*>'), '');
          cues.add(SubtitleCue(start: start, end: end, text: cleanText));
          continue;
        }
      }
    }
    i++;
  }
  
  return cues;
}
