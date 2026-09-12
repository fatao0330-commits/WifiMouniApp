import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  User? get currentUser =>
      _auth.currentUser;

  // ==========================================================
  // RÉFÉRENCE DU PORTEFEUILLE
  // ==========================================================

  DocumentReference<Map<String, dynamic>>
      get walletRef {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        "Utilisateur non connecté.",
      );
    }

    return _firestore
        .collection("wallets")
        .doc(user.uid);
  }

  // ==========================================================
  // RÉCUPÉRER LE PORTEFEUILLE
  // ==========================================================

  Future<Map<String, dynamic>?>
      getWallet() async {
    final doc = await walletRef.get();

    if (!doc.exists) {
      return null;
    }

    return doc.data();
  }

  // ==========================================================
  // RÉCUPÉRER LE SOLDE
  // ==========================================================

  Future<int> getBalance() async {
    final wallet = await getWallet();

    if (wallet == null) {
      return 0;
    }

    final balance =
        wallet["balance"];

    if (balance is int) {
      return balance;
    }

    if (balance is num) {
      return balance.toInt();
    }

    return 0;
  }

  // ==========================================================
  // VÉRIFIER LE SOLDE
  // ==========================================================

  Future<bool> hasEnoughBalance(
    int amount,
  ) async {
    if (amount < 0) {
      return false;
    }

    final balance =
        await getBalance();

    return balance >= amount;
  }

  // ==========================================================
  // BLOQUER / DÉBLOQUER
  // ==========================================================

  Future<void> setBlocked(
    bool blocked,
  ) async {
    await walletRef.update({
      "isBlocked": blocked,
      "updatedAt":
          FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // VÉRIFIER SI LE PORTEFEUILLE EST BLOQUÉ
  // ==========================================================

  Future<bool> isWalletBlocked() async {
    final wallet =
        await getWallet();

    if (wallet == null) {
      return true;
    }

    return wallet["isBlocked"] == true;
  }
}