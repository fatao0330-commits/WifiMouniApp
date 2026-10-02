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

  static const _additionalTexts = <String, Map<String, String>>{
    'es': {
      'contactByEmail': 'Contactar con soporte por correo', 'contactViaWhatsApp': 'Contactar con soporte por WhatsApp',
      'emailLaunchFailed': 'No se pudo abrir la aplicación de correo.', 'whatsappLaunchFailed': 'No se pudo abrir WhatsApp.',
      'cameraPermissionDenied': 'Permite el acceso a la cámara en los ajustes para escanear un código QR.', 'cameraUnavailable': 'La cámara no está disponible. Comprueba los permisos e inténtalo de nuevo.',
      'retry': 'Reintentar', 'invalidQrCode': 'Código QR no válido.', 'qrUserNotFound': 'No se encontró al usuario.', 'qrLookupFailed': 'No se pudo verificar el código QR.',
      'qrUserFound': 'Usuario encontrado', 'scanAgain': 'Escanear otro código QR', 'qrVerifying': 'Verificando...', 'qrScannerHint': 'Coloca el código QR de WiFi Mouni dentro del marco.',
    },
    'ar': {
      'contactByEmail': 'مراسلة الدعم عبر البريد الإلكتروني', 'contactViaWhatsApp': 'التواصل مع الدعم عبر WhatsApp',
      'emailLaunchFailed': 'تعذر فتح تطبيق البريد الإلكتروني.', 'whatsappLaunchFailed': 'تعذر فتح WhatsApp.',
      'cameraPermissionDenied': 'اسمح بالوصول إلى الكاميرا من الإعدادات لمسح رمز QR.', 'cameraUnavailable': 'الكاميرا غير متاحة. تحقق من الأذونات ثم حاول مجددًا.',
      'retry': 'إعادة المحاولة', 'invalidQrCode': 'رمز QR غير صالح.', 'qrUserNotFound': 'لم يتم العثور على المستخدم.', 'qrLookupFailed': 'تعذر التحقق من رمز QR.',
      'qrUserFound': 'تم العثور على المستخدم', 'scanAgain': 'مسح رمز QR آخر', 'qrVerifying': 'جارٍ التحقق...', 'qrScannerHint': 'ضع رمز WiFi Mouni QR داخل الإطار.',
    },
    'pt': {
      'contactByEmail': 'Falar com o suporte por e-mail', 'contactViaWhatsApp': 'Falar com o suporte pelo WhatsApp',
      'emailLaunchFailed': 'Não foi possível abrir o aplicativo de e-mail.', 'whatsappLaunchFailed': 'Não foi possível abrir o WhatsApp.',
      'cameraPermissionDenied': 'Permita o acesso à câmera nas configurações para ler um código QR.', 'cameraUnavailable': 'A câmera está indisponível. Verifique as permissões e tente novamente.',
      'retry': 'Tentar novamente', 'invalidQrCode': 'Código QR inválido.', 'qrUserNotFound': 'Usuário não encontrado.', 'qrLookupFailed': 'Não foi possível verificar o código QR.',
      'qrUserFound': 'Usuário encontrado', 'scanAgain': 'Ler outro código QR', 'qrVerifying': 'Verificando...', 'qrScannerHint': 'Posicione o código QR do WiFi Mouni dentro da moldura.',
    },
    'hi': {
      'contactByEmail': 'ईमेल से सहायता टीम से संपर्क करें', 'contactViaWhatsApp': 'WhatsApp पर सहायता टीम से संपर्क करें',
      'emailLaunchFailed': 'ईमेल ऐप नहीं खुल सका।', 'whatsappLaunchFailed': 'WhatsApp नहीं खुल सका।',
      'cameraPermissionDenied': 'QR कोड स्कैन करने के लिए सेटिंग्स में कैमरा अनुमति दें।', 'cameraUnavailable': 'कैमरा उपलब्ध नहीं है। अनुमति जाँचकर फिर प्रयास करें।',
      'retry': 'फिर से प्रयास करें', 'invalidQrCode': 'QR कोड अमान्य है।', 'qrUserNotFound': 'उपयोगकर्ता नहीं मिला।', 'qrLookupFailed': 'QR कोड सत्यापित नहीं हो सका।',
      'qrUserFound': 'उपयोगकर्ता मिल गया', 'scanAgain': 'दूसरा QR कोड स्कैन करें', 'qrVerifying': 'सत्यापन हो रहा है...', 'qrScannerHint': 'WiFi Mouni QR कोड को फ्रेम के अंदर रखें।',
    },
    'de': {
      'contactByEmail': 'Support per E-Mail kontaktieren', 'contactViaWhatsApp': 'Support über WhatsApp kontaktieren',
      'emailLaunchFailed': 'Die E-Mail-App konnte nicht geöffnet werden.', 'whatsappLaunchFailed': 'WhatsApp konnte nicht geöffnet werden.',
      'cameraPermissionDenied': 'Erlaube den Kamerazugriff in den Einstellungen, um einen QR-Code zu scannen.', 'cameraUnavailable': 'Die Kamera ist nicht verfügbar. Prüfe die Berechtigungen und versuche es erneut.',
      'retry': 'Erneut versuchen', 'invalidQrCode': 'Ungültiger QR-Code.', 'qrUserNotFound': 'Benutzer nicht gefunden.', 'qrLookupFailed': 'Der QR-Code konnte nicht überprüft werden.',
      'qrUserFound': 'Benutzer gefunden', 'scanAgain': 'Weiteren QR-Code scannen', 'qrVerifying': 'Wird überprüft...', 'qrScannerHint': 'Halte den WiFi-Mouni-QR-Code in den Rahmen.',
    },
    'ja': {
      'contactByEmail': 'メールでサポートに問い合わせ', 'contactViaWhatsApp': 'WhatsAppでサポートに問い合わせ',
      'emailLaunchFailed': 'メールアプリを開けませんでした。', 'whatsappLaunchFailed': 'WhatsAppを開けませんでした。',
      'cameraPermissionDenied': 'QRコードをスキャンするには、設定でカメラへのアクセスを許可してください。', 'cameraUnavailable': 'カメラを利用できません。権限を確認して再試行してください。',
      'retry': '再試行', 'invalidQrCode': 'QRコードが無効です。', 'qrUserNotFound': 'ユーザーが見つかりません。', 'qrLookupFailed': 'QRコードを確認できませんでした。',
      'qrUserFound': 'ユーザーが見つかりました', 'scanAgain': '別のQRコードをスキャン', 'qrVerifying': '確認中...', 'qrScannerHint': 'WiFi MouniのQRコードを枠内に合わせてください。',
    },
    'ru': {
      'contactByEmail': 'Написать в поддержку по электронной почте', 'contactViaWhatsApp': 'Связаться с поддержкой в WhatsApp',
      'emailLaunchFailed': 'Не удалось открыть почтовое приложение.', 'whatsappLaunchFailed': 'Не удалось открыть WhatsApp.',
      'cameraPermissionDenied': 'Разрешите доступ к камере в настройках, чтобы сканировать QR-код.', 'cameraUnavailable': 'Камера недоступна. Проверьте разрешения и повторите попытку.',
      'retry': 'Повторить', 'invalidQrCode': 'Недействительный QR-код.', 'qrUserNotFound': 'Пользователь не найден.', 'qrLookupFailed': 'Не удалось проверить QR-код.',
      'qrUserFound': 'Пользователь найден', 'scanAgain': 'Сканировать другой QR-код', 'qrVerifying': 'Проверка...', 'qrScannerHint': 'Поместите QR-код WiFi Mouni в рамку.',
    },
    'zh': {
      'contactByEmail': '通过电子邮件联系支持团队', 'contactViaWhatsApp': '通过 WhatsApp 联系支持团队',
      'emailLaunchFailed': '无法打开邮件应用。', 'whatsappLaunchFailed': '无法打开 WhatsApp。',
      'cameraPermissionDenied': '请在设置中允许使用相机，以扫描二维码。', 'cameraUnavailable': '相机不可用。请检查权限后重试。',
      'retry': '重试', 'invalidQrCode': '二维码无效。', 'qrUserNotFound': '未找到用户。', 'qrLookupFailed': '无法验证二维码。',
      'qrUserFound': '已找到用户', 'scanAgain': '扫描另一个二维码', 'qrVerifying': '正在验证...', 'qrScannerHint': '将 WiFi Mouni 二维码对准取景框。',
    },
    'it': {
      'contactByEmail': "Contatta l'assistenza via e-mail", 'contactViaWhatsApp': "Contatta l'assistenza su WhatsApp",
      'emailLaunchFailed': "Impossibile aprire l'app di posta.", 'whatsappLaunchFailed': 'Impossibile aprire WhatsApp.',
      'cameraPermissionDenied': "Consenti l'accesso alla fotocamera nelle impostazioni per scansionare un codice QR.", 'cameraUnavailable': 'Fotocamera non disponibile. Controlla le autorizzazioni e riprova.',
      'retry': 'Riprova', 'invalidQrCode': 'Codice QR non valido.', 'qrUserNotFound': 'Utente non trovato.', 'qrLookupFailed': 'Impossibile verificare il codice QR.',
      'qrUserFound': 'Utente trovato', 'scanAgain': 'Scansiona un altro codice QR', 'qrVerifying': 'Verifica in corso...', 'qrScannerHint': 'Inquadra il codice QR WiFi Mouni.',
    },
    'tr': {
      'contactByEmail': 'Destek ekibine e-posta gönder', 'contactViaWhatsApp': 'WhatsApp üzerinden destek al',
      'emailLaunchFailed': 'E-posta uygulaması açılamadı.', 'whatsappLaunchFailed': 'WhatsApp açılamadı.',
      'cameraPermissionDenied': 'QR kodu taramak için ayarlardan kamera erişimine izin verin.', 'cameraUnavailable': 'Kamera kullanılamıyor. İzinleri kontrol edip tekrar deneyin.',
      'retry': 'Tekrar dene', 'invalidQrCode': 'QR kodu geçersiz.', 'qrUserNotFound': 'Kullanıcı bulunamadı.', 'qrLookupFailed': 'QR kodu doğrulanamadı.',
      'qrUserFound': 'Kullanıcı bulundu', 'scanAgain': 'Başka bir QR kodu tara', 'qrVerifying': 'Doğrulanıyor...', 'qrScannerHint': 'WiFi Mouni QR kodunu çerçevenin içine yerleştirin.',
    },
    'ko': {
      'contactByEmail': '이메일로 고객 지원 문의', 'contactViaWhatsApp': 'WhatsApp으로 고객 지원 문의',
      'emailLaunchFailed': '이메일 앱을 열 수 없습니다.', 'whatsappLaunchFailed': 'WhatsApp을 열 수 없습니다.',
      'cameraPermissionDenied': 'QR 코드를 스캔하려면 설정에서 카메라 접근을 허용하세요.', 'cameraUnavailable': '카메라를 사용할 수 없습니다. 권한을 확인한 후 다시 시도하세요.',
      'retry': '다시 시도', 'invalidQrCode': 'QR 코드가 올바르지 않습니다.', 'qrUserNotFound': '사용자를 찾을 수 없습니다.', 'qrLookupFailed': 'QR 코드를 확인할 수 없습니다.',
      'qrUserFound': '사용자를 찾았습니다', 'scanAgain': '다른 QR 코드 스캔', 'qrVerifying': '확인 중...', 'qrScannerHint': 'WiFi Mouni QR 코드를 프레임 안에 맞추세요.',
    },
    'nl': {
      'contactByEmail': 'E-mail de ondersteuning', 'contactViaWhatsApp': 'Neem contact op via WhatsApp',
      'emailLaunchFailed': 'De e-mailapp kon niet worden geopend.', 'whatsappLaunchFailed': 'WhatsApp kon niet worden geopend.',
      'cameraPermissionDenied': 'Sta cameratoegang toe in de instellingen om een QR-code te scannen.', 'cameraUnavailable': 'De camera is niet beschikbaar. Controleer de machtigingen en probeer het opnieuw.',
      'retry': 'Opnieuw proberen', 'invalidQrCode': 'Ongeldige QR-code.', 'qrUserNotFound': 'Gebruiker niet gevonden.', 'qrLookupFailed': 'De QR-code kon niet worden gecontroleerd.',
      'qrUserFound': 'Gebruiker gevonden', 'scanAgain': 'Nog een QR-code scannen', 'qrVerifying': 'Controleren...', 'qrScannerHint': 'Richt de WiFi Mouni QR-code op het kader.',
    },
  };

  String _newText(String key, String french, String english) =>
      _additionalTexts[locale.languageCode]?[key] ?? _text(french, english);

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
  String get contactByEmail => _newText('contactByEmail', 'Écrire au support par e-mail', 'Email support');
  String get contactViaWhatsApp => _newText('contactViaWhatsApp', 'Contacter le support sur WhatsApp', 'Contact support on WhatsApp');
  String get emailLaunchFailed => _newText('emailLaunchFailed', 'Impossible d’ouvrir l’application de messagerie.', 'Unable to open the email app.');
  String get whatsappLaunchFailed => _newText('whatsappLaunchFailed', 'Impossible d’ouvrir WhatsApp.', 'Unable to open WhatsApp.');
  String get cameraPermissionDenied => _newText('cameraPermissionDenied', 'Autorisez l’accès à la caméra dans les réglages pour scanner un QR Code.', 'Allow camera access in settings to scan a QR code.');
  String get cameraUnavailable => _newText('cameraUnavailable', 'La caméra est indisponible. Vérifiez ses autorisations puis réessayez.', 'The camera is unavailable. Check its permissions and try again.');
  String get retry => _newText('retry', 'Réessayer', 'Try again');
  String get invalidQrCode => _newText('invalidQrCode', 'QR Code invalide.', 'Invalid QR code.');
  String get qrUserNotFound => _newText('qrUserNotFound', 'Utilisateur introuvable.', 'User not found.');
  String get qrLookupFailed => _newText('qrLookupFailed', 'Impossible de vérifier le QR Code.', 'Unable to verify the QR code.');
  String get qrUserFound => _newText('qrUserFound', 'Utilisateur trouvé', 'User found');
  String get scanAgain => _newText('scanAgain', 'Scanner un autre QR Code', 'Scan another QR code');
  String get qrVerifying => _newText('qrVerifying', 'Vérification...', 'Verifying...');
  String get qrScannerHint => _newText('qrScannerHint', 'Placez le QR Code WiFi Mouni dans le cadre.', 'Place the WiFi Mouni QR code inside the frame.');
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
