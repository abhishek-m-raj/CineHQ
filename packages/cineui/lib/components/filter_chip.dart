import 'package:flutter/material.dart';
import 'package:cineui/components/chip.dart';

class CineFilterChip<T> extends StatefulWidget {
  final List<T> selected;
  final List<T> options;
  final Function(List<T>) onChange;

  const CineFilterChip({super.key, this.selected = const [], required this.options, required this.onChange});

  @override
  State<CineFilterChip<T>> createState() => _HqFilterChipState<T>();
}

class _HqFilterChipState<T> extends State<CineFilterChip<T>> {
  late List<T> _selected;

  @override
  void initState() {
    _selected = List.from(widget.selected, growable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: Wrap(
        runSpacing: 8,
        spacing: 8,
        children: [
          ...widget.options.map((i) {
            return CineChip(
              text: i.toString(),
              highlight: _selected.contains(i),
              onTap: () {
                if (_selected.contains(i)) {
                  _selected.remove(i);
                } else {
                  _selected.add(i);
                }
                widget.onChange(_selected);
                setState(() {});
              },
            );
          }),
        ],
      ),
    );
  }
}
