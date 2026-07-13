import 'dart:convert';

import 'package:chethanafm/models/comment.dart';
import 'package:chethanafm/models/live_program.dart';
import 'package:chethanafm/models/program_schedule.dart';
import 'package:chethanafm/models/auth_models.dart';
import 'package:chethanafm/services/live_radio_api_service.dart';
import 'package:chethanafm/services/program_schedule_api_service.dart';
import 'package:chethanafm/services/auth_api_service.dart';
import 'package:chethanafm/repo/api_client.dart';
import 'package:chethanafm/repo/api_state.dart';
import 'package:chethanafm/repo/rest_client.dart';
import 'package:chethanafm/utils/debug.dart';
import 'package:chethanafm/utils/helper.dart';

import '../models/program.dart';

class Repository extends ApiClient {
  Repository();

  Repository._privateConstructor();

  static final Repository _instance = Repository._privateConstructor();
  final PrefHelper _prefHelper = PrefHelper.instance;

  static Repository get instance => _instance;
  final restClient = RestClient.instance;
  
  // HTTP API Services
  final _liveRadioApiService = LiveRadioApiService();
  final _programScheduleApiService = ProgramScheduleApiService();
  final _authApiService = AuthApiService();

  // For storing the current position

  NetworkResult handleResponse(NetworkResult networkResult) {
    if (networkResult.status == Status.success) {
      return networkResult;
    } else {
      return handleError(networkResult);
    }
  }

  NetworkResult handleError(NetworkResult networkResult) {
    try {
      return networkResult.copyWith(error: jsonDecode(networkResult.data)['message']);
    } catch (e) {
      return networkResult;
    }
  }

  // ---------------------------------------------------------
  // HTTP API Service Methods (MVVM compliant)
  // ---------------------------------------------------------

  @override
  Future<NetworkResult<List<CountryCode>>> getCountryCodes() async {
    return await _authApiService.getCountryCodes();
  }

  @override
  Future<NetworkResult<User>> getProfile(String token) async {
    return await _authApiService.getProfile(token);
  }

  @override
  Future<NetworkResult<LoginResponse>> loginWithPhone(String countryCode, String phone, String password) async {
    return await _authApiService.login(countryCode, phone, password);
  }

  @override
  Future<NetworkResult<RegisterResponse>> registerWithPhone(String countryCode, String phone, String password, String confirmPassword, String name, String securityQuestion, String securityAnswer) async {
    return await _authApiService.register(countryCode, phone, password, confirmPassword, name, securityQuestion, securityAnswer);
  }

  @override
  Future<NetworkResult<void>> checkPhone(String phone) async {
    return await _authApiService.checkPhone(phone);
  }

  @override
  Future<NetworkResult<void>> resetPassword(String countryCode, String phone, String securityAnswer, String newPassword, String confirmPassword) async {
    return await _authApiService.resetPassword(countryCode, phone, securityAnswer, newPassword, confirmPassword);
  }

