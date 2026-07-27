import 'package:animated_visibility/animated_visibility.dart';
import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';
import 'package:video/controller.dart';
import 'package:video/utils/extentions.dart';

class SkipBtn extends StatelessWidget {
  const SkipBtn({super.key, this.visible = true, required this.controller});

  final bool visible;
  final Controller controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibility(
      visible: (visible && (controller.currentChapter?.isSkippable ?? false)),
      enterDuration: 300.ms,
      exitDuration: 300.ms,
      enter: fadeIn(curve: Curves.easeInCubic) + slideInHorizontally(curve: Curves.easeOutCubic),
      exit: fadeOut(curve: Curves.easeOutCubic),
      child: OutlinedButton(
        onPressed: () {
          controller.skipChapter();
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.black.putOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: HqBorderRadius.br1.asRadius),
        ),
        child: HqText("Skip ${controller.currentChapter?.name ?? ""}"),
      ),
    );
  }
}
