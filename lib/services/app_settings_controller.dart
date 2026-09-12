import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_service.dart';

class AppSettingsController extends ChangeNotifier {
  static const supportedLanguageCodes = <String>[
    'fr', 'en', 'es', 'ar', 'pt', 'hi', 'de', 'ja', 'ru', 'zh', 'it', 'tr', 'ko', 'nl',
  ];
  AppSettingsController({required String language, required bool darkMode, required bool notifications})
      : _language = supportedLanguageCodes.contains(language) ? language : 'fr',
        _darkMode = darkMode,
        _notifications = notifications;

  static const _languageKey = 'settings_language';
  static const _darkModeKey = 'settings_dark_mode';
  static const _notificationsKey = 'settings_notifications';

  final SettingsService _settingsService = SettingsService();
  String _language;
  bool _darkMode;
  bool _notifications;

  String get language => _language;
  bool get darkMode => _darkMode;
  bool get notifications => _notifications;
  Locale get locale => Locale(_language);
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> setLanguage(String language) async {
    final newLanguage = supportedLanguageCodes.contains(language) ? language : 'fr';
    if (_language == newLanguage) return;
    _language = newLanguage;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, newLanguage);
    try {
      await _settingsService.setLanguage(newLanguage);
    } catch (error) {
      debugPrint('Synchronisation de la langue impossible : $error');
    }
  }

  Future<void> setDarkMode(bool enabled) async {
    if (_darkMode == enabled) return;
    _darkMode = enabled;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, enabled);
    try {
      await _settingsService.setDarkModeEnabled(enabled);
    } catch (error) {
      debugPrint('Synchronisation du mode sombre impossible : $error');
    }
  }

  Future<void> setNotifications(bool enabled) async {
    if (_notifications == enabled) return;
    _notifications = enabled;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_notificationsKey, enabled);
    try {
      await _settingsService.setNotificationsEnabled(enabled);
    } catch (error) {
      debugPrint('Synchronisation des notifications impossible : $error');
    }
  }

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final savedLanguage = preferences.getString(_languageKey);
    _language = supportedLanguageCodes.contains(savedLanguage) ? savedLanguage! : _language;
    _darkMode = preferences.getBool(_darkModeKey) ?? _darkMode;
    _notifications = preferences.getBool(_notificationsKey) ?? _notifications;
    notifyListeners();

    try {
      final settings = await _settingsService.getSettings();
      _language = supportedLanguageCodes.contains(settings.language) ? settings.language : 'fr';
      _darkMode = settings.darkModeEnabled;
      _notifications = settings.notificationsEnabled;
      await preferences.setString(_languageKey, _language);
      await preferences.setBool(_darkModeKey, _darkMode);
      await preferences.setBool(_notificationsKey, _notifications);
      notifyListeners();
    } catch (error) {
      debugPrint('Erreur lors du chargement des paramètres : $error');
    }
  }
}
