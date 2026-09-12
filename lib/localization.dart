import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const _base = <String, String>{
    'appName': 'Wifi Mouni', 'login': 'Login', 'register': 'Create account', 'email': 'Email address', 'password': 'Password',
    'emailRequired': 'Enter your email address.', 'emailInvalid': 'Enter a valid email address.', 'passwordRequired': 'Enter your password.', 'passwordTooShort': 'Password must be at least 6 characters.',
    'continue': 'Continue', 'settings': 'Settings', 'language': 'Language', 'chooseLanguage': 'Choose language', 'welcome': 'Welcome to Wifi Mouni', 'home': 'Home', 'logout': 'Log out', 'noAccount': "Don't have an account?", 'hasAccount': 'Already have an account?', 'createAccount': 'Sign up to get started', 'loginSubtitle': 'Log in to your account', 'loginFailed': 'Incorrect email or password.', 'accountExists': 'An account already exists on this device.',
    'pin': 'PIN', 'pinSubtitle': 'Protect access to your settings with a 4 to 6 digit PIN.', 'confirmPin': 'Confirm PIN', 'pinInvalid': 'The PIN must contain 4 to 6 digits.', 'pinMismatch': 'The PINs do not match.', 'save': 'Save', 'removePin': 'Remove PIN', 'pinSaved': 'PIN saved.', 'pinRemoved': 'PIN removed.',
    'balance': 'Available balance', 'recharge': 'Top up', 'rechargeSubtitle': 'Add an amount to your wallet.', 'subscriptionPlans': 'Available plans', 'plansUnavailable': 'Plans are temporarily unavailable.', 'noPlans': 'No plans available.', 'customAmount': 'Custom top-up', 'amount': 'Amount', 'amountInvalid': 'Enter a valid amount.', 'amountRangeError': 'The amount must be between {min} and {max}.', 'paymentMethod': 'Payment method', 'bankCard': 'Bank card', 'mobileMoney': 'Mobile Money', 'bankTransfer': 'Bank transfer', 'paymentRequired': 'Select a payment method.', 'paymentMethodsUnavailable': 'Payment methods are temporarily unavailable.', 'noPaymentMethods': 'No payment methods available.', 'phoneNumber': 'Phone number', 'accountName': 'Account name', 'exactAmount': 'Exact amount', 'transactionReference': 'Transaction reference', 'referenceRequired': 'Enter the transaction reference.', 'attachProof': 'Attach payment proof', 'paymentMade': 'I have made the payment', 'confirmRecharge': 'Confirm top up', 'rechargeFailed': 'The top up could not be completed.', 'rechargeRequestSubmitted': 'Your top-up request is pending verification.', 'rechargeRequestFailed': 'The top-up request could not be submitted.', 'currency': 'XOF',
    'subscriptions': 'Subscriptions', 'subscriptionsUnavailable': 'Subscriptions are temporarily unavailable.', 'noSubscriptions': 'No subscriptions available.', 'confirmSubscription': 'Confirm subscription', 'insufficientFunds': 'The wallet balance is insufficient.', 'pinRequiredForSubscription': 'Set up a PIN before buying a subscription.', 'verifyPin': 'Verify PIN', 'verifyPinSubtitle': 'Enter your PIN to confirm this purchase.', 'verify': 'Verify', 'pinIncorrect': 'Incorrect PIN.', 'subscriptionRequestSubmitted': 'The activation request is pending processing.', 'subscriptionAlreadyPending': 'A request for this plan is already pending.', 'subscriptionRequestFailed': 'The activation request could not be submitted.',
  };

  static const _french = <String, String>{
    'login': 'Connexion', 'register': 'Créer un compte', 'email': 'Adresse e-mail', 'password': 'Mot de passe', 'emailRequired': 'Saisissez votre adresse e-mail.', 'emailInvalid': 'Saisissez une adresse e-mail valide.', 'passwordRequired': 'Saisissez votre mot de passe.', 'passwordTooShort': 'Le mot de passe doit contenir au moins 6 caractères.', 'continue': 'Continuer', 'settings': 'Paramètres', 'language': 'Langue', 'chooseLanguage': 'Choisir la langue', 'welcome': 'Bienvenue sur Wifi Mouni', 'home': 'Accueil', 'logout': 'Déconnexion', 'noAccount': 'Pas encore de compte ?', 'hasAccount': 'Vous avez déjà un compte ?', 'createAccount': 'Inscrivez-vous pour commencer', 'loginSubtitle': 'Connectez-vous à votre compte', 'loginFailed': 'E-mail ou mot de passe incorrect.', 'accountExists': 'Un compte existe déjà sur cet appareil.',
    'pin': 'Code PIN', 'pinSubtitle': 'Protégez l’accès à vos réglages avec un code de 4 à 6 chiffres.', 'confirmPin': 'Confirmer le PIN', 'pinInvalid': 'Le PIN doit contenir 4 à 6 chiffres.', 'pinMismatch': 'Les deux PIN ne correspondent pas.', 'save': 'Enregistrer', 'removePin': 'Supprimer le PIN', 'pinSaved': 'PIN enregistré.', 'pinRemoved': 'PIN supprimé.', 'balance': 'Solde disponible', 'recharge': 'Recharger', 'rechargeSubtitle': 'Ajoutez un montant à votre portefeuille.', 'subscriptionPlans': 'Forfaits disponibles', 'plansUnavailable': 'Les forfaits sont temporairement indisponibles.', 'noPlans': 'Aucun forfait disponible.', 'customAmount': 'Recharge libre', 'amount': 'Montant', 'amountInvalid': 'Saisissez un montant valide.', 'amountRangeError': 'Le montant doit être compris entre {min} et {max}.', 'paymentMethod': 'Moyen de paiement', 'bankCard': 'Carte bancaire', 'mobileMoney': 'Mobile Money', 'bankTransfer': 'Virement bancaire', 'paymentRequired': 'Sélectionnez un moyen de paiement.', 'paymentMethodsUnavailable': 'Les moyens de paiement sont temporairement indisponibles.', 'noPaymentMethods': 'Aucun moyen de paiement disponible.', 'phoneNumber': 'Numéro', 'accountName': 'Nom du compte', 'exactAmount': 'Montant exact', 'transactionReference': 'Référence de transaction', 'referenceRequired': 'Saisissez la référence de transaction.', 'attachProof': 'Joindre une preuve de paiement', 'paymentMade': 'J’ai effectué le paiement', 'confirmRecharge': 'Confirmer la recharge', 'rechargeFailed': 'La recharge n’a pas pu être effectuée.', 'rechargeRequestSubmitted': 'Votre demande de recharge est en attente de vérification.', 'rechargeRequestFailed': 'La demande de recharge n’a pas pu être envoyée.', 'currency': 'XOF',
    'subscriptions': 'Abonnements', 'subscriptionsUnavailable': 'Les abonnements sont temporairement indisponibles.', 'noSubscriptions': 'Aucun abonnement disponible.', 'confirmSubscription': 'Confirmer l’abonnement', 'insufficientFunds': 'Le solde du portefeuille est insuffisant.', 'pinRequiredForSubscription': 'Configurez un PIN avant d’acheter un abonnement.', 'verifyPin': 'Vérifier le PIN', 'verifyPinSubtitle': 'Saisissez votre PIN pour confirmer cet achat.', 'verify': 'Vérifier', 'pinIncorrect': 'PIN incorrect.', 'subscriptionRequestSubmitted': 'La demande d’activation est en attente de traitement.', 'subscriptionAlreadyPending': 'Une demande pour ce forfait est déjà en attente.', 'subscriptionRequestFailed': 'La demande d’activation n’a pas pu être envoyée.',
  };

  Map<String, String> get _strings => {..._base, if (locale.languageCode == 'fr') ..._french};

  String text(String key) => _strings[key] ?? key;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => const ['fr', 'en', 'es', 'ar', 'pt', 'hi', 'de', 'ja', 'ru', 'zh', 'it', 'tr', 'ko', 'nl'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
