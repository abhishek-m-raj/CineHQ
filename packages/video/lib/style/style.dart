import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';
import 'package:video/style/enums.dart';

class VidStyle {
  final Color loaderColor;
  final Color videoUiBtnsColor;
  final Color videoUiBtnsFocusColor;
  final Color settingTileColor;
  final Color seekBarColor;
  final Color? _seekBarPositionColor;
  final Color seekBarPositionFocusColor;
  final Color seekBarBufferColor;
  final Color seekBarThumbColor;
  final Color volumeIndicatorColor;
  final Color volumeIndicatorBgColor;
  final VidPlayerMode playerMode;

  Color get seekBarPositionColor =>
      _seekBarPositionColor ?? (Device.isTv ? HqColorScheme.secondary : HqColorScheme.primaryContainer);

  const VidStyle({
    this.loaderColor = HqColorScheme.primary,
    this.settingTileColor = HqColorScheme.secondaryContainer,
    this.seekBarColor = const Color(0x3DFFFFFF),
    this._seekBarPositionColor,
    this.seekBarPositionFocusColor = HqColorScheme.primaryContainer,
    this.seekBarBufferColor = const Color(0x37F0D3FC),
    this.videoUiBtnsFocusColor = HqColorScheme.primaryContainer,
    this.videoUiBtnsColor = HqColorScheme.surfaceTint,
    this.volumeIndicatorColor = HqColorScheme.primaryContainer,
    this.volumeIndicatorBgColor = const Color.fromARGB(50, 196, 147, 218),
    this.seekBarThumbColor = const Color.fromARGB(204, 255, 255, 255),
    this.playerMode = VidPlayerMode.desktop,
  });
}
