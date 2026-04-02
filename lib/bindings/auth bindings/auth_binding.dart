import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/auth_repository.dart';
import 'package:flip_health/controllers/auth%20controllers/login_controller.dart';
import 'package:flip_health/controllers/auth%20controllers/otp_controllers.dart' show OTPController;

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    Get.lazyPut<AuthRepository>(
        () => AuthRepository(apiService: Get.find()));
    Get.lazyPut<LoginController>(
        () => LoginController(repository: Get.find()));
    Get.lazyPut<OTPController>(
        () => OTPController(repository: Get.find()));
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    Get.lazyPut<AuthRepository>(
        () => AuthRepository(apiService: Get.find()), fenix: true);
    Get.lazyPut<LoginController>(
        () => LoginController(repository: Get.find()), fenix: true);
  }
}

class OTPBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(
          () => AuthRepository(apiService: Get.find()));
    }
    Get.lazyPut<OTPController>(
        () => OTPController(repository: Get.find()));
  }
}