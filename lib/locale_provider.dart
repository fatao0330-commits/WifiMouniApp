import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_settings.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider({Locale initialLocale = const Locale('fr')}) : _locale = initialLocale;

  Locale _locale;
  bool _isLoading = true;

  Locale get locale => _locale;
  bool get isLoading => _isLoading;

  static const supportedLocales = <Locale>[
    Locale('fr'), Locale('en'), Locale('es'), Locale('ar'), Locale('pt'),
    Locale('hi'), Locale('de'), Locale('ja'), Locale('ru'), Locale('zh'),
  ];

  Future<void> load() async {
    final savedLanguage = await AppSettings.loadLocale();
    if (savedLanguage != null && supportedLocales.any((item) => item.languageCode == savedLanguage)) {
      _locale = Locale(savedLanguage);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.any((item) => item.languageCode == locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
    await AppSettings.saveLocale(locale.languageCode);
  }
}