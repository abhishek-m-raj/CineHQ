import 'dart:async';
import 'package:device/device.dart';
import 'package:video/utils/extentions.dart';
import 'package:video/video.dart';
import 'package:volume_controller/volume_controller.dart';

class VidVolume {
  final Player player;

  VidVolume(this.player) {
    init();
  }

  void init() {
    _volumeController = StreamController.broadcast();
    if (_isSupported) {
      VolumeController.instance.showSystemUI = false;
      _volumeSub = VolumeController.instance.addListener((volume) {
        _volume = volume * 100;
        _volumeController.add(_volume);
      }, fetchInitialVolume: true);
    }
    _volumeBeforeMute = 0;
  }

  void dispose() {
    if (_isSupported) {
      VolumeController.instance.removeListener();
      _volumeSub.cancel();
    }
    _volumeController.close();
  }

  late final StreamSubscription _volumeSub;
  late final StreamController<double> _volumeController;
  Timer? _volumeTimer;
  double _volume = 100;
  double _volumeBeforeMute = 0;
  bool get _isSupported => !Device.isWeb && !Device.isLinux;

  double get value {
    if (_isSupported) {
      return _volume;
    } else {
      return player.state.volume;
    }
  }

  Future<bool> get isMuted async {
    if (_isSupported) {
      return await VolumeController.instance.isMuted();
    }
    return (value == 0);
  }

  Stream<double> get stream {
    return _isSupported ? _volumeController.stream : player.stream.volume;
  }

  Future<void> set(double vol) async {
    final double volume = vol.clamp(0, 100);
    if (_isSupported) {
      _volume = volume;
      _volumeController.add(_volume);
      _volumeTimer?.cancel();
      _volumeTimer = Timer(300.ms, () async {
        await VolumeController.instance.setVolume((volume.roundToDouble() / 100));
      });
    } else {
      await player.setVolume(volume);
    }
  }

  Future<void> setMute([bool? enable]) async {
    final bool shouldEnable = (enable ?? !(await isMuted));
    if (_isSupported) {
      await VolumeController.instance.setMute(shouldEnable);
    } else {
      if (shouldEnable) {
        _volumeBeforeMute = player.state.volume;
      }
      await set(shouldEnable ? 0 : _volumeBeforeMute);
    }
  }
}
