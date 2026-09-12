import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ==========================================================
  // UTILISATEUR CONNECTÉ
  // ==========================================================

  User? get currentUser =>
      _auth.currentUser;

  // ==========================================================
  // INFORMATIONS UTILISATEUR EN TEMPS RÉEL
  // ==========================================================

  Stream<UserModel> getCurrentUser() {
    final user = currentUser;

    if (user == null) {
      return Stream.error(
        Exception(
          "Aucun utilisateur connecté.",
        ),
      );
    }

    return _firestore
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception(
          "Utilisateur introuvable.",
        );
      }

      final data = doc.data();

      if (data == null) {
        throw Exception(
          "Données utilisateur introuvables.",
        );
      }

      return UserModel.fromMap(data);
    });
  }

  // ==========================================================
  // RÉCUPÉRER L'UTILISATEUR UNE SEULE FOIS
  // ==========================================================

  Future<UserModel?> getCurrentUserOnce() async {
    final user = currentUser;

    if (user == null) {
      return null;
    }

    final doc = await _firestore
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return UserModel.fromMap(data);
  }

  // ==========================================================
  // MODIFIER L'ABONNEMENT
  // ==========================================================

  Future<void> updateSubscription({
    required String nomAbonnement,
    required int joursRestants,
    required String statut,
    required DateTime dateDebutAbonnement,
    required DateTime dateFinAbonnement,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        "Utilisateur non connecté.",
      );
    }

    await _firestore
        .collection("users")
        .doc(user.uid)
        .update({
      "abonnement":
          statut == "actif",

      "nomAbonnement":
          nomAbonnement,

      "joursRestants":
          joursRestants,

      "statut":
          statut,

      "dateDebutAbonnement":
          Timestamp.fromDate(
        dateDebutAbonnement,
      ),

      "dateFinAbonnement":
          Timestamp.fromDate(
        dateFinAbonnement,
      ),
    });
  }
}