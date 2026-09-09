import 'package:firebase_auth/firebase_auth.dart';

import '../models/wallet_model.dart';
import '../services/wallet_service.dart';

class HomeController {
  final WalletService _walletService = WalletService();

  Stream<WalletModel?> walletStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value(null);
    }

    return _walletService.getWallet(user.uid);
  }
}