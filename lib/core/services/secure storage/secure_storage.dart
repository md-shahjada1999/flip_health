
import 'package:flip_health/core/utils/print_log.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppSecureStorage {
  // static final FlutterSecureStorage _storage = FlutterSecureStorage(
  //   iOptions: IOSOptions(
  //     accessibility: KeychainAccessibility.first_unlock_this_device, // Prevent persistence after uninstall
  //   ),
  // );

  static SharedPreferences? _preferences;

  static Future<SharedPreferences?> getInstance() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
      return _preferences;
    }
    return _preferences;
  }

  // Keys
  static const String kAuthToken = "token";
  static const String kIsLogin = "is_login";
  static const String kFcmToken = "fcm_token";
  static const String kUserId = "user_id";
  static const String kUserEmail = "user_email";
  static const String kUserPhone = "user_phone";
  static const String kUserPassword = "user_password";
  static const String kUserProfileImage = "user_profile_image";
  static const String kFirstName = "first_name";
  static const String kLastName = "last_name";

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

  /// CLEAR SHARED PREFERENCE
  static Future clearSharedPref() async {
    PrintLog.printLog("Shared Preference clean...");
    _preferences?.clear();
  }
}