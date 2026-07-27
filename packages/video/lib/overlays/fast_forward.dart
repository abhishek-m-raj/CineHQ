import 'package:animated_visibility/animated_visibility.dart';
import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';
import 'package:video/controller.dart';

class FastForwardOverlay extends StatelessWidget {
  final Controller controller;

  const FastForwardOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: StreamBuilder(
          stream: controller.player.stream.rate,
          builder: (context, snapshot) {
            final double playbackRate = snapshot.data ?? 0;
            return AnimatedVisibility(
              visible: controller.isFastForwarding,
              enter: scaleIn(initialScale: 0.8, alignment: Alignment.topCenter, curve: Curves.easeInCubic) + fadeIn(),
              exit: scaleOut(targetScale: 0.8, alignment: Alignment.topCenter, curve: Curves.easeInCubic) + fadeOut(),
              enterDuration: const Duration(milliseconds: 100),
              exitDuration: const Duration(milliseconds: 80),
              child: Container(
                width: 70,
                height: 40,
                alignment: Alignment.center,
                margin: EdgeInsets.all(HqSpacing.s2),
                decoration: BoxDecoration(
                  color: Colors.black54.putOpacity(0.3),
                  borderRadius: HqBorderRadius.br2.asRadius,
                ),
                child: HqText("${playbackRate.toString()} x", style: HqTextStyles.h4),
              ),
            );
          },
        ),
      ),
    );
  }
}
