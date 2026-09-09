import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

import 'screens/auth/login_page.dart';
import 'screens/auth/reset_password_page.dart';

import 'services/app_settings_controller.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ============================================================
// CONTRÔLEUR GLOBAL DES PARAMÈTRES
// ============================================================
//
// Accessible depuis toutes les pages avec :
//
// appSettings.updateLanguage(...)
// appSettings.updateDarkMode(...)
// appSettings.updateNotifications(...)
//
late final AppSettingsController appSettings;

// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================================
  // FIREBASE
  // ==========================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ==========================================================
  // CONTRÔLEUR GLOBAL
  // ==========================================================

  appSettings = AppSettingsController(
    language: 'fr',
    darkMode: false,
    notifications: true,
  );

  // Charger les paramètres sauvegardés.
  try {
    await appSettings.load();
  } catch (e) {
    debugPrint(
      'Impossible de charger les paramètres : $e',
    );
  }

  // ==========================================================
  // LANCER L'APPLICATION
  // ==========================================================

  runApp(
    const WiFiMouniApp(),
  );
}

// ============================================================
// APPLICATION WIFI MOUNI
// ============================================================

class WiFiMouniApp extends StatefulWidget {
  const WiFiMouniApp({
    super.key,
  });

  @override
  State<WiFiMouniApp> createState() => _WiFiMouniAppState();
}

class _WiFiMouniAppState extends State<WiFiMouniApp> {
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _linkSubscription;

  bool _openingResetPage = false;

  // ==========================================================
  // INIT STATE
  // ==========================================================

  @override
  void initState() {
    super.initState();

    // Écouter les changements de :
    // - langue
    // - mode sombre
    // - notifications
    appSettings.addListener(
      _settingsChanged,
    );

    // Initialiser les Deep Links.
    _initDeepLinks();
  }

  // ==ÿ========================================================
  // PARAMÈTRES MODIFIÉS
  // ==========================================================

  void _settingsChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ==========================================================
  // DEEP LINKS
  // ==========================================================

  Future<void> _initDeepLinks() async {
    try {
      // --------------------------------------------------------
      // LIEN QUI A OUVERT L'APPLICATION
      // --------------------------------------------------------

      final Uri? initialUri = await _appLinks.getInitialLink();

      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }

      // --------------------------------------------------------
      // LIENS REÇUS ALORS QUE L'APPLICATION EST OUVERTE
      // --------------------------------------------------------

      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          _handleDeepLink(uri);
        },
        onError: (error) {
          debugPrint(
            'Erreur Deep Link : $error',
          );
        },
      );
    } catch (e) {
      debugPrint(
        'Impossible d\'initialiser les Deep Links : $e',
      );
    }
  }

  // ==========================================================
  // TRAITER UN DEEP LINK
  // ==========================================================

  void _handleDeepLink(Uri uri) {
    debugPrint(
      'Deep Link reçu : $uri',
    );

    final String? mode = uri.queryParameters['mode'];

    final String? oobCode = uri.queryParameters['oobCode'];

    if (mode == 'resetPassword' && oobCode != null && oobCode.isNotEmpty) {
      _openResetPasswordPage(
        oobCode,
      );
    }
  }

  // ==========================================================
  // OUVRIR RESET PASSWORD
  // ==========================================================

  void _openResetPasswordPage(
    String oobCode,
  ) {
    if (_openingResetPage) {
      return;
    }

    _openingResetPage = true;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final navigator = navigatorKey.currentState;

        if (navigator == null) {
          _openingResetPage = false;
          return;
        }

        navigator.push(
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(
              oobCode: oobCode,
            ),
          ),
        );

        Future.delayed(
          const Duration(
            milliseconds: 500,
          ),
          () {
            _openingResetPage = false;
          },
        );
      },
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    appSettings.removeListener(
      _settingsChanged,
    );

    _linkSubscription?.cancel();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      navigatorKey: navigatorKey,

      debugShowCheckedModeBanner: false,

      title: 'WiFi Mouni',

      // ========================================================
      // LOCALISATION
      // ========================================================

      locale: appSettings.locale,

      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ========================================================
      // THÈME CLAIR
      // ========================================================

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),

      // ========================================================
      // THÈME SOMBRE
      // ========================================================

      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),

      // ========================================================
      // MODE ACTUEL
      // ========================================================

      themeMode: appSettings.themeMode,

      // ========================================================
      // PAGE DE DÉMARRAGE
      // ========================================================

      home: const LoginPage(),
    );
  }
}
