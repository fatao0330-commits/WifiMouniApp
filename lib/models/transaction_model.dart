class TransactionModel {
  final String id;
  final String uid;
  final String type;
  final int amount;
  final String currency;
  final String status;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.uid,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });
      factory TransactionModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return TransactionModel(
      id: id,
      uid: data['uid'] ?? '',
      type: data['type'] ?? '',
      amount: data['amount'] ?? 0,
      currency: data['currency'] ?? 'XOF',
      status: data['status'] ?? 'success',
      createdAt:
          data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'type': type,
      'amount': amount,
      'currency': currency,
      'status': status,
      'createdAt': createdAt,
    };
  }
}