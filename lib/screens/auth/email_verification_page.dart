import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({
    super.key,
  });

  @override
  State<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState
    extends State<EmailVerificationPage> {
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final AuthService _authService =
      AuthService();

  bool loading = false;
  bool emailSent = false;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
  }

  // ============================================================
  // ENVOYER LE LIEN GMAIL
  // ============================================================

  Future<void> _sendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) return;

    try {
      await user.reload();

      final currentUser =
          _auth.currentUser;

      if (currentUser == null) return;

      if (!currentUser.emailVerified) {
        await currentUser
            .sendEmailVerification();
      }

      if (!mounted) return;

      setState(() {
        emailSent = true;
      });
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Impossible d’envoyer l’e-mail.',
        error: true,
      );
    }
  }

  // ============================================================
  // VÉRIFIER GMAIL
  // ============================================================

  Future<void> _checkEmail() async {
    setState(() {
      loading = true;
    });

    try {
      await _auth.currentUser?.reload();

      final user =
          _auth.currentUser;

      if (user == null) {
        throw Exception();
      }

      if (!user.emailVerified) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        _showMessage(
          'Votre adresse e-mail n’est pas encore vérifiée. Ouvrez le lien reçu dans Gmail.',
          error: true,
        );

        return;
      }

      // ========================================================
      // EMAIL + TÉLÉPHONE VALIDÉS
      // ========================================================

      await _authService
          .refreshEmailVerification();

      final authorized =
          await _authService
              .isAccountAuthorized();

      if (!authorized) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        _showMessage(
          'Votre compte n’est pas encore complètement vérifié.',
          error: true,
        );

        return;
      }

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Compte vérifié avec succès.',
      );

      // ========================================================
      // IMPORTANT :
      // On retourne au LoginPage.
      // L'utilisateur se connectera normalement.
      // ========================================================

      await Future.delayed(
        const Duration(seconds: 1),
      );

      if (!mounted) return;

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Impossible de vérifier votre adresse e-mail.',
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
    final email =
        _auth.currentUser?.email ??
            '';

    return Scaffold(
      backgroundColor:
          const Color(0xff101010),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vérification du compte',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.all(20),

          children: [
            const SizedBox(height: 50),

            const Icon(
              Icons.mark_email_read_outlined,
              size: 90,
              color: Colors.blue,
            ),

            const SizedBox(height: 30),

            const Text(
              'Vérifiez votre adresse e-mail',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Un lien de vérification a été envoyé à :\n$email',
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Ouvrez Gmail, recherchez l’e-mail de WiFi Mouni et appuyez sur le lien de vérification.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed:
                    loading
                        ? null
                        : _checkEmail,

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
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'J’ai vérifié mon e-mail',
                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 18),

            TextButton(
              onPressed:
                  loading
                      ? null
                      : _sendVerificationEmail,
              child: const Text(
                'Renvoyer l’e-mail',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}