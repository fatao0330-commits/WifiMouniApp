import 'package:flutter/material.dart';

import '../../services/password_reset_service.dart';

class ForgotPinPage extends StatefulWidget {
  const ForgotPinPage({super.key});

  @override
  State<ForgotPinPage> createState() =>
      _ForgotPinPageState();
}

class _ForgotPinPageState
    extends State<ForgotPinPage> {
  final TextEditingController _emailController =
      TextEditingController();

  final PasswordResetService _resetService =
      PasswordResetService();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email =
        _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        "Entrez votre adresse e-mail.",
        error: true,
      );
      return;
    }

    if (!email.contains("@")) {
      _showMessage(
        "Adresse e-mail invalide.",
        error: true,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    final result =
        await _resetService.sendResetEmail(
      email,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    if (result != null) {
      _showMessage(
        result,
        error: true,
      );
      return;
    }

    await _showEmailSentDialog();
  }

  Future<void> _showEmailSentDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.mark_email_read,
            color: Colors.blue,
            size: 50,
          ),

          title: const Text(
            "E-mail envoyé",
            textAlign: TextAlign.center,
          ),

          content: const Text(
            "Un e-mail de réinitialisation "
            "du mot de passe vient de vous être envoyé.\n\n"
            "Ouvrez votre Gmail et appuyez sur "
            "le lien de réinitialisation.\n\n"
            "WiFi Mouni ouvrira ensuite la page "
            "pour créer votre nouveau mot de passe.",
            textAlign: TextAlign.center,
          ),

          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "J'ai compris",
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
          "Mot de passe oublié",
        ),

        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 40),

              const Icon(
                Icons.lock_reset,
                size: 90,
                color: Colors.blue,
              ),

              const SizedBox(height: 25),

              const Text(
                "Réinitialisation du mot de passe",
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Entrez l'adresse e-mail liée "
                "à votre compte WiFi Mouni.",
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 35),

              TextField(
                controller:
                    _emailController,

                keyboardType:
                    TextInputType.emailAddress,

                style:
                    const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    InputDecoration(
                  labelText:
                      "Adresse e-mail",

                  labelStyle:
                      const TextStyle(
                    color: Colors.grey,
                  ),

                  prefixIcon:
                      const Icon(
                    Icons.email_outlined,
                    color: Colors.blue,
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

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(15),
                    borderSide:
                        const BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      _loading
                          ? null
                          : _sendResetEmail,

                  icon: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            color:
                                Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.email_outlined,
                        ),

                  label: Text(
                    _loading
                        ? "Envoi..."
                        : "Envoyer l'e-mail",
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue,

                    foregroundColor:
                        Colors.white,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Card(
                child: Padding(
                  padding:
                      EdgeInsets.all(16),

                  child: Column(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.blue,
                        size: 35,
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Pour votre sécurité, "
                        "le mot de passe actuel "
                        "n'est jamais envoyé par e-mail.",
                        textAlign:
                            TextAlign.center,
                      ),

                      SizedBox(height: 8),

                      Text(
                        "Vous recevrez uniquement "
                        "un lien sécurisé permettant "
                        "de créer un nouveau mot de passe.",
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
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