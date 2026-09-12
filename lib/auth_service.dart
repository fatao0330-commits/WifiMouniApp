import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();

  static const _pinKey = 'security_pin';

  static User? get currentUser => FirebaseAuth.instance.currentUser;

  static Future<bool> register({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.trim(), password: password);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  static Future<bool> login({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.trim(), password: password);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  static Future<void> logout() {
    return FirebaseAuth.instance.signOut();
  }

  static Future<bool> isAuthenticated() async {
    return currentUser != null;
  }

  static Future<bool> hasPin() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey(_pinKey);
  }

  static Future<bool> verifyPin(String pin) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_pinKey) == pin;
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
