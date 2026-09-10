import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'localization.dart';

class PinPage extends StatefulWidget {
  const PinPage({super.key});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _hasPin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPinState();
  }

  Future<void> _loadPinState() async {
    final hasPin = await AuthService.hasPin();
    if (!mounted) return;
    setState(() {
      _hasPin = hasPin;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate()) return;
    await AuthService.savePin(_pinController.text);
    if (!mounted) return;
    setState(() => _hasPin = true);
    _pinController.clear();
    _confirmationController.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).text('pinSaved'))));
  }

  Future<void> _removePin() async {
    await AuthService.removePin();
    if (!mounted) return;
    setState(() => _hasPin = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).text('pinRemoved'))));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.text('pin'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(strings.text('pinSubtitle')),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 6,
                        decoration: InputDecoration(labelText: strings.text('pin'), border: const OutlineInputBorder()),
                        validator: (value) {
                          final pin = value ?? '';
                          if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) return strings.text('pinInvalid');
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmationController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 6,
                        decoration: InputDecoration(labelText: strings.text('confirmPin'), border: const OutlineInputBorder()),
                        validator: (value) => value != _pinController.text ? strings.text('pinMismatch') : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: _savePin, child: Text(strings.text('save'))),
                if (_hasPin) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _removePin, child: Text(strings.text('removePin'))),
                ],
              ],
            ),
    );
  }
}
