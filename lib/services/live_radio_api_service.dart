import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/live_program.dart';
import '../repo/api_state.dart';

class LiveRadioApiService {
  static const String _baseUrl = 'https://api.chethanafm.com';
  static const String _liveEndpoint = '/api/live/';

  Future<NetworkResult<LiveProgram>> getLiveProgram() async {
    try {
      final url = Uri.parse('$_baseUrl$_liveEndpoint');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      final int statusCode = response.statusCode;
      final String body = response.body;

      if (statusCode >= 200 && statusCode < 300) {
        if (body.contains("No live program") || body.contains("detail")) {
          String errorMsg = 'No live program found.';
          try {
            final Map<String, dynamic> jsonResponse = jsonDecode(body);
            if (jsonResponse.containsKey('detail')) {
              errorMsg = jsonResponse['detail'] as String;
            } else if (jsonResponse.containsKey('message')) {
              errorMsg = jsonResponse['message'] as String;
            }
          } catch (_) {}
          return NetworkResult.error(errorMsg, statusCode: statusCode);
        }
        final Map<String, dynamic> jsonResponse = jsonDecode(body);
        final liveProgram = LiveProgram.fromJson(jsonResponse);
        return NetworkResult.success(liveProgram, statusCode: statusCode);
      } else if (statusCode == 404) {
        String errorMsg = 'No live program found.';
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(body);
          if (jsonResponse.containsKey('detail')) {
            errorMsg = jsonResponse['detail'] as String;
          }
        } catch (_) {}
        return NetworkResult.error(errorMsg, statusCode: statusCode);
      } else if (statusCode == 500) {
        return NetworkResult.error('We are experiencing server issues. Please try again later.', statusCode: statusCode);
      } else {
        return NetworkResult.error('We couldn\'t load the show details. Please check back soon!', statusCode: statusCode);
      }
    } on TimeoutException {
      return NetworkResult.error('Connection timed out. Please check your internet connection.');
    } on SocketException {
      return NetworkResult.error('No internet connection. Please connect to Wi-Fi or mobile data.');
    } catch (e) {
      return NetworkResult.error('Could not read show details. Please try again.');
    }
  }
}
