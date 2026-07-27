import 'package:animated_visibility/animated_visibility.dart';
import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';
import 'package:video/controller.dart';
import 'package:video/utils/extentions.dart';

class MiniProgressOverlay extends StatelessWidget {
  final Controller controller;

  const MiniProgressOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: StreamBuilder(
          stream: controller.player.stream.position,
          builder: (context, snapshot) {
            final Duration pos = controller.seekDragedDur ?? controller.player.state.position;
            final Duration dur = controller.player.state.duration;
            final double progress = (pos.inSeconds / dur.inSeconds);
            return AnimatedVisibility(
              visible: controller.isDragSeeking || controller.isForwardRewinding,
              enter: scaleIn(initialScale: 0.9, alignment: Alignment.topCenter, curve: Curves.easeInCubic) + fadeIn(),
              exit: scaleOut(targetScale: 0.9, alignment: Alignment.topCenter, curve: Curves.easeInCubic) + fadeOut(),
              enterDuration: const Duration(milliseconds: 100),
              exitDuration: const Duration(milliseconds: 90),
              child: Container(
                width: 250,
                height: 75,
                alignment: Alignment.center,
                margin: const EdgeInsets.all(10),
                padding: EdgeInsets.all(HqSpacing.s2),
                decoration: BoxDecoration(
                  color: Colors.black87.putOpacity(0.3),
                  borderRadius: HqBorderRadius.br3.asRadius,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        HqIcon(icon: HqIcons.vidFastForward),
                        SizedBox(width: HqSpacing.s2),
                        HqText("${pos.label()} / ${dur.label()}", style: HqTextStyles.b1),
                      ],
                    ),
                    SizedBox(height: HqSpacing.s2),
                    LinearProgressIndicator(
                      value: !progress.isNaN ? progress : null,
                      borderRadius: HqBorderRadius.br1.asRadius,
                      minHeight: HqSpacing.s2,
                      color: HqColorScheme.primary,
                      backgroundColor: HqColorScheme.onSecondary,
                      trackGap: 0,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
