import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';
import 'package:video/style/style.dart';
import 'package:video/widgets/btns/btn.dart';
import '../../controller.dart';

class MuteBtn extends StatelessWidget {
  final Controller controller;
  final VidStyle style;

  const MuteBtn({super.key, required this.style, required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: controller.volume.stream,
      builder: (context, snapshot) {
        return FutureBuilder<bool>(
          future: controller.volume.isMuted,
          builder: (context, snapshot) {
            final bool muted = snapshot.data ?? false;
            return VidBtn(
              onTap: () => controller.volume.setMute(),
              icon: muted ? HqIcons.vidMuted : HqIcons.vidVolume,
              style: style,
            );
          },
        );
      },
    );
  }
}
