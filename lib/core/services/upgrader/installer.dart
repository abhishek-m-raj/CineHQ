import 'dart:async';
import 'dart:io' show File, Process;
import 'package:device/device.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cineui/cineui.dart';

import '../../router/app_router.dart';
import '../../storage/local_storage.dart';
import 'version.dart';

class DownloadProgress {
  final double progress;
  final int received;
  final int total;

  DownloadProgress({required this.progress, required this.received, required this.total});
}

class AppInstaller {
  final Dio dio;
  final Talker talker;
  final LocalStorage localStorage;
  final VersionInfo versionInfo;
  static final Uri helpUrl = Uri.parse("https://github.com/abhishek-m-raj/CineHQ/releases");

  const AppInstaller({
    required this.dio,
    required this.talker,
    required this.localStorage,
    required this.versionInfo,
  });

  BuildContext? get _context => AppRouter.rootNavigatorKey.currentContext;

  void updateApp() async {
    try {
      final String filePath = await downloadFile();
      await Future.delayed(const Duration(seconds: 1));
      
      if (_context != null && _context!.mounted) {
        Navigator.of(_context!, rootNavigator: true).pop();
      }

      if (Device.isAndroid) {
        final status = await Permission.requestInstallPackages.request();
        if (status.isGranted) {
          installApp(filePath);
        } else {
          if (_context != null && _context!.mounted) {
            CineSnackbar(
              content: "App install permission denied!",
              actionLabel: "OK",
            ).show(_context!);
          }
        }
      } else {
        installApp(filePath);
      }
    } catch (e, s) {
      talker.handle(e, s);
      try {
        if (_context != null && _context!.mounted) {
          Navigator.of(_context!, rootNavigator: true).pop();
        }
      } catch (_) {}

      if (_context != null && _context!.mounted) {
        _showErrorDialog(
          title: "Update failed",
          message: "An error occurred while updating CineHQ.\n\nPlease visit our releases page for manual installation instructions.",
        );
      }
    }
  }

  void showDownloadingDialog(Stream<DownloadProgress> progress) {
    final context = _context;
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: StreamBuilder<DownloadProgress>(
            stream: progress,
            builder: (context, snapshot) {
              final isComplete = snapshot.data?.progress == 1.0;
              return Text(
                isComplete ? "Download Complete" : "Downloading Update",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              );
            },
          ),
          content: StreamBuilder<DownloadProgress>(
            stream: progress,
            builder: (context, snapshot) {
              final data = snapshot.data;
              final value = data?.progress ?? 0.0;
              final receivedMB = (data?.received ?? 0) / (1024 * 1024);
              final totalMB = (data?.total ?? 0) / (1024 * 1024);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${(value * 100).toStringAsFixed(0)}%",
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (data != null && data.total > 0)
                        Text(
                          "${receivedMB.toStringAsFixed(1)} MB / ${totalMB.toStringAsFixed(1)} MB",
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<String> downloadFile() async {
    final StreamController<DownloadProgress> progressController = StreamController.broadcast();
    final String? downloadUrl = versionInfo.files.fromPlatform();
    final String? filePath = await versionInfo.files.generateFilePath(versionInfo.latest);

    showDownloadingDialog(progressController.stream);

    if (filePath != null && downloadUrl != null && downloadUrl.isNotEmpty) {
      final file = File(filePath);
      await file.parent.create(recursive: true);

      await dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            progressController.add(DownloadProgress(progress: received / total, received: received, total: total));
          }
        },
      );
      progressController.close();
      return filePath;
    } else {
      progressController.close();
      throw Exception("Installation file not available for this OS or architecture.");
    }
  }

  void installApp(String filePath) async {
    if (versionInfo.clearData) {
      talker.info("Clearing app data for new version");
      await localStorage.clearAllData();
    }

    if (Device.isLinux) {
      await _installLinux(filePath);
    } else {
      if (_context != null && _context!.mounted) {
        showDialog(
          context: _context!,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text("Installing CineHQ"),
            content: const Text("Please wait and follow any system prompts that appear on your screen."),
          ),
        );
      }

      final result = await OpenFile.open(filePath);

      try {
        if (_context != null && _context!.mounted) {
          Navigator.of(_context!, rootNavigator: true).pop();
        }
      } catch (_) {}

      if (result.type != ResultType.done) {
        if (_context != null && _context!.mounted) {
          _showErrorDialog(
            title: "Installation failed",
            message: "Could not launch installation file.\n\nPlease visit our releases page for manual installation instructions.",
          );
        }
      }
    }
  }

  Future<void> _installLinux(String filePath) async {
    final ext = filePath.split('.').last.toLowerCase();

    try {
      late final List<String> command;
      switch (ext) {
        case 'deb':
          command = ['pkexec', 'dpkg', '-i', filePath];
          break;
        case 'rpm':
          command = ['pkexec', 'rpm', '-Uvh', filePath];
          break;
        case 'pacman':
          command = ['pkexec', 'pacman', '-U', '--noconfirm', filePath];
          break;
        case 'appimage':
          await Process.run('chmod', ['+x', filePath]);
          if (_context != null && _context!.mounted) {
            showDialog(
              context: _context!,
              builder: (dialogContext) => AlertDialog(
                title: const Text("AppImage Ready"),
                content: Text("The AppImage has been saved to:\n$filePath\n\nYou can run it directly or move it to your preferred location."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
          await OpenFile.open(filePath);
          return;
        default:
          await OpenFile.open(filePath);
          return;
      }

      if (_context != null && _context!.mounted) {
        showDialog(
          context: _context!,
          barrierDismissible: false,
          builder: (dialogContext) => const AlertDialog(
            title: Text("Installing update"),
            content: Text("Your system will request administrator password to install the update."),
          ),
        );
      }

      final result = await Process.run(command.first, command.sublist(1));

      try {
        if (_context != null && _context!.mounted) {
          Navigator.of(_context!, rootNavigator: true).pop();
        }
      } catch (_) {}

      if (result.exitCode == 0) {
        if (_context != null && _context!.mounted) {
          showDialog(
            context: _context!,
            builder: (dialogContext) => AlertDialog(
              title: const Text("Update Installed! 🎉"),
              content: const Text("Please restart CineHQ to use the new version."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } else {
        talker.error("Linux install failed (exit ${result.exitCode}): ${result.stderr}");
        if (_context != null && _context!.mounted) {
          _showErrorDialog(
            title: "Installation failed",
            message: "The package manager returned an error.\n\nYou can install manually from: $filePath",
          );
        }
      }
    } catch (e, s) {
      talker.handle(e, s);
      if (_context != null && _context!.mounted) {
        _showErrorDialog(
          title: "Installation failed",
          message: "Failed to install update: $e",
        );
      }
    }
  }

  void _showErrorDialog({required String title, required String message}) {
    final context = _context;
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                launchUrl(helpUrl, mode: LaunchMode.externalApplication);
              },
              child: const Text("DOWNLOAD FROM RELEASES"),
            ),
          ],
        );
      },
    );
  }
}
