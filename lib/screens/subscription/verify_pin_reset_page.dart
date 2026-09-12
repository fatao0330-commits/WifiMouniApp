import 'package:flutter/material.dart';

import '../../../auth_service.dart';
import '../../../localization.dart';

class VerifyPinResetPage extends StatefulWidget {
  const VerifyPinResetPage({super.key});

  @override
  State<VerifyPinResetPage> createState() => _VerifyPinResetPageState();
}

class _VerifyPinResetPageState extends State<VerifyPinResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  bool _isChecking = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verify(AppLocalizations strings) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isChecking = true);
    final valid = await AuthService.verifyPin(_pinController.text);
    if (!mounted) return;
    if (!valid) {
      setState(() => _isChecking = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.text('pinIncorrect'))));
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.text('verifyPin'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(strings.text('verifyPinSubtitle')),
            const SizedBox(height: 24),
            TextFormField(
              controller: _pinController,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(labelText: strings.text('pin'), border: const OutlineInputBorder()),
              validator: (value) => value != null && RegExp(r'^\d{4,6}$').hasMatch(value) ? null : strings.text('pinInvalid'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isChecking ? null : () => _verify(strings),
              child: _isChecking ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(strings.text('verify')),
            ),
          ],
        ),
      ),
    );
  }
}
