import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeLanguageProvider extends ChangeNotifier {

  // theme code
  static final ThemeLanguageProvider _instance = ThemeLanguageProvider._internal();
  factory ThemeLanguageProvider() => _instance;

  Locale _locale = Locale('en');
  Locale get locale => _locale;

  ThemeLanguageProvider._internal() {
    loadThemeMode();
    _loadLocale();
  }
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode(_themeMode);
    notifyListeners();
  }

  static bool get isDark => _instance.isDarkMode;

  Future<void> loadThemeMode() async {
    log("Theme mode loaded");
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    log("Theme mode saved");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
  }

  // language Code
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    _locale = locale;
    notifyListeners();
  }
}
