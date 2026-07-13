import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:chethanafm/models/auth_models.dart';
import 'package:chethanafm/repo/api_client.dart';
import 'package:chethanafm/repo/api_state.dart';
import 'package:chethanafm/repo/repository.dart';
import 'package:chethanafm/utils/helper.dart';
import 'package:chethanafm/services/secure_storage_service.dart';
import 'package:chethanafm/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final _secureStorage = SecureStorageService();
  final _firebaseAuthService = FirebaseAuthService();
  
  int _userId = 0;
  String _name = "";
  String _email = "";
  String _phone = "";
  bool _isLoading = false;
  List<Map<String, dynamic>> _securityQuestions = [];

  List<CountryCode> _countryCodes = [];
  String? _selectedCountryCode = "+91";
  User? _currentUser;
  String? _token;
  String? _errorMessage;

  static final List<Future<void> Function()> _onLogoutCallbacks = [];

  static void addOnLogoutCallback(Future<void> Function() callback) {
    _onLogoutCallbacks.add(callback);
  }

  static void removeOnLogoutCallback(Future<void> Function() callback) {
    _onLogoutCallbacks.remove(callback);
  }

  AuthViewModel({ApiClient? apiClient}) : _apiClient = apiClient ?? Repository.instance {
    _loadUserSession();
  }

  int get userId => _userId;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userId != 0;
  List<Map<String, dynamic>> get securityQuestions => _securityQuestions;

  List<CountryCode> get countryCodes => _countryCodes;
  String? get selectedCountryCode => _selectedCountryCode;
  User? get currentUser => _currentUser;
  String? get token => _token;
  String? get errorMessage => _errorMessage;

  set selectedCountryCode(String? code) {
    _selectedCountryCode = code;
    notifyListeners();
  }

  Future<void> _syncUserWithFirebase() async {
    if (_userId == 0) return;
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      final docRef = FirebaseFirestore.instance.collection('users').doc(_userId.toString());
      await docRef.set({
        'userId': _userId.toString(),
        'name': _name,
        'phoneNumber': _phone,
        'profileImage': 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_name)}&background=random',
        'online': true,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Firebase user sync error: $e");
    }
  }

  Future<void> _loadUserSession() async {
    final helper = PrefHelper.prefs;
    if (helper != null) {
      _userId = helper.getInt(PrefHelper.userId) ?? 0;
      _name = helper.getString("userName") ?? "";
      _email = helper.getString("userEmail") ?? "";
      _phone = helper.getString("userPhone") ?? "";
      _selectedCountryCode = helper.getString("userCountryCode") ?? "+91";
      _token = helper.getString(PrefHelper.token) ?? "";
    }
    
    final savedToken = await _secureStorage.getToken();
    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
    } else {
      _userId = 0;
      _token = null;
    }
    
    if (_userId != 0 && _token != null) {
      _currentUser = User(
        id: _userId,
        name: _name,
        countryCode: _selectedCountryCode ?? "+91",
        phoneNumber: _phone,
      );
      _syncUserWithFirebase();
      getProfile();
    }
    notifyListeners();
  }

  Future<void> loadCountryCodes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiClient.getCountryCodes();
    if (result.status == Status.success && result.data != null) {
      _countryCodes = result.data!;
      bool foundDefault = _countryCodes.any((c) => c.code == "+91");
      if (foundDefault) {
        _selectedCountryCode = "+91";
      } else if (_countryCodes.isNotEmpty) {
        _selectedCountryCode = _countryCodes.first.code;
      }
    } else {
      _errorMessage = result.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getProfile() async {
    final currentToken = _token ?? await _secureStorage.getToken();
    if (currentToken == null || currentToken.isEmpty) return;

    final result = await _apiClient.getProfile(currentToken);
    if (result.status == Status.success && result.data != null) {
      _currentUser = result.data!;
      _userId = _currentUser!.id;
      _name = _currentUser!.name;
      _phone = _currentUser!.phoneNumber;
      _selectedCountryCode = _currentUser!.countryCode;

      final prefs = PrefHelper.prefs;
      if (prefs != null) {
        prefs.setInt(PrefHelper.userId, _userId);
        prefs.setString("userName", _name);
        prefs.setString("userPhone", _phone);
        prefs.setString("userCountryCode", _selectedCountryCode ?? "+91");
      }
      notifyListeners();
    }
  }

  Future<void> login(String countryCode, String phone, String password, Function(NetworkResult) callback) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiClient.loginWithPhone(countryCode, phone, password);

    if (result.status == Status.success && result.data != null) {
      final loginResponse = result.data!;
      _currentUser = loginResponse.user;
      _userId = _currentUser!.id;
      _name = _currentUser!.name;
      _phone = _currentUser!.phoneNumber;
      _selectedCountryCode = _currentUser!.countryCode;
      _token = loginResponse.token;
      _email = "";

      await _secureStorage.saveToken(loginResponse.token);

      final prefs = PrefHelper.prefs;
      if (prefs != null) {
        prefs.setInt(PrefHelper.userId, _userId);
        prefs.setBool(PrefHelper.isLogin, true);
        prefs.setString("userName", _name);
        prefs.setString("userEmail", _email);
        prefs.setString("userPhone", _phone);
        prefs.setString("userCountryCode", _selectedCountryCode ?? "+91");
        prefs.setString(PrefHelper.token, loginResponse.token);
      }

      _isLoading = false;
      notifyListeners();
      await _syncUserWithFirebase();
      callback(NetworkResult.success("Login successful"));
    } else {
      _errorMessage = result.error;
      _isLoading = false;
      notifyListeners();
      callback(NetworkResult.error(result.error));
    }
  }

  Future<void> loginWithPassword(String phone, String password, Function(NetworkResult) callback) async {
    await login(_selectedCountryCode ?? "+91", phone, password, callback);
  }

  Future<void> loginWithSocial(String provider, Function(NetworkResult) callback) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1000));

    _userId = 999;
    _name = provider == "Google" ? "Google User" : "Facebook User";
    _email = "${provider.toLowerCase()}user@gmail.com";
    _phone = "9876543210";
    _selectedCountryCode = "+91";
    _token = "mock_social_token_${provider.toLowerCase()}";
    
    _currentUser = User(
      id: _userId,
      name: _name,
      countryCode: _selectedCountryCode!,
      phoneNumber: _phone,
    );

    final prefs = PrefHelper.prefs;
    if (prefs != null) {
      prefs.setInt(PrefHelper.userId, _userId);
      prefs.setBool(PrefHelper.isLogin, true);
      prefs.setString("userName", _name);
      prefs.setString("userEmail", _email);
      prefs.setString("userPhone", _phone);
      prefs.setString("userCountryCode", _selectedCountryCode!);
      prefs.setString(PrefHelper.token, _token!);
    }

    _isLoading = false;
    notifyListeners();
    callback(NetworkResult.success("Logged in with $provider"));
  }

  Future<void> signup(String email, String name, Function(NetworkResult) callback) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiClient.signup(email, name);
    _isLoading = false;
    notifyListeners();
    callback(result);
  }

  Future<void> register(
      String name,
      String countryCode,
      String phone,
      String password,
      String confirmPassword,
      String securityQuestion,
      String securityAnswer,
      Function(NetworkResult) callback) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiClient.registerWithPhone(
      countryCode,
      phone,
      password,
      confirmPassword,
      name,
      securityQuestion,
      securityAnswer,
    );

    if (result.status == Status.success && result.data != null) {
      final registerResponse = result.data!;
      _currentUser = registerResponse.user;
      _userId = _currentUser!.id;
      _name = _currentUser!.name;
      _phone = _currentUser!.phoneNumber;
      _selectedCountryCode = _currentUser!.countryCode;
      _token = registerResponse.token;
      _email = "";

      await _secureStorage.saveToken(registerResponse.token);

      final prefs = PrefHelper.prefs;
      if (prefs != null) {
        prefs.setInt(PrefHelper.userId, _userId);
        prefs.setBool(PrefHelper.isLogin, true);
        prefs.setString("userName", _name);
        prefs.setString("userEmail", _email);
        prefs.setString("userPhone", _phone);
        prefs.setString("userCountryCode", _selectedCountryCode ?? "+91");
        prefs.setString(PrefHelper.token, registerResponse.token);
      }

      await _syncUserWithFirebase();
    }

    _isLoading = false;
    _errorMessage = result.error;
    notifyListeners();
    callback(result);
  }

  Future<void> registerWithPassword(String phone, String password, String confirmPassword, String name, String securityQuestion, String securityAnswer, Function(NetworkResult) callback) async {
    await register(
      name,
      _selectedCountryCode ?? "+91",
      phone,
      password,
      confirmPassword,
      securityQuestion,
      securityAnswer,
      callback,
    );
  }

  Future<void> checkPhone(String phone, Function(NetworkResult) callback) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiClient.checkPhone(phone);
    _isLoading = false;
    notifyListeners();
    callback(result);
  }

  Future<void> sendFirebaseOtp(
    String phoneNumber,
    Function(String verificationId) onSuccess,
    Function(String error) onFailure,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseAuthService.sendOtp(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId, resendToken) {
          _isLoading = false;
          notifyListeners();
          onSuccess(verificationId);
        },
        onVerificationFailed: (e) {
          _isLoading = false;
          notifyListeners();
          String errorMsg = e.message ?? 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            errorMsg = 'The provided phone number is not valid.';
          } else if (e.code == 'too-many-requests') {
            errorMsg = 'Too many requests. Please try again later.';
          }
          onFailure(errorMsg);
        },
        onVerificationCompleted: (credential) {
          // Future auto verification step
        },
        onAutoRetrievalTimeout: (verificationId) {
          // Timeout
        },
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onFailure(e.toString());
    }
  }

  Future<void> verifyOtp(String email, int tempUserId, String otp, String type, Function(NetworkResult) callback) async {
    _isLoading = true;
    notifyListeners();

    final parsedOtp = int.tryParse(otp) ?? 0;
    NetworkResult result;
    if (type == "register") {
      result = await _apiClient.registerOtpVerify(tempUserId, parsedOtp, "mobile");
    } else {
      result = await _apiClient.loginOtpVerify(tempUserId, parsedOtp, "mobile");
    }

    if (result.status == Status.success) {
      final data = jsonDecode(result.data);
      final userMap = data['data']['user'];
      _userId = userMap['id'];
      _name = userMap['name'] ?? "";
      _email = userMap['email'] ?? email;
      _phone = userMap['phone_number'] ?? "";
      _selectedCountryCode = userMap['country_code'] ?? "+91";
      _token = data['data']['token'] ?? "";

      _currentUser = User(
        id: _userId,
        name: _name,
        countryCode: _selectedCountryCode!,
        phoneNumber: _phone,
      );
      
      final prefs = PrefHelper.prefs;
      if (prefs != null) {
        prefs.setInt(PrefHelper.userId, _userId);
        prefs.setBool(PrefHelper.isLogin, true);
        prefs.setString("userName", _name);
        prefs.setString("userEmail", _email);
        prefs.setString("userPhone", _phone);
        prefs.setString("userCountryCode", _selectedCountryCode!);
        prefs.setString(PrefHelper.token, _token!);
      }
      await _syncUserWithFirebase();
    }

    _isLoading = false;
    notifyListeners();
    callback(result);
  }

  Future<void> updateProfile(String newName, String newPhone, Function(bool) callback) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate API delay
    
    _name = newName;
    _phone = newPhone;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: newName,
        phoneNumber: newPhone,
      );
    }
    
    final prefs = PrefHelper.prefs;
    if (prefs != null) {
      prefs.setString("userName", _name);
      prefs.setString("userPhone", _phone);
    }
    
    _isLoading = false;
    notifyListeners();
    await _syncUserWithFirebase();
    callback(true);
  }

  Future<void> loadSecurityQuestions() async {
    await fetchSecurityQuestions();
  }

  Future<void> fetchSecurityQuestions() async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiClient.getSecurityQuestions();
    if (result.status == Status.success) {
      _securityQuestions = List<Map<String, dynamic>>.from(result.data ?? []);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getSecurityQuestion(String countryCode, String phone, Function(NetworkResult) callback) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiClient.getSecurityQuestion(countryCode, phone);
    _isLoading = false;
    notifyListeners();
    callback(result);
  }

  Future<void> verifySecurityAnswer(String countryCode, String phone, String answer, Function(NetworkResult) callback) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiClient.verifyAnswer(countryCode, phone, answer);
    _isLoading = false;
    notifyListeners();
    callback(result);
  }

  Future<void> verifyAnswer(String countryCode, String phone, String answer, Function(NetworkResult) callback) async {
    await verifySecurityAnswer(countryCode, phone, answer, callback);
  }

  Future<void> changePassword(String currentPassword, String newPassword, Function(bool, String) callback) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1000));
    _isLoading = false;
    notifyListeners();
    callback(true, "Password changed successfully");
  }

  Future<void> deleteAccount(Function(bool) callback) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    
    await logout();
    _isLoading = false;
    notifyListeners();
    callback(true);
  }

  Future<void> logout() async {
    for (final callback in List.of(_onLogoutCallbacks)) {
      try {
        await callback();
      } catch (e) {
        debugPrint("Error in logout callback: $e");
      }
    }

    if (_userId != 0) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(_userId.toString()).set({
          'online': false,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint("Error setting user offline in Firebase: $e");
      }
    }

    _userId = 0;
    _name = "";
    _email = "";
    _phone = "";
    _token = null;
    _currentUser = null;
    _errorMessage = null;
    
    await _secureStorage.deleteToken();
    
    final prefs = PrefHelper.prefs;
    if (prefs != null) {
      prefs.remove(PrefHelper.userId);
      prefs.remove(PrefHelper.isLogin);
      prefs.remove("userName");
      prefs.remove("userEmail");
      prefs.remove("userPhone");
      prefs.remove("userCountryCode");
      prefs.remove(PrefHelper.token);
    }
    notifyListeners();
  }

  Future<void> resendOtp(String email, Function(NetworkResult) callback) async {
    final result = await _apiClient.resendOTP(email);
    callback(result);
  }

  Future<void> verifyFirebaseOtp(
    String verificationId,
    String smsCode,
    Function() onSuccess,
    Function(String error) onFailure,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _isLoading = false;
      notifyListeners();
      onSuccess();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFailure(e.message ?? 'Invalid OTP code');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onFailure(e.toString());
    }
  }

  Future<void> resetPassword(
    String countryCode,
    String phone,
    String securityAnswer,
    String newPassword,
    String confirmPassword,
    Function(NetworkResult) callback,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiClient.resetPassword(countryCode, phone, securityAnswer, newPassword, confirmPassword);
    
    if (result.status == Status.success) {
      await logout();
    }
    
    _isLoading = false;
    notifyListeners();
    callback(result);
  }
}
