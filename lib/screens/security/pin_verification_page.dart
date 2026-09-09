import 'package:flutter/material.dart';

import '../../services/pin_service.dart';
import '../../services/biometric_service.dart';

class PinVerificationPage extends StatefulWidget {
  final Future<void> Function() onSuccess;

  const PinVerificationPage({
    super.key,
    required this.onSuccess,
  });

  @override
  State<PinVerificationPage> createState() =>
      _PinVerificationPageState();
}

class _PinVerificationPageState
    extends State<PinVerificationPage> {
  final PinService _pinService = PinService();

  final BiometricService _biometricService =
      BiometricService();

  final TextEditingController _pinController =
      TextEditingController();

  bool _loading = false;
  bool _biometricAvailable = false;
  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // ============================================================
  // BIOMÉTRIE
  // ============================================================

  Future<void> _loadBiometricStatus() async {
    try {
      final available =
          await _biometricService.isBiometricReady();

      if (!mounted) return;

      setState(() {
        _biometricAvailable = available;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _biometricAvailable = false;
      });
    }
  }

  // ============================================================
  // VÉRIFICATION DU PIN
  // ============================================================

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      _showMessage(
        'Le code PIN doit contenir exactement 4 chiffres.',
        error: true,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      final isValid =
          await _pinService.verifyPin(pin);

      if (!mounted) return;

      if (!isValid) {
        setState(() {
          _loading = false;
        });

        _pinController.clear();

        _showMessage(
          'Code PIN incorrect.',
          error: true,
        );

        return;
      }

      // Le PIN est correct.
      // On ferme la page avant de poursuivre
      // l'opération sensible.
      Navigator.of(context).pop();

      await widget.onSuccess();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(
        'Impossible de vérifier le code PIN.',
        error: true,
      );
    }
  }

  // ============================================================
  // BIOMÉTRIE
  // ============================================================

  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _loading = true;
    });

    try {
      final success =
          await _biometricService.authenticate(
        reason:
            'Confirmez votre identité pour continuer.',
      );

      if (!mounted) return;

      if (!success) {
        setState(() {
          _loading = false;
        });

        _showMessage(
          'Authentification biométrique échouée.',
          error: true,
        );

        return;
      }

      Navigator.of(context).pop();

      await widget.onSuccess();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(
        'Impossible de vérifier votre identité.',
        error: true,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error ? Colors.red : Colors.green,
      ),
    );
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vérification du PIN',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 30),

              const Icon(
                Icons.lock,
                size: 80,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                'Confirmez votre identité',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Entrez votre code PIN à 4 chiffres '
                'pour continuer.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 35),

              TextField(
                controller: _pinController,

                keyboardType:
                    TextInputType.number,

                obscureText: _obscurePin,

                maxLength: 4,

                enabled: !_loading,

                style: const TextStyle(
                  fontSize: 22,
                  letterSpacing: 8,
                ),

                decoration: InputDecoration(
                  labelText: 'Code PIN',

                  border:
                      const OutlineInputBorder(),

                  prefixIcon:
                      const Icon(Icons.password),

                  suffixIcon: IconButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              _obscurePin =
                                  !_obscurePin;
                            });
                          },

                    icon: Icon(
                      _obscurePin
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),

                onSubmitted: (_) {
                  if (!_loading) {
                    _verifyPin();
                  }
                },
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed:
                      _loading
                          ? null
                          : _verifyPin,

                  child: _loading
                      ? const SizedBox(
                          width: 25,
                          height: 25,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Valider',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              if (_biometricAvailable) ...[
                const SizedBox(height: 20),

                const Text(
                  'ou',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child:
                      OutlinedButton.icon(
                    onPressed:
                        _loading
                            ? null
                            : _authenticateWithBiometric,

                    icon: const Icon(
                      Icons.fingerprint,
                    ),

                    label: const Text(
                      'Utiliser la biométrie',
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 25),

              const Text(
                'Ne communiquez jamais votre code PIN '
                'à une autre personne.',
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}