import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wallet_model.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _wallets =
      FirebaseFirestore.instance.collection('wallets');
      /// Récupère le portefeuille d'un utilisateur
  Stream<WalletModel?> getWallet(String userId) {
    return _wallets.doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }

      return WalletModel.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    });
  }

  /// Lire une seule fois le portefeuille
  Future<WalletModel?> getWalletOnce(String userId) async {
    final doc = await _wallets.doc(userId).get();

    if (!doc.exists) {
      return null;
    }

    return WalletModel.fromMap(
      doc.id,
      doc.data() as Map<String, dynamic>,
    );
  }
  /// Bloquer ou débloquer le portefeuille
  Future<void> setBlocked(
    String userId,
    bool blocked,
  ) async {
    await _wallets.doc(userId).update({
      'isBlocked': blocked,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Vérifier si le portefeuille existe
  Future<bool> walletExists(String userId) async {
    final doc = await _wallets.doc(userId).get();
    return doc.exists;
  }
}