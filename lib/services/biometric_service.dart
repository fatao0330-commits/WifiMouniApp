import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // ==========================================================
  // DISPONIBILITÉ BIOMÉTRIQUE
  // ==========================================================

  /// Vérifie si l'appareil prend en charge la biométrie.
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();

      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // BIOMÉTRIES DISPONIBLES
  // ==========================================================

  /// Retourne les types de biométrie disponibles.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return <BiometricType>[];
    }
  }

  // ==========================================================
  // AUTHENTIFICATION
  // ==========================================================

  /// Lance une authentification biométrique.
  Future<bool> authenticate({
    String reason = 'Authentifiez-vous pour continuer.',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          sensitiveTransaction: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // EMPREINTE DIGITALE
  // ==========================================================

  /// Vérifie si une empreinte digitale est disponible.
  Future<bool> hasFingerprint() async {
    try {
      final biometrics = await getAvailableBiometrics();

      return biometrics.contains(
        BiometricType.fingerprint,
      );
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // RECONNAISSANCE FACIALE
  // ==========================================================

  /// Vérifie si la reconnaissance faciale est disponible.
  Future<bool> hasFaceRecognition() async {
    try {
      final biometrics = await getAvailableBiometrics();

      return biometrics.contains(
        BiometricType.face,
      );
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // BIOMÉTRIE PRÊTE
  // ==========================================================

  /// Vérifie si une biométrie peut réellement être utilisée.
  Future<bool> isBiometricReady() async {
    try {
      final available = await isBiometricAvailable();

      if (!available) {
        return false;
      }

      final biometrics =
          await getAvailableBiometrics();

      return biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // EMPREINTE UTILISABLE
  // ==========================================================

  /// Vérifie si l'empreinte peut être utilisée.
  Future<bool> canUseFingerprint() async {
    try {
      if (!await isBiometricReady()) {
        return false;
      }

      return await hasFingerprint();
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // VISAGE UTILISABLE
  // ==========================================================

  /// Vérifie si la reconnaissance faciale peut être utilisée.
  Future<bool> canUseFaceId() async {
    try {
      if (!await isBiometricReady()) {
        return false;
      }

      return await hasFaceRecognition();
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // PAIEMENT
  // ==========================================================

  Future<bool> authenticateForPayment() async {
    return authenticate(
      reason:
          'Confirmez votre identité pour effectuer cette opération.',
    );
  }

  // ==========================================================
  // RECHARGE
  // ==========================================================

  Future<bool> authenticateForRecharge() async {
    return authenticate(
      reason:
          'Authentifiez-vous pour recharger votre compte WiFi Mouni.',
    );
  }

  // ==========================================================
  // ABONNEMENT
  // ==========================================================

  Future<bool> authenticateForSubscription() async {
    return authenticate(
      reason:
          'Authentifiez-vous pour acheter un abonnement.',
    );
  }

  // ==========================================================
  // MODIFICATION DU PIN
  // ==========================================================

  Future<bool> authenticateForPinChange() async {
    return authenticate(
      reason:
          'Authentifiez-vous pour modifier votre code PIN.',
    );
  }

  // ==========================================================
  // ACTION SENSIBLE
  // ==========================================================

  Future<bool> authenticateForSensitiveAction(
    String actionName,
  ) async {
    return authenticate(
      reason:
          'Authentifiez-vous pour $actionName.',
    );
  }

  // ==========================================================
  // ALIAS
  // ==========================================================

  Future<bool> isReady() async {
    return isBiometricReady();
  }

  // ==========================================================
  // ARRÊTER L'AUTHENTIFICATION
  // ==========================================================

  Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (_) {}
  }
}