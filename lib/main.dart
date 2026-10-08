import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'localization.dart' as legacy_localizations;

import 'screens/auth/login_page.dart';

import 'services/app_settings_controller.dart';

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
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    appSettings.removeListener(
      _settingsChanged,
    );

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
      debugShowCheckedModeBanner: false,

      title: 'WiFi Mouni',

      // ========================================================
      // LOCALISATION
      // ========================================================

      locale: appSettings.locale,

      supportedLocales: AppLocalizations.supportedLocales,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        legacy_localizations.AppLocalizations.delegate,
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
