import 'package:flutter/material.dart';

import 'settings_service.dart';

/// ============================================================
/// CONTRÔLEUR GLOBAL DES PARAMÈTRES DE WIFI MOUNI
/// ============================================================
///
/// Ce contrôleur permet à toute l'application d'utiliser les
/// mêmes paramètres :
///
/// 🇫🇷 / 🇬🇧 Langue
/// 🌙 Mode sombre
/// 🔔 Notifications
///
/// Le contrôleur est utilisé par main.dart pour reconstruire
/// automatiquement l'application lorsque les paramètres changent.
class AppSettingsController extends ChangeNotifier {
  AppSettingsController({
    required String language,
    required bool darkMode,
    required bool notifications,
  })  : _language = language == "en" ? "en" : "fr",
        _darkMode = darkMode,
        _notifications = notifications;

  final SettingsService _settingsService = SettingsService();

  String _language;
  bool _darkMode;
  bool _notifications;

  // ============================================================
  // GETTERS
  // ============================================================

  /// Langue actuelle : "fr" ou "en".
  String get language => _language;

  /// Indique si le mode sombre est activé.
  bool get darkMode => _darkMode;

  /// Indique si les notifications sont activées.
  bool get notifications => _notifications;

  /// Locale Flutter utilisée par MaterialApp.
  Locale get locale {
    return _language == "en"
        ? const Locale("en")
        : const Locale("fr");
  }

  /// Mode du thème Flutter.
  ThemeMode get themeMode {
    return _darkMode
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  // ============================================================
  // CHANGER LA LANGUE
  // ============================================================

  Future<void> setLanguage(String language) async {
    final newLanguage =
        language == "en" ? "en" : "fr";

    if (_language == newLanguage) {
      return;
    }

    // Enregistrer dans Firestore.
    await _settingsService.setLanguage(
      newLanguage,
    );

    // Modifier immédiatement l'application.
    _language = newLanguage;

    notifyListeners();
  }

  // ============================================================
  // MODE SOMBRE
  // ============================================================

  Future<void> setDarkMode(bool enabled) async {
    if (_darkMode == enabled) {
      return;
    }

    // Enregistrer dans Firestore.
    await _settingsService.setDarkModeEnabled(
      enabled,
    );

    // Modifier immédiatement l'application.
    _darkMode = enabled;

    notifyListeners();
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<void> setNotifications(
    bool enabled,
  ) async {
    if (_notifications == enabled) {
      return;
    }

    // Enregistrer dans Firestore.
    await _settingsService
        .setNotificationsEnabled(
      enabled,
    );

    // Modifier immédiatement l'application.
    _notifications = enabled;

    notifyListeners();
  }

  // ============================================================
  // CHARGER LES PARAMÈTRES DEPUIS FIRESTORE
  // ============================================================

  Future<void> load() async {
    try {
      final settings =
          await _settingsService.getSettings();

      _language =
          settings.language == "en"
              ? "en"
              : "fr";

      _darkMode =
          settings.darkModeEnabled;

      _notifications =
          settings.notificationsEnabled;

      notifyListeners();
    } catch (e) {
      debugPrint(
        "Erreur lors du chargement des paramètres : $e",
      );
    }
  }
}