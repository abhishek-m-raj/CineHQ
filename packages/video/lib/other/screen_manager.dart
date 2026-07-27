import 'package:auto_orientation/auto_orientation.dart';
import 'package:device/device.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'logging.dart';

class ScreenManager {
  /// [orientations] the device orientation after exit of the fullscreen
  final List<DeviceOrientation> orientations;

  /// [overlays] the device overlays after exit of the fullscreen
  final List<SystemUiOverlay> overlays;

  /// when the player is in fullscreen mode if forceLandScapeInFullscreen the player only show the landscape mode
  final bool forceLandScapeInFullscreen;

  ///how system overlay are handled hidden
  final SystemUiMode? systemUiMode;

  ///if system overlays should be hidden or not
  final bool hideSystemOverlay;

  const ScreenManager({
    this.orientations = DeviceOrientation.values,
    this.overlays = SystemUiOverlay.values,
    this.forceLandScapeInFullscreen = true,
    this.systemUiMode,
    this.hideSystemOverlay = true,
  });

  /// set the default orientations and overlays after exit of fullscreen
  Future<void> setDefaultOverlaysAndOrientations() async {
    try {
      await SystemChrome.setPreferredOrientations(orientations);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: overlays);
      if (Device.isIOS) {
        AutoOrientation.portraitAutoMode();
      }
    } catch (e) {
      log.e("Error setting default overlays and orientations: $e");
    }
  }

  /// Toggle fullscreen for desktop
  Future<void> setDesktopFullScreen(bool state) async {
    try {
      await windowManager.setFullScreen(state);
    } catch (e) {
      log.e("Error setting desktop fullscreen: $e");
    }
  }

  /// Toggle fullscreen for web
  Future<void> setWebFullScreen(bool state) async {
    try {
      await FullScreenWindow.setFullScreen(state);
    } catch (e) {
      if (e.toString().contains("Document not active")) {
        log.w("Document not active ignored");
      } else {
        log.e("Error setting web fullscreen: $e");
      }
    }
  }

  /// Toggle system overlays
  Future<void> setOverlays(bool visible) async {
    if (hideSystemOverlay) {
      try {
        if (visible) {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: overlays);
        } else {
          await SystemChrome.setEnabledSystemUIMode(systemUiMode ?? SystemUiMode.immersiveSticky);
        }
      } catch (e) {
        log.e("Error setting overlays: $e");
      }
    }
  }

  /// hide the statusBar and the navigation bar, set only landscape mode only if forceLandScapeInFullscreen is true
  Future<void> setFullScreenOverlaysAndOrientations({bool hideOverLays = true}) async {
    try {
      if (forceLandScapeInFullscreen) {
        AutoOrientation.landscapeAutoMode(forceSensor: true);
      } else {
        AutoOrientation.fullAutoMode();
      }

      if (hideOverLays) {
        await setOverlays(false);
      }
    } catch (e) {
      log.e("Error setting fullscreen overlays and orientations: $e");
    }
  }

  /// Unified method to set fullscreen across all platforms
  Future<void> setFullScreen(bool state) async {
    if (Device.isWeb) {
      await setWebFullScreen(state);
    } else if (Device.isDesktop) {
      await setDesktopFullScreen(state);
    } else {
      if (state) {
        await setFullScreenOverlaysAndOrientations();
      } else {
        await setDefaultOverlaysAndOrientations();
      }
    }
  }
}
