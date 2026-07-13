import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/program_schedule.dart';
import '../repo/api_state.dart';

class ProgramScheduleApiService {
  static const String _baseUrl = 'https://api.chethanafm.com';
  static const String _scheduleEndpoint = '/api/schedule/';

  Future<NetworkResult<List<ProgramSchedule>>> getProgramSchedule() async {
    try {
      final url = Uri.parse('$_baseUrl$_scheduleEndpoint');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      final int statusCode = response.statusCode;
      final String body = response.body;

      if (statusCode >= 200 && statusCode < 300) {
        final Map<String, dynamic> jsonMap = jsonDecode(body);
        final List<dynamic> jsonList = jsonMap['results'] as List<dynamic>;
        final List<ProgramSchedule> schedules = jsonList
            .map((item) => ProgramSchedule.fromJson(item))
            .toList();
        return NetworkResult.success(schedules, statusCode: statusCode);
      } else if (statusCode == 500) {
        return NetworkResult.error(
          "We're unable to load the programme schedule right now. Please try again in a few moments.",
          statusCode: statusCode,
        );
      } else {
        return NetworkResult.error(
          "Something went wrong. Please try again later.",
          statusCode: statusCode,
        );
      }
    } on TimeoutException {
      return NetworkResult.error("The request took too long. Please try again.");
    } on SocketException {
      return NetworkResult.error(
        "No internet connection. Please check your Wi-Fi or mobile data and try again.",
      );
    } catch (e) {
      return NetworkResult.error("No programmes are currently available.");
    }
  }
}
