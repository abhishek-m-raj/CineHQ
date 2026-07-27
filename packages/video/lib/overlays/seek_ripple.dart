import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';
import 'package:video/controller.dart';
import 'dart:async';
import '../other/responsive.dart';

class ForwardAndRewindOverlay extends StatefulWidget {
  final Controller controller;

  const ForwardAndRewindOverlay({super.key, required this.controller});

  @override
  ForwardAndRewindOverlayState createState() => ForwardAndRewindOverlayState();
}

class ForwardAndRewindOverlayState extends State<ForwardAndRewindOverlay> {
  late bool showRewind, showForward;
  late int rewindSeconds, forwardSeconds;

  Timer? rewindTimer;
  Timer? forwardTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.seek = seekFunc;
    showRewind = false;
    showForward = false;
    rewindSeconds = 0;
    forwardSeconds = 0;
  }

  @override
  void dispose() {
    super.dispose();
    rewindTimer?.cancel();
    forwardTimer?.cancel();
  }

  void seekFunc(RippleSide side) {
    final int seekSecond = widget.controller.settings.seekSeconds;
    final player = widget.controller.player;
    widget.controller.isForwardRewinding = true;
    widget.controller.setControlsVisibility(false);
    if (side == RippleSide.left) {
      showRewind = true;
      rewindSeconds += seekSecond;
      final Duration value = player.state.position - Duration(seconds: rewindSeconds);
      final bool isLower = value.isNegative;
      player.seek(!isLower ? value : Duration.zero);
      rewindTimer?.cancel();
      rewindTimer = Timer(const Duration(milliseconds: 800), () async {
        showRewind = false;
        widget.controller.isForwardRewinding = false;
        if (mounted) {
          setState(() {});
        }
        await Future.delayed(const Duration(milliseconds: 500), () {
          if (!showRewind) rewindSeconds = 0;
        });
      });
    } else {
      showForward = true;
      forwardSeconds += seekSecond;
      final Duration value = player.state.position + Duration(seconds: forwardSeconds);
      final bool isAbove = value > player.state.duration;
      player.seek(!isAbove ? value : player.state.duration);
      forwardTimer?.cancel();
      forwardTimer = Timer(const Duration(milliseconds: 900), () async {
        showForward = false;
        widget.controller.isForwardRewinding = false;
        if (mounted) {
          setState(() {});
        }
        await Future.delayed(const Duration(milliseconds: 500), () {
          if (!showForward) forwardSeconds = 0;
        });
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  Widget layout({required Widget rewind, required Widget forward}) {
    return Row(
      children: [
        Expanded(child: rewind),
        Container(width: getDimensions().width / 3, color: Colors.transparent),
        Expanded(child: forward),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: layout(
        rewind: CustomOpacityTransition(
          visible: showRewind,
          child: ForwardAndRewindRippleSide(text: "$rewindSeconds Sec", side: RippleSide.left),
        ),
        forward: CustomOpacityTransition(
          visible: showForward,
          child: ForwardAndRewindRippleSide(text: "$forwardSeconds Sec", side: RippleSide.right),
        ),
      ),
    );
  }
}

enum RippleSide { left, right }

class ForwardAndRewindRippleSide extends StatelessWidget {
  const ForwardAndRewindRippleSide({super.key, required this.side, required this.text});

  final RippleSide side;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ripple = Colors.grey[900]?.putOpacity(0.35);
    return CustomPaint(
      size: Size.infinite,
      painter: side == RippleSide.left ? _RippleLeftPainter(ripple!) : _RippleRightPainter(ripple!),
      child: Padding(
        padding: side == RippleSide.left ? const EdgeInsets.only(right: 10) : const EdgeInsets.only(left: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            side == RippleSide.left
                ? HqIcon(icon: HqIcons.vidFastRewind, size: 30)
                : HqIcon(icon: HqIcons.vidFastForward, size: 30),
            HqText(text, style: HqTextStyles.h2),
          ],
        ),
      ),
    );
  }
}

class _RippleLeftPainter extends CustomPainter {
  _RippleLeftPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..arcTo(Offset(size.width * 0.75, 0.0) & Size(size.width / 4, size.height), -1.5, 3, false)
        ..lineTo(0.0, size.height)
        ..lineTo(0.0, 0.0),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _RippleRightPainter extends CustomPainter {
  _RippleRightPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..arcTo(Offset.zero & Size(size.width / 4, size.height), -1.5, -3.3, false)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, 0.0),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CustomOpacityTransition extends StatelessWidget {
  const CustomOpacityTransition({super.key, this.visible, this.child});

  final bool? visible;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible!,
      child: AnimatedOpacity(
        curve: Curves.ease,
        duration: const Duration(milliseconds: 500),
        opacity: visible! ? 1 : 0,
        child: child!,
      ),
    );
  }
}
