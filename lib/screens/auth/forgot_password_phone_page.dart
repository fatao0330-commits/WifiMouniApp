import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/phone_password_reset_service.dart';
import '../../utils/phone_number_utils.dart';

class ForgotPasswordPhonePage extends StatefulWidget {
  const ForgotPasswordPhonePage({super.key});

  @override
  State<ForgotPasswordPhonePage> createState() =>
      _ForgotPasswordPhonePageState();
}

enum _ResetStep { phone, code, password }

class _ForgotPasswordPhonePageState extends State<ForgotPasswordPhonePage> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _resetService = PhonePasswordResetService();

  _ResetStep _step = _ResetStep.phone;
  String? _resetToken;
  String _phoneNumber = '';
  String _phoneLookupValue = '';
  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_phoneFormKey.currentState?.validate() != true) return;
    FocusScope.of(context).unfocus();
    final phone = PhoneNumberUtils.normalize(_phoneController.text);
    setState(() => _loading = true);

    try {
      await _resetService.requestCode(_phoneController.text);
      if (!mounted) return;
      setState(() {
        _phoneNumber = phone;
        _phoneLookupValue = _phoneController.text.trim();
        _step = _ResetStep.code;
      });
      _showMessage(AppLocalizations.of(context).otpCodeSent);
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;
      _showMessage(_messageFor(error.code), error: true);
    } on FormatException {
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).invalidPhoneNumber, error: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).otpSendFailed, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_codeFormKey.currentState?.validate() != true) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final token = await _resetService.verifyCode(
        phoneNumber: _phoneLookupValue,
        code: _codeController.text,
      );
      if (!mounted) return;
      setState(() {
        _resetToken = token;
        _step = _ResetStep.password;
      });
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;
      _showMessage(_messageFor(error.code), error: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).otpVerificationFailed, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _savePassword() async {
    if (_passwordFormKey.currentState?.validate() != true) return;
    final token = _resetToken;
    if (token == null || token.isEmpty) {
      _showMessage(AppLocalizations.of(context).otpVerificationFailed, error: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await _resetService.resetPassword(
        phoneNumber: _phoneLookupValue,
        resetToken: token,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;
      _showMessage(_messageFor(error.code), error: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).passwordResetFailed, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _messageFor(String code) {
    final strings = AppLocalizations.of(context);
    switch (code) {
      case 'not-found':
        return strings.phoneNotFound;
      case 'invalid-argument':
        switch (_step) {
          case _ResetStep.phone:
            return strings.invalidPhoneNumber;
          case _ResetStep.code:
            return strings.otpVerificationFailed;
          case _ResetStep.password:
            return strings.passwordResetFailed;
        }
      case 'deadline-exceeded':
        return strings.otpExpired;
      case 'permission-denied':
      case 'failed-precondition':
        return strings.otpVerificationFailed;
      default:
        return _step == _ResetStep.password
            ? strings.passwordResetFailed
            : strings.otpSendFailed;
    }
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xff101010),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(strings.forgotPasswordPhoneTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _keyForStep,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 28),
              const Icon(Icons.lock_reset, size: 76, color: Colors.blue),
              const SizedBox(height: 22),
              Text(
                strings.resetPasswordPhone,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _step == _ResetStep.phone
                    ? strings.forgotPasswordPhoneSubtitle
                    : _step == _ResetStep.code
                        ? '${strings.enterOtpCode}\n$_phoneNumber'
                        : strings.otpCodeSent,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 30),
              if (_step == _ResetStep.phone) _buildPhoneField(strings),
              if (_step == _ResetStep.code) _buildCodeField(strings),
              if (_step == _ResetStep.password) ...[
                _buildPasswordField(strings),
                const SizedBox(height: 16),
                _buildConfirmationField(strings),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _loading ? null : _submitForStep,
                  child: _loading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_buttonLabel(strings)),
                ),
              ),
              if (_step != _ResetStep.phone) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => setState(() {
                            _step = _ResetStep.phone;
                            _resetToken = null;
                          }),
                  child: Text(strings.enterPhoneNumber),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  GlobalKey<FormState> get _keyForStep {
    switch (_step) {
      case _ResetStep.phone:
        return _phoneFormKey;
      case _ResetStep.code:
        return _codeFormKey;
      case _ResetStep.password:
        return _passwordFormKey;
    }
  }

  VoidCallback get _submitForStep {
    switch (_step) {
      case _ResetStep.phone:
        return _sendCode;
      case _ResetStep.code:
        return _verifyCode;
      case _ResetStep.password:
        return _savePassword;
    }
  }

  String _buttonLabel(AppLocalizations strings) {
    switch (_step) {
      case _ResetStep.phone:
        return strings.sendOtpCode;
      case _ResetStep.code:
        return strings.verifyCode;
      case _ResetStep.password:
        return strings.save;
    }
  }

  Widget _buildPhoneField(AppLocalizations strings) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(
        label: strings.enterPhoneNumber,
        icon: Icons.phone_outlined,
        hint: '+2250700000000',
      ),
      validator: (value) {
        final number = PhoneNumberUtils.normalize(value ?? '');
        if (number.isEmpty) return strings.phoneNumberRequired;
        if (!PhoneNumberUtils.isValid(number)) {
          return number.startsWith('+')
              ? strings.invalidPhoneNumber
              : strings.phoneInternationalFormat;
        }
        return null;
      },
    );
  }

  Widget _buildCodeField(AppLocalizations strings) {
    return TextFormField(
      controller: _codeController,
      keyboardType: TextInputType.number,
      maxLength: 4,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        letterSpacing: 8,
        fontWeight: FontWeight.bold,
      ),
      decoration: _decoration(label: strings.smsCode, icon: Icons.sms_outlined),
      validator: (value) {
        final code = value?.trim() ?? '';
        if (code.isEmpty) return strings.otpRequired;
        if (!RegExp(r'^\d{4}$').hasMatch(code)) return strings.otpInvalid;
        return null;
      },
    );
  }

  Widget _buildPasswordField(AppLocalizations strings) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _hidePassword,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(
        label: strings.newPassword,
        icon: Icons.lock_outline,
        suffix: IconButton(
          onPressed: () => setState(() => _hidePassword = !_hidePassword),
          icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return strings.requiredPassword;
        if (value.length < 6) return strings.passwordTooShort;
        return null;
      },
    );
  }

  Widget _buildConfirmationField(AppLocalizations strings) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _hideConfirmation,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(
        label: strings.confirmNewPassword,
        icon: Icons.lock_outline,
        suffix: IconButton(
          onPressed: () => setState(() => _hideConfirmation = !_hideConfirmation),
          icon: Icon(_hideConfirmation ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return strings.confirmPasswordRequired;
        if (value != _passwordController.text) return strings.passwordMismatch;
        return null;
      },
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blue),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xff1d1d1d),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
