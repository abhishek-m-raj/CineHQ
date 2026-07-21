import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cineui/constants/theme/color_scheme.dart';

class CineSkelton extends StatelessWidget {
  final EdgeInsets? padding;
  final BoxShape? shape;
  final double? width;
  final double? height;

  const CineSkelton({
    super.key,
    this.padding,
    this.shape,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      onComplete: (controller) => controller.repeat(reverse: true),
      effects: [
        if (Device.isWeb)
          FadeEffect(delay: const Duration(milliseconds: 600), begin: 0.5, duration: const Duration(milliseconds: 500)),
        if (!Device.isWeb)
          ShimmerEffect(
            color: Colors.grey[800],
            delay: const Duration(milliseconds: 800),
            duration: const Duration(milliseconds: 500),
          ),
      ],
      child: Container(
        margin: padding ?? EdgeInsets.zero,
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: shape ?? BoxShape.rectangle,
          color: CineColorScheme.surfaceBright,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
      ).animate().fadeIn(),
    );
  }
}
