import 'package:flutter/material.dart';
import 'package:cineui/constants/radius.dart';
import 'package:cineui/cineui.dart';

class CineChip extends StatefulWidget {
  final String text;
  final bool highlight;
  final Function()? onTap;

  const CineChip({super.key, this.highlight = false, required this.text, this.onTap});

  @override
  State<CineChip> createState() => _HqChipState();
}

class _HqChipState extends State<CineChip> {
  late bool _focused;
  late bool _hovered;

  @override
  void initState() {
    _focused = false;
    _hovered = false;
    super.initState();
  }

  Color get boxColor {
    if (widget.highlight) {
      return _hovered ? CineColorScheme.onSurfaceBright : CineColorScheme.onSurfaceBright.putOpacity(0.9);
    } else {
      return _hovered ? CineColorScheme.surfaceContainer : CineColorScheme.surfaceContainer.putOpacity(0.9);
    }
  }

  Color get textColor {
    if (widget.highlight) {
      return _hovered ? CineColorScheme.surfaceContainer : CineColorScheme.surfaceContainer.putOpacity(0.9);
    } else {
      return _hovered ? CineColorScheme.onSurfaceBright : CineColorScheme.onSurfaceContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onTap?.call(),
      onFocusChange: (value) {
        _focused = value;
        setState(() {});
      },
      onHover: (value) {
        _hovered = value;
        setState(() {});
      },
      borderRadius: CineBorderRadius.br2.asRadius,
      child: Ink(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: CineBorderRadius.br2.asRadius,
          border: Border.all(color: _focused ? CineColorScheme.onSurfaceBright : CineColorScheme.transparent),
        ),
        child: CineText(widget.text, style: CineTextStyles.b3, color: textColor),
      ),
    );
  }
}
