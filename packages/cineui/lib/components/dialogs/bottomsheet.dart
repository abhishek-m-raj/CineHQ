import 'package:flutter/material.dart';
import 'package:cineui/constants/radius.dart';
import 'package:cineui/constants/theme/color_scheme.dart';
import 'package:cineui/utils/radius.dart';

class CineBottomSheet {
  final Widget Function(BuildContext) builder;

  const CineBottomSheet({required this.builder});

  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: builder,
      elevation: 2,
      isScrollControlled: true,
      backgroundColor: CineColorScheme.surfaceContainer,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: CineBorderRadius.br3.asRadius.topLeft,
          topRight: CineBorderRadius.br3.asRadius.topRight,
        ),
      ),
    );
  }
}
