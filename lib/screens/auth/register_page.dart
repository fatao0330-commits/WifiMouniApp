import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/phone_number_utils.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_page.dart';
import 'otp_page.dart';
import '../../widgets/app_language_selector.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController telephoneController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthService authService = AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool loading = false;
  bool _otpPageOpened = false;
  bool _finishingRegistration = false;
  bool _registrationFinished = false;

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // INSCRIPTION
  // ============================================================

  Future<void> _register() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final strings = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

    try {
      final email =
          emailController.text.trim().toLowerCase();

      final phone = PhoneNumberUtils.normalize(
        telephoneController.text,
      );

      // --------------------------------------------------------
      // 1. CRÉATION DU COMPTE + PROFIL + WALLET
      // --------------------------------------------------------

      final result =
          await authService.registerUser(
        nom: nomController.text.trim(),
        email: email,
        telephone: phone,
        password: passwordController.text,
      );

      if (!mounted) return;

      if (result != null) {
        setState(() {
          loading = false;
        });

        _showMessage(
          _registrationErrorText(result, strings),
          error: true,
        );

        return;
      }

      // --------------------------------------------------------
      // ENVOYER LE CODE OTP
      // --------------------------------------------------------

      await _sendOtp(phone);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        _registrationErrorText(e.code, strings),
        error: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        strings.registrationFailed,
        error: true,
      );
    }
  }

  String _registrationErrorText(
    String code,
    AppLocalizations strings,
  ) {
    switch (code) {
      case 'email-already-in-use':
        return strings.emailAlreadyInUse;
      case 'invalid-email':
        return strings.invalidEmail;
      case 'weak-password':
        return strings.weakPassword;
      case 'operation-not-allowed':
        return strings.emailSignUpUnavailable;
      case 'network-request-failed':
        return strings.networkError;
      case 'invalidPhoneNumber':
        return strings.invalidPhoneNumber;
      default:
        return strings.registrationFailed;
    }
  }

  // ============================================================
  // OTP TÉLÉPHONE
  // ============================================================

  Future<void> _sendOtp(
    String phoneNumber,
  ) async {
    final strings = AppLocalizations.of(context);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        // ------------------------------------------------------
        // VÉRIFICATION AUTOMATIQUE
        // ------------------------------------------------------

        verificationCompleted:
            (PhoneAuthCredential credential) async {
          if (_registrationFinished || _finishingRegistration) return;
          final user = _auth.currentUser;

          if (user == null) {
            if (!mounted) return;

            setState(() {
              loading = false;
            });

            _showMessage(
              strings.accountSessionMissing,
              error: true,
            );

            return;
          }

          try {
            await user.linkWithCredential(
              credential,
            );
            final marked = await authService.markPhoneVerified();
            if (!marked) {
              throw StateError('Phone verification could not be saved.');
            }

            if (!mounted) return;

            setState(() {
              loading = false;
            });

            _showMessage(
              strings.phoneVerified,
            );

            await _finishRegistration();
          } on FirebaseAuthException catch (e) {
            if (!mounted) return;

            setState(() {
              loading = false;
            });

            _showMessage(
              e.code == 'credential-already-in-use'
                  ? strings.phoneAlreadyInUse
                  : strings.otpVerificationFailed,
              error: true,
            );
          } catch (_) {
            if (!mounted) return;
            setState(() => loading = false);
            _showMessage(strings.otpVerificationFailed, error: true);
          }
        },

        // ------------------------------------------------------
        // ÉCHEC ENVOI OTP
        // ------------------------------------------------------

        verificationFailed:
            (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() {
            loading = false;
          });

          _showMessage(
            strings.otpSendFailed,
            error: true,
          );
        },

        // ------------------------------------------------------
        // CODE OTP ENVOYÉ
        // ------------------------------------------------------

        codeSent: (
          String verificationId,
          int? resendToken,
        ) async {
          if (!mounted || _otpPageOpened || _registrationFinished) return;

          _otpPageOpened = true;
          setState(() {
            loading = false;
          });

          final verified =
              await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => OtpPage(
                verificationId:
                    verificationId,
                phoneNumber:
                    phoneNumber,
              ),
            ),
          );
          _otpPageOpened = false;

          if (!mounted) return;

          if (verified == true) {
            await _finishRegistration();
          }
        },

        // ------------------------------------------------------
        // TIMEOUT
        // ------------------------------------------------------

        codeAutoRetrievalTimeout:
            (String verificationId) {},
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        strings.otpSendFailed,
        error: true,
      );
    }
  }

  // ============================================================
  // FIN DE L'INSCRIPTION
  // ============================================================

  Future<void> _finishRegistration() async {
    if (!mounted || _finishingRegistration || _registrationFinished) return;
    _finishingRegistration = true;
    final strings = AppLocalizations.of(context);

    setState(() {
      loading = true;
    });

    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw StateError(strings.accountSessionMissing);
      }

      // Actualiser les informations Firebase.
      await user.reload();

      final refreshedUser =
          _auth.currentUser;

      if (refreshedUser == null ||
          refreshedUser.phoneNumber !=
              PhoneNumberUtils.normalize(telephoneController.text)) {
        throw StateError(strings.otpVerificationFailed);
      }

      final phoneMarked = await authService.markPhoneVerified();
      if (!phoneMarked) throw StateError(strings.otpVerificationFailed);

      // --------------------------------------------------------
      // TOUT EST OK
      // → HOME PAGE
      // --------------------------------------------------------

      if (!mounted) return;

      setState(() {
        loading = false;
      });
      _registrationFinished = true;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        strings.registrationFailed,
        error: true,
      );
    } finally {
      _finishingRegistration = false;
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
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor:
          const Color(0xff101010),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,

        title: Text(strings.registerTitle),

        centerTitle: true,
        actions: const [AppLanguageSelector()],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              children: [
                const SizedBox(height: 20),

                const Icon(
                  Icons.wifi,
                  size: 85,
                  color: Colors.blue,
                ),

                const SizedBox(height: 20),

                const Text(
                  'WiFi Mouni',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // NOM
                // =================================================

                TextFormField(
                  controller:
                      nomController,

                  style:
                      const TextStyle(
                    color: Colors.white,
                  ),

                  decoration:
                      _inputDecoration(
                    label: strings.fullName,
                    icon:
                        Icons.person,
                  ),

                  validator: (value) {
                    final name =
                        value?.trim() ?? '';

                    if (name.isEmpty) {
                        return strings.nameRequired;
                    }

                    if (name.length < 2) {
                        return strings.nameTooShort;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // =================================================
                // EMAIL
                // =================================================

                TextFormField(
                  controller:
                      emailController,

                  keyboardType:
                      TextInputType.emailAddress,

                  style:
                      const TextStyle(
                    color: Colors.white,
                  ),

                  decoration:
                      _inputDecoration(
                    label:
                        'Adresse e-mail',
                    icon:
                        Icons.email,
                  ),

                  validator: (value) {
                    final email =
                        value?.trim() ?? '';

                    if (email.isEmpty) {
                        return strings.requiredEmail;
                    }

                    final regex = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    );

                    if (!regex.hasMatch(
                        email)) {
                        return strings.invalidEmail;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // =================================================
                // TÉLÉPHONE
                // =================================================

                TextFormField(
                  controller:
                      telephoneController,

                  keyboardType:
                      TextInputType.phone,

                  style:
                      const TextStyle(
                    color: Colors.white,
                  ),

                  decoration:
                      _inputDecoration(
                    label: strings.enterPhoneNumber,
                    icon:
                        Icons.phone,
                    hint:
                        '+2250700000000',
                  ),

                  validator: (value) {
                    final phone = PhoneNumberUtils.normalize(
                      value ?? '',
                    );

                    if (phone.isEmpty) {
                      return strings.phoneNumberRequired;
                    }

                    if (!PhoneNumberUtils.isValid(phone)) {
                      return phone.startsWith('+')
                          ? strings.invalidPhoneNumber
                          : strings.phoneInternationalFormat;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // =================================================
                // MOT DE PASSE
                // =================================================

                TextFormField(
                  controller:
                      passwordController,

                  obscureText:
                      hidePassword,

                  style:
                      const TextStyle(
                    color: Colors.white,
                  ),

                  decoration:
                      _inputDecoration(
                    label: strings.password,
                    icon:
                        Icons.lock,

                    suffix:
                        IconButton(
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color:
                            Colors.grey,
                      ),

                      onPressed: () {
                        setState(() {
                          hidePassword =
                              !hidePassword;
                        });
                      },
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                        return strings.requiredPassword;
                    }

                    if (value.length < 6) {
                        return strings.passwordTooShort;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // =================================================
                // CONFIRMATION
                // =================================================

                TextFormField(
                  controller:
                      confirmPasswordController,

                  obscureText:
                      hideConfirmPassword,

                  style:
                      const TextStyle(
                    color: Colors.white,
                  ),

                  decoration:
                      _inputDecoration(
                    label: strings.confirmPassword,

                    icon:
                        Icons.lock_outline,

                    suffix:
                        IconButton(
                      icon: Icon(
                        hideConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color:
                            Colors.grey,
                      ),

                      onPressed: () {
                        setState(() {
                          hideConfirmPassword =
                              !hideConfirmPassword;
                        });
                      },
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                        return strings.confirmPasswordRequired;
                    }

                    if (value !=
                        passwordController
                            .text) {
                        return strings.passwordMismatch;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // =================================================
                // CRÉER LE COMPTE
                // =================================================

                SizedBox(
                  width:
                      double.infinity,

                  height: 55,

                  child:
                      ElevatedButton(
                    onPressed:
                        loading
                            ? null
                            : _register,

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

                    child: loading
                        ? const SizedBox(
                            width: 25,
                            height: 25,

                            child:
                                CircularProgressIndicator(
                              color:
                                  Colors.white,
                              strokeWidth:
                                  2,
                            ),
                          )

                        : Text(
                          strings.signUp,
                          style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // RETOUR CONNEXION
                // =================================================

                TextButton(
                  onPressed:
                      loading
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                              );
                            },

                  child:
                      Text(
                    strings.signIn,

                    style:
                        TextStyle(
                      color:
                          Colors.blue,
                      fontSize:
                          16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DÉCORATION DES CHAMPS
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffix,
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

      prefixIcon:
          Icon(
        icon,
        color: Colors.blue,
      ),

      suffixIcon:
          suffix,

      filled: true,

      fillColor:
          const Color(0xff1d1d1d),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          15,
        ),
        borderSide:
            BorderSide.none,
      ),

      enabledBorder:
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
    );
  }
}