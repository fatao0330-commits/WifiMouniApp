import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings._();

  static const _localeKey = 'app_locale';

  static Future<String?> loadLocale() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_localeKey);
  }

  static Future<void> saveLocale(String languageCode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_localeKey, languageCode);
  }
}