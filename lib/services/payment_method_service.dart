import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment_method_model.dart';

class PaymentMethodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PaymentMethodModel>> getPaymentMethods() {
    return _firestore
        .collection("payment_methods")
        .where("actif", isEqualTo: true)
        .orderBy("ordre")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PaymentMethodModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }
}
