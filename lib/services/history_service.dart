import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        "Utilisateur non connecté.",
      );
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>>
      get _historyCollection {
    return _firestore
        .collection("users")
        .doc(_uid)
        .collection("history");
  }

  // ==========================================================
  // AJOUTER UNE OPÉRATION À L'HISTORIQUE
  // ==========================================================

  Future<void> addHistory({
    required String type,
    required String titre,
    required int montant,
    required String statut,
    String? description,
  }) async {
    await _historyCollection.add({
      "type": type,
      "titre": titre,
      "montant": montant,
      "statut": statut,
      "description": description ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // AJOUTER UNE OPÉRATION À L'HISTORIQUE D'UN AUTRE UTILISATEUR
  // ==========================================================

  Future<void> addHistoryForUser({
    required String userUid,
    required String type,
    required String titre,
    required int montant,
    required String statut,
    String? description,
  }) async {
    await _firestore
        .collection("users")
        .doc(userUid)
        .collection("history")
        .add({
      "type": type,
      "titre": titre,
      "montant": montant,
      "statut": statut,
      "description": description ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // LIRE L'HISTORIQUE EN TEMPS RÉEL
  // ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getHistory() {
    return _historyCollection
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots();
  }

  // ==========================================================
  // SUPPRIMER UNE OPÉRATION
  // ==========================================================

  Future<void> deleteHistory(
    String historyId,
  ) async {
    await _historyCollection
        .doc(historyId)
        .delete();
  }

  // ==========================================================
  // SUPPRIMER TOUT L'HISTORIQUE
  // ==========================================================

  Future<void> clearHistory() async {
    final snapshot =
        await _historyCollection.get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    for (
      int i = 0;
      i < snapshot.docs.length;
      i += 500
    ) {
      final batch =
          _firestore.batch();

      final end =
          (i + 500 > snapshot.docs.length)
              ? snapshot.docs.length
              : i + 500;

      final documents =
          snapshot.docs.sublist(i, end);

      for (final doc in documents) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    }
  }

  // ==========================================================
  // VÉRIFIER SI L'HISTORIQUE EST VIDE
  // ==========================================================

  Future<bool> isHistoryEmpty() async {
    final snapshot =
        await _historyCollection
            .limit(1)
            .get();

    return snapshot.docs.isEmpty;
  }

  // ==========================================================
  // COMPTER LES OPÉRATIONS
  // ==========================================================

  Future<int> getHistoryCount() async {
    final snapshot =
        await _historyCollection.get();

    return snapshot.docs.length;
  }
}