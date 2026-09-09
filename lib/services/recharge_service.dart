import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RechargeService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ==========================================================
  // CRÉER UNE DEMANDE DE RECHARGE
  // ==========================================================

  Future<String?> recharge({
    required int amount,
    required String paymentMethod,
    required String phoneNumber,
  }) async {
    try {
      final user =
          _auth.currentUser;

      if (user == null) {
        return "Utilisateur non connecté.";
      }

      if (amount <= 0) {
        return "Le montant doit être supérieur à zéro.";
      }

      if (paymentMethod.trim().isEmpty) {
        return "Veuillez choisir un moyen de paiement.";
      }

      if (phoneNumber.trim().isEmpty) {
        return "Veuillez entrer le numéro de paiement.";
      }

      // Vérifier que le portefeuille existe
      final walletDoc =
          await _firestore
              .collection("wallets")
              .doc(user.uid)
              .get();

      if (!walletDoc.exists) {
        return "Portefeuille introuvable.";
      }

      final walletData =
          walletDoc.data();

      if (walletData?["isBlocked"] == true) {
        return "Votre portefeuille est bloqué.";
      }

      // Créer la demande
      final rechargeRef =
          _firestore
              .collection("recharges")
              .doc();

      await rechargeRef.set({
        "uid": user.uid,
        "amount": amount,
        "paymentMethod":
            paymentMethod.trim(),
        "phoneNumber":
            phoneNumber.trim(),
        "status": "pending",
        "createdAt":
            FieldValue.serverTimestamp(),
      });

      // Ajouter également dans l'historique
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("history")
          .add({
        "type": "recharge",
        "titre": "Demande de recharge",
        "montant": amount,
        "statut": "pending",
        "description":
            "Recharge via $paymentMethod",
        "createdAt":
            FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseException catch (e) {
      return e.message ??
          "Une erreur Firebase est survenue.";
    } catch (e) {
      return e
          .toString()
          .replaceFirst(
            "Exception: ",
            "",
          );
    }
  }

  // ==========================================================
  // RÉCUPÉRER LES DEMANDES DE RECHARGE
  // ==========================================================

  Stream<QuerySnapshot<
      Map<String, dynamic>>>
      getMyRecharges() {
    final user =
        _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection("recharges")
        .where(
          "uid",
          isEqualTo: user.uid,
        )
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots();
  }

  // ==========================================================
  // RÉCUPÉRER UNE RECHARGE
  // ==========================================================

  Future<
      DocumentSnapshot<
          Map<String, dynamic>>?> getRecharge(
    String rechargeId,
  ) async {
    final doc =
        await _firestore
            .collection("recharges")
            .doc(rechargeId)
            .get();

    if (!doc.exists) {
      return null;
    }

    return doc;
  }
}