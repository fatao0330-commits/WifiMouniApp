class WalletModel {
  final String id;
  final int balance;
  final String currency;
  final String country;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.balance,
    required this.currency,
    required this.country,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
  });
      factory WalletModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return WalletModel(
      id: id,
      balance: data['balance'] ?? 0,
      currency: data['currency'] ?? 'XOF',
      country: data['country'] ?? 'CI',
      isBlocked: data['isBlocked'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }
      Map<String, dynamic> toMap() {
    return {
      'balance': balance,
      'currency': currency,
      'country': country,
      'isBlocked': isBlocked,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}