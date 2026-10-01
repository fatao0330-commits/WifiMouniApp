import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;
  static const delegate = AppLocalizationsDelegate();
  static const supportedLanguageCodes = <String>[
    'fr', 'en', 'es', 'ar', 'pt', 'hi', 'de', 'ja', 'ru', 'zh', 'it', 'tr', 'ko', 'nl',
  ];
  static const supportedLocales = <Locale>[
    Locale('fr'), Locale('en'), Locale('es'), Locale('ar'), Locale('pt'),
    Locale('hi'), Locale('de'), Locale('ja'), Locale('ru'), Locale('zh'),
    Locale('it'), Locale('tr'), Locale('ko'), Locale('nl'),
  ];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      const AppLocalizations(Locale('fr'));

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
  String get login => _text('Connexion', 'Login');
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
  String get registerTitle => _text('Créer un compte', 'Create account');
  String get fullName => _text('Nom complet', 'Full name');
  String get nameRequired => _text('Entrez votre nom.', 'Enter your name.');
  String get nameTooShort => _text('Nom trop court.', 'Name is too short.');
  String get enterPhoneNumber => _text('Numéro de téléphone', 'Phone number');
  String get phoneNumberRequired => _text('Entrez votre numéro de téléphone.', 'Enter your phone number.');
  String get invalidPhoneNumber => _text('Numéro de téléphone invalide.', 'Invalid phone number.');
  String get phoneInternationalFormat => _text('Utilisez le format international : +225...', 'Use international format: +225...');
  String get phoneInvalidCharacters => _text('Le numéro contient des caractères invalides.', 'The phone number contains invalid characters.');
  String get passwordTooShort => _text('Le mot de passe doit contenir au moins 6 caractères.', 'Password must be at least 6 characters.');
  String get confirmPassword => _text('Confirmer le mot de passe', 'Confirm password');
  String get confirmPasswordRequired => _text('Confirmez le mot de passe.', 'Confirm your password.');
  String get passwordMismatch => _text('Les mots de passe ne correspondent pas.', 'Passwords do not match.');
  String get registrationFailed => _text('Impossible de créer le compte. Réessayez.', 'Unable to create the account. Try again.');
  String get emailAlreadyInUse => _text('Cette adresse e-mail est déjà utilisée.', 'This email address is already in use.');
  String get weakPassword => _text('Le mot de passe est trop faible.', 'The password is too weak.');
  String get emailSignUpUnavailable => _text('L’inscription par e-mail n’est pas activée.', 'Email sign-up is not enabled.');
  String get networkError => _text('Problème de connexion Internet.', 'Internet connection problem.');
  String get phoneVerificationTitle => _text('Vérifiez votre numéro', 'Verify your phone number');
  String get otpSent => _text('Un code de vérification a été envoyé au numéro :', 'A verification code was sent to:');
  String get smsCode => _text('Code SMS', 'SMS code');
  String get otpRequired => _text('Entrez le code reçu.', 'Enter the code you received.');
  String get otpInvalid => _text('Le code doit contenir 4 chiffres.', 'The code must contain 4 digits.');
  String get firebaseOtpInvalid => _text('Le code doit contenir 6 chiffres.', 'The code must contain 6 digits.');
  String get verifyCode => _text('Vérifier le code', 'Verify code');
  String get otpHelp => _text('Si vous ne recevez pas le SMS, vérifiez le numéro et la réception des SMS.', 'If you do not receive the SMS, check the phone number and SMS reception.');
  String get phoneVerified => _text('Numéro vérifié avec succès.', 'Phone number verified successfully.');
  String get accountSessionMissing => _text('Session utilisateur introuvable.', 'User session not found.');
  String get forgotPasswordPhoneTitle => _text('Mot de passe oublié', 'Forgot password');
  String get resetPasswordPhone => _text('Réinitialiser le mot de passe par téléphone', 'Reset password by phone');
  String get forgotPasswordPhoneSubtitle => _text('Entrez le numéro associé à votre compte. Nous vous enverrons un code par SMS.', 'Enter the phone number linked to your account. We will send you a code by SMS.');
  String get phoneNotFound => _text('Aucun compte associé à ce numéro.', 'No account is associated with this number.');
  String get sendOtpCode => _text('Envoyer le code SMS', 'Send SMS code');
  String get otpCodeSent => _text('Code envoyé. Saisissez-le pour continuer.', 'Code sent. Enter it to continue.');
  String get enterOtpCode => _text('Saisissez le code reçu par SMS.', 'Enter the code received by SMS.');
  String get newPassword => _text('Nouveau mot de passe', 'New password');
  String get confirmNewPassword => _text('Confirmer le nouveau mot de passe', 'Confirm new password');
  String get otpExpired => _text('Le code a expiré. Demandez-en un nouveau.', 'The code expired. Request a new one.');
  String get otpVerificationFailed => _text('Code incorrect ou expiré.', 'Incorrect or expired code.');
  String get otpSendFailed => _text('Impossible d’envoyer le code SMS.', 'Unable to send the SMS code.');
  String get phoneAlreadyInUse => _text('Ce numéro est déjà associé à un autre compte.', 'This phone number is already linked to another account.');
  String get passwordResetSuccess => _text('Votre mot de passe a été modifié.', 'Your password has been changed.');
  String get passwordResetFailed => _text('Impossible de réinitialiser le mot de passe.', 'Unable to reset the password.');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLanguageCodes.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
