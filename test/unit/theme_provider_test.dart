import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codoky/core/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeNotifier Unit Tests', () {
    test('Initial theme state should default to ThemeMode.system when no saved preference exists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeNotifier(prefs);

      expect(notifier.state, equals(ThemeMode.system));
    });

    test('Loads ThemeMode.dark correctly from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        kAppThemeModeKey: 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeNotifier(prefs);

      expect(notifier.state, equals(ThemeMode.dark));
    });

    test('Loads ThemeMode.light correctly from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        kAppThemeModeKey: 'light',
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeNotifier(prefs);

      expect(notifier.state, equals(ThemeMode.light));
    });

    test('setThemeMode updates state and persists choice to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeNotifier(prefs);

      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, equals(ThemeMode.dark));
      expect(prefs.getString(kAppThemeModeKey), equals('dark'));

      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state, equals(ThemeMode.light));
      expect(prefs.getString(kAppThemeModeKey), equals('light'));

      await notifier.setThemeMode(ThemeMode.system);
      expect(notifier.state, equals(ThemeMode.system));
      expect(prefs.getString(kAppThemeModeKey), equals('system'));
    });
  });
}
