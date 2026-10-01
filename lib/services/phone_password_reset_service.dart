import 'package:cloud_functions/cloud_functions.dart';

import '../utils/phone_number_utils.dart';

class PhonePasswordResetService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  Future<void> requestCode(String phoneNumber) async {
    final phone = PhoneNumberUtils.normalize(phoneNumber);
    if (!PhoneNumberUtils.isValid(phone)) {
      throw const FormatException('invalidPhoneNumber');
    }

    final result = await _functions
        .httpsCallable('requestPasswordReset')
      .call({'identifier': phoneNumber.trim()});
    if (result.data is! Map || result.data['success'] != true) {
      throw FirebaseFunctionsException(
        code: 'internal',
        message: 'otpSendFailed',
      );
    }
  }

  Future<String> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    final phone = PhoneNumberUtils.normalize(phoneNumber);
    if (!PhoneNumberUtils.isValid(phone)) {
      throw const FormatException('invalidPhoneNumber');
    }
    final result = await _functions
        .httpsCallable('verifyPasswordResetCode')
        .call({'identifier': phoneNumber.trim(), 'code': code.trim()});
    final data = result.data;
    final token = data is Map ? data['resetToken']?.toString() : null;
    if (token == null || token.isEmpty) {
      throw FirebaseFunctionsException(
        code: 'failed-precondition',
        message: 'otpVerificationFailed',
      );
    }
    return token;
  }

  Future<void> resetPassword({
    required String phoneNumber,
    required String resetToken,
    required String newPassword,
  }) async {
    final phone = PhoneNumberUtils.normalize(phoneNumber);
    if (!PhoneNumberUtils.isValid(phone)) {
      throw const FormatException('invalidPhoneNumber');
    }
    await _functions.httpsCallable('resetPasswordByPhone').call({
      'identifier': phoneNumber.trim(),
      'resetToken': resetToken,
      'newPassword': newPassword,
    });
  }
}
