import 'package:flutter/material.dart';

extension ColorUtils on Color {
  Color putOpacity(double val) {
    return withAlpha((255 * val).toInt());
  }
}
