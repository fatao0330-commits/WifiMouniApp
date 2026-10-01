class PhoneNumberUtils {
  PhoneNumberUtils._();

  static String normalize(String input) {
    var value = input.trim().replaceAll(RegExp(r'[\s().-]'), '');
    if (value.startsWith('00')) {
      value = '+${value.substring(2)}';
    }
    return value;
  }

  static bool isValid(String input) =>
      RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(normalize(input));
}
