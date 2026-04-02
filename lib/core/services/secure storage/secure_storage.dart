import 'dart:convert';

import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/user%20models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppSecureStorage {
  static SharedPreferences? _preferences;

  static Future<SharedPreferences?> getInstance() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
      return _preferences;
    }
    return _preferences;
  }

  // Keys - Auth
  static const String kAuthToken = "token";
  static const String kIsLogin = "is_login";
  static const String kFcmToken = "fcm_token";
  static const String kUserPassword = "user_password";

  // Keys - User Info
  static const String kUserId = "user_id";
  static const String kUserEmail = "user_email";
  static const String kUserPhone = "user_phone";
  static const String kUserProfileImage = "user_profile_image";
  static const String kFirstName = "first_name";
  static const String kLastName = "last_name";
  static const String kUserName = "user_name";
  static const String kUserDob = "user_dob";
  static const String kUserGender = "user_gender";
  static const String kUserAge = "user_age";
  static const String kUserBloodGroup = "user_blood_group";
  static const String kUserEmpId = "user_emp_id";
  static const String kUserLanguage = "user_language";
  static const String kUserType = "user_type";
  static const String kUserPrimary = "user_primary";
  static const String kCorporateId = "corporate_id";
  static const String kCorporateName = "corporate_name";
  static const String kCorporateCode = "corporate_code";
  static const String kIsSubscribed = "is_subscribed";
  static const String kIsDiabetic = "is_diabetic";
  static const String kIsBloodPressure = "is_blood_pressure";
  static const String kUserRelationship = "user_relationship";
  static const String kUserJson = "user_json";

  // Keys - Onboarding & Health Score
  static const String kOnboardingDone = "onboarding_done";
  static const String kHealthStatus = "health_status";

  /// Save complete login response (token + user info)
  static Future<void> saveLoginResponse(LoginResponse response) async {
    await addStringValueToSharedPref(
        variableName: kAuthToken, variableValue: response.token);
    await addBoolValueToSharedPref(
        variableName: kIsLogin, variableValue: true);
    await saveUserInfo(response.user);
  }

  /// Save user info to local storage
  static Future<void> saveUserInfo(UserModel user) async {
    await addIntValueToSharedPref(
        variableName: kUserId, variableValue: user.id);
    await addStringValueToSharedPref(
        variableName: kUserName, variableValue: user.name);
    await addStringValueToSharedPref(
        variableName: kFirstName, variableValue: user.firstName);
    await addStringValueToSharedPref(
        variableName: kLastName, variableValue: user.lastName);
    await addStringValueToSharedPref(
        variableName: kUserEmail, variableValue: user.email);
    await addStringValueToSharedPref(
        variableName: kUserPhone, variableValue: user.phone);
    if (user.dob != null) {
      await addStringValueToSharedPref(
          variableName: kUserDob, variableValue: user.dob!);
    }
    if (user.image != null) {
      await addStringValueToSharedPref(
          variableName: kUserProfileImage, variableValue: user.image!);
    }
    if (user.gender != null) {
      await addStringValueToSharedPref(
          variableName: kUserGender, variableValue: user.gender!);
    }
    await addIntValueToSharedPref(
        variableName: kUserAge, variableValue: user.age);
    if (user.bloodGroup != null) {
      await addStringValueToSharedPref(
          variableName: kUserBloodGroup, variableValue: user.bloodGroup!);
    }
    if (user.empId != null) {
      await addStringValueToSharedPref(
          variableName: kUserEmpId, variableValue: user.empId!);
    }
    if (user.language != null) {
      await addStringValueToSharedPref(
          variableName: kUserLanguage, variableValue: user.language!);
    }
    await addStringValueToSharedPref(
        variableName: kUserType, variableValue: user.type);
    await addStringValueToSharedPref(
        variableName: kUserPrimary, variableValue: user.primary);
    await addIntValueToSharedPref(
        variableName: kCorporateId, variableValue: user.corporateId);
    if (user.company != null) {
      await addStringValueToSharedPref(
          variableName: kCorporateName, variableValue: user.company!.name);
      await addStringValueToSharedPref(
          variableName: kCorporateCode, variableValue: user.company!.code);
    }
    await addBoolValueToSharedPref(
        variableName: kIsSubscribed, variableValue: user.isSubscribed);
    if (user.isDiabetic != null) {
      await addStringValueToSharedPref(
          variableName: kIsDiabetic, variableValue: user.isDiabetic!);
    }
    if (user.isBloodPressure != null) {
      await addStringValueToSharedPref(
          variableName: kIsBloodPressure, variableValue: user.isBloodPressure!);
    }

    // Store full JSON for complex fields
    await addStringValueToSharedPref(
        variableName: kUserJson, variableValue: jsonEncode(user.toJson()));
  }

  /// Get saved user as model (from stored JSON)
  static UserModel? getSavedUser() {
    final jsonStr = getStringFromSharedPref(variableName: kUserJson);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  /// Get the saved auth token
  static String? getToken() =>
      getStringFromSharedPref(variableName: kAuthToken);

  /// Check if user is logged in
  static bool isLoggedIn() =>
      getBoolValueFromSharedPref(variableName: kIsLogin) ?? false;

  /// ADD DATA
  static addStringValueToSharedPref(
      {required String variableName, required String variableValue}) async {
    await _preferences?.setString(variableName, variableValue);
  }

  static addBoolValueToSharedPref(
      {required String variableName, required bool variableValue}) async {
    await _preferences?.setBool(variableName, variableValue);
  }

  static addIntValueToSharedPref(
      {required String variableName, required int variableValue}) async {
    await _preferences?.setInt(variableName, variableValue);
  }

  static addStringListValueToSharedPref(
      {required String variableName,
        required List<String> variableValue}) async {
    await _preferences?.setStringList(variableName, variableValue);
  }

  static removeValueToSharedPref(
      {required String variableName}) async {
    await _preferences?.remove(variableName);
  }

  ///GET DATA
  static String? getStringFromSharedPref({required String variableName}) {
    String? returnValue = _preferences?.getString(variableName);
    return returnValue;
  }

  static int? getIntValueFromSharedPref({required String variableName}) {
    int? returnValue = _preferences?.getInt(variableName);
    return returnValue;
  }

  static bool? getBoolValueFromSharedPref({required String variableName}) {
    bool? returnValue = _preferences?.getBool(variableName);
    return returnValue;
  }

  static List<String>? getStringListValueFromSharedPref(
      {required String variableName}) {
    List<String>? returnValue = _preferences?.getStringList(variableName);
    return returnValue;
  }

  /// Onboarding status
  static bool isOnboardingDone() =>
      getBoolValueFromSharedPref(variableName: kOnboardingDone) ?? false;

  static Future<void> setOnboardingDone() async =>
      addBoolValueToSharedPref(variableName: kOnboardingDone, variableValue: true);

  /// Health score status: 0 = not completed, 1 = completed
  static int getHealthStatus() =>
      getIntValueFromSharedPref(variableName: kHealthStatus) ?? 0;

  static Future<void> setHealthStatus(int value) async =>
      addIntValueToSharedPref(variableName: kHealthStatus, variableValue: value);

  /// CLEAR SHARED PREFERENCE
  static Future clearSharedPref() async {
    PrintLog.printLog("Shared Preference clean...");
    _preferences?.clear();
  }
}