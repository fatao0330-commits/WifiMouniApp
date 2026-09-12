import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  WalletService._();

  static const _balanceKey = 'wallet_balance_cents';
  static const _lastPaymentMethodKey = 'wallet_last_payment_method';

  static Future<int> getBalanceCents() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_balanceKey) ?? 0;
  }

  static Future<int> recharge({required int amountCents, required String paymentMethod}) async {
    if (amountCents <= 0) {
      throw ArgumentError.value(amountCents, 'amountCents', 'Amount must be positive');
    }
    final preferences = await SharedPreferences.getInstance();
    final newBalance = (preferences.getInt(_balanceKey) ?? 0) + amountCents;
    await preferences.setInt(_balanceKey, newBalance);
    await preferences.setString(_lastPaymentMethodKey, paymentMethod);
    return newBalance;
  }

  static Future<String?> getLastPaymentMethod() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_lastPaymentMethodKey);
  }
}
