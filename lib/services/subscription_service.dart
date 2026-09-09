import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/subscription_model.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final CollectionReference<
      Map<String, dynamic>> _subscriptions =
      FirebaseFirestore.instance
          .collection("subscriptions");

  // ==========================================================
  // RÉCUPÉRER LES ABONNEMENTS ACTIFS
  // ==========================================================

  Stream<List<SubscriptionModel>>
      getSubscriptions() {
    return _subscriptions
        .where(
          "actif",
          isEqualTo: true,
        )
        .orderBy("ordre")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SubscriptionModel
            .fromFirestore(doc);
      }).toList();
    });
  }

  // ==========================================================
  // RÉCUPÉRER TOUS LES ABONNEMENTS
  // ==========================================================

  Stream<List<SubscriptionModel>>
      getAllSubscriptions() {
    return _subscriptions
        .orderBy("ordre")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SubscriptionModel
            .fromFirestore(doc);
      }).toList();
    });
  }

  // ==========================================================
  // RÉCUPÉRER UN ABONNEMENT PAR SON ID
  // ==========================================================

  Future<SubscriptionModel?>
      getSubscriptionById(
    String id,
  ) async {
    final doc =
        await _subscriptions.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return SubscriptionModel
        .fromFirestore(doc);
  }

  // ==========================================================
  // VÉRIFIER SI UN ABONNEMENT EXISTE
  // ==========================================================

  Future<bool> subscriptionExists(
    String id,
  ) async {
    final doc =
        await _subscriptions.doc(id).get();

    return doc.exists;
  }
}