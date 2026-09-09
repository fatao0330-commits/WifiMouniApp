import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;

      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS n’est pas configuré pour WiFi Mouni.',
        );

      case TargetPlatform.macOS:
        throw UnsupportedError(
          'macOS n’est pas configuré pour WiFi Mouni.',
        );

      case TargetPlatform.windows:
        throw UnsupportedError(
          'Windows n’est pas configuré pour WiFi Mouni.',
        );

      case TargetPlatform.linux:
        throw UnsupportedError(
          'Linux n’est pas configuré pour WiFi Mouni.',
        );

      default:
        throw UnsupportedError(
          'Plateforme non prise en charge.',
        );
    }
  }

  // ============================================================
  // FIREBASE WEB
  // ============================================================

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBhS0RKM3uaJ-RgWWeUPB8VhnfLdSy70rc',
    authDomain: 'wifi-mouni.firebaseapp.com',
    projectId: 'wifi-mouni',
    storageBucket: 'wifi-mouni.firebasestorage.app',
    messagingSenderId: '661243021438',
    appId: '1:661243021438:web:6c2986119eff4cd1e7b02f',
  );

  // ============================================================
  // FIREBASE ANDROID
  // ============================================================

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCFEa4uqRyZecVz1-wI_9nE1UMGNgg1iE',
    appId: '1:661243021438:android:fc3287d62d312ba6e7b02f',
    messagingSenderId: '661243021438',
    projectId: 'wifi-mouni',
    storageBucket: 'wifi-mouni.firebasestorage.app',
  );
}