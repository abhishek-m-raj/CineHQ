import 'package:flutter/material.dart';

extension BorderUtils on double {
  BorderRadius get asRadius {
    return BorderRadius.circular(this);
  }
}
