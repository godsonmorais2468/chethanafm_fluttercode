import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../repo/api_state.dart';

class AuthApiService {
  static const String _baseUrl = 'https://api.chethanafm.com';
  static const String _loginEndpoint = '/api/auth/login/';
  static const String _registerEndpoint = '/api/auth/register/';
  static const String _checkPhoneEndpoint = '/api/auth/check-phone/';
  static const String _resetPasswordEndpoint = '/api/auth/reset-password/';
  static const String _securityQuestionsEndpoint = '/api/auth/security-questions/';
  static const String _getSecurityQuestionEndpoint = '/api/auth/get-security-question/';
  static const String _verifyAnswerEndpoint = '/api/auth/verify-answer/';
  static const String _countryCodesEndpoint = '/api/auth/country-codes/';
  static const String _profileEndpoint = '/api/auth/profile/';

  String _formatErrors(String body, String defaultMsg) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final List<String> errorLines = [];
        decoded.forEach((key, value) {
          final cleanKey = key.replaceAll('_', ' ');
          final capitalizedKey = cleanKey.isEmpty
              ? ''
              : cleanKey[0].toUpperCase() + cleanKey.substring(1);
          if (value is List) {
            errorLines.add('$capitalizedKey: ${value.join(', ')}');
          } else if (value is String) {
            errorLines.add('$capitalizedKey: $value');
          }
        });
        if (errorLines.isNotEmpty) {
          return errorLines.join('\n');
        }
        return decoded['message'] ?? decoded['error'] ?? defaultMsg;
      }
    } catch (_) {}
    return defaultMsg;
  }

  Future<NetworkResult<List<CountryCode>>> getCountryCodes() async {
    try {
      final url = Uri.parse('$_baseUrl$_countryCodesEndpoint');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      final int statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        final List<CountryCode> codes = jsonResponse
            .map((c) => CountryCode.fromJson(c as Map<String, dynamic>))
            .toList();
        return NetworkResult.success(codes, statusCode: statusCode);
      } else {
        final errorMsg = _formatErrors(response.body, 'Failed to load country codes');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      }
    } on TimeoutException {
      return NetworkResult.error('Request Timed Out');
    } on SocketException {
      return NetworkResult.error('No Internet Connection');
    } catch (e) {
      return NetworkResult.error('Unexpected Error');
    }
  }

  Future<NetworkResult<User>> getProfile(String token) async {
    try {
      final url = Uri.parse('$_baseUrl$_profileEndpoint');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
      ).timeout(const Duration(seconds: 15));

      final int statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final profileResponse = ProfileResponse.fromJson(jsonResponse);
        return NetworkResult.success(profileResponse.user, statusCode: statusCode);
      } else {
        final errorMsg = _formatErrors(response.body, 'Failed to load profile');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      }
    } on TimeoutException {
      return NetworkResult.error('Request Timed Out');
    } on SocketException {
      return NetworkResult.error('No Internet Connection');
    } catch (e) {
      return NetworkResult.error('Unexpected Error');
    }
  }

  Future<NetworkResult<LoginResponse>> login(String countryCode, String phoneNumber, String password) async {
    try {
      final url = Uri.parse('$_baseUrl$_loginEndpoint');
      final body = jsonEncode({
        'country_code': countryCode,
        'phone_number': phoneNumber,
        'password': password,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      final int statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonResponse);
        return NetworkResult.success(loginResponse, statusCode: statusCode);
      } else if (statusCode == 400) {
        final errorMsg = _formatErrors(response.body, 'Validation Error');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      } else if (statusCode == 401) {
        return NetworkResult.error('Invalid phone number or password', statusCode: statusCode);
      } else if (statusCode == 500) {
        return NetworkResult.error('Something went wrong. Please try again.', statusCode: statusCode);
      } else {
        final errorMsg = _formatErrors(response.body, 'Unexpected error occurred');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      }
    } on TimeoutException {
      return NetworkResult.error('Request Timed Out');
    } on SocketException {
      return NetworkResult.error('No Internet Connection');
    } catch (e) {
      return NetworkResult.error('Unexpected Error');
    }
  }

  Future<NetworkResult<RegisterResponse>> register(
      String countryCode, String phoneNumber, String password, String confirmPassword, String name, String securityQuestion, String securityAnswer) async {
    try {
      final url = Uri.parse('$_baseUrl$_registerEndpoint');
      final body = jsonEncode({
        'country_code': countryCode,
        'phone_number': phoneNumber,
        'password': password,
        'confirm_password': confirmPassword,
        'name': name,
        'security_question': securityQuestion,
        'security_answer': securityAnswer,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      final int statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final registerResponse = RegisterResponse.fromJson(jsonResponse);
        return NetworkResult.success(registerResponse, statusCode: statusCode);
      } else if (statusCode == 400) {
        final errorMsg = _formatErrors(response.body, 'Validation Error');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      } else if (statusCode == 401) {
        return NetworkResult.error('Unauthorized', statusCode: statusCode);
      } else if (statusCode == 500) {
        return NetworkResult.error('Something went wrong. Please try again.', statusCode: statusCode);
      } else {
        final errorMsg = _formatErrors(response.body, 'Unexpected error occurred');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      }
    } on TimeoutException {
      return NetworkResult.error('Request Timed Out');
    } on SocketException {
      return NetworkResult.error('No Internet Connection');
    } catch (e) {
      return NetworkResult.error('Unexpected Error');
    }
  }

  Future<NetworkResult<String>> checkPhone(String phoneNumber) async {
    try {
      final url = Uri.parse('$_baseUrl$_checkPhoneEndpoint');
      final body = jsonEncode({
        'phone_number': phoneNumber,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      final int statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        return NetworkResult.success(response.body, statusCode: statusCode);
      } else if (statusCode == 400) {
        final errorMsg = _formatErrors(response.body, 'Validation Error');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      } else if (statusCode == 404) {
        final errorMsg = _formatErrors(response.body, 'Phone number not found');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      } else if (statusCode == 500) {
        return NetworkResult.error('Something went wrong. Please try again.', statusCode: statusCode);
      } else {
        final errorMsg = _formatErrors(response.body, 'Unexpected error occurred');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      }
    } on TimeoutException {
      return NetworkResult.error('Request Timed Out');
    } on SocketException {
      return NetworkResult.error('No Internet Connection');
    } catch (e) {
      return NetworkResult.error('Unexpected Error');
    }
  }

  Future<NetworkResult<String>> resetPassword(String countryCode, String phoneNumber, String securityAnswer, String newPassword, String confirmPassword) async {
    try {
      final url = Uri.parse('$_baseUrl$_resetPasswordEndpoint');
      final body = jsonEncode({
        'country_code': countryCode,
        'phone_number': phoneNumber,
        'security_answer': securityAnswer,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      final int statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        return NetworkResult.success(response.body, statusCode: statusCode);
      } else if (statusCode == 400) {
        final errorMsg = _formatErrors(response.body, 'Validation Error');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      } else if (statusCode == 401) {
        return NetworkResult.error('Unauthorized', statusCode: statusCode);
      } else if (statusCode == 500) {
        return NetworkResult.error('Something went wrong. Please try again.', statusCode: statusCode);
      } else {
        final errorMsg = _formatErrors(response.body, 'Unexpected error occurred');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      }
    } on TimeoutException {
      return NetworkResult.error('Request Timed Out');
    } on SocketException {
      return NetworkResult.error('No Internet Connection');
    } catch (e) {
      return NetworkResult.error('Unexpected Error');
    }
  }

  Future<NetworkResult<List<dynamic>>> getSecurityQuestions() async {
    try {
      final url = Uri.parse('$_baseUrl$_securityQuestionsEndpoint');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      final int statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return NetworkResult.success(jsonResponse, statusCode: statusCode);
      } else {
        final errorMsg = _formatErrors(response.body, 'Failed to load security questions');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      }
    } on TimeoutException {
      return NetworkResult.error('Request Timed Out');
    } on SocketException {
      return NetworkResult.error('No Internet Connection');
    } catch (e) {
      return NetworkResult.error('Unexpected Error');
    }
  }

  Future<NetworkResult<Map<String, dynamic>>> getSecurityQuestion(String countryCode, String phoneNumber) async {
    try {
      final url = Uri.parse('$_baseUrl$_getSecurityQuestionEndpoint');
      final body = jsonEncode({
        'country_code': countryCode,
        'phone_number': phoneNumber,
      });

      debugPrint("API CALL: getSecurityQuestion - POST $url");
      debugPrint("API BODY: $body");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      final int statusCode = response.statusCode;
      debugPrint("API RESPONSE STATUS: $statusCode");
      debugPrint("API RESPONSE BODY: ${response.body}");

      if (statusCode >= 200 && statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return NetworkResult.success(jsonResponse, statusCode: statusCode);
      } else {
        final errorMsg = _formatErrors(response.body, 'No security question set for this account');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      }
    } on TimeoutException {
      return NetworkResult.error('Request Timed Out');
    } on SocketException {
      return NetworkResult.error('No Internet Connection');
    } catch (e) {
      return NetworkResult.error('Unexpected Error');
    }
  }

  Future<NetworkResult<String>> verifyAnswer(String countryCode, String phoneNumber, String securityAnswer) async {
    try {
      final url = Uri.parse('$_baseUrl$_verifyAnswerEndpoint');
      final body = jsonEncode({
        'country_code': countryCode,
        'phone_number': phoneNumber,
        'security_answer': securityAnswer,
      });

      debugPrint("API CALL: verifyAnswer - POST $url");
      debugPrint("API BODY: $body");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      final int statusCode = response.statusCode;
      debugPrint("API RESPONSE STATUS: $statusCode");
      debugPrint("API RESPONSE BODY: ${response.body}");

      if (statusCode >= 200 && statusCode < 300) {
        return NetworkResult.success(response.body, statusCode: statusCode);
      } else {
        final errorMsg = _formatErrors(response.body, 'Security answer is incorrect');
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      }
    } on TimeoutException {
      return NetworkResult.error('Request Timed Out');
    } on SocketException {
      return NetworkResult.error('No Internet Connection');
    } catch (e) {
      return NetworkResult.error('Unexpected Error');
    }
  }
}
