import 'package:device/device.dart';
import 'package:flutter/widgets.dart';
import 'package:video/controller.dart';

class VideoPopScope extends StatelessWidget {
  final bool noFullscreen;
  final Controller controller;
  final Widget child;

  const VideoPopScope({super.key, this.noFullscreen = false, required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.streams.onFullscreen,
      builder: (context, snapshot) {
        final bool isFullscreen = snapshot.data ?? controller.isFullscreen;
        return PopScope(
          canPop: !isFullscreen && !Device.isTv,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            if (controller.settingsOverlayController.isOpen) {
              controller.settingsOverlayController.close();
            } else if (controller.episodeOverlayController.isOpen) {
              controller.episodeOverlayController.close();
            } else if (controller.framesOverlayController.isOpen) {
              controller.framesOverlayController.close();
            } else if (isFullscreen || noFullscreen || Device.isTv) {
              if (controller.isControlsVisble && Device.isTv) {
                controller.setControlsVisibility(false);
              } else {
                if (controller.isFullscreen) {
                  controller.exFullscreen();
                } else {
                  controller.onBack();
                }
              }
            }
          },
          child: child,
        );
      },
    );
  }
}
