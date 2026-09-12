import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment_method_model.dart';

class PaymentMethodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PaymentMethodModel>> getPaymentMethods() {
    return _firestore
        .collection("payment_methods")
        .snapshots()
        .map((snapshot) {
      final methods = snapshot.docs
          .map((doc) => PaymentMethodModel.fromMap(doc.id, doc.data()))
          .where((method) => method.actif && (method.pays.isEmpty || method.pays.toUpperCase() == 'CI'))
          .toList();
      methods.sort((a, b) => a.ordre.compareTo(b.ordre));
      return methods;
    });
  }
}
