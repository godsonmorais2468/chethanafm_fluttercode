import 'package:chethanafm/models/comment.dart';
import 'package:chethanafm/models/program.dart';
import 'package:chethanafm/models/live_program.dart';
import 'package:chethanafm/models/program_schedule.dart';
import 'package:chethanafm/models/auth_models.dart';
import 'package:chethanafm/repo/api_state.dart';

abstract class ApiClient {
  Future<NetworkResult> signup(String email, String name);
  Future<NetworkResult> login(String email);
  Future<NetworkResult<Program>> liveProgram();
  Future<NetworkResult<LiveProgram>> getLiveProgram();
  Future<NetworkResult> resendOTP(String email);
  Future<NetworkResult> loginOtpVerify(int userId, int otp, String deviceName);
  Future<NetworkResult> registerOtpVerify(int userId, int otp, String deviceName);
  Future<NetworkResult<List<Comment>>> commentList();
  Future<NetworkResult<List<Program>>> programList(int userId);
  Future<NetworkResult<List<Program>>> programUserList(int userId);
  Future<NetworkResult> programStar(int userId, int programId);
  Future<NetworkResult> commentSave(int userId, String comment);
  Future<NetworkResult<List<ProgramSchedule>>> getProgrammeSchedule();

  // HTTP API Services
  Future<NetworkResult<List<CountryCode>>> getCountryCodes();
  Future<NetworkResult<User>> getProfile(String token);
  Future<NetworkResult<LoginResponse>> loginWithPhone(String countryCode, String phone, String password);
  Future<NetworkResult<RegisterResponse>> registerWithPhone(String countryCode, String phone, String password, String confirmPassword, String name, String securityQuestion, String securityAnswer);
  Future<NetworkResult<void>> checkPhone(String phone);
  Future<NetworkResult<void>> resetPassword(String countryCode, String phone, String securityAnswer, String newPassword, String confirmPassword);
  Future<NetworkResult<List<dynamic>>> getSecurityQuestions();
  Future<NetworkResult<Map<String, dynamic>>> getSecurityQuestion(String countryCode, String phone);
  Future<NetworkResult<String>> verifyAnswer(String countryCode, String phone, String answer);
}
