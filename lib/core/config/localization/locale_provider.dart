import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codoky/core/logging/app_logger.dart';

const String kAppLocaleKey = 'app_locale';
const Locale kDefaultLocale = Locale('vi');

class LocaleNotifier extends StateNotifier<Locale> {
  SharedPreferences? _prefs;

  LocaleNotifier([SharedPreferences? prefs]) : super(kDefaultLocale) {
    if (prefs != null) {
      _prefs = prefs;
      _loadLocale();
    } else {
      _initPrefs();
    }
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadLocale();
    } catch (e) {
      AppLogger.w('Could not initialize SharedPreferences for LocaleNotifier: $e');
    }
  }

  void _loadLocale() {
    final savedCode = _prefs?.getString(kAppLocaleKey);
    if (savedCode != null && savedCode.isNotEmpty) {
      state = Locale(savedCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      await _prefs?.setString(kAppLocaleKey, locale.languageCode);
      AppLogger.i('Locale updated to: ${locale.languageCode}');
    } catch (e) {
      AppLogger.w('Failed to save Locale to SharedPreferences: $e');
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
