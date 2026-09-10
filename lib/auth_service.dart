import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();

  static const _emailKey = 'auth_email';
  static const _passwordKey = 'auth_password';
  static const _sessionKey = 'auth_session';
  static const _pinKey = 'security_pin';

  static Future<bool> register({required String email, required String password}) async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(_emailKey)) return false;
    await preferences.setString(_emailKey, email.trim());
    await preferences.setString(_passwordKey, password);
    await preferences.setBool(_sessionKey, true);
    return true;
  }

  static Future<bool> login({required String email, required String password}) async {
    final preferences = await SharedPreferences.getInstance();
    final savedEmail = preferences.getString(_emailKey);
    final savedPassword = preferences.getString(_passwordKey);
    final isValid = savedEmail == email.trim() && savedPassword == password;
    if (isValid) await preferences.setBool(_sessionKey, true);
    return isValid;
  }

  static Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_sessionKey, false);
  }

  static Future<bool> isAuthenticated() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_sessionKey) ?? false;
  }

  static Future<bool> hasPin() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey(_pinKey);
  }

  static Future<void> savePin(String pin) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pinKey, pin);
  }

  static Future<void> removePin() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_pinKey);
  }
}
