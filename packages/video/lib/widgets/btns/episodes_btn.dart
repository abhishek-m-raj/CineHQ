import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:video/controller.dart';
import 'package:video/style/style.dart';
import 'package:video/ui/ui.dart';
import 'btn.dart';

class EpisodesBtn extends StatelessWidget {
  final Controller controller;
  final VidStyle style;

  const EpisodesBtn({super.key, required this.controller, required this.style});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.episodeOverlayController,
      builder: (context, child) {
        if (controller.episodeData == null) {
          return const SizedBox.shrink();
        }
        return VidBtn(
          icon: HqIcons.vidEpList,
          style: style,
          onTap: () {
            controller.episodeOverlayController.toggle();
            if (Device.isTv) {
              controller.playBtnFocusNode.requestFocus();
            }
          },
        );
      },
    );
  }
}
