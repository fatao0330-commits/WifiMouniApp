import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../home/home_page.dart';
import 'email_verification_page.dart';
import 'otp_page.dart';

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

    try {
      final email =
          emailController.text.trim().toLowerCase();

      final phone =
          telephoneController.text.trim();

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
          result,
          error: true,
        );

        return;
      }

      // --------------------------------------------------------
      // 2. VÉRIFICATION DU NUMÉRO OBLIGATOIRE
      // --------------------------------------------------------

      if (phone.isEmpty) {
        setState(() {
          loading = false;
        });

        _showMessage(
          'Numéro de téléphone obligatoire.',
          error: true,
        );

        return;
      }

      // --------------------------------------------------------
      // 3. ENVOYER LE CODE OTP
      // --------------------------------------------------------

      await _sendOtp(phone);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        e.message ??
            'Impossible de créer le compte.',
        error: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Une erreur est survenue.',
        error: true,
      );
    }
  }

  // ============================================================
  // OTP TÉLÉPHONE
  // ============================================================

  Future<void> _sendOtp(
    String phoneNumber,
  ) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        // ------------------------------------------------------
        // VÉRIFICATION AUTOMATIQUE
        // ------------------------------------------------------

        verificationCompleted:
            (PhoneAuthCredential credential) async {
          final user = _auth.currentUser;

          if (user == null) {
            if (!mounted) return;

            setState(() {
              loading = false;
            });

            _showMessage(
              'Session utilisateur introuvable.',
              error: true,
            );

            return;
          }

          try {
            await user.linkWithCredential(
              credential,
            );

            await user.reload();

            if (!mounted) return;

            setState(() {
              loading = false;
            });

            _showMessage(
              'Numéro vérifié automatiquement.',
            );

            await _openEmailVerification();
          } on FirebaseAuthException catch (e) {
            if (!mounted) return;

            setState(() {
              loading = false;
            });

            _showMessage(
              e.message ??
                  'Impossible de vérifier le numéro.',
              error: true,
            );
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
            e.message ??
                'Impossible d’envoyer le code OTP.',
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
          if (!mounted) return;

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

          if (!mounted) return;

          if (verified == true) {
            _showMessage(
              'Numéro vérifié avec succès.',
            );

            // --------------------------------------------------
            // APRÈS OTP → VÉRIFICATION EMAIL
            // --------------------------------------------------

            await _openEmailVerification();
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
        'Impossible d’envoyer le code OTP.',
        error: true,
      );
    }
  }

  // ============================================================
  // VÉRIFICATION EMAIL
  // ============================================================

  Future<void> _openEmailVerification() async {
    if (!mounted) return;

    final emailVerified =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const EmailVerificationPage(),
      ),
    );

    if (!mounted) return;

    // ----------------------------------------------------------
    // L'EMAIL EST VALIDÉ
    // ----------------------------------------------------------

    if (emailVerified == true) {
      await _finishRegistration();
    }
  }

  // ============================================================
  // FIN DE L'INSCRIPTION
  // ============================================================

  Future<void> _finishRegistration() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final user = _auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        _showMessage(
          'Session utilisateur introuvable.',
          error: true,
        );

        return;
      }

      // Actualiser les informations Firebase.
      await user.reload();

      final refreshedUser =
          _auth.currentUser;

      if (refreshedUser == null) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        _showMessage(
          'Impossible de récupérer votre compte.',
          error: true,
        );

        return;
      }

      // --------------------------------------------------------
      // VÉRIFICATION FINALE EMAIL
      // --------------------------------------------------------

      if (!refreshedUser.emailVerified) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        _showMessage(
          'Votre adresse e-mail n’est pas encore vérifiée.',
          error: true,
        );

        return;
      }

      // --------------------------------------------------------
      // TOUT EST OK
      // → HOME PAGE
      // --------------------------------------------------------

      if (!mounted) return;

      setState(() {
        loading = false;
      });

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
        'Impossible de terminer l’inscription.',
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
      backgroundColor:
          const Color(0xff101010),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,

        title: const Text(
          'Créer un compte',
        ),

        centerTitle: true,
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
                    label:
                        'Nom complet',
                    icon:
                        Icons.person,
                  ),

                  validator: (value) {
                    final name =
                        value?.trim() ?? '';

                    if (name.isEmpty) {
                      return
                          'Entrez votre nom.';
                    }

                    if (name.length < 2) {
                      return
                          'Nom trop court.';
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
                      return
                          'Entrez votre adresse e-mail.';
                    }

                    final regex = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    );

                    if (!regex.hasMatch(
                        email)) {
                      return
                          'Adresse e-mail invalide.';
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
                    label:
                        'Numéro de téléphone',
                    icon:
                        Icons.phone,
                    hint:
                        '+2250700000000',
                  ),

                  validator: (value) {
                    final phone =
                        value?.trim() ?? '';

                    if (phone.isEmpty) {
                      return
                          'Entrez votre numéro.';
                    }

                    if (!phone.startsWith('+')) {
                      return
                          'Utilisez le format international : +225...';
                    }

                    final digits =
                        phone.substring(1);

                    if (!RegExp(r'^\d+$')
                        .hasMatch(digits)) {
                      return
                          'Le numéro contient des caractères invalides.';
                    }

                    if (digits.length < 8 ||
                        digits.length > 15) {
                      return
                          'Numéro de téléphone invalide.';
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
                    label:
                        'Mot de passe',
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
                      return
                          'Entrez un mot de passe.';
                    }

                    if (value.length < 6) {
                      return
                          'Minimum 6 caractères.';
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
                    label:
                        'Confirmer le mot de passe',

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
                      return
                          'Confirmez le mot de passe.';
                    }

                    if (value !=
                        passwordController
                            .text) {
                      return
                          'Les mots de passe ne correspondent pas.';
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

                        : const Text(
                            'Créer un compte',

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
                      const Text(
                    'J’ai déjà un compte',

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