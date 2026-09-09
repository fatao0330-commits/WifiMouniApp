import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ============================================================
/// MODÈLE DES PARAMÈTRES
/// ============================================================

class SettingsModel {
  final String language;
  final bool notificationsEnabled;
  final bool darkModeEnabled;

  const SettingsModel({
    required this.language,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
  });

  /// Paramètres par défaut
  factory SettingsModel.defaultSettings() {
    return const SettingsModel(
      language: "fr",
      notificationsEnabled: true,
      darkModeEnabled: false,
    );
  }

  /// Création depuis Firestore
  factory SettingsModel.fromMap(
    Map<String, dynamic> data,
  ) {
    return SettingsModel(
      language:
          data["language"] as String? ?? "fr",
      notificationsEnabled:
          data["notificationsEnabled"] as bool? ?? true,
      darkModeEnabled:
          data["darkModeEnabled"] as bool? ?? false,
    );
  }

  /// Conversion vers Firestore
  Map<String, dynamic> toMap() {
    return {
      "language": language,
      "notificationsEnabled":
          notificationsEnabled,
      "darkModeEnabled":
          darkModeEnabled,
    };
  }

  /// Copie avec modification de certaines valeurs
  SettingsModel copyWith({
    String? language,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
  }) {
    return SettingsModel(
      language:
          language ?? this.language,
      notificationsEnabled:
          notificationsEnabled ??
              this.notificationsEnabled,
      darkModeEnabled:
          darkModeEnabled ??
              this.darkModeEnabled,
    );
  }
}

/// ============================================================
/// SETTINGS SERVICE
/// ============================================================

class SettingsService {
  SettingsService();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// UID de l'utilisateur connecté
  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        "Utilisateur non connecté.",
      );
    }

    return user.uid;
  }

  /// Document des paramètres
  DocumentReference<Map<String, dynamic>>
      get _settingsDoc {
    return _firestore
        .collection("users")
        .doc(_uid)
        .collection("settings")
        .doc("preferences");
  }

  // ==========================================================
  // RÉCUPÉRER LES PARAMÈTRES
  // ==========================================================

  Future<SettingsModel> getSettings() async {
    final snapshot =
        await _settingsDoc.get();

    if (!snapshot.exists ||
        snapshot.data() == null) {
      return SettingsModel.defaultSettings();
    }

    return SettingsModel.fromMap(
      snapshot.data()!,
    );
  }

  // ==========================================================
  // ENREGISTRER TOUS LES PARAMÈTRES
  // ==========================================================

  Future<void> saveSettings(
    SettingsModel settings,
  ) async {
    await _settingsDoc.set(
      {
        ...settings.toMap(),
        "updatedAt":
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ==========================================================
  // LANGUE
  // ==========================================================

  Future<void> setLanguage(
    String language,
  ) async {
    if (language.trim().isEmpty) {
      throw Exception(
        "La langue ne peut pas être vide.",
      );
    }

    await _settingsDoc.set(
      {
        "language": language,
        "updatedAt":
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<String> getLanguage() async {
    final settings =
        await getSettings();

    return settings.language;
  }

  // ==========================================================
  // NOTIFICATIONS
  // ==========================================================

  Future<void> setNotificationsEnabled(
    bool enabled,
  ) async {
    await _settingsDoc.set(
      {
        "notificationsEnabled":
            enabled,
        "updatedAt":
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<bool> areNotificationsEnabled() async {
    final settings =
        await getSettings();

    return settings.notificationsEnabled;
  }

  // ==========================================================
  // MODE SOMBRE
  // ==========================================================

  Future<void> setDarkModeEnabled(
    bool enabled,
  ) async {
    await _settingsDoc.set(
      {
        "darkModeEnabled":
            enabled,
        "updatedAt":
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<bool> isDarkModeEnabled() async {
    final settings =
        await getSettings();

    return settings.darkModeEnabled;
  }

  // ==========================================================
  // VÉRIFIER SI LES PARAMÈTRES SONT DISPONIBLES
  // ==========================================================

  Future<bool> isReady() async {
    try {
      final snapshot =
          await _settingsDoc.get();

      return snapshot.exists;
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // RÉINITIALISER LES PARAMÈTRES
  // ==========================================================

  Future<void> resetSettings() async {
    final defaults =
        SettingsModel.defaultSettings();

    await _settingsDoc.set(
      {
        ...defaults.toMap(),
        "updatedAt":
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}