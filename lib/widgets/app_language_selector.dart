import 'package:flutter/material.dart';

import '../main.dart';
import '../services/app_settings_controller.dart';

class AppLanguageSelector extends StatelessWidget {
  const AppLanguageSelector({super.key});

  static const names = <String, String>{
    'fr': 'Français', 'en': 'English', 'es': 'Español', 'ar': 'العربية', 'pt': 'Português', 'hi': 'हिन्दी', 'de': 'Deutsch',
    'ja': '日本語', 'ru': 'Русский', 'zh': '中文', 'it': 'Italiano', 'tr': 'Türkçe', 'ko': '한국어', 'nl': 'Nederlands',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Language',
      icon: const Icon(Icons.language),
      initialValue: appSettings.language,
      onSelected: appSettings.setLanguage,
      itemBuilder: (context) => AppSettingsController.supportedLanguageCodes.map((code) => PopupMenuItem<String>(value: code, child: Text(names[code]!))).toList(),
    );
  }
}