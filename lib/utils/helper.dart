
import 'package:shared_preferences/shared_preferences.dart';

class StringHelper {
  static const String noDataFound = "No data found";
  static const String errorMsgEmptyData = "Something went wrong! We are sorry for your inconvenience. Please try again.";
  static const quantity = "Quantity";
  static const price = "Price";
  static String exploreNewWay = "Explore new ways to\ntravel with CabTo";
  static const String error = "Error";
  static const String rupees = '₹';
}

class PrefHelper {
  static final PrefHelper _instance = PrefHelper();
  static SharedPreferences? prefs;

  static const String userCredentials = "userCredentials";
  static const String deviceToken = "deviceToken";
  static const String refreshToken = 'refreshToken';
  static const String isLogin = "isLogin";
  static const String accessToken = "accessToken";
  static const String userId = "userId";
  static const String token = "token";
  static const String tokenType = "tokenType";
  static const String corporateId = "corporateId";

  static Future<PrefHelper> getInstance() async {
    prefs ??= await SharedPreferences.getInstance();
    return _instance;
  }

  static PrefHelper get instance => _instance;

  void setBoolean(String key, bool? value) {
    if (value != null) {
      prefs?.setBool(key, value);
    }
  }

  bool getBoolean(String key, bool defaultVal) {
    if (prefs?.containsKey(key) == true) {
      return prefs!.getBool(key)!;
    } else {
      return defaultVal;
    }
  }

  void setString(String key, String? value) {
    if (value?.isNotEmpty == true) {
      prefs?.setString(key, value!);
    }
  }

  String getString(String key, String defaultVal) {
    if (prefs?.containsKey(key) == true) {
      return prefs!.getString(key)!;
    } else {
      return defaultVal;
    }
  }

  void setInt(String key, int? value) {
    if (value != null) {
      prefs?.setInt(key, value);
    }
  }

  int getInt(String key, int defaultVal) {
    if (prefs?.containsKey(key) == true) {
      return prefs!.getInt(key)!;
    } else {
      return defaultVal;
    }
  }

  void clearAllPreference() {
    String token = getString(deviceToken, "");
    prefs?.clear();
    setString(deviceToken, token);
  }
}
