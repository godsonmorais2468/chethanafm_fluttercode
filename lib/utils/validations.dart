// import 'package:intl/intl.dart';

import 'package:email_validator/email_validator.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
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
    return "Please enter your phone number.";
  }
  if (countryCode == null || countryCode.isEmpty) {
    return "Please select a country code.";
  }
  final cleanPhone = value.replaceAll(RegExp(r'\D'), '');
  if (cleanPhone.isEmpty) {
    return "Please enter a valid phone number.";
  }

  try {
    final fullNumber = '$countryCode$cleanPhone';
    final parsed = PhoneNumber.parse(fullNumber);
    
    if (!parsed.isValid()) {
      return "Phone number length is invalid for the selected country.";
    }
  } catch (e) {
    return "Invalid mobile number.";
  }
  
  return null;
}

int getPhoneNumberMaxLength(String? countryCode) {
  switch (countryCode) {
    case '+91': return 10;
    case '+1': return 10;
    case '+44': return 10;
    case '+61': return 9;
    case '+971': return 9;
    case '+966': return 9;
    case '+65': return 8;
    case '+60': return 10;
    case '+33': return 9;
    case '+49': return 11;
    default: return 15;
  }
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
