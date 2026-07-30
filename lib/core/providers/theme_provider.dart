import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codoky/core/logging/app_logger.dart';

const String kAppThemeModeKey = 'app_theme_mode';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  SharedPreferences? _prefs;

  ThemeNotifier([SharedPreferences? prefs]) : super(ThemeMode.system) {
    if (prefs != null) {
      _prefs = prefs;
      _loadThemeMode();
    } else {
      _initPrefs();
    }
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadThemeMode();
    } catch (e) {
      AppLogger.w('Could not initialize SharedPreferences for ThemeNotifier: $e');
    }
  }

  void _loadThemeMode() {
    final savedModeStr = _prefs?.getString(kAppThemeModeKey);
    if (savedModeStr != null) {
      switch (savedModeStr) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        case 'system':
        default:
          state = ThemeMode.system;
          break;
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      String modeStr = 'system';
      if (mode == ThemeMode.light) {
        modeStr = 'light';
      } else if (mode == ThemeMode.dark) {
        modeStr = 'dark';
      }
      await _prefs?.setString(kAppThemeModeKey, modeStr);
      AppLogger.i('ThemeMode updated to: $modeStr');
    } catch (e) {
      AppLogger.w('Failed to save ThemeMode to SharedPreferences: $e');
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
