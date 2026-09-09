import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // ENVOYER L'EMAIL DE RÉINITIALISATION
  // ============================================================

  Future<String?> sendResetEmail(String email) async {
    try {
      final cleanEmail = email.trim();

      if (cleanEmail.isEmpty) {
        return "Entrez votre adresse e-mail.";
      }

      await _auth.setLanguageCode("fr");

      await _auth.sendPasswordResetEmail(
        email: cleanEmail,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          return "Adresse e-mail invalide.";

        case "user-not-found":
          return "Aucun compte associé à cette adresse e-mail.";

        case "user-disabled":
          return "Ce compte a été désactivé.";

        case "network-request-failed":
          return "Problème de connexion Internet.";

        case "too-many-requests":
          return "Trop de demandes. Réessayez plus tard.";

        default:
          return e.message ??
              "Impossible d'envoyer l'e-mail de récupération.";
      }
    } catch (e) {
      return "Une erreur est survenue.";
    }
  }

  // ============================================================
  // VÉRIFIER LE CODE DE RÉINITIALISATION
  // ============================================================

  Future<String?> verifyResetCode(
    String code,
  ) async {
    try {
      final cleanCode = code.trim();

      if (cleanCode.isEmpty) {
        return "Le code de réinitialisation est obligatoire.";
      }

      final email =
          await _auth.verifyPasswordResetCode(
        cleanCode,
      );

      return email;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "expired-action-code":
          return "Le lien de réinitialisation a expiré.";

        case "invalid-action-code":
          return "Le code de réinitialisation est invalide.";

        case "user-disabled":
          return "Ce compte a été désactivé.";

        case "user-not-found":
          return "Compte introuvable.";

        default:
          return e.message ??
              "Code de réinitialisation invalide.";
      }
    } catch (e) {
      return "Impossible de vérifier le code.";
    }
  }

  // ============================================================
  // DÉFINIR LE NOUVEAU MOT DE PASSE
  // ============================================================

  Future<String?> confirmReset(
    String code,
    String newPassword,
  ) async {
    try {
      final cleanCode = code.trim();

      if (cleanCode.isEmpty) {
        return "Code de réinitialisation manquant.";
      }

      if (newPassword.length < 6) {
        return "Le mot de passe doit contenir au moins 6 caractères.";
      }

      await _auth.confirmPasswordReset(
        code: cleanCode,
        newPassword: newPassword,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "expired-action-code":
          return "Le code de réinitialisation a expiré.";

        case "invalid-action-code":
          return "Le code de réinitialisation est invalide ou a déjà été utilisé.";

        case "weak-password":
          return "Le nouveau mot de passe est trop faible.";

        case "user-disabled":
          return "Ce compte a été désactivé.";

        case "user-not-found":
          return "Compte utilisateur introuvable.";

        default:
          return e.message ??
              "Impossible de modifier le mot de passe.";
      }
    } catch (e) {
      return "Une erreur est survenue lors de la modification du mot de passe.";
    }
  }
}