import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../l10n/app_localizations.dart';

import '../../services/biometric_service.dart';
import '../../services/pin_service.dart';
import '../../services/settings_service.dart';

import '../about/about_page.dart';
import '../auth/login_page.dart';
import '../conditions/conditions_page.dart';
import '../privacy/privacy_page.dart';
import '../support/support_page.dart';

import '../settings/change_pin_page.dart';
import '../security/create_pin_page.dart';
import '../security/forgot_pin_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PinService _pinService = PinService();
  final SettingsService _settingsService = SettingsService();
  final BiometricService _biometricService = BiometricService();

  bool _loading = true;

  bool _hasPin = false;
  bool _fingerprintEnabled = false;
  bool _faceIdEnabled = false;

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  String _language = 'fr';

  // ==========================================================
  // TRADUCTIONS
  // ==========================================================

  AppLocalizations get l10n {
    return AppLocalizations.of(context)!;
  }

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ==========================================================
  // CHARGER LES PARAMÈTRES
  // ==========================================================

  Future<void> _loadSettings() async {
    try {
      final security =
          await _pinService.getSecuritySettings();

      final settings =
          await _settingsService.getSettings();

      final hasPin =
          await _pinService.hasPin();

      if (!mounted) return;

      setState(() {
        _hasPin = hasPin;

        _fingerprintEnabled =
            security['fingerprintEnabled'] == true;

        _faceIdEnabled =
            security['faceIdEnabled'] == true;

        _notificationsEnabled =
            settings.notificationsEnabled;

        _darkModeEnabled =
            settings.darkModeEnabled;

        _language =
            settings.language == 'en' ? 'en' : 'fr';

        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'Erreur chargement paramètres : $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ==========================================================
  // CRÉER OU MODIFIER LE PIN
  // ==========================================================

  Future<void> _createOrChangePin() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (_hasPin) {
            return const ChangePinPage();
          }

          return const CreatePinPage();
        },
      ),
    );

    if (result == true) {
      await _loadSettings();
    }
  }

  // ==========================================================
  // PIN OUBLIÉ
  // ==========================================================

  Future<void> _forgotPin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ForgotPinPage(),
      ),
    );
  }

  // ==========================================================
  // EMPREINTE DIGITALE
  // ==========================================================

  Future<void> _changeFingerprint(bool value) async {
    try {
      if (value) {
        final canUse =
            await _biometricService.canUseFingerprint();

        if (!canUse) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _language == 'fr'
                    ? 'Empreinte digitale indisponible.'
                    : 'Fingerprint authentication unavailable.',
              ),
            ),
          );

          return;
        }
      }

      await _pinService.setFingerprintEnabled(value);

      if (!mounted) return;

      setState(() {
        _fingerprintEnabled = value;
      });
    } catch (e) {
      debugPrint(
        'Erreur empreinte digitale : $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _language == 'fr'
                ? 'Impossible de modifier le réglage de l’empreinte.'
                : 'Unable to change fingerprint setting.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // RECONNAISSANCE FACIALE
  // ==========================================================

  Future<void> _changeFaceId(bool value) async {
    try {
      if (value) {
        final canUse =
            await _biometricService.canUseFaceId();

        if (!canUse) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _language == 'fr'
                    ? 'Reconnaissance faciale indisponible.'
                    : 'Face recognition unavailable.',
              ),
            ),
          );

          return;
        }
      }

      await _pinService.setFaceIdEnabled(value);

      if (!mounted) return;

      setState(() {
        _faceIdEnabled = value;
      });
    } catch (e) {
      debugPrint(
        'Erreur reconnaissance faciale : $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _language == 'fr'
                ? 'Impossible de modifier la reconnaissance faciale.'
                : 'Unable to change face recognition setting.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // CHOISIR LA LANGUE
  // ==========================================================

  Future<void> _selectLanguage() async {
    final selectedLanguage =
        await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l10n.language,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.language,
                ),
                title: Text(
                  l10n.french,
                ),
                trailing: _language == 'fr'
                    ? const Icon(
                        Icons.check,
                        color: Colors.blue,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(
                    sheetContext,
                    'fr',
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.language,
                ),
                title: Text(
                  l10n.english,
                ),
                trailing: _language == 'en'
                    ? const Icon(
                        Icons.check,
                        color: Colors.blue,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(
                    sheetContext,
                    'en',
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (selectedLanguage == null) {
      return;
    }

    if (selectedLanguage == _language) {
      return;
    }

    try {
      await appSettings.setLanguage(
        selectedLanguage,
      );

      if (!mounted) return;

      setState(() {
        _language = selectedLanguage;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedLanguage == 'fr'
                ? 'Langue française sélectionnée.'
                : 'English language selected.',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Erreur changement langue : $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedLanguage == 'fr'
                ? 'Impossible de changer la langue.'
                : 'Unable to change language.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // NOTIFICATIONS
  // ==========================================================

  Future<void> _changeNotifications(bool value) async {
    try {
      await appSettings.setNotifications(
        value,
      );

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = value;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? l10n.notificationsEnabled
                : l10n.notificationsDisabled,
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Erreur notifications : $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _language == 'fr'
                ? 'Impossible de modifier les notifications.'
                : 'Unable to change notifications.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // MODE SOMBRE GLOBAL
  // ==========================================================

  Future<void> _changeDarkMode(bool value) async {
    try {
      await appSettings.setDarkMode(
        value,
      );

      if (!mounted) return;

      setState(() {
        _darkModeEnabled = value;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? l10n.darkModeEnabled
                : l10n.darkModeDisabled,
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Erreur mode sombre : $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _language == 'fr'
                ? 'Impossible de modifier le mode sombre.'
                : 'Unable to change dark mode.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // DÉCONNEXION
  // ==========================================================

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
        (_) => false,
      );
    } catch (e) {
      debugPrint(
        'Erreur déconnexion : $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _language == 'fr'
                ? 'Impossible de se déconnecter.'
                : 'Unable to log out.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // OUVRIR UNE PAGE
  // ==========================================================

  void _openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====================================================
          // SÉCURITÉ
          // ====================================================

          Text(
            l10n.security,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                // ==================================================
                // CRÉER / MODIFIER PIN
                // ==================================================

                ListTile(
                  leading: Icon(
                    _hasPin
                        ? Icons.lock_reset
                        : Icons.add_moderator,
                  ),

                  title: Text(
                    _hasPin
                        ? l10n.changePin
                        : l10n.createPin,
                  ),

                  subtitle: Text(
                    _hasPin
                        ? (_language == 'fr'
                            ? 'Un code PIN est configuré.'
                            : 'A PIN is configured.')
                        : (_language == 'fr'
                            ? 'Aucun code PIN n’est configuré.'
                            : 'No PIN is configured.'),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                  onTap: _createOrChangePin,
                ),

                // ==================================================
                // PIN OUBLIÉ
                // ==================================================

                if (_hasPin) ...[
                  const Divider(
                    height: 1,
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.lock_reset,
                    ),

                    title: Text(
                      _language == 'fr'
                          ? 'PIN oublié ?'
                          : 'Forgot PIN?',
                    ),

                    subtitle: Text(
                      _language == 'fr'
                          ? 'Réinitialiser votre code PIN par SMS.'
                          : 'Reset your PIN by SMS.',
                    ),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),

                    onTap: _forgotPin,
                  ),
                ],

                // ==================================================
                // EMPREINTE
                // ==================================================

                const Divider(
                  height: 1,
                ),

                SwitchListTile(
                  secondary: const Icon(
                    Icons.fingerprint,
                  ),

                  title: Text(
                    l10n.fingerprint,
                  ),

                  value: _fingerprintEnabled,

                  onChanged: _changeFingerprint,
                ),

                // ==================================================
                // FACE ID
                // ==================================================

                const Divider(
                  height: 1,
                ),

                SwitchListTile(
                  secondary: const Icon(
                    Icons.face,
                  ),

                  title: Text(
                    l10n.faceRecognition,
                  ),

                  value: _faceIdEnabled,

                  onChanged: _changeFaceId,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ====================================================
          // PRÉFÉRENCES
          // ====================================================

          Text(
            l10n.preferences,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                // ==================================================
                // LANGUE
                // ==================================================

                ListTile(
                  leading: const Icon(
                    Icons.language,
                  ),

                  title: Text(
                    l10n.language,
                  ),

                  subtitle: Text(
                    _language == 'fr'
                        ? l10n.french
                        : l10n.english,
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                  onTap: _selectLanguage,
                ),

                const Divider(
                  height: 1,
                ),

                // ==================================================
                // NOTIFICATIONS
                // ==================================================

                SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications,
                  ),

                  title: Text(
                    l10n.notifications,
                  ),

                  value: _notificationsEnabled,

                  onChanged: _changeNotifications,
                ),

                const Divider(
                  height: 1,
                ),

                // ==================================================
                // MODE SOMBRE
                // ==================================================

                SwitchListTile(
                  secondary: const Icon(
                    Icons.dark_mode,
                  ),

                  title: Text(
                    l10n.darkMode,
                  ),

                  value: _darkModeEnabled,

                  onChanged: _changeDarkMode,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ====================================================
          // COMPTE
          // ====================================================

          Text(
            l10n.account,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                // ==================================================
                // CONFIDENTIALITÉ
                // ==================================================

                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                  ),

                  title: Text(
                    l10n.privacyPolicy,
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                  onTap: () {
                    _openPage(
                      const PrivacyPage(),
                    );
                  },
                ),

                const Divider(
                  height: 1,
                ),

                // ==================================================
                // CONDITIONS
                // ==================================================

                ListTile(
                  leading: const Icon(
                    Icons.description_outlined,
                  ),

                  title: Text(
                    l10n.terms,
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                  onTap: () {
                    _openPage(
                      const ConditionsPage(),
                    );
                  },
                ),

                const Divider(
                  height: 1,
                ),

                // ==================================================
                // SUPPORT
                // ==================================================

                ListTile(
                  leading: const Icon(
                    Icons.support_agent,
                  ),

                  title: Text(
                    l10n.support,
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                  onTap: () {
                    _openPage(
                      const SupportPage(),
                    );
                  },
                ),

                const Divider(
                  height: 1,
                ),

                // ==================================================
                // À PROPOS
                // ==================================================

                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                  ),

                  title: Text(
                    l10n.about,
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                  onTap: () {
                    _openPage(
                      const AboutPage(),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ====================================================
          // DÉCONNEXION
          // ====================================================

          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: _logout,

              icon: const Icon(
                Icons.logout,
              ),

              label: Text(
                l10n.logout,
              ),

              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}