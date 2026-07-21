import 'package:flutter/material.dart';
import 'package:cineui/constants/radius.dart';
import 'package:cineui/cineui.dart';

class CineTextBtn extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;

  const CineTextBtn(this.text, {super.key, this.onPress});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: CineBorderRadius.br1.asRadius),
        padding: EdgeInsets.all(CineSpacing.s1),
      ),
      onPressed: onPress,
      child: CineText(text, style: CineTextStyles.b2),
    );
  }
}
