import 'package:animated_visibility/animated_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video/ui/ui.dart';
import 'package:video/controller.dart';

class ShadeOverlay extends StatelessWidget {
  final Controller controller;

  const ShadeOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: StreamBuilder<bool>(
        stream: controller.player.stream.buffering,
        builder: (context, snapshot) {
          return AnimatedVisibility(
            visible: controller.isControlsVisble || (snapshot.data ?? controller.player.state.buffering),
            enterDuration: 400.ms,
            exitDuration: 300.ms,
            enter: fadeIn(curve: Curves.easeOutCubic),
            exit: fadeOut(curve: Curves.easeOutCubic),
            child: Stack(
              children: [
                // top
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black12.putOpacity(0.2),
                          Colors.black.putOpacity(0.4),
                          Colors.black.putOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // bottom
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black12.putOpacity(0.2),
                          Colors.black.putOpacity(0.3),
                          Colors.black.putOpacity(0.6),
                          Colors.black.putOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
