import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:cineui/components/filter_chip.dart';
import 'package:cineui/components/text.dart';
import 'package:cineui/constants/icons.dart';
import 'package:cineui/constants/radius.dart';
import 'package:cineui/constants/theme/color_scheme.dart';
import 'package:cineui/utils/colors.dart';
import 'package:cineui/utils/radius.dart';
import '../../constants/spacing.dart';
import '../../typography/textstyles.dart';
import 'package:cineui/components/icon.dart';
import 'radio.dart';
import 'switch.dart';

class CineListTile extends StatefulWidget {
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? leading;
  final IconSource? leadingIcon;
  final Widget? trailing;
  final EdgeInsets? padding;
  final bool filled;
  final VoidCallback? onPress;
  final bool endArrow;
  final FocusNode? focusNode;

  const CineListTile({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.leading,
    this.leadingIcon,
    this.trailing,
    this.padding,
    this.filled = false,
    this.onPress,
    this.endArrow = false,
    this.focusNode,
  });

  @override
  State<CineListTile> createState() => _HqListTileState();
}

class _HqListTileState extends State<CineListTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: CineBorderRadius.br2.asRadius,
          border: (_focused && Device.isTv) ? Border.all(color: CineColorScheme.outline, width: 2) : null,
        ),
        child: ListTile(
          focusNode: widget.focusNode,
          onFocusChange: (val) {
            setState(() {
              _focused = val;
            });
          },
          leading:
              widget.leading ??
              (widget.leadingIcon != null
                  ? Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: CineBorderRadius.br2.asRadius,
                        color: CineColorScheme.primary.putOpacity(0.1),
                      ),
                      child: CineIcon(icon: widget.leadingIcon!, color: CineColorScheme.primary),
                    )
                  : null),
          title:
              widget.titleWidget ??
              (widget.title != null
                  ? CineText(widget.title, style: CineTextStyles.b2, color: CineColorScheme.onSurface)
                  : null),
          subtitle:
              widget.subtitleWidget ??
              (widget.subtitle != null
                  ? CineText(widget.subtitle!, style: CineTextStyles.b3, color: CineColorScheme.secondary.putOpacity(0.8))
                  : null),
          tileColor: (widget.filled == true) ? CineColorScheme.surfaceBright.putOpacity(0.3) : null,
          enabled: !(widget.onPress == null),
          contentPadding: widget.padding,
          onTap: widget.onPress,
          shape: RoundedRectangleBorder(borderRadius: CineBorderRadius.br2.asRadius),
          trailing: widget.trailing ?? (widget.endArrow ? CineIcon(icon: CineIcons.arrowRight) : null),
        ),
      ),
    );
  }
}

class CineSwitchListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final Function(bool) onChange;

  const CineSwitchListTile({super.key, required this.title, this.subtitle, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return CineListTile(
      title: title,
      subtitle: subtitle,
      filled: true,
      padding: EdgeInsets.symmetric(vertical: CineSpacing.s3, horizontal: CineSpacing.s4),
      trailing: CineSwitch(value: value, onChange: (i) => onChange(i)),
    );
  }
}

class CineRadioListTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String suffix;
  final T initialItem;
  final List<T> items;
  final Function(T) onChange;

  const CineRadioListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.suffix = "",
    required this.initialItem,
    required this.items,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return CineListTile(
      title: title,
      subtitleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            CineText(subtitle!, style: CineTextStyles.b3, color: CineColorScheme.secondary.putOpacity(0.8)),
          ],
          SizedBox(height: CineSpacing.s4),
          CineRadioBtn(initialItem: initialItem, items: items, suffix: suffix, onChange: (i) => onChange(i)),
        ],
      ),
      filled: true,
      padding: EdgeInsets.symmetric(vertical: CineSpacing.s3, horizontal: CineSpacing.s4),
    );
  }
}

class CineFilterChipListTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<T> selected;
  final List<T> options;
  final Function(List<T>) onChange;

  const CineFilterChipListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.options,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return CineListTile(
      title: title,
      filled: true,
      padding: EdgeInsets.symmetric(vertical: CineSpacing.s3, horizontal: CineSpacing.s4),
      subtitleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CineText(subtitle, style: CineTextStyles.b3, color: CineColorScheme.secondary.putOpacity(0.8)),
          SizedBox(height: CineSpacing.s2),
          CineFilterChip(selected: selected, options: options, onChange: (val) => onChange(val)),
        ],
      ),
    );
  }
}
