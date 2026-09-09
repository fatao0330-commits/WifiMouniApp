import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/pin_service.dart';
import 'create_pin_page.dart';

class VerifyPinResetPage extends StatefulWidget {
  final String identifier;
  final String maskedDestination;
  final String method;

  const VerifyPinResetPage({
    super.key,
    required this.identifier,
    required this.maskedDestination,
    required this.method,
  });

  @override
  State<VerifyPinResetPage> createState() =>
      _VerifyPinResetPageState();
}

class _VerifyPinResetPageState
    extends State<VerifyPinResetPage> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _codeController =
      TextEditingController();

  final PinService _pinService =
      PinService();

  Timer? _timer;

  int _secondsRemaining =
      15 * 60;

  bool _loading = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining =
          15 * 60;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining <= 1) {
          timer.cancel();

          setState(() {
            _secondsRemaining = 0;
          });
        } else {
          setState(() {
            _secondsRemaining--;
          });
        }
      },
    );
  }

  String get _formattedTime {
    final minutes =
        (_secondsRemaining ~/ 60)
            .toString()
            .padLeft(2, '0');

    final seconds =
        (_secondsRemaining % 60)
            .toString()
            .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  Future<void> _verifyCode() async {
    if (_loading) return;

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_secondsRemaining <= 0) {
      _showMessage(
        'Le code a expiré. Demandez un nouveau code.',
        error: true,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      final resetToken =
          await _pinService
              .verifyPinResetCode(
        identifier:
            widget.identifier,
        code:
            _codeController.text.trim(),
      );

      if (!mounted) return;

      _timer?.cancel();

      setState(() {
        _loading = false;
      });

      Navigator.of(context)
          .pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              CreatePinPage(
            isReset: true,
            identifier:
                widget.identifier,
            resetToken:
                resetToken,
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

  Future<void> _resendCode() async {
    if (_resending ||
        _loading) {
      return;
    }

    setState(() {
      _resending = true;
    });

    try {
      final result =
          await _pinService
              .requestPinReset(
        widget.identifier,
      );

      if (!mounted) return;

      _codeController.clear();

      _startTimer();

      final message =
          result['message']
              ?.toString();

      _showMessage(
        message == null ||
                message.isEmpty
            ? 'Un nouveau code a été envoyé.'
            : message,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _resending = false;
        });
      }
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
          'Vérification',
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
                Icons.sms_outlined,
                size: 85,
                color: Colors.blue,
              ),

              const SizedBox(
                height: 25,
              ),

              const Text(
                'Vérifiez votre compte',
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
                'Un code de vérification a été envoyé sur votre numéro de téléphone.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                widget.maskedDestination,
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 30,
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
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.blue,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        _secondsRemaining >
                                0
                            ? 'Le code expire dans $_formattedTime'
                            : 'Le code a expiré.',
                        style:
                            const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              TextFormField(
                controller:
                    _codeController,

                keyboardType:
                    TextInputType.number,

                maxLength: 4,

                textAlign:
                    TextAlign.center,

                autofocus: true,

                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                ],

                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                  letterSpacing: 8,
                ),

                decoration:
                    InputDecoration(
                  labelText:
                      'Code de vérification',

                  hintText:
                      '0000',

                  counterText: '',

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
                    Icons.password,
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

                validator: (value) {
                  final code =
                      value?.trim() ?? '';

                  if (code.isEmpty) {
                    return
                        'Entrez le code reçu.';
                  }

                  if (!RegExp(
                    r'^\d{4}$',
                  ).hasMatch(code)) {
                    return
                        'Le code doit contenir 4 chiffres.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 25,
              ),

              SizedBox(
                height: 55,
                width: double.infinity,

                child:
                    ElevatedButton(
                  onPressed:
                      _loading ||
                              _resending ||
                              _secondsRemaining <=
                                  0
                          ? null
                          : _verifyCode,

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
                              'Confirmer le code',
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

              const SizedBox(
                height: 20,
              ),

              TextButton(
                onPressed:
                    _resending ||
                            _loading
                        ? null
                        : _resendCode,

                child:
                    _resending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Renvoyer le code',
                          ),
              ),

              const SizedBox(
                height: 15,
              ),

              const Text(
                'Ne partagez jamais ce code avec une autre personne.',
                textAlign:
                    TextAlign.center,
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