import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'language_selector.dart';
import 'localization.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _savedPin;
  bool _isLoadingPin = true;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final pin = await AppSettings.loadPin();
    if (!mounted) return;
    setState(() {
      _savedPin = pin;
      _isLoadingPin = false;
    });
  }

  Future<void> _openPinDialog() async {
    final strings = AppLocalizations.of(context);
    final pinController = TextEditingController();
    final confirmationController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_savedPin == null ? strings.text('createPin') : strings.text('changePin')),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: pinController,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(labelText: strings.text('pin'), counterText: ''),
                validator: (value) => _validatePin(value, strings),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmationController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(labelText: strings.text('confirmPin'), counterText: ''),
                validator: (value) => value != pinController.text ? strings.text('pinMismatch') : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(strings.text('cancel'))),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              try {
                await AppSettings.savePin(pinController.text);
                if (!mounted) return;
                setState(() => _savedPin = pinController.text);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _showMessage(strings.text('pinSaved'));
              } catch (_) {
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _showMessage(strings.text('pinSaveError'), isError: true);
              }
            },
            child: Text(strings.text('save')),
          ),
        ],
      ),
    );
    pinController.dispose();
    confirmationController.dispose();
  }

  String? _validatePin(String? value, AppLocalizations strings) {
    if (value == null || !RegExp(r'^\d{4}$').hasMatch(value)) return strings.text('pinInvalid');
    return null;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : null));
  }

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
            leading: const Icon(Icons.lock_outline),
            title: Text(strings.text('pin')),
            subtitle: Text(_isLoadingPin
                ? strings.text('loading')
                : _savedPin == null
                    ? strings.text('pinNotSet')
                    : strings.text('pinSet')),
            trailing: IconButton(
              tooltip: _savedPin == null ? strings.text('createPin') : strings.text('changePin'),
              icon: Icon(_savedPin == null ? Icons.add_circle_outline : Icons.edit_outlined),
              onPressed: _isLoadingPin ? null : _openPinDialog,
            ),
          ),
        ],
      ),
    );
  }
}
