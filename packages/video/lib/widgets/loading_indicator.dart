import 'dart:math';
import 'package:animated_visibility/animated_visibility.dart';
import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';
import 'package:video/utils/extentions.dart';
import 'package:video/style/style.dart';

class LoadingIndicator extends StatelessWidget {
  final VidStyle style;
  final bool buffering;

  const LoadingIndicator({super.key, required this.style, required this.buffering});

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibility(
      visible: buffering,
      enterDuration: 200.ms,
      exitDuration: 200.ms,
      enter: fadeIn(curve: Curves.easeIn),
      exit: fadeOut(curve: Curves.easeOut),
      child: Center(child: Loader()),
    );
  }
}

class Loader extends StatefulWidget {
  const Loader({super.key});

  @override
  LoaderState createState() => LoaderState();
}

class LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 800))
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..repeat();

    _animation = CurveTween(curve: Curves.easeOutSine).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * pi,
          child: CustomPaint(size: Size(70, 70), painter: _LoaderPainter()),
        );
      },
    );
  }
}

class _LoaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final angle = -pi / 2;

    // Arc trail with a sweep gradient
    final trailPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * pi,
        colors: [
          Colors.transparent,
          HqColorScheme.secondaryContainer.putOpacity(0.3),
          HqColorScheme.secondaryContainer,
          HqColorScheme.primary,
          Colors.white,
        ],
        stops: [0.0, 0.35, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Draw the full arc with gradient trail
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 4), angle, 2 * pi, false, trailPaint);

    // Glowing white dot at the top
    final dotPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 15);
    final dotRadius = 4.0;
    final dotOffset = Offset(center.dx - (radius - 4) * sin(angle), center.dy - (radius - 4) * cos(angle));
    canvas.drawCircle(dotOffset, dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