  @override
  Future<NetworkResult<List<dynamic>>> getSecurityQuestions() async {
    return await _authApiService.getSecurityQuestions();
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> getSecurityQuestion(String countryCode, String phone) async {
    return await _authApiService.getSecurityQuestion(countryCode, phone);
  }

  @override
  Future<NetworkResult<String>> verifyAnswer(String countryCode, String phone, String answer) async {
    return await _authApiService.verifyAnswer(countryCode, phone, answer);
  }

  // ---------------------------------------------------------
  // Legacy RestClient Auth Methods
  // ---------------------------------------------------------
  
  @override
  Future<NetworkResult> login(String email) async {
    final result = await RestClient.instance.post(
        ApiList.login,
        {
          'email': email,
        },
        isToken: false,
        extraHeaders: {"Content-Type": "application/json"});

    if (result.status == Status.success) {
      return NetworkResult.success(result.data);
    }
    return NetworkResult.error(handleError(result).error);
  }

  @override
  Future<NetworkResult> signup(String email, String name) async {
    final result = await RestClient.instance.post(
        ApiList.signup,
        {
          'email': email,
          'name': name,
        },
        isToken: false,
        extraHeaders: {"Content-Type": "application/json"});

    if (result.status == Status.success) {
      return NetworkResult.success(result.data);
    }
    return NetworkResult.error(handleError(result).error);
  }

  @override
  Future<NetworkResult> loginOtpVerify(int userId, int otp, String deviceName) async {
    final result = await RestClient.instance.post(
        ApiList.loginOtpVerify,
        {
          'user_id': userId,
          'otp': otp,
          'device_name': deviceName,
        },
        isToken: false,
        extraHeaders: {"Content-Type": "application/json"});

    if (result.status == Status.success) {
      return NetworkResult.success(result.data);
    }
    return NetworkResult.error(handleError(result).error);
  }

  @override
  Future<NetworkResult> registerOtpVerify(int userId, int otp, String deviceName) async {
    final result = await RestClient.instance.post(
        ApiList.registerOtpVerify,
        {
          'user_id': userId,
          'otp': otp,
          'device_name': deviceName,
        },
        isToken: false,
        extraHeaders: {"Content-Type": "application/json"});

    if (result.status == Status.success) {
      return NetworkResult.success(result.data);
    }
    return NetworkResult.error(handleError(result).error);
  }

  @override
  Future<NetworkResult> resendOTP(String email) async {
    final result = await RestClient.instance.post(
        ApiList.resendotp,
        {
          'email': email,
        },
        isToken: false,
        extraHeaders: {"Content-Type": "application/json"});

    if (result.status == Status.success) {
      return NetworkResult.success(result.data);
    }
    return NetworkResult.error(handleError(result).error);
  }

  @override
  Future<NetworkResult<List<Comment>>> commentList() async {
    final result = await RestClient.instance.get(ApiList.commentList, isToken: true);
    if (result.status == Status.success) {
      // Assuming `result.data` is the JSON string you received
      final List<dynamic> data = jsonDecode(result.data)['data'];
      final List<Comment> fareList = [];
      for (var value in data) {
        fareList.add(Comment.fromJson(value));
      }
      return NetworkResult.success(fareList);
    }

    return NetworkResult.error(handleError(result).error);
  }

  @override
  Future<NetworkResult<Program>> liveProgram() async {
    final result = await RestClient.instance.get(ApiList.liveProgram, isToken: true);
    if (result.status == Status.success) {
      // Assuming `result.data` is the JSON string you received
      final Map<String, dynamic> responseData = json.decode(result.data);
      Program data = Program.fromJson(responseData['data']);

      return NetworkResult.success(data);
    }

    return NetworkResult.error(handleError(result).error);
  }

  @override
  Future<NetworkResult<LiveProgram>> getLiveProgram() async {
    return await _liveRadioApiService.getLiveProgram();
  }

  @override
  Future<NetworkResult<List<Program>>> programList(int userId) async {
    final result = await RestClient.instance.get('${ApiList.prgramList}?user_id=$userId', isToken: true);
    if (result.status == Status.success) {
      // Assuming `result.data` is the JSON string you received
      final List<dynamic> data = jsonDecode(result.data)['data'];
      final List<Program> fareList = [];
      for (var value in data) {
        fareList.add(Program.fromJson(value));
      }
      return NetworkResult.success(fareList);
    }

    return NetworkResult.error(handleError(result).error);
  }

  @override
  Future<NetworkResult<List<Program>>> programUserList(int userId) async {
    final result = await RestClient.instance.post(
        ApiList.programUserStar,
        {
          'user_id': userId,
        },
        isToken: true,
        extraHeaders: {"Content-Type": "application/json"});

    if (result.status == Status.success) {
      // Assuming `result.data` is the JSON string you received
      final List<dynamic> data = jsonDecode(result.data)['data'];
      final List<Program> fareList = [];
      for (var value in data) {
        Debug.trace(value);

        fareList.add(Program.fromJson(value));
      }
      return NetworkResult.success(fareList);
    }

    return NetworkResult.error(handleError(result).error);
  }

  @override
  Future<NetworkResult> programStar(int userId, int programId) async {
    final result = await RestClient.instance.post(
        ApiList.programStar,
        {
          'user_id': userId,
          'program_id': programId,
        },
        isToken: true,
        extraHeaders: {"Content-Type": "application/json"});
    if (result.status == Status.success) {
      return NetworkResult.success(result);
    }

    return NetworkResult.error(handleError(result).error);
  }

  @override
  Future<NetworkResult> commentSave(int userId, String comment) async {
    final result = await RestClient.instance.post(
        ApiList.commentSave,
        {
          'user_id': userId,
          'comment': comment,
        },
        isToken: true,
        extraHeaders: {"Content-Type": "application/json"});
    if (result.status == Status.success) {
      return NetworkResult.success(result);
    }

    return NetworkResult.error(handleError(result).error);
  }

  @override
  Future<NetworkResult<List<ProgramSchedule>>> getProgrammeSchedule() async {
    return await _programScheduleApiService.getProgramSchedule();
  }
}
