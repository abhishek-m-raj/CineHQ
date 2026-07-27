import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';
import 'package:video/widgets/btns/btn.dart';
import '../../controller.dart';
import '../../style/style.dart';
import '../../other/responsive.dart';

class PauseBtn extends StatelessWidget {
  final Controller controller;
  final VidStyle style;

  const PauseBtn({super.key, required this.controller, required this.style});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: controller.player.stream.playing,
      builder: (context, snapshot) {
        final bool playing = snapshot.data ?? controller.player.state.playing;
        return VidBtn(
          focusNode: controller.playBtnFocusNode,
          onTap: () => controller.player.playOrPause(),
          icon: playing ? HqIcons.vidPause : HqIcons.vidPlay,
          style: style,
          size: overlayMainBtnSize(),
        );
      },
    );
  }
}
