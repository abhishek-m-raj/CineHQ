import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

double ip(double percent) {
  final data = getDimensions();
  return getInch(data) * percent / 100;
}

Size getDimensions() {
  final data = MediaQueryData.fromView(PlatformDispatcher.instance.views.first);
  return data.size;
}

double getFontSize(double relativeSize, double minVal, double maxVal) {
  final value = ip(relativeSize);
  if (value < minVal) {
    return minVal;
  } else {
    return min(value, maxVal);
  }
}

double getInch(Size data) {
  final double width = data.width;
  final double height = data.height;
  return sqrt((width * width) + (height * height));
}
