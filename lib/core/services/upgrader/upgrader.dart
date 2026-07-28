import 'dart:async';
import 'package:device/device.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:cineui/cineui.dart';

import '../../router/app_router.dart';
import '../../storage/local_storage.dart';
import 'installer.dart';
import 'version.dart';

class UpgraderService {
  final Dio dio;
  final LocalStorage localStorage;
  final Talker talker;

  UpgraderService({
    required this.dio,
    required this.localStorage,
    required this.talker,
  });

  late final String currentVersion;
  final String releaseApiUrl = "https://api.github.com/repos/abhishek-m-raj/CineHQ/releases/latest";

  BuildContext? get _context => AppRouter.rootNavigatorKey.currentContext;

  Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      currentVersion = info.version;

      final lastVersion = localStorage.getLastInstalledVersion();
      if (lastVersion != null && lastVersion != currentVersion) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_context != null && _context!.mounted) {
            CineSnackbar(
              content: "App successfully updated to v$currentVersion",
              actionLabel: "OK",
            ).show(_context!);
          }
        });
      }
      await localStorage.saveLastInstalledVersion(currentVersion);

      if (!Device.isWeb) {
        check4updates();
      }
    } catch (e, s) {
      talker.handle(e, s);
    }
  }

  Future<void> check4updates([bool manualCheck = false]) async {
    talker.info("Checking for CineHQ updates");
    if (manualCheck && _context != null && _context!.mounted) {
      showDialog(
        context: _context!,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.surfaceContainer,
          content: const Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Checking for updates..."),
            ],
          ),
        ),
      );
    }

    try {
      final response = await dio.get(releaseApiUrl);

      if (manualCheck && _context != null && _context!.mounted) {
        Navigator.of(_context!, rootNavigator: true).pop();
      }

      if (response.data is Map) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data as Map);
        final VersionInfo versionInfo = VersionInfo.parse(current: currentVersion, data: data);

        if (versionInfo.hasNewUpdate) {
          talker.info("New CineHQ update available: v${versionInfo.latest}");
          _showUpdateDialog(versionInfo);
        } else {
          talker.info("No new update available");
          if (versionInfo.clearData) {
            talker.info("Clearing app data for new version");
            await localStorage.clearAllData();
            if (_context != null && _context!.mounted) {
              CineSnackbar(
                content: "App data cleared for new version",
                actionLabel: "OK",
              ).show(_context!);
            }
          }
          if (manualCheck && _context != null && _context!.mounted) {
            showDialog(
              context: _context!,
              builder: (dialogContext) => AlertDialog(
                title: const Text("You are up to date"),
                content: Text("CineHQ v$currentVersion is currently the latest version available."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e, s) {
      talker.handle(e, s);
      if (manualCheck && _context != null && _context!.mounted) {
        try {
          Navigator.of(_context!, rootNavigator: true).pop();
        } catch (_) {}
        showDialog(
          context: _context!,
          builder: (dialogContext) => AlertDialog(
            title: const Text("Check Failed"),
            content: Text("Could not fetch update information: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showUpdateDialog(VersionInfo versionInfo) {
    final context = _context;
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: !versionInfo.forceUpdate,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final platformFile = versionInfo.files.fromPlatform();

        return AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            "✨ New Version Available! v${versionInfo.latest}",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (versionInfo.description.isNotEmpty) ...[
                  Text(
                    "What's New:",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    versionInfo.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                ] else
                  const Text("A new update for CineHQ is available for download."),
              ],
            ),
          ),
          actions: [
            if (!versionInfo.forceUpdate)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("LATER"),
              ),
            if (platformFile != null && platformFile.isNotEmpty)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  AppInstaller(
                    dio: dio,
                    talker: talker,
                    localStorage: localStorage,
                    versionInfo: versionInfo,
                  ).updateApp();
                },
                child: const Text("UPDATE NOW"),
              ),
          ],
        );
      },
    );
  }
}
