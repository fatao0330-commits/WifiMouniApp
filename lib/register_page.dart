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

class _RegisterForm extends StatefulWidget {
  const _RegisterForm({required this.title, required this.subtitle, required this.alternateText, required this.alternateLabel, required this.onAlternate});

  final String title;
  final String subtitle;
  final String alternateText;
  final String alternateLabel;
  final VoidCallback onAlternate;

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value, AppLocalizations strings) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return strings.text('emailRequired');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) return strings.text('emailInvalid');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(widget.subtitle),
        const SizedBox(height: 28),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(labelText: strings.text('email'), border: const OutlineInputBorder()),
                validator: (value) => _validateEmail(value, strings),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(labelText: strings.text('password'), border: const OutlineInputBorder()),
                validator: (value) {
                  final password = value ?? '';
                  if (password.isEmpty) return strings.text('passwordRequired');
                  if (password.length < 6) return strings.text('passwordTooShort');
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) FocusScope.of(context).unfocus();
          },
          child: Text(strings.text('continue')),
        ),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(widget.alternateText), TextButton(onPressed: widget.onAlternate, child: Text(widget.alternateLabel))]),
      ],
    );
  }
}