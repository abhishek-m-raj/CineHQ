export 'enums.dart';
import 'package:device/dimensions.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import 'enums.dart';

final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
late AndroidDeviceInfo? androidInfo;
late bool isDebugTvMode;

class Device {
  static Future<void> ensureInitialized({bool debugTvMode = false}) async {
    if (isAndroid && !isWeb) {
      androidInfo = await deviceInfo.androidInfo;
    }
    isDebugTvMode = debugTvMode;
  }

  static PlatformType get value {
    if (UniversalPlatform.isWindows) return PlatformType.windows;
    if (UniversalPlatform.isFuchsia) return PlatformType.fuchsia;
    if (UniversalPlatform.isMacOS) return PlatformType.macOS;
    if (UniversalPlatform.isLinux) return PlatformType.linux;
    if (UniversalPlatform.isIOS) return PlatformType.iOS;
    return PlatformType.android;
  }

  static bool get isMacOS => UniversalPlatform.isMacOS;
  static bool get isWindows => UniversalPlatform.isWindows;
  static bool get isLinux => UniversalPlatform.isLinux;
  static bool get isAndroid => UniversalPlatform.isAndroid;
  static bool get isIOS => UniversalPlatform.isIOS;
  static bool get isFuchsia => UniversalPlatform.isFuchsia;

  static bool get isWeb => kIsWeb;
  static bool get isMobile => (isAndroid || isIOS) && !isTv && !isTablet;
  static bool get isDesktop => isLinux || isMacOS || isWindows;
  static bool get isDesktopOrWeb => isWeb || isDesktop;

  static bool get isTv {
    if (isAndroid && !isWeb) {
      return androidInfo!.systemFeatures.contains('android.software.leanback');
    } else {
      return isDebugTvMode;
    }
  }

  static bool get isTablet {
    if (!isAndroid || !isIOS) {
      return false;
    }
    final data = WidgetsBinding.instance.platformDispatcher.views.first;
    return data.display.size.shortestSide <= mobileWidth ? false : true;
  }
}
