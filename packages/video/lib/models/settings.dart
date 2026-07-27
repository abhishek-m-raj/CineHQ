import 'package:flutter/material.dart';

enum SubtitleShadowIntensity {
  none,
  low,
  medium,
  high;

  @override
  String toString() {
    switch (this) {
      case SubtitleShadowIntensity.none:
        return 'None';
      case SubtitleShadowIntensity.low:
        return 'Low';
      case SubtitleShadowIntensity.medium:
        return 'Medium';
      case SubtitleShadowIntensity.high:
        return 'High';
    }
  }

  List<Shadow> get shadows {
    switch (this) {
      case SubtitleShadowIntensity.none:
        return const [];
      case SubtitleShadowIntensity.low:
        return const [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)];
      case SubtitleShadowIntensity.medium:
        return const [
          Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 4),
          Shadow(color: Colors.black, offset: Offset(-1, -1), blurRadius: 4),
        ];
      case SubtitleShadowIntensity.high:
        return const [
          Shadow(color: Colors.black, offset: Offset(0, 0), blurRadius: 6),
          Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
          Shadow(color: Colors.black, offset: Offset(-1, -1), blurRadius: 2),
        ];
    }
  }

  List<BoxShadow> get boxShadows {
    switch (this) {
      case SubtitleShadowIntensity.none:
        return const [];
      case SubtitleShadowIntensity.low:
        return const [BoxShadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)];
      case SubtitleShadowIntensity.medium:
        return const [
          BoxShadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 4),
          BoxShadow(color: Colors.black, offset: Offset(-1, -1), blurRadius: 4),
        ];
      case SubtitleShadowIntensity.high:
        return const [BoxShadow(color: Colors.black, spreadRadius: 2, blurRadius: 6, blurStyle: BlurStyle.solid)];
    }
  }
}

enum SubtitleFont {
  system,
  nunito,
  poppins,
  teko,
  googleFont;

  @override
  String toString() {
    switch (this) {
      case SubtitleFont.system:
        return 'System Default';
      case SubtitleFont.nunito:
        return 'Nunito';
      case SubtitleFont.poppins:
        return 'Poppins';
      case SubtitleFont.teko:
        return 'Teko';
      case SubtitleFont.googleFont:
        return 'Google Font...';
    }
  }

  String? get fontFamily {
    switch (this) {
      case SubtitleFont.system:
        return null;
      case SubtitleFont.nunito:
        return 'Nunito';
      case SubtitleFont.poppins:
        return 'Poppins';
      case SubtitleFont.teko:
        return 'Teko';
      case SubtitleFont.googleFont:
        return null;
    }
  }
}

enum SubtitleBackgroundType {
  none,
  solid,
  translucent,
  translucentGlass;

  @override
  String toString() {
    switch (this) {
      case SubtitleBackgroundType.none:
        return 'None';
      case SubtitleBackgroundType.translucent:
        return 'Translucent';
      case SubtitleBackgroundType.solid:
        return 'Solid';
      case SubtitleBackgroundType.translucentGlass:
        return 'Translucent Glass';
    }
  }
}

class VideoSettings {
  final int seekSeconds;
  final bool fastForwardOnLongPress;
  final bool seekOnDoubleTap;
  final bool pauseOnTap;
  final bool seekOnHorizontalDrag;
  final bool brightnesVolumeDrags;
  final double fastForwardRate;
  final bool autoPlay;
  final bool skipTimestamps;
  final bool hardwareAcceleration;
  final double subtitleFontSize;
  final String subtitleColorHex;
  final String subtitleBackgroundColorHex;
  final double subtitleBackgroundOpacity;
  final String subtitleOutlineColorHex;
  final double subtitleOutlineWidth;
  final double subtitleGlassBlur;
  final String subtitleGlassTintHex;
  final String subtitleGoogleFontName;
  final double subtitleBottomPadding;
  final bool usePackageSubtitleViewer;
  final SubtitleShadowIntensity subtitleShadowIntensity;
  final SubtitleFont subtitleFont;
  final SubtitleBackgroundType subtitleBackgroundType;
  final double subtitleBackgroundRoundness;
  final double subtitleBackgroundPaddingHorizontal;
  final double subtitleBackgroundPaddingVertical;
  final Map<String, String> nativePlayerProperties;

  const VideoSettings({
    this.seekSeconds = 10,
    this.fastForwardOnLongPress = true,
    this.seekOnDoubleTap = true,
    this.pauseOnTap = false,
    this.seekOnHorizontalDrag = true,
    this.brightnesVolumeDrags = true,
    this.fastForwardRate = 2.0,
    this.autoPlay = true,
    this.skipTimestamps = true,
    this.hardwareAcceleration = false,
    this.subtitleFontSize = 18.0,
    this.subtitleColorHex = 'ffffff',
    this.subtitleBackgroundColorHex = '000000',
    this.subtitleBackgroundOpacity = 0.5,
    this.subtitleOutlineColorHex = '000000',
    this.subtitleOutlineWidth = 2.0,
    this.subtitleGlassBlur = 10.0,
    this.subtitleGlassTintHex = 'ffffff',
    this.subtitleGoogleFontName = 'Nunito',
    this.subtitleBottomPadding = 24.0,
    this.usePackageSubtitleViewer = true,
    this.subtitleShadowIntensity = SubtitleShadowIntensity.high,
    this.subtitleFont = SubtitleFont.system,
    this.subtitleBackgroundType = SubtitleBackgroundType.none,
    this.subtitleBackgroundRoundness = 8.0,
    this.subtitleBackgroundPaddingHorizontal = 16.0,
    this.subtitleBackgroundPaddingVertical = 8.0,
    this.nativePlayerProperties = const {
      'cache': 'yes',
      'cache-secs': '60',
      'demuxer-readahead-secs': '30',
      'demuxer-max-back-bytes': '100M',
      'audio-buffer': '1',
      'video-sync': 'display-resample',
    },
  });
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.white;
    }
  }

  String toHex() {
    return '#${toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
