import 'dart:async';
import 'package:animated_visibility/animated_visibility.dart';
import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video/controller.dart';
import 'package:video/style/style.dart';

class VolumeBrightnessOverlay extends StatefulWidget {
  final Controller controller;
  final VidStyle style;

  const VolumeBrightnessOverlay({super.key, required this.controller, required this.style});

  @override
  State<VolumeBrightnessOverlay> createState() => _VolumeBrightnessOverlayState();
}

class _VolumeBrightnessOverlayState extends State<VolumeBrightnessOverlay> {
  final List<StreamSubscription> _subs = [];
  Timer? volumeTimer;
  double volume = 0;
  bool isVolumeVisible = false;
  Timer? brightnesTimer;
  double brightnes = 0;
  bool isBrightnesVisible = false;

  @override
  void initState() {
    _subs.addAll([
      widget.controller.volume.stream.listen((e) {
        widget.controller.setControlsVisibility(false);
        setState(() {
          isVolumeVisible = true;
          volume = e;
        });
        volumeTimer?.cancel();
        volumeTimer = Timer(700.ms, () {
          isVolumeVisible = false;
        });
      }),
      widget.controller.brightness.stream.listen((e) {
        widget.controller.setControlsVisibility(false);
        setState(() {
          isBrightnesVisible = true;
          brightnes = e;
        });
        brightnesTimer?.cancel();
        brightnesTimer = Timer(700.ms, () {
          isBrightnesVisible = false;
        });
      }),
    ]);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    for (final i in _subs) {
      i.cancel();
    }
  }

  Widget indicator(IconData icon, bool isVisible, double value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        late final double height;
        if (Device.isMobile) {
          height = constraints.maxHeight / 2;
        } else {
          height = constraints.maxHeight / 4;
        }
        return AnimatedVisibility(
          visible: isVisible,
          enterDuration: 300.ms,
          exitDuration: 300.ms,
          enter: fadeIn(curve: Curves.easeOutCubic) + scaleIn(curve: Curves.easeOutCubic),
          exit: fadeOut(curve: Curves.easeOutCubic),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1 / 4,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      color: widget.style.volumeIndicatorBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      height: (value / 100) * height,
                      decoration: BoxDecoration(
                        color: widget.style.volumeIndicatorColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(left: 0, right: 0, bottom: 10, child: Icon(icon)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Row(
          children: [
            Expanded(child: Center(child: indicator(Icons.brightness_5, isBrightnesVisible, brightnes))),
            Expanded(child: Center(child: indicator(Icons.volume_up, isVolumeVisible, volume))),
          ],
        ),
      ),
    );
  }
}
