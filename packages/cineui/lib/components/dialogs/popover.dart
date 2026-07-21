import 'package:flutter/material.dart';
import 'package:cineui/constants/radius.dart';
import 'package:cineui/constants/theme/color_scheme.dart';
import 'package:popover/popover.dart';
export 'package:popover/popover.dart';

class CinePopover {
  final Widget content;
  final PopoverDirection direction;

  const CinePopover({required this.content, this.direction = PopoverDirection.top});

  void show(BuildContext context) {
    showPopover(
      context: context,
      bodyBuilder: (_) => content,
      backgroundColor: CineColorScheme.surfaceContainer,
      radius: CineBorderRadius.br2,
      transition: PopoverTransition.scale,
      direction: direction,
    );
  }
}
