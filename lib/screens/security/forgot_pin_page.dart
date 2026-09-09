import 'package:flutter/material.dart';

import '../../services/pin_service.dart';
import 'verify_pin_reset_page.dart';

class ForgotPinPage extends StatefulWidget {
  const ForgotPinPage({
    super.key,
  });

  @override
  State<ForgotPinPage> createState() =>
      _ForgotPinPageState();
}

class _ForgotPinPageState
    extends State<ForgotPinPage> {
  final GlobalKey<FormState>
      _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _identifierController =
      TextEditingController();

  final PinService _pinService =
      PinService();

  bool _loading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_loading) return;

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final identifier =
        _identifierController.text
            .trim();

    setState(() {
      _loading = true;
    });

    try {
      final result =
          await _pinService
              .requestPinReset(
        identifier,
      );

      if (!mounted) return;

      final maskedDestination =
          result[
                  'maskedDestination']
              ?.toString() ??
          'destination masquée';

      final method =
          result['method']
                  ?.toString() ??
              'phone';

      setState(() {
        _loading = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              VerifyPinResetPage(
            identifier:
                identifier,
            maskedDestination:
                maskedDestination,
            method:
                method,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        error: true,
      );
    }
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

  String? _validateIdentifier(
    String? value,
  ) {
    final text =
        value?.trim() ?? '';

    if (text.isEmpty) {
      return
          'Entrez votre numéro de téléphone.';
    }

    if (!RegExp(
      r'^[0-9+ ]{8,20}$',
    ).hasMatch(text)) {
      return
          'Numéro de téléphone invalide.';
    }

    return null;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
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

        title: const Text(
          'PIN oublié',
          style: TextStyle(
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
                height: 30,
              ),

              const Icon(
                Icons.lock_reset,
                size: 90,
                color: Colors.blue,
              ),

              const SizedBox(
                height: 25,
              ),

              const Text(
                'Réinitialiser votre PIN',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              const Text(
                'Entrez le numéro de téléphone utilisé lors de la création de votre compte WiFi Mouni.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
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
                    _identifierController,

                keyboardType:
                    TextInputType.phone,

                style:
                    const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    InputDecoration(
                  labelText:
                      'Numéro de téléphone',

                  hintText:
                      'Ex. 0700000000',

                  labelStyle:
                      const TextStyle(
                    color: Colors.grey,
                  ),

                  hintStyle:
                      const TextStyle(
                    color: Colors.grey,
                  ),

                  prefixIcon:
                      const Icon(
                    Icons.phone_outlined,
                    color: Colors.blue,
                  ),

                  filled: true,

                  fillColor:
                      const Color(
                    0xff1d1d1d,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    borderSide:
                        const BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),

                validator:
                    _validateIdentifier,
              ),

              const SizedBox(
                height: 20,
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

                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Icon(
                      Icons.security,
                      color: Colors.blue,
                    ),

                    SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        'Un code de vérification à 4 chiffres sera envoyé par SMS. Ne partagez jamais ce code.',
                        style: TextStyle(
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
                height: 55,
                width:
                    double.infinity,

                child:
                    ElevatedButton(
                  onPressed:
                      _loading
                          ? null
                          : _continue,

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
                          : const Text(
                              'Continuer',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}