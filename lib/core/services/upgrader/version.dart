import 'dart:io' show Process, ProcessResult;

import 'package:device/device.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';

import 'android_abi.dart';

class VersionInfo {
  final Version current;
  final Version latest;
  final bool forceUpdate;
  final bool clearData;
  final String description;
  final AppInstallFiles files;

  const VersionInfo({
    required this.current,
    required this.latest,
    required this.forceUpdate,
    required this.clearData,
    required this.description,
    required this.files,
  });

  bool get isUpdated => current == latest;
  bool get hasNewUpdate => current < latest;

  factory VersionInfo.parse({required Map<String, dynamic> data, required String current}) {
    String versionStr = '0.0.0';
    if (data.containsKey('tag_name')) {
      versionStr = (data['tag_name'] as String).replaceAll(RegExp(r'^v'), '');
    } else if (data.containsKey('version')) {
      versionStr = (data['version'] as String).replaceAll(RegExp(r'^v'), '');
    }

    final String body = (data['body'] as String?) ?? (data['description'] as String?) ?? '';
    final bool force = (data['forceUpdate'] as bool?) ?? body.toLowerCase().contains('[force]');
    final bool clear = (data['clearData'] as bool?) ?? body.toLowerCase().contains('[cleardata]');

    // Strip build numbers like +1 from semver strings if present
    final cleanCurrent = current.replaceAll(RegExp(r'^v'), '').split('+').first;
    final cleanLatest = versionStr.split('+').first;

    return VersionInfo(
      current: Version.parse(cleanCurrent),
      latest: Version.parse(cleanLatest),
      forceUpdate: force,
      clearData: clear,
      description: body,
      files: AppInstallFiles.fromMap(data),
    );
  }
}

enum LinuxDistro {
  debian,
  arch,
  fedora,
  unknown;

  static LinuxDistro detect() {
    if (!Device.isLinux || kIsWeb) return LinuxDistro.unknown;

    try {
      final ProcessResult result = Process.runSync('cat', ['/etc/os-release']);
      final String osRelease = result.stdout.toString().toLowerCase();

      final idLike = RegExp(r'id_like\s*=\s*"?([^"\n]+)"?').firstMatch(osRelease)?.group(1) ?? '';
      final id = RegExp(r'^id\s*=\s*"?([^"\n]+)"?', multiLine: true).firstMatch(osRelease)?.group(1) ?? '';

      final combined = '$idLike $id';

      if (combined.contains('debian') || combined.contains('ubuntu')) {
        return LinuxDistro.debian;
      }
      if (combined.contains('arch')) return LinuxDistro.arch;
      if (combined.contains('fedora') ||
          combined.contains('rhel') ||
          combined.contains('centos') ||
          combined.contains('suse')) {
        return LinuxDistro.fedora;
      }
    } catch (_) {}

    return LinuxDistro.unknown;
  }
}

class AppInstallFiles {
  final String android;
  final String androidArm64;
  final String androidArm32;
  final String androidX86_64;
  final String windows;
  final String linuxDeb;
  final String linuxAppimage;
  final String linuxPacman;
  final String linuxRpm;

  const AppInstallFiles({
    required this.android,
    required this.androidArm64,
    required this.androidArm32,
    required this.androidX86_64,
    required this.windows,
    required this.linuxDeb,
    required this.linuxAppimage,
    required this.linuxPacman,
    required this.linuxRpm,
  });

  factory AppInstallFiles.fromMap(Map<String, dynamic> map) {
    // If map contains GitHub Releases 'assets' array
    if (map['assets'] is List) {
      final List assets = map['assets'] as List;
      String androidVal = '';
      String androidArm64Val = '';
      String androidArm32Val = '';
      String androidX86_64Val = '';
      String windowsVal = '';
      String linuxDebVal = '';
      String linuxAppimageVal = '';
      String linuxPacmanVal = '';
      String linuxRpmVal = '';

      for (final item in assets) {
        if (item is Map) {
          final String name = (item['name'] as String? ?? '').toLowerCase();
          final String url = (item['browser_download_url'] as String? ?? item['url'] as String? ?? '');

          if (name.endsWith('.apk')) {
            if (name.contains('arm64') || name.contains('arm64-v8a')) {
              androidArm64Val = url;
            } else if (name.contains('armeabi') || name.contains('arm32') || name.contains('v7a')) {
              androidArm32Val = url;
            } else if (name.contains('x86_64') || name.contains('x64')) {
              androidX86_64Val = url;
            } else if (name.contains('universal')) {
              androidVal = url;
            } else {
              if (androidVal.isEmpty) androidVal = url;
            }
          } else if (name.endsWith('.deb')) {
            linuxDebVal = url;
          } else if (name.endsWith('.appimage')) {
            linuxAppimageVal = url;
          } else if (name.endsWith('.pacman')) {
            linuxPacmanVal = url;
          } else if (name.endsWith('.rpm')) {
            linuxRpmVal = url;
          } else if (name.endsWith('.exe') || (name.endsWith('.zip') && name.contains('windows'))) {
            windowsVal = url;
          }
        }
      }

      return AppInstallFiles(
        android: androidVal,
        androidArm64: androidArm64Val,
        androidArm32: androidArm32Val,
        androidX86_64: androidX86_64Val,
        windows: windowsVal,
        linuxDeb: linuxDebVal,
        linuxAppimage: linuxAppimageVal,
        linuxPacman: linuxPacmanVal,
        linuxRpm: linuxRpmVal,
      );
    }

    // Direct JSON API response format
    return AppInstallFiles(
      android: (map["android"] as String?) ?? '',
      androidArm64: (map["android_arm64"] as String?) ?? '',
      androidArm32: (map["android_arm32"] as String?) ?? (map["android_arm"] as String?) ?? '',
      androidX86_64: (map["android_x86_64"] as String?) ?? '',
      windows: (map["windows"] as String?) ?? '',
      linuxDeb: (map["linux_deb"] as String?) ?? '',
      linuxAppimage: (map["linux_appimage"] as String?) ?? '',
      linuxPacman: (map["linux_pacman"] as String?) ?? '',
      linuxRpm: (map["linux_rpm"] as String?) ?? '',
    );
  }

