import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _values = <String, Map<String, String>>{
    'fr': {'appName': 'Wifi Mouni', 'login': 'Connexion', 'register': 'Créer un compte', 'email': 'Adresse e-mail', 'password': 'Mot de passe', 'continue': 'Continuer', 'settings': 'Paramètres', 'language': 'Langue', 'chooseLanguage': 'Choisir la langue', 'welcome': 'Bienvenue sur Wifi Mouni', 'home': 'Accueil', 'logout': 'Déconnexion', 'noAccount': 'Pas encore de compte ?', 'hasAccount': 'Vous avez déjà un compte ?', 'createAccount': 'Inscrivez-vous pour commencer', 'loginSubtitle': 'Connectez-vous à votre compte', 'pin': 'Code PIN', 'createPin': 'Créer un code PIN', 'changePin': 'Modifier le code PIN', 'confirmPin': 'Confirmer le code PIN', 'pinInvalid': 'Le code PIN doit contenir exactement 4 chiffres.', 'pinMismatch': 'Les codes PIN ne correspondent pas.', 'pinSaved': 'Code PIN enregistré.', 'pinSaveError': 'Impossible d’enregistrer le code PIN.', 'pinNotSet': 'Aucun code PIN défini', 'pinSet': 'Code PIN défini', 'loading': 'Chargement...', 'cancel': 'Annuler', 'save': 'Enregistrer'},
    'en': {'appName': 'Wifi Mouni', 'login': 'Login', 'register': 'Create account', 'email': 'Email address', 'password': 'Password', 'continue': 'Continue', 'settings': 'Settings', 'language': 'Language', 'chooseLanguage': 'Choose language', 'welcome': 'Welcome to Wifi Mouni', 'home': 'Home', 'logout': 'Log out', 'noAccount': "Don't have an account?", 'hasAccount': 'Already have an account?', 'createAccount': 'Sign up to get started', 'loginSubtitle': 'Log in to your account', 'pin': 'PIN code', 'createPin': 'Create PIN code', 'changePin': 'Change PIN code', 'confirmPin': 'Confirm PIN code', 'pinInvalid': 'The PIN must contain exactly 4 digits.', 'pinMismatch': 'The PIN codes do not match.', 'pinSaved': 'PIN code saved.', 'pinSaveError': 'Unable to save the PIN code.', 'pinNotSet': 'No PIN configured', 'pinSet': 'PIN configured', 'loading': 'Loading...', 'cancel': 'Cancel', 'save': 'Save'},
    'es': {'login': 'Iniciar sesión', 'register': 'Crear cuenta', 'email': 'Correo electrónico', 'password': 'Contraseña', 'continue': 'Continuar', 'settings': 'Ajustes', 'language': 'Idioma', 'chooseLanguage': 'Elegir idioma', 'welcome': 'Bienvenido a Wifi Mouni', 'home': 'Inicio', 'logout': 'Cerrar sesión', 'noAccount': '¿No tienes una cuenta?', 'hasAccount': '¿Ya tienes una cuenta?', 'createAccount': 'Regístrate para comenzar', 'loginSubtitle': 'Inicia sesión en tu cuenta'},
    'ar': {'login': 'تسجيل الدخول', 'register': 'إنشاء حساب', 'email': 'البريد الإلكتروني', 'password': 'كلمة المرور', 'continue': 'متابعة', 'settings': 'الإعدادات', 'language': 'اللغة', 'chooseLanguage': 'اختر اللغة', 'welcome': 'مرحبًا بك في Wifi Mouni', 'home': 'الرئيسية', 'logout': 'تسجيل الخروج', 'noAccount': 'ليس لديك حساب؟', 'hasAccount': 'لديك حساب بالفعل؟', 'createAccount': 'أنشئ حسابًا للبدء', 'loginSubtitle': 'سجّل الدخول إلى حسابك'},
    'pt': {'login': 'Entrar', 'register': 'Criar conta', 'email': 'E-mail', 'password': 'Senha', 'continue': 'Continuar', 'settings': 'Definições', 'language': 'Idioma', 'chooseLanguage': 'Escolher idioma', 'welcome': 'Bem-vindo ao Wifi Mouni', 'home': 'Início', 'logout': 'Sair', 'noAccount': 'Ainda não tem uma conta?', 'hasAccount': 'Já tem uma conta?', 'createAccount': 'Crie uma conta para começar', 'loginSubtitle': 'Entre na sua conta'},
    'hi': {'login': 'लॉग इन', 'register': 'खाता बनाएँ', 'email': 'ईमेल पता', 'password': 'पासवर्ड', 'continue': 'जारी रखें', 'settings': 'सेटिंग्स', 'language': 'भाषा', 'chooseLanguage': 'भाषा चुनें', 'welcome': 'Wifi Mouni में आपका स्वागत है', 'home': 'होम', 'logout': 'लॉग आउट', 'noAccount': 'खाता नहीं है?', 'hasAccount': 'पहले से खाता है?', 'createAccount': 'शुरू करने के लिए साइन अप करें', 'loginSubtitle': 'अपने खाते में लॉग इन करें'},
    'de': {'login': 'Anmelden', 'register': 'Konto erstellen', 'email': 'E-Mail-Adresse', 'password': 'Passwort', 'continue': 'Weiter', 'settings': 'Einstellungen', 'language': 'Sprache', 'chooseLanguage': 'Sprache auswählen', 'welcome': 'Willkommen bei Wifi Mouni', 'home': 'Startseite', 'logout': 'Abmelden', 'noAccount': 'Noch kein Konto?', 'hasAccount': 'Bereits ein Konto?', 'createAccount': 'Jetzt registrieren', 'loginSubtitle': 'Melde dich bei deinem Konto an'},
    'ja': {'login': 'ログイン', 'register': 'アカウント作成', 'email': 'メールアドレス', 'password': 'パスワード', 'continue': '続ける', 'settings': '設定', 'language': '言語', 'chooseLanguage': '言語を選択', 'welcome': 'Wifi Mouniへようこそ', 'home': 'ホーム', 'logout': 'ログアウト', 'noAccount': 'アカウントをお持ちでないですか？', 'hasAccount': 'すでにアカウントをお持ちですか？', 'createAccount': '登録して始める', 'loginSubtitle': 'アカウントにログイン'},
    'ru': {'login': 'Войти', 'register': 'Создать аккаунт', 'email': 'Электронная почта', 'password': 'Пароль', 'continue': 'Продолжить', 'settings': 'Настройки', 'language': 'Язык', 'chooseLanguage': 'Выберите язык', 'welcome': 'Добро пожаловать в Wifi Mouni', 'home': 'Главная', 'logout': 'Выйти', 'noAccount': 'Нет аккаунта?', 'hasAccount': 'Уже есть аккаунт?', 'createAccount': 'Зарегистрируйтесь, чтобы начать', 'loginSubtitle': 'Войдите в свой аккаунт'},
    'zh': {'login': '登录', 'register': '创建账户', 'email': '电子邮箱', 'password': '密码', 'continue': '继续', 'settings': '设置', 'language': '语言', 'chooseLanguage': '选择语言', 'welcome': '欢迎使用 Wifi Mouni', 'home': '首页', 'logout': '退出登录', 'noAccount': '还没有账户？', 'hasAccount': '已有账户？', 'createAccount': '注册后开始使用', 'loginSubtitle': '登录您的账户'},
  };

  String text(String key) => _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations._values.keys.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}