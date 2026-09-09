import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/pin_service.dart';

class CreatePinPage extends StatefulWidget {
  final bool isReset;
  final String? resetToken;
  final String? identifier;

  const CreatePinPage({
    super.key,
    this.isReset = false,
    this.resetToken,
    this.identifier,
  });

  @override
  State<CreatePinPage> createState() =>
      _CreatePinPageState();
}

class _CreatePinPageState
    extends State<CreatePinPage> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _pinController =
      TextEditingController();

  final TextEditingController
      _confirmPinController =
      TextEditingController();

  final PinService _pinService =
      PinService();

  bool _hidePin = true;
  bool _hideConfirmPin = true;
  bool _loading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submitPin() async {
    if (_loading) return;

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final pin =
        _pinController.text.trim();

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      if (widget.isReset) {
        final token =
            widget.resetToken
                    ?.trim() ??
                '';

        final identifier =
            widget.identifier
                    ?.trim() ??
                '';

        if (token.isEmpty) {
          throw Exception(
            'Session de réinitialisation invalide.',
          );
        }

        if (identifier.isEmpty) {
          throw Exception(
            'Identifiant de réinitialisation manquant.',
          );
        }

        await _pinService.resetPin(
          identifier: identifier,
          resetToken: token,
          newPin: pin,
        );
      } else {
        await _pinService.createPin(
          pin,
        );
      }

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      await _showSuccessDialog();

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on FirebaseException catch (e) {
      _handleError(
        e.message ??
            'Impossible d’enregistrer votre code PIN.',
      );
    } catch (e) {
      _handleError(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  Future<void> _showSuccessDialog() async {
    final title =
        widget.isReset
            ? 'PIN réinitialisé'
            : 'Code PIN créé';

    final message =
        widget.isReset
            ? 'Votre nouveau code PIN WiFi Mouni a été enregistré avec succès.\n\n'
              'Ne communiquez jamais votre code PIN.'
            : 'Votre code PIN WiFi Mouni a été créé avec succès.\n\n'
              'Ne communiquez jamais votre code PIN.';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  title,
                ),
              ),
            ],
          ),
          content: Text(
            message,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'Compris',
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleError(
    String message,
  ) {
    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    _showMessage(
      message,
      error: true,
    );
  }

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error
                ? Colors.red
                : Colors.green,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required Widget suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle:
          const TextStyle(
        color: Colors.grey,
      ),
      hintStyle:
          const TextStyle(
        color: Colors.grey,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.blue,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor:
          const Color(0xff1d1d1d),
      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),
        borderSide:
            BorderSide.none,
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),
        borderSide:
            const BorderSide(
          color: Colors.blue,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),
        borderSide:
            const BorderSide(
          color: Colors.red,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final title =
        widget.isReset
            ? 'Nouveau code PIN'
            : 'Créer mon code PIN';

    final mainTitle =
        widget.isReset
            ? 'Créer un nouveau PIN'
            : 'Créer votre code PIN';

    final description =
        widget.isReset
            ? 'Votre numéro a été vérifié avec succès.\n\n'
              'Choisissez un nouveau code PIN de 4 chiffres.'
            : 'Choisissez un code personnel de 4 chiffres.\n\n'
              'Ce code sera utilisé pour confirmer certaines opérations sensibles.';

    final buttonText =
        widget.isReset
            ? 'Enregistrer le nouveau PIN'
            : 'Créer mon code PIN';

    return Scaffold(
      backgroundColor:
          const Color(0xff101010),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed:
              _loading
                  ? null
                  : () =>
                      Navigator.of(
                        context,
                      ).pop(),
        ),

        title: Text(
          title,
          style:
              const TextStyle(
            color: Colors.white,
          ),
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
                height: 25,
              ),

              Icon(
                widget.isReset
                    ? Icons.lock_reset
                    : Icons.pin,
                size: 90,
                color: Colors.blue,
              ),

              const SizedBox(
                height: 25,
              ),

              Text(
                mainTitle,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Text(
                description,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(
                height: 35,
              ),

              TextFormField(
                controller:
                    _pinController,

                obscureText:
                    _hidePin,

                keyboardType:
                    TextInputType.number,

                maxLength: 4,

                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                ],

                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 8,
                ),

                decoration:
                    _inputDecoration(
                  label:
                      widget.isReset
                          ? 'Nouveau PIN'
                          : 'Code PIN',

                  hint:
                      '4 chiffres',

                  icon:
                      Icons.lock,

                  suffix:
                      IconButton(
                    icon: Icon(
                      _hidePin
                          ? Icons
                              .visibility_off
                          : Icons
                              .visibility,
                      color:
                          Colors.grey,
                    ),
                    onPressed:
                        _loading
                            ? null
                            : () {
                                setState(
                                  () {
                                    _hidePin =
                                        !_hidePin;
                                  },
                                );
                              },
                  ),
                ),

                validator: (value) {
                  final pin =
                      value?.trim() ??
                          '';

                  if (pin.isEmpty) {
                    return
                        'Entrez votre code PIN.';
                  }

                  if (!RegExp(
                    r'^\d{4}$',
                  ).hasMatch(pin)) {
                    return
                        'Le PIN doit contenir exactement 4 chiffres.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 18,
              ),

              TextFormField(
                controller:
                    _confirmPinController,

                obscureText:
                    _hideConfirmPin,

                keyboardType:
                    TextInputType.number,

                maxLength: 4,

                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                ],

                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 8,
                ),

                decoration:
                    _inputDecoration(
                  label:
                      'Confirmer le PIN',

                  hint:
                      'Répétez les 4 chiffres',

                  icon:
                      Icons.lock_outline,

                  suffix:
                      IconButton(
                    icon: Icon(
                      _hideConfirmPin
                          ? Icons
                              .visibility_off
                          : Icons
                              .visibility,
                      color:
                          Colors.grey,
                    ),
                    onPressed:
                        _loading
                            ? null
                            : () {
                                setState(
                                  () {
                                    _hideConfirmPin =
                                        !_hideConfirmPin;
                                  },
                                );
                              },
                  ),
                ),

                validator: (value) {
                  final pin =
                      value?.trim() ??
                          '';

                  if (pin.isEmpty) {
                    return
                        'Confirmez votre code PIN.';
                  }

                  if (!RegExp(
                    r'^\d{4}$',
                  ).hasMatch(pin)) {
                    return
                        'Le PIN doit contenir exactement 4 chiffres.';
                  }

                  if (pin !=
                      _pinController
                          .text
                          .trim()) {
                    return
                        'Les codes PIN ne correspondent pas.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 25,
              ),

              Container(
                padding:
                    const EdgeInsets.all(
                  15,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xff1d1d1d,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    const Icon(
                      Icons.security,
                      color: Colors.blue,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        widget.isReset
                            ? 'Votre ancien PIN ne sera plus utilisable. Votre nouveau PIN doit rester secret.'
                            : 'Votre PIN doit rester secret. WiFi Mouni ne vous demandera jamais de communiquer votre code PIN.',
                        style:
                            const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 55,

                child:
                    ElevatedButton(
                  onPressed:
                      _loading
                          ? null
                          : _submitPin,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),

                  child:
                      _loading
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child:
                                  CircularProgressIndicator(
                                color:
                                    Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              buttonText,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
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
}