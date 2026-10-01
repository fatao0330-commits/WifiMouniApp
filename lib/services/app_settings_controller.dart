import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'settings_service.dart';

class AppSettingsController extends ChangeNotifier {
  static const supportedLanguageCodes = AppLocalizations.supportedLanguageCodes;
  AppSettingsController({required String language, required bool darkMode, required bool notifications})
      : _language = _normalizeLanguage(language),
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
  Locale get locale {
    final language = _normalizeLanguage(_language);
    return language == 'fr' ? const Locale('fr') : Locale(language);
  }
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  static String _normalizeLanguage(String? language) {
    if (language == null || !supportedLanguageCodes.contains(language)) {
      return 'fr';
    }
    return language;
  }

  Future<void> setLanguage(String language) async {
    final newLanguage = _normalizeLanguage(language);
    if (_language == newLanguage) return;
    _language = newLanguage;
    notifyListeners();
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_languageKey, newLanguage);
    } catch (error) {
      debugPrint('Impossible d’enregistrer la langue localement : $error');
    }
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
    _language = _normalizeLanguage(savedLanguage);
    _darkMode = preferences.getBool(_darkModeKey) ?? _darkMode;
    _notifications = preferences.getBool(_notificationsKey) ?? _notifications;
    notifyListeners();

    try {
      final settings = await _settingsService.getSettings();
      _language = _normalizeLanguage(settings.language);
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