  String? get fieldName {
    if (kIsWeb) return null;

    if (Device.isAndroid) {
      final androidAbi = getAndroidAbiFieldName();
      if (androidAbi != null) return androidAbi;
      return "android";
    } else if (Device.isWindows) {
      return "windows";
    } else if (Device.isLinux) {
      return _linuxFieldName;
    } else {
      return null;
    }
  }

  String? fromPlatform() {
    if (kIsWeb) return null;

    if (Device.isAndroid) {
      final androidAbi = getAndroidAbiFieldName();
      if (androidAbi == "android_arm64" && androidArm64.isNotEmpty) return androidArm64;
      if (androidAbi == "android_arm32" && androidArm32.isNotEmpty) return androidArm32;
      if (androidAbi == "android_x86_64" && androidX86_64.isNotEmpty) return androidX86_64;
      if (androidArm64.isNotEmpty) return androidArm64;
      if (androidArm32.isNotEmpty) return androidArm32;
      if (androidX86_64.isNotEmpty) return androidX86_64;
      return android.isNotEmpty ? android : null;
    } else if (Device.isWindows) {
      return windows.isNotEmpty ? windows : null;
    } else if (Device.isLinux) {
      return _linuxUrl;
    } else {
      return null;
    }
  }

  String? get fileExtension {
    if (kIsWeb) return null;

    if (Device.isAndroid) {
      return "apk";
    } else if (Device.isWindows) {
      final url = windows.toLowerCase();
      if (url.endsWith('.zip')) return "zip";
      return "exe";
    } else if (Device.isLinux) {
      return _linuxExtension;
    } else {
      return null;
    }
  }

  Future<String?> generateFilePath(Version version) async {
    if (kIsWeb) return null;

    final cacheDir = await getTemporaryDirectory();
    final String filePath = "${cacheDir.path}/install/CineHQ-$version.$fileExtension";
    return fileExtension != null ? filePath : null;
  }

  String? get _linuxUrl {
    final distro = LinuxDistro.detect();
    switch (distro) {
      case LinuxDistro.debian:
        if (linuxDeb.isNotEmpty) return linuxDeb;
      case LinuxDistro.arch:
        if (linuxPacman.isNotEmpty) return linuxPacman;
      case LinuxDistro.fedora:
        if (linuxRpm.isNotEmpty) return linuxRpm;
      case LinuxDistro.unknown:
        break;
    }
    if (linuxAppimage.isNotEmpty) return linuxAppimage;
    if (linuxDeb.isNotEmpty) return linuxDeb;
    if (linuxRpm.isNotEmpty) return linuxRpm;
    if (linuxPacman.isNotEmpty) return linuxPacman;
    return null;
  }

  String? get _linuxFieldName {
    final distro = LinuxDistro.detect();
    switch (distro) {
      case LinuxDistro.debian:
        if (linuxDeb.isNotEmpty) return 'linux_deb';
      case LinuxDistro.arch:
        if (linuxPacman.isNotEmpty) return 'linux_pacman';
      case LinuxDistro.fedora:
        if (linuxRpm.isNotEmpty) return 'linux_rpm';
      case LinuxDistro.unknown:
        break;
    }
    if (linuxAppimage.isNotEmpty) return 'linux_appimage';
    if (linuxDeb.isNotEmpty) return 'linux_deb';
    if (linuxRpm.isNotEmpty) return 'linux_rpm';
    if (linuxPacman.isNotEmpty) return 'linux_pacman';
    return null;
  }

  String? get _linuxExtension {
    final field = _linuxFieldName;
    if (field == null) return null;
    const map = {'linux_deb': 'deb', 'linux_appimage': 'AppImage', 'linux_pacman': 'pacman', 'linux_rpm': 'rpm'};
    return map[field];
  }
}
