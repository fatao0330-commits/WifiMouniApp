import 'package:flutter/material.dart';

import 'language_selector.dart';
import 'localization.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(actions: const [LanguageSelector()]),
      body: _RegisterForm(
        title: strings.text('register'),
        subtitle: strings.text('createAccount'),
        alternateText: strings.text('hasAccount'),
        alternateLabel: strings.text('login'),
        onAlternate: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({required this.title, required this.subtitle, required this.alternateText, required this.alternateLabel, required this.onAlternate});

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