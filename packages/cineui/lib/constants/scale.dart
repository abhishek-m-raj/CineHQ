import 'package:device/device.dart';

class CineScaler {
  static double get textScale => _scale;
  static double get spacingScale => _scale;

  static double get _scale {
    return Device.isMobile ? 1 : 1.1;
  }
}
