import 'dart:async';
import 'package:device/device.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video/utils/extentions.dart';

class VidScreenBrightness {
  VidScreenBrightness() {
    init();
  }

  void init() async {
    _brightnessController = StreamController.broadcast();
    if (_isSupported) {
      try {
        _brightness = await ScreenBrightness.instance.application;
      } catch (e) {
        _brightness = 100;
      }
      _brightnessSub = ScreenBrightness.instance.onApplicationScreenBrightnessChanged.listen((brightness) {
        _brightness = brightness * 100;
        _brightnessController.add(_brightness);
      });
    } else {
      _brightness = 100;
    }
  }

  void dispose() {
    if (_isSupported) {
      _brightnessSub.cancel();
    }
    _brightnessController.close();
  }

  late final StreamSubscription _brightnessSub;
  late final StreamController<double> _brightnessController;
  Timer? _brightnessTimer;
  double _brightness = 100;

  bool get _isSupported => !Device.isWeb && !Device.isLinux;

  double get value => _brightness;

  Stream<double> get stream {
    return _brightnessController.stream;
  }

  Future<void> set(double vol) async {
    final double brightness = vol.clamp(0, 100);
    _brightness = brightness;
    _brightnessController.add(_brightness);
    if (!_isSupported) return;
    _brightnessTimer?.cancel();
    _brightnessTimer = Timer(300.ms, () async {
      try {
        await ScreenBrightness.instance.setApplicationScreenBrightness((brightness.roundToDouble() / 100));
      } catch (_) {}
    });
  }

  Future<void> reset() async {
    if (!_isSupported) return;
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {}
  }
}
