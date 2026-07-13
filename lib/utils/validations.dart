// import 'package:intl/intl.dart';

import 'package:email_validator/email_validator.dart';

extension TextUtilsStringExtension on String? {
  /// Returns true if string is not :
  /// - null
  /// - empty
  /// - whitespace string.
  bool get isValid => this != null && this!.trim().isNotEmpty;

  bool get isValidEmail => this != null && EmailValidator.validate(this!);

  // RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
  //     .hasMatch(this!);

  bool get isValidMobile => this != null && this!.trim().length == 10;

  bool get isValidGST => this != null && this!.trim().length == 15;
}

String? validatePhoneNumber(String? value, String? countryCode) {
  if (value == null || value.trim().isEmpty) {
    return "Please enter phone number";
  }
  if (countryCode == null || countryCode.isEmpty) {
    return "Please select a country code";
  }
  final cleanPhone = value.trim();
  switch (countryCode) {
    case "+91":
      if (cleanPhone.length != 10) {
        return "Phone number must be exactly 10 digits";
      }
      if (!RegExp(r'^[6-9]').hasMatch(cleanPhone)) {
        return "India phone number must start with 6, 7, 8, or 9";
      }
      break;
    case "+1":
      if (cleanPhone.length != 10) {
        return "Phone number must be exactly 10 digits";
      }
      break;
    case "+44":
      if (cleanPhone.length != 10) {
        return "Phone number must be exactly 10 digits";
      }
      break;
    case "+61":
      if (cleanPhone.length != 9) {
        return "Phone number must be exactly 9 digits";
      }
      break;
    case "+971":
      if (cleanPhone.length != 9) {
        return "Phone number must be exactly 9 digits";
      }
      break;
    case "+966":
      if (cleanPhone.length != 9) {
        return "Phone number must be exactly 9 digits";
      }
      break;
    case "+65":
      if (cleanPhone.length != 8) {
        return "Phone number must be exactly 8 digits";
      }
      if (!RegExp(r'^[689]').hasMatch(cleanPhone)) {
        return "Singapore phone number must start with 6, 8, or 9";
      }
      break;
    default:
      if (cleanPhone.isEmpty) {
        return "Please enter phone number";
      }
  }
  return null;
}


// final oCcy = NumberFormat.currency(locale: 'HI', symbol: '');
//
// extension TruncateDoubles on num? {
//   num? truncateToDecimalPlaces(int fractionalDigits) => this != null
//       ? (this! * pow(10, fractionalDigits)).truncate() /
//           pow(10, fractionalDigits)
//       : this;
//
//   String currencyFormat() => oCcy.format(this);
// }
