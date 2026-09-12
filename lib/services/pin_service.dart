import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinService {
  PinService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFunctions get _functions {
    return FirebaseFunctions.instanceFor(
      region: 'us-central1',
    );
  }

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userDoc {
    return _firestore.collection('users').doc(_uid);
  }

  String get _pinConfiguredKey => 'pin_configured_$_uid';

  // ==========================================================
  // TÉLÉPHONE
  // ==========================================================

  String _normalizePhone(String phone) {
    String value = phone.trim();

    // Supprime espaces, tirets, parenthèses, etc.
    value = value.replaceAll(RegExp(r'[^\d+]'), '');

    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith('00225')) {
      value = '+${value.substring(2)}';
    } else if (value.startsWith('00')) {
      value = '+${value.substring(2)}';
    } else if (value.startsWith('225')) {
      value = '+$value';
    } else if (RegExp(r'^(01|05|07)\d{8}$').hasMatch(value)) {
      value = '+225$value';
    } else if (RegExp(r'^\d{8}$').hasMatch(value)) {
      value = '+225$value';
    } else if (!value.startsWith('+')) {
      value = '+$value';
    }

    return value;
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+\d{8,15}$').hasMatch(phone);
  }

  bool _isValidPin(String pin) {
    return RegExp(r'^\d{4}$').hasMatch(pin.trim());
  }

  // ==========================================================
  // VÉRIFIER SI UN PIN EXISTE
  // ==========================================================

  Future<bool> hasPin() async {
    final preferences = await SharedPreferences.getInstance();
    final cached = preferences.getBool(_pinConfiguredKey);
    if (cached != null) return cached;
    final doc = await _userDoc.get();
    final configured = doc.exists && doc.data()?['pinConfigured'] == true;
    await preferences.setBool(_pinConfiguredKey, configured);
    return configured;
  }

  // ==========================================================
  // CRÉER UN PIN
  // ==========================================================

  Future<void> createPin(String pin) async {
    final value = pin.trim();

    if (!_isValidPin(value)) {
      throw Exception(
        'Le code PIN doit contenir exactement 4 chiffres.',
      );
    }

    try {
      final callable = _functions.httpsCallable('createPin');

      await callable.call({
        'pin': value,
      });
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_pinConfiguredKey, true);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ?? 'Impossible de créer le code PIN.',
      );
    }
  }

  // ==========================================================
  // VÉRIFIER LE PIN
  // ==========================================================

  Future<bool> verifyPin(String pin) async {
    final value = pin.trim();

    if (!_isValidPin(value)) {
      return false;
    }

    try {
      final callable = _functions.httpsCallable('verifyPin');

      final result = await callable.call({
        'pin': value,
      });

      final data = result.data;

      return data is Map && data['verified'] == true;
    } on FirebaseFunctionsException {
      return false;
    }
  }

  // ==========================================================
  // CHANGER LE PIN
  // ==========================================================

  Future<void> changePin({
    required String oldPin,
    required String newPin,
  }) async {
    final oldValue = oldPin.trim();
    final newValue = newPin.trim();

    if (!_isValidPin(oldValue)) {
      throw Exception(
        'L’ancien PIN doit contenir exactement 4 chiffres.',
      );
    }

    if (!_isValidPin(newValue)) {
      throw Exception(
        'Le nouveau PIN doit contenir exactement 4 chiffres.',
      );
    }

    if (oldValue == newValue) {
      throw Exception(
        'Le nouveau code PIN doit être différent de l’ancien.',
      );
    }

    try {
      final callable = _functions.httpsCallable('changePin');

      await callable.call({
        'currentPin': oldValue,
        'newPin': newValue,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ?? 'Impossible de modifier le code PIN.',
      );
    }
  }

  // ==========================================================
  // DEMANDER UNE RÉINITIALISATION
  // ==========================================================

  Future<Map<String, dynamic>> requestPinReset(
    String identifier,
  ) async {
    final phone = _normalizePhone(identifier);

    if (!_isValidPhone(phone)) {
      throw Exception(
        'Numéro de téléphone invalide.',
      );
    }

    try {
      final callable =
          _functions.httpsCallable('requestPinReset');

      final result = await callable.call({
        'identifier': phone,
      });

      final data = result.data;

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        'Réponse invalide du serveur.',
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ??
            'Impossible d’envoyer le code de vérification.',
      );
    }
  }

  // ==========================================================
  // VÉRIFIER LE CODE SMS
  // ==========================================================

  Future<String> verifyPinResetCode({
    required String identifier,
    required String code,
  }) async {
    final phone = _normalizePhone(identifier);
    final value = code.trim();

    if (!_isValidPhone(phone)) {
      throw Exception(
        'Numéro de téléphone invalide.',
      );
    }

    if (!_isValidPin(value)) {
      throw Exception(
        'Le code de vérification doit contenir exactement 4 chiffres.',
      );
    }

    try {
      final callable =
          _functions.httpsCallable('verifyPinResetCode');

      final result = await callable.call({
        'identifier': phone,
        'code': value,
      });

      final data = result.data;

      if (data is! Map) {
        throw Exception(
          'Réponse invalide du serveur.',
        );
      }

      final token =
          data['resetToken']?.toString() ?? '';

      if (token.isEmpty) {
        throw Exception(
          'Session de réinitialisation invalide.',
        );
      }

      return token;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ??
            'Code de vérification incorrect ou expiré.',
      );
    }
  }

  // ==========================================================
  // RÉINITIALISER LE PIN
  // ==========================================================

  Future<void> resetPin({
    required String identifier,
    required String resetToken,
    required String newPin,
  }) async {
    final phone = _normalizePhone(identifier);
    final token = resetToken.trim();
    final pin = newPin.trim();

    if (!_isValidPhone(phone)) {
      throw Exception(
        'Numéro de téléphone invalide.',
      );
    }

    if (token.isEmpty) {
      throw Exception(
        'Jeton de réinitialisation manquant.',
      );
    }

    if (!_isValidPin(pin)) {
      throw Exception(
        'Le nouveau PIN doit contenir exactement 4 chiffres.',
      );
    }

    try {
      final callable =
          _functions.httpsCallable('resetPin');

      await callable.call({
        'identifier': phone,
        'resetToken': token,
        'newPin': pin,
      });
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_pinConfiguredKey, true);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ??
            'Impossible de réinitialiser le PIN.',
      );
    }
  }

  // ==========================================================
  // PARAMÈTRES DE SÉCURITÉ
  // ==========================================================

  Future<Map<String, dynamic>> getSecuritySettings() async {
    final doc = await _userDoc.get();

    if (!doc.exists) {
      return {
        'pinConfigured': false,
        'fingerprintEnabled': false,
        'faceIdEnabled': false,
      };
    }

    final data = doc.data() ?? {};

    return {
      'pinConfigured': data['pinConfigured'] == true,
      'fingerprintEnabled':
          data['fingerprintEnabled'] == true,
      'faceIdEnabled':
          data['faceIdEnabled'] == true,
    };
  }

  // ==========================================================
  // EMPREINTE
  // ==========================================================

  Future<void> setFingerprintEnabled(
    bool enabled,
  ) async {
    try {
      await _userDoc.update({
        'fingerprintEnabled': enabled,
        'securityUpdatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception(
        'Impossible de modifier le réglage de l’empreinte.',
      );
    }
  }

  // ==========================================================
  // FACE ID
  // ==========================================================

  Future<void> setFaceIdEnabled(
    bool enabled,
  ) async {
    try {
      await _userDoc.update({
        'faceIdEnabled': enabled,
        'securityUpdatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception(
        'Impossible de modifier le réglage de Face ID.',
      );
    }
  }

  Future<bool> isFingerprintEnabled() async {
    try {
      final settings = await getSecuritySettings();

      return settings['fingerprintEnabled'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isFaceIdEnabled() async {
    try {
      final settings = await getSecuritySettings();

      return settings['faceIdEnabled'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isSecurityReady() async {
    try {
      return await hasPin();
    } catch (_) {
      return false;
    }
  }

  Future<void> disableBiometrics() async {
    try {
      await _userDoc.update({
        'fingerprintEnabled': false,
        'faceIdEnabled': false,
        'securityUpdatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception(
        'Impossible de désactiver les options biométriques.',
      );
    }
  }
}