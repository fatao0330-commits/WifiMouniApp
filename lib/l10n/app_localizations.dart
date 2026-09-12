import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;
  static const delegate = AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations);

  bool get _isFrench => locale.languageCode == 'fr';
  String _text(String french, String english) => _isFrench ? french : english;

  String get appName => 'WiFi Mouni';
  String get home => _text('Accueil', 'Home');
  String get contact => _text('Contact', 'Contact');
  String get history => _text('Historique', 'History');
  String get profile => _text('Profil', 'Profile');
  String get settings => _text('Paramètres', 'Settings');
  String get recharge => _text('Recharger', 'Top up');
  String get buySubscription => _text('Acheter un abonnement', 'Buy subscription');
  String get myQrCode => _text('Mon QR Code', 'My QR Code');
  String get scanQrCode => _text('Scanner QR Code', 'Scan QR Code');
  String get security => _text('Sécurité', 'Security');
  String get createPin => _text('Créer mon code PIN', 'Create my PIN');
  String get changePin => _text('Modifier le code PIN', 'Change PIN');
  String get fingerprint => _text('Empreinte digitale', 'Fingerprint');
  String get faceRecognition => _text('Reconnaissance faciale', 'Face recognition');
  String get preferences => _text('Préférences', 'Preferences');
  String get language => _text('Langue', 'Language');
  String get french => 'Français';
  String get english => 'English';
  String get notifications => _text('Notifications', 'Notifications');
  String get notificationsEnabled => _text('Notifications activées', 'Notifications enabled');
  String get notificationsDisabled => _text('Notifications désactivées', 'Notifications disabled');
  String get darkMode => _text('Mode sombre', 'Dark mode');
  String get darkModeEnabled => _text('Mode sombre activé', 'Dark mode enabled');
  String get darkModeDisabled => _text('Mode sombre désactivé', 'Dark mode disabled');
  String get account => _text('Compte', 'Account');
  String get privacyPolicy => _text('Politique de confidentialité', 'Privacy policy');
  String get terms => _text("Conditions d'utilisation", 'Terms of use');
  String get support => 'Support';
  String get about => _text('À propos', 'About');
  String get logout => _text('Se déconnecter', 'Log out');
  String get save => _text('Enregistrer', 'Save');
  String get cancel => _text('Annuler', 'Cancel');
  String get confirm => _text('Confirmer', 'Confirm');
  String get continueText => _text('Continuer', 'Continue');
  String get close => _text('Fermer', 'Close');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => const ['fr', 'en', 'es', 'ar', 'pt', 'hi', 'de', 'ja', 'ru', 'zh', 'it', 'tr', 'ko', 'nl'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
