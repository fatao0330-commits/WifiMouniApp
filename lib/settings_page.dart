import 'package:flutter/material.dart';

import 'language_selector.dart';
import 'localization.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.text('settings'))),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(strings.text('language')),
            subtitle: Text(strings.text('chooseLanguage')),
            trailing: const LanguageSelector(),
          ),
        ],
      ),
    );
  }
}
