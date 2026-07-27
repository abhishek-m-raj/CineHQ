import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';
import 'package:video/controller.dart';
import 'package:video/style/style.dart';
import 'package:video/widgets/btns/btn.dart';

class FullScreenBtn extends StatefulWidget {
  final Controller controller;
  final VidStyle style;

  const FullScreenBtn({super.key, required this.style, required this.controller});

  @override
  State<FullScreenBtn> createState() => FullScreenBtnState();
}

class FullScreenBtnState extends State<FullScreenBtn> {
  void fullScreen() {
    if (!widget.controller.isFullscreen) {
      widget.controller.enFullscreen();
    } else {
      widget.controller.exFullscreen();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return VidBtn(
      onTap: () => fullScreen(),
      icon: widget.controller.isFullscreen ? HqIcons.vidCloseFullscreen : HqIcons.vidFullscreen,
      style: widget.style,
    );
  }
}
