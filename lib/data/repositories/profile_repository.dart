import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';

class ProfileRepository {
  final ApiService apiService;

  ProfileRepository({required this.apiService});

  Future<Map<String, String>> getUserData() async {
    return {
      'firstName': AppSecureStorage.getStringFromSharedPref(
              variableName: AppSecureStorage.kFirstName) ??
          '',
      'lastName': AppSecureStorage.getStringFromSharedPref(
              variableName: AppSecureStorage.kLastName) ??
          '',
      'phone': AppSecureStorage.getStringFromSharedPref(
              variableName: AppSecureStorage.kUserPhone) ??
          '',
      'email': AppSecureStorage.getStringFromSharedPref(
              variableName: AppSecureStorage.kUserEmail) ??
          '',
      'profileImage': AppSecureStorage.getStringFromSharedPref(
              variableName: AppSecureStorage.kUserProfileImage) ??
          '',
    };
  }

  Future<void> updateProfileImage({required String path}) async {
    await AppSecureStorage.addStringValueToSharedPref(
      variableName: AppSecureStorage.kUserProfileImage,
      variableValue: path,
    );
  }

  Future<void> logout() async {
    await AppSecureStorage.clearSharedPref();
  }
}
