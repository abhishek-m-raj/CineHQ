import 'package:flutter/material.dart';
import 'package:cineui/constants/theme/color_scheme.dart';
import 'package:cineui/utils/colors.dart';
import '../../typography/textstyles.dart';
import '../text.dart';

class CineRadioBtn<T> extends StatefulWidget {
  final String? text;
  final String suffix;
  final T initialItem;
  final List<T> items;
  final Function(T) onChange;

  const CineRadioBtn({
    super.key,
    this.text,
    this.suffix = "",
    required this.initialItem,
    required this.items,
    required this.onChange,
  });

  @override
  State<CineRadioBtn<T>> createState() => _HqRadioBtnState<T>();
}

class _HqRadioBtnState<T> extends State<CineRadioBtn<T>> {
  late T? current;

  @override
  void initState() {
    current = widget.initialItem;
    super.initState();
  }

  String getText(T i) {
    if (i is! String) {
      return "$i${widget.suffix}";
    }
    return i;
  }

  Color getColor(T i) {
    return current == i ? CineColorScheme.primary : CineColorScheme.white.putOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ...widget.items.map((i) {
          return Padding(
            padding: const EdgeInsets.all(2),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                side: BorderSide(width: 2, color: getColor(i)),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  current = i;
                });
                widget.onChange(i);
              },
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: CineText(getText(i), style: CineTextStyles.b2, color: getColor(i)),
              ),
            ),
          );
        }),
      ],
    );
  }
}
