import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';

class SettingsBtnPage extends StatelessWidget {
  final Function() onTap;
  final int itemCount;
  final EdgeInsets? padding;
  final Function(int) builder;

  const SettingsBtnPage({super.key, required this.onTap, required this.itemCount, this.padding, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HqListTile(leading: const Icon(Icons.arrow_back), title: "", onPress: onTap),
        SizedBox(height: HqSpacing.s2),
        Expanded(
          child: ListView(padding: padding, children: List.generate(itemCount, (index) => builder(index))),
        ),
      ],
    );
  }
}
