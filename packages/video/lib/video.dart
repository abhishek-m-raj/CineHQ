export 'controller.dart';
export 'models/settings.dart';
export 'models/chapter.dart';
export 'models/track.dart';
export 'style/style.dart';
export 'models/datasource.dart';
export 'other/video_pop_scope.dart';
export 'player/player.dart';
export 'other/screen_manager.dart';
export 'models/episode_data.dart';
export 'widgets/btns/episodes_btn.dart';
export 'overlays/episodes_overlay.dart';
export 'ui/ui.dart';
import 'dart:async';
import 'dart:ui';
import 'models/settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video/ui/ui.dart';
import 'package:video/style/enums.dart';
import 'package:video/style/style.dart';
import 'package:video/other/events_listener.dart';
import 'package:video/widgets/btns/btn.dart';
import 'controller.dart';
import 'videoui.dart';
import 'player/player.dart';
import 'package:device/device.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoPlayer extends StatefulWidget {
  final Controller controller;
  final VidStyle style;
  final List<VidBtn> extraBtns;
  final List<Widget> extraOverlays;
  final bool fullScreenBtn;

  const VideoPlayer({
    super.key,
    required this.controller,
    this.style = const VidStyle(),
    this.extraBtns = const [],
    this.extraOverlays = const [],
    this.fullScreenBtn = true,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late KeyEventsManager _keyEventsManager;
  late StreamSubscription<BoxFit> _fitSubscription;
  StreamSubscription<bool>? _playingSubscription;

  @override
  void initState() {
    _keyEventsManager = KeyEventsManager(controller: widget.controller, noFullscreen: !widget.fullScreenBtn);
    _keyEventsManager.init();
    _fitSubscription = widget.controller.fitController.stream.listen((_) => setState(() {}));
    if (!widget.controller.player.hasWakelock) {
      _playingSubscription = widget.controller.player.stream.playing.listen((isPlaying) {
        if (isPlaying) {
          WakelockPlus.enable();
        } else {
          WakelockPlus.disable();
        }
      });
      if (widget.controller.player.state.playing) {
        WakelockPlus.enable();
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _keyEventsManager.dispose();
    _fitSubscription.cancel();
    _playingSubscription?.cancel();
    if (!widget.controller.player.hasWakelock) {
      WakelockPlus.disable();
    }
    widget.controller.brightness.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldClip = widget.style.playerMode == VidPlayerMode.desktop && widget.fullScreenBtn;
    Widget view = widget.controller.player.buildVideoView(
      context,
      playerKey: widget.controller.key,
      fit: widget.controller.fit,
      settings: widget.controller.settings,
      controlsBuilder: (context) {
        return VideoUI(
          style: widget.style,
          controller: widget.controller,
          extraBtns: widget.extraBtns,
          extraOverlays: widget.extraOverlays,
          showFullScreenBtn: widget.fullScreenBtn,
        );
      },
    );

    return Container(
      clipBehavior: shouldClip ? Clip.hardEdge : Clip.none,
      decoration: shouldClip ? BoxDecoration(borderRadius: HqBorderRadius.br2.asRadius) : null,
      child: AspectRatio(aspectRatio: 16 / 9, child: view),
    );
  }
}

typedef PlayerFactory = Player Function();

class VideoPlayerConfig {
  final PlayerFactory factory;
  final FutureOr<void> Function()? initialize;

  const VideoPlayerConfig({required this.factory, this.initialize});
}

class Video {
  static final Map<PlatformType, VideoPlayerConfig> _platformConfigs = {};
  static VideoPlayerConfig? _webConfig;

  static Future<void> initialize(Map<PlatformType, VideoPlayerConfig> configs, {VideoPlayerConfig? webConfig}) async {
    _platformConfigs.addAll(configs);
    _webConfig = webConfig;

    final config = _currentConfig;
    if (config?.initialize != null) {
      await config!.initialize!();
    }
  }

  static VideoPlayerConfig? get _currentConfig {
    if (Device.isWeb) {
      return _webConfig;
    }
    final platform = Device.value;
    return _platformConfigs[platform];
  }

  static Player createPlayer() {
    final config = _currentConfig;
    if (config == null) {
      throw StateError(
        'No video player configured for the current platform (Platform: ${Device.value}, Web: ${Device.isWeb})',
      );
    }
    return config.factory();
  }
}

class VideoSubtitleView extends StatelessWidget {
  final String? text;
  final VideoSettings settings;
  const VideoSubtitleView({super.key, this.text, required this.settings});

  Widget _buildBackground({required Widget child, required double scale}) {
    final bgType = settings.subtitleBackgroundType;
    final roundness = settings.subtitleBackgroundRoundness * scale;

    if (bgType == SubtitleBackgroundType.none) {
      return child;
    }

    if (bgType == SubtitleBackgroundType.translucentGlass) {
      final tintColor = HexColor.fromHex(settings.subtitleGlassTintHex);
      final blur = settings.subtitleGlassBlur * scale;
      return ClipRRect(
        borderRadius: BorderRadius.circular(roundness),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: tintColor.withValues(alpha: settings.subtitleBackgroundOpacity),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
              borderRadius: BorderRadius.circular(roundness),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: settings.subtitleBackgroundPaddingHorizontal * scale,
              vertical: settings.subtitleBackgroundPaddingVertical * scale,
            ),
            child: child,
          ),
        ),
      );
    }

    Color color;
    if (bgType == SubtitleBackgroundType.translucent) {
      color = HexColor.fromHex(
        settings.subtitleBackgroundColorHex,
      ).withValues(alpha: settings.subtitleBackgroundOpacity);
    } else {
      color = HexColor.fromHex(settings.subtitleBackgroundColorHex);
    }

    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(roundness)),
      padding: EdgeInsets.symmetric(
        horizontal: settings.subtitleBackgroundPaddingHorizontal * scale,
        vertical: settings.subtitleBackgroundPaddingVertical * scale,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double scale = (constraints.maxWidth / 800.0).clamp(0.4, 2.5);
        final double fontSize = settings.subtitleFontSize * scale;

        Widget textWidget = Stack(
          children: [
            if (settings.subtitleOutlineWidth > 0)
              Text(
                text!,
                textAlign: TextAlign.center,
                style: () {
                  TextStyle s = TextStyle(
                    height: 1.4,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.0,
                    wordSpacing: 0.0,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = settings.subtitleOutlineWidth * scale
                      ..color = HexColor.fromHex(settings.subtitleOutlineColorHex),
                  );
                  if (settings.subtitleFont == SubtitleFont.googleFont) {
                    try {
                      s = GoogleFonts.getFont(settings.subtitleGoogleFontName, textStyle: s);
                    } catch (_) {}
                  } else {
                    s = s.copyWith(fontFamily: settings.subtitleFont.fontFamily);
                  }
                  return s;
                }(),
              ),
            Text(
              text!,
              textAlign: TextAlign.center,
              style: () {
                TextStyle s = TextStyle(
                  height: 1.4,
                  fontSize: fontSize,
                  letterSpacing: 0.0,
                  wordSpacing: 0.0,
                  color: HexColor.fromHex(settings.subtitleColorHex),
                  fontWeight: FontWeight.bold,
                  shadows: settings.subtitleShadowIntensity.shadows,
                );
                if (settings.subtitleFont == SubtitleFont.googleFont) {
                  try {
                    s = GoogleFonts.getFont(settings.subtitleGoogleFontName, textStyle: s);
                  } catch (_) {}
                } else {
                  s = s.copyWith(fontFamily: settings.subtitleFont.fontFamily);
                }
                return s;
              }(),
            ),
          ],
        );

        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: settings.subtitleBottomPadding * scale, left: 16.0, right: 16.0),
            child: _buildBackground(child: textWidget, scale: scale),
          ),
        );
      },
    );
  }
}
