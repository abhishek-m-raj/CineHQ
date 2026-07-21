import 'package:flutter/material.dart';
import 'package:cineui/constants/theme/color_scheme.dart';
import 'package:cineui/utils/colors.dart';

class CineSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChange;

  const CineSwitch({super.key, required this.value, this.onChange});

  @override
  CineSwitchState createState() => CineSwitchState();
}

class CineSwitchState extends State<CineSwitch> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didChangeDependencies() {
    _value = widget.value;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return CineColorScheme.inversePrimary;
        }
        return CineColorScheme.onPrimaryContainer;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return CineColorScheme.secondary;
        }
        return CineColorScheme.onPrimaryContainer.putOpacity(0.1);
      }),
      onChanged: (newValue) {
        setState(() {
          _value = newValue;
        });
        if (widget.onChange != null) {
          widget.onChange!(newValue);
        }
      },
    );
  }
}
