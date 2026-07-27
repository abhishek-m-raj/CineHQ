import 'package:animated_visibility/animated_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video/ui/ui.dart';
import 'package:video/controller.dart';
import 'package:video/style/enums.dart';
import 'package:video/style/style.dart';
import 'package:video/widgets/btns/back_btn.dart';
import '../widgets/btns/full_screen_btn.dart';
import '../widgets/btns/mute_btn.dart';
import '../widgets/btns/settings/settings_btn.dart';

class TopControlsOverlay extends StatelessWidget {
  final Controller controller;
  final VidStyle style;

  const TopControlsOverlay({super.key, required this.controller, required this.style});

  Widget topRow() {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    BackBtn(style: style, controller: controller),
                    SizedBox(width: HqSpacing.s2),
                  ],
                  if (style.playerMode != VidPlayerMode.mobile || controller.isFullscreen)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HqText(controller.datasource?.title, style: HqTextStyles.h2),
                          HqText(controller.datasource?.subtitle, style: HqTextStyles.b2),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (style.playerMode == VidPlayerMode.mobile)
              Row(
                children: [
                  SizedBox(width: HqSpacing.s7),
                  MuteBtn(controller: controller, style: style),
                  SettingsBtn(controller: controller, style: style),
                  if (style.playerMode != VidPlayerMode.mobile || !controller.isFullscreen)
                    FullScreenBtn(controller: controller, style: style),
                ],
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibility(
      visible: controller.isControlsVisble,
      enterDuration: 400.ms,
      exitDuration: 300.ms,
      enter: fadeIn(curve: Curves.easeOutCubic),
      exit: fadeOut(curve: Curves.easeOutCubic),
      child: Builder(
        builder: (context) {
          return topRow();
        },
      ),
    );
  }
}
