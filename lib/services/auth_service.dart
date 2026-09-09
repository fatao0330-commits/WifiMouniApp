import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // UTILISATEUR CONNECTÉ
  // ============================================================

  User? get currentUser {
    return _auth.currentUser;
  }

  // ============================================================
  // ÉTAT AUTHENTIFICATION
  // ============================================================

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  // ============================================================
  // GÉNÉRER UN ID WIFI MOUNI
  // Exemple : 53456473M
  // ============================================================

  Future<String> generateUserId() async {
    final random = Random();

    while (true) {
      String id = '';

      for (int i = 0; i < 8; i++) {
        id += random.nextInt(10).toString();
      }

      id += 'M';

      final query = await _firestore
          .collection('users')
          .where(
            'userId',
            isEqualTo: id,
          )
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return id;
      }
    }
  }

  // ============================================================
  // INSCRIPTION
  // ============================================================

  Future<String?> registerUser({
    required String nom,
    required String email,
    required String password,
    required String telephone,
  }) async {
    User? createdUser;

    try {
      final cleanName = nom.trim();
      final cleanEmail = email.trim().toLowerCase();
      final cleanPhone = telephone.trim();

      // --------------------------------------------------------
      // 1. CRÉER LE COMPTE FIREBASE AUTH
      // --------------------------------------------------------

      final credential =
          await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      createdUser = credential.user;

      if (createdUser == null) {
        return 'Impossible de créer le compte.';
      }

      final uid = createdUser.uid;

      // --------------------------------------------------------
      // 2. GÉNÉRER L'ID WIFI MOUNI
      // --------------------------------------------------------

      final userId = await generateUserId();

      // --------------------------------------------------------
      // 3. CRÉER LE PROFIL UTILISATEUR
      // --------------------------------------------------------

      await _firestore
          .collection('users')
          .doc(uid)
          .set({
        'uid': uid,
        'userId': userId,

        'nom': cleanName,
        'email': cleanEmail,
        'telephone': cleanPhone,

        // Solde
        'solde': 0,

        // Abonnement
        'abonnement': false,
        'nomAbonnement': '',
        'joursRestants': 0,
        'statut': 'expire',
        'internetActif': false,

        // Profil
        'photoUrl': '',

        // PIN
        'pin': '',
        'pinConfigured': false,

        // Vérifications
        'phoneVerified': false,
        'emailVerified': false,

        // Dates
        'dateCreation':
            FieldValue.serverTimestamp(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      // --------------------------------------------------------
      // 4. CRÉER LE WALLET
      // --------------------------------------------------------

      await _firestore
          .collection('wallets')
          .doc(uid)
          .set({
        'uid': uid,
        'userId': userId,

        'balance': 0,
        'currency': 'XOF',
        'country': 'CI',

        'isBlocked': false,

        'createdAt':
            FieldValue.serverTimestamp(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      // --------------------------------------------------------
      // 5. ENVOYER L'E-MAIL DE VÉRIFICATION
      // --------------------------------------------------------

      try {
        await createdUser.sendEmailVerification();
      } catch (_) {
        // L'inscription reste valide même si
        // l'envoi de l'e-mail échoue temporairement.
      }

      return null;
    } on FirebaseAuthException catch (e) {
      // --------------------------------------------------------
      // ERREURS FIREBASE AUTH
      // --------------------------------------------------------

      switch (e.code) {
        case 'email-already-in-use':
          return 'Cette adresse e-mail est déjà utilisée.';

        case 'invalid-email':
          return 'Adresse e-mail invalide.';

        case 'weak-password':
          return 'Le mot de passe est trop faible.';

        case 'operation-not-allowed':
          return 'L’inscription par e-mail n’est pas activée dans Firebase.';

        case 'network-request-failed':
          return 'Problème de connexion Internet.';

        default:
          return e.message ??
              'Impossible de créer le compte.';
      }
    } catch (e) {
      // --------------------------------------------------------
      // SI FIRESTORE ÉCHOUE APRÈS LA CRÉATION AUTH
      // ON SUPPRIME LE COMPTE AUTH
      // --------------------------------------------------------

      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {}
      }

      return 'Erreur lors de la création du compte. Vérifiez votre connexion et réessayez.';
    }
  }

  // ============================================================
  // CONNEXION
  // ============================================================

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Adresse e-mail invalide.';

        case 'user-not-found':
          return 'Aucun compte trouvé avec cette adresse e-mail.';

        case 'wrong-password':
        case 'invalid-credential':
          return 'E-mail ou mot de passe incorrect.';

        case 'user-disabled':
          return 'Ce compte a été désactivé.';

        case 'too-many-requests':
          return 'Trop de tentatives. Réessayez plus tard.';

        case 'network-request-failed':
          return 'Problème de connexion Internet.';

        default:
          return e.message ??
              'Impossible de se connecter.';
      }
    } catch (_) {
      return 'Erreur lors de la connexion.';
    }
  }

  // ============================================================
  // DÉCONNEXION
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ============================================================
  // RÉINITIALISATION DU MOT DE PASSE
  // ============================================================

  Future<String?> resetPassword(
    String email,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Adresse e-mail invalide.';

        case 'user-not-found':
          return 'Aucun compte trouvé avec cette adresse e-mail.';

        case 'network-request-failed':
          return 'Problème de connexion Internet.';

        default:
          return e.message ??
              'Impossible d’envoyer le lien.';
      }
    } catch (_) {
      return 'Erreur lors de la réinitialisation.';
    }
  }

  // ============================================================
  // ACTUALISER LA VÉRIFICATION E-MAIL
  // ============================================================

  Future<bool> refreshEmailVerification() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return false;
      }

      await user.reload();

      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return false;
      }

      final verified = refreshedUser.emailVerified;

      await _firestore
          .collection('users')
          .doc(refreshedUser.uid)
          .update({
        'emailVerified': verified,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      return verified;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // MARQUER LE TÉLÉPHONE COMME VÉRIFIÉ
  // ============================================================

  Future<bool> markPhoneVerified() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return false;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'phoneVerified': true,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // VÉRIFIER SI LE COMPTE EST AUTORISÉ
  // ============================================================

  Future<bool> isAccountAuthorized() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return false;
      }

      await user.reload();

      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return false;
      }

      // L'e-mail doit être vérifié.
      if (!refreshedUser.emailVerified) {
        return false;
      }

      final doc = await _firestore
          .collection('users')
          .doc(refreshedUser.uid)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data();

      final phoneVerified =
          data?['phoneVerified'] == true;

      return phoneVerified;
    } catch (_) {
      return false;
    }
  }
}