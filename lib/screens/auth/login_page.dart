import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'register_page.dart';
import '../home/home_page.dart';
import '../../widgets/app_language_selector.dart';
import '../../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // CONNEXION
  // ==========================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      final credential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (credential.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message =
              'Aucun compte ne correspond à cette adresse email.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message =
              'Email ou mot de passe incorrect.';
          break;

        case 'invalid-email':
          message =
              'Adresse email invalide.';
          break;

        case 'user-disabled':
          message =
              'Ce compte a été désactivé.';
          break;

        case 'too-many-requests':
          message =
              'Trop de tentatives. Réessayez plus tard.';
          break;

        case 'network-request-failed':
          message =
              'Problème de connexion réseau.';
          break;

        default:
          message =
              'Impossible de se connecter. Réessayez.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Une erreur est survenue. Réessayez.',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ==========================================================
  // MOT DE PASSE OUBLIÉ
  // ==========================================================

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Entrez votre adresse email.',
          ),
        ),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Un email de réinitialisation a été envoyé.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Adresse email invalide.';
          break;

        case 'user-not-found':
          message =
              'Aucun compte trouvé avec cette adresse.';
          break;

        case 'too-many-requests':
          message =
              'Trop de demandes. Réessayez plus tard.';
          break;

        default:
          message =
              'Impossible d’envoyer le lien de réinitialisation.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Une erreur est survenue.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // INSCRIPTION
  // ==========================================================

  void _openRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login),
        centerTitle: true,
        actions: const [AppLanguageSelector()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

                const Icon(
                  Icons.wifi,
                  size: 70,
                ),

                const SizedBox(height: 20),

                Text(
                  l10n.welcome,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 35),

                // EMAIL
                TextFormField(
                  controller: _emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  textInputAction:
                      TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    hintText: 'exemple@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return l10n.requiredEmail;
                    }

                    final emailRegex = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    );

                    if (!emailRegex.hasMatch(
                      value.trim(),
                    )) {
                      return l10n.invalidEmail;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // MOT DE PASSE
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction:
                      TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!_loading) {
                      _login();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon:
                        const Icon(Icons.lock_outline),
                    border:
                        const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return l10n.requiredPassword;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // MOT DE PASSE OUBLIÉ
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                        _loading
                            ? null
                            : _forgotPassword,
                    child: Text(
                      l10n.forgotPassword,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // CONNEXION
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                          l10n.signIn,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                // INSCRIPTION
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.noAccount,
                    ),
                    TextButton(
                      onPressed:
                          _loading
                              ? null
                              : _openRegisterPage,
                      child: Text(
                        l10n.signUp,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}