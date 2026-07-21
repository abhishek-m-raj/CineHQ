import 'package:flutter/material.dart';
import 'package:cineui/components/chip.dart';
import 'package:cineui/constants/radius.dart';
import 'package:cineui/constants/theme/color_scheme.dart';
import 'package:cineui/utils/radius.dart';

class CineDialog {
  final Widget? title;
  final Widget? content;
  final List<CineChip>? actions;
  final bool isDismissible;
  final EdgeInsets? padding;

  CineDialog({this.title, this.content, this.actions, this.isDismissible = true, this.padding});

  void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: UniqueKey().toString(),
      useRootNavigator: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          title: title,
          backgroundColor: CineColorScheme.surfaceContainer,
          contentPadding: padding,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: CineBorderRadius.br2.asRadius),
          content: content,
          actions: actions,
          scrollable: true,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOutQuart).animate(animation),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.6,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
            child: child,
          ),
        );
      },
    );
  }
}
