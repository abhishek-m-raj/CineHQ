import 'package:flutter/material.dart';
import 'package:video/video.dart';
import 'package:video/widgets/btns/btn.dart';

class SettingsBtn extends StatelessWidget {
  final Controller controller;
  final VidStyle style;

  const SettingsBtn({super.key, required this.controller, required this.style});

  @override
  Widget build(BuildContext context) {
    return VidBtn(
      onTap: () {
        controller.settingsOverlayController.toggle();
      },
      icon: HqIcons.vidSettings,
      style: style,
    );
  }
}
