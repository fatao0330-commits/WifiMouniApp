import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/biometric_service.dart';
import '../../services/pin_service.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final _formKey = GlobalKey<FormState>();

  final PinService _pinService = PinService();

  final BiometricService _biometricService =
      BiometricService();

  final TextEditingController _oldPinController =
      TextEditingController();

  final TextEditingController _newPinController =
      TextEditingController();

  final TextEditingController _confirmPinController =
      TextEditingController();

  bool _obscureOldPin = true;
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;

  bool _fingerprintEnabled = false;
  bool _faceIdEnabled = false;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  // ============================================================
  // CHARGER LES PARAMÈTRES DE SÉCURITÉ
  // ============================================================

  Future<void> _loadSecuritySettings() async {
    try {
      final settings =
          await _pinService.getSecuritySettings();

      if (!mounted) return;

      setState(() {
        _fingerprintEnabled =
            settings["fingerprintEnabled"] ?? false;

        _faceIdEnabled =
            settings["faceIdEnabled"] ?? false;
      });
    } catch (_) {
      // Les valeurs par défaut restent false.
    }
  }

  // ============================================================
  // MODIFIER LE PIN
  // ============================================================

  Future<void> _changePin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      // --------------------------------------------------------
      // BIOMÉTRIE
      // --------------------------------------------------------

      if (_fingerprintEnabled || _faceIdEnabled) {
        final authenticated =
            await _biometricService
                .authenticateForPinChange();

        if (!authenticated) {
          if (!mounted) return;

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orange,
              content: Text(
                "Authentification biométrique annulée.",
              ),
            ),
          );

          return;
        }
      }

      // --------------------------------------------------------
      // MODIFICATION DU PIN
      // --------------------------------------------------------

      await _pinService.changePin(
        oldPin: _oldPinController.text.trim(),
        newPin: _newPinController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Votre code PIN a été modifié avec succès.",
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      final message = e
          .toString()
          .replaceFirst(
            "Exception: ",
            "",
          );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // EMPREINTE DIGITALE
  // ============================================================

  Future<void> _toggleFingerprint(
    bool value,
  ) async {
    if (value) {
      final available =
          await _biometricService
              .canUseFingerprint();

      if (!mounted) return;

      if (!available) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Aucune empreinte digitale utilisable n'est disponible sur cet appareil.",
            ),
          ),
        );

        return;
      }
    }

    try {
      await _pinService
          .setFingerprintEnabled(value);

      if (!mounted) return;

      setState(() {
        _fingerprintEnabled = value;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Impossible de modifier ce réglage.",
          ),
        ),
      );
    }
  }

  // ============================================================
  // RECONNAISSANCE FACIALE
  // ============================================================

  Future<void> _toggleFaceId(
    bool value,
  ) async {
    if (value) {
      final available =
          await _biometricService
              .canUseFaceId();

      if (!mounted) return;

      if (!available) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "La reconnaissance faciale n'est pas disponible sur cet appareil.",
            ),
          ),
        );

        return;
      }
    }

    try {
      await _pinService
          .setFaceIdEnabled(value);

      if (!mounted) return;

      setState(() {
        _faceIdEnabled = value;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Impossible de modifier ce réglage.",
          ),
        ),
      );
    }
  }

  // ============================================================
  // CHAMP PIN
  // ============================================================

  InputDecoration _pinDecoration({
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(icon),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),

      suffixIcon: IconButton(
        icon: Icon(
          obscure
              ? Icons.visibility_off
              : Icons.visibility,
        ),
        onPressed: onToggle,
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
          "Modifier le code PIN",
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: ListView(
            padding:
                const EdgeInsets.all(20),

            children: [
              const SizedBox(
                height: 15,
              ),

              const Icon(
                Icons.lock_reset_rounded,
                size: 80,
                color: Colors.blue,
              ),

              const SizedBox(
                height: 15,
              ),

              const Center(
                child: Text(
                  "Sécurité du compte",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Center(
                child: Text(
                  "Modifiez votre code PIN et gérez vos options de sécurité.",
                  textAlign:
                      TextAlign.center,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // =================================================
              // ANCIEN PIN
              // =================================================

              TextFormField(
                controller:
                    _oldPinController,

                keyboardType:
                    TextInputType.number,

                maxLength: 4,

                obscureText:
                    _obscureOldPin,

                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                ],

                decoration:
                    _pinDecoration(
                  label:
                      "Ancien code PIN",
                  icon:
                      Icons.lock_outline,
                  obscure:
                      _obscureOldPin,
                  onToggle: () {
                    setState(() {
                      _obscureOldPin =
                          !_obscureOldPin;
                    });
                  },
                ),

                validator: (value) {
                  final pin =
                      value?.trim() ?? "";

                  if (pin.isEmpty) {
                    return "Entrez votre ancien code PIN.";
                  }

                  if (!RegExp(
                    r'^\d{4}$',
                  ).hasMatch(pin)) {
                    return "Le PIN doit contenir exactement 4 chiffres.";
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // =================================================
              // NOUVEAU PIN
              // =================================================

              TextFormField(
                controller:
                    _newPinController,

                keyboardType:
                    TextInputType.number,

                maxLength: 4,

                obscureText:
                    _obscureNewPin,

                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                ],

                decoration:
                    _pinDecoration(
                  label:
                      "Nouveau code PIN",
                  icon:
                      Icons.lock,
                  obscure:
                      _obscureNewPin,
                  onToggle: () {
                    setState(() {
                      _obscureNewPin =
                          !_obscureNewPin;
                    });
                  },
                ),

                validator: (value) {
                  final pin =
                      value?.trim() ?? "";

                  if (pin.isEmpty) {
                    return "Entrez un nouveau code PIN.";
                  }

                  if (!RegExp(
                    r'^\d{4}$',
                  ).hasMatch(pin)) {
                    return "Le PIN doit contenir exactement 4 chiffres.";
                  }

                  if (pin ==
                      _oldPinController
                          .text
                          .trim()) {
                    return "Le nouveau PIN doit être différent de l'ancien.";
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // =================================================
              // CONFIRMATION
              // =================================================

              TextFormField(
                controller:
                    _confirmPinController,

                keyboardType:
                    TextInputType.number,

                maxLength: 4,

                obscureText:
                    _obscureConfirmPin,

                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                ],

                decoration:
                    _pinDecoration(
                  label:
                      "Confirmer le nouveau code PIN",
                  icon:
                      Icons.verified_user,
                  obscure:
                      _obscureConfirmPin,
                  onToggle: () {
                    setState(() {
                      _obscureConfirmPin =
                          !_obscureConfirmPin;
                    });
                  },
                ),

                validator: (value) {
                  final pin =
                      value?.trim() ?? "";

                  if (pin.isEmpty) {
                    return "Confirmez votre nouveau PIN.";
                  }

                  if (!RegExp(
                    r'^\d{4}$',
                  ).hasMatch(pin)) {
                    return "Le PIN doit contenir exactement 4 chiffres.";
                  }

                  if (pin !=
                      _newPinController
                          .text
                          .trim()) {
                    return "Les deux codes PIN ne correspondent pas.";
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 30,
              ),

              const Divider(),

              const SizedBox(
                height: 15,
              ),

              // =================================================
              // BIOMÉTRIE
              // =================================================

              const Text(
                "Sécurité biométrique",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              SwitchListTile(
                secondary:
                    const Icon(
                  Icons.fingerprint,
                ),

                title: const Text(
                  "Empreinte digitale",
                ),

                subtitle:
                    const Text(
                  "Utiliser votre empreinte pour confirmer les opérations importantes.",
                ),

                value:
                    _fingerprintEnabled,

                onChanged:
                    _loading
                        ? null
                        : _toggleFingerprint,
              ),

              const Divider(),

              SwitchListTile(
                secondary:
                    const Icon(
                  Icons.face,
                ),

                title: const Text(
                  "Reconnaissance faciale",
                ),

                subtitle:
                    const Text(
                  "Utiliser votre visage pour confirmer les opérations importantes.",
                ),

                value:
                    _faceIdEnabled,

                onChanged:
                    _loading
                        ? null
                        : _toggleFaceId,
              ),

              const SizedBox(
                height: 30,
              ),

              // =================================================
              // BOUTON ENREGISTRER
              // =================================================

              SizedBox(
                height: 55,

                child:
                    ElevatedButton.icon(
                  icon: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2.5,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.save,
                        ),

                  label: Text(
                    _loading
                        ? "Enregistrement..."
                        : "Enregistrer les modifications",
                  ),

                  onPressed:
                      _loading
                          ? null
                          : _changePin,

                  style:
                      ElevatedButton.styleFrom(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // =================================================
              // CONSEILS
              // =================================================

              Card(
                elevation: 0,

                color:
                    Colors.blue
                        .withOpacity(0.08),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: const Padding(
                  padding:
                      EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            color:
                                Colors.blue,
                          ),

                          SizedBox(
                            width: 8,
                          ),

                          Text(
                            "Conseils de sécurité",
                            style:
                                TextStyle(
                              fontSize:
                                  17,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 12,
                      ),

                      Text(
                        "• Ne communiquez jamais votre code PIN.\n"
                        "• Choisissez un code difficile à deviner.\n"
                        "• Activez l'empreinte digitale ou la reconnaissance faciale pour les opérations sensibles.\n"
                        "• Utilisez un PIN différent de celui de votre téléphone.\n"
                        "• Si vous pensez que votre PIN est compromis, modifiez-le immédiatement.",
                        style:
                            TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              const Center(
                child: Text(
                  "WiFi Mouni © 2026",
                  style:
                      TextStyle(
                    color:
                        Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();

    super.dispose();
  }
}