import 'package:flutter/material.dart';

import '../../services/password_reset_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String oobCode;

  const ResetPasswordPage({
    super.key,
    required this.oobCode,
  });

  @override
  State<ResetPasswordPage> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState
    extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmController =
      TextEditingController();

  final PasswordResetService _resetService =
      PasswordResetService();

  bool _loading = true;
  bool _saving = false;

  bool _hidePassword = true;
  bool _hideConfirm = true;

  String? _email;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verifyResetCode();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ============================================================
  // VÉRIFIER LE LIEN FIREBASE
  // ============================================================

  Future<void> _verifyResetCode() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _resetService.verifyResetCode(
        widget.oobCode,
      );

      if (!mounted) return;

      if (result == null ||
          !result.contains("@")) {
        setState(() {
          _loading = false;
          _errorMessage =
              result ??
              "Le lien de réinitialisation est invalide ou a expiré.";
        });

        return;
      }

      setState(() {
        _loading = false;
        _email = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage =
            "Impossible de vérifier le lien de réinitialisation.";
      });
    }
  }

  // ============================================================
  // ENREGISTRER LE NOUVEAU MOT DE PASSE
  // ============================================================

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final password =
        _passwordController.text.trim();

    final confirm =
        _confirmController.text.trim();

    if (password != confirm) {
      _showMessage(
        "Les mots de passe ne correspondent pas.",
        error: true,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
    });

    try {
      final result =
          await _resetService.confirmReset(
        widget.oobCode,
        password,
      );

      if (!mounted) return;

      if (result != null) {
        setState(() {
          _saving = false;
        });

        _showMessage(
          result,
          error: true,
        );

        return;
      }

      setState(() {
        _saving = false;
      });

      await _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        "Impossible de modifier le mot de passe.",
        error: true,
      );
    }
  }

  // ============================================================
  // MESSAGE DE SUCCÈS
  // ============================================================

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 60,
          ),

          title: const Text(
            "Mot de passe modifié",
            textAlign: TextAlign.center,
          ),

          content: const Text(
            "Votre nouveau mot de passe a été "
            "enregistré avec succès.\n\n"
            "Vous pouvez maintenant vous connecter "
            "à votre compte WiFi Mouni avec ce nouveau "
            "mot de passe.",
            textAlign: TextAlign.center,
          ),

          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  "Se connecter",
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    // Retour vers la première page
    // normalement LoginPage.
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  // ============================================================
  // AFFICHER UN MESSAGE
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
          "Nouveau mot de passe",
        ),

        centerTitle: true,
      ),

      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // ----------------------------------------------------------
    // VÉRIFICATION EN COURS
    // ----------------------------------------------------------

    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              "Vérification du lien...",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // ----------------------------------------------------------
    // ERREUR
    // ----------------------------------------------------------

    if (_errorMessage != null ||
        _email == null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(25),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 80,
              ),

              const SizedBox(height: 20),

              const Text(
                "Lien invalide",
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                _errorMessage ??
                    "Le lien de réinitialisation est invalide ou a expiré.",
                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil(
                      (route) =>
                          route.isFirst,
                    );
                  },

                  child: const Text(
                    "Retour à la connexion",
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // FORMULAIRE
    // ----------------------------------------------------------

    return Form(
      key: _formKey,

      child: ListView(
        padding:
            const EdgeInsets.all(20),

        children: [
          const SizedBox(height: 25),

          const Icon(
            Icons.lock_reset,
            size: 90,
            color: Colors.blue,
          ),

          const SizedBox(height: 25),

          const Text(
            "Créer un nouveau mot de passe",
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            _email!,
            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 35),

          // ------------------------------------------------------
          // NOUVEAU MOT DE PASSE
          // ------------------------------------------------------

          TextFormField(
            controller:
                _passwordController,

            obscureText:
                _hidePassword,

            enabled: !_saving,

            style: const TextStyle(
              color: Colors.white,
            ),

            decoration:
                _inputDecoration(
              label:
                  "Nouveau mot de passe",
              icon: Icons.lock,
              suffix: IconButton(
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),

                onPressed: () {
                  setState(() {
                    _hidePassword =
                        !_hidePassword;
                  });
                },
              ),
            ),

            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return
                    "Entrez un nouveau mot de passe.";
              }

              if (value.length < 6) {
                return
                    "Minimum 6 caractères.";
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------------
          // CONFIRMATION
          // ------------------------------------------------------

          TextFormField(
            controller:
                _confirmController,

            obscureText:
                _hideConfirm,

            enabled: !_saving,

            style: const TextStyle(
              color: Colors.white,
            ),

            decoration:
                _inputDecoration(
              label:
                  "Confirmer le mot de passe",
              icon:
                  Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _hideConfirm
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),

                onPressed: () {
                  setState(() {
                    _hideConfirm =
                        !_hideConfirm;
                  });
                },
              ),
            ),

            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return
                    "Confirmez le mot de passe.";
              }

              if (value !=
                  _passwordController.text) {
                return
                    "Les mots de passe ne correspondent pas.";
              }

              return null;
            },
          ),

          const SizedBox(height: 30),

          // ------------------------------------------------------
          // BOUTON
          // ------------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 55,

            child: ElevatedButton(
              onPressed:
                  _saving
                      ? null
                      : _changePassword,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue,

                foregroundColor:
                    Colors.white,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),

              child: _saving
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
                      "Enregistrer le nouveau mot de passe",
                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 25),

          const Card(
            child: Padding(
              padding:
                  EdgeInsets.all(16),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.security,
                    color: Colors.blue,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "Le lien de réinitialisation est "
                      "sécurisé par Firebase Authentication. "
                      "Votre ancien mot de passe n'est "
                      "jamais affiché.",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STYLE DES CHAMPS
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,

      labelStyle:
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

      enabledBorder:
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

      focusedErrorBorder:
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
}