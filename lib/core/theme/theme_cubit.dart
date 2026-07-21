import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;
  static const _key = 'theme_mode';

  ThemeCubit(this._prefs) : super(ThemeMode.dark) {
    _load();
  }

  void _load() {
    try {
      final isLight = _prefs.getBool(_key) ?? false;
      emit(isLight ? ThemeMode.light : ThemeMode.dark);
    } catch (_) {
      emit(ThemeMode.dark);
    }
  }

  Future<void> toggleTheme() async {
    try {
      if (state == ThemeMode.dark) {
        emit(ThemeMode.light);
        await _prefs.setBool(_key, true);
      } else {
        emit(ThemeMode.dark);
        await _prefs.setBool(_key, false);
      }
    } catch (_) {}
  }
}
