import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../l10n/app_localizations.dart';

class OtpPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey =
      GlobalKey<FormState>();

  final codeController =
      TextEditingController();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final AuthService _authService =
      AuthService();

  bool loading = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  // ============================================================
  // VÉRIFIER LE CODE
  // ============================================================

  Future<void> _verifyCode() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final strings = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

    try {
      final smsCode =
          codeController.text.trim();

      final credential =
          PhoneAuthProvider.credential(
        verificationId:
            widget.verificationId,
        smsCode: smsCode,
      );

      final user =
          _auth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
            message: strings.accountSessionMissing,
        );
      }

      // ========================================================
      // LIER LE NUMÉRO AU COMPTE EMAIL
      // ========================================================

      await user.linkWithCredential(
        credential,
      );

      // ========================================================
      // ENREGISTRER LA VÉRIFICATION DANS FIRESTORE
      // ========================================================

      final phoneMarked = await _authService.markPhoneVerified();
      if (!phoneMarked) {
        throw StateError(strings.otpVerificationFailed);
      }

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        strings.phoneVerified,
      );

      // Retour vers RegisterPage
      Navigator.pop(
        context,
        true,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      String message = strings.otpVerificationFailed;

      switch (e.code) {
        case 'invalid-verification-code':
          break;

        case 'invalid-verification-id':
            message = strings.otpExpired;
          break;

        case 'credential-already-in-use':
            message = strings.phoneAlreadyInUse;
          break;

        case 'provider-already-linked':
            message = strings.phoneVerified;
          break;

        case 'too-many-requests':
            message = strings.otpVerificationFailed;
          break;

        default:
            message = strings.otpVerificationFailed;
      }

      _showMessage(
        message,
        error: true,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        strings.otpVerificationFailed,
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

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor:
          const Color(0xff101010),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        title: Text(strings.phoneVerificationTitle),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: ListView(
            padding:
                const EdgeInsets.all(20),

            children: [
              const SizedBox(height: 40),

              const Icon(
                Icons.sms_outlined,
                size: 85,
                color: Colors.blue,
              ),

              const SizedBox(height: 25),

              Text(
                strings.phoneVerificationTitle,
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                '${strings.otpSent}\n${widget.phoneNumber}',
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 35),

              TextFormField(
                controller:
                    codeController,

                keyboardType:
                    TextInputType.number,

                maxLength: 6,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  letterSpacing: 8,
                  fontWeight:
                      FontWeight.bold,
                ),

                decoration:
                    InputDecoration(
                  labelText:
                      strings.smsCode,
                  labelStyle:
                      const TextStyle(
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor:
                      const Color(
                          0xff1d1d1d),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(15),
                    borderSide:
                        BorderSide.none,
                  ),
                ),

                validator: (value) {
                  final code =
                      value?.trim() ?? '';

                  if (code.isEmpty) {
                    return strings.otpRequired;
                  }

                  if (code.length != 6) {
                    return strings.firebaseOtpInvalid;
                  }

                  return null;
                },
              ),

              const SizedBox(height: 25),

              SizedBox(
                height: 55,
                child:
                    ElevatedButton(
                  onPressed:
                      loading
                          ? null
                          : _verifyCode,

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.blue,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(15),
                    ),
                  ),

                  child: loading
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
                          strings.verifyCode,
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                strings.otpHelp,
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