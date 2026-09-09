import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// Retourne l'ID WiFi Mouni de l'utilisateur connecté.
  Future<String?> getMyUserId() async {
    final user = _auth.currentUser;

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

    return data?["userId"]?.toString();
  }

  /// Vérifie qu'un ID WiFi Mouni existe.
  Future<Map<String, dynamic>?> findUserById(
    String userId,
  ) async {
    final id = userId.trim().toUpperCase();

    if (id.isEmpty) {
      return null;
    }

    final result = await _firestore
        .collection("users")
        .where(
          "userId",
          isEqualTo: id,
        )
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }

    return result.docs.first.data();
  }

  /// Vérifie si l'ID scanné appartient
  /// à l'utilisateur connecté.
  Future<bool> isMyUserId(String userId) async {
    final myId = await getMyUserId();

    if (myId == null) {
      return false;
    }

    return myId.toUpperCase() ==
        userId.trim().toUpperCase();
  }
}