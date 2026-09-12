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
  String get welcome => _text('Bienvenue sur WiFi Mouni', 'Welcome to WiFi Mouni');
  String get signIn => _text('Se connecter', 'Sign in');
  String get signUp => _text('Créer un compte', 'Create account');
  String get loginSubtitle => _text('Connectez-vous à votre compte', 'Log in to your account');
  String get noAccount => _text('Vous n’avez pas de compte ?', "Don't have an account?");
  String get email => _text('Adresse e-mail', 'Email address');
  String get password => _text('Mot de passe', 'Password');
  String get forgotPassword => _text('Mot de passe oublié ?', 'Forgot password?');
  String get invalidEmail => _text('Adresse e-mail invalide.', 'Invalid email address.');
  String get requiredEmail => _text('Saisissez votre adresse e-mail.', 'Enter your email address.');
  String get requiredPassword => _text('Saisissez votre mot de passe.', 'Enter your password.');
  String get availableBalance => _text('Solde disponible', 'Available balance');
  String get quickActions => _text('Actions rapides', 'Quick actions');
  String get recentActivities => _text('Dernières activités', 'Recent activity');
  String get noActiveSubscription => _text('Aucun abonnement actif', 'No active subscription');
  String get activeInternet => _text('Internet actif', 'Internet active');
  String get expiredInternet => _text('Internet expiré', 'Internet expired');
  String get remainingDays => _text('Jours restants', 'Days remaining');
  String get copiedId => _text('ID copié dans le presse-papiers.', 'ID copied to clipboard.');
  String get notificationsComingSoon => _text('Les notifications seront disponibles prochainement.', 'Notifications will be available soon.');
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
