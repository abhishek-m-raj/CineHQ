import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

const double overlayMainBtnSizeRelativeToScreen = 5;
const double overlaySeekBtnSizeRelativeToScreen = 5;
const double buttonsSizeRelativeToScreen = 2.5;
const double paddingSizeRelativeToScreen = 0.2;
const double fontSizeRelativeToScreen = 1;

const double maxOverlayMainBtnSize = 120;
const double maxOverlaySeekBtnSize = 85;
const double maxButtonsSize = 45;
const double maxPaddingSize = 8;
const double maxFontSize = 20;

const double minOverlayMainBtnSize = 60;
const double minOverlaySeekBtnSize = 20;
const double minButtonsSize = 30;
const double minPaddingSize = 5;
const double minFontSize = 10;

double ip(double percent) {
  final data = getDimensions();
  return getInch(data) * percent / 100;
}

double wp(double percent) {
  final data = getDimensions();
  return data.width * percent / 100;
}

double hp(double percent) {
  final data = getDimensions();
  return data.height * percent / 100;
}

Size getDimensions() {
  final data = MediaQueryData.fromView(PlatformDispatcher.instance.views.first);
  return data.size;
}

double getInch(Size data) {
  final double width = data.width;
  final double height = data.height;
  return sqrt((width * width) + (height * height));
}

double overlayMainBtnSize() {
  final value = ip(overlayMainBtnSizeRelativeToScreen);
  if (value < minOverlayMainBtnSize) {
    return minOverlayMainBtnSize;
  } else {
    return min(value, maxOverlayMainBtnSize);
  }
}

double overlaySeekBtnSize() {
  final value = ip(overlayMainBtnSizeRelativeToScreen);
  if (value < minOverlaySeekBtnSize) {
    return minOverlaySeekBtnSize;
  } else {
    return min(value, maxOverlaySeekBtnSize);
  }
}

double buttonSize() {
  final value = ip(buttonsSizeRelativeToScreen);
  if (value < minButtonsSize) {
    return minButtonsSize;
  } else {
    return min(value, maxButtonsSize);
  }
}

double paddingSize() {
  final value = ip(paddingSizeRelativeToScreen);
  if (value < minPaddingSize) {
    return minPaddingSize;
  } else {
    return min(value, maxPaddingSize);
  }
}

double fontSize() {
  final value = ip(fontSizeRelativeToScreen);
  if (value < minFontSize) {
    return minFontSize;
  } else {
    return min(value, maxFontSize);
  }
}
