import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:cineui/utils/colors.dart';
import 'package:cineui/utils/radius.dart';
import '../../constants/radius.dart';
import '../../constants/theme/color_scheme.dart';
import '../../typography/textstyles.dart';
import '../text.dart';

class CineDropDown<T> extends StatefulWidget {
  const CineDropDown({
    super.key,
    required this.width,
    required this.hintText,
    required this.items,
    required this.initialItem,
    required this.onChange,
  });

  final double width;
  final String hintText;
  final List<T> items;
  final T? initialItem;
  final Function(T) onChange;

  @override
  State<CineDropDown<T>> createState() => _HqDropDownState<T>();
}

class _HqDropDownState<T> extends State<CineDropDown<T>> {
  late FocusNode _focusNode;
  bool _focused = false;
  bool _isHovered = false;
  late T? current;

  @override
  void initState() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _focused = _focusNode.hasFocus;
      });
    });
    current = widget.initialItem;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CineDropDown<T> oldWidget) {
    setState(() {
      current = widget.initialItem;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: CineBorderRadius.br2.asRadius,
          color: _focused || _isHovered
              ? CineColorScheme.surfaceContainer.putOpacity(0.9)
              : CineColorScheme.surfaceContainer,
          border: _focused || _isHovered ? Border.all(color: CineColorScheme.onSurface, width: 1) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 30,
        child: DropdownButton<T>(
          focusColor: Colors.white,
          value: current,
          elevation: 5,
          dropdownColor: Theme.of(context).colorScheme.onSecondary,
          focusNode: _focusNode,
          underline: SizedBox.shrink(),
          items: widget.items.toSet().map((T value) {
            return DropdownMenuItem(
              value: value,
              child: CineText(value.toString(), style: CineTextStyles.btnText, color: CineColorScheme.onSurfaceContainer),
            );
          }).toList(),
          hint: CineText(widget.hintText, style: CineTextStyles.btnText, color: CineColorScheme.onSurfaceContainer),
          borderRadius: BorderRadius.circular(5),
          onTap: () {
            if (!Device.isTv) {
              _focusNode.unfocus();
            }
          },
          onChanged: (T? value) {
            if (value != null) {
              setState(() {
                widget.onChange(value);
                current = value;
              });
            }
          },
        ),
      ),
    );
  }
}
