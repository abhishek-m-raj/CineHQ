import 'package:flutter/material.dart';
import 'package:cineui/typography/fonts.dart';

class CineTextStyles {
  static TextStyle get h1 =>
      CineFonts.poppins.copyWith(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 0.5, height: 1.1);
  static TextStyle get h2 =>
      CineFonts.poppins.copyWith(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.1);
  static TextStyle get h3 =>
      CineFonts.poppins.copyWith(fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0, height: 1.15);
  static TextStyle get h4 =>
      CineFonts.poppins.copyWith(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0, height: 1.15);
  static TextStyle get h5 =>
      CineFonts.poppins.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0, height: 1.15);
  static TextStyle get h6 =>
      CineFonts.poppins.copyWith(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0, height: 1.15);

  static TextStyle get b1 =>
      CineFonts.rubik.copyWith(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.4);
  static TextStyle get b2 =>
      CineFonts.rubik.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.2, height: 1.4);
  static TextStyle get b3 =>
      CineFonts.rubik.copyWith(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0, height: 1.4);

  static TextStyle get btnText =>
      CineFonts.rubik.copyWith(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.75, height: 1.2);
}
