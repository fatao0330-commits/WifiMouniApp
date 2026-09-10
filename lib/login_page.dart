import 'package:flutter/material.dart';

import 'language_selector.dart';
import 'localization.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(actions: const [LanguageSelector()]),
      body: _AuthForm(title: strings.text('login'), subtitle: strings.text('loginSubtitle'), alternateText: strings.text('noAccount'), alternateLabel: strings.text('register'), onAlternate: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterPage()))),
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({required this.title, required this.subtitle, required this.alternateText, required this.alternateLabel, required this.onAlternate});

  final String title;
  final String subtitle;
  final String alternateText;
  final String alternateLabel;
  final VoidCallback onAlternate;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(subtitle),
        const SizedBox(height: 28),
        TextField(decoration: InputDecoration(labelText: strings.text('email'), border: const OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(obscureText: true, decoration: InputDecoration(labelText: strings.text('password'), border: const OutlineInputBorder())),
        const SizedBox(height: 24),
        FilledButton(onPressed: () {}, child: Text(strings.text('continue'))),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(alternateText), TextButton(onPressed: onAlternate, child: Text(alternateLabel))]),
      ],
    );
  }
}
