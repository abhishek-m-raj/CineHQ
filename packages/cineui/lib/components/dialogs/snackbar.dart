import 'package:flutter/material.dart';
import 'package:cineui/components/icon.dart';
import 'package:cineui/components/text.dart';
import 'package:cineui/constants/spacing.dart';
import 'package:cineui/constants/theme/color_scheme.dart';
import 'package:cineui/typography/textstyles.dart';

class CineSnackbar {
  final IconSource? icon;
  final String? content;
  final String actionLabel;
  final VoidCallback? onActionTap;
  final Duration? duration;

  CineSnackbar({this.icon, this.content, this.actionLabel = "ok", this.onActionTap, this.duration});

  void show(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.down,
        duration: duration ?? const Duration(seconds: 4),
        content: Row(
          children: [
            if (icon != null) CineIcon(icon: icon!),
            SizedBox(width: CineSpacing.s2),
            CineText(content ?? "", style: CineTextStyles.b2, color: CineColorScheme.onSurface),
          ],
        ),
        persist: false,
        action: SnackBarAction(
          textColor: CineColorScheme.onSurface,
          label: actionLabel,
          onPressed:
              onActionTap ??
              () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
        ),
        backgroundColor: CineColorScheme.surfaceContainer,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(CineSpacing.s3),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: CineColorScheme.primary, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
