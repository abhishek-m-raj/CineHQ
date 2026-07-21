import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

sealed class IconSource {}

class NormalIcon extends IconSource {
  final IconData icon;
  NormalIcon(this.icon);
}

class ExternalIcon extends IconSource {
  final List<List<dynamic>> icon;
  ExternalIcon(this.icon);
}

class CineIcon extends StatelessWidget {
  final IconSource icon;
  final Color? color;
  final double? size;
  final double? strokeWidth;

  const CineIcon({super.key, required this.icon, this.color, this.size, this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    if (icon is ExternalIcon) {
      final externalIcon = icon as ExternalIcon;
      return HugeIcon(
        icon: externalIcon.icon,
        color: color ?? Theme.of(context).iconTheme.color,
        size: size ?? 24,
        strokeWidth: strokeWidth ?? 2,
      );
    } else {
      return Icon((icon as NormalIcon).icon, color: color, size: size);
    }
  }
}
