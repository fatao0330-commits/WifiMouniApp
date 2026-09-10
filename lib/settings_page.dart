import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'language_selector.dart';
import 'localization.dart';
import 'login_page.dart';
import 'pin_page.dart';

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
          ListTile(
            leading: const Icon(Icons.pin_outlined),
            title: Text(strings.text('pin')),
            subtitle: Text(strings.text('pinSubtitle')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PinPage())),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(strings.text('logout')),
            onTap: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
