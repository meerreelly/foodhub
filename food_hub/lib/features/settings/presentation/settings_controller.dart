import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

final settingsControllerProvider = StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController()..load();
});

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController()
      : super(
          const AppSettings(
            themeMode: ThemeMode.system,
            languageCode: 'uk',
          ),
        );

  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language_code';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      themeMode: _themeFromString(prefs.getString(_themeKey)),
      languageCode: prefs.getString(_languageKey) ?? 'uk',
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> setLanguage(String languageCode) async {
    state = state.copyWith(languageCode: languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static ThemeMode _themeFromString(String? value) {
    return ThemeMode.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
