import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:video/controller.dart';
import 'package:video/style/style.dart';
import 'package:video/ui/ui.dart';
import 'package:video/widgets/btns/btn.dart';

class BackBtn extends StatelessWidget {
  const BackBtn({super.key, required this.style, required this.controller});

  final VidStyle style;
  final Controller controller;

  @override
  Widget build(BuildContext context) {
    return VidBtn(
      icon: NormalIcon(Icons.arrow_back),
      style: style,
      onTap: () async {
        if (Device.isTv) {
          if (controller.isFullscreen) {
            controller.exFullscreen();
          } else {
            controller.onBack();
          }
        } else {
          Navigator.of(context).maybePop();
        }
      },
    );
  }
}
