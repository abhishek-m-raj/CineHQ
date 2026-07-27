import 'package:animated_visibility/animated_visibility.dart';
import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';
import 'package:video/utils/extentions.dart';
import 'dart:async';
import '../controller.dart';

class TimeLabel extends StatefulWidget {
  final bool isVisible;
  final Controller controller;

  const TimeLabel({super.key, this.isVisible = true, required this.controller});

  @override
  State<TimeLabel> createState() => TimeLabelState();
}

class TimeLabelState extends State<TimeLabel> {
  late Duration position = widget.controller.player.state.position;
  late Duration duration = widget.controller.player.state.duration;

  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    subscriptions.addAll([
      widget.controller.player.stream.position.listen((event) {
        setState(() {
          position = event;
        });
      }),
      widget.controller.player.stream.duration.listen((event) {
        setState(() {
          duration = event;
        });
      }),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    for (final s in subscriptions) {
      s.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibility(
      visible: widget.isVisible,
      enterDuration: 300.ms,
      exitDuration: 300.ms,
      enter: fadeIn(curve: Curves.easeOutCubic) + slideInHorizontally(curve: Curves.easeOutCubic),
      exit: fadeOut(curve: Curves.easeOutCubic),
      child: Row(
        children: [
          HqText(position.label(), style: HqTextStyles.b2),
          HqText(' / ', style: HqTextStyles.b2),
          HqText(duration.label(), style: HqTextStyles.b2),
        ],
      ),
    );
  }
}
