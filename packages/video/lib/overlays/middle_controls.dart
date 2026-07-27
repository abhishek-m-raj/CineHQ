import 'package:animated_visibility/animated_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video/controller.dart';
import 'package:video/style/style.dart';
import 'package:video/widgets/btns/pause_btn.dart';

class MiddleControlsOverlay extends StatelessWidget {
  final Controller controller;
  final VidStyle style;

  const MiddleControlsOverlay({super.key, required this.controller, required this.style});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.player.stream.buffering,
      builder: (context, snapshot) {
        final String? img = controller.coverImg ?? controller.datasource?.coverImg;
        final bool isCoverLoading = (controller.player.state.duration == Duration.zero && img != null);
        final bool buffering = snapshot.data ?? false;
        final bool visible = controller.isControlsVisble && !(buffering || isCoverLoading);
        return IgnorePointer(
          ignoring: !visible,
          child: Center(
            child: AnimatedVisibility(
              visible: visible,
              enterDuration: 300.ms,
              exitDuration: 300.ms,
              enter: fadeIn(curve: Curves.easeOutCubic) + scaleIn(curve: Curves.easeOutCubic),
              exit: fadeOut(curve: Curves.easeOutCubic),
              child: PauseBtn(controller: controller, style: style),
            ),
          ),
        );
      },
    );
  }
}
