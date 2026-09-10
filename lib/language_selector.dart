import 'package:flutter/material.dart';

import 'locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  static const names = <String, String>{
    'fr': 'Français', 'en': 'English', 'es': 'Español', 'ar': 'العربية',
    'pt': 'Português', 'hi': 'हिन्दी', 'de': 'Deutsch', 'ja': '日本語',
    'ru': 'Русский', 'zh': '中文',
  };

  @override
  Widget build(BuildContext context) {
    final provider = LocaleScope.of(context);
    return DropdownButton<Locale>(
      value: provider.locale,
      underline: const SizedBox.shrink(),
      icon: const Icon(Icons.language),
      items: LocaleProvider.supportedLocales.map((locale) => DropdownMenuItem(value: locale, child: Text(names[locale.languageCode]!))).toList(),
      onChanged: (locale) {
        if (locale != null) provider.setLocale(locale);
      },
    );
  }
}

class LocaleScope extends InheritedNotifier<LocaleProvider> {
  const LocaleScope({required super.notifier, required super.child});

  static LocaleProvider of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<LocaleScope>()!.notifier!;
}
