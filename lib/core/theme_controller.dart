import 'package:flutter/material.dart';

class AppThemeController {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  static void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }
}
