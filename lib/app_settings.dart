import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings._();

  static const _localeKey = 'app_locale';
  static const _pinKey = 'settings_pin';

  static Future<String?> loadLocale() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_localeKey);
  }

  static Future<void> saveLocale(String languageCode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_localeKey, languageCode);
  }

  static Future<String?> loadPin() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_pinKey);
  }

  static Future<void> savePin(String pin) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_pinKey, pin);
    if (!saved) {
      throw StateError('Le code PIN n’a pas pu être enregistré.');
    }
  }
}