import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/payment_method_model.dart';
import '../models/subscription_model.dart';
import '../utils/phone_number_utils.dart';
import 'payment_method_service.dart';
import 'subscription_service.dart';

class RechargeSettings {
  final int minimumAmount;
  final int maximumAmount;
  final String currency;

  const RechargeSettings({
    required this.minimumAmount,
    required this.maximumAmount,
    required this.currency,
  });

  factory RechargeSettings.fromMap(Map<String, dynamic> data) {
    final minimumAmount = _integerValue(data['minimumAmount']);
    final maximumAmount = _integerValue(data['maximumAmount']);
    final currency = data['currency'];

    if (minimumAmount <= 0 ||
        maximumAmount < minimumAmount ||
        currency is! String ||
        currency.trim().isEmpty) {
      throw StateError('Les paramètres de recharge sont invalides.');
    }

    return RechargeSettings(
      minimumAmount: minimumAmount,
      maximumAmount: maximumAmount,
      currency: currency.trim(),
    );
  }
}

class WalletSnapshot {
  final int balance;
  final String currency;
  final bool isBlocked;

  const WalletSnapshot({
    required this.balance,
    required this.currency,
    required this.isBlocked,
  });

  factory WalletSnapshot.fromMap(Map<String, dynamic> data) {
    return WalletSnapshot(
      balance: _integerValue(data['balance']),
      currency: data['currency'] is String
          ? (data['currency'] as String)
          : 'XOF',
      isBlocked: data['isBlocked'] == true,
    );
  }
}

class RechargeService {
  RechargeService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    PaymentMethodService? paymentMethodService,
    SubscriptionService? subscriptionService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _paymentMethodService =
            paymentMethodService ?? PaymentMethodService(),
        _subscriptionService =
            subscriptionService ?? SubscriptionService();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final PaymentMethodService _paymentMethodService;
  final SubscriptionService _subscriptionService;

  Stream<RechargeSettings> watchSettings() {
    return _firestore.doc('settings/recharge').snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw StateError('Les paramètres de recharge sont introuvables.');
      }
      return RechargeSettings.fromMap(snapshot.data()!);
    });
  }

  Stream<WalletSnapshot?> watchWallet() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.error(StateError('Utilisateur non connecté.'));
    }

    return _firestore.collection('wallets').doc(user.uid).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) return null;
        return WalletSnapshot.fromMap(snapshot.data()!);
      },
    );
  }

  Stream<List<PaymentMethodModel>> watchPaymentMethods() {
    return _paymentMethodService.getPaymentMethods();
  }

  Stream<List<SubscriptionModel>> watchSubscriptions() {
    return _subscriptionService.getSubscriptions();
  }

  Future<String> uploadProof({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Utilisateur non connecté.');
    }
    if (bytes.isEmpty || bytes.length >= 10 * 1024 * 1024) {
      throw ArgumentError('La preuve doit peser moins de 10 Mo.');
    }

    final safeFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final reference = _storage
        .ref()
        .child('recharge_proofs/${user.uid}/${DateTime.now().microsecondsSinceEpoch}_$safeFileName');
    final result = await reference.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    return result.ref.getDownloadURL();
  }

  Future<String> createRechargeRequest({
    required int amount,
    required String currency,
    required PaymentMethodModel paymentMethod,
    required String reference,
    required String customerNumber,
    String? proofUrl,
    String? subscriptionId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Utilisateur non connecté.');
    }
    if (amount <= 0) {
      throw ArgumentError('Le montant doit être supérieur à zéro.');
    }
    if (paymentMethod.id.trim().isEmpty || !paymentMethod.actif) {
      throw ArgumentError('Le moyen de paiement sélectionné est indisponible.');
    }
    if (!RegExp(r'^[+\d\s().-]+$').hasMatch(customerNumber.trim())) {
      throw ArgumentError('Numéro de paiement invalide.');
    }
    final normalizedCustomerNumber = PhoneNumberUtils.normalize(customerNumber);
    if (!PhoneNumberUtils.isValid(normalizedCustomerNumber)) {
      throw ArgumentError('Numéro de paiement invalide.');
    }
    final trimmedReference = reference.trim();
    if (trimmedReference.isEmpty) {
      throw ArgumentError('La référence de transaction est obligatoire.');
    }

    final settingsDocument =
        await _firestore.doc('settings/recharge').get();
    if (!settingsDocument.exists) {
      throw StateError('Les paramètres de recharge sont introuvables.');
    }
    final settings = RechargeSettings.fromMap(settingsDocument.data()!);
    if (amount < settings.minimumAmount || amount > settings.maximumAmount) {
      throw ArgumentError(
        'Le montant doit être compris entre ${settings.minimumAmount} '
        'et ${settings.maximumAmount}.',
      );
    }
    if (currency != settings.currency) {
      throw StateError('La devise de recharge a changé. Veuillez réessayer.');
    }

    final wallet = await _firestore.collection('wallets').doc(user.uid).get();
    if (!wallet.exists) {
      throw StateError('Portefeuille introuvable.');
    }
    if (wallet.data()?['isBlocked'] == true) {
      throw StateError('Votre portefeuille est bloqué.');
    }

    final request = <String, dynamic>{
      'userId': user.uid,
      'userUid': user.uid,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod.id,
      'paymentMethodName': paymentMethod.nom,
      'customerNumber': normalizedCustomerNumber,
      'reference': trimmedReference,
      'proofUrl': proofUrl,
      'subscriptionId': subscriptionId,
      'status': 'pending',
      'processedAt': null,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final document = await _firestore
        .collection('recharge_requests')
        .add(request);
    return document.id;
  }
}

int _integerValue(Object? value) {
  if (value is int) return value;
  if (value is num && value.isFinite) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
